#!/bin/bash

# Check if build-essential is installed as a proxy for development libraries
if ! dpkg -l | grep -q "^ii  build-essential "; then
    sudo apt install -y \
      build-essential pkg-config autoconf bison clang rustc pipx \
      libssl-dev libreadline-dev zlib1g-dev libyaml-dev libreadline-dev libncurses5-dev libffi-dev libgdbm-dev libjemalloc2 \
      libvips imagemagick libmagickwand-dev mupdf mupdf-tools \
      redis-tools sqlite3 libsqlite3-0 libmysqlclient-dev libpq-dev postgresql-client postgresql-client-common
else
    echo "✓ Development libraries already installed"
fi
