#!/usr/bin/env bash

set -e

config_path=${BASHGRESS_CONFIG_PATH:="/config"}

echo '{
  "resources":[]
}' >"${config_path}/cds.json"

echo '{
  "resources":[{
    "@type":"type.googleapis.com/envoy.config.route.v3.RouteConfiguration",
    "name":"ingress_http",
    "virtual_hosts":[]
  }]
}' >"${config_path}/rds.json"

while true; do
  routes='[]'
  clusters='[]'

  ingress_objects=$(kubectl get ingress -o name)
  while read -r ingress; do
    json=$(kubectl get "$ingress" -o json | jq -c)
    ingressClass=$(jq -r '.spec.ingressClassName' <<<"$json")

    if [[ $ingressClass = "bashgress" ]]; then
      namespace=$(jq -r '.metadata.namespace' <<<"$json")
      host=$(jq -r '.spec.rules[0].host' <<<"$json")
      service_name=$(jq -r '.spec.rules[0].http.paths[0].backend.service.name' <<<"$json")
      service_port=$(jq -r '.spec.rules[0].http.paths[0].backend.service.port.number' <<<"$json")
      service_path=$(jq -r '.spec.rules[0].http.paths[0].path' <<<"$json")

      echo "==> Applying ingress settings for $host"

      routes=$(
        jq \
          --arg DOMAIN "$host" \
          --arg PREFIX "$service_path" \
          --arg CLUSTER "${namespace}-${service_name}-${service_port}" \
          '. += [{
            "name": "service",
            "domains": [ $DOMAIN ],
            "routes": [{
              "match": { "prefix": $PREFIX },
              "route": { "cluster": $CLUSTER }
            }]
          }]' <<<"$routes"
      )

      clusters=$(
        jq \
          --arg CLUSTER "${namespace}-${service_name}-${service_port}" \
          --arg ADDRESS "${service_name}.${namespace}" \
          --arg PORT "$service_port" \
          '. += [{
            "@type": "type.googleapis.com/envoy.config.cluster.v3.Cluster",
            "name": $CLUSTER,
            "type": "STRICT_DNS",
            "load_assignment": {
              "cluster_name": $CLUSTER,
              "endpoints": [{
                "lb_endpoints": [{
                  "endpoint": {
                    "address": {
                      "socket_address": {
                        "address": $ADDRESS,
                        "port_value": $PORT | tonumber
                      }
                    }
                  }
                }]
              }]
            }
          }]' <<<"$clusters"
      )
    fi
  done <<<"$ingress_objects"

  jq --argjson r "$routes" '.resources[0].virtual_hosts = $r' "${config_path}/rds.json" \
    >"/tmp/rds.json" && mv "/tmp/rds.json" "${config_path}/rds.json"

  jq --argjson c "$clusters" '.resources = $c' "${config_path}/cds.json" \
    >"/tmp/cds.json" && mv "/tmp/cds.json" "${config_path}/cds.json"

  touch "${config_path}/updated" && mv "${config_path}/updated" "${config_path}/trigger" && rm "${config_path}/trigger"

  sleep 10
done
