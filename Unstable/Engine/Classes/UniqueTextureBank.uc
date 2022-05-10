//=============================================================================
// UniqueTextureBank (NJS)
// Event is triggered when unique texture changes
//=============================================================================
class UniqueTextureBank expands Triggers;

var () struct ETextureTriggers
{	
	var () name TriggerTag;
	var () name SurfaceTag;
	var actor   TriggerActor;
} TextureTriggers[32];

var () texture UniqueTexture;
var () texture DefaultTexture;

function PostBeginPlay()
{
	local int i;
	super.PostBeginPlay();

	for(i=0;i<ArrayCount(TextureTriggers);i++)
		if(TextureTriggers[i].TriggerTag!='')
		{
			TextureTriggers[i].TriggerActor=Spawn(class'Engine.TriggerSelfForward',self);
			TextureTriggers[i].TriggerActor.Tag=TextureTriggers[i].TriggerTag;
		}
}

function Trigger(actor Other, Pawn EventInstigator)
{
	local int i,j;
	local int SurfaceIndex;

	for(i=0;i<ArrayCount(TextureTriggers);i++)
		if((TextureTriggers[i].TriggerTag!='')&&(TextureTriggers[i].TriggerActor!=none))
		{
			// Found the unique texture:
			SurfaceIndex=FindSurfaceByName( TextureTriggers[i].SurfaceTag);
			if(SurfaceIndex==-1) continue;	// Invalid surface

			if(Other==TextureTriggers[i].TriggerActor)
			{
				if(GetSurfaceTexture(SurfaceIndex)!=UniqueTexture)
				{
					SetSurfaceTexture(SurfaceIndex,UniqueTexture);
					GlobalTrigger(Event);
				}
			} else
				SetSurfaceTexture(SurfaceIndex,DefaultTexture);
		}
}