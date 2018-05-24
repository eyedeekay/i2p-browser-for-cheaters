# i2p-browser-for-cheaters

The path of least resistance to a Linux-only i2p browser. Modifies a tor browser
and spits out a tar.gz.

Since this got a little attention, I figure I should explain what I did here
for good measure. All it does it take the standard Tor Browser Bundle,
applies custom settings to torlauncher, torbutton, and HTTPS everywhere(I've
disabled the observatory and automatic updates for now,for now, until I learn
more about HTTPS everywhere rulesets and how they work/[worked](https://github.com/chris-barry/darkweb-everywhere) with i2p).
Then it adds a configuration file from ~~PurpleI2P~~ Me for now, based on the
PurpleI2P settings and experimentation: https://github.com/eyedeekay/i2p-browser-for-cheaters/raw/master/i2p-browser.js
and replaces the Tor socks proxy with the i2p http proxy. In order to do that,
the extension-overrides file needs to be edited to look like this https://github.com/eyedeekay/i2p-browser-for-cheaters/raw/master/extension-overrides.js
Then it renames a few files from something like start-tor-browser to
start-i2p-browser and zips it back up.

Oh also it determines which version of the TBB to use by scraping the TBB
download page and getting the latest stable version. Which could be useful or
could be unstable.

By the way, these notes are, at this point, as much for my benefit as anybody
else's. Need to keep track of what's going on.

From there, it can be run from the working directory, run in the Docker
container used to build it(look in the Makefile under "make browse"), or
re-packaged with checkinstall and run under it's own user.

So I cheated. Like it says in the title. I took a bunch of shortcuts and it's
not as good as it should be. Thanks to hulahoopwhonix I know how to make
TorButton cooperate with a non-tor proxy now, so that situation has improved.
But I'm sure there's plenty of room for improvement still. This readme, for
instance. Could be broken up into done/not done tasks as they are identified.

Besides TorButton, If one wants to, at some point, create an i2p browser bundle,
then one will need something like TorLauncher to make sure that i2p starts.
Pretty soon, it seems that TBB may only work over the Unix socket, so I'll need
to deal with that. And I'm not at all sure what i2p's plans for HTTPS are yet,
but I'm aware of some. I don't change the NoScript configuration and frankly,
I find Firefox in general a little complicated and hard to configure. There is
plenty I could have missed. I made this because I needed something like it and
didn't particularly like the other options. Mostly that they were based on old
versions of TorBrowser. ~~Which makes me nervous about the config file I~~
~~pulled~~. Thank goodness for constructive criticism and peer-review. The new
sysprefs.js merely sets the i2p proxy and relies on TorButton to fix the
remaining settings. This should make the browser even less unique to the user.

For more details about the issues being addressed in this browser, please see:
https://forums.whonix.org/t/i2p-integration/

To generate your own, just type

        make

Use at your own risk. It's torbrowser, less the Tor bits, pointed at localhost
4444.

If you don't want to use a TBB downloaded by the makefile, running

        ./setup-i2p-browser.sh "$path_to_browser" "$desired_port"

will modify an existing TBB to use i2p.

My gpg key is: 70D2060738BEF80523ACAFF7D75C03B39B5E14E1

you can find the full public key at
[https://eyedeekay.github.io/apt-now/eyedeekay.github.io.gpg.key](https://eyedeekay.github.io/apt-now/eyedeekay.github.io.gpg.key)

