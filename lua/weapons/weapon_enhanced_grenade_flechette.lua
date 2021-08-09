if ( !IsMounted( "ep2" ) ) then return end

AddCSLuaFile()

SWEP.Base               = "weapon_enhanced_grenade_base"
SWEP.PrintName			= "Flechette Grenade" -- This will be shown in the spawn menu, and in the weapon selection menu
SWEP.Instructions       = "Pull Pin, Aim, Throw -> Fires unguided flechettes"
SWEP.Category           = "Enhanced Grenades"
SWEP.Spawnable          = true
SWEP.GrenadeEntity      = "ent_enhanced_grenade_flechette"
SWEP.Primary.Ammo	    = "flechette_grenade"

hook.Add("Initialize", "expanded_grenade_flechette_ammo", function()
    game.AddAmmoType( {
	    name = "flechette_grenade",
    } )
end)
