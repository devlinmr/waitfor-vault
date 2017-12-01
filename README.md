# waitfor-vault

A container to wait on a vault instance and optionally a value.
Intended as an init container in Kubernetes.

## Inputs

VAULT_ADDR The instance address. Required.

VAULT_TOKEN The access token. Optional.

VAULT_KEY Key to wait for. Optional.

EXPORT_KEY Boolean to determine whether or not to write value to filesystem. Optional.

## Notes

EXPORT_KEY if true will write out the value of VAULT_KEY to /pod-data/vault/${VAULT_KEY}.

This is intended to allow sharing of values with other containers in the pod via a VolumeMount (/pod-data/vault).

## End
