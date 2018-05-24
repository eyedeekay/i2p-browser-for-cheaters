# Packaging goals

The priority right now is the maintenance of the script. This is just my notes
on a potential long-term goal. I'd love input.

Hypothetically, I'd really like to make an i2p Browser Bundle that's just as
easy to use as the Tor Browser Bundle, with similar safety features where
applicable to i2p. Obviously non-reproducibility is a serious issue here.

Besides that, there are some fundamental differences between these networks and
the natural ways they are used means that there's not a direct approach for some
things. For instance, Tor starts pretty quickly, i2p needs to bootstrap and
gather information and open tunnels before it's ready to use. It's not long, but
it's not what people expect when they simply launch an application. So an i2p
browser for now has to assume a running i2p router to use with an http proxy
open. Fortunately, it'll just fail instead of falling back to the clearnet,
obviously. But if one wants to package an i2prouter which is launched by the
browser, then the router needs to be able to signal the browser when it's ready
and the browser needs to indicate to the user the i2prouter's status. I'm pretty
sure this is analogous to what torlauncher and torbutton do with the
controlport. On the matter of identity, it can be useful to have a single
anonymous identity across multiple sessions, or one might want identities to be
throwaway on a per-session basis, or one might want to make identities that are
more aggressively separated. All of these are possible, even if the code is, in
some significant places, obviously written by a recent amateur(that was me). I
promise I'll get back to making it better this weekend.
