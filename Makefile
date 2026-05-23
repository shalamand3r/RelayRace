TARGET := iphone:clang:latest:15.0
ARCHS = arm64e
THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = RelayRace

RelayRace_FILES = Tweak.x
RelayRace_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-stage::
	install_name_tool -change @rpath/CydiaSubstrate.framework/CydiaSubstrate /System/Library/VideoCodecs/lib/libellekit.dylib $(THEOS_STAGING_DIR)/Library/MobileSubstrate/DynamicLibraries/RelayRace.dylib
	ldid -S -Icom.shalamand3r.relayrace $(THEOS_STAGING_DIR)/Library/MobileSubstrate/DynamicLibraries/RelayRace.dylib
	if [ -x build/macprep/relayrace-ct-bypass-mac ]; then build/macprep/relayrace-ct-bypass-mac -i $(THEOS_STAGING_DIR)/Library/MobileSubstrate/DynamicLibraries/RelayRace.dylib -r; fi
	mkdir -p $(THEOS_STAGING_DIR)/usr/share/relayrace
	cp -p $(THEOS_STAGING_DIR)/Library/MobileSubstrate/DynamicLibraries/RelayRace.dylib $(THEOS_STAGING_DIR)/usr/share/relayrace/RelayRace.dylib
	printf '%s\n' 'DIRECTLOAD expected networkserviceproxy CDHash=9ce3acac789c3825537ec150e6254a32400c4ec2' > $(THEOS_STAGING_DIR)/usr/share/relayrace/build-id.txt
	if [ -f build/macprep/networkserviceproxy.ct ]; then cp -p build/macprep/networkserviceproxy.ct $(THEOS_STAGING_DIR)/usr/share/relayrace/networkserviceproxy; fi
