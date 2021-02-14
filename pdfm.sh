#!/bin/sh

MYNAME=`basename $0`
IMAGEWIDTH="43%"

while [ "$1" ]; do
	case "$1" in
	--)
		shift
		break
		;;
	-1)
		IMAGEWIDTH="80%"
		;;
	-2)
		IMAGEWIDTH="43%"
		;;
	-h|--help)
		echo "Usage: $MYNAME [options] <PDF-File>"
		echo ""
		echo "option:"
		echo "    -1           Display two pages on the screen."
		echo "    -2           Dispaey one page on the screen."
		echo "    -h, --help   Display this help message."
		exit 0
		;;
	-*)
		echo "ERROR: Unknown Option -- $1" >&2
		echo "Try $MYNAME -h for more details." >&2
		exit 1
		;;
	*)
		break
	esac
	shift
done

if [ -z "$1" ]; then
	echo "ERROR: No File specified." >&2
	echo "Try $MYNAME -h for more details." >&2
	exit 1
fi

TEMPDIR=`mktemp -d`
TEMPBASE="$TEMPDIR/pdfm"
TEMPHTML=`tempfile -s.html`

PDFPAGE=`pdfinfo $1 | grep "Pages" | awk '{ print $2 }'`

printf 'Preparating '

for i in `seq $PDFPAGE`
do
	pdftoppm -f $i -l $i -png $1 $TEMPBASE && printf '.' &
done
wait
printf ' '
printf 'done.\n'

cat << EOF > $TEMPHTML
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
<HTML>
<HEAD>
<TITLE>$1</TITLE>
</HEAD>
<BODY>
<CENTER>
EOF

find $TEMPDIR/*.png | sort | while read line
do
	echo "<IMG SRC=\"$line\" WIDTH=\"$IMAGEWIDTH\">" >> $TEMPHTML
done

cat << EOF >> $TEMPHTML
</CENTER>
</BODY>
</HTML>
EOF

w3m $TEMPHTML

rm -rf $TEMPHTML $TEMPDIR
