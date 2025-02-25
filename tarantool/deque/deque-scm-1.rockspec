rockspec_format = "3.0"
package = "deque"
version = "scm-1"
source = {
   url = "git+https://github.com/ochaton/deque"
}
description = {
   homepage = "https://github.com/ochaton/deque",
   license = "MIT"
}
dependencies = {
   "spacer ~> 3",
   "expirationd ~> 1.6",
   "package-reload",
}
test_dependencies = {
   "luacheck",
   "luatest",
   "luacov",
   "luacov-coveralls",
   "luacov-console",
}
test = {
   type = 'command',
   command = 'make test',
}
build = {
   type = "builtin",
   modules = {},
}
