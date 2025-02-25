local config = require 'config'

-- With hot reload code => reload configuration before that
require 'package.reload':register(function()
	config:reload()
end)

local log = require 'log'
local spacer = require 'storage.schema'
rawset(_G, 'config', config)

local M = {}
local api = require 'storage.api'
rawset(_G, 'deque', M) -- publish and export

box.watch('box.status', function(_, event)
	assert(type(event) == 'table')
	if event.is_ro or event.status ~= 'running' then
		if event.is_ro then
			log.warn("Node is readonly, reason=%s", box.info.ro_reason)
		else
			log.warn("Node is not running, status=%s (ro_reason=%s)",
				box.info.status, box.info.ro_reason)
		end

		if M.api ~= nil then
			log.warn("Unpublishing api, since node became ro")
			M.api = nil
		end
		return
	end

	-- became running and not ro, publish api
	if M.api == nil then
		M.api = api
		log.warn("deque.api has been published (node is rw and running)")
	end

	-- Following code matters only when node is RW:
	if spacer:version() == nil then
		log.warn("Performing initial migrations...")
		spacer:migrate_up()
	end
end)

function M.status()
	return {
		instance_name = box.info.name,
		tarantool = box.info.version,
		spacer = spacer:version(),
		is_ro = box.info.ro,
		time = os.time(),
		config = config:info(),
	}
end

