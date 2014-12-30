GO_EASY_ON_ME = 1
SDKVERSION = 8.0
ARCHS = armv7 arm64

include theos/makefiles/common.mk
TWEAK_NAME = MyLapse
MyLapse_FILES = Tweak.xm
MyLapse_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

