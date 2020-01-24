#!/bin/bash

# This is a helper script for adding more peers to an already
# running tezos-node. It first queries for, and adds all
# foundation nodes, then queries tzscan's API for more peers and
# adds them as well.
#
# The tezos-admin-client binary will output 'Error' messages in
# most cases, even when already connected to a peer.
#
# Be sure to install jq and configure the TZPATH variable below
# [yum|apt] install jq
#
# If you found this script helpful, send a tip to:
# - https://tezosbakery.ch/ tz1fZ767VDbqx4DeKiFswPSHh513f51mKEUZ (updated, fixed version)
#
# Assumptions: 
# - tezos commands must be in the users PATH directory
# - following commands are available on your system: dig (dnsutils package on debian), jq, curl
# - when using docker, install with:
#     docker exec -it name_of_your_container sudo apk add bind-tools jq curl bash

# Constants
PUB_TZ_PORT=9732

# Script Constants
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
missing_app=false

check_setup () {
  for p in dig jq curl tezos-admin-client; do 
      which "$p" &>/dev/null 
      if [ $? -eq 0 ]; then
        echo -e "$p was found ${GREEN}[OK]${NC}"
      else 
        echo -e "$p is missing ${RED}[ERR]${NC}"
        missing_app=true
      fi
  done
  if [ $missing_app == true ]; then
    echo "Dependencies not satisfied, exiting."
    exit 1
  fi
  # TODO: wait for node RPC here
  initial_peers=$(tezos-admin-client -A localhost p2p stat | grep "BETA\|MAINNET" | wc -l)
  echo "current number of peers: $initial_peers"
  newpeers=0
}

trust_connect () {
  tezos-admin-client -A localhost trust address "${1}"
  tezos-admin-client -A localhost connect address "${1}"
  # tezos-node config update --peer=$1 --data-dir=/home/pi/tezos-data
  if [ $? -eq 0 ]; then
    ((newpeers++))
  #  echo "New connection to $j established"
  fi
}

foundation_nodes () {
  # get foundation nodes
  for i in dubnodes franodes sinnodes nrtnodes pdxnodes; do
      for j in `dig $i.tzbeta.net +short`; do
        address="[$j]:$PUB_TZ_PORT"
        echo -e "Trust and connect ${YELLOW}foundation peer${NC} ${address}..."
        trust_connect "${address}"
      done
  done
}

public_github_nodes () {
  local peers_url=$(curl -s https://api.github.com/repos/Phlogi/tezos-snapshots/releases/latest | jq -r ".assets[] | select(.name) | .browser_download_url" | grep mainnet.list)
  curl -sL $peers_url | while read address
  do
      echo -e "Trust and connect ${YELLOW}public peer${NC} $address..."
      trust_connect "${address}"
  done
}

## MAIN ##
check_setup
public_github_nodes
# foundation_nodes

# how many peers do we have now? how many did we add?
numpeers=$(tezos-admin-client -A localhost p2p stat | grep "BETA\|MAINNET" | wc -l)
let diff_peers=numpeers-initial_peers
echo "Added $newpeers peers. Currently $numpeers connected."
echo "Actually added peers according p2p stat from node: $diff_peers."
echo -e "${GREEN}[done]${NC}"
