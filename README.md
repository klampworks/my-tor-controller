my-tor-controller
=================

Utility to monitor and modify the status of a running Tor process.

This application connects to the Tor control port running on the local machine with a Unix socket and communicates using the Tor control protocol.

Usage: -p &lt;port&gt; -a &lt;password&gt; (-n|-d)

* -n Builds a new Tor circuit. It does the same thing as Vidalia's "new identity". Returns 0 on success and 1 on failure.
* -d Dumps the ip addresses of the currently used Entry Guards. The original idea was the plug these values into iptables to prevent leaks but there is no real advatage to this over the Tails style firewall.
* -p Control port, set it in your torrc.
* -a Password for control port (sanatised on exit).
