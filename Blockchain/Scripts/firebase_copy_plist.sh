#!/bin/sh
#
#  Blockchain/Scripts/firebase_copy_plist.sh
#
#  What It Does
#  ------------
#  Copies the correct GoogleService-Info.plist into the built .app
#  NOTE: GoogleService-Info.plist files should only live on the file system and should NOT be part
#  of the target (since we'll be adding them to the target manually).

# File name of the resource we're selectively copying.
PLIST_FILENAME=GoogleService-Info.plist

# Destination directory where the resource will be copied to.
PLIST_DESTINATION=${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app

# References to dev, staging, and prod versions of the resource.
GOOGLESERVICE_INFO_DEV=${PROJECT_DIR}/Blockchain/Firebase/Dev/${PLIST_FILENAME}
GOOGLESERVICE_INFO_PROD=${PROJECT_DIR}/Blockchain/Firebase/Prod/${PLIST_FILENAME}
GOOGLESERVICE_INFO_STAG=${PROJECT_DIR}/Blockchain/Firebase/Staging/${PLIST_FILENAME}
GOOGLESERVICE_INFO_DOGFOOD=${PROJECT_DIR}/Blockchain/Firebase/Alpha/${PLIST_FILENAME}

# Will hold reference to choosen resource.
GOOGLESERVICE_INFO=""

# Make sure Dev, Staging, and Prod versions exists.

# Dev exists:
echo "Looking for ${PLIST_FILENAME} in ${GOOGLESERVICE_INFO_DEV}"
if [ ! -f $GOOGLESERVICE_INFO_DEV ]; then
    echo "No Development ${PLIST_FILENAME} found. Please ensure it's in the proper directory."
    exit 1
fi

# Staging exists:
echo "Looking for ${PLIST_FILENAME} in ${GOOGLESERVICE_INFO_STAG}"
if [ ! -f $GOOGLESERVICE_INFO_STAG ]; then
    echo "No Staging ${PLIST_FILENAME} found. Please ensure it's in the proper directory."
    exit 1
fi

# Prod exists:
echo "Looking for ${PLIST_FILENAME} in ${GOOGLESERVICE_INFO_PROD}"
if [ ! -f $GOOGLESERVICE_INFO_PROD ]; then
    echo "No Production ${PLIST_FILENAME} found. Please ensure it's in the proper directory."
    exit 1
fi

# Alpha exists:
echo "Looking for ${PLIST_FILENAME} in ${GOOGLESERVICE_INFO_DOGFOOD}"
if [ ! -f $GOOGLESERVICE_INFO_DOGFOOD ]; then
    echo "No Production ${PLIST_FILENAME} found. Please ensure it's in the proper directory."
    exit 1
fi

# Select version based on the current CONFIGURATION
echo "The current configuration is ${CONFIGURATION}"
if [ "${CONFIGURATION}" == "Debug Dev" ]; then
    GOOGLESERVICE_INFO=${GOOGLESERVICE_INFO_DEV}
elif [ "${CONFIGURATION}" == "Debug Staging" ] || [ "${CONFIGURATION}" == "Release Staging" ]; then
    GOOGLESERVICE_INFO=${GOOGLESERVICE_INFO_STAG}
elif [ "${CONFIGURATION}" == "Debug Production" ] || [ "${CONFIGURATION}" == "Release" ] || [ "${CONFIGURATION}" == "Release Internal" ]; then
    GOOGLESERVICE_INFO=${GOOGLESERVICE_INFO_PROD}
elif [ "${CONFIGURATION}" == "Debug Alpha" ] || [ "${CONFIGURATION}" == "Release Alpha" ]; then
    GOOGLESERVICE_INFO=${GOOGLESERVICE_INFO_DOGFOOD}
else
    echo "Unexpected configuration: ${CONFIGURATION}. Aborting."
    exit 1
fi
echo "Using ${GOOGLESERVICE_INFO}"

# Copies selected version into destination directory

echo "Will copy ${PLIST_FILENAME} to final destination: ${PLIST_DESTINATION}"
cp "${GOOGLESERVICE_INFO}" "${PLIST_DESTINATION}"
