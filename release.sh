#! /bin/bash
#
# This file is part of Sympathy
# Copyright (c) 2016 Job and Esther Technologies, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
set -e
TARGET="$1"
PLATFORM="$2"
if [ "$TARGET"  = "" -o "$PLATFORM" = "" ]; then
	echo "Usage: $0 <target-platform> <path-to-jkop-eq-src-directory>"
	exit 1
fi
PLATFORM="$(cd "$PLATFORM" ; pwd)"
if [ "$WORKDIR" = "" ]; then
	WORKDIR="$(pwd)/build/$TARGET"
fi
if [ "$SRC" = "" ]; then
	SRC="$(pwd)"
fi
if [ "$EQC" = "" ]; then
	EQC="eqc"
fi
VERSION="$(cat "$SRC"/eqela.version)"
if echo "$VERSION" | grep '\.x$' > /dev/null
then
	VERSION="$VERSION.$(date '+%Y%m%d')"
fi
TPARAM="-target=${TARGET}"
GPARAM=""
if [ "$GCC" != "" ]; then
	GPARAM="-Ogcc=$GCC"
fi
rm -rf "$WORKDIR"
for app in symvhsd symmanager presspathy wimpathy symadmin symfiles
do
	"${EQC}" "$TPARAM" "${SRC}"/${app} -output="${WORKDIR}/apps/${app}" -platform="${PLATFORM}" "$GPARAM"
done
OUTPUTID="sympathy_${VERSION}_${TARGET}"
DEST="${WORKDIR}/${OUTPUTID}"
rm -rf "${DEST}"
mkdir -p "${DEST}"
for app in $(cd "${WORKDIR}"/apps/ && ls)
do
	cp -v "${WORKDIR}"/apps/${app}/${app}* "${DEST}"/
done
cp "${SRC}"/README.md "${DEST}"/README
cp "${SRC}"/LICENSE "${DEST}"/LICENSE
(cd "$WORKDIR" ; tar jcvf "$OUTPUTID".tar.bz2 "$OUTPUTID")
(cd "$WORKDIR" ; zip -r "$OUTPUTID".zip "$OUTPUTID")
ls -l "$WORKDIR"/"$OUTPUTID".*
