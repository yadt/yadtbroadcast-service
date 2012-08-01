#!/bin/bash
set -u -e -E -C -o pipefail

DIST=dist
SPECFILES=(*.spec)
WORK="$(mktemp -d -t "$(basename $0)"-XXXXXXXXXX)"

function exittrap {
    if [[ -n "${KEEPWORKDIR:-}" && -s "$WORK/log.txt" ]]; then
        sed -e 's/^/LOG: /' "$WORK/log.txt"
    fi
    ${KEEPWORKDIR:+echo Do not forget to} rm -Rf "$WORK"
}
trap "exittrap" EXIT

function die {
    echo "ERROR: $@"
    KEEPWORKDIR=1
    exit 1
}


# get package name and version from spec file
PACKAGE_NAME="$( sed -ne '/Name:/{s/.*: \(.*\)/\1/;P}' "$SPECFILES" )"
PACKAGE_VERSION="$( sed -ne '/Version:/{s/.*: \(.*\)/\1/;P}' "$SPECFILES" )"
PACKAGE="$PACKAGE_NAME-$PACKAGE_VERSION"
test "$PACKAGE" = "-" && die "Could not determine correct package name and version from SPEC file (got $PACKAGE)"

cp -R . "$WORK/$PACKAGE" >> "$WORK"/log.txt 2>&1 || die "Could not move '$WORK/export' to '$WORK/$PACKAGE'"

# prepare rpm build environment
mkdir -p "$WORK"/rpmbuild/{SPECS,SOURCES,BUILD,RPMS/noarch,RPMS/x86_64,RPMS/i386,RPMS/i486,RPMS/i586,RPMS/i686,SRPMS}

# pack tgz and build RPMs
tar -cvzf "$WORK/$PACKAGE".tar.gz -C "$WORK" "$PACKAGE" >> "$WORK"/log.txt 2>&1 || die "Could not pack archive"

# pack transport tgz for build agent
mkdir -p dist
tar -zcf dist/$PACKAGE.tar.gz -C "$WORK" rpmbuild $PACKAGE.tar.gz

