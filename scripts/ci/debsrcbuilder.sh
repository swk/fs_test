#!/bin/bash

src_repo="$(pwd)"

if [ ! -d .git ]; then
    echo "error: must be run from within the top level of a FreeSWITCH git tree." 1>&2
    exit 1;
fi

if [ -z "$1" ]; then
    echo "usage: ./scripts/ci/debbuilder.sh MAJOR.MINOR.MICRO[.REVISION] BUILD_NUMBER" 1>&2
    exit 1;
fi

ver="$1"
major=$(echo "$ver" | cut -d. -f1)
minor=$(echo "$ver" | cut -d. -f2)
micro=$(echo "$ver" | cut -d. -f3)
rev=$(echo "$ver" | cut -d. -f4)

build="$2"

dst_version="$major.$minor.$micro"
dst_name="freeswitch-$dst_version"
dst_parent="/tmp/"
dst_dir="/tmp/$dst_name"


mkdir -p $src_repo/debbuild/

tar xvjf src_dist/$dst_name.tar.bz2 -C $src_repo/debbuild/
cp src_dist/$dst_name.tar.bz2 $src_repo/debbuild/freeswitch_${dst_version}.orig.tar.bz2

# Build the debian source package first, from the source tar file.
cd $src_repo/debbuild/$dst_name

dch -v $dst_version-$build "Nightly Build"

dpkg-buildpackage -rfakeroot -S -us -uc

status=$?

if [ $status -gt 0 ]; then
    exit $status
else
cat 1>&2 <<EOF
----------------------------------------------------------------------
The v$ver-$build DEB-SRCs have been rolled, now we 
just need to push them to the YUM Repo
----------------------------------------------------------------------
EOF
    
fi
