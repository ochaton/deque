local api = require('storage.api')

local t = require('luatest')
local g = t.group('unit_api_test')

local validation_pg = t.group(
    'validation',
    {
        { data = { id = 123, time = 1, payload = {} } },
        { data = { id = '1', time = '1', payload = {} } },
        { data = { id = '1', time = 1, payload = 123 } },
        { data = { id = '1', time = 1, payload = '123' } },
        { data = { id = '1', time = 1, payload = true } },
    }
)
validation_pg.test_validation_push = function(cg)
    local result = api.push(cg.params.data)
    t.assert_eval_to_false(
        result[tostring(cg.params.data.id)].ok
    )
end
