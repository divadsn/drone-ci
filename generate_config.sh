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
  read -p "Hostname: " -ei "http://ci.example.org" DRONE_HOST
fi

echo "----------------------------"
echo "     GitHub OAuth Setup     "
echo "----------------------------"

if [ -z "$DRONE_GITHUB_CLIENT" ]; then
  echo "You must register Drone with GitHub to obtain the client and secret."
  echo "The authorization callback url must match <scheme>://<host>/authorize"
  read -p "Client ID: " -ei "d428e2c573990bc589d2" DRONE_GITHUB_CLIENT
  read -p "Client secret: " -ei "e72e16c7e42f292c6912e7710c838347ae178b4a" DRONE_GITHUB_SECRET
fi

cat << EOF > drone.conf
# Drone needs to know its own address. You must therefore provide the address in <scheme>://<hostname> format.
DRONE_HOST=${DRONE_HOST}

# You must register Drone with GitHub to obtain the client and secret.
# The authorization callback url must match <scheme>://<host>/authorize
DRONE_GITHUB_CLIENT=${DRONE_GITHUB_CLIENT}
DRONE_GITHUB_SECRET=${DRONE_GITHUB_SECRET}

# Drone registration is closed by default.
# This example enables open registration for users that are members of approved GitHub organizations.
DRONE_ORGS=dolores,dogpatch
DRONE_ADMIN=johnsmith,janedoe

# Drone server and agents use a shared secret to authenticate communication.
# This should be a random string of your choosing and should be kept private.
DRONE_SECRET=$(</dev/urandom tr -dc A-Za-z0-9 | head -c 28)

# You should use HTTPS behind a proxy using NGINX or Apache2
HTTP_PORT=8008
HTTP_BIND=127.0.0.1

# Fixed project name
COMPOSE_PROJECT_NAME=drone-ci

EOF

# Create data directory for the sqlite database
# TODO: MySQL/PostgreSQL altenative in configuration
mkdir -p data

echo "----------------------------"
echo "Done! Please check drone.conf for additional configuration."
echo "To run Drone CI, just type 'docker-compose pull && docker-compose up -d'"
