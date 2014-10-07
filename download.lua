local arg = {...}
dofile('./socket.lua')
dofile('./http.lua')
local http = require('socket.http')

local MIN_BLOCK_SIZE = 128 * 1024
local MAX_BLOCK_SIZE = 2 * 1024 * 1024
local TASK_NUM = 5
local DEFAULT_SAVEDIR = 'd:\\';

socket.BLOCKSIZE = 4096

local
function compute_block(length)
	if length <= 0 then
		return 0
	end
	
	local initSize = MIN_BLOCK_SIZE
	local blockNum = 0
	while true do 
		blockNum = math.ceil(length / initSize)
		if blockNum <= TASK_NUM then
			return blockNum, initSize
		end
		
		local doubleSize = initSize * 2;
		if doubleSize <= MAX_BLOCK_SIZE then
			initSize = doubleSize
		else
			break
		end
	end
	
	return blockNum, initSize
end

local
function request(url, headers, fd, offset)
	local ft = {}
	ft.handle = fd
	ft.offset = offset or 0
	
	local function random_file(ft, io_err)
		if ft.handle then
			return function(chunk, err)
				local handle = ft.handle
				
				if not chunk then
					--handle:close()
					print('file closed. ', ft.offset - offset)
					return 1
				else 
					handle:seek('set', ft.offset)
					ft.offset = ft.offset + #chunk
					return handle:write(chunk)
				end
			end
		else
			return sink.error(io_err or "unable to open file") 
		end
	end

	local function asyn_http_step(src, snk)
		local function deal(chunk, src_err)
			local ret, snk_err = snk(chunk, src_err)
			if chunk and ret then return 1
			else return nil, src_err or snk_err end
		end
		
		local chunk, src_err, partial = src()
		chunk = chunk or partial
		
		if src_err then
			if chunk then
				deal(chunk, src_err)
			end
			
			if src_err == 'timeout' then
				coroutine.yield(false)
				return 1
			elseif src_err == 'closed' then
				return nil, src_err
			end
		else
			return deal(chunk, src_err)
		end
	end
	
	local r, c, h = http.request{
		url = url,
		method = 'GET',
		headers = headers,
		sink = random_file(ft),
		step = asyn_http_step,
	}
	
	print(r, c, h)
	for i, v in pairs(h) do
		print(i, v)
	end
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
	if tonumber(c) ~= 200 then
		print('status is not 200')
		return
	end

	---[[
	local contentLength = tonumber(h['content-length'])
	local num, size = compute_block(contentLength)
	if num == 0 then
		print('Content-Length not get!')
		return
	end
	print(num, size)
	
	local index = 1
	local threadNum = math.min(num, TASK_NUM)
	local handle = io.open(savePath, 'wb+')
	assert(handle, 'target file can not be opened for write.')
	
	for idx = 1, threadNum do
		local co
		co = coroutine.create(function()
			while index <= num do
				print('index = ', index, co)
				local offset = (index - 1) * size
				local headers = {
					Range = 'Bytes=' .. offset .. '-' .. math.min(offset + size, contentLength) - 1
				}

				index = index + 1
				request(url, headers, handle, offset)
			end
			return 'succ'
		end)
		table.insert(threads, co)
	end
end

-- E151F93C6A993010B77546743108F80B
--local url = 'http://dlsw.baidu.com/sw-search-sp/soft/7b/26860/ThunderSpeed1.0.15.168.1411009942.exe'
--local url = 'http://114.116.146.246/test.txt'
--local url = 'http://localhost/VA_X.dll'	-- 69F5CC837061ECC535C5D0549673E26C
--download(url, DEFAULT_SAVEDIR .. 'test.exe')

print('download from: ', arg[1])
print('save to: ', arg[2])
download(arg[1], arg[2])

local t = os.time()
while true do
	if #threads == 0 then
		break
	end
	
	for i, co in ipairs(threads) do
		local ret, err = coroutine.resume(co)
		if ret then
			if err == 'succ' then
				table.remove(threads, i)
				break
			end
		else 
			print('err = ', err)
			table.remove(threads, i)
			break
		end
	end
end
print('cost ', os.time() - t, 's')
