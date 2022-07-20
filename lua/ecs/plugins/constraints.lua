
ECS.Plugin = "constraints"


--
ECS:AddCommand( "weld", "nocollide forcelimit", function( ply, trace, params )
    local ent = trace.Entity

    if not ECS.CanTool( ply, ent, "weld" ) then
        return
    end

    local forcelimit = tonumber( params[1] ) or 0
    local nocollide = tobool( params[2] )

    for sel in pairs( ECS.GetSelection( ply ) ) do
        if ent ~= sel and ECS.CanTool( ply, sel, "weld" ) then
            constraint.Weld( ent, sel, 0, 0, forcelimit, nocollide )
        end
    end
end )


--
ECS:AddCommand( "nocollide", "", function( ply, trace, params )
    local ent = trace.Entity

    if not ECS.CanTool( ply, ent, "nocollide" ) then
        return
    end

    for sel in pairs( ECS.GetSelection( ply ) ) do
        if ent ~= sel and ECS.CanTool( ply, sel, "nocollide" ) then
            constraint.NoCollide( ent, sel, 0, 0 )
        end
    end
end )


--
local alias = {
    weld = "Weld",
    axis = "Axis",
    advballsocket = "AdvBallsocket",
    rope = "Rope",
    elastic = "Elastic",
    nocollide = "NoCollide",
    motor = "Motor",
    pulley = "Pulley",
    ballsocket = "Ballsocket",
    winch = "Winch",
    hydraulic = "Hydraulic",
    muscle = "Muscle",
    keepupright = "Keepupright",
    slider = "Slider",
}

ECS:AddCommand( "removeconstraints", "type", function( ply, trace, params )
    local type = string.lower( params[1] )
    local func

    if type == nil or type == "" or type == "all" then
        func = constraint.RemoveAll
    else
        if alias[type] then type = alias[type] end
        func = constraint.RemoveConstraints
    end

    local ents = ECS.GetSelection( ply )

    if next( ents ) == nil then
        if ECS.CanSelect( ply, trace.Entity ) then
            func( trace.Entity, type )
        end

        return
    end

    for sel in pairs( ents ) do
        func( sel, type )
    end
end )



