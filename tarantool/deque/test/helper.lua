local fio = require('fio')
local t = require('luatest')

local helper = require 'test.config'

t.before_suite(function()
    fio.rmtree(helper.datadir)
    fio.mktree(helper.datadir)
end)

t.after_suite(function()
    fio.rmtree(helper.datadir)
end)

return helper