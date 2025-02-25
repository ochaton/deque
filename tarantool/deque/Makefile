.PHONY := all test

build:
	tt build

pack:
	tt -V pack deb --postinst ./postinst-deb.sh --name deque --app-list deque

clean:
	tt rocks purge

test-deps:
	tt rocks test --prepare

luacheck: test-deps
	.rocks/bin/luacheck .

luatest: test-deps
	.rocks/bin/luatest -c -v --coverage

coverage: test-deps
	.rocks/bin/luacov-console $$(pwd) && .rocks/bin/luacov-console -s

test: luacheck luatest coverage

start:
	tt start

status:
	tt status

log:
	tt log
