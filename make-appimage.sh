#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(pacman -Q faugus-launcher | awk '{print $2; exit}') # example command to get version of application here
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=/usr/share/icons/hicolor/scalable/apps/faugus-launcher.svg
export DESKTOP=/usr/share/applications/faugus-launcher.desktop
export DEPLOY_PYTHON=1

# Deploy dependencies
quick-sharun \
	/usr/bin/faugus*           \
	/usr/share/faugus-launcher \
	/usr/lib/libgtk-3.so*
echo 'unset VK_DRIVER_FILES' >> ./AppDir/.env

# This is needed since the application downloads binaries that link to glibc
# on the host regardlesss of the host glibc being compatible or even present at all
#
# This way the execve call will use our bundled sharun -> dynamic linker -> glibc
#
cc -shared -fPIC -O2 -o ./AppDir/lib/execve-sharun-hack.so execve-sharun-hack.c -ldl
echo 'execve-sharun-hack.so' >> ./AppDir/.preload

# We need to include $HOME/.local/share/Steam as faugus-launcher hardcodes that location
echo 'export ANYLINUX_EXECVE_WRAP_PATHS="$DATADIR/Steam:$HOME/.local/share/Steam"' >> ./AppDir/bin/execve-wrap-path.hook

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
quick-sharun --test ./dist/*.AppImage
