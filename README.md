# i2p-browser-for-cheaters

The path of least resistance to a Linux-only i2p browser. Modifies a tor browser
and spits out a tar.gz.

Since this got a little attention, I figure I should explain what I did here
for good measure. All it does it take the standard Tor Browser Bundle,
~~removes the Torbutton and~~ TorButton has been added back in, TorLauncher
plugins, HTTPS everywhere(for now, until I learn more about HTTPS everywhere
rulesets and how they work/[worked](https://github.com/chris-barry/darkweb-everywhere) with i2p). Then it downloads a configuration
file from ~~PurpleI2P~~ Me for now, based on the PurpleI2P settings and
experimentation: https://github.com/eyedeekay/i2p-browser-for-cheaters/raw/master/syspref.js
and replaces the Tor socks proxy with the i2p http proxy. In order to do that,
the extension-overrides file needs to be edited to include use\_nontor\_proxy
true. Then it renames a few files from something like start-tor-browser to
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
then one will need something like TorLauncher to make sure that i2p starts. And
I'm not at all sure what i2p's plans for HTTPS are yet, but I'm aware of some.
I don't change the NoScript configuration and frankly, I find Firefox in general
a little complicated and hard to configure. There is plenty I could have missed.
I made this because I needed something like it and didn't particularly like the
other options. Mostly that they were based on old versions of TorBrowser.
~~Which makes me nervous about the config file I pulled~~. Thank goodness for
constructive criticism and peer-review. The new sysprefs.js merely sets the i2p
proxy and relies on TorButton to fix the remaining settings. This should make
the browser even less unique to the user.

For more details about the issues being addressed in this browser, please see:
https://forums.whonix.org/t/i2p-integration/

In the spirit of this being a total rip-off, here's the story of a nameless
hero.

        The principle of generating small amounts of finite improbability by
        simply hooking the logic circuits of a Bambleweeny 57 Sub-Meson Brain to
        an atomic vector plotter suspended in a strong Brownian Motion producer
        (say a nice hot cup of tea) were of course well understood — and such
        generators were often used to break the ice at parties by making all the
        molecules in the hostess's undergarments leap simultaneously one foot
        to the left, in accordance with the theory of indeterminacy.

        Many respectable physicists said that they weren't going to stand for
        this, partly because it was a debasement of science, but mostly because
        they didn't get invited to those sorts of parties.

        Another thing they couldn't stand was the perpetual failure they
        encountered while trying to construct a machine which could generate
        the infinite improbability field needed to flip a spaceship across the
        mind-paralyzing distances between the farthest stars, and at the end of
        the day they grumpily announced that such a machine was virtually
        impossible.

        Then, one day, a student who had been left to sweep up after a
        particularly unsuccessful party found himself reasoning in this way: If,
        he thought to himself, such a machine is a virtual impossibility, it
        must have finite improbability. So all I have to do in order to make
        one is to work out how exactly improbable it is, feed that figure into
        the finite improbability generator, give it a fresh cup of really hot
        tea... and turn it on!

        He did this and was rather startled when he managed to create the long
        sought after golden Infinite Improbability generator. He was even more
        startled when just after he was awarded the Galactic Institute's Prize
        for Extreme Cleverness he was lynched by a rampaging mob of respectable
        physicists who had realized that one thing they couldn't stand was a
        smart-arse.

To generate your own, just type

        make

Use at your own risk. It's torbrowser, less the Tor bits, pointed at localhost
4444.

My gpg key is: 70D2060738BEF80523ACAFF7D75C03B39B5E14E1

you can find the full public key at
[https://eyedeekay.github.io/apt-now/eyedeekay.github.io.gpg.key](https://eyedeekay.github.io/apt-now/eyedeekay.github.io.gpg.key)


