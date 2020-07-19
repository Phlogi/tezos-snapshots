# :tada: Automatic tezos blockchain snapshot [releases](https://github.com/Phlogi/tezos-snapshots/releases)
- Updated every 3 days :repeat:
- Snapshots in *rolling* and *full* mode 
- Highly compressed with *xz*, use xz-utils to decompress
- File name shows *block number* and *level*

# Public list of peers :handshake:
- One peer per line, format is ready for `tezos trust address` and `tezos connect address` commands

# Scripting :page_with_curl:
## Get latest release
### Rolling
`curl -s https://api.github.com/repos/Phlogi/tezos-snapshots/releases/latest | jq -r ".assets[] | select(.name) | .browser_download_url" | grep roll | xargs wget -q --show-progress`
### Full 
`curl -s https://api.github.com/repos/Phlogi/tezos-snapshots/releases/latest | jq -r ".assets[] | select(.name) | .browser_download_url" | grep full | xargs wget -q --show-progress`

This will download *multiple* splitted files as the limit is 2GB per asset on github. 
Extract them all with: 

`cat mainnet.full.* | xz -d -v -T0 > mainnet.importme`

### Block hash (e.g. for import)
Example using the *rolling* snapshot:

`curl -s https://api.github.com/repos/Phlogi/tezos-snapshots/releases/latest | jq -r ".assets[] | select(.name) | .name" | grep roll | awk -F '.' '{print $4; exit}'`

### Block height 
Example using the *full* snapshot:

`curl -s https://api.github.com/repos/Phlogi/tezos-snapshots/releases/latest | jq -r ".assets[] | select(.name) | .name" | grep roll | awk -F '.' '{print $5; exit}'`

## Update your node with public peers
```
  peers_url=$(curl -s https://api.github.com/repos/Phlogi/tezos-snapshots/releases/latest | jq -r ".assets[] | select(.name) | .browser_download_url" | grep mainnet.list)
  curl -sL $peers_url | while read address
  do
      # trust command needed if you run a private node
      tezos-admin-client -A localhost trust address "${address}"
      tezos-admin-client -A localhost connect address "${address}"
  done
  ```

Happy scripting :muscle:
