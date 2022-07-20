
ECS.Plugin = "constraints"


ECS:AddCommand( "weld", "nocollide forcelimit", function( ply, trace, params )
    local ent = trace.Entity

    if not ECS.CanTool( ply, ent, "weld" ) then
        return
    end

    local forcelimit = tonumber( params[1] ) or 0
    local nocollide = tobool( params[2] )

    for sel in pairs( ECS.GetSelection( ply ) ) do
        if ent ~= sel then
            constraint.Weld( ent, sel, 0, 0, forcelimit, nocollide )
        end
    end
end )
