class TrophyGame extends UTIntro;

var Class<Trophy> NewTrophyClass;
var int TrophyTime;
var rotator CorrectRotation;

event playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<playerpawn> SpawnClass
)
{
	local PlayerPawn NewPlayer;
	local SpectatorCam Cam;
	local TrophyDude TD;
	local int i;

	NewPlayer = Super.Login(Portal, Options, Error, SpawnClass);
	NewPlayer.bHidden = True;

	foreach AllActors(class'SpectatorCam', Cam) 
		NewPlayer.ViewTarget = Cam;

	foreach AllActors(class'TrophyDude', TD)
	{
		TD.Mesh = Mesh(DynamicLoadObject(SpawnClass.Default.SpecialMesh, class'Mesh'));
		for (i=0; i<8; i++)
			TD.MultiSkins[i] = NewPlayer.MultiSkins[i];
	}

	return NewPlayer;
}

function AcceptInventory(pawn PlayerPawn)
{
	local inventory Inv, Next;
	local LadderInventory LadderObj;
	local DeathMatchTrophy DMT;
	local DominationTrophy DOMT;
	local CTFTrophy CTFT;
	local AssaultTrophy AT;
	local Challenge ChalT;

	// DeathMatchPlus accepts LadderInventory
	for( Inv=PlayerPawn.Inventory; Inv!=None; Inv=Next )
	{
		Next = Inv.Inventory;
		if (Inv.IsA('LadderInventory'))
		{
			LadderObj = LadderInventory(Inv);
			if (LadderObj != None) 
			{
				// Hide trophies.
				foreach AllActors(class'DeathMatchTrophy', DMT)
				{
					CorrectRotation = DMT.Rotation;
					if (LadderObj.DMRank != 6)
					{
						DMT.bHidden = True;
					} else {
						if (LadderObj.LastMatchType == 1)
						{
							NewTrophyClass = DMT.Class;
							TrophyTime = 28;
							DMT.bHidden = True;
						}
					}
				}
				foreach AllActors(class'DominationTrophy', DOMT)
				{
					if (LadderObj.DOMRank != 6)
					{
						DOMT.bHidden = True;
					} else {
						if (LadderObj.LastMatchType == 3)
						{
							NewTrophyClass = DOMT.Class;
							TrophyTime = 30;
							DOMT.bHidden = True;
						}
					}
				}
				foreach AllActors(class'CTFTrophy', CTFT)
				{
					if (LadderObj.CTFRank != 6)
					{
						CTFT.bHidden = True;
					} else {
						if (LadderObj.LastMatchType == 2)
						{
							NewTrophyClass = CTFT.Class;
							TrophyTime = 30;
							CTFT.bHidden = True;
						}
					}
				}
				foreach AllActors(class'AssaultTrophy', AT)
				{
					if (LadderObj.ASRank != 6)
					{
						AT.bHidden = True;
					} else {
						if (LadderObj.LastMatchType == 4)
						{
							NewTrophyClass = AT.Class;
							TrophyTime = 29;
							AT.bHidden = True;
						}
					}
				}
				foreach AllActors(class'Challenge', ChalT)
				{
					if (LadderObj.ChalRank != 6)
					{
						ChalT.bHidden = True;
					} else {
						if (LadderObj.LastMatchType == 5)
						{
							NewTrophyClass = ChalT.Class;
							TrophyTime = 30;
							ChalT.bHidden = True;
						}
					}
				}
				// Award this dude the SECRET ROBOT BOSS MESH!!!
				if ((LadderObj.DMRank == 6) && (LadderObj.DOMRank == 6) &&
					(LadderObj.CTFRank == 6) && (LadderObj.ASRank == 6) &&
					(LadderObj.ChalRank == 6))
				{
					class'Ladder'.Default.HasBeatenGame = True;
					class'Ladder'.Static.StaticSaveConfig();
				}
			}
		} else {	
			Inv.Destroy();
		}
	}
	PlayerPawn.Weapon = None;
	PlayerPawn.SelectedItem = None;
}

function Timer()
{
	local Trophy T;

	Super.Timer();

	Log(Level.TimeSeconds);
	if (TrophyTime >= 0)
		TrophyTime--;
	if (NewTrophyClass != None)
	{
		if (TrophyTime == 0)
		{
			foreach AllActors(class'Trophy', T)
			{
				if (NewTrophyClass == T.Class)
				{
					PlayTrophyEffect(T);
					T.bHidden = False;
				}
			}
		}
	}
}

function PlayTrophyEffect(Trophy NewTrophy)
{
	Spawn(class'UTTeleportEffect',,, NewTrophy.Location, CorrectRotation);
	NewTrophy.PlaySound(sound'Resp2A',, 10.0);
}


defaultproperties
{
     HUDType=class'Botpack.CHEOLHUD'
}
