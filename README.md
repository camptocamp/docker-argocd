# Argo CD Docker Image

This Argo CD Docker Image contains the necessary tools to make use of Helm value files encrypted using Sops.

The following tools have been added to the image:

- AWS CLI
- GnuPG
- [Helm Sops](https://github.com/camptocamp/helm-sops)

Helm Sops is installed to transparently wrap Helm. This way, there is no need to configure a custom tool in Argo CD and native Helm functionalities can still be used (such as *valueFiles* or *values*).

Argo CD repository server binary is wrapped by a shell script which can import a GPG private key if it exists. The key must be located at `/app/config/gpg/privkey.asc`.

## Usage

### Encrypting Helm value files

Read [Helm Sops documentation](https://github.com/camptocamp/helm-sops) to start using Helm encrypted value files.

### Deploying Argo CD using the Helm chart

#### Using the custom image

To use this custom image when deploying Argo CD using the [Helm chart](https://github.com/argoproj/argo-helm/tree/master/charts/argo-cd), add the following lines to the chart value file:

```yaml
global:
  image:
    repository: "camptocamp/argocd"
    tag: "v1.4.2_c2c.1"
```

#### Using Sops with a GPG key

In order to use Sops with a GPG key, add the following lines to the chart value file:

```yaml
global:
  securityContext:
    fsGroup: 2000

repoServer:
  volumes:
    - name: "gpg-private-key"
      secret:
        secretName: "argocd-secret"
        items:
          - key: "gpg.privkey.asc"
            path: "privkey.asc"
        defaultMode: 0600
  volumeMounts:
    - name: "gpg-private-key"
      mountPath: "/app/config/gpg"
```

and add the following lines to an encrypted value file (the GPG private key can be exported by running `gpg --export-secret-keys --armor <key ID>`:

```yaml
configs:
  secret:
    extra:
      gpg.privkey.asc: |
        -----BEGIN PGP PRIVATE KEY BLOCK-----
        
        ...
        -----END PGP PRIVATE KEY BLOCK-----
```

#### Using Sops with an AWS KMS key

In order to use Sops with an AWS KMS key and if [instance profiles](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-ec2.html) cannot be used, add the following lines to the chart value file:

```yaml
repoServer:
  env:
    - name: "AWS_ACCESS_KEY_ID"
      valueFrom:
        secretKeyRef:
          name: "argocd-secret"
          key: "aws.accessKeyId"
    - name: "AWS_SECRET_ACCESS_KEY"
      valueFrom:
        secretKeyRef:
          name: "argocd-secret"
          key: "aws.secretAccessKey"
```

and add the following lines to an encrypted value file (create a dedicated IAM Access Key):

```yaml
configs:
  secret:
    extra:
      aws.accessKeyId: <Access Key ID>
      aws.secretAccessKey: <Secret Access Key>
```

## Example application

An example application as well as an example Argo CD setup to deploy it can be found [here](https://github.com/camptocamp/argocd-helm-sops-example).
