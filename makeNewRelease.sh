#!/bin/sh

#  postArchive.sh
#  TFTest
#
#  Created by Aijaz Ansari on 3/5/14.
#  Copyright (c) 2014 Euclid Software, LLC. All rights reserved.

# This script is run after the build
# So actually this is updating the version numbers that will be used for the next compile/archive


# The main Plist
MASTERPLIST=${PROJECT_DIR}/${PROJECT_NAME}/${PROJECT_NAME}-Info.plist

# This target's plist
TARGETPLIST=${PROJECT_DIR}/${PROJECT_NAME}/${TARGET_NAME}-Info.plist

# This file is over-written on every archive
RELEASENOTES=${PROJECT_DIR}/Build/releaseNotes.md

# Every release's release notes are appended to this file
CHANGELOG=${PROJECT_DIR}/Build/changeLog.md

# temp file for atomic changes
TEMP=${PROJECT_DIR}/Build/changeLog.md.temp

# current date stamp
NOW=`date +"%Y/%m/%d %H:%M"`

# Adapted From: http://stackoverflow.com/a/15483906/772526
# This splits a two-decimal version string, such as "0.45.123", allowing us to increment the third position.

# get the full version string FROM THE MASTER PLIST
VERSIONNUM=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$MASTERPLIST")

# extract the third part
NEWSUBVERSION=`echo $VERSIONNUM | awk -F "." '{print $3}'`

# increment it by 1
NEWSUBVERSION=$(($NEWSUBVERSION + 1))

# reconstruct the new version string
NEWVERSIONSTRING=`echo $VERSIONNUM | awk -F "." '{print $1 "." $2 ".'$NEWSUBVERSION'" }'`

# save it back into CFBundleShortVersionString in both plist files...
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $NEWVERSIONSTRING" "$MASTERPLIST"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $NEWVERSIONSTRING" "$TARGETPLIST"

# ...as well as CFBundleVersion
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $NEWVERSIONSTRING" "$MASTERPLIST"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $NEWVERSIONSTRING" "$TARGETPLIST"

# this dir will not exist the first time you build
/bin/mkdir -p ${PROJECT_DIR}/Build

/bin/rm $TEMP 2>/dev/null
echo "## Build $VERSIONNUM :: $NOW :: $TARGET_NAME ####################" > $TEMP
echo "" >> $TEMP
echo "* " >> $TEMP
echo "" >> $TEMP
cat $CHANGELOG >> $TEMP

/bin/mv $TEMP $CHANGELOG

# open with TextEdit, -W => Wait till exit, -n => open as a new app even if the app is already running
open -a /Applications/TextEdit.app -W -n $CHANGELOG


/bin/rm $RELEASENOTES

# Take the first chunk of text out and put it into the release notes
perl -ne 'if (/^\#\#\s*Build\s/i) { exit if $found++ == 1; $first = 1} elsif ($first && !/\S/) { $first = 0; } else { print; }'  $CHANGELOG > $RELEASENOTES


