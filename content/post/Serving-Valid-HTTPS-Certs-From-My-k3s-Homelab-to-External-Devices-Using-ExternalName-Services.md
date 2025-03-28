---
title: "Serving Valid HTTPS Certs From My K3s Homelab to External Devices Using ExternalName Services"
date: 2025-03-28T13:26:42-04:00
tags:
    - bash
    - homelab
    - https
---

It isn’t particularly sexy, but one of my favorite things about my k3s homelab is that I took the time early in its creation to get proper HTTPS certificates, and automate their renewal. I think it’s great that all the top-shelf browsers require sites to use HTTPS, but it’s a nightmare for self-hosting when you have to click through several pages of warnings to hit any of your own services.

After several attempts, I finally figured out how to take advantage of this setup for things running on my network but outside of the cluster.  My first instinct was to try to find a way to sync the wildcard cert to all my external devices, but it expires every 90 days, and I need it on six different devices from six different manufacturers. That would have been a huge hassle to figure out, and I’m not even sure it would have been possible to automate fully. It turns out this is a fairly easy thing to do using a Kubernetes Service Type I was previously unfamiliar with: `ExternalName`.

An `Ingress` pointed at an `ExternalName` `Service` works kind of like a DNS CNAME, or an HTTPS redirect. My browser hits the `IngressController` inside my k3s cluster, and that redirects me to the device on my local network external to the cluster. Since it’s the same `IngressController` everything else uses I’m served a valid cert for HTTPS between my browser and the `Ingress`. If the actual device running external to the cluster isn’t hosting a self-signed cert then the connection between the cluster and the device isn’t encrypted, but at least it’s all inside my local network. If the external (to the cluster, not my local network) device does have a self-signed cert, the `IngressController` silently accepts it by default and my connection is secure end-to-end, and I don’t get any warnings in my browser because the browser was served the valid cert that the `IngressController` served.

Here's a real-life example. Hitting `https://nas01.crt.house` (if you're on my local network, of course) goes to my internal `IngressController` which serves a valid cert for `*.crt.house`, and proxies the traffic from `https://nas01.local:5001` (the UI for my NAS).

All this takes (aside from [my `IngressController` setup](https://github.com/charlesthomas/homelab-nginx-internal/)) is a `Service` of type `ExternalName`:

```yaml
---
apiVersion: v1
kind: Service
metadata:
  name: nas01
  namespace: external-ingresses
spec:
  type: ExternalName
  externalName: nas01.local
```

and an `Ingress` configured to use that `Service`:

```yaml
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nas01
  namespace: external-ingresses
  annotations:
    external-dns.alpha.kubernetes.io/hostname: nas01.crt.house
    nginx.ingress.kubernetes.io/backend-protocol: HTTPS
spec:
  ingressClassName: nginx-internal
  rules:
  - host: nas01.crt.house
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nas01
            port:
              number: 5001
  tls:
  - hosts:
    - nas01.crt.house
```

I've only hooked up a couple of these so far, but I expect to add more. So I wrote a quick template and script to easily add more; with or without the `backend-service: HTTPS` annotation. As with everything in my [homelab](https://github.com/charlesthomas/homelab) (except `Secrets`), [everything is open-source](https://github.com/charlesthomas/homelab-external-ingresses).
