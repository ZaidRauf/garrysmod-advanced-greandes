AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self.incendiaryTime = 4.5
    self.timeToLive = 20
    
    self:SetModel("models/weapons/w_npcnade.mdl")
    self:SetSubMaterial(0, self.WorldMaterial)

    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    self.isRunning = false
    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:Wake()
    end

    util.SpriteTrail(self, 0, self.GrenadeColor, false, 1.25, 0, 0.35, 1/1.25 * 0.5, "trails/laser.vmt")

    self:EmitSound( self.TickSound )
    timer.Create("soundTickTimer"..self:EntIndex(), 0.4, 0, function()
        self:EmitSound( self.TickSound )
    end)

    timer.Create("incendiaryStartTimer"..self:GetName()..self:EntIndex(), self.incendiaryTime, 1, function() 
        timer.Remove("soundTickTimer"..self:EntIndex())
        self:StopSound(self.TickSound)

        self:EmitSound( self.ThermiteSound )
        timer.Create("soundThermiteTimer"..self:EntIndex(), SoundDuration(self.ThermiteSound), 0, function() 
            self:EmitSound( self.ThermiteSound )
        end)

        self:SetIncendiaryActive(true)
    end)

    timer.Create("explodeTimer"..self:GetName()..self:EntIndex(), self.timeToLive, 1, function() 
        self:StopSound(self.ThermiteSound)
        timer.Remove("soundThermiteTimer"..self:EntIndex())
        self:Remove()
    end)
 
end

function ENT:Use(activator, caller, useType, value)
    if activator:IsValid() and activator:IsPlayer() then
        activator:PickupObject(self)
    end
end

function ENT:Think()
    if self:GetIncendiaryActive() then
        for k,v in pairs(ents.FindInSphere(self:GetPos(), 125)) do
            if v:IsPlayer() or v:IsNPC() or v:IsNextBot() or v:IsVehicle() or v:IsRagdoll() or v:GetClass() == "prop_physics" then
                v:Ignite(4)
                v:SetHealth(v:Health() - 1)
            end
        end
    end
end

function ENT:OnRemove()
    self:StopSound(self.ThermiteSound)
	local explosion = ents.Create( "env_explosion" ) -- The explosion entity
	if ( not explosion:IsValid() ) then return end
    
    explosion:SetPos( self:GetPos() ) -- Put the position of the explosion at the position of the entity
	explosion:Spawn() -- Spawn the explosion
	explosion:SetKeyValue( "iMagnitude", "25" ) -- the magnitude of the explosion
	explosion:Fire( "Explode", 0, 0 ) -- explode
end

function ENT:PhysicsCollide(colData, collider)    
    if colData.Speed > 300 then
        local soundNumber = math.random(3)
        local volumeCalc = math.min(1, colData.Speed / 500)
        self:EmitSound(Sound("physics/metal/metal_grenade_impact_hard"..soundNumber..".wav"), 75, 100, volumeCalc)
    end
end