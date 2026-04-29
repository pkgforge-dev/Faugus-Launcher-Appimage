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
  
# Additional changes can be done in between here

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
quick-sharun --test ./dist/*.AppImage
