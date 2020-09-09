# This file is part of rirccfilter, distributed under the ISC license.
# For full terms see the included COPYING file.

function showusage() {
	print("Usage: rirccfilter [-v cc=CC] [-v format=FORMAT]") >"/dev/stderr"
	print("\nCC has to be an ISO 3166 2-letter code.") >"/dev/stderr"
	print("\nFORMAT can be one of:") >"/dev/stderr"
	print("  cidr  Output IP ranges in CIDR address format.") >"/dev/stderr"
	print("  p2p   Output IP ranges in P2P plaintext format (default).") >"/dev/stderr"
	print("") >"/dev/stderr"
	exit 2
}

BEGIN {
	# set field separator for RIR datasets
	FS = "|"

	# calculate this only once
	logof2 = log(2)

	# check given format 
	_format = "p2p"
	if (format) {
		if (format != "cidr" && format != "p2p")
			showusage()
		_format = format
	}

	# check given country code
	_cc = ""
	if (cc) {
		if (cc !~ /^[[:alpha:]]{2}$/)
			showusage()
		_cc = toupper(cc)
	}
}

/^\s*$/ || /^\s*#/ {
	# this line is blank or a comment
	next
}

NF == 6 && $NF == "summary" {
	# this line is a header (summary)
	next
}

NF == 7 && FNR == 1 {
	# this line is a header (version)
	k[1] = "Version"
	k[2] = "Registry"
	k[3] = "Serial"
	k[4] = "Records"
	k[5] = "Startdate"
	k[6] = "Enddate"
	k[7] = "UTC-Offset"
	for (i = 1; i <= NF; i++)
		print(k[i], $i) >"/dev/stderr"
}

NF == 9 && $3 == "ipv4" {
	# this line is a record

	# skip records not matching the selected county
	if (_cc && _cc != $2)
		next

	switch (_format) {
		case "cidr":
			logofhostcount = log($5)
			hostbits = logofhostcount / logof2
			if (and($5, $5 - 1) != 0) {
				# not all records represent CIDR ranges; round up to
				# ensure that all host identifiers of the selected
				# country are included
				hostbits = int(hostbits) + 1
			}
			print($4 "/" 32 - hostbits)
			break
		case "p2p":
			split($4, octets, ".")
			network = lshift(octets[1], 24) + lshift(octets[2], 16) + lshift(octets[3], 8) + octets[4]

			# determine usable IP range by excluding network and broadcast
			# addresses
			hostmin = network + 1
			hostmax = network + $5 - 2

			printf("%s%d:%d.%d.%d.%d-%d.%d.%d.%d\n",
			       $2,
			       ++n[$2],
			       and(rshift(hostmin, 24), 0xff),
			       and(rshift(hostmin, 16), 0xff),
			       and(rshift(hostmin,  8), 0xff),
			       and(hostmin, 0xff),
			       and(rshift(hostmax, 24), 0xff),
			       and(rshift(hostmax, 16), 0xff),
			       and(rshift(hostmax,  8), 0xff),
			       and(hostmax, 0xff))
			break
	}
}

# vim: noet sw=8 ts=8
