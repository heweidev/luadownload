--local socket = require('socket')
print(package.path)
print(package.cpath)

local socket = _G['except'] or require('socket')
print(socket)


local function finalize()
	print('error')
end

socket.try = socket.newtry(finalize)

local function test_impl(a, b, c)
	print(a, b, c)
	print(socket.try(nil, 'Hello'))
	print('ret')
end

local test = socket.protect(test_impl)
local ret, err = test(nil, 3, 3)
print(ret, err)
print('---------------')
test_impl(nil, 3, 3)

print('test ok!')