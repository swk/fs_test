#!/bin/bash

src_repo="$(pwd)"

if [ ! -d .git ]; then
    echo "error: must be run from within the top level of a FreeSWITCH git tree." 1>&2
    exit 1;
fi

if [ -z "$1" ]; then
    echo "usage: ./scripts/ci/extras/erlangbuilder.sh" 1>&2
    exit 1;
fi

mkdir -p $src_repo/rpmbuild/{SOURCES,BUILD,BUILDROOT,i386,x86_64,SOURCES,SPECS}
cd $src_repo

rpmbuild --define "_topdir %(pwd)/rpmbuild" \
	--define "_rpmdir %{_topdir}" \
	--define "_srcrpmdir %{_topdir}" \
	-ba erlang.spec 

mkdir $src_repo/RPMS 
mv $src_repo/rpmbuild/*/*.rpm $src_repo/RPMS/.
