local t = require('luatest') -- [[@as luatest]]
local server = require('luatest.server') --[[@as luatest.server]]
local test_config = require('test.config')
local fio         = require('fio')

local helper = {}

helper.server = server:new({
    datadir = test_config.datadir, -- where to store binary files
    workdir = test_config.root,    -- where to search application
    alias = 'deque_001',
    config_file = fio.pathjoin(test_config.root, 'test', 'test.yml'),
    -- By default net_box connects via (guest:'')
    net_box_credentials = {
        user = test_config.user,
        password = test_config.password,
    },
})

t.before_suite(function()
    helper.server:start({ wait_until_ready = true })
end)

t.after_suite(function()
    helper.server:drop()
end)

return helper
