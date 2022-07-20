
ECS.Plugin = "selection"


--
ECS:AddCommand( "select", "", function( ply, trace, params )
    if ECS.CanTool( ply, trace.Entity ) then
        ECS.SelectEntity( ply, trace.Entity )
    end
end )


--
ECS:AddCommand( "selectsphere", "radius", function( ply, trace, params )
    local radius = tonumber( params[1] ) or 0
    local ents = ECS.Filter( ply, ents.FindInSphere( trace.HitPos, radius ) )

    for ent in pairs( ents ) do
        ECS.SelectEntity( ply, ent )
    end
end )


--
ECS:AddCommand( "deselect", "", function( ply, trace, params )
    ECS.DeselectEntity( ply, trace.Entity )
end )


--
ECS:AddCommand( "deselectall", "", function( ply, trace, params )
    for ent in pairs( ECS.GetSelection( ply ) ) do
        ECS.DeselectEntity( ply, ent )
    end
end )


--
ECS:AddCommand( "deselectsphere", "radius", function( ply, trace, params )
    local radius = tonumber( params[1] ) or 0
    local ents = ECS.Filter( ply, ents.FindInSphere( trace.HitPos, radius ) )

    for ent in pairs( ents ) do
        ECS.DeselectEntity( ply, ent )
    end
end )

