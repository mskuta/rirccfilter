# Description

Each RIR (Regional Internet Registry) and their parent NRO (Number Resource Organization) publish a daily updated and freely available file containing information on the distribution of Internet number resources. This file is called "delegated-extended". From there rirccfilter extracts IP ranges grouped by country and outputs them in [P2P plaintext format](https://en.wikipedia.org/wiki/PeerGuardian#P2P_plaintext_format).


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

CC has to be an ISO 3166 2-letter code.

```

`CC` specifies a country code whose IP ranges should be included in the result. Omitting it will process all records.

RIR datasets can be passed either as filename or via stdin. The result is written to stdout. Metadata is shown on stderr.

Hint: Whereas datasets of individual RIRs contain only records about countries for which they are responsible, the file of the NRO includes the records of all RIRs.

## Example

Download the latest RIR dataset, filter IP addresses from Germany and store them in file `blocklist`:
```shell
curl -fLsS https://www.nro.net/wp-content/uploads/apnic-uploads/delegated-extended | rirccfilter -v cc=DE >blocklist
```


# License

This software is distributed under the ISC license.


