#!/usr/bin/env bash

####################################### GLOBAL VARS ###########################################

## Parameters
TILE_GEN_DIR="$( cd "$1" && pwd )"
POOL_DIR="$( cd "$2" && pwd )"
SOLACE_TILE_DIR="$( cd "$3" && pwd )"
LOG_DIR="$( cd "$4" && pwd )"
TILE_DIR="$( cd "$5" && pwd )"


TILE_FILE=`cd "${TILE_DIR}"; ls *.pivotal`
if [ -z "${TILE_FILE}" ]; then
   echo "No files matching ${TILE_DIR}/*.pivotal"
   ls -lR "${TILE_DIR}"
   exit 1
fi

PRODUCT=`echo "${TILE_FILE}" | sed "s/-[^-]*$//"`
VERSION=`echo "${TILE_FILE}" | sed "s/.*-//" | sed "s/\.pivotal\$//"`

echo "PRODUCT: $PRODUCT"
echo "VERSION: $VERSION"

## Commands
PCF=${TILE_GEN_DIR}/bin/pcf

####################################### FUNCTIONS ###########################################

function log() {
	echo ""
	echo `date` $1
}

function which_pcf() {
  PIE_NAME=`cat ${POOL_DIR}/name`
  log "${POOL_DIR}/pcf/claimed/${PIE_NAME}:"
  cat ${POOL_DIR}/pcf/claimed/$PIE_NAME
}

####################################### MAIN ###########################################

cd ${POOL_DIR}

which_pcf

# Insert tests here
# You have access to the pcf command, and you are in the dir that has the metadata file

# Typical tests here would:
# - Connect to your deployed services and brokers
# - Verify that you can create service instances
# - Bind those to test apps
# - Make sure the right things happen

## Enable or Disable exit on error
set -e
