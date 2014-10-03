local http = require('socket.http')

local MIN_BLOCK_SIZE = 128 * 1024
local MAX_BLOCK_SIZE = 1024 * 1024
local TASK_NUM = 5
local DEFAULT_SAVEDIR = 'd:\\';

local
function computeBlock(length)
	if length <= 0 then
		return 0
	end
	
	local initSize = MIN_BLOCK_SIZE	
	while true do 
		local blockNum = math.ceil(length / initSize)
		if blockNum < TASK_NUM then
			return blockNum, initSize
		end
		
		initSize = initSize * 2;
	end
	
	return 0
end

local
function random_file(ft, io_err)
	if ft.handle then
        return function(chunk, err)
			local handle = ft.handle
			
            if not chunk then
                handle:close()
                return 1
            else 
				--print('get ', #chunk)
				handle:seek('set', ft.offset)
				ft.offset = ft.offset + #chunk
				return handle:write(chunk)
			end
        end
    else
		return sink.error(io_err or "unable to open file") 
	end
end

local
function request(url, headers, savePath, offset)
	print('request', offset)
	local ft = {}
	local handle = io.open(savePath, 'wb+')
	assert(handle, 'target file can not be opened for write.')
	ft.handle = handle
	ft.offset = offset or 0
	
	local r, c, h = http.request{
		url = url,
		method = 'GET',
		headers = headers,
		sink = random_file(ft)
	}
	
	if r ~= -1 then
		print('http request error. err = ' .. status)
	end
	print('status = ', status)
end

local threads = {}

local
function download(url, savePath)
	local r, c, h = http.request {
		method = 'HEAD',
		url = url,
		redirect = true,
	}

	print(r, c, h)
	--for i, v in pairs(h) do
	--	print(i, v)
	--end

	local contentLength = tonumber(h['content-length'])
	--[[
	local num, size = computeBlock(contentLength)
	if num == 0 then
		print('Content-Length not get!')
		return
	end
	]]
	num = 1
	size = contentLength

	print(num, size)
	for i = 1, num do
		local co = coroutine.create(function()
			local offset = (num - 1) * size
			local headers = {
				Range = offset .. '-' .. math.min(offset + size, contentLength) - 1
			}
	
			request(url, headers, savePath, offset)
		end)
		table.insert(threads, co)
	end
end

-- E151F93C6A993010B77546743108F80B
local url = 'http://dlsw.baidu.com/sw-search-sp/soft/7b/26860/ThunderSpeed1.0.15.168.1411009942.exe'
--local url = 'http://114.116.146.246/test.txt'
--local url = 'http://114.116.146.246/VA_X.dll'
download(url, DEFAULT_SAVEDIR .. 'test.exe')

coroutine.resume(threads[1])

