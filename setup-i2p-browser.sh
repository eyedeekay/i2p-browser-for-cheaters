#! /usr/bin/env sh

## USAGE:

## in other scripts:

# set i2pbrowser_directory and i2pbrowser_port in the sourceing script:
#    export i2pbrowser_directory="path_to_a_tbb" #No default, will fail if unset
#       #or not pointed at a TBB
#    export i2pbrowser_port="4444" #Defaults to 4444, change only if using a non
#       #default i2p http proxy
#    source ./setup-i2p-browser.sh

## from the terminal:

#    ./setup-i2p-browser.sh "path_to_tbb"(required) "4444"(optional)

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
    if [ -z "$i2pbrowser_port" ]; then
        i2pbrowser_port="4444"
    fi
fi

if [ -z "$i2pbrowser_directory" ]; then
    echo "error; i2pbrowser_directory unset" 1>&2
    exit 1
fi

extension_overrides="$i2pbrowser_directory/Browser/TorBrowser/Data/Browser/profile.default/preferences/extension-overrides.js"
sysprefs_location="$i2pbrowser_directory/Browser/TorBrowser/Data/Browser/profile.default/prefs.js"

echo "modifying Tor Browser Bundle in: $i2pbrowser_directory for use with i2p. http port is set to $i2pbrowser_port" 1>&2

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

