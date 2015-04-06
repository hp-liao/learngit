local log = require "framework.log"
local base = require "framework.base"
local ui = require "framework.ui"
local apps = require "framework.apps"
local utils = require "framework.utils"
local magazine = require "magazine"
-- local bookshelfCommon = require "common"
local track = require "framework.track"
local http = require "framework.http"
local json = require "json"
local share = require "ebookshare"
local common = require "common"
local deviceInfo = base.getDeviceInfo()
local deviceservice = registry.getService("device")
local _G = _G
local _root = nil
local LOG_TAG = "test_tag:"
local share_ui_is_show = false

function onCreated(object)

end

function readFile(path)
	local file =io.open(path,"rb")
	local data = file:read("*all")
	file:close()
	return data
end
--[[
	local share_params = {
		title = "测试，请无视",
		content = "测试的内容，请无视, blalalalalalalalalalalalalalalalalalal",
		url = "https://www.marykayintouch.com.cn",
		image = "http://mkimobile.marykay.com.cn/productimages/008145.png"
	}
]]
local shareDic =nil
function getShareInfoByPageNumber()
	local magazineId = base.getGSandbox():get("$currentEBookID")
	local tableName = base.getGSandbox():get("$currentEBookSupply")
	local pageNumber = _G["ebookView"]:currentPageNumber()
	if not shareDic then
		shareDic = loadShareInfo(tableName, magazineId)
	end

	if shareDic then
		log.debug("getShareInfoByPageNumber: shareDic" .. utils.objecttostring(shareDic) )
		log.debug("pageNummber is:" .. pageNumber)
		
		for i,v in ipairs(shareDic) do
			if tonumber(v.page) == pageNumber then
				return v
			end
		end

		return nil
	else
		log.debug("getShareInfoByPageNumber: shareDic is nil ")
		return nil
	end
end
function downloadImageByUrl(imageUrl, path)
	log.debug(LOG_TAG.."imageUrl:"..imageUrl)
	log.debug(LOG_TAG.."path:"..path)
	-- local httpRet = http.downloadToAbsolutePath(string.trim(imageUrl), absolutePath)
	local httpRet = http.download(string.trim(imageUrl), path)
	log.debug(LOG_TAG.."httpRet:" .. utils.objecttostring(httpRet))
	return httpRet
end
function loadShareInfo(tableName, magazineId)
	local shareFile = magazine.getMagazinePath(tableName, magazineId) .. "/shareinfo.txt"

	if not lfs.attributes(shareFile) then
		log.debug("loadShareInfo: can't find file " .. utils.objecttostring(shareFile) )
		return nil
	end
	local shareJsonStr = readFile(shareFile)
	log.debug("loadShareInfo: shareJsonStr: " .. utils.objecttostring(shareJsonStr) )
	if shareJsonStr and string.len(shareJsonStr) > 10 then
		local shareData = json.decode(shareJsonStr )
		log.debug("loadShareInfo: shareDic: " .. utils.objecttostring(shareData) )
		return shareData.shareInfo
	else
		log.debug("read shareinfo.txt failed")
	end
end
function showOrHideBars()
	local topToolBar = _G["topToolBar"]
	log.debug(LOG_TAG.."showOrHideBars")
	isShowShareBtn()
	if tonumber(topToolBar.marginTop) == - 44 then
		showBar()
	elseif  tonumber(topToolBar.marginTop) == 0 then
		hiddenBar()
	end
end
function isShowShareBtn()
	log.debug(LOG_TAG.."isShowShareBtn")
	local shareParams = getShareInfoByPageNumber()
	log.debug(LOG_TAG.."isShowShareBtn :"..utils.objecttostring(shareParams))
	if not shareParams then
		_G["shareBtn"].hidden = true
	else
		_G["shareBtn"].hidden = false
	end
end
function hiddenBar()
	local topToolBar = _G["topToolBar"]
	local bottomToolBar = _G["bottomToolBar"]
	log.debug(LOG_TAG.."hiddenBar")
	if topToolBar == nil or bottomToolBar == nil then
		return
	end
	if _G["shareBackground"] then 
		_G["shareBackground"].hidden = true
	end
	_root:suspendLayout()
	topToolBar.marginTop = -44
	bottomToolBar.marginBottom = -134.5
	_root:resumeLayout(0.3)
	sleep(0.5)
	addRedRectWhenJump()
	bottomToolBar.hidden = true
end
function showBar()
	local topToolBar = _G["topToolBar"]
	local bottomToolBar = _G["bottomToolBar"]
	bottomToolBar.hidden = false
	log.debug(LOG_TAG.."showBar")
	addRedRectWhenJump()
	_root:suspendLayout()
	topToolBar.marginTop = 0
	bottomToolBar.marginBottom = 0
	_root:resumeLayout(0.3)
end

function onFronted()
	_root = _G["ebookRoot"]
	local ebookView = _G["ebookView"]
	local magazineId = base.getGSandbox():get("$currentEBookID")
	local tableName = base.getGSandbox():get("$currentEBookSupply")
	local bookPath = base.getGSandbox():getAppSandbox("emagazine"):getDataPath() .. "/magazines/" .. tableName .. "/" .. magazineId .. "mag"
	log.debug("book path:" .. bookPath)
	ebookView:loadBook(bookPath)
	topToolBarUI()
	bottomToolBarUI()
	ebookView.onTurnPage = function (pgNumber)
		isShowShareBtn()
		hiddenBar()
	end
	 if deviceInfo["os.name"] ~= "IOS" then
    	log.debug(LOG_TAG.."android ontouch")
		ebookView.onPageTouched = showOrHideBars
	else
		_root.onTouch = showOrHideBars
    end
end

function topToolBarUI()
	local topToolBar = _G["topToolBar"]
	if topToolBar == nil then

		log.debug("create toolbar")
		local topToolBar = ui.view{id = "topToolBar", backgroundColor="#000000", backgroundAlpha=0.8, width = "100%", height = 44,marginTop=-44}

		local imageWidth,imageHeight = common.getImgWidthHeight("icon2.png")
		topToolBar:addChild(ui.image{src="icon2.png",marginLeft=12,  marginTop = (44 - imageHeight)/2 , width = imageWidth,height = imageHeight,scale = "fill"})
		local gobackBtn = ui.button{ margin = "auto auto auto 10", width = 70, label = "返回", height = 44,color="#FFFFFF",fontSize=18, bold=true}
		gobackBtn.onclick = function ()
			log.debug("clicked go back btn")
			if deviceservice then
				deviceservice.statusBarHidden = false
			end
			apps.popPage()
		end
		topToolBar:addChild(gobackBtn)

		local shareBtn = ui.button{id = "shareBtn", margin = "auto 0 auto auto", width = 60, label = "分享至", height = 44,color="#FFFFFF",fontSize=14, bold=true}
		topToolBar:addChild(shareBtn)
		shareBtn.onclick = function()
			local shareBackground = _G["shareBackground"]
		    if shareBackground ~= nil then
		       log.debug(LOG_TAG.."shareBackground hidden:".. utils.objecttostring(shareBackground.hidden))
		       if shareBackground.hidden == false then
		       	shareBackground.hidden = true
		       	return
		       end
		    end
			local shareParams = getShareInfoByPageNumber()
			log.debug(utils.objecttostring(shareParams))
			if shareParams then
				share_ui_is_show = true
				local tempString = string.reverse(shareParams.image)
				local startOption = string.len(shareParams.image) - string.find(tempString,"/") + 2
				local imageName = string.sub(shareParams.image,startOption)
				log.debug("imageName:"..imageName)
				local magazineId = base.getGSandbox():get("$currentEBookID")
				local tableName = base.getGSandbox():get("$currentEBookSupply")
				local date = base.getGSandbox():get("$currentEBookTitle")
				
				local relativePath = magazine.getMagazineRelativePath(tableName, magazineId) .. "/Resources/" .. imageName
				local absoluteIamgePath = magazine.getMagazinePath(tableName, magazineId) .. "/Resources/" .. imageName
				log.debug("absoluteIamgePath" .. absoluteIamgePath)
				if not lfs.attributes(absoluteIamgePath) then
					ui.startBusy(nil,"请稍后...")
					local httpReq = downloadImageByUrl(shareParams.image,relativePath)
					ui.stopBusy()
					if not httpReq then
						alert("提示","网络异常，请稍候再试","确定")
						return
					end
				end
				local tableName = base.getGSandbox():get("$currentEBookSupply")
				local englishtableName = tableName
				tableName = getChineseNameFromEnglishName(tableName)
				share.setEnv(_G)
				share.ebookShare(
				_root,
				date,
				tableName,
				englishtableName,
				shareParams.title,
				shareParams.content,
				shareParams.url,
				function ()
					if absoluteIamgePath then
						return absoluteIamgePath
					end
				end
				,function ()
				end,
				function ()
				end,
				function ()
				end)
			end 
			
	
		 end
		_root:addChild(topToolBar)
	end
end
function getChineseNameFromEnglishName( englistTableName )
	-- body
	local  tableName = englistTableName
	if tableName == "mcb" then
		tableName = "每月精点"
	elseif tableName == "applause" then
		tableName = "喝彩"
	elseif tableName == "thinkpink" then
		tableName = "玫丽"
	end

	return tableName
end

function addRedRectWhenJump()
	local redBorder = _G["redBorder"]
	local bottomToolBar = _G["bottomToolBar"]
	local offset = 0
	--local imageDispalyWidth = _root.width*0.2
	local imageDispalyWidth = 60

	local ebookcurrentPageNumber = _G["ebookView"]:currentPageNumber()
	for i = 1,tonumber(ebookcurrentPageNumber) do
		offset = (imageDispalyWidth) * (i-1) + 15 * i
	end
	local marginL = _root.width*0.4
	redBorder.marginLeft = offset  - 2
	local totalOffset = gettotaloffset()
	if offset - marginL <= 0 then
		bottomToolBar:setContentOffset(0 ,0)
	elseif offset +  marginL >= totalOffset then 
		bottomToolBar:setContentOffset(totalOffset - 2*marginL ,0)
	else
		bottomToolBar:setContentOffset(offset - marginL ,0)
	end
end

function gettotaloffset()
	local offset = 0
	local ebooktotalPageNumber = _G["ebookView"]:totalPageNumber()
	local imageDispalyWidth = 60
	for i = 1,tonumber(ebooktotalPageNumber) do
		offset = (imageDispalyWidth) * (i-1) + 15 * i
	end
	return offset
end


function getImageAbsolutePathWidthHeight(imageAbsolutePath)
	local imageservice = registry.getService("image")
	local img = imageservice:load(imageAbsolutePath)
	local imgWidth,imgHeight = img:getSize()
	return imgWidth,imgHeight
end
function bottomToolBarUI()
	if deviceInfo["os.name"] ~= "IOS" then
		_G["ebookView"].onBookParsed = createBottomUI
	else
		createBottomUI()
	end
end
function createBottomUI ()
	local bottomToolBar = _G["bottomToolBar"]
	if bottomToolBar == nil then
		local bottomToolBar = ui.scrollview{direction="horizontal",id="bottomToolBar", margin="auto 0 0 auto", width="100%", height=134.5,backgroundColor="#000000", backgroundAlpha=0.8,marginBottom=-134.5}
		local ebookURL = _G["ebookView"]:tableOfContent()
		local ebookcurrentPageNumber = _G["ebookView"]:currentPageNumber()
		local ebooktotalPageNumber = _G["ebookView"]:totalPageNumber()
		--local imageDispalyWidth = _root.width*0.2
		local imageDispalyWidth = 60
		
		local imageWidth,imageHeight = getImageAbsolutePathWidthHeight(ebookURL[1].thumbnail)
		local redBorder = ui.view{id = "redBorder",width = imageDispalyWidth + 4 ,height = 100 + 4,marginLeft = 0,marginTop = 10 - 2,backgroundColor = "#ff5f5f" }
		bottomToolBar:addChild(redBorder)
		for i,ablum in ipairs(ebookURL) do
		 	imageWidth,imageHeight = getImageAbsolutePathWidthHeight(ablum.thumbnail)
			bottomToolBar:addChild(ui.button{width=imageDispalyWidth,height=100,marginTop=10,marginLeft= imageDispalyWidth * (i-1) + 15*i,backgroundImage=ablum.thumbnail,backgroundScale = "fill",
				onclick=function()
					_G["ebookView"]:switchToPage(ablum.pageNumber)
				end
				})
			bottomToolBar:addChild(ui.label{width = imageDispalyWidth,height = 22.5,color = "white",fontSize = 12,bold = true,align = "center",marginLeft = imageDispalyWidth * (i-1) + 15*i,text = ablum.label,marginTop = 100 + 12 })
		 end
		_root:addChild(bottomToolBar)
	end
	
end
function onNavBack()
	apps.popPage()
end