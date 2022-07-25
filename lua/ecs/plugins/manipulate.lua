
ECS.Plugin = "manipulate"


--
local function setNotFrozen( ent, f )
    local phys = ent:GetPhysicsObject()

    if phys:IsValid() then
        if phys:IsMoveable() then
            phys:Sleep()
        else
            phys:Wake()
        end

        phys:EnableMotion( f )
    end
end

local function move( ent, vec, isLocal )
    local pos
    if isLocal then
        pos = ent:LocalToWorld( vec )
    else
        pos = ent:GetPos() + vec
    end

    setNotFrozen( ent, false )
    ent:SetPos( vec )
end

local function rotate( ent, ang )
    local rot
    if isLocal then
        rot = ent:LocalToWorldAngles( ang )
    else
        rot = ent:GetAngles() + ang
    end

    setNotFrozen( ent, false )
    ent:SetAngles( rot )
end

local function removeEntity( ent )
    constraint.RemoveAll( ent )

    timer.Simple( 1, function() if ( IsValid( ent ) ) then ent:Remove() end end )

    ent:SetNotSolid( true )
    ent:SetMoveType( MOVETYPE_NONE )
    ent:SetNoDraw( true )

    local ed = EffectData()
    ed:SetOrigin( ent:GetPos() )
    ed:SetEntity( ent )

    util.Effect( "entity_remove", ed, true, true )
end


--
ECS:AddCommand( "remove", "", function( ply, trace, params )
    local ents = ECS.GetSelection( ply )

    if next( ents ) == nil then
        if ECS.CanTool( ply, ent, "remover" ) then
            removeEntity( trace.Entity )
        end

        return
    end

    for sel in pairs( ents ) do
        if ECS.CanTool( ply, sel, "remover" ) then
            removeEntity( sel )
        end
    end
end )


--
ECS:AddCommand( "setang", "p y r", function( ply, trace, params )
    local p = math.Clamp( tonumber( params[1] ) or 0, -50000, 50000 )
    local y = math.Clamp( tonumber( params[2] ) or 0, -50000, 50000 )
    local r = math.Clamp( tonumber( params[3] ) or 0, -50000, 50000 )

    local ang = Angle( p, y, r )
    ang:Normalize()

    local ents = ECS.GetSelection( ply )

    if next( ents ) == nil then
        if ECS.CanSelect( ply, trace.Entity ) then
            setNotFrozen( trace.Entity, false )
            trace.Entity:SetAngles( ang )
        end

        return
    end

    for sel in pairs( ents ) do
        setNotFrozen( sel, false )
        sel:SetAngles( ang )
    end
end )


--
ECS:AddCommand( "rotate", "p y r local", function( ply, trace, params )
    local p = math.Clamp( tonumber( params[1] ) or 0, -50000, 50000 )
    local y = math.Clamp( tonumber( params[2] ) or 0, -50000, 50000 )
    local r = math.Clamp( tonumber( params[3] ) or 0, -50000, 50000 )

    local ang = Angle( p, y, r )
    ang:Normalize()

    local isLocal = tobool( params[4] )

    local ents = ECS.GetSelection( ply )

    if next( ents ) == nil then
        if ECS.CanSelect( ply, trace.Entity ) then
            rotate( trace.Entity, ang, isLocal )
        end

        return
    end

    for sel in pairs( ents ) do
        rotate( sel, ang, isLocal )
    end
end )


--
ECS:AddCommand( "move", "x y z local", function( ply, trace, params )
    local x = math.Clamp( tonumber( params[1] ) or 0, -1000, 1000 )
    local y = math.Clamp( tonumber( params[2] ) or 0, -1000, 1000 )
    local z = math.Clamp( tonumber( params[3] ) or 0, -1000, 1000 )

    local vec = Vector( x, y, z )
    local isLocal = tobool( params[4] )

    local ents = ECS.GetSelection( ply )

    if next( ents ) == nil then
        if ECS.CanSelect( ply, trace.Entity ) then
            move( trace.Entity, vec, isLocal )
        end

        return
    end

    for sel in pairs( ents ) do
        move( sel, vec, isLocal )
    end
end )


--
ECS:AddCommand( "freeze", "", function( ply, trace, params )
    local ents = ECS.GetSelection( ply )

    if next( ents ) == nil then
        if ECS.CanSelect( ply, trace.Entity ) then
            setNotFrozen( trace.Entity, false )
        end

        return
    end

    for sel in pairs( ents ) do
        setNotFrozen( sel, false )
    end
end )


--
ECS:AddCommand( "unfreeze", "", function( ply, trace, params )
    local ents = ECS.GetSelection( ply )

    if next( ents ) == nil then
        if ECS.CanSelect( ply, trace.Entity ) then
            setNotFrozen( trace.Entity, true )
        end

        return
    end

    for sel in pairs( ents ) do
        setNotFrozen( sel, true )
    end
end )
