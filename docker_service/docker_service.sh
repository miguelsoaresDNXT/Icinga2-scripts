#!/bin/bash

# Executa o comando "docker service ls" e captura a saída
services=$(docker service ls --format "{{.ID}}\t{{.Name}}\t{{.Image}}\t{{.Replicas}}")

# Variável para controlar se algum serviço com contagem "0/1" ou "0/0" foi encontrado
unhealthy_found=false

# Variável para armazenar os nomes dos serviços não saudáveis
unhealthy_services=""

# Loop através dos serviços e verifica se algum está com a contagem "0/1" ou "0/0"
while IFS=$'\t' read -r id name image replicas; do
    if [[ $replicas == *"0/1"* ]] || [[ $replicas == *"0/0"* ]]; then
        #echo "Service NAME: $name, Service Replicas: $replicas"

        unhealthy_found=true
        unhealthy_services+=" $name"
    fi
done <<< "$services"

# Verifica se algum serviço com contagem "0/1" ou "0/0" foi encontrado e define o status do Icinga de acordo
if [ "$unhealthy_found" = true ]; then
    echo "CRITICAL - Unhealthy services found"
    echo "Unhealthy Services: $unhealthy_services"
    exit 2
else
    echo "OK - All services are healthy"
    exit 0
fi

