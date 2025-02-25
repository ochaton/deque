local helper = require('test.helper.integration')


local t = require('luatest')
local g = t.group('integration_api_test')


g.test_push = function()
    helper.server:exec(function()
        t.assert_equals(
            deque.api.push({ id = '1', time = 1, payload = {} }),
            { ['1'] = { ok = true } }
        )
    end)
end
