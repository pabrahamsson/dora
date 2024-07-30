# ExternalSecret with kubernetes provider

## Summary

An example of how a k8s secret can be shared from one namespace to another using the [External Secrets Operator](https://external-secrets.io) and an `ExternalSecret`.

## Requirements

An OpenShift/Kubernetes cluster (tested on OpenShift 4.13) with the External Secrets Operator installed (tested with v0.9.9).

## Scenario

* `eso-creds-testing-source` - The namespace with a secret that will be shared, `test-secret`.
* `eso-creds-testing-target` - The namespace with which the above secret will be shared.

The following resources will be created in `eso-creds-testing-source`:
```
# kustomize build . | yq 'select(.metadata.namespace=="eso-creds-testing-source")' | oc apply -f - --dry-run=client
role.rbac.authorization.k8s.io/eso-store-role created (dry run)
rolebinding.rbac.authorization.k8s.io/my-store created (dry run)
secret/test-secret configured (dry run)
```

And similarly for `eso-creds-testing-target`:
```
# kustomize build . | yq 'select(.metadata.namespace=="eso-creds-testing-target")' | oc apply -f - --dry-run=client
serviceaccount/my-store created (dry run)
externalsecret.external-secrets.io/test-cred created (dry run)
secretstore.external-secrets.io/k8s-store-sa-auth created (dry run)
```

## Creating the resources

The resources can be created using `oc` or `kubectl`:
```
oc apply -k .
```

## Verification

```
# oc get secret/test-cred -n eso-creds-testing-target -oyaml
apiVersion: v1
data:
  foo: YmFy
immutable: false
kind: Secret
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"external-secrets.io/v1beta1","kind":"ExternalSecret","metadata":{"annotations":{},"name":"test-cred","namespace":"eso-creds-testing-target"},"spec":{"data":[{"remoteRef":{"key":"test-secret","property":"foo"},"secretKey":"foo"}],"refreshInterval":"5m","secretStoreRef":{"kind":"SecretStore","name":"k8s-store-sa-auth"}}}
    reconcile.external-secrets.io/data-hash: 5211b9bd4ac724a48a80e741f54ca581
  creationTimestamp: "2024-07-30T20:41:47Z"
  labels:
    reconcile.external-secrets.io/created-by: 19f2696dfb023985d2c942f29c91c2d1
  name: test-cred
  namespace: eso-creds-testing-target
  ownerReferences:
  - apiVersion: external-secrets.io/v1beta1
    blockOwnerDeletion: true
    controller: true
    kind: ExternalSecret
    name: test-cred
    uid: 2fb356e9-59ee-460e-93c3-9ca1a44533c3
  resourceVersion: "85780417"
  uid: 2e5aa1a4-b3df-4da5-8464-38fba011ba2e
type: Opaque
```

## Cleanup

To delete the resources created above, run the following command:
```
oc delete -k .
```
