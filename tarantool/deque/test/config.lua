local fio = require 'fio'
local root = fio.dirname(fio.dirname(fio.abspath(debug.getinfo(1, "S").source:sub(2))))

return {
	root = root,
	datadir = fio.tempdir(),
	user = 'test',
	password = 'test',
}