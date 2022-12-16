# Homelab k3s cluster

## Setup

```bash
# Install k3s
curl -sfL https://get.k3s.io | sh -s - --flannel-backend=wireguard-native \
--disable=traefik \
--disable=servicelb \
--disable=local-storage \
--write-kubeconfig-mode=644
```

```bash
# Install flux
flux bootstrap github \
  --owner=muchobien \
  --repository=homelab \
  --path=clusters/k3s \
  --ssh-key-algorithm=ed25519
```
