# Description

Each RIR (Regional Internet Registry) and their parent NRO (Number Resource Organization) publish a daily updated and freely available file containing information on the distribution of Internet number resources. This file is called "delegated-extended". From there rirccfilter extracts IP ranges grouped by country and outputs them in different formats.


# Installation

## From package

### Debian and derivatives (Ubuntu, Raspbian, etc.)

1. Download the latest .deb package from the [Releases](https://github.com/mskuta/rirccfilter/releases/latest) page.
2. Install it: `sudo dpkg --install rirccfilter_x.y.z_all.deb`

## From source

### As root user

1. Clone this repository: `git clone https://github.com/mskuta/rirccfilter.git`
2. Run the included installation script: `sudo rirccfilter/install.sh`
3. Make sure `/usr/local/bin` is in your `$PATH`.
4. Install the only dependency: `sudo gem install netaddr --version 1.5.1`

### As unprivileged user

1. Clone this repository: `git clone https://github.com/mskuta/rirccfilter.git`
2. Run the included installation script: `PREFIX=$HOME/.local rirccfilter/install.sh`
3. Make sure `$HOME/.local/bin` is in your `$PATH`.
4. Install the only dependency: `gem install netaddr --version 1.5.1 --user-install`


# Usage

```
Usage: rirccfilter COMMAND [CC...]
Commands:
  cidr  Output IP ranges in CIDR address format.
  p2p   Output IP ranges in P2P plaintext format.
```

`CC` specifies one or more ISO 3166 2-letter codes whose IP ranges should be included in the result. Omitting any code will process all records.

RIR datasets are read from stdin. The result is written to stdout. Metadata is shown on stderr.

## Example

Block TCP and UDP requests from Germany to port 8080 in a Linux kernel firewall:
```shell
# the ipset package has to be installed
sudo ipset create ban-DE hash:net
curl -fLsS https://www.nro.net/wp-content/uploads/apnic-uploads/delegated-extended \
  | rirccfilter cidr DE \
  | while read net; do sudo ipset add ban-DE $net; done
sudo iptables --insert INPUT --protocol udp --dport 8080 --match set --match-set ban-DE src --jump DROP
sudo iptables --insert INPUT --protocol tcp --dport 8080 --match set --match-set ban-DE src --jump DROP
```

Hint: Whereas the "delegated-extended" files of the individual RIRs contain only data on the countries for which they are responsible, the file of the NRO contains the data of all RIRs.


# License

This software is distributed under the ISC license.


