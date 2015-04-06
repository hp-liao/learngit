
local apiHelper = require "apiHelper"

module( ..., package.seeall ) 

function EBookGet( MinCreateTime ,MinShareInfoCreateTime, whichBook, DeviceType )
	return apiHelper.EBookGet(MinCreateTime,MinShareInfoCreateTime,whichBook, DeviceType)
end
