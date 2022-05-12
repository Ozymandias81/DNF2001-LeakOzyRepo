class ClientScriptedTexture expands Info;

var() Texture ScriptedTexture;

simulated function BeginPlay()
{
	if(ScriptedTexture != None)
		ScriptedTexture(ScriptedTexture).NotifyActor = Self;
}

simulated function Destroyed()
{
	if(ScriptedTexture != None)
		ScriptedTexture(ScriptedTexture).NotifyActor = None;
}

simulated event RenderTexture(ScriptedTexture Tex)
{
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	bStatic=False
	bAlwaysRelevant=True
	bNoDelete=True
}