--[[
about
	 api helper
interface
	getAtGlanceFromMKC( contactId )
	
	   
by @liang
]]
module( ..., package.seeall ) 
local token = require "framework.token"
local api = require "resource.api"
local log = require "framework.log"
local utils = require "framework.utils"
local json = require "json"
local common = require "common"

local NO_INT_ERROR = {ErrorCode=0, Message="没有可用的网络！"}
local UNKNOWN_ERROR = {ErrorCode=0, Message="遇到末知错误！"}
local  myApiTable = {}

myApiTable["dev"]  ="http://dev.api.marykayintouch.com.cn:8080/bookshelf/v1"
myApiTable["qa"]   ="http://qa.api.marykayintouch.com.cn:8081/bookshelf/v1"
myApiTable["stg"]  ="http://dev.api.marykayintouch.com.cn:8080/bookshelf/v1"
myApiTable["prod"] ="https://api.marykayintouch.com.cn/bookshelf/v1"
myApiTable["us"]   ="https://api.marykayintouch.com.cn/bookshelf/v1"


myApiTable["core_dev"] = "http://dev.api.marykayintouch.com.cn:8080/MobileCore/v1"
myApiTable["core_qa"] =  "http://qa.api.marykayintouch.com.cn:8081/MobileCore/v1"
myApiTable["core_stg"] = "http://dev.api.marykayintouch.com.cn:8080/MobileCore/v1"
myApiTable["core_prod"] ="https://api.marykayintouch.com.cn/MobileCore/v1"
myApiTable["core_us"]   ="https://api.marykayintouch.com.cn/MobileCore/v1"



-- api.setAPITable(myApiTable) 

function get(service, operation, param)
	api.setAPITable(myApiTable) 
	return api.get(service, operation, param)
	-- body
end

function post( service, operation, param )
	api.setAPITable(myApiTable) 
	return api.post(service, operation, param)
end


function put( service, operation, param )
	api.setAPITable(myApiTable) 
	return api.put(service, operation, param)
end

function delete( service, operation, param )
	api.setAPITable(myApiTable) 
	return api.delete(service, operation, param)
end


function checkResult(ret, responseStatus, responseText)
	-- no available internet access
	if (responseStatus == 0) then
		return nil, NO_INT_ERROR
	end

	if not ret then
		log.error("checkResult ==> status code : " .. utils.objecttostring(responseStatus))
		log.error("checkResult ==> response text : " .. utils.objecttostring(responseText))
		pcall(function() ret = json.decode(responseText) end)
	end

	if ret and type(ret) == "table" then
		local errorMsg = ret["ResponseStatus"] 
		if errorMsg then
			log.error('checkResult ==> error msg: \r\n\t' .. json.encode(errorMsg))
			return nil, errorMsg
		end
	else
		return nil, UNKNOWN_ERROR
	end
	return ret
end

function EBookGet( MinCreateTime ,MinShareInfoCreateTime, whichBook , DeviceType)
	log.debug("[Reource API] begin EBookGet ")
	local path = whichBook
	local param = {}
	param.MinCreateTime = MinCreateTime
	param.MinShareInfoCreateTime = MinShareInfoCreateTime
	if DeviceType then
		param.DeviceType = DeviceType
	end
	local ret, responseStatus, responseText =  get("BookShelf", path, param)
	log.debug("ret=" .. utils.objecttostring(ret) .. " , responseStatus=" .. utils.objecttostring(responseStatus) .. " , responseText=" .. utils.objecttostring(responseText) )
	local result, errorMsg= checkResult(ret, responseStatus, responseText)
	return result
end



