INSTALL_TARGET_PROCESSES = Preferences
ARCHS = arm64 arm64e
FINALPACKAGE = 1
SDKPATH=/Users/conor/theos/sdks/iPhoneOS13.0.sdk
SDKVERSION=13.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = ShyLabels
$(BUNDLE_NAME)_FILES = $(wildcard *.m) $(wildcard */*.m)
$(BUNDLE_NAME)_CFLAGS = -Wno-deprecated-declarations
$(BUNDLE_NAME)_INSTALL_PATH = /Library/PreferenceBundles
$(BUNDLE_NAME)_FRAMEWORKS = CoreGraphics UIKit
$(BUNDLE_NAME)_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/ShyLabels.plist$(ECHO_END)
