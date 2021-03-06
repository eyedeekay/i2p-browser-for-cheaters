Progress
========

This is a sort of progress report on my part in getting the i2p browser into
Whonix:

tb-updater
----------

*available in testers*

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

*available in testers via tb-starter*

In order to make Tor Browser work with alternative networks like i2p, ZeroNet,
FreeNet, and similar, the browser needs a profile and a way to select it in
lieu of the default Tor Browser profile. In order to do this in a
straightforward, easily established and easily reversible way, I've packaged a
profile in tb-starter that I've been testing at [tb-profile-i2p](https://github.com/eyedeekay/tb-profile-i2p)
and an alternative launcher which ensures that the i2p browser profile is
selected as Tor's default profile is. The profile is copied to the ~/.i2pb
folder, then symlinked to the Tor Browser's profile directory, then the
launchers(start-i2p-browser and start-i2p-browser.desktop) are symlinked into
the appropriate Tor Browser directory from their home in
/var/lib/tb-profile-i2p. This is finished, and instead of proposing a new
package, I added it to tb-starter. **Very** open to change on that matter, but
the profile itself is in good order.

tb-starter
----------

*available in testers*

Whonix has another very useful helper script for launching a Tor Browser Bundle
safely in a package called tb-starter. It solves quite a few relevant problems
with distributing a browser like the Tor Browser Bundle on an operating system
with policies like Debian and an architecture like Whonix. It's actually a
really convenient way of running Tor Browser on vanilla Debian too, but YMMV.
tb-starter detects things about the system and configures Tor Browser using
environment variables(As opposed to the preference-setting here). If the helper
script(/usr/bin/torbrowser) doesn't find a Tor Browser Bundle at
$HOME/.tb/tor-browser, then it will invoke update-torbrowser.

The changes I made can be viewed [here:](https://github.com/eyedeekay/tb-starter/compare)

It adds functionality for i2p Browser which operates in parallel to the way that
the regular Tor Browser does. It can be launched with /usr/bin/i2pbrowser.

You can test it by installing with 'make install' or using the package manager
by running

        tar -czvf ../tb-starter_3.7.orig.tar.gz .
        debuild -us -uc

from the cloned repo directory. Once installed, you'll have a helper script
at /usr/bin/i2pbrowser which will launch your pre-configured Tor Browser for
i2p, hereafter called i2p browser. This version is available in the Whonix
testers repository.

### Configuring start-tor-browser with Environment Variables

*work-in-progress*

In order to get this working, I needed to re-create the start-tor-browser
script to launch the i2p Browser specifically. This is because
start-tor-browser uses the hard-coded path to the Tor Browser Profile which must
be changed so the i2p Browser profile can be used, and because we need to change
the WM_CLASS and other features so that the system does not confuse the Tor and
i2p Browsers. In turn. because start-tor-browser generates .desktop launchers
for use with a desktop environment, those need to be altered to safely launch
the i2p Browser instead. The only place that it's possible to do these things is
in start-tor-browser.

tb-apparmor-profile
-------------------

*available in testers*

Whonix ships apparmor profiles for Tor Browser Bundle. I noticed that
/usr/bin/i2pbrowser launched correctly when /usr/bin/torbrowser didn't due to
a faulty torbrowser apparmor profile. I need to create an apparmor profile for
the i2p browser. This is implemented and corresponds to the version in Whonix's
testers repository.

open-link-confirmation
----------------------

*available in testers*

The open-link-confirmation version in the Whonix testers repository honors
$tb_title to set the display name of the browser it will open.

anon-ws-disable-stacked-tor
---------------------------

*work-in-progress*

Eventually, Tor Browser Bundle will no longer speak TCP, it will communicate via
a Unix socket. To be prepared for this change, I'm going to set up a rule for
setting up the socket in anon-ws-disable-stacked-tor.
