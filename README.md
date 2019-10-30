# :tada: Automatic tezos blockchain snapshots [releases](https://github.com/Phlogi/tezos-snapshots/releases)
- Updated daily :repeat:
- Snapshots in *rolling* and *full* mode 
- Highly compressed with *xz*, use xz-utils to decompress
- File name shows *block number* and *level*

# Public list of peers :handshake:
- Updated daily :repeat:
- One peer per line, format is ready for `tezos trust address` and `tezos connect address` commands

# Scripting :page_with_curl:
## Get latest release
### Rolling
`curl -s https://api.github.com/repos/Phlogi/tezos-snapshots/releases/latest | jq -r ".assets[] | select(.name) | .browser_download_url" | grep roll | xargs wget -q --show-progress`
### Full 
`curl -s https://api.github.com/repos/Phlogi/tezos-snapshots/releases/latest | jq -r ".assets[] | select(.name) | .browser_download_url" | grep full | xargs wget -q --show-progress`
### Block hash (for import)
`curl -s https://api.github.com/repos/Phlogi/tezos-snapshots/releases/latest | jq -r ".assets[] | select(.name) | .name" | grep roll | tail -c 61 | head -c 51`

Happy scripting :muscle:
