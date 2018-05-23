# Overrides for Extension Preferences
# Tor Browser Bundle
# Do not edit this file.

# HTTPS Everywhere Preferences:
pref("extensions.https_everywhere._observatory.popup_shown", true);
pref("extensions.https_everywhere.toolbar_hint_shown", true);

# NoScript Preferences:
pref("capability.policy.maonoscript.javascript.enabled", "allAccess");
pref("capability.policy.maonoscript.sites", "[System+Principal] about: about:tbupdate about:tor chrome: resource: blob: mediasource: moz-extension: moz-safe-about: about:neterror about:certerror about:feeds about:tabcrashed about:cache");
pref("noscript.default", "[System+Principal] about: about:tbupdate about:tor chrome: resource: blob: mediasource: moz-extension: moz-safe-about: about:neterror about:certerror about:feeds about:tabcrashed about:cache");
pref("noscript.mandatory", "[System+Principal] about: about:tbupdate about:tor chrome: resource: blob: mediasource: moz-extension: moz-safe-about: about:neterror about:certerror about:feeds about:tabcrashed about:cache");
pref("noscript.ABE.enabled", false);
pref("noscript.ABE.notify", false);
pref("noscript.ABE.wanIpAsLocal", false);
pref("noscript.confirmUnblock", false);
pref("noscript.contentBlocker", true);
pref("noscript.firstRunRedirection", false);
pref("noscript.global", true);
pref("noscript.gtemp", "");
pref("noscript.opacizeObject", 3);
pref("noscript.forbidWebGL", true);
pref("noscript.forbidFonts", false);
pref("noscript.options.tabSelectedIndexes", "5,0,0");
pref("noscript.policynames", "");
pref("noscript.secureCookies", true);
pref("noscript.showAllowPage", false);
pref("noscript.showBaseDomain", false);
pref("noscript.showDistrust", false);
pref("noscript.showRecentlyBlocked", false);
pref("noscript.showTemp", false);
pref("noscript.showTempToPerm", false);
pref("noscript.showUntrusted", false);
pref("noscript.STS.enabled", false);
pref("noscript.subscription.lastCheck", -142148139);
pref("noscript.temp", "");
pref("noscript.untrusted", "");
pref("noscript.forbidMedia", false);
pref("noscript.allowWhitelistUpdates", false);
pref("noscript.fixLinks", false);
// Now handled by plugins.click_to_play
pref("noscript.forbidFlash", false);
pref("noscript.forbidSilverlight", false);
pref("noscript.forbidJava", false);
pref("noscript.forbidPlugins", false);
// Usability tweaks
pref("noscript.showPermanent", false);
pref("noscript.showTempAllowPage", true);
pref("noscript.showRevokeTemp", true);
pref("noscript.notify", false);
pref("noscript.autoReload", true);
pref("noscript.autoReload.allTabs", false);
pref("noscript.cascadePermissions", true);
pref("noscript.restrictSubdocScripting", true);
pref("noscript.showVolatilePrivatePermissionsToggle", false);
pref("noscript.volatilePrivatePermissions", true);
pref("noscript.clearClick", 0);
# Tor Launcher preferences (default bridges):

// Default bridges.




pref("intl.locale.matchOS", false);

pref("extensions.torbutton.use_nontor_proxy", true);

