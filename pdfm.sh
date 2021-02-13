#!/bin/sh

if [ $# -ne 1 ]; then
	echo "Usage: `basename $0` pdf-file"
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
	echo "<IMG SRC=\"$line\" WIDTH=\"43%\">" >> $TEMPHTML
done

cat << EOF >> $TEMPHTML
</CENTER>
</BODY>
</HTML>
EOF

w3m $TEMPHTML

rm -rf $TEMPHTML $TEMPDIR
