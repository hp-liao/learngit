local log = require "framework.log"
local base = require "framework.base"
local utils = require "framework.utils"
local ui = require "framework.ui"
local apps = require "framework.apps"
local phone = require "framework.phone"
local track = require "framework.track"
-- local VtrackData = require "bookshelf.VtrackData"
local LOG_TAG = "test_tag:"

module(..., package.seeall)
local _G = nil
local shareText = {"微信好友","朋友圈","新浪微博","腾讯微博","QQ空间"}
function createShareUI(_root,params)

    if _G["shareBackground"] then
        _root:removeChild(_G["shareBackground"])
    end
      local deviceInfo1 = base.getDeviceInfo()
    if deviceInfo1["os.name"] == "IOS" then
            log.debug(LOG_TAG.."create shareUI _root.width:".._root.width ..": _root.height：".._root.height) 
    local containerHeight = _root.height
    local containerWidth = _root.width
    local shareBackground = ui.view{id = "shareBackground" ,qName="gestureView",marginTop = 44,width = _root.width,height = _root.height-44,backgroundColor = "black",backgroundAlpha = 0.4,onTouch=function()
       hiddenBar()
    end}
    --local shareUI = ui.view{width = _root.width,height = containerHeight*0.22,backgroundColor = "white"}
    local shareUI = ui.view{width = 163/374*containerWidth,height =138/660*containerHeight,marginLeft=205/374*containerWidth,marginTop=0,backgroundImage="images/share/bg.png",backgroundScale="fill"}
    
    local imageWidth,imageHeigh = getImgWidthHeight("images/share/icon-1.png")
    local sharebtnWidth = containerWidth*(35/374)
    --local sharebtnHeight = containerWidth*0.22*imageHeigh/imageWidth
    local sharebtnHeight = containerHeight*(35/660)
    local sharebtnMarginT = containerWidth*0.069
    local sharebtnMarginL = containerWidth*0.065
    local sharebtnMarginR = containerWidth*0.109
    local sharebtnMarginB = containerWidth*0.114

    --1
   --shareUI:addChild(ui.button{backgroundImage = "images/share/icon1.png",width = sharebtnWidth,height = sharebtnHeight,marginLeft = (containerWidth/2-sharebtnWidth)/2 ,marginTop = sharebtnMarginT,backgroundScale = "fill",onclick = function ()createSelectFunc(_root,params[1]) end})
    shareUI:addChild(ui.button{backgroundImage = "images/share/icon-1.png",width = 36/163*shareUI.width,height =36/163*shareUI.width ,marginLeft = 21/163*shareUI.width ,marginTop = 24/137*shareUI.height,backgroundScale = "fill",onclick = function ()createSelectFunc(_root,params[1]) end})
   -- shareUI:addChild(ui.label{text = shareText[1],fontSize = 12,color = "#666666",width = sharebtnWidth,align = "center",marginLeft = (containerWidth/2-sharebtnWidth)/2,marginTop = sharebtnMarginT + sharebtnHeight,height = sharebtnHeight*0.4 })
    shareUI:addChild(ui.label{text = shareText[1],fontSize = 15,color = "#4d4d4d",width = 72/163*shareUI.width,marginLeft = (70/163)*shareUI.width,marginTop = (29/127)*shareUI.height,height = 18/127*shareUI.height })
    --2
   -- shareUI:addChild(ui.button{backgroundImage = "images/share/icon2.png",width = sharebtnWidth,height = sharebtnHeight,marginLeft = containerWidth/2+(containerWidth/2-sharebtnWidth)/2,marginTop = sharebtnMarginT,backgroundScale = "fill",onclick = function () createSelectFunc(_root,params[2]) end})
     shareUI:addChild(ui.button{backgroundImage = "images/share/icon-2.png",width = 36/163*shareUI.width,height =36/163*shareUI.width ,marginLeft = 21/163*shareUI.width,marginTop = 86/137*shareUI.height,backgroundScale = "fill",onclick = function () createSelectFunc(_root,params[2]) end})
   -- shareUI:addChild(ui.label{text = shareText[2],fontSize = 12,color = "#666666",width = sharebtnWidth,align = "center",marginLeft = containerWidth/2+(containerWidth/2-sharebtnWidth)/2,marginTop = sharebtnMarginT + sharebtnHeight,height = sharebtnHeight*0.4 })
    shareUI:addChild(ui.label{text = shareText[2],fontSize = 15,color = "#4d4d4d",width = 72/163*shareUI.width,marginLeft = (70/163)*shareUI.width,marginTop = 86/127*shareUI.height,height = 18/127*shareUI.height })
    shareUI:addChild(ui.view{width=shareUI.width-4,height=1,marginTop=73/138*shareUI.height,marginRight=2,backgroundColor="#e5e5e5"})
    shareUI:addChild(ui.button{width=shareUI.width,height=0.47*shareUI.height,marginBottom=0.46*shareUI.height,onclick=function (  )
        createSelectFunc(_root,params[1])
    end})
    shareUI:addChild(ui.button{width=shareUI.width,height=0.46*shareUI.height,marginBottom=0,onclick=function (  )
        createSelectFunc(_root,params[2])
    end})
    shareBackground:addChild(shareUI)
    _root:addChild(shareBackground)
    else
         log.debug(LOG_TAG.."create shareUI _root.width:".._root.width ..": _root.height：".._root.height) 
    local containerHeight = _root.height
    local containerWidth = _root.width
    local shareBackground = ui.view{id = "shareBackground" ,qName="gestureView",marginTop = 44,width = _root.width,height = _root.height-44,backgroundColor = "black",backgroundAlpha = 0.4,onTouch=function()
       hiddenBar()
    end}
    --local shareUI = ui.view{width = _root.width,height = containerHeight*0.22,backgroundColor = "white"}
    local shareUI = ui.view{width = 163/374*containerWidth,height =138/660*containerHeight,marginRight=20/374*containerWidth,marginTop=0,backgroundImage="images/share/bg.png",backgroundScale="fill"}
    
    local imageWidth,imageHeigh = getImgWidthHeight("images/share/icon-1.png")
    local sharebtnWidth = containerWidth*(35/374)
    --local sharebtnHeight = containerWidth*0.22*imageHeigh/imageWidth
    local sharebtnHeight = containerHeight*(35/660)
    local sharebtnMarginT = containerWidth*0.069
    local sharebtnMarginL = containerWidth*0.065
    local sharebtnMarginR = containerWidth*0.109
    local sharebtnMarginB = containerWidth*0.114

    --1
   --shareUI:addChild(ui.button{backgroundImage = "images/share/icon1.png",width = sharebtnWidth,height = sharebtnHeight,marginLeft = (containerWidth/2-sharebtnWidth)/2 ,marginTop = sharebtnMarginT,backgroundScale = "fill",onclick = function ()createSelectFunc(_root,params[1]) end})
    shareUI:addChild(ui.button{backgroundImage = "images/share/icon-1.png",width = 36/163*shareUI.width,height =36/163*shareUI.width ,marginLeft = 21/163*shareUI.width ,marginTop = 24/137*shareUI.height,backgroundScale = "fill",onclick = function ()createSelectFunc(_root,params[1]) end})
   -- shareUI:addChild(ui.label{text = shareText[1],fontSize = 12,color = "#666666",width = sharebtnWidth,align = "center",marginLeft = (containerWidth/2-sharebtnWidth)/2,marginTop = sharebtnMarginT + sharebtnHeight,height = sharebtnHeight*0.4 })
    shareUI:addChild(ui.label{text = shareText[1],fontSize = 17,color = "#4d4d4d",width = 100/163*shareUI.width,marginLeft = (70/163)*shareUI.width,marginTop = (30/127)*shareUI.height,height = 18/127*shareUI.height })
    --2
   -- shareUI:addChild(ui.button{backgroundImage = "images/share/icon2.png",width = sharebtnWidth,height = sharebtnHeight,marginLeft = containerWidth/2+(containerWidth/2-sharebtnWidth)/2,marginTop = sharebtnMarginT,backgroundScale = "fill",onclick = function () createSelectFunc(_root,params[2]) end})
     shareUI:addChild(ui.button{backgroundImage = "images/share/icon-2.png",width = 36/163*shareUI.width,height =36/163*shareUI.width ,marginLeft = 21/163*shareUI.width,marginTop = 86/137*shareUI.height,backgroundScale = "fill",onclick = function () createSelectFunc(_root,params[2]) end})
   -- shareUI:addChild(ui.label{text = shareText[2],fontSize = 12,color = "#666666",width = sharebtnWidth,align = "center",marginLeft = containerWidth/2+(containerWidth/2-sharebtnWidth)/2,marginTop = sharebtnMarginT + sharebtnHeight,height = sharebtnHeight*0.4 })
    shareUI:addChild(ui.label{text = shareText[2],fontSize = 17,color = "#4d4d4d",width = 100/163*shareUI.width,marginLeft = (70/163)*shareUI.width,marginTop = 88/127*shareUI.height,height = 18/127*shareUI.height })
    shareUI:addChild(ui.view{width=shareUI.width+2,height=1,marginTop=73/138*shareUI.height,marginLeft=2,backgroundColor="#e5e5e5"})
    shareUI:addChild(ui.button{width=shareUI.width,height=0.47*shareUI.height,marginBottom=0.46*shareUI.height,onclick=function (  )
        createSelectFunc(_root,params[1])
    end})
    shareUI:addChild(ui.button{width=shareUI.width,height=0.46*shareUI.height,marginBottom=0,onclick=function (  )
        createSelectFunc(_root,params[2])
    end})
    shareBackground:addChild(shareUI)
    _root:addChild(shareBackground)
    end
    

end
function getImgWidthHeight(imgPath)
    local fileAbsoultePath = imgPath
    local firstChar = string.sub(imgPath, 1, 1)
    if firstChar ~= "/" then
       fileAbsoultePath = base.resolveFile(imgPath)
    end
    local imageservice = registry.getService("image")
    local img = imageservice:load(fileAbsoultePath)
    local imgWidth,imgHeight = img:getSize()
    return imgWidth,imgHeight
end
function ebookShare(container,date,tableName,englishtableName,title,content,url,imageFunc,successFunc,failedFunc,logFunc)
    if not title then 
        title = "电子杂志分享"
    end
  local params1 = {
                tableName = tableName,
                englishtableName = englishtableName,
                method="tencent_weixin",
                type="mix",
                date = date,
                text=content,
                title=title,
                url=url,
                preview=false,
                imageFunc=imageFunc,
                successFunc=successFunc,
                failedFunc=failedFunc,
                logFunc=logFunc
  }
  local params2 = {
                tableName = tableName,
                englishtableName = englishtableName,
                method="tencent_friend",
                type="mix",
                date = date,
                text=content,
                title=title,
                url=url,
                preview=false,
                imageFunc=imageFunc,
                successFunc=successFunc,
                failedFunc=failedFunc,
                logFunc=logFunc
  }
   local params3 = {
                tableName = tableName,
                englishtableName = englishtableName,
                method="sina_weibo",
                type="mix",
                date = date,
                text="#" .. tableName .. "# " .. title.." "..url.." ",
                title=title,
                url=url,
                preview=false,
                imageFunc=imageFunc,
                successFunc=successFunc,
                failedFunc=failedFunc,
                logFunc=logFunc
  }
  local params4 = {
                tableName = tableName,
                englishtableName = englishtableName,
                method="tencent_weibo",
                type="mix",
                date = date,
                text="#" .. tableName .. "# " .. title.." "..url.." ",
                title=title,
                url=url,
                preview=false,
                imageFunc=imageFunc,
                successFunc=successFunc,
                failedFunc=failedFunc,
                logFunc=logFunc
  }
  local params5 = {
                tableName = tableName,
                englishtableName = englishtableName,
                method="tencent_qzon",
                type="mix",
                date = date,
                text=content,
                --photo="http://su.bdimg.com/static/superplus/img/logo_white.png",
                title=title,
                url=url,
                preview=false,
                imageFunc=imageFunc,
                successFunc=successFunc,
                failedFunc=failedFunc,
                logFunc=logFunc
  }

  local shareParamsArr5 = {params1,params2,params3,params4,params5} ---五种分享的情况
  createShareUI(container,shareParamsArr5)
end
function createSelectFunc(container,params)

   if (params.selectFunc == nil) then
      --  log.debug("params.onSelect is nil,use defaultSelectFunc!!")
        params.selectFunc = defaultSelectFunc(container,params)
    end
end
function setEnv(env)
    _G = env
end
function share(params)
    local platformName = ""
    if params.method == "tencent_weixin" then
        platformName = "wechat"
    elseif params.method == "tencent_friend" then
        platformName = "moments"
    elseif params.method == "tencent_qzon" then
        platformName = "qzone"
    elseif params.method == "tencent_weibo" then
        platformName = "tweibo"
    elseif params.method == "sina_weibo" then
        platformName = "weibo"
    end
    log.debug("emagazine:"  .. params.tableName .. ":" .. params.date .. ":share:" .. platformName, "emagazine")
    track.track("emagazine:"  .. params.englishtableName .. ":" .. params.date .. ":share:" .. platformName, "emagazine")
    
    local shareService = registry.getService("socialnetwork")
    shareService:share(params, params.imageFunc, params.successFunc, params.failedFunc, params.logFunc)
end
function defaultSelectFunc(container,params)
   -- params.successFunc = defaultSuccessFunc(container)
    hiddenBar()
    if params.method == "tencent_weixin" or params.method == "tencent_friend" then
      share(params)
      return
    end
    if _G["alertShareMainView"] then
        container:removeChild(_G["alertShareMainView"])
    end
        local containerWidth = container.width
        local containerHeight = container.height
        local alertShareMainView = ui.view{qName = "gestureView",id = "alertShareMainView",width =containerWidth,height = containerHeight,backgroundAlpha = 0.5,backgroundColor = "black"}
        local contentView = ui.view{id = "contentView",height = containerHeight*0.76,marginTop = containerHeight*0.12,width = containerWidth*0.86,marginLeft = containerWidth * 0.07,backgroundColor = "#f1f1f1"}
        alertShareMainView.onTouch = ""
        local imagePath = "images/share/Shut.png"
        local imageWidth,imageHeight = getImgWidthHeight(imagePath)
        contentView:addChild(ui.button{backgroundImage = imagePath,height = alertShareMainView.width*0.08,width = alertShareMainView.width*0.08,marginRight = 10,marginTop = 10,onclick = function ()
           container:removeChild(_G["alertShareMainView"])
        end})

        imagePath = params.imageFunc()
        local imageservice = registry.getService("image")
        local img = imageservice:load(imagePath)
        imageWidth,imageHeight = img:getSize()
        local picView = ui.view{width = containerWidth*0.4,height = containerWidth*0.4*imageHeight/imageWidth,marginLeft = (contentView.width - containerWidth*0.4)/2,marginTop = contentView.height*0.16,backgroundColor = "white"}
        picView:addChild(ui.view{backgroundColor = "#c8c8c8",height =picView.height - 6,width = picView.width - 6 ,marginTop = 3,marginLeft = 3})
        picView:addChild(ui.image{src = imagePath,height =picView.height - 8,width = picView.width - 8 , scale = "fill",marginTop = 4,marginLeft = 4})
        imagePath = "images/share/Input-box.png"
        imageWidth,imageHeight = getImgWidthHeight(imagePath)
        local inputBox = ui.view{backgroundImage = imagePath,width = contentView.width*0.9,marginTop = contentView.height*0.64,height = contentView.width*0.9*imageHeight/imageWidth,marginLeft = contentView.width*0.05,backgroundScale = "fill"}
        local inputText = ui.textarea{id = "inputText",width = inputBox.width*0.94,maxLength = 140,marginLeft = inputBox.width*0.03,height = inputBox.height*0.7,marginTop = inputBox.height *0.2 , color = "#444444",fontSize = 12,text = params.text
            ,onchange = function()
            local lastlen = 140 - string.ulen(inputText.text)
            if lastlen >=0 then
                 tipView.text = tostring(lastlen) .. "/140"
            else
              tipView.text = string.sub(tipView.text,1,140)
            end
        end,
        onblur = function()
            _G["contentView"].marginTop = containerHeight*0.12
        end,onfocus =function ()
            _G["contentView"].marginTop = -100
        end
            }
        inputBox:addChild(inputText)
        local len = 0
        local len = tonumber(inputText.maxLength) - string.ulen(params.text)
       inputBox:addChild(ui.label{text = tostring(len) .. "/140",id = "tipView",width = inputBox.width *0.3,height = inputBox.height*0.3,marginRight = inputBox.width * 0.05,marginBottom = 0,color = "#f6f6f6",fontSize = 10,align = "right"})
        
        imagePath = "images/share/button.png"
        imageWidth,imageHeight = getImgWidthHeight(imagePath)
        contentView:addChild(ui.button{backgroundImage = imagePath ,width = contentView.width*0.9,height = contentView.width*0.9*imageHeight/imageWidth,marginTop = contentView.height*0.873,backgroundScale = "fill",marginLeft = contentView.width*0.05,onclick = function ()
           local text = inputText.text
           if text == nil or text == "" then
                alert("分享主题不能为空！")
                return 
            end
            --log.debug("params...."..utils.objecttostring(params))
            params.text = inputText.text
            share(params)
            container:removeChild(_G["alertShareMainView"])
        end })
        contentView:addChild(inputBox)
        contentView:addChild(picView)
        alertShareMainView:addChild(contentView)
        container:addChild(alertShareMainView)

end

function hiddenBar()
    log.debug(LOG_TAG.."hiddenBar")
    local _root = _G["ebookRoot"]
    if _G["shareBackground"] then 
        _G["shareBackground"].hidden = true
    end
    _root:suspendLayout()
    _G["topToolBar"].marginTop = -44
    _G["bottomToolBar"].marginBottom = -155
    _root:resumeLayout(0.3)
end
