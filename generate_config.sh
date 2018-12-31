#!/bin/bash

if [[ -f drone.conf ]]; then
  read -r -p "A config file exists and will be overwritten, are you sure you want to contine? [y/N] " response
  case $response in
    [yY][eE][sS]|[yY])
      mv drone.conf drone.conf_backup
      ;;
    *)
      exit 1
    ;;
  esac
fi

echo "----------------------------"
echo "  Basic environment config  "
echo "----------------------------"

if [ -z "$DRONE_HOST" ]; then
  echo "Drone needs to know its own address. You must therefore provide the address in <scheme>://<hostname> format."
  read -p "Hostname: " -ei "http://ci.example.org" DRONE_SERVER_HOST
fi

echo "----------------------------"
echo "     GitHub OAuth Setup     "
echo "----------------------------"

if [ -z "$DRONE_GITHUB_CLIENT" ]; then
  echo "You must register Drone with GitHub to obtain the client and secret."
  echo "The authorization callback url must match <scheme>://<host>/authorize"
  read -p "Client ID: " -ei "d428e2c573990bc589d2" DRONE_GITHUB_CLIENT_ID
  read -p "Client secret: " -ei "e72e16c7e42f292c6912e7710c838347ae178b4a" DRONE_GITHUB_CLIENT_SECRET
fi

cat << EOF > drone.conf
# Drone needs to know its own address. You must therefore provide the address in <scheme>://<hostname> format.
DRONE_SERVER_HOST=${DRONE_SERVER_HOST}
DRONE_SERVER_PROTO=http

# You must register Drone with GitHub to obtain the client and secret.
# The authorization callback url must match <scheme>://<host>/authorize
DRONE_GITHUB_SERVER=https://github.com
DRONE_GITHUB_CLIENT_ID=${DRONE_GITHUB_CLIENT_ID}
DRONE_GITHUB_CLIENT_SECRET=${DRONE_GITHUB_CLIENT_SECRET}

# Drone registration is closed by default.
# This example enables open registration for users that are members of approved GitHub organizations.
DRONE_USER_FILTER=octocat,spacheghost,github
DRONE_USER_CREATE=username:octocat,machine:false,admin:true,token:55f24eb3d61ef6ac5e83d550178638dc

# Drone server and agents use a shared secret to authenticate communication.
# This should be a random string of your choosing and should be kept private.
DRONE_RPC_SERVER=${DRONE_SERVER_HOST}
DRONE_RPC_SECRET=$(</dev/urandom tr -dc A-Za-z0-9 | head -c 28)

# Each agent is able to process one build by default, but you can also increase the number of parallel builds.
DRONE_RUNNER_CAPACITY=1
DRONE_RUNNER_NAME=$(hostname --long)

# You should use HTTPS behind a proxy using NGINX or Apache2
HTTP_PORT=8008
HTTP_BIND=127.0.0.1
HTTPS_PORT=8043
HTTPS_BIND=127.0.0.1

# Fixed project name
COMPOSE_PROJECT_NAME=drone-ci

EOF

# Create data directory for the sqlite database
mkdir -p data

echo "----------------------------"
echo "Done! Please check drone.conf for additional configuration."
echo "To run Drone CI, just type 'docker-compose pull && docker-compose up -d'"
