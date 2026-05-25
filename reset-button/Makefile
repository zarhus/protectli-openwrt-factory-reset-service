# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=reset-button
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0-only

include $(INCLUDE_DIR)/package.mk

define Package/reset-button
  SECTION:=base
  CATEGORY:=Base system
  TITLE:=Factory reset button handler for Protectli hardware
  DEPENDS:=+fstools +dmidecode
  DEFAULT:=y
endef

define Package/reset-button/description
  Monitors the hardware reset button on Protectli VP-series platforms.
  When the button is held for 10 seconds, triggers a factory reset
  (firstboot) and reboots the device.
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/reset-button/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) ./files/reset-button-watch.sh $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/reset-button.init $(1)/etc/init.d/reset-button
endef

$(eval $(call BuildPackage,reset-button))
