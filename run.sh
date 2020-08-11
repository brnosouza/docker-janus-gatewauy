CERTBOT_EMAIL=${NETWORK_ADAPTER:-'brnosouza@gmail.com'}
NETWORK_ADAPTER=${NETWORK_ADAPTER:-wlp1s0}
DOCKER_IP=$(ifconfig $NETWORK_ADAPTER | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1') docker-compose up