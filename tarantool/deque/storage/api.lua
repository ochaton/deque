--- publically accessible via deque.api.*
local api = {}

local checks = require 'checks'
local log = require 'log'
local json = require 'json'
local fiber = require 'fiber'

---@param task storage.task
local function push_one(task)
	task.time = task.time or fiber.time()
	box.space.queue:upsert(T.queue.tuple(task), {
		{ '=', 'time', fiber.time() }
	})
end

local function validate_task(_)
	checks({
		id = 'string',
		time = '?number',
		payload = 'table',
	})
end

---@class storage.task
---@field id uuid
---@field time number? (can be nil then defaulted)
---@field payload any (just random payload which saved as is)

---@param task storage.task
---@return {ok: boolean, error: string?} result
function api.push(task)
	local ok, err = pcall(validate_task, task)
	if not ok then
		return { ok = ok, error = err }
	end

	ok, err = pcall(push_one, task)
	return { ok = ok, error = err }
end

---@param tasks storage.task[]
---@return table<string, {ok: boolean, error: string?}> results
function api.push_many(tasks)
	local results = {}

	for _, task in ipairs(tasks) do
		local ok, err
		ok, err = pcall(validate_task, task)
		if not ok then
			results[tostring(task.id)] = { ok = ok, error = err }
			log.warn("Failed to push task %s: %s", json.encode(task), err)
			goto continue
		end

		ok, err = pcall(push_one, task)
		results[tostring(task.id)] = { ok = ok, error = err }
		::continue::
	end

	return results
end

---@param opts { wait_timeout: number?, delay: number }
---@return storage.task?
function api.pop(opts)
	-- checks validates given `opts`
	checks({ wait_timeout = '?number', delay = 'number' })
	if opts.delay < 0 then
		error('bad argument opts.delay to api.pop (positive expected, got negative)')
	end

	local now = fiber.time()

	local task = box.space.queue.index.time:pairs({ 0 }, { iterator = "GE" }):nth(1)
	if task and task.time < now then
		return box.space.queue:update({ task.id }, { { '=', 'time', now + opts.delay } })
			:tomap({ names_only = true })
	end

	local timeout = tonumber(opts.wait_timeout) or 0
	if task and task.time < now + timeout then
		-- task can be awaited in a given timeout
		fiber.sleep(timeout)

		-- a way to check whether client still awaits us
		if not pcall(box.session.peer) then
			-- no client => no task
			return
		end

		if timeout ~= 0 then
			-- resolve infinite tail-calls
			return api.pop({ delay = opts.delay, wait_timeout = 0 })
		end
	end

	return --(void)
end

local function pop_n(args)
	local limit = args.limit
	local now = args.now
	local delay = args.delay

	local result = table.new(limit, 0)

	for _, task in box.space.queue.index.time:pairs({ 0 }, { iterator = "GE" }) do
		if task.time > now then break end
		if limit == 0 then break end

		task = box.space.queue:update({ task.id }, {
			{ '=', 'time', now + delay }
		}):tomap({ names_only = true })

		limit = limit - 1
		table.insert(result, task)
	end

	return result
end

---@param opts { delay: number, limit: number }
---@return storage.task[]
function api.pop_many(opts)
	checks({ delay = 'number', limit = '?number' })
	if opts.delay < 0 then
		error('bad argument opts.delay to api.pop (positive expected, got negative)')
	end

	opts.limit = opts.limit or 100
	if opts.limit <= 0 then
		error('bad argument opts.limit to api.pop (positive expected, got non-positive)')
	end

	local limit = opts.limit

	return box.atomic(pop_n, {
		limit = limit,
		now = fiber.time(),
		delay = opts.delay,
	})
end

return api
