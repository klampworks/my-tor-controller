my-tor-controller
=================

Utility to monitor and modify the status of a running Tor process.

This application connects to the Tor control port running on the local machine with a Unix socket and communicates using the Tor control protocol.

* Entirely written in C.
* Connects to the Tor control port using TCP sockets.
* Uses the Tor Control Protocol to communicate with a running Tor process.
* Responses from Tor are parsed using Flex and Bison from hand written grammars.
* When run as root securely drops privileges and switches to a custom UID, facilitating integration with popular fire walling strategies such as that used by Tails.

Usage: (-p &lt;port&gt; -a &lt;password&gt; | -P &lt;filename&gt;) (options)

* -p Control port, set it in your torrc.
* -a Password for control port (sanatised on exit).
* -P Read Password and port from a text file instead. Format: &lt;port&gt;&lt;space&gt;&lt;password&gt;

Options

* -n **Builds a new Tor circuit**. It does the same thing as Vidalia's "new identity". Returns 0 on success and 1 on failure.
* -d **Dumps the IP addresses of the currently selected Entry Guards**. This allows the creation of very strict firewall rules in order to avoid clearnet leaks.
* -f **Dumps all currently built circuits and a *full description* of each node.** See *full description*.
* -e **Dump *full description* of Exit Nodes only.** See *full description*.

Full Description:
A full description for an Onion Router includes:

* Nickname
* OR id (40 character hash)
* IP address
* Platform
* Uptime
* Bandwidth (min, max and average)
* RSA Onion Key
* RSA Signing key
* Country
