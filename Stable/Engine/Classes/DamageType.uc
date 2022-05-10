/*-----------------------------------------------------------------------------
	DamageType
	Author: Brandon Reinhart

	DamageTypes are never instantiated.  They are used as statics only.
-----------------------------------------------------------------------------*/
class DamageType extends InfoActor
	native
	abstract;

var bool				bGibDamage;
var bool				bBloodEffect;
var localized string	DamageName;
var localized string    DeathMessage;
var float				FlashScale;
var vector				FlashFog;
var float				gibChance;
var bool				bFlyCarcass;
var bool				bShieldBlocks;
var bool                bBloodPool;
var Texture				Icon;

defaultproperties
{
	DeathMessage="%o was killed by %k's %w"
	gibChance=1.0
	FlashScale=-0.019
	FlashFog=(X=20.500000,Y=0.500000,Z=0.500000)
	bShieldBlocks=true
}
