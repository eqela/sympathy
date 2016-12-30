#! /bin/bash
#
# This file is part of Sympathy
# Copyright (c) 2017 Job and Esther Technologies, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

SAM="$1"
JKOP="$2"
if [ "$SAM" = "" ]; then
	echo "Usage: $0 <sam-command> [jkopdir]"
	exit 1
fi
set -e
JKOP=" -libdir=$(cd "$JKOP"/src ; pwd)"
OUTPUTDIR="$(pwd)"
OUTPUT="$OUTPUTDIR/_release_tmp"
rm -rf "$OUTPUT"

function compileForTarget()
{
	local OUTPUTID
	local VERSION
	rm -rf "$OUTPUT"
	mkdir -p "$OUTPUT"
	for app in artsc artsy filesy keepalive # dby
	do
		echo
		echo "*** Building for $1: $app ***"
		echo
		$SAM slingc$JKOP "src/$app" -target="$1" -output="$OUTPUT/apps/$app"
		rm -rf "$OUTPUT/apps/$app/src" "$OUTPUT/apps/$app/sling.module"
		cp -va "$OUTPUT"/apps/"$app"/* "$OUTPUT"/
	done
	rm -rf "$OUTPUT/apps"
	if [ "$1" == "mono" ]; then
		makeMonoWrapperScripts "$OUTPUT"
	fi
	cp -v "LICENSE" "README.md" "$OUTPUT/"
	VERSION="$(mono "$OUTPUT"/artsy.exe -v)"
	OUTPUTID="sympathy-web-services-${VERSION}_$1"
	rm -rf "$OUTPUTDIR"/"$OUTPUTID" "$OUTPUTDIR"/"${OUTPUTID}".zip
	mv -v "$OUTPUT" "$OUTPUTDIR"/"$OUTPUTID"
	(cd "$OUTPUTDIR" ; zip -r "${OUTPUTID}.zip" "$OUTPUTID")
}

function makeMonoWrapperScripts()
{
	local IDNAME
	local SCRIPT
	for exe in $(cd "$1" ; echo *.exe)
	do
		IDNAME="$(echo "$exe" | sed -e 's/\.exe$//g')"
		SCRIPT="$1/$IDNAME"
		cat > "$SCRIPT" <<EOF
#! /bin/bash
if [ "\$MONO_PATH" = "" ]; then
	MONO_PATH="mono"
fi
DIR="\$(cd "\$(dirname "\$(readlink "\${BASH_SOURCE[0]}" || echo "\${BASH_SOURCE[0]}")")" && pwd)"
exec "\$MONO_PATH" "\$DIR/$exe" "\$@"
EOF
		chmod +x "$SCRIPT"
	done
}

compileForTarget "mono"
compileForTarget "dotnet"
