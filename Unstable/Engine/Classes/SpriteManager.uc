//=============================================================================
// SpriteManager. (NJS)
//=============================================================================
class SpriteManager expands InfoActor;

var () TextureCanvas DrawCanvas;	// Canvas to draw to.
var () float FrameRate;				// Frame rate to update sprite manager
var () name  PreFrameTrigger;		// Called before each frame is generated.
var () name  PostFrameTrigger;		// Called after each frame is generated.
var float LastTime;					// Internal - last time this sprite manager was updated.
var int CurrentSprite;				// The sprite I'm currently processing.

var () struct ESpriteRepresentation
{
	var () bool 	inUse;			// If this sprite is valid or not.

	var () bool	   	isVisible;		// Whether this sprite is visible or not.
	var () texture 	bmap; 			// Bitmap that this sprite uses.
	var () bool    	masking; 		// Whether this sprite is masking or not.
	var () bool	   	wrap;			// Whether this sprite will wrap or not.
	//var () bool     SpawnTemplate;	// If this is a spawn template (no logic until spawned)
	
} SpriteRepresentation[32];

var () struct ESprite
{
	var () byte		ObjectType;		// This object type (Should be 0-7 if object can collide)

	var () byte MinX, MaxX;
	var () byte MinY, MaxY;
	
	var () Vector2D position;		// Sprite's current position.
	var () Vector2D velocity;		// Sprite's current velocity.
	var () Vector2D acceleration;	// Sprite's current acceleration.
	
	//var () bool VarPositionWriteBack;	// Whether to write back to the position variables or not.
	//var () bool VarVelocityWriteBack;
	//var () bool VarAccelWriteBack;	

	var () name VarPositionX, VarPositionY;	
	var () name VarVelocityX, VarVelocityY;
	var () name VarAccelX,    VarAccelY;
} Sprites[32];

var () struct ESpriteCollision
{
	var () name CollisionEvent[8];	// Collision events called for each colliding object type
} SpriteCollision[32];



// Returns true if 2 sprites collide, false if not.
final function bool SpritesCollide( int x, int y, byte S1, byte S2 )
{
	// If I don't have a representation, just return.
	if(SpriteRepresentation[S1].bMap==none)
		return false;
	
	return SpriteRepresentation[S1].bMap.CollisionCheck( x, y, SpriteRepresentation[S2].bMap, Sprites[S2].position.x, Sprites[S2].position.y );
}

final function UpdateSprites(float DeltaTime)
{
	local int i, j;
	local Variable v;
	local int newX, newY;
	
	for(i=0;i<ArrayCount(Sprites);i++)
	{		
		if(SpriteRepresentation[i].inUse/*&&!SpriteRepresentation[i].SpawnTemplate*/)
		{
			CurrentSprite=i;	// Set the current sprite.

			// Get new starting position:
			newX=GetVariableValue(Sprites[i].VarPositionX,Sprites[i].position.X);
			newY=GetVariableValue(Sprites[i].VarPositionY,Sprites[i].position.Y);
		
			// Update Acceleration:
			Sprites[i].acceleration.x=GetVariableValue(Sprites[i].VarAccelX,Sprites[i].acceleration.X);
			Sprites[i].acceleration.y=GetVariableValue(Sprites[i].VarAccelY,Sprites[i].acceleration.Y);

			// Use new acceleration to compute new velocity:
			Sprites[i].velocity.x+=Sprites[i].acceleration.x*DeltaTime;
			Sprites[i].velocity.y+=Sprites[i].acceleration.y*DeltaTime;
			
			// Update Velocity:
			Sprites[i].velocity.x=GetVariableValue(Sprites[i].VarVelocityX,Sprites[i].velocity.X);
			Sprites[i].velocity.y=GetVariableValue(Sprites[i].VarVelocityY,Sprites[i].velocity.Y);

			// Update new position with velocity:
			newX=newX+Sprites[i].velocity.x*DeltaTime;
			newY=newY+Sprites[i].velocity.y*DeltaTime;

			// Restrict to my bounding rectangle (if I have one):
			if(bool(Sprites[i].MinX)||bool(Sprites[i].MaxX))	// Restrict X Axis.
			{
				if(newX<Sprites[i].MinX) 		newX=Sprites[i].MinX;
				else if(newX>Sprites[i].MaxX) 	newX=Sprites[i].MaxX;
			}		

			if(bool(Sprites[i].MinY)||bool(Sprites[i].MaxY))	// Restrict X Axis
			{
				if(newY<Sprites[i].MinY) 		newY=Sprites[i].MinY;
				else if(newY>Sprites[i].MaxY) 	newY=Sprites[i].MaxY;
			}		
			
			// Do collision detection:
			if(Sprites[i].ObjectType<8) // Am I a collideable sprite?
				for(j=0;j<ArrayCount(Sprites);j++)	// Check to see if I collide with any of my predecessors.
					if((j!=i)&&SpriteRepresentation[j].inUse&&(Sprites[j].ObjectType<8)) // Is this a collideable sprite?
						if(SpritesCollide(newX, newY, i,j))
						{
							// Do I acknowledge collisions with this guy?
							if(SpriteCollision[i].CollisionEvent[Sprites[j].ObjectType]!='')
							{
								GlobalTrigger(SpriteCollision[i].CollisionEvent[Sprites[j].ObjectType]);

								// Move myself back to my old position.
								newX=Sprites[i].position.X;
								newY=Sprites[i].position.Y;	
							}
							
							// If the other guy acknowledges collisions with me, splorp him.
							GlobalTrigger(SpriteCollision[j].CollisionEvent[Sprites[i].ObjectType]);
						}
						
			// Update my current position with the new position:
			Sprites[i].position.X=newX;
			Sprites[i].position.Y=newY;		
			
			// Write the position back.
			SetVariableValue(Sprites[i].VarPositionX,newX);
			SetVariableValue(Sprites[i].VarPositionY,newY);
		}
	}
}

final function DrawSprites(float DeltaTime)
{
	local int i;
	
	if(DrawCanvas==none) return;		// No valid draw canvas.
	
	// Draw each sprite in turn:
	for(i=0;i<ArrayCount(Sprites);i++)
		if(SpriteRepresentation[i].inUse&&SpriteRepresentation[i].isVisible&&(SpriteRepresentation[i].bMap!=none))	// Is the sprite in use and visible?
		{
			DrawCanvas.DrawBitmap(Sprites[i].position.X,Sprites[i].position.Y,0,0,0,0,SpriteRepresentation[i].bMap,SpriteRepresentation[i].masking,SpriteRepresentation[i].wrap);
		}
}

final function DrawFrame()
{
	local float DeltaTime;	
	
	GlobalTrigger(PreFrameTrigger);
	
	// Compute my delta time:
	if(LastTime!=0) DeltaTime=Level.TimeSeconds-LastTime;
	else 			DeltaTime=0.0001;
	
	// Update the state:
	UpdateSprites(DeltaTime);	// Update all sprites
	DrawSprites(DeltaTime);		// Draw all sprites

	LastTime=Level.TimeSeconds;	// Update the last time.
	
	GlobalTrigger(PostFrameTrigger);
}

// Unreal events:
function PostBeginPlay()
{
	super.PostBeginPlay();
	
	// If I have a frame rate, start the timer:
	if(FrameRate!=0)
		SetTimer(1.0/FrameRate,true);
}

function Timer(optional int TimerNum)
{
	DrawFrame();
}

function Trigger( actor Other, pawn EventInstigator )
{
	DrawFrame();
}

// SpriteManager specific events:
final function int SpawnSprite( int SpriteIndex, int x, int y )
{
	local int i;
	
	// Get the real sprite index:
	if((SpriteIndex<0)||(SpriteIndex>=ArrayCount(SpriteRepresentation)))
		SpriteIndex=CurrentSprite;

	// Find a free slot:
	for(i=0;i<ArrayCount(SpriteRepresentation);i++)
		if(!SpriteRepresentation[i].inUse)	// is this a free slot?
		{
			// Copy the sprite from the template:
			SpriteRepresentation[i]=SpriteRepresentation[SpriteIndex];
			Sprites[i]=Sprites[SpriteIndex];
			SpriteCollision[i]=SpriteCollision[SpriteIndex];

			SpriteRepresentation[i].isVisible=true;
			SpriteRepresentation[i].inUse=true;			

			// Set my x and y, and write the position back to the variables if nessecary:	
			Sprites[i].position.X=x;
			Sprites[i].position.Y=y;					
			SetVariableValue(Sprites[i].VarPositionX,x);
			SetVariableValue(Sprites[i].VarPositionY,y);

						
			return i;	// Return the sprite index
		}
	
	return -1;	// Return -1
}

final function DestroySprite( int SpriteIndex )
{
	// Get the real sprite index:
	if((SpriteIndex<0)||(SpriteIndex>=ArrayCount(SpriteRepresentation)))
		SpriteIndex=CurrentSprite;
				
	SpriteRepresentation[SpriteIndex].inUse=false; // Kill it:
}

final function SetVisibility( int SpriteIndex, int Value )
{
	// Get the real sprite index:
	if((SpriteIndex<0)||(SpriteIndex>=ArrayCount(SpriteRepresentation)))
		SpriteIndex=CurrentSprite;

	if(Value<0)	// If value is less than zero, then I should toggle my visibility.
	{
		if(SpriteRepresentation[SpriteIndex].isVisible)
			SpriteRepresentation[SpriteIndex].isVisible=false;
		else
			SpriteRepresentation[SpriteIndex].isVisible=true;
	} else	// Set my visibility
		SpriteRepresentation[SpriteIndex].isVisible=bool(Value);	
}

defaultproperties
{
     Sprites(0)=(ObjectType=255)
     Sprites(1)=(ObjectType=255)
     Sprites(2)=(ObjectType=255)
     Sprites(3)=(ObjectType=255)
     Sprites(4)=(ObjectType=255)
     Sprites(5)=(ObjectType=255)
     Sprites(6)=(ObjectType=255)
     Sprites(7)=(ObjectType=255)
     Sprites(8)=(ObjectType=255)
     Sprites(9)=(ObjectType=255)
     Sprites(10)=(ObjectType=255)
     Sprites(11)=(ObjectType=255)
     Sprites(12)=(ObjectType=255)
     Sprites(13)=(ObjectType=255)
     Sprites(14)=(ObjectType=255)
     Sprites(15)=(ObjectType=255)
     Sprites(16)=(ObjectType=255)
     Sprites(17)=(ObjectType=255)
     Sprites(18)=(ObjectType=255)
     Sprites(19)=(ObjectType=255)
     Sprites(20)=(ObjectType=255)
     Sprites(21)=(ObjectType=255)
     Sprites(22)=(ObjectType=255)
     Sprites(23)=(ObjectType=255)
     Sprites(24)=(ObjectType=255)
     Sprites(25)=(ObjectType=255)
     Sprites(26)=(ObjectType=255)
     Sprites(27)=(ObjectType=255)
     Sprites(28)=(ObjectType=255)
     Sprites(29)=(ObjectType=255)
     Sprites(30)=(ObjectType=255)
     Sprites(31)=(ObjectType=255)
}
