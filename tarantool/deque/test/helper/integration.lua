local t = require('luatest')
local server = require('luatest.server')
local shared = require('test.helper')

local helper = { shared = shared }


helper.server = server:new {
    alias = 'test-server',
    workdir = shared.datadir,
}

t.before_suite(function()
    helper.server:start()
end)

t.after_suite(function()
    helper.server:drop()
end)

return helper
