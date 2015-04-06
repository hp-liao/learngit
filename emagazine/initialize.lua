local sqlite3 = require "sqlite3"

--[[
The EOS framework will call this function,
when the mobility app has been successfully installed.
]]
function onInstalled()
    -- local path = sandbox:getDataPath() .. "/" .. "sqlite.db"
    -- local db = sqlite3.open(path)
    -- db:exec[=[
    --     CREATE TABLE magazine(id integer primary key,category text,name text,fullname text,thumbnailurl text,thumbnailurl2 text,magazineurl text,defaultlaunch text,auxlaunch text,isdownload integer default 0,needupdate integer default 0,status integer default 0,createdtime text, schema integer default 0);
    --     PRAGMA user_version = 3;
    -- ]=]
    -- db:close()
end

function upgradeSchema(db,fromVersion,toVersion,ddl)
    -- if fromVersion < toVersion then
    --     ddl = ddl .. ";" .. "PRAGMA user_version = " .. toVersion .. ";"
    --     local isSucceed = db:exec(ddl)
    --     if isSucceed == sqlite3.OK then
    --         print("succeed!")
    --     else
    --         print("failed!")
    --     end
    -- end
end

--[[
The EOS framework will call this function,
when the mobility app has been successfully patched.
]]
function onPatched(oldVersion)
 --    print("onpatch script running...")
 --    local current_version = 0
 --    local path = sandbox:getDataPath() .. "/" .. "sqlite.db"
 --    local db = sqlite3.open(path)
 --    local sql = "PRAGMA user_version"
 --    local stmt = db:prepare(sql)
 --    for row in stmt:rows() do
 --        if row then
 --            current_version = row[1]
 --            print(current_version) -- the user version for current sqlite
 --        end
 --    end
 --    stmt:step()
 --    stmt:finalize()
    
 --    upgradeSchema(db,current_version,2,[=[
 --        ALTER TABLE magazine add fullname text;
 --        UPDATE TABLE magazine set fullname = name
 --        ]=])
	
	-- upgradeSchema(db,current_version,3,[=[
	--     ALTER TABLE magazine add schema integer default 0;
	--     ]=])
	
	
 --    db:close()
    --onInstalled()
end
