local log = require 'log'
local spacer = require 'storage.schema'

box.watch('box.status', function(_, event)
	assert(type(event) == 'table')
	if event.is_ro or event.status ~= 'running' then
		log.warn("Node is readlonly")
		return
	end

	-- Following code matters only when node is RW:
	if spacer:version() == nil then
		log.warn("Performing initial migrations...")
		spacer:migrate_up()
	end
end)

local M = {}
rawset(_G, 'deque', M) -- publish and export

M.api = require 'storage.api'
