#!/bin/bash

# This script performs various Docker-related checks and operations with configurable options.
#
# Usage: ./stat.sh [options]
# Run the script with default settings:
#     ./stat.sh
#
# Options:
#   --no-config: Skip displaying service configurations
#   --no-error-logs: Skip displaying error logs
#   --show-all-logs: Show all logs, including informational logs
#
# Note: You can comment out or uncomment specific checks and operations in the 'main' function
# based on your requirements. Modify the 'DOCKER_COMMANDS' or 'SERVICES_TO_CHECK' array and set flags to 0 or 1
# to customize the script's behavior as needed.
#
# Prerequisites: Docker and Docker Machine must be installed and configured.

# Global Variable
declare -A DOCKER_COMMANDS=(
  ["Docker Services"]="docker service ls"
  ["Tasks of muul Stack"]="docker stack ps muul"
  ["Tasks of traefik Stack"]="docker stack ps traefik"
  ["Running Containers"]="docker ps"
  ["Services of muul Stack"]="docker stack services muul"
  ["Services of traefik Stack"]="docker stack services traefik"
  ["Docker Machine List"]="docker-machine ls"
  ["Docker Networks"]="docker network ls"
  ["Docker Volumes"]="docker volume ls"
  ["Docker Networks Inspect"]="docker network inspect muul_chat_bot"
)

# Function to get Docker general information
get_docker_info() {
  echo "======= Docker Info ======="
  for section in "${!DOCKER_COMMANDS[@]}"; do
      echo "======= $section ======="
      eval "${DOCKER_COMMANDS[$section]}"
  done
}

# Function to check DNS resolutions
check_dns() {
  local domains=("$@")
  echo "======= Checking DNS resolution ======="
  for domain in "${domains[@]}"; do
      echo "IP for $domain:"
      dig +short "$domain"
  done
}

# Function to check ports
check_ports() {
  local ports=("$@")
  echo "======= Checking Ports ======="
  for port in "${ports[@]}"; do
      port_in_use=$(docker-machine ssh do-manager-1 "sudo ss -tuln | grep ':$port '")
      echo "Port $port: $(if [ -z "$port_in_use" ]; then echo "Not in use"; else echo "In use"; fi)"
  done
}

check_traefik_acme_logs() {
    echo "======= Checking Traefik ACME Logs ======="
    local service="traefik_main"
    if docker service ls | grep -q "$service"; then
        echo "------- ACME Related Logs for $service -------"
        docker service logs "$service" 2>&1 | grep -Ei "acme|let'?s encrypt"
    else
        echo "Service $service does not exist."
    fi
}

# Function to check Docker socket permissions
check_docker_socket_permissions() {
    echo "======= Checking Docker Socket Permissions ======="
    
    # Retrieve the permissions of the Docker socket
    socket_permissions=$(docker-machine ssh do-manager-1 "ls -l /var/run/docker.sock")
    
    echo "Docker Socket Permissions: $socket_permissions"
    
    # Checking if the Docker socket has the 'rw' permissions for the group
    if [[ "$socket_permissions" == *".rw."* ]]; then
        echo "Docker socket has read and write permissions for the group."
    else
        echo "Docker socket does NOT have read and write permissions for the group!"
    fi
}

# Function to check the existence and contents of acme.json inside the named volume
check_acme_contents() {
    echo "======= Checking Contents of acme.json in all volumes ======="
    
    # Get a list of all Docker volumes
    volumes=$(docker volume ls -q)

    for volume in $volumes; do
        echo "Checking volume: $volume ..."

        # Check if the file exists in the current volume
        file_exists=$(docker run --rm -v $volume:/temp_volume alpine sh -c "if [ -f /temp_volume/acme.json ]; then echo 'yes'; else echo 'no'; fi")
        
        if [ "$file_exists" = "yes" ]; then
            echo "acme.json exists inside the volume $volume."
            
            # Display the content and path
            echo "Path: /$volume/acme.json"
            docker run --rm -v $volume:/temp_volume alpine sh -c "cat /temp_volume/acme.json"
        else
            echo "acme.json does not exist inside the volume $volume."
        fi

        echo "--------------------------------------------"
    done
}

# Function to check Docker service logs and status
check_docker_services_status_and_logs() {
  local show_config=true
  local show_error_logs=true
  local show_all_logs=false

  # Extract special flags and services separately
  local services=()
  for arg in "$@"; do
    case "$arg" in
      --no-config) 
          show_config=false ;;
      --no-error-logs) 
          show_error_logs=false ;;
      --show-all-logs) 
          show_all_logs=true ;;
      *)  # Any other argument is considered as a service name
          services+=("$arg") ;;
    esac
  done

  echo "======= Docker Service Status and Logs ======="
  for service in "${services[@]}"; do
    if docker service ls | grep -q "$service"; then
      echo "======= $service ======="
      if [ "$show_config" = true ]; then
          echo "------- Configuration -------"
          docker service inspect "$service" --pretty
      fi
      if [ "$show_error_logs" = true ]; then
          echo "------- Error Logs -------"
          docker service logs "$service" 2>&1 | grep -i "error"
      fi
      if [ "$show_all_logs" = true ]; then
          echo "------- All Logs -------"
          docker service logs "$service"
      fi
    else
        echo "Service $service does not exist."
    fi
  done
}

list_containers_attached_to_network() {
    local NETWORK_NAME="$1"

    # Fetch the details of the network
    local NETWORK_DETAILS=$(docker network inspect "$NETWORK_NAME" -f '{{range $key, $value := .Containers}}{{with $value}}{{printf "%s with IP %s\n" .Name .IPv4Address}}{{end}}{{end}}' 2>/dev/null)

    # Check if any details were fetched
    if [ -z "$NETWORK_DETAILS" ]; then
        echo "No containers are attached to the network $NETWORK_NAME or the network does not exist."
        return 1
    fi

    # Print the details
    echo "Containers: This section lists the containers attached to this network."
    local container_count=$(echo "$NETWORK_DETAILS" | wc -l)
    echo "There are $container_count containers (or services) attached to this network:"
    echo "$NETWORK_DETAILS"
}

# Function to setup Docker Machine
setup_docker_machine() {
  echo "======= Setting Docker Machine Environment ======="
  eval $(docker-machine env do-manager-1)
  docker_machine_ip=$(docker-machine ip do-manager-1)
  echo "Docker Machine IP: $docker_machine_ip"
}

# Function to check service connectivity
check_services() {
    echo "======= Check Services======="
    for service in "$@"; do
        ip=$(echo $service | cut -d: -f1)
        port=$(echo $service | cut -d: -f2)

        # Ping check
        if ping -c 1 $ip &> /dev/null; then
            echo "Ping to $ip successful."
        else
            echo "Ping to $ip failed!"
            continue
        fi

        # Port check
        if nc -z $ip $port &> /dev/null; then
            echo "Service on $service is accessible!"
        else
            echo "Service on $service is NOT accessible!"
        fi
    done
}

list_docker_subnets() {
    # Get a list of all Docker network IDs
    network_ids=$(docker network ls -q)

    echo "Listing subnets for Docker networks:"
    echo "------------------------------------"

    for id in $network_ids; do
        # Extract the name and subnet for each network
        network_name=$(docker network inspect -f '{{.Name}}' $id)
        subnet=$(docker network inspect -f '{{range .IPAM.Config}}{{.Subnet}}{{end}}' $id)

        echo "Network Name: $network_name"
        echo "Subnet: $subnet"
        echo "------------------------------------"
    done
}

check_service_connectivity() {
    local service_url="http://muul_ai_chat:3000/api/signup"
    echo "======= Checking Service Connectivity ======="
    
    # Get the container ID and name of the running bot service
    local bot_container_id=$(docker ps --filter "name=^muul_tg_bot.1." --format "{{.ID}}" | head -n 1)
    local bot_container_name=$(docker ps --filter "name=^muul_tg_bot.1." --format "{{.Names}}" | head -n 1)

    # Check the status of the bot container
    if [ -z "$bot_container_id" ]; then
        echo "Bot container is not running!"
        return
    fi

    echo "Bot Container ID: $bot_container_id"
    echo "Bot Container Name: $bot_container_name"

    # Attempt to curl the web service from within the bot container
    local connectivity=$(docker exec "$bot_container_id" curl -s -o /dev/null -w "%{http_code}" "$service_url")
    
    # Display the result based on the HTTP status code
    if [ "$connectivity" == "200" ]; then
        echo "Connectivity between bot and $service_url service: SUCCESSFUL"
    else
        echo "Connectivity between bot and $service_url service: FAILED with HTTP status $connectivity"
    fi
}

SERVICES_TO_CHECK=(
    "traefik_main"
    "muul_ai_chat"
    "muul_tg_bot"
    "muul_ai_chat_db_migrator"
    "muul_tg_bot_db_migrator"
    "muul_ai_chat_db"
    "muul_tg_bot_db"
    "muul_ai_chat_redis"
    "muul_ai_chat_redis_uploader"
    "muul_tg_bot_redis"
    "muul_tg_bot_signup"
    "muul_tg_bot_webhook"
)

NO_CONFIG=1
NO_ERROR_LOGS=1
SHOW_ALL_LOGS=1

main() {
  check_dns "web.muul.ru" "tg.muul.ru"

  setup_docker_machine
  get_docker_info
  check_ports 80 443 8080 3000 3001
  check_service_connectivity
  list_containers_attached_to_network "muul_chat_bot"
  check_acme_contents
  check_docker_socket_permissions
  list_docker_subnets
#   check_traefik_acme_logs
#   check_services "10.0.1.3:59999" "10.0.1.8:80" "10.0.1.6:80"

  local flags=()
  if [ "$NO_CONFIG" -eq 1 ]; then
      flags+=("--no-config")
  fi

  if [ "$NO_ERROR_LOGS" -eq 1 ]; then
      flags+=("--no-error-logs")
  fi

  if [ "$SHOW_ALL_LOGS" -eq 1 ]; then
      flags+=("--show-all-logs")
  fi

  for service in "${SERVICES_TO_CHECK[@]}"; do
    check_docker_services_status_and_logs "${flags[@]}" "$service"
  done
}

main