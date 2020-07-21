#!/bin/sh

if ! which carthage > /dev/null; then
    echo 'Error: Carthage is not installed' >&2
    exit 1
fi

if [ ! -f Package.swift ]; then
    echo "Package.swift can't be found, please make sure you run scripts/carthage-archive.sh from the root folder" >&2
    exit 1
fi

if ! which swift > /dev/null; then
    echo 'Swift is not installed' >&2
    exit 1
fi

REQUIRED_SWIFT_TOOLING="5.1.0"
TOOLS_VERSION=`swift package tools-version`
XCODE_XCCONFIG_FILE=$(pwd)/Carthage.xcconfig

if [ ! -f ${XCODE_XCCONFIG_FILE} ]; then
    echo 'Carthage.xcconfig does not exist'
    exit 1 
fi

if [ ! "$(printf '%s\n' "$REQUIRED_SWIFT_TOOLING" "$TOOLS_VERSION" | sort -V | head -n1)" = "$REQUIRED_SWIFT_TOOLING" ]; then
    echo 'You must have Swift Package Manager 5.1.0 or later.'
    exit 1
fi

swift package generate-xcodeproj
export XCODE_XCCONFIG_FILE
carthage build --no-skip-current
carthage archive
unset XCODE_XCCONFIG_FILE

echo "Upload RxCombine.framework.zip to the latest release"
