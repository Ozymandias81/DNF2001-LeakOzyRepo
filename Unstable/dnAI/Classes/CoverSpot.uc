class CoverSpot extends Info;

#exec OBJ LOAD FILE=..\Textures\DukeED_Gfx.dtx

var() bool	bStrafeCover			?( "Pawn can strafe out (sidestep or roll) from this CoverSpot." );
var() bool	bIgnoreCantSee			?( "Pawn will ignore EnemyNotVisible notifications when at this CoverSpot." );
var() float	MaxCampTime				?( "Max duration (in seconds) this Pawn will wait before hunting." );
var() name	NextLogicalSpotTag		?( "Forces the Grunt to choose a CoverSpot matching this tag as his next spot." );
var() bool  bMustSeeEnemyFrom		?( "Grunt must be capable of seeing the enemy from this CoverSpot before it is chosen." );

var bool bOccupied;
var Pawn OccupiedBy;


DefaultProperties
{
	CollisionHeight=1.000000
	CollisionRadius=1.000000
    Texture=Texture'DukeED_Gfx.CoverSpot'
    bDirectional=true
    bMustSeeEnemyFrom=true
}
