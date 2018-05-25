#! /usr/bin/env sh

## USAGE:

## in other scripts:

# set i2pbrowser_directory and i2pbrowser_port in the sourceing script:
#    export i2pbrowser_directory="path_to_a_tbb" #No default, will fail if unset
#       #or not pointed at a TBB
#    export i2pbrowser_port="4444" #Defaults to 4444, change only if using a non
#       #default i2p http proxy
#    export i2pbrowser_addr="127.0.0.1"
#       #local or isolated i2p http proxy
#    source ./setup-i2p-browser.sh

## from the terminal:

#    ./setup-i2p-browser.sh "path_to_tbb"(required) "4444"(optional) "127.0.0.1(default)"

i2pbrowser_syspref_js="
pref(\"network.proxy.no_proxies_on\", 0);
pref(\"network.proxy.type\", 1);
pref(\"network.proxy.http\", \"127.0.0.1\");
pref(\"network.proxy.http_port\", 4444);
pref(\"network.proxy.share_proxy_settings\", true);
"

i2pbrowser_append_extension_overrides="
pref(\"extensions.https_everywhere._observatory.enabled\", false);
pref(\"extensions.https_everywhere.autoUpdateRulesets\", false);

pref(\"extensions.torbutton.use_nontor_proxy\", true);

//For socket conversion: in the future, I'll need to make TBB communicate with
//i2p over a unix socket. Fortunately, this is how you do that. It will be
//configurable in a similar way to the host:port configuration when that happens.
//pref(\"extensions.torlauncher.socks_port_use_ipc\", true);
//pref(\"extensions.torlauncher.socks_ipc_path\", \"/var/run/cheaters-i2p-browser_en-US/i2p.sock\");

pref(\"extensions.torlauncher.start_tor\", false);
pref(\"extensions.torlauncher.default_bridge_type\", \"\");
pref(\"extensions.torlauncher.prompt_at_startup\", false);
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

if [ ! -z "$3" ]; then
    i2pbrowser_addr="$3"
else
    if [ -z "$i2pbrowser_addr" ]; then
        i2pbrowser_addr="127.0.0.1"
    fi
fi

if [ -z "$i2pbrowser_directory" ]; then
    echo "error; i2pbrowser_directory unset" 1>&2
    exit 1
fi

extension_overrides="$i2pbrowser_directory/Browser/TorBrowser/Data/Browser/profile.default/preferences/extension-overrides.js"
i2pbrowser_preferences="$i2pbrowser_directory/Browser/TorBrowser/Data/Browser/profile.default/preferences/i2p-browser.js"

echo "modifying Tor Browser Bundle in: $i2pbrowser_directory for use with i2p.
    http port is set to $i2pbrowser_port
    firefox preferences are in $i2pbrowser_preferences
    extension preferences are in $extension_overrides
    " 1>&2

echo "$i2pbrowser_append_extension_overrides" | tee -a "$extension_overrides"

echo "$i2pbrowser_syspref_js" > "$i2pbrowser_preferences"

sed -i "s|4444|$i2pbrowser_port|g" "$i2pbrowser_preferences"

sed -i "s|127.0.0.1|$i2pbrowser_addr|g" "$i2pbrowser_preferences"

#sed -i "s|/var/run/cheaters-i2p-browser_en-US/i2p.sock|$i2pbrowser_socket|g" "$extension_overrides"

cat "$i2pbrowser_preferences"

mv "$i2pbrowser_directory/start-tor-browser.desktop" "$i2pbrowser_directory/start-i2p-browser.desktop"
mv "$i2pbrowser_directory/Browser/start-tor-browser.desktop" "$i2pbrowser_directory/Browser/start-i2p-browser.desktop"
mv "$i2pbrowser_directory/Browser/start-tor-browser" "$i2pbrowser_directory/Browser/start-i2p-browser"

find "$i2pbrowser_directory/" -name '*.desktop' -exec sed -i 's|start-tor-browser|start-i2p-browser|g' {} \;
