
local ECS = ECS

function ECS.AddCommand( self, name, param, func )
    self.Commands[name] = { plugin = self.Plugin, func = SERVER and func or nil, autocomplete = string.format( "ecs %s %s", name, param ) }
    return self.Commands[name]
end


if SERVER then

    --[[

        COMMANDS

    ]]

    util.AddNetworkString( "ecs_command" )

    function ECS.HandleInvalidCommand( ply, name )

    end

    function ECS.HandleCommand( ply, name, args )

        ECS.Commands[name].func( ply, ply:GetEyeTraceNoCursor(), args )

    end

    net.Receive( "ecs_command", function( len, ply )
        local name = net.ReadString()

        if not ECS.Commands[name] or not isfunction( ECS.Commands[name].func ) then
            return ECS.HandleInvalidCommand( ply, name )
        end

        ECS.HandleCommand( ply, name, net.ReadTable() )
    end )


    --[[

        SELECTION

    ]]

    local SELECT_COL = Color( 0, 255, 255, 255 )
    local SELECT_MAT = "hunter/myplastic"

    ECS.EntityIgnore = {}

    function ECS.CanSelect( ply, ent )
        if not IsValid( ent ) or ent:IsWorld() or ent:IsPlayer() then return end
        if ECS.EntityIgnore[ ent:GetClass() ] then return end
        return gamemode.Call( "CanProperty", ply, "entitycommandsuite", ent )
    end

    function ECS.CanTool( ply, ent, mode )
        if not IsValid( ent ) or ent:IsWorld() or ent:IsPlayer() then return end
        if ECS.EntityIgnore[ ent:GetClass() ] then return end
        return gamemode.Call( "CanTool", ply, { Entity = ent }, mode )
    end

    function ECS.Filter( ply, ents )
        local t = {}

        for k, v in pairs( ents ) do
            if ECS.CanSelect( ply, v ) then
                t[v] = true
            end
        end

        return t
    end

    function ECS.SelectEntity( ply, ent )
        if not IsValid( ply ) or not IsValid( ent ) then
            return
        end

        if not ECS.Selections[ply] then
            ECS.Selections[ply] = {}
        end

        if ECS.Selections[ply][ent] then
            return
        end

        ECS.Selections[ply][ent] = { Color = ent:GetColor(), Material = ent:GetMaterial(), Mode = ent:GetRenderMode() }

        ent:SetColor( SELECT_COL )
        ent:SetMaterial( SELECT_MAT )
    end

    function ECS.DeselectEntity( ply, ent )
        if ECS.Selections[ply] and IsValid( ent ) and ECS.Selections[ply][ent] then
            local data = ECS.Selections[ply][ent]

            ent:SetColor( data.Color )
            ent:SetMaterial( data.Material )
            ent:SetRenderMode( data.Mode )
        end

        ECS.Selections[ply][ent] = nil
    end

    function ECS.GetSelection( ply )
        if not ECS.Selections[ply] then
            ECS.Selections[ply] = {}
        end

        return ECS.Selections[ply]
    end

else

    --[[

        COMMANDS

    ]]

    ECS.Commands.getinfo = { plugin = "debug", autocomplete = "ecs getinfo", clientFunc = function( ply, trace, params )
        local ent = trace.Entity

        local yel = Color( 255, 255, 0 )
        local wht = Color( 255, 255, 255 )

        MsgC( yel, "ent:      ", wht, ent, "\n" )
        MsgC( yel, "pos:      ", wht, ent:GetPos(), "\n" )
        MsgC( yel, "ang:      ", wht, ent:GetAngles(), "\n" )
        MsgC( yel, "material: ", wht, ent:GetMaterial(), "\n" )
        MsgC( yel, "color:    ", wht, tostring( ent:GetColor() ), "\n" )
        MsgC( yel, "model:    ", wht, ent:GetModel(), "\n\n" )
    end }

    local function Send( ply, cmd, args )
        local name = table.remove( args, 1 )

        if not ECS.Commands[name] then
            return
        end

        if ECS.Commands[name].clientFunc then
            ECS.Commands[name].clientFunc( ply, ply:GetEyeTraceNoCursor(), args )
            return
        end

        net.Start( "ecs_command" )
        net.WriteString( name )
        net.WriteTable( args )
        net.SendToServer()
    end

    local function Auto( cmd, stringargs )
        local tbl = {}
        local sub = string.Trim( string.lower( stringargs ) )

        for k, v in pairs( ECS.Commands ) do
            if string.StartWith( k, sub ) then
                table.insert( tbl, v.autocomplete)
            end
        end

        table.sort( tbl )

        return tbl
    end

    concommand.Add( "ecs", Send, Auto )

end
