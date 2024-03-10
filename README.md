# DEVOPS_SCRIPTS

--- Steps to use a self signed certificate in the kubernetes cluster.

# Self-Signed Certificates in Kubernetes
 
## Steps

1. Create a Certificate Authority
    a. Create a CA private key
    ```bash
    openssl genrsa -out ca.key 4096
    ```
    b. Create a CA certificate
    ```bash
    openssl req -new -x509 -sha256 -days 365 -key ca.key -out ca.crt
    ```
    c. Import the CA certificate in the `trusted Root Ca store` of your clients
2. Convert the content of the key and crt to base64 oneline
    ```bash
    cat ca.crt | base64 -w 0
    cat ca.key | base64 -w 0
    ```
3. Create a secret object `nginx1-ca-secret.yml` and put in the key and crt content
4. Create a cluster issuer object `nginx1-clusterissuer.yml`
5. Create a new certificate `nginx1-cert.yml` for your projects
6. Add a `tls` reference in your ingress `nginx1-ingress.yml`
7. Apply all changes

## Architecture Diagram

```
                Cert-Manager Objects                        Nginx1 Objects

               ┌───────────────────────┐                    ┌─────────────────────────────────┐
Created CA     │ kind: Secret          │                    │                                 │
private key ──►│ name: nginx1-ca-secret│◄─────────┐         │ kind: Ingress                   │
and cert       │ tls.key: **priv key** │          │         │ name: nginx1-ingress            │
               │ tls.crt: **cert**     │          │         │ tls:                            │
               └───────────────────────┘          │         │   - hosts:                      │
                                                  │         │     - nginx1.clcreative.home    │
               ┌──────────────────────────────┐   │    ┌────┼───secretName: nginx1-tls-secret │
               │                              │   │    │    │                                 │
               │ kind: ClusterIssuer          │   │    │    └─────────────────────────────────┘
           ┌───┤►name: nginx1-clusterissuer   │   │    │
           │   │ secretName: nginx1-ca-secret─┼───┘    │
           │   │                              │        │
           │   └──────────────────────────────┘        │
           │                                           │
           │   ┌───────────────────────────────┐       │
           │   │                               │       │
           │   │ kind: Certificate             │       │
           │   │ name: nginx1-cert             │       │
           └───┼─issuerRef:                    │       │
               │   name: nginx1-clusterissuer  │       │
               │   kind: ClusterIssuer         │       │
               │ dnsNames:                     │       │
               │   - nginx1.clcreative.home    │       │
           ┌───┼─secretName: nginx1-tls-secret │       │
           │   │                               │       │
           │   └──────────┬────────────────────┘       │
           │              │                            │
           │              │ will be created            │
           │              ▼ and managed automatically  │
           │   ┌───────────────────────────────┐       │
           │   │                               │       │
           │   │ kind: Secret                  │       │
           └───┤►name: nginx1-tls-secret◄──────┼───────┘
               │                               │
               └───────────────────────────────┘
```
#  Steps to solve Git Merge conflicts which are:- 
  1. The Git merge conflict arises when a pull request is opened and then the merge conflict is arises.
  2. In that case the conflict ocuurs in the following command :- git push upstream main
  3. Check for the git rebase --main
  4. Then you have to push the changes forcefully
  5. git push -f origin main

# Datree CLI installation and usage:- 
  1. The Datree is cli tool that check the kubernetes manifests before applying in the production it basically check the maniest yaml file using production env.

# Kubecost:- Monitoring the cost of the kubernetes env is very essentials:-
 1. This tool help us to monitor the cost of the kubernetes env. Using the following commands install the kubecost onto your cluster in a separate namespace.
 2. helm install kubecost cost-analyzer \
--repo https://kubecost.github.io/cost-analyzer/ \
--namespace kubecost --create-namespace \
--set kubecostToken="c2liYXNpc2hzYXRwYXRoeTIwMDJAZ21haWwuY29txm343yadf98"
3. kubectl port-forward --namespace kubecost deployment/kubecost-cost-analyzer 9090
4. Updating kubecost:- helm repo add kubecost https://kubecost.github.io/cost-analyzer/ && \
helm repo update && \
helm upgrade kubecost kubecost/cost-analyzer -n kubecost
5. Deleting the kubecost from your cluster :- helm uninstall kubecost -n kubecost
6. to check the cost from the cli we can use krew into the cluster and then use this command :- kubectl cost pod -n kubecost
