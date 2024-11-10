#!/bin/sh

CFG=/etc/tarantool/deque;
DEB=/usr/share/tarantool/deque/deque;

# Install configuration directories:
install -d -m 0755 -o tarantool -g tarantool "$CFG";

# Move out configuration from the package into /etc/
[ -f "$CFG/config.yml" ] || cp -v "$DEB/config.yml" "$CFG/";
rm -v "$DEB/config.yml" && ln -s "$CFG/config.yml" "$DEB/config.yml";

[ -f "$CFG/instances.yml" ] || cp -v "$DEB/instances.yml" "$CFG/";
rm -v "$DEB/instances.yml" && ln -s "$CFG/instances.yml" "$DEB/instances.yml";

[ -f "$CFG/tt.yaml" ] || cat <<EOF > "$CFG/tt.yaml"
---
env:
  bin_dir: /usr/share/tarantool/deque/bin
  inc_dir: /usr/share/tarantool/deque/include
  instances_enabled: /usr/share/tarantool/deque/instances.enabled
  restart_on_failure: false
  tarantoolctl_layout: false
modules:
  directory: modules
app:
  run_dir: /var/run/tarantool
  log_dir: /var/log/tarantool
  wal_dir: /var/lib/tarantool
  memtx_dir: /var/lib/tarantool
  vinyl_dir: /var/lib/tarantool
ee:
  credential_path: ""
templates:
- path: templates
repo:
  rocks: ""
  distfiles: distfiles
EOF


PKG=/usr/share/tarantool/deque;

[ -f "$PKG/tt.yaml" ] && rm -v "$PKG/tt.yaml"; ln -s "$CFG/tt.yaml" "$PKG/tt.yaml";

