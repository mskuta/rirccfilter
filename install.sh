#!/bin/sh -e

# provide sane environment
\unalias -a
PATH="$(getconf PATH)"

SRCDIR="$(cd "$(dirname "$0")" && pwd)"
PRJNAME="${SRCDIR##*/}"

# set installation root directory
PREFIX="${PREFIX:-/usr/local}"

# install program
DSTDIR="$PREFIX/bin"
SRCFILE='rirccfilter.rb'
DSTFILE="${SRCFILE%%.*}"
TMPFILE="$(mktemp)"
printf '#!/usr/bin/env ruby\n\n' | cat - "$SRCDIR/$SRCFILE" >"$TMPFILE"
install -D "$TMPFILE" "$DSTDIR/$DSTFILE"
unlink "$TMPFILE"

# install docs
DSTDIR="$PREFIX/share/doc/$PRJNAME"
for SRCFILE in 'COPYING' 'README.md'; do
	DSTFILE="$SRCFILE"
	install -D "$SRCDIR/$SRCFILE" "$DSTDIR/$DSTFILE"
	chmod a-x "$DSTDIR/$DSTFILE"
done

exit 0

