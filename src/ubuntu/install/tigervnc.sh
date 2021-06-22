#!/usr/bin/env bash
set -e

echo "Install TigerVNC server"
wget -qO- https://sourceforge.net/projects/tigervnc/files/stable/1.8.0/tigervnc-1.8.0.x86_64.tar.gz | tar xz --strip 1 -C /
#wget -qO- https://dl.bintray.com/tigervnc/stable/tigervnc-1.8.0.x86_64.tar.gz | tar xz --strip 1 -C /
