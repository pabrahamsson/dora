# PushSecret with kubernetes provider

## Summary

An example of how a k8s secret can be shared from one namespace to another using the [External Secrets Operator](https://external-secrets.io) and a `PushSecret`.

## Requirements

An OpenShift/Kubernetes cluster (tested on OpenShift 4.13) with the External Secrets Operator installed (tested with v0.9.9).

## Scenario

* `eso-creds-testing-source` - The namespace with a secret that will be shared, `test-secret`.
* `eso-creds-testing-target` - The namespace with which the above secret will be shared.

The following resources will be created in `eso-creds-testing-source`:
```
# kustomize build . | yq 'select(.metadata.namespace=="eso-creds-testing-source")' | oc apply -f - --dry-run=client
serviceaccount/my-store configured (dry run)
secret/test-secret configured (dry run)
pushsecret.external-secrets.io/test-cred configured (dry run)
secretstore.external-secrets.io/k8s-store-sa-auth configured (dry run)
```

And similarly for `eso-creds-testing-target`:
```
# kustomize build . | yq 'select(.metadata.namespace=="eso-creds-testing-target")' | oc apply -f - --dry-run=client
```

That's correct, no resources will be created in `eso-creds-testing-target`

Instead we rely on two cluster-wide resources (not counting the `Namespace` resources):
```
# kustomize build . | yq '. | select(.metadata | has("namespace") | not)' | oc apply -f - --dry-run=client
namespace/eso-creds-testing-source configured (dry run)
namespace/eso-creds-testing-target configured (dry run)
clusterrole.rbac.authorization.k8s.io/eso-push-secret configured (dry run)
clusterrolebinding.rbac.authorization.k8s.io/my-store configured (dry run)
```

Here we use a `ClusterRole` and `ClusterRoleBinding` to give the `my-store` service account the necessary privileges to create secrets in any namespace.

> ❗**NOTE**❗\
> The `SecretStore` is limited to a single namespace, defined by `.spec.provider.kubernetes.remoteNamespace`. If this is omitted, the `default` namespace will be used.

## Creating the resources

The resources can be created using `oc` or `kubectl`:
```
oc apply -k .
```

## Verification

```
# oc get secret/pushed-cred -n eso-creds-testing-target -oyaml
apiVersion: v1
data:
  pushed-foo: YmFy
kind: Secret
metadata:
  creationTimestamp: "2024-07-30T20:48:45Z"
  name: pushed-cred
  namespace: eso-creds-testing-target
  resourceVersion: "85792550"
  uid: cbafb397-5b80-40dd-b1af-faebb5f7cfc4
type: Opaque
```

## Cleanup

To delete the resources created above, run the following command:
```
oc delete -k .
```
