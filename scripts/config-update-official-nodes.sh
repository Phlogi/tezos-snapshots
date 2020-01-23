#!/bin/bash
PUB_TZ_PORT=9732
  for i in dubnodes franodes sinnodes nrtnodes pdxnodes; do
      for j in `dig $i.tzbeta.net +short`; do
        address="[$j]:$PUB_TZ_PORT"
        echo -e "Trust and connect ${YELLOW}foundation peer${NC} ${address}..."
        # trust_connect "${address}"
        tezos-node config update --peer="${address}"
      done
  done
