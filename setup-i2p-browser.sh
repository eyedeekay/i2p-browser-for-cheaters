#! /usr/bin/env sh

i2pbrowser_syspref_js="
pref(\"network.proxy.no_proxies_on\", 0);
pref(\"network.proxy.type\", 1);
pref(\"network.proxy.http\", \"127.0.0.1\");
pref(\"network.proxy.http_port\", 4444);
pref(\"network.proxy.share_proxy_settings\", true);
"

i2pbrowser_append_extension_overrides="
pref(\"extensions.torbutton.use_nontor_proxy\", true);
"

validate_i2pbrowser_directory(){
    temp="$1"
    if [ -d "$temp" ]; then
        if [ -f "$temp/Browser/TorBrowser/Data/Browser/profile.default/preferences/extension-overrides.js" ]; then
            echo "$temp"
        else
            echo "error; i2pbrowser_directory does not appear to be a TBB directory" 1>&2
            exit 1
        fi
    else
        echo "error; i2pbrowser_directory is not a directory" 1>&2
        exit 1
    fi
}

if [ ! -z "$1" ]; then
    i2pbrowser_directory=$(validate_i2pbrowser_directory "$1")
fi

if [ ! -z "$2" ]; then
    i2pbrowser_port="$2"
else
    i2pbrowser_port="4444"
fi

if [ -z "$i2pbrowser_directory" ]; then
    echo "error; i2pbrowser_directory unset" 1>&2
    exit 1
fi

extension_overrides="$i2pbrowser_directory/Browser/TorBrowser/Data/Browser/profile.default/preferences/extension-overrides.js"
sysprefs_location="$i2pbrowser_directory/Browser/TorBrowser/Data/Browser/profile.default/prefs.js"

echo "modifying Tor Browser Bundle in: $i2pbrowser_directory for use with i2p." 1>&2

grep -v torlauncher "$extension_overrides" > \
    "$i2pbrowser_directory/Browser/TorBrowser/Data/Browser/profile.default/preferences/temp.js"

mv "$i2pbrowser_directory/Browser/TorBrowser/Data/Browser/profile.default/preferences/temp.js" \
    "$extension_overrides"

echo "$i2pbrowser_append_extension_overrides" | tee -a "$extension_overrides"

echo "$i2pbrowser_syspref_js" | tee "$sysprefs_location"

sed -i "s|4444|$i2pbrowser_port|g" "$sysprefs_location"

rm -f "$i2pbrowser_directory/Browser/TorBrowser/Data/Browser/profile.default/extensions/tor-launcher*.xpi" \
    "$i2pbrowser_directory/Browser/TorBrowser/Data/Browser/profile.default/extensions/https*.xpi" \
    "$i2pbrowser_directory/Browser/TorBrowser/Data/Browser/profile.meek-http-helper"

