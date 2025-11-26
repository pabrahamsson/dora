#!/bin/bash

export COSIGN_EXPERIMENTAL=1
export TUF_URL=https://tuf-trusted-artifact-signer.apps.outils.infra.paas.p1.za.qc
export COSIGN_FULCIO_URL=https://fulcio-server-trusted-artifact-signer.apps.outils.infra.paas.p1.za.qc
export COSIGN_REKOR_URL=https://rekor-server-trusted-artifact-signer.apps.outils.infra.paas.p1.za.qc
export COSIGN_MIRROR=${TUF_URL}
export COSIGN_ROOT=${TUF_URL}/root.json
export COSIGN_OIDC_CLIENT_ID=trusted-artifact-signer
export COSIGN_OIDC_ISSUER=https://auth.infra.paas.gouv.qc.ca/realms/trusted-artifact-signer
export COSIGN_CERTIFICATE_OIDC_ISSUER=https://auth.infra.paas.gouv.qc.ca/realms/trusted-artifact-signer
export COSIGN_YES="true"
export SIGSTORE_FULCIO_URL=${COSIGN_FULCIO_URL}
export SIGSTORE_OIDC_ISSUER=https://auth.infra.paas.gouv.qc.ca/realms/trusted-artifact-signer
export SIGSTORE_REKOR_URL=${COSIGN_REKOR_URL}
export REKOR_REKOR_SERVER=${COSIGN_REKOR_URL}
