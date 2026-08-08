TARGET := iphone:clang:latest:15.0
ARCHS = arm64e
THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = RelayRace

RelayRace_FILES = Tweak.x
RelayRace_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-stage::
	# Keep Theos' canonical CydiaSubstrate compatibility install name for the
	# native Dopamine/ElleKit payload. ElleKit provides this framework shim.
	ldid -S -Icom.shalamand3r.relayrace $(THEOS_STAGING_DIR)/Library/MobileSubstrate/DynamicLibraries/RelayRace.dylib
	mkdir -p $(THEOS_STAGING_DIR)/usr/share/relayrace
	cp -p $(THEOS_STAGING_DIR)/Library/MobileSubstrate/DynamicLibraries/RelayRace.dylib $(THEOS_STAGING_DIR)/usr/share/relayrace/RelayRace.dylib

	# NathanLR's preloaded daemon uses its legacy absolute ElleKit path. Keep a
	# second signed copy for that path; the native copy remains framework-based.
	cp -p $(THEOS_STAGING_DIR)/Library/MobileSubstrate/DynamicLibraries/RelayRace.dylib $(THEOS_STAGING_DIR)/usr/share/relayrace/RelayRace.nathanlr.dylib
	install_name_tool -change @rpath/CydiaSubstrate.framework/CydiaSubstrate /System/Library/VideoCodecs/lib/libellekit.dylib $(THEOS_STAGING_DIR)/usr/share/relayrace/RelayRace.nathanlr.dylib
	ldid -S -Icom.shalamand3r.relayrace $(THEOS_STAGING_DIR)/usr/share/relayrace/RelayRace.nathanlr.dylib
	if [ -x tools/macprep/relayrace-ct-bypass-mac ]; then tools/macprep/relayrace-ct-bypass-mac -i $(THEOS_STAGING_DIR)/usr/share/relayrace/RelayRace.nathanlr.dylib -r; fi

	cp -p $(THEOS_STAGING_DIR)/Library/MobileSubstrate/DynamicLibraries/RelayRace.plist $(THEOS_STAGING_DIR)/usr/share/relayrace/RelayRace.plist
	printf '%s\n' 'DIRECTLOAD expected networkserviceproxy CDHash=9ce3acac789c3825537ec150e6254a32400c4ec2' > $(THEOS_STAGING_DIR)/usr/share/relayrace/build-id.txt
	if [ -f tools/macprep/networkserviceproxy.ct ]; then cp -p tools/macprep/networkserviceproxy.ct $(THEOS_STAGING_DIR)/usr/share/relayrace/networkserviceproxy; fi
