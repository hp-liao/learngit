local require = require
local registry = registry

local log = require "framework.log"
local apps = require "framework.apps"
local services = require "framework.services"
local ui = require "framework.ui"
local base = require "framework.base"
local storage = require "framework.storage"
local utils = require "framework.utils"
local mba = require "framework.mba"
local http = require "framework.http"
local json = require "json"
local zip = require "zip"
local track = require "framework.track"
local user = require "framework.user"

local sqlite3 = require "sqlite3"
local mymagazine = require "magazine"


local _G = _G

local LOG_TAG = "test_tag:"

local registry = registry
local deviceservice = registry.getService("device")
local downloadservice = registry.getService("genericdownload")

local magazineType = 1 -- 1-applause(default) 2-mcb
local wScale = 1
local hScale = 1


local magazineWidth = 180
local magazineHeight = 228
local magazineLeft = 24
local magazineTop = 26
local magazineHeight = 228
local magazineMarginBottom = 20--34
local magazineMarginRight = 26 --24
local titleHeight = 50--44

local btnWidth = 120
local btnHeight = 42
local downloadBtnWidth =60

-- 640 * 1136 -- book 180+228
function onFronted()
  -- Record omniture tracking info
  log.debug(LOG_TAG.." onFronted")
  local profile = user.getProfile()  
  local pageName="emagazine:index"
  local channel ="emagazine"
  track.track(pageName,channel)
  if deviceservice then
    deviceservice.statusBarHidden = false
  end
end
function onCreated()
  log.debug(LOG_TAG.." onCreated")
  local rootView = _G["rootView"]
  wScale = rootView.width/640
  hScale = rootView.height/1136
  log.debug(LOG_TAG.."wScale:"..wScale .." hScale:"..hScale)
  mymagazine.initDatabase()
  createFrame(rootView)
  showMagazineList(1)
end

function createFrame(rootView)
  rootView.backgroundColor = "#f0f0f0"
  local mt 
  local height1 
  local deviceInfo1 = base.getDeviceInfo()

	mt=0
	height1=43*hScale

  local navBar = ui.view{id="navBar",width=640*wScale,height=height1,backgroundColor="#f0f0f0",marginTop=mt}
  local backBtnView = ui.view{id="backBtnView",width=20*wScale,height=34*hScale,backgroundImage="images/return.png",backgroundScale = "fitHeight",marginLeft=24*wScale,marginTop=(86-34)/2*hScale}
  local backBtn = ui.button{id="backBtn",width=100*wScale,height=86*hScale,onclick=function() goBack() end}
  local navView = ui.view{id="navView",width=340*wScale,height=58*hScale,backgroundImage="images/tab1.png",backgroundScale = "fill",marginLeft=(640-340)/2*wScale,marginTop=(86-58)/2*hScale}
  local applauseBtn = ui.button{id="applauseBtn",label="喝彩",fontSize=14, color="#ffffff",width=navView.width/2,height=navView.height,marginLeft=0,marginTop=0*hScale,onclick=function() switchType(1) end}
  local mcbBtn = ui.button{id="mcbBtn",label="每月精点",fontSize=14,color="#f96464",width=navView.width/2,height=navView.height,marginLeft=navView.width/2,marginTop=0*hScale,onclick=function() switchType(2) end}
 
  local bodder = ui.view{id="bodder",width=640*wScale,height=0.5,backgroundColor="#cccccc",marginTop=navBar.height+(23/660)*rootView.height}
  
  navView:addChild(applauseBtn)
  navView:addChild(mcbBtn)
  navBar:addChild(navView)
  navBar:addChild(backBtnView)
  navBar:addChild(backBtn)
  rootView:addChild(navBar)
  rootView:addChild(bodder)
  local magazineListView = ui.scrollview{id="magazineListView",width=navBar.width,height=rootView.height-navBar.height-bodder.height,backgroundColor="#ffffff",marginTop=navBar.height+(23/660)*rootView.height+bodder.height}
  -- ui.scrollview{id="magazineList", margin = "auto 0 0 0", height = magList.height - theSeperatorLineHeight - marginTopForSeperator, backgroundColor = "#efefef"}
  rootView:addChild(magazineListView)
end
function showMagazineList(magazineType)
  log.debug(LOG_TAG.." showMagazineList")
  
  local  tableName = ""
  if magazineType == 1 then
    tableName = "applause"
  else
    tableName = "mcb"
  end
  local magazines = mymagazine.selectMagazinesByCategory(tableName)
  log.debug(LOG_TAG..utils.objecttostring(magazines))
  --mymagazine.showMagazineList(magazines, tableName)
  local magazineListView = _G["magazineListView"]
  magazineListView:removeAllChildren()
  local i = 0
  local originY = 0
  for key, magazineInfo in ipairs(magazines) do
    local row = math.floor(i/3)
    local column = i%3
    originY =  (magazineTop+(magazineHeight+magazineMarginBottom+titleHeight)*row)*hScale
    local originX = (magazineLeft + (magazineWidth + magazineMarginRight) * column)*wScale
    --print("onemagazineInfo:" .. utils.objecttostring(magazineInfo))
    local oneMagazine = createUIForOfflineMagazine(originX, originY, magazineInfo, tableName,magazineListView)
    i = i + 1
  end
end

function createUIForOfflineMagazine(originX, originY, magazineInfo, tableName,magazineList)
  local downloadStatus = mymagazine.getStatus(magazineInfo.MagazineId)
  local oneOfflineMagazine = nil
  local gestureCover = {}
  gestureCover.qName = "gestureView"
  gestureCover.id = magazineInfo.MagazineId .."gestureView"
  gestureCover.marginTop = 0
  gestureCover.marginLeft = 0
  gestureCover.width = magazineWidth*wScale
  gestureCover.height = magazineHeight*hScale
  gestureCover.backgroundColor = "black"
  gestureCover.backgroundAlpha = 0.7
  local okBtn = ui.button{id=magazineInfo.MagazineId .."confirmdeletemagazine", marginLeft = ((magazineWidth - btnWidth)/2)*wScale, hidden = true, marginTop = 50 * hScale, 
      width = 120 * wScale, height = 42 * hScale, backgroundScale = "fill", backgroundImage = "images/delete.png", onclick = function()
      deleteDownloadedMagazine(magazineInfo, tableName,magazineList)
    end
  }
  local cancelBtn = ui.button{id = magazineInfo.MagazineId .."canceldeletemagazine", marginLeft = ((magazineWidth - btnWidth)/2)*wScale, hidden = true,  marginTop = (50+42+42) * hScale,
      width = 120 * wScale, height = 42 * hScale, backgroundScale = "fill",backgroundImage = "images/cancel.png", onclick = function()
      local okBtnView = _G[magazineInfo.MagazineId .."confirmdeletemagazine"]
      local cancelBtnView = _G[magazineInfo.MagazineId .."canceldeletemagazine"]
      okBtnView.hidden = true
      cancelBtnView.hidden = true
      local gestureView = _G[magazineInfo.MagazineId .."gestureView"]
      if downloadStatus == downloadservice.StatusComplete then
        gestureView.backgroundColor = nil
      end
    end
  }
  log.debug(LOG_TAG.."downloadStatus:" .. downloadStatus)
  if downloadStatus == downloadservice.StatusUnknown then
    oneOfflineMagazine = createUIForMagazine(originX, originY, magazineInfo, tableName)
    gestureCover.height = magazineHeight*hScale
    --gestureCover.backgroundColor = nil
    gestureCover.onTouch = function()
      downloadOfflineMagazine(magazineInfo, tableName,magazineList)
    end
    oneOfflineMagazine:addChild(gestureCover)
    local downloadIcon = ui.button{marginTop = (magazineHeight - downloadBtnWidth)/2*hScale, marginLeft = (magazineWidth - downloadBtnWidth)/2*wScale, 
        width = downloadBtnWidth*wScale, height = downloadBtnWidth*hScale, backgroundScale = "fill", backgroundImage = "images/download-icon.png", onclick = function ()
      downloadOfflineMagazine(magazineInfo, tableName,magazineList)
    end}
    oneOfflineMagazine:addChild(downloadIcon)
    magazineList:addChild(oneOfflineMagazine)
    local bottomBar = _G[magazineInfo.MagazineId .."bottomBar"]
    bottomBar.hidden = true
  elseif downloadStatus == downloadservice.StatusComplete then
    oneOfflineMagazine = createUIForMagazine(originX, originY, magazineInfo, tableName)
    gestureCover.backgroundColor = nil
    gestureCover.height = magazineHeight*hScale
    gestureCover.onTouch = function()
      local okBtnView = _G[magazineInfo.MagazineId .."confirmdeletemagazine"]
      if okBtnView then
        if okBtnView.hidden == false then
          return
        end
      end
      mymagazine.playMagazine(magazineInfo.Id, tableName, magazineInfo.Title)
    end
    gestureCover.onLongPress = function()
      local gestureView = _G[magazineInfo.MagazineId .."gestureView"]
      gestureView.backgroundColor = "black"
      local okBtnView = _G[magazineInfo.MagazineId .."confirmdeletemagazine"]
      local cancelBtnView = _G[magazineInfo.MagazineId .."canceldeletemagazine"]
      okBtnView.hidden = false
      cancelBtnView.hidden = false
    end
    oneOfflineMagazine:addChild(gestureCover)
    oneOfflineMagazine:addChild(okBtn)
    oneOfflineMagazine:addChild(cancelBtn)
    magazineList:addChild(oneOfflineMagazine)
    local bottomBar = _G[magazineInfo.MagazineId .."bottomBar"]
    bottomBar.hidden = true
  else
    if downloadStatus == downloadservice.StatusRunning or downloadStatus == downloadservice.StatusPause then
      oneOfflineMagazine = createUIForMagazine(originX, originY, magazineInfo, tableName)
      gestureCover.backgroundAlpha = 0.2
      local dinfo = mymagazine.getDownloadInfo(magazineInfo.MagazineId)
      gestureCover.onTouch = function()
        local okBtnView = _G[magazineInfo.MagazineId .."confirmdeletemagazine"]
        if okBtnView then
          if okBtnView.hidden == false then
            return
          end
        end
        downloadStatus = mymagazine.getStatus(magazineInfo.MagazineId)
        local durationLabel = _G[magazineInfo.MagazineId .. "_duration"]
        if downloadStatus == downloadservice.StatusRunning then
          downloadservice:pause("magazine"..magazineInfo.MagazineId)
          durationLabel.text = "暂停"
        else
          local hasNetwork = common.hasNetworkWithPrompt(nil)
          if not hasNetwork then
            return
          end
          local possibleNewFilePath = sandbox:getDataPath() .. "/magazines/" .. tableName .. "/" .. string.gsub(magazineInfo.MagazineId, tableName, "", 1)
          local deviceInfo = base.getDeviceInfo()
          if deviceInfo["os.name"] == "IOS" then
            --if not lfs.attributes(possibleNewFilePath) then 
              downloadservice:updateDestFilePath("magazine" .. magazineInfo.MagazineId, possibleNewFilePath)
            --end
          end
          downloadservice:resume("magazine"..magazineInfo.MagazineId)
          durationLabel.text = "下载中"
        end
      end
      gestureCover.onLongPress = function()
        local okBtnView = _G[magazineInfo.MagazineId .."confirmdeletemagazine"]
        local cancelBtnView = _G[magazineInfo.MagazineId .."canceldeletemagazine"]
        okBtnView.hidden = false
        cancelBtnView.hidden = false
      end
      oneOfflineMagazine:addChild(gestureCover)
      oneOfflineMagazine:addChild(okBtn)
      oneOfflineMagazine:addChild(cancelBtn)
      magazineList:addChild(oneOfflineMagazine)
      
      local progressbar = _G[magazineInfo.MagazineId .. "_progressbar"]
      progressbar.hidden = false 
      progressbar.width = (dinfo.progress / 10) .. "%" 
      
      local durationLabel = _G[magazineInfo.MagazineId .. "_duration"]
      if downloadStatus == downloadservice.StatusRunning then
        durationLabel.text = "下载中"
      else
        durationLabel.text = "暂停"
      end
      log.debug(LOG_TAG.."fileSize44:"..utils.objecttostring(dinfo.fileSize))
      if dinfo.fileSize ~= nil and type(dinfo.fileSize) == number and tonumber(dinfo.fileSize) ~= 0 then
        local magazineLabel = _G[magazineInfo.MagazineId .. "_magazineSize"]
        magazineLabel.text = string.format("%.1f",dinfo.fileSize/(1024*1024)).."M"
      end
      attachProgressWatcher(dinfo, magazineInfo.MagazineId, magazineInfo.FileSize, tableName,magazineList)
    end
  end
end


function createUIForMagazine(originX, originY, magazineInfo, tableName)
  local container = ui.view{marginTop = originY, marginLeft = originX, width = magazineWidth*wScale, height = (magazineHeight + titleHeight)*hScale, id = magazineInfo.MagazineId .. "_container"}
  
  local cover = ui.view{marginTop = 0, marginLeft = 0, width = magazineWidth * wScale, height = magazineHeight * hScale, backgroundImage = magazineInfo.CoverPath, backgroundScale="fill"}
  
  local bottomBar = ui.view{id = magazineInfo.MagazineId .. "bottomBar", width = "100%", height = 30 * hScale, marginLeft = 0, marginBottom = 0, backgroundColor = "black", backgroundAlpha = 0.7}
  
  local progressBar = ui.view{marginTop = 0, marginLeft = 0, width = "0%", hidden = true, id = magazineInfo.MagazineId .. "_progressbar", height = "100%", backgroundColor = "#e84242"}
  bottomBar:addChild(progressBar)
  
  local magazineDurationText = ""
  local magazineDuration = ui.label{text = magazineDurationText, fontSize = 24 * hScale, width = bottomBar.width, marginLeft = 4, height = bottomBar.height, color = "white", backgroundAlpha = 0.2,id = magazineInfo.MagazineId .. "_duration"}
  bottomBar:addChild(magazineDuration)
  local magazineSize = ui.label {text ="", fontSize = 24 * hScale, width = bottomBar.width, marginRight = 4, align = "right", height = bottomBar.height, color = "white",backgroundAlpha = 0.2,id = magazineInfo.MagazineId .. "_magazineSize"}
  bottomBar:addChild(magazineSize)
  cover:addChild(bottomBar)
  
  local playBtn = ui.button{width = "100%", height = "100%", onclick = function()
      local currentGestureCover = _G[magazineInfo.MagazineId .."gestureView"]
      log.debug(LOG_TAG.." cover:".. utils.objecttostring(currentGestureCover))
      if currentGestureCover then
        log.debug(LOG_TAG.." onTouch")
        currentGestureCover.onTouch()
      else
      log.debug("playBtn can't get currentGestureCover")
      end
    end
  }
  
  cover:addChild(playBtn)
  container:addChild(cover)
  
  local myTitleText = string.gsub(magazineInfo.Title,"%p","-")
  local magazineTitle = ui.label{text = myTitleText, marginLeft = 3, marginBottom = 0, width = magazineWidth*wScale, height = titleHeight * hScale, fontSize = 24 * wScale, color="#444444"}
  local deviceInfo = base.getDeviceInfo()
  magazineTitle.fontSize = magazineTitle.fontSize + 2
  if deviceInfo["os.name"] == "IOS" then
    magazineTitle.fontSize = magazineTitle.fontSize - 1
    magazineTitle.marginLeft = magazineTitle.marginLeft - 2
    magazineTitle.width = magazineTitle.width + 12
  end
  container:addChild(magazineTitle)
  return container
end

local watchers = {}
local statuswwatchers = {}
function attachProgressWatcher(dinfo, magazineId, magazineSize, tableName,magazineList)
  local func = function(dinfo,progress)
    if progress == -1 then
      local container = _G[magazineId .. "_container"]
      local marginTop = container.marginTop
      local marginLeft = container.marginLeft
      log.debug(LOG_TAG.."tableName:"..tableName.." name:"..getCurrentMagazineTypeName())
      if tableName == getCurrentMagazineTypeName() then
        magazineList:removeChild(container)
        createUIForOfflineMagazine(marginLeft, marginTop, mymagazine.selectMagazineById(magazineId, tableName), tableName,magazineList)
      end
    end
    local magazineLabel = _G[magazineId.. "_magazineSize"]
    magazineLabel.text = string.format("%.1f",dinfo.fileSize/(1024*1024)).."M"
    progress = dinfo.progress
    animation(function()
      local progressbar = _G[magazineId .. "_progressbar"]
      if progressbar then
        progressbar.width = (progress / 10) .. "%"
      end

      local progresslabel = _G[magazineId .. "_progresslabel"]
      if progresslabel then
        --progresslabel.text = string.format("%1.1f", ((progress / 1000) * magazineSize)/1024/1024) .. "/" ..  string.format("%1.1fM",  magazineSize/1024/1024)
        progresslabel.text = (progress / 10) .. "%"
      end
    end)

    if progress == 1000 then
    end
  end

  watchers[magazineId] = dinfo:addProgressWatcher(func)

  local func2 = function(item, status)
    if status == downloadservice.StatusComplete then
        log.debug("download completed for magazine:" .. magazineId)
        local durationLabel = _G[magazineId .. "_duration"]
      --downloadservice:pause("magazine"..magazineId)
      durationLabel.text = "安装中"
      ui.startBusy(nil, "解压安装中...")
      mymagazine.unzipMagazine(dinfo, magazineId)
      ui.stopBusy()
      local x = 1
      log.debug(LOG_TAG.."tableName:"..tableName.." name:"..getCurrentMagazineTypeName())
      if tableName == getCurrentMagazineTypeName() then
        local container = _G[magazineId .. "_container"]
        local marginTop = container.marginTop
        local marginLeft = container.marginLeft
        magazineList:removeChild(container)
        local maganizeInfo = mymagazine.selectMagazineById(magazineId, tableName)
        createUIForOfflineMagazine(marginLeft, marginTop, maganizeInfo, tableName,magazineList)
      end
    elseif status == downloadservice.StatusPause then
      local durationLabel = _G[magazineId .. "_duration"]
      --downloadservice:pause("magazine"..magazineId)
      durationLabel.text = "暂停"
    end

  end

    statuswwatchers[magazineId] = dinfo:addStatusWatcher(func2)
end

function getCurrentMagazineTypeName()
  if magazineType == 1 then
    return "applause"
  else
    return "mcb"
  end
end

function downloadOfflineMagazine(magazineInfo, tableName,magazineList)
  --log.debug("emagazine:DOWNLOAD:" .. getChineseNameFromEnglishName(tableName) .. magazineInfo.Title)
  track.track("emagazine:" .. tableName .. ":" .. magazineInfo.Title .. ":download", "emagazine")
  local magazineId = magazineInfo.MagazineId
  downloadservice:add(magazineInfo.FileUrl, "magazine"..magazineId, magazineInfo.FilePath, true)
  downloadservice:resume("magazine"..magazineId)
  local container = _G[magazineId .. "_container"]
  local marginTop = container.marginTop
  local marginLeft = container.marginLeft
  magazineList:removeChild(container)
  createUIForOfflineMagazine(marginLeft, marginTop, magazineInfo, tableName,magazineList)
end


function deleteDownloadedMagazine(magazineInfo, tableName,magazineList)
  --log.debug("emagazine:DELETE:" .. getChineseNameFromEnglishName(tableName) .. magazineInfo.Title)
  track.track("emagazine:" .. tableName .. ":" .. magazineInfo.Title .. ":delete", "emagazine")
  downloadservice:delete("magazine" .. magazineInfo.MagazineId)
  mymagazine.removeMagazineFiles(tableName, string.gsub(magazineInfo.MagazineId, tableName, "", 1))
  local container = _G[magazineInfo.MagazineId .. "_container"]
  local marginTop = container.marginTop
  local marginLeft = container.marginLeft
  magazineList:removeChild(container)
  createUIForOfflineMagazine(marginLeft, marginTop, magazineInfo, tableName,magazineList)
end

function switchType(magatype)
  if magazineType ~= magatype then
    magazineType = magatype
    local navView = _G["navView"]
    navView.backgroundImage = ("images/tab"..magatype..".png")
    local applauseBtn = _G["applauseBtn"]
    local mcbBtn = _G["mcbBtn"]
    if magatype == 1 then
      applauseBtn.color="#ffffff"
      mcbBtn.color="#f96464"
    else
      applauseBtn.color="#f96464"
      mcbBtn.color="#ffffff"
    end
    showMagazineList(magatype)
  end
end

function onNavBack()
  goBack()
  return true
end

function goBack()
  apps.pop()
end

