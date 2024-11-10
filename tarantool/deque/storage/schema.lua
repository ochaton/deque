box.spacer = require('spacer').new({
	migrations = './storage/migrations',
})

-- This file exists for informational matters
-- If you want to modify or add spaces you need in
-- dev-environment modify contents here and run box.spacer:makemigration(<name-of-your-migration>)
-- After that, in prod-environment you need to restart Tarantool and type box.spacer:migrate_up()

box.spacer:space({
	name = 'queue',
	format = {
		{ name = 'id',      type = 'string' },
		{ name = 'time',    type = 'number' }, -- support fractional
		{ name = 'payload', type = 'any'    }, -- any non-nullable payload
	},
	indexes = {
		{ name = 'primary', parts = {'id'} },
		{ name = 'time',    parts = {'time', 'id'} },
	},
})

box.spacer:space({
	name = 'cache',
	format = {
		{ name = 'id',      type = 'string' }, -- same as queue.id
		{ name = 'expires', type = 'number' }, -- timestamp (unix seconds) when must be removed
		{ name = 'payload', type = 'any'    }, -- payload
	},

	indexes = {
		{ name = 'primary', parts = {'id'} },
		{ name = 'expires', parts = {'expires'}, unique = false },
	},
})

return box.spacer
