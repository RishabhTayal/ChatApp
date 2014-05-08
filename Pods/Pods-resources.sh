#!/bin/sh
set -e

RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy-${TARGETNAME}.txt
> "$RESOURCES_TO_COPY"

install_resource()
{
  case $1 in
    *.storyboard)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.xib)
        echo "ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.framework)
      echo "mkdir -p ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      mkdir -p "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      echo "rsync -av ${PODS_ROOT}/$1 ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      rsync -av "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodel)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1"`.mom\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodel`.mom"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd"
      ;;
    *.xcassets)
      ;;
    /*)
      echo "$1"
      echo "$1" >> "$RESOURCES_TO_COPY"
      ;;
    *)
      echo "${PODS_ROOT}/$1"
      echo "${PODS_ROOT}/$1" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
install_resource "AOTutorial/src/AOTutorialViewController.xib"
install_resource "Facebook-iOS-SDK/src/FBUserSettingsViewResources.bundle"
install_resource "JSQMessagesViewController/JSQMessagesViewController/Assets/Images/bubble.png"
install_resource "JSQMessagesViewController/JSQMessagesViewController/Assets/Images/bubble@2x.png"
install_resource "JSQMessagesViewController/JSQMessagesViewController/Assets/Images/bubble_min.png"
install_resource "JSQMessagesViewController/JSQMessagesViewController/Assets/Images/bubble_min@2x.png"
install_resource "JSQMessagesViewController/JSQMessagesViewController/Assets/Images/bubble_min_tailless.png"
install_resource "JSQMessagesViewController/JSQMessagesViewController/Assets/Images/bubble_min_tailless@2x.png"
install_resource "JSQMessagesViewController/JSQMessagesViewController/Assets/Images/bubble_stroked.png"
install_resource "JSQMessagesViewController/JSQMessagesViewController/Assets/Images/bubble_stroked@2x.png"
install_resource "JSQMessagesViewController/JSQMessagesViewController/Assets/Images/bubble_stroked_tailless.png"
install_resource "JSQMessagesViewController/JSQMessagesViewController/Assets/Images/bubble_stroked_tailless@2x.png"
install_resource "JSQMessagesViewController/JSQMessagesViewController/Assets/Images/bubble_tailless.png"
install_resource "JSQMessagesViewController/JSQMessagesViewController/Assets/Images/bubble_tailless@2x.png"
install_resource "JSQMessagesViewController/JSQMessagesViewController/Assets/Images/camera.png"
install_resource "JSQMessagesViewController/JSQMessagesViewController/Assets/Images/camera@2x.png"
install_resource "JSQMessagesViewController/JSQMessagesViewController/Assets/Images/typing.png"
install_resource "JSQMessagesViewController/JSQMessagesViewController/Assets/Images/typing@2x.png"
install_resource "JSQMessagesViewController/JSQMessagesViewController/Assets/Sounds/message_received.aiff"
install_resource "JSQMessagesViewController/JSQMessagesViewController/Assets/Sounds/message_sent.aiff"
install_resource "JSQMessagesViewController/JSQMessagesViewController/Assets/Images"
install_resource "JSQMessagesViewController/JSQMessagesViewController/Assets/Sounds"
install_resource "JSQMessagesViewController/JSQMessagesViewController/Controllers/JSQMessagesViewController.xib"
install_resource "JSQMessagesViewController/JSQMessagesViewController/Views/JSQMessagesCollectionViewCellIncoming.xib"
install_resource "JSQMessagesViewController/JSQMessagesViewController/Views/JSQMessagesCollectionViewCellOutgoing.xib"
install_resource "JSQMessagesViewController/JSQMessagesViewController/Views/JSQMessagesLoadEarlierHeaderView.xib"
install_resource "JSQMessagesViewController/JSQMessagesViewController/Views/JSQMessagesToolbarContentView.xib"
install_resource "JSQMessagesViewController/JSQMessagesViewController/Views/JSQMessagesTypingIndicatorFooterView.xib"
install_resource "TSMessages/TSMessages/Resources/Images/NotificationBackgroundError.png"
install_resource "TSMessages/TSMessages/Resources/Images/NotificationBackgroundError@2x.png"
install_resource "TSMessages/TSMessages/Resources/Images/NotificationBackgroundErrorIcon.png"
install_resource "TSMessages/TSMessages/Resources/Images/NotificationBackgroundErrorIcon@2x.png"
install_resource "TSMessages/TSMessages/Resources/Images/NotificationBackgroundMessage.png"
install_resource "TSMessages/TSMessages/Resources/Images/NotificationBackgroundMessage@2x.png"
install_resource "TSMessages/TSMessages/Resources/Images/NotificationBackgroundSuccess.png"
install_resource "TSMessages/TSMessages/Resources/Images/NotificationBackgroundSuccess@2x.png"
install_resource "TSMessages/TSMessages/Resources/Images/NotificationBackgroundSuccessIcon.png"
install_resource "TSMessages/TSMessages/Resources/Images/NotificationBackgroundSuccessIcon@2x.png"
install_resource "TSMessages/TSMessages/Resources/Images/NotificationBackgroundWarning.png"
install_resource "TSMessages/TSMessages/Resources/Images/NotificationBackgroundWarning@2x.png"
install_resource "TSMessages/TSMessages/Resources/Images/NotificationBackgroundWarningIcon.png"
install_resource "TSMessages/TSMessages/Resources/Images/NotificationBackgroundWarningIcon@2x.png"
install_resource "TSMessages/TSMessages/Resources/Images/NotificationButtonBackground.png"
install_resource "TSMessages/TSMessages/Resources/Images/NotificationButtonBackground@2x.png"
install_resource "TSMessages/TSMessages/Resources/TSMessagesDefaultDesign.json"

rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
if [[ "${ACTION}" == "install" ]]; then
  rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
rm -f "$RESOURCES_TO_COPY"

if [[ -n "${WRAPPER_EXTENSION}" ]] && [ `xcrun --find actool` ] && [ `find . -name '*.xcassets' | wc -l` -ne 0 ]
then
  case "${TARGETED_DEVICE_FAMILY}" in 
    1,2)
      TARGET_DEVICE_ARGS="--target-device ipad --target-device iphone"
      ;;
    1)
      TARGET_DEVICE_ARGS="--target-device iphone"
      ;;
    2)
      TARGET_DEVICE_ARGS="--target-device ipad"
      ;;
    *)
      TARGET_DEVICE_ARGS="--target-device mac"
      ;;  
  esac 
  find "${PWD}" -name "*.xcassets" -print0 | xargs -0 actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${IPHONEOS_DEPLOYMENT_TARGET}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
