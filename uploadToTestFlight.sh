#!/bin/bash

#  uploadToTestFlight.sh
#  TFTest
#
#  Created by Aijaz Ansari on 3/5/14.
#  Copyright (c) 2014 Euclid Software, LLC. All rights reserved.
#

# This script assumes that the following environment variables are present:
# ARCHIVE_DSYMS_PATH
# PRODUCT_NAME
# ARCHIVE_PRODUCTS_PATH
# PROJECT_DIR
# TF_API_TOKEN - This comes from the environment
# TF_TEAM_TOKEN


# ARCHIVE_DSYMS_PATH & ARCHIVE_PRODUCTS_PATH is available to Post Archive Actions per
# Xcode 4.0 Developer Preview 5 Release Notes at
# https://developer.apple.com/library/ios/releasenotes/developertools/rn-xcode/#//apple_ref/doc/uid/TP40001051-SW72

DSYM="${ARCHIVE_DSYMS_PATH}/${PRODUCT_NAME}.app.dSYM"
APP="${ARCHIVE_PRODUCTS_PATH}/Applications/${PRODUCT_NAME}.app"
IPA_PATH=/tmp/${PRODUCT_NAME}.ipa
DSYM_PATH=/tmp/${PRODUCT_NAME}.dSYM.zip
TEMP_JSON=/tmp/${PRODUCT_NAME}.json
TF_API_TOKEN=`cat ~/.tfapi`

# create the IPA
# got this command from http://stackoverflow.com/questions/8334500/generating-ipa-from-xcode-command-line
#
/bin/rm "$IPA_PATH"
/usr/bin/xcrun -sdk iphoneos PackageApplication -v "${APP}" -o "$IPA_PATH"

# Zip DSYM for upload
#
/bin/rm "$DSYM_PATH"
/usr/bin/zip -r "$DSYM_PATH" "${DSYM}"
/bin/rm $TEMP_JSON


`/usr/bin/curl \
-F "file=@$IPA_PATH" \
-F "dsym=@$DSYM_PATH" \
-F api_token="$TF_API_TOKEN" \
-F team_token="$TF_TEAM_TOKEN" \
-F notes="<${PROJECT_DIR}/Build/releaseNotes.md" \
-F distribution_lists="betaTesters" \
-F notify=True \
-o $TEMP_JSON \
http://testflightapp.com/api/builds.json`


CONFIG_URL=`/usr/local/bin/perl -MJSON -e '$i=join("", <STDIN>); $p=from_json($i); print "$p->{config_url}\n";' < $TEMP_JSON`

open $CONFIG_URL


