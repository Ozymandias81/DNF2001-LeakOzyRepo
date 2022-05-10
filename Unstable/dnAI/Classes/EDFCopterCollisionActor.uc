class EDFCopterCollisionActor extends RenderActor;

function TakeDamage( int Damage, Pawn instigatedBy, vector HitLocation, vector momentum, class<DamageType> damageType )
{
	Health -= Damage;
	//EDFHoverCopter( Owner ).ProcessDamage( self );
	Pawn( Owner ).TakeDamage( Damage, instigatedBy, HitLocation, momentum, damageType );
}

DefaultProperties
{
    Health=100
	bCollideActors=true
	bCollideWorld=true
	bBlockPlayers=true
	bBlockActors=false
    bProjTarget=true
	CollisionRadius=120
	CollisionHeight=65
    bHidden=false
}
