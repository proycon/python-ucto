#!/bin/sh

# Builds dependencies (latest stable releases) from source
# Used for building wheels

set -e

. /etc/os-release

get_latest_version() {
    #Finds the latest git tag or falls back to returning the git default branch (usually master or main)
    #Assumes some kind of semantic versioning (possibly with a v prefix)
    TAG=$(git tag -l | grep -E "^v?[0-9]+(\.[0-9])*" | sort -t. -k 1.2,1n -k 2,2n -k 3,3n -k 4,4n | tail -n 1)
    if [ -z "$TAG" ]; then
        echo "No releases found, falling back to default git branch!">&2
        #output the git default branch for the repository in the current working dir (usually master or main)
        git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'
    else
        echo "$TAG"
    fi
}

if [ "$ID" = "almalinux" ] || [ "$ID" = "centos" ] || [ "$ID" = "rhel" ]; then
    if [ -d /usr/local/share/aclocal ]; then
        #needed for manylinux_2_28 container which ships custom autoconf, possibly others too?
        export ACLOCAL_PATH=/usr/share/aclocal
    fi
    if [ "$VERSION_ID" = "7" ]; then
        yum install -y libexttextcat-devel
    elif [ "$VERSION_ID" = "8" ]; then
        #they forgot to package libexttextcat-devel? grab one manually:
        wget https://github.com/proycon/LaMachine/raw/master/deps/centos8/libexttextcat-devel-3.4.5-2.el8.x86_64.rpm
        yum install -y libexttextcat-devel-3.4.5-2.el8.x86_64.rpm
    fi
fi

[ -z "$PREFIX" ] && PREFIX="/usr/local/"
PREVPWD="$(pwd)"
BUILDDIR="$(mktemp -dt "build-deps.XXXXXX")"
cd "$BUILDDIR"
for PACKAGE in LanguageMachines/ticcutils LanguageMachines/libfolia LanguageMachines/uctodata LanguageMachines/ucto; do
    echo "Git cloning $PACKAGE ">&2
    git clone https://github.com/$PACKAGE
    PACKAGE="$(basename $PACKAGE)"
    cd "$PACKAGE"
    if [ "$1" != "--devel" ]; then
        VERSION="$(get_latest_version)"
        if [ "$VERSION" != "master" ] && [ "$VERSION" != "main" ] && [ "$VERSION" != "devel" ]; then
            echo "Checking out latest stable version: $VERSION">&2
            git -c advice.detachedHead=false checkout "$VERSION"
        fi
    fi
    echo "Bootstrapping $PACKAGE ">&2
    if [ ! -f configure ] && [ -f configure.ac ]; then
        #shellcheck disable=SC2086
        autoreconf --install --verbose
    fi
    echo "Configuring $PACKAGE" >&2
    ./configure --prefix="$PREFIX" >&2
    echo "Make $PACKAGE" >&2
    make
    echo "Make install $PACKAGE" >&2
    make install
    cd ..
done
cd "$PREVPWD"
[ -n "$BUILDDIR" ] && rm -Rf "$BUILDDIR"
echo "Dependencies installed" >&2
