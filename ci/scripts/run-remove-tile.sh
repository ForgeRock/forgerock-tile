#!/usr/bin/env bash

set -e

# echo "### Skipping remove"
# exit 0

TILE_GEN_DIR="$( cd "$1" && pwd )"
POOL_DIR="$( cd "$2" && pwd )"
PRODUCT="forgerock-service-broker-tile"

BIN_DIR="$( cd "${TILE_GEN_DIR}/bin" && pwd )"

PCF="${BIN_DIR}/pcf"

cd "${POOL_DIR}"

echo "Available products:"
$PCF products
echo

if ! $PCF is-installed "${PRODUCT}" ; then
	echo "${PRODUCT} not installed - skipping removal"
	exit 0
fi

echo "Uninstalling ${PRODUCT}"
$PCF uninstall "${PRODUCT}"
echo

echo "Applying Changes"
$PCF apply-changes
echo

echo "Available products:"
$PCF products
echo

if $PCF is-installed "${PRODUCT}" ; then
	echo "${PRODUCT} remains installed - remove failed"
	exit 1
fi
