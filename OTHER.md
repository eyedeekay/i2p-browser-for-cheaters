Progress
========

This is a sort of progress report on my part in getting the i2p browser into
Whonix:

tb-updater
----------

Whonix has a useful helper script which makes sure you have an up-to-date Tor
Browser in a package called tb-updater. The script(/usr/bin/update-torbrowser)
checks for the presence of a current Tor browser at $HOME/.tb/tor-browser, and
downloads it if one is not present. It can do this on Whonix and non-Whonix
distributions. This script was simple to modify to add an --i2p flag, which does
exactly the same procedure to download a Tor Browser Bundle(unmodified) to the
$HOME/.i2pb/i2p-browser path.

The changes I made can be viewed [here:](https://github.com/eyedeekay/tb-updater/compare)

You can test it by installing with 'make install' or using the package manager
by cloning my fork and running

        tar -czvf ../tb-updater_6.2.orig.tar.gz .
        debuild -us -uc

from the cloned repo directory. Once installed, you can download an i2p browser
by running torbrowser-updater with the new **--i2p** flag. As of June 10th, 2018
this change has been submitted to https://github.com/Whonix/tb-updater by a pull
request. As of June 12th, 2018 the tb-updater script modified for i2p has been
included in tb-updater.

tb-profile-i2p
--------------

In order to make Tor Browser work with alternative networks like i2p, ZeroNet,
FreeNet, and similar, the browser needs a profile and a way to select it in
lieu of the default Tor Browser profile. In order to do this in a
straightforward, easily established and easily reversible way, I've packaged a
profile in tb-starter that I've been testing at (tb-profile-i2p)[https://github.com/eyedeekay/tb-profile-i2p]
and an alternative launcher which ensures that the i2p browser profile is
selected as Tor's default profile is. The profile is copied to the ~/.i2pb
folder, then symlinked to the Tor Browser's profile directory, then the
launchers(start-i2p-browser and start-i2p-browser.desktop) are symlinked into
the appropriate Tor Browser directory from their home in
/var/lib/tb-profile-i2p.

tb-starter
----------

Whonix has another very useful helper script for launching a Tor Browser Bundle
safely in a package called tb-starter. It solves quite a few relevant problems
with distributing a browser like the Tor Browser Bundle on an operating system
with policies like Debian and an architecture like Whonix. It's actually a
really convenient way of running Tor Browser on vanilla Debian too, but YMMV.
tb-starter detects things about the system and configures Tor Browser using
environment variables(As opposed to the preference-setting here). If the helper
script(/usr/bin/torbrowser) doesn't find a Tor Browser Bundle at
$HOME/.tb/tor-browser, then it will invoke tb-updater.

The changes I made can be viewed [here:](https://github.com/eyedeekay/tb-starter/compare)

You can test it by installing with 'make install' or using the package manager
by running

        tar -czvf ../tb-starter_3.2.orig.tar.gz .
        debuild -us -uc

from the cloned repo directory. Once installed, you'll have a helper script
at /usr/bin/i2pbrowser which will launch your pre-configured Tor Browser for
i2p, hereafter called i2p browser.

~~torbutton~~
---------

~~Most of the environment variables set by tb-starter pertain to Torbutton.~~
~~Unfortunately, there was no environment variable for~~
~~extensions.torbutton.use\_nontor\_proxy and there was no environment variable~~
~~for setting the HTTP proxy(And i2p's SOCKS proxy isn't used for web-browsing~~
~~under normal circumstances). In order to fix the SOCKS proxy issue in a way that~~
~~did not complicate the Tor Browser itself and which accounted for a future where~~
~~the Tor Browser Bundle communicates via a Unix socket instead of a SOCKS proxy,~~
~~I chose to use the TOR\_SOCKS\_IPC\_PATH environment variable to direct the~~
~~i2p browser to communicate with~~
~~/var/run/i2p-torbrowser-sockets-workaround/i2p\_127.0.0.1\_4447.sock.~~
~~Unfortunately, this wasn't sufficient, even with the existing environment~~
~~variables, to allow the Tor Browser to communicate over i2p. In order to do~~
~~that, I neeeded to set extensions.torbutton.use\_nontor\_proxy=true, which means~~
~~adding an environment variable to configure Torbutton.~~

~~In order to do that, I made the change shown in [this commit](https://github.com/eyedeekay/torbutton/commit/3879775737a640a78e4cbe99605ac22d7b201a0a).~~

~~In order to test it, you'll need to close my fork of Torbutton and run the~~

        ./makexpi.sh

~~from the cloned repo director. Then you'll need to start the i2p browser and go~~
~~to about:config, where you'll need to disable xpiinstall.signatures. Then you~~
~~can install the add-on from the newly generated .xpi file. You may need re-start~~
~~the browser for the changes to take effect. As of June 10th, 2018, this change~~
~~has been [submitted as a trac ticket to the Tor Project](https://trac.torproject.org/projects/tor/ticket/26341).~~

i2p-torbrowser-sockets-workaround
---------------------------------

Since Tor Browser Bundle needs to communicate over a Unix socket, and since i2p
does not provide one by default, I needed to provide one. For testing, I simply
did this with socat, roughly thus:

        socat -t600 -x -v UNIX-LISTEN:"/var/run/i2p-torbrowser-sockets-workaround/i2p_127.0.0.1_4444.sock",mode=777,reuseaddr,fork TCP-CONNECT:localhost:4444

However to start these automatically, and direct them to a guest, it would be
better to have them managed by the system/services. So that's what this repo
is for. It's barely tested, as I'm usually travelling and my netbook doesn't
have the horsepower to support a Qubes or Whonix-based setup.

As far as I can reckon, once I have this finished some semblance of support for
i2p browsing in Whonix [will be within reach.](https://github.com/eyedeekay/i2p-torbrowser-sockets-workaround)

