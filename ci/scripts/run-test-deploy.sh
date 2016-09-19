#!/usr/bin/env bash

####################################### GLOBAL VARS ###########################################

## Parameters
TILE_GEN_DIR="$( cd "$1" && pwd )"
POOL_DIR="$( cd "$2" && pwd )"
REPO_DIR="$( cd "$3" && pwd )"
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

APP_DOMAIN=`$PCF cf-info | grep apps_domain | cut -d" " -f1`
${REPO_DIR}/ci/scripts/tests.py ${REPO_DIR} ${APP_DOMAIN}

## Enable or Disable exit on error
set -e
