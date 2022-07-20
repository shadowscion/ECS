
--
ECS = { Selections = {}, Commands = {} }

if SERVER then
    AddCSLuaFile( "ecs/core.lua" )
end

include( "ecs/core.lua" )

local function load( path, realm )
    local files, folders = file.Find( path .. "*.lua", "LUA" )

    for _, file in pairs( files ) do
        file = path .. file

        if SERVER then
            AddCSLuaFile( file )
        end

        if realm then
            include( file )
        end
    end
end

load( "ecs/plugins/", true )
