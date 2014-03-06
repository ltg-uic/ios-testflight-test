#!/bin/sh

#  uploadToHockey.sh
#  TFTest
#
#  Created by Aijaz Ansari on 3/6/14.
#  Copyright (c) 2014 Euclid Software, LLC. All rights reserved.

# This script assumes that the following environment variables are present:
# HOCKEY_APP_ID
# HOCKEY_API_TOKEN - This comes from the environment
# ARCHIVE_DSYMS_PATH
# PRODUCT_NAME
# ARCHIVE_PRODUCTS_PATH
# PROJECT_DIR


# ARCHIVE_DSYMS_PATH & ARCHIVE_PRODUCTS_PATH is available to Post Archive Actions per
# Xcode 4.0 Developer Preview 5 Release Notes at
# https://developer.apple.com/library/ios/releasenotes/developertools/rn-xcode/#//apple_ref/doc/uid/TP40001051-SW72

DSYM="${ARCHIVE_DSYMS_PATH}/${PRODUCT_NAME}.app.dSYM"
APP="${ARCHIVE_PRODUCTS_PATH}/Applications/${PRODUCT_NAME}.app"
IPA_PATH=/tmp/${PRODUCT_NAME}.ipa
DSYM_PATH=/tmp/${PRODUCT_NAME}.dSYM.zip
TEMP_JSON=/tmp/${PRODUCT_NAME}json
HOCKEY_API_TOKEN=`cat ~/.haapi`

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

# perform the upload
`/usr/bin/curl \
-F "status=2" \
-F "notify=0" \
-F "notes=<${PROJECT_DIR}/Build/releaseNotes.md" \
-F "notes_type=1" \
-F "tags=devs" \
-F "ipa=@$IPA_PATH" \
-F "dsym=@$DSYM_PATH" \
-H "X-HockeyAppToken: $HOCKEY_API_TOKEN" \
-o $TEMP_JSON \
https://rink.hockeyapp.net/api/2/apps/$HOCKEY_APP_ID/app_versions/upload`

CONFIG_URL=`/usr/local/bin/perl -MJSON -e '$i=<STDIN>; $p=from_json($i); print "$p->{config_url}\n";' < $TEMP_JSON`

open $CONFIG_URL
