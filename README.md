# Description

Each RIR (Regional Internet Registry) and their parent NRO (Number Resource Organization) publish a daily updated and freely available file containing information on the distribution of Internet number resources. This file is called "delegated-extended". From there rirccfilter extracts IP ranges grouped by country and outputs them in CIDR notation.


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

### As unprivileged user

1. Clone this repository: `git clone https://github.com/mskuta/rirccfilter.git`
2. Run the included installation script: `PREFIX=$HOME/.local rirccfilter/install.sh`
3. Make sure `$HOME/.local/bin` is in your `$PATH`.


# Usage

```
Usage: rirccfilter [-v cc=CC]
```

`CC` specifies an ISO 3166 2-letter code whose IP ranges should be included in the result. Omitting it will process all records.

RIR datasets are read from stdin. The result is written to stdout. Metadata is shown on stderr.

## Examples

Convert output to P2P plaintext format:
```shell
# the sipcalc package has to be installed
curl -fLsS https://www.nro.net/wp-content/uploads/apnic-uploads/delegated-extended \
  | rirccfilter \
  | sipcalc - \
  | awk -e '/^\[CIDR\]$/,/^-$/ { split($0, a, "[ \t]+-[ \t]+"); if (a[1] ~ /^Host address \(hex\)$/) { id = a[2] } else if (a[1] ~ /^Usable range$/) { from = a[2]; to = a[3] } } /^-$/ { print(id":"from"-"to) }'
```

Block TCP and UDP requests from Germany to port 8080 in a Linux kernel firewall:
```shell
# the ipset package has to be installed
sudo ipset create ban-DE hash:net
curl -fLsS https://www.nro.net/wp-content/uploads/apnic-uploads/delegated-extended \
  | rirccfilter -v cc=DE \
  | while read net; do sudo ipset add ban-DE $net; done
sudo iptables --insert INPUT --protocol udp --dport 8080 --match set --match-set ban-DE src --jump DROP
sudo iptables --insert INPUT --protocol tcp --dport 8080 --match set --match-set ban-DE src --jump DROP
```

Hint: Whereas the "delegated-extended" files of the individual RIRs contain only data on the countries for which they are responsible, the file of the NRO contains the data of all RIRs.


# License

This software is distributed under the ISC license.


