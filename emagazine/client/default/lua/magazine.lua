module(..., package.seeall)

local log = require "framework.log"
local base =require "framework.base"
local ui = require "framework.ui"
local apps = require "framework.apps"
local common = require "common"
local utils = require "framework.utils"
local user = require "framework.user"
local mba = require "framework.mba"
local http = require "framework.http"
--local http = require "native.http"
local json = require "json"
local zip = require "zip"
local dataOp =  require "dataOp"
local registry = registry
local downloadservice = registry.getService("genericdownload")
local track = require "framework.track"
local deviceservice = registry.getService("device")

local magazinePageCreated = false
local _G = _G
local appId = utils.getAppId(sandbox)
local path = sandbox:getDataPath() .. "/" .. "magazines.sqlite"
local sqlite3 = require "sqlite3"
local db = sqlite3.open(path)
local magNameSuffix = "mag"
local currentCategory = ""
local currentCategoryIndex = 1
local currentCategoryName = nil
local validMagazineids = nil
local bookCount = 0
local LOG_TAG = "test_tag:"


function initDatabase()     
  log.debug(LOG_TAG.." initDatabase")
  ui.startBusy(nil, "加载中...")
  sleep(0.01)
  fetchHecaiData("applause")
  fetchHecaiData("mcb")
  ui.stopBusy()

  bookCount = tonumber(getMagazineCount("applause")) + tonumber(getMagazineCount("mcb"))
  log.debug(LOG_TAG.."third party ebook count:" .. bookCount)
end

function selectMagazinesByCategory(tableName)
  local magazines = {}
  local sqlQuery = "select id, name, magazineurl, thumbnailurl,shareinfourl from " .. tableName .. " ORDER BY id DESC "
  for oneMagazine in db:rows(sqlQuery) do
    local magazineInfo = {}
    magazineInfo.FileUrl = oneMagazine[3]
    magazineInfo.FilePath = sandbox:getDataPath() .. "/magazines/" .. tableName .. "/" .. oneMagazine[1]
    magazineInfo.MagazineId = tableName .. oneMagazine[1]
    magazineInfo.CoverPath = oneMagazine[4]
    magazineInfo.Title = oneMagazine[2]
    magazineInfo.Id = oneMagazine[1]

    magazineInfo.shareinfourl = oneMagazine[5]
    magazineInfo.shareinfPath = sandbox:getDataPath() .. "/magazines/" .. tableName .. "/" .. oneMagazine[1] .. "/shareinfo"

    table.insert(magazines, magazineInfo)
    end
    return magazines
end

function unzipMagazine(dinfo, magName) 
    local oldName

    if type(dinfo.absolutePath) == "string" then
    -- for ios due to absolutePath is not supported by android now
      oldName = dinfo.absolutePath;   
    else
    -- for android
        oldName = dinfo.path;
    end

  -- This downloaded file is a zip file, need not rename to *.zip, then unzip, zip.unzip method can unzip this file directly
    local newDest = oldName .. magNameSuffix
    log.debug("unzip magazine from: " .. oldName .. " to " .. newDest)
    local ret, msg = zip.unzip(oldName, newDest)
    os.remove(oldName)

  --local fileExists = checkMagazineFileExists(newDest)

    if ret == 0 then 
      log.debug("unzip magazine success")
      return true   
    else
    --track.track(0x202, {"Unzip magazine failed", magName})
      log.debug("unzip magazine failed, err code = " .. ret)
      ui.alert("提示", "解压电子杂志操作失败，请长按删除后并重试", "确定")
      return false
    end
end

function selectMagazineById(magazineId, tableName)
  local magazineInfo = {}
    local idx = string.gsub(magazineId, tableName, "")
    for oneMagazine in db:rows("select id, name, magazineurl, thumbnailurl,shareinfourl from " .. tableName .. " where id = " .. idx) do
    magazineInfo.FileUrl = oneMagazine[3]
    magazineInfo.FilePath = sandbox:getDataPath() .. "/magazines/" .. tableName .. "/" .. oneMagazine[1]
    magazineInfo.MagazineId = tableName .. oneMagazine[1]
    magazineInfo.CoverPath = oneMagazine[4]
    magazineInfo.Title = oneMagazine[2]
    magazineInfo.Id = oneMagazine[1]

    magazineInfo.shareinfourl = oneMagazine[5]
    magazineInfo.shareinfPath = sandbox:getDataPath() .. "/magazines/" .. tableName .. "/" .. oneMagazine[1] .. "/shareinfo"
    break
    end

    return magazineInfo
end

function playMagazine(magazineId, tableName, magazineTitle)
  local magazineZipFilePath = sandbox:getDataPath() .. "/magazines/".. tableName .. "/" .. magazineId
  local magazineFilePath = getMagazinePath(tableName, magazineId)
  local pathattr = lfs.attributes(magazineZipFilePath)
  --if zipfile exists, it means that user exited our application when unzip was ongoing the last time.
  if pathattr then
    --unzip again
    ui.startBusy(nil, "解压中，请稍后重新点击进入")
    local ret, msg = zip.unzip(magazineZipFilePath, magazineFilePath)
      os.remove(magazineZipFilePath)
      ui.stopBusy()

      if ret ~= 0 then
        log.debug("unzip magazine failed before play magazine, err code = " .. ret)
        ui.alert("提示", "解压电子杂志操作失败，请长按删除后重新下载", "确定")
        return
      end
      return
  end

  local fileExists = checkMagazineFileExists(magazineFilePath)
    if not fileExists then 
      log.debug("this should not happen, wierd thing...")
      ui.alert("提示", "文件校验失败，请长按删除后重新下载", "确定")
      return
    end

  base.getGSandbox():put("$currentEBookSupply", tableName)
  base.getGSandbox():put("$currentEBookID", magazineId)
  base.getGSandbox():put("$currentEBookTitle", magazineTitle)
  --log.debug("emagazine:READ:" .. getChineseNameFromEnglishName(tableName) .. magazineTitle)
  track.track("emagazine:" .. tableName .. ":" .. magazineTitle .. ":open", "emagazine")
  if deviceservice then
    deviceservice.statusBarHidden = true
  end
  apps.pushPage("ebook")
end

function  checkMagazineFileExists(newDest)
  -- body
    local pathattr = lfs.attributes(newDest .. "/Pages")
    if pathattr then
      return true
  end

  pathattr = lfs.attributes(newDest .. "/CoordFile")
    if pathattr then
      return true
  end

  pathattr = lfs.attributes(newDest .. "/TextFile")
    if pathattr then
      return true
  end

  log.debug("magzine file not exist after unzip!")
  return false
end

function removeMagazineFiles(tableName, magazineId)
  local path = getMagazinePath(tableName, magazineId)
  local pathattr = lfs.attributes(path)
  if not pathattr then
    return false
  end

  if pathattr.mode ~= "directory" then
    os.remove(path)
    return true
  end

  for file in lfs.dir(path) do
    local lowerFileName = string.lower(file)
    if file ~= "." and file ~= ".." and lowerFileName ~= "shareinfo.txt" then
      local f = path..'/'..file
      local attr = lfs.attributes (f)
      if attr.mode == "directory" then
        utils.removePath(f)
      else
        os.remove(f)
      end
    end
  end

  --lfs.rmdir(path)
end

function getMagazinePath(tableName, magazineID)
  local path = nil
  path = sandbox:getDataPath() .. "/magazines/" 
  if not lfs.attributes(path) then
    lfs.mkdir(path)
  end
  path = sandbox:getDataPath() .. "/magazines/".. tableName .. "/"  
  if not lfs.attributes(path) then
    lfs.mkdir(path)
  end
  path = sandbox:getDataPath() .. "/magazines/".. tableName .. "/" .. magazineID .. magNameSuffix
  if not lfs.attributes(path) then
    lfs.mkdir(path)
  end
  return path
end

function getMagazineRelativePath(tableName, magazineID)
  local path = nil
  path =  "/magazines/" 
  if not lfs.attributes(path) then
    lfs.mkdir(path)
  end
  path = "/magazines/".. tableName .. "/"  
  if not lfs.attributes(path) then
    lfs.mkdir(path)
  end
  path = "/magazines/".. tableName .. "/" .. magazineID .. magNameSuffix
  if not lfs.attributes(path) then
    lfs.mkdir(path)
  end
  return path
end

function getDownloadInfo(magazineId)
  return downloadservice:query("magazine"..magazineId)
end

function getStatus(magazineId)
  local dinfo = getDownloadInfo(magazineId)
  return dinfo and dinfo.status or downloadservice.StatusUnknown
end

function fetchHecaiData(tableName)
  local  stmt = db:prepare("CREATE TABLE IF NOT EXISTS " .. tableName .. "(id integer primary key,type text,name text,fullname text,thumbnailurl text,magazineurl text,status integer default 0,createdtime text,shareinfourl text,shareinfocreatedtime text );")
  stmt:step()
  stmt:finalize()

  local time = 1
  for tma in db:rows("SELECT COUNT(id),createdtime FROM " .. tableName .. " group by createdtime order by createdtime DESC LIMIT 1") do
      if tma[1] == 0 then
        time = 1
      else
          time = math.ceil(tma[2])
      end
  end
  local magazineLastCreatedTime = getMagazineLastCreatedTime( tableName )
  local shareInfoLastCreatedTime = getShareInfoLastCreatedTime( tableName )
  local apiName = ""
  if tableName == "applause" then
    apiName = "Applauseebook"
  elseif tableName == "mcb" then
    apiName = "Mcbebook"
  elseif tableName == "thinkpink" then
    apiName = "ThinkPinkebook"
  end

  local respdic = dataOp.EBookGet(magazineLastCreatedTime,shareInfoLastCreatedTime, apiName, "Phone")
    
  if respdic then
    local magazines = respdic["magazines"]
    if #(magazines) > 0 then
      tagAllBooksAsOld(tableName)
      traversalMagazines(magazines, tableName)
      deleteAllOldMagazines(tableName)
    end
  end
end

function getMagazineLastCreatedTime( tableName )
  local time = 1
    for tma in db:rows("SELECT COUNT(id),createdtime FROM " .. tableName .. " group by createdtime order by createdtime DESC LIMIT 1") do
        if tma[1] == 0 then
          time = 1
        else
            time = math.ceil(tma[2])
        end
    end
    return time
end

function getShareInfoLastCreatedTime( tableName )
  local time = 1
    for tma in db:rows("SELECT COUNT(id),shareinfocreatedtime FROM " .. tableName .. " group by shareinfocreatedtime order by shareinfocreatedtime DESC LIMIT 1") do
        if tma[1] == 0 then
          time = 1
        else
            time = math.ceil(tma[2])
        end
    end
    return time
end
function tagAllBooksAsOld(tableName)
  local stmt = db:prepare("update " .. tableName .. " set status=1")
    stmt:step()
    stmt:finalize()
end

function deleteAllOldMagazines(tableName)
  local stmt = db:prepare("delete from " .. tableName .. " where status=1")
    stmt:step()
    stmt:finalize()
end
function traversalMagazines(magazines, tableName)
  local profile = user.getProfile()  
  local userLevelCode = profile.levelCode
    for i=1,#(magazines) do
        local magazine = magazines[i]
        if magazine.levelcodeMax and magazine.levelcodeMin and tonumber(magazine.levelcodeMax) >= userLevelCode and tonumber(magazine.levelcodeMin) <= userLevelCode then
          handleShareInfo(magazine, tableName)
          handleMagazine(magazine, tableName)
      end
    end
end

function handleShareInfo(magazine, tableName)
  if  magazine then
    local timeStamp = loadShareInfoTimeStampById(magazine["id"], tableName)
    local needDownlaod = true
    log.debug("handleShareInfo:: remote timeStamp:" .. utils.objecttostring( magazine["shareinfocreatedtime"]) .. ", local timeStamp:" .. utils.objecttostring(timeStamp) )
    if timeStamp and string.len(timeStamp) > 0 then
      timeStamp = tonumber(timeStamp)
       if magazine["shareinfocreatedtime"] and timeStamp >= magazine["shareinfocreatedtime"] then
        needDownlaod = false
       end
    end
    if needDownlaod and magazine["shareinfourl"]  and string.len(magazine["shareinfourl"]) > 0 then
      --log.debug("magazine:" .. utils.objecttostring(magazine))
      log.debug("go download sharinfo:" .. magazine.id .. "  " .. tableName)
      local isSuccess = downloadShareInfo(magazine["shareinfourl"], tableName,magazine["id"] )
      if isSuccess then
        updateShareInfoCreateTimeById(magazine["id"], tableName,  magazine["shareinfocreatedtime"] )
      end
    end
  end
end

function handleMagazine(magazine, tableName)
    if magazine then
        local timeStamp = loadMagazineTimeStampById(magazine["id"], tableName)
        if timeStamp and string.len(timeStamp) > 0 then
            local stmt = nil
      timeStamp = tonumber(timeStamp)
      log.debug("handle magazine, remote time:" .. magazine["createdtime"] .. ", local time:" .. timeStamp)
            if magazine["createdtime"] and timeStamp < magazine["createdtime"] then
              downloadservice:delete("magazine" .. tableName .. magazine["id"])
                stmt = db:prepare("update ".. tableName .. " set status=0, type=?,name=?,fullname=?,thumbnailurl=?,magazineurl=?,createdtime=?,shareinfourl=?,shareinfocreatedtime=?   where id=?")
                stmt:bind_values(magazine["type"], magazine["alias"], magazine["name"], magazine["thumbnailurl"], magazine["magazineurl"], magazine["createdtime"], magazine["shareinfourl"], magazine["shareinfocreatedtime"], magazine["id"])
            else
                stmt = db:prepare("update " .. tableName .. " set status=0 where id=?")
                stmt:bind_values(magazine["id"])
            end
            stmt:step()
            stmt:finalize()
        else
            insertNewMagazine(magazine, tableName)
        end
    end
end

function loadMagazineTimeStampById(id, tableName)
    for tma in db:rows("SELECT createdtime FROM " .. tableName .. " WHERE id = '" .. id .. "'") do
        return tma[1]
    end
    return nil
end

function loadShareInfoTimeStampById(id, tableName)
    for tma in db:rows("SELECT shareinfocreatedtime FROM " .. tableName .. " WHERE id = '" .. id .. "'") do
        return tma[1]
    end
    return nil
end
function updateShareInfoCreateTimeById(id, tableName, shareinfocreatedtime)

  local sqlString = "update " .. tableName .. " set shareinfocreatedtime = " .. shareinfocreatedtime .. " where id=" .. id
  log.debug("update share create time query:" .. sqlString)
  local stmt = db:prepare(sqlString)
  stmt:step()
  stmt:finalize()
end
function insertNewMagazine(magazine, tableName)
  if not magazine["shareinfourl"] then
    magazine["shareinfourl"] = ""  
  end

  if not magazine["magazineurl"] then
    magazine["magazineurl"] = ""
  end

    local stmt = db:prepare("insert into " .. tableName .. "(id,type,name,fullname,thumbnailurl,magazineurl,createdtime,shareinfourl,shareinfocreatedtime) values(?, ?, ?, ?, ?, ?, ?,?,?)")
  
    stmt:bind_values(magazine["id"], magazine["type"], magazine["alias"], magazine["name"], triml(magazine["thumbnailurl"]), triml(magazine["magazineurl"]), magazine["createdtime"],triml(magazine["shareinfourl"]), magazine["shareinfocreatedtime"] )
    stmt:step()
    stmt:finalize()
end
function getMagazineCount( tableName )
    for tma in db:rows("SELECT COUNT(*) FROM " .. tableName)  do
        return tma[1]
    end
    return 0
end
function triml(s)
  return s:match'^%s*(.*)'
end
function downloadShareInfo(url, tableName, magazineId )
  local path =  getMagazinePath(tableName,magazineId)
  local absolutePath = path .. "/shareInfo.zip"
  log.debug("downloadShareInfo:: url:" .. utils.objecttostring(url) .. ",tableName:" 
                      .. utils.objecttostring(tableName) .. ", magazineId" .. utils.objecttostring(magazineId) ..", absolutePath:".. utils.objecttostring(absolutePath))
  if lfs.attributes(absolutePath) then
    os.remove(absolutePath)
  end

  --local ret = http.downloadToAbsolutePath(url .. "?=" .. os.time(), absolutePath)
  local tempPath = "tmp_" .. tableName .. "_" .. magazineId .. "_shareinfo" .. os.time() .. ".zip"
  local tmpDownloadPath = http.download(url .. "?=" .. os.time(), tempPath)

  if(tmpDownloadPath == tempPath) then
    tmpDownloadPath = base.getDataFile(tmpDownloadPath)
  end

  log.debug(LOG_TAG.." download ret path:" .. tmpDownloadPath)
  --log.debug("downloadShareInfo:absolutePath:" .. absolutePath .. " , ret:" .. utils.objecttostring(ret))
  local ret, msg = zip.unzip(tmpDownloadPath, path)
  os.remove(tmpDownloadPath)
  if ret == 0 then 
    return true   
  else
    return false
  end
end