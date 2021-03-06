#!/bin/bash

src_repo="$(pwd)"

if [ ! -d .git ]; then
    echo "error: must be run from within the top level of a FreeSWITCH git tree." 1>&2
    exit 1;
fi

if [ -z "$1" ]; then
    echo "usage: ./scripts/ci/rpmbuilder.sh MAJOR.MINOR.MICRO[.REVISION] BUILD_NUMBER" 1>&2
    exit 1;
fi

ver="$1"
major=$(echo "$ver" | cut -d. -f1)
minor=$(echo "$ver" | cut -d. -f2)
micro=$(echo "$ver" | cut -d. -f3)
rev=$(echo "$ver" | cut -d. -f4)

build="$2"

dst_name="freeswitch-$major.$minor.$micro"
dst_parent="/tmp/"
dst_dir="/tmp/$dst_name"

mkdir -p $src_repo/rpmbuild/{SOURCES,BUILD,BUILDROOT,i386,x86_64,SPECS}

cd $src_repo

rpmbuild --define "VERSION_NUMBER $ver" \
	--define "BUILD_NUMBER $build" \
	--define "_topdir %(pwd)/rpmbuild" \
	--define "_rpmdir %{_topdir}" \
	--define "_srcrpmdir %{_topdir}" \
	-ba freeswitch.spec 

# --define '_rpmfilename %%{NAME}-%%{VERSION}-%%{RELEASE}.%%{ARCH}.rpm' \
# --define "_sourcedir  %{_topdir}" \
# --define "_builddir %{_topdir}" \


mkdir $src_repo/RPMS 
mv $src_repo/rpmbuild/*/*.rpm $src_repo/RPMS/.

cat 1>&2 <<EOF
----------------------------------------------------------------------
The v$ver-$build RPMs have been rolled, now we 
just need to push them to the YUM Repo
----------------------------------------------------------------------
EOF

