#!/usr/bin/env bash
if ! UUID=$(cat /proc/sys/kernel/random/uuid 2>/dev/null); then
    UUID=$(uuidgen | tr '[:upper:]' '[:lower:]')
fi

if [ -z "${SVC}" ]; then
    read -p 'Service: ' SVC
fi

ROUTING=${SVC}-${UUID}

if [ -z "${NS}" ]; then
    read -p 'Namespace: ' NS
fi

if [ -z "${PORT}" ]; then
    read -p 'Local Port(s) (space separated for multiple): ' PORT
fi

LOCAL_PORTS=""
for i in ${PORT}; do
    LOCAL_PORTS="${LOCAL_PORTS} --local-port ${i}"
done

echo "Connecting service ${SVC} in namepace ${NS} to ports ${PORT} with routing ${ROUTING}"

dsc connect \
    --service ${SVC} \
    --routing ${ROUTING} \
    --namespace ${NS} \
    ${LOCAL_PORTS} \
    --use-kubernetes-service-environment-variables  
