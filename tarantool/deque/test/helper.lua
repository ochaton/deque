local fio = require('fio')
local t = require('luatest')

local helper = {}

helper.root = fio.dirname(fio.abspath(package.search('storage')))
helper.datadir = fio.pathjoin(helper.root, 'tmp')
helper.server_command = fio.pathjoin(helper.root, 'init.lua')


-- t.before_suite(function()
--     fio.rmtree(helper.datadir)
--     fio.mktree(helper.datadir)
-- end)

-- t.after_suite(function()
--     fio.rmtree(helper.datadir)
-- end)

return helper