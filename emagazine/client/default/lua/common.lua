local log = require "framework.log"
local apps = require "framework.apps"
local services = require "framework.services"
local ui = require "framework.ui"
local base = require "framework.base"
module( ..., package.seeall ) 


function checkNetwork()
	-- if not phone.isWLAN() then
	-- 	local state = base.getGSandbox():get("_getNetworkState")
	-- 	if state == nil or state == NO_NETWORK or state == WLAN then
	-- 		if ui.confirm("提示", "未找到 WIFI，是否使用 2G/3G 网络?", "是", "否", ui.CONFIRM_CANCEL) == ui.CONFIRM_CANCEL then
	-- 			base.getGSandbox():put_value("_getNetworkState", NO_NETWORK)
	-- 			return false
	-- 		else
	-- 			base.getGSandbox():put_value("_getNetworkState", USE2G3G)
	-- 			return true
	-- 		end
	-- 	else
	-- 		return true
	-- 	end
	-- else
	-- 	base.getGSandbox():put_value("_getNetworkState", WLAN)
	-- 	return true
	-- end
	return true
end

function hasNetworkWithPrompt(msg)
    return checkNetwork()
end
function getImgWidthHeight(imgPath)
    local imageservice = registry.getService("image")
    local fileAbsoultePath = base.resolveFile(imgPath)
    local img = imageservice:load(fileAbsoultePath)
    local imgWidth,imgHeight = img:getSize()
    return imgWidth,imgHeight
end