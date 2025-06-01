# Argo CD Docker Image with Helm Secrets Support

This Argo CD Docker image comes pre-built with support for encrypted Helm value files using [SOPS](https://github.com/mozilla/sops). No manual image building is required.

### Included Tools

* **GnuPG** – For PGP key management
* **Helm Sops (helm-secrets plugin)** – For decrypting Helm secrets

---

## 1. Use the Pre-Built Custom Image

Only the `argocd-repo-server` component requires the custom image. Other Argo CD components can continue using upstream images.

### Example Helm Configuration

```yaml
repoServer:
  image:
    repository: camptocamp/argocd
    tag: v3.0.5_c2c.1
    imagePullPolicy: ""
```

---

## 2. Export Your GPG Private Key

Before creating the Kubernetes secret, export your GPG private key in ASCII-armored format:

```bash
gpg --armor --export-secret-keys <key-id> > key.asc
```

Replace `<key-id>` with your actual GPG key ID. This file (`key.asc`) will be used in the next step.

---

### Reference the Secret in Argo CD

```yaml
repoServer:
  volumes:
    - name: "gpg-private-key"
      secret:
        secretName: "argocd-secret"
        items:
          - key: "gpg.privkey.asc"
            path: "privkey.asc"
        defaultMode: 0600
```

---

## 3. Mount the GPG Key in the Container

Make the GPG key accessible to Helm inside the `argocd-repo-server` container:

```yaml
repoServer:
  volumeMounts:
    - name: "gpg-private-key"
      mountPath: "/app/config/gpg/privkey.asc"
      subPath: "privkey.asc"
```

> The `helm-secrets` plugin will use this path to access GPG keys during chart decryption.

---

## 4. Allow Helm Secrets Schemes in `argocd-cm` ConfigMap

By default, Argo CD only allows `http://` and `https://` value file schemes. To support `helm-secrets` schemes, update the `argocd-cm` ConfigMap:

```yaml
configs:
  cm:
    helm.valuesFileSchemes: >-
      secrets+gpg-import, secrets+gpg-import-kubernetes,
      secrets+age-import, secrets+age-import-kubernetes,
      secrets, secrets+literal,
      https
```

> This enables Argo CD to recognize and process encrypted Helm value files using schemes like `secrets+gpg-import://`.

