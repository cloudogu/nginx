#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

# move binary to volume
mv /usr/sbin/nginx /dist
