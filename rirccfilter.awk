function perror(string) {
	print("Error: " string) >"/dev/stderr"
}
BEGIN {
	FS = "|"
	logof2 = log(2)  # calculate only once
	if (cc != "") {
		if (cc !~ /^[[:alpha:]]{2}$/) {
			perror("Invalid country code: " cc)
			exit 2
		}
		cc = toupper(cc)
	}
}
{
	if (length($0) == 0 || substr($0, 1, 1) == "#") {
		# this line is blank or a comment
		next
	}
	else if (NF == 6 && $NF == "summary") {
		# this line is a header (summary)
		next
	}
	else if (NF == 7 && NR == 1) {
		# this line is a header (version)
		k[1] = "version"
		k[2] = "Registry"
		k[3] = "Serial"
		k[4] = "Records"
		k[5] = "Startdate"
		k[6] = "Enddate"
		k[7] = "UTC-Offset"
		for (i = 1; i <= NF; i++) {
			print(k[i] ": " $i) >"/dev/stderr"
		}
	}
	else if (NF == 9) {
		# this line is a record
		if ($3 == "ipv4") {
			if (cc != "" && cc != $2) {
				# skip record not matching selected county code
				next
			}

                        logofhostcount = log($5)
			hostbits = logofhostcount / logof2
			if (2 ^ hostbits != $5) {
				# not all records represent CIDR ranges;
				# round up to ensure that all host identifiers
				# of the selected country are included
				hostbits = int(hostbits) + 1
			}
			print($4 "/" 32 - hostbits)
		}
	}
	else {
		perror("Invalid input line: " $0)
		exit 1
	}
}

# vim: noet sw=8 ts=8
