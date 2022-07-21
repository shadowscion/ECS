
ECS.Plugin = "properties"

--[[
    model
    drag
    shadow
]]

--
ECS:AddCommand( "setphysprop", "material", function( ply, trace, params )
    local mat = params[1]

    local ents = ECS.GetSelection( ply )

    if next( ents ) == nil then
        local ent = trace.Entity

        if ECS.CanTool( ply, ent, "physprop" ) then
            local phys = ent:GetPhysicsObject()

            if IsValid( phys ) then
                construct.SetPhysProp( ply, ent, 0, nil, { GravityToggle = phys:IsGravityEnabled(), Material = mat } )
            end
        end

        return
    end

    for sel, data in pairs( ents ) do
        if ECS.CanTool( ply, sel, "physprop" ) then
            local phys = sel:GetPhysicsObject()

            if IsValid( phys ) then
                construct.SetPhysProp( ply, sel, 0, nil, { GravityToggle = phys:IsGravityEnabled(), Material = mat } )
            end
        end
    end
end )


--
ECS:AddCommand( "setgravity", "enabled", function( ply, trace, params )
    local grav = tobool( params[1] )

    local ents = ECS.GetSelection( ply )

    if next( ents ) == nil then
        local ent = trace.Entity

        if ECS.CanTool( ply, ent, "physprop" ) then
            local phys = ent:GetPhysicsObject()

            if IsValid( phys ) then
                construct.SetPhysProp( ply, ent, 0, nil, { GravityToggle = grav, Material = phys:GetMaterial() } )
            end
        end

        return
    end

    for sel, data in pairs( ents ) do
        if ECS.CanTool( ply, sel, "physprop" ) then
            local phys = sel:GetPhysicsObject()

            if IsValid( phys ) then
                construct.SetPhysProp( ply, sel, 0, nil, { GravityToggle = grav, Material = phys:GetMaterial() } )
            end
        end
    end
end )


--
ECS:AddCommand( "setmass", "mass", function( ply, trace, params )
    local mass = math.Clamp( tonumber( params[1] ) or 0.1, 0.1, 50000 )

    local ents = ECS.GetSelection( ply )

    if next( ents ) == nil then
        local ent = trace.Entity

        if ECS.CanTool( ply, ent, "weight" ) then
            local phys = ent:GetPhysicsObject()

            if IsValid( phys ) then
                phys:SetMass( mass )
                duplicator.StoreEntityModifier( ent, "mass", { Mass = mass } )
            end
        end

        return
    end

    for sel, data in pairs( ents ) do
        if ECS.CanTool( ply, sel, "weight" ) then
            local phys = sel:GetPhysicsObject()

            if IsValid( phys ) then
                phys:SetMass( mass )
                duplicator.StoreEntityModifier( sel, "mass", { Mass = mass } )
            end
        end
    end
end )


--
ECS:AddCommand( "setmaterial", "material", function( ply, trace, params )
    local mat = params[1]

    if not game.SinglePlayer() and not list.Contains( "OverrideMaterials", mat ) and mat ~= "" then
        return
    end

    local ents = ECS.GetSelection( ply )

    if next( ents ) == nil then
        local ent = trace.Entity

        if ECS.CanTool( ply, ent, "material" ) then
            ent:SetMaterial( mat )
            duplicator.StoreEntityModifier( ent, "material", { MaterialOverride = mat } )
        end

        return
    end

    for sel, data in pairs( ents ) do
        if ECS.CanTool( ply, sel, "material" ) then
            data.Material = mat
            duplicator.StoreEntityModifier( sel, "material", { MaterialOverride = mat } )
        end
    end
end )


--
ECS:AddCommand( "setcolor", "r g b a", function( ply, trace, params )
    local color = Color(
        tonumber( params[1] ) or 255,
        tonumber( params[2] ) or 255,
        tonumber( params[3] ) or 255,
        tonumber( params[4] ) or 255
    )

    local mode = color.a < 255 and RENDERMODE_TRANSCOLOR or RENDERMODE_NORMAL

    local ents = ECS.GetSelection( ply )

    if next( ents ) == nil then
        local ent = trace.Entity

        if ECS.CanTool( ply, ent, "colour" ) then
            ent:SetColor( color )
            ent:SetRenderMode( mode )
            duplicator.StoreEntityModifier( ent, "colour", { Color = color, RenderMode = mode } )
        end

        return
    end

    for sel, data in pairs( ents ) do
        if ECS.CanTool( ply, sel, "colour" ) then
            data.Color = color
            data.Mode = mode
            duplicator.StoreEntityModifier( sel, "colour", { Color = color, RenderMode = mode } )
        end
    end
end )


--
ECS:AddCommand( "setalpha", "a", function( ply, trace, params )
    local alpha = tonumber( params[1] ) or 255

    local mode = alpha < 255 and RENDERMODE_TRANSCOLOR or RENDERMODE_NORMAL

    local ents = ECS.GetSelection( ply )

    if next( ents ) == nil then
        local ent = trace.Entity

        if ECS.CanTool( ply, ent, "colour" ) then
            local color = ent:GetColor()
            color.a = alpha

            ent:SetColor( color )
            ent:SetRenderMode( mode )
            duplicator.StoreEntityModifier( ent, "colour", { Color = color, RenderMode = mode } )
        end

        return
    end

    for sel, data in pairs( ents ) do
        if ECS.CanTool( ply, sel, "colour" ) then
            data.Color.a = alpha
            data.Mode = mode
            duplicator.StoreEntityModifier( sel, "colour", { Color = data.Color, RenderMode = mode } )
        end
    end
end )


--
ECS:AddCommand( "nocollideall", "remove", function( ply, trace, params )
    local cg = tobool( params[1] ) and COLLISION_GROUP_NONE or COLLISION_GROUP_WORLD
    local ents = ECS.GetSelection( ply )

    if next( ents ) == nil then
        local ent = trace.Entity

        if ECS.CanTool( ply, ent, "nocollide" ) then
            ent:SetCollisionGroup( cg )
        end

        return
    end

    for sel in pairs( ents ) do
        if ECS.CanTool( ply, sel, "nocollide" ) then
            sel:SetCollisionGroup( cg )
        end
    end
end )


--
local function ParentCheck( child, parent )
    while IsValid( parent ) do
        if child == parent then
            return false
        end
        parent = parent:GetParent()
    end
    return true
end

ECS:AddCommand( "parent", "removeconstraints", function( ply, trace, params )
    local ent = trace.Entity

    if not ECS.CanTool( ply, ent, "multi_parent" ) then
        return
    end

    local rc = tobool( params[1] )

    for sel in pairs( ECS.GetSelection( ply ) ) do
        if not ECS.CanTool( ply, sel, "multi_parent" ) or not ParentCheck( sel, ent ) then
            goto CONTINUE
        end

        local phys = sel:GetPhysicsObject()

        if IsValid( phys ) then
            if rc then
                constraint.RemoveAll( sel )
            end

            phys:EnableMotion( true )
            phys:Sleep()

            sel:SetParent( ent )
        end

        ::CONTINUE::
    end
end )


--
local function ParentRemove( ent )
    if not IsValid( ent:GetParent() ) then
        return
    end

    local pos, ang = ent:GetPos(), ent:GetAngles()

    local phys = ent:GetPhysicsObject()
    if IsValid( phys ) then
        phys:EnableMotion( false )
    end

    ent:SetParent( nil )
    ent:SetAngles( ang )
    ent:SetPos( pos )
end

ECS:AddCommand( "unparent", "", function( ply, trace, params )
    local ents = ECS.GetSelection( ply )

    if next( ents ) == nil then
        local ent = trace.Entity

        if ECS.CanTool( ply, ent, "multi_unparent" ) then
            ParentRemove( ent )
        end

        return
    end

    for sel in pairs( ents ) do
        if ECS.CanTool( ply, sel, "multi_unparent" ) then
            ParentRemove( sel )
        end
    end
end )
