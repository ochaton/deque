local helper = require('test.helper.integration')

local t = require('luatest') --[[@as luatest]]
local g = t.group('integration_api_test')

g.test_push = function()
    local result = helper.server:call('deque.api.push', {{ id = '1', time = 1, payload = {} }})
    t.assert_type(result, 'table', 'api.push returns object')
    t.assert_equals(result.ok, true, '.ok == true')
end


local pg = t.group(
    'multi_push',
    {
        { data = { id = 123, time = 1, payload = {} } },
        { data = { id = '1', time = '1', payload = {} } },
        { data = { id = '1', time = 1, payload = 123 } },
        { data = { id = '1', time = 1, payload = '123' } },
        { data = { id = '1', time = 1, payload = true } },
    }
)

pg.test_validation_push = function(cg)
    local result = helper.server:call('deque.api.push', {cg.params.data})
    t.assert_equals(result.ok, false)
end
