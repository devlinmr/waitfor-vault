#!/bin/bash

if [ "x${VAULT_ADDR}x" == "xx" ]; then
    echo "Set VAULT_ADDR"
    exit 0
fi

rc=`curl -k -s -o /dev/null -w "%{http_code}" -H "X-Vault-Token:$VAULT_TOKEN" ${VAULT_ADDR}/v1/sys/auth`
resp="false"

while [ $resp == "false" ]; do
    if [ $rc == "200" ] || [ $rc == "429" ]; then
        echo "Vault alive at ${VAULT_ADDR}"
        resp="true"
    elif [ $rc == "403" ]; then
        echo "Check VAULT_TOKEN: received 403 from ${VAULT_ADDR}/v1/sys/auth"
        resp="true"
        exit 1
    else
        echo "Unexpected response code ${rc} from ${VAULT_ADDR}/v1/sys/auth"
        sleep 10
        rc=`curl -k -s -o /dev/null -w "%{http_code}" -H "X-Vault-Token:$VAULT_TOKEN" ${VAULT_ADDR}/v1/sys/auth`
    fi
done

if [ "x${VAULT_KEY}x" == "xx" ]; then
    echo "No VAULT_KEY specified, Exiting."
    exit 0
fi

echo "Checking ${VAULT_ADDR}/v1/kv/${VAULT_KEY}..."

while [ `curl -k -s -o /dev/null -w "%{http_code}" -H "X-Vault-Token:$VAULT_TOKEN" ${VAULT_ADDR}/v1/secret/${VAULT_KEY}` != "200" ]; do
    rc=`curl -k -s -o /dev/null -w "%{http_code}" -H "X-Vault-Token:$VAULT_TOKEN" ${VAULT_ADDR}/v1/secret/${VAULT_KEY}`
    echo "Waiting on ${VAULT_ADDR}/v1/secret/${VAULT_KEY}... $rc"
    sleep 5
done

if [ "${EXPORT_KEY}" != "true" ]; then
    echo "${VAULT_KEY} found. Exiting."
    exit 0
fi

VAULT_VAL=`curl -k -s -H "X-Vault-Token:$VAULT_TOKEN" ${VAULT_ADDR}/v1/secret/${VAULT_KEY} | jq -r .data.value`

echo "Exporting /pod-data/vault/${VAULT_KEY}."

mkdir -p `dirname /pod-data/vault/${VAULT_KEY}`

echo ${VAULT_VAL} > /pod-data/vault/${VAULT_KEY}

echo "End"
exit 0
