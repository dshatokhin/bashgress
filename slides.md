---
author: Denis Shatokhin
date: dd MMMM YYYY
paging: "%d / %d"
---

# Bashgress: let's build a simple ingress-controller

```plain




██████╗  █████╗ ███████╗██╗  ██╗ ██████╗ ██████╗ ███████╗███████╗███████╗
██╔══██╗██╔══██╗██╔════╝██║  ██║██╔════╝ ██╔══██╗██╔════╝██╔════╝██╔════╝
██████╔╝███████║███████╗███████║██║  ███╗██████╔╝█████╗  ███████╗███████╗
██╔══██╗██╔══██║╚════██║██╔══██║██║   ██║██╔══██╗██╔══╝  ╚════██║╚════██║
██████╔╝██║  ██║███████║██║  ██║╚██████╔╝██║  ██║███████╗███████║███████║
╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝

         Demystifying what the ingress controller actually does

```

---
## The scope of this presentation

- What is an ingress-controller?
  - Example of `ingress-nginx`
- Disclaimer
- Our approach for a simple ingress-controller
  - Envoy
- Demo
- Links
- Questions

---
## What is an ingress-controller?

Usually there are 2 main components:
- `control-plane` - watches K8S objects and creates dynamic config for data-plane
- `data-plane` - proxy server doing actual routing of incoming traffic to pods

`control-plane` ensures that K8S objects (`ingress` or `gateway` APIs) converted to
the   valid configuration for the `data-plane`.

`data-plane` only follows the configuration provided by `control-plane` and
doing the routing/proxying

Popular proxy servers:

- `Nginx`
- `HAProxy`
- `Traefik`
- `Apache APISIX`
- `Envoy`

---

### Example of `ingress-nginx`

Both `control-plane` and `data-plane` combined together into one container:

```shell
$ ps -o pid,args
PID     COMMAND
    1   /usr/bin/dumb-init <long args string>
    7   /nginx-ingress-controller <long args string>
   26   nginx: master process /usr/bin/nginx -c /etc/nginx/nginx.conf
88163   nginx: worker process
88164   nginx: worker process
88165   nginx: worker process
88166   nginx: worker process
88167   nginx: worker process
88168   nginx: worker process
88169   nginx: worker process
88170   nginx: worker process
88173   nginx: cache manager process
```

---

### Example of `ingress-nginx`

Right after the install `ingress-nginx` has 562 lines in `/etc/nginx/nginx.conf`.

After adding 2 simple ingress objects config becomes 835 lines long.

It is not good or bad - this only means that it would be really difficult to understand how it works.

That's why we're building our own ingress controller.

---

## Disclaimer

- this is not `production ready` solution
- lacking `HTTPS` support
- only understands port numbers and not port names in `ingress` objects
- build for the sake of learning

---

## Our approach for a simple ingress-controller

We'll draw the line between `control-plane` and `data-plane` but allow them to communicate.

`control-plane` components:

- `kubectl` - getting ingress objects
- `jq` - transforming ingress objects into config for proxy server
- `bash` - gluing things together

`data-plane` components:

- `envoy` - proxy server to read config and route requests

---

### Envoy

Build by LYFT, `v1.0.0` relesead back in 2016

From the official documentation:

> Envoy is an L7 proxy and communication bus designed for large modern service oriented architectures.
> The project was born out of the belief that:  
> _The network should be transparent to applications._
> _When network and application problems do occur it_
> _should be easy to determine the source of the problem._

- L3/L4 - TCP/UDP, HTTP, TLS, custom protocols like `postgres`, `redis` etc
- HTTP L7 - buffering, rate limiting, routing/forwarding (what we using in our case)
- HTTP/1.1, HTTP/2, HTTP/3 support
- service discovery and dynamic configuration (we are using it as well)
- really good observability
- could be extended via LUA or WASM
- written in `C++`

---

### And now it's time for...

```plain



     _____        ______        ______  _______           _____
 ___|\    \   ___|\     \      |      \/       \     ____|\    \
|    |\    \ |     \     \    /          /\     \   /     /\    \
|    | |    ||     ,_____/|  /     /\   / /\     | /     /  \    \
|    | |    ||     \--'\_|/ /     /\ \_/ / /    /||     |    |    |
|    | |    ||     /___/|  |     |  \|_|/ /    / ||     |    |    |
|    | |    ||     \____|\ |     |       |    |  ||\     \  /    /|
|____|/____/||____ '     /||\____\       |____|  /| \_____\/____/ |
|    /    | ||    /_____/ || |    |      |    | /  \ |    ||    | /
|____|____|/ |____|     | / \|____|      |____|/    \|____||____|/
  \(    )/     \( |_____|/     \(          )/          \(    )/
   '    '       '    )/         '          '            '    '
                     '
```

---

## Links

- This repo (including slides)
  > https://gitlab.com/dshatokhin/bashgress
- Envoy Sandboxes to play with
  > https://www.envoyproxy.io/docs/envoy/v1.29.1/start/sandboxes
- Envoy Dynamic Configuration using filesystem
  > https://www.envoyproxy.io/docs/envoy/v1.29.1/start/sandboxes/dynamic-configuration-filesystem
- Contour - envoy-based ingress-controller
  > https://projectcontour.io
- List of ingress-controllers for Kubernetes
  > https://kubernetes.io/docs/concepts/services-networking/ingress-controllers
- Apple PKL K8S examples
  > https://github.com/apple/pkl-k8s-examples

---

## Questions

```plain



   .-''''-..        .-''''-..        .-''''-..        .-''''-..     
 .' .'''.   `.    .' .'''.   `.    .' .'''.   `.    .' .'''.   `.   
/    \   \    `. /    \   \    `. /    \   \    `. /    \   \    `. 
\    '   |     | \    '   |     | \    '   |     | \    '   |     | 
 `--'   /     /   `--'   /     /   `--'   /     /   `--'   /     /  
      .'  ,-''         .'  ,-''         .'  ,-''         .'  ,-''   
      |  /             |  /             |  /             |  /       
      | '              | '              | '              | '        
      '-'              '-'              '-'              '-'        
     .--.             .--.             .--.             .--.        
    /    \           /    \           /    \           /    \       
    \    /           \    /           \    /           \    /       
     `--'             `--'             `--'             `--'        
```
