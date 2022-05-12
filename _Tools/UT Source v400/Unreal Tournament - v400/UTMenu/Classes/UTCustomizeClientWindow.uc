class UTCustomizeClientWindow expands UMenuCustomizeClientWindow;

var int VoiceKeyNumber;
var int ConsoleKeyNumber;

function WindowShown()
{
	Super.WindowShown();
	Root.bAllowConsole = False;
}

function WindowHidden()
{
	Super.WindowHidden();
	Root.bAllowConsole = True;
}

function LoadExistingKeys()
{
	Super.LoadExistingKeys();

	if(Root.Console.IsA('UTConsole'))
		BoundKey1[VoiceKeyNumber] = UTConsole(Root.Console).SpeechKey;

	BoundKey1[ConsoleKeyNumber] = Root.Console.ConsoleKey;
}

function SetKey(int KeyNo, string KeyName)
{
	if(Selection == VoiceKeyNumber)
	{
		if(KeyNo != 1 && KeyNo != 27 && Root.Console.IsA('UTConsole'))
		{
			UTConsole(Root.Console).SpeechKey = KeyNo;
			Root.Console.SaveConfig();

			BoundKey1[Selection] = KeyNo;
			BoundKey2[Selection] = 0;
		}
	}
	else
	if(Selection == ConsoleKeyNumber)
	{
		if(KeyNo != 1 && KeyNo != 27) // LeftMouse, Escape
		{
			Root.Console.ConsoleKey = KeyNo;
			Root.Console.SaveConfig();

			BoundKey1[Selection] = KeyNo;
			BoundKey2[Selection] = 0;
		}
	}
	else
	{
		if(KeyNo == Root.Console.ConsoleKey)
		{
			Root.Console.ConsoleKey = 0;
			Root.Console.SaveConfig();
			BoundKey1[ConsoleKeyNumber] = 0;	
		}
		if(Root.Console.IsA('UTConsole') && KeyNo == UTConsole(Root.Console).SpeechKey)
		{
			UTConsole(Root.Console).SpeechKey = 0;
			Root.Console.SaveConfig();
			BoundKey1[VoiceKeyNumber] = 0;	
		}
		Super.SetKey(KeyNo, KeyName);
	}
}

defaultproperties
{
	AliasNames(0)="Fire"
	AliasNames(1)="AltFire"
	AliasNames(2)="MoveForward"
	AliasNames(3)="MoveBackward"
	AliasNames(4)="StrafeLeft"
	AliasNames(5)="StrafeRight"
	AliasNames(6)="TurnLeft"
	AliasNames(7)="TurnRight"
	AliasNames(8)="Jump"
	AliasNames(9)="Duck"
	AliasNames(10)="Look"
	AliasNames(11)="LookUp"
	AliasNames(12)="LookDown"
	AliasNames(13)="CenterView"
	AliasNames(14)="Walking"
	AliasNames(15)="Strafe"
	AliasNames(16)="FeignDeath"
	AliasNames(17)="Talk"
	AliasNames(18)="TeamTalk"
	AliasNames(19)="None"
	AliasNames(20)="taunt thrust"
	AliasNames(21)="taunt wave"
	AliasNames(22)="taunt taunt1"
	AliasNames(23)="taunt victory1"
	AliasNames(24)="NextWeapon"
	AliasNames(25)="PrevWeapon"
	AliasNames(26)="ThrowWeapon"
	AliasNames(27)="switchtobestweapon"
	AliasNames(28)="getweapon Translocator"
	AliasNames(29)="getweapon ChainSaw"
	AliasNames(30)="getweapon ImpactHammer"
	AliasNames(31)="getweapon enforcer"
	AliasNames(32)="getweapon ShockRifle"
	AliasNames(33)="getweapon ut_biorifle"
	AliasNames(34)="getweapon PulseGun"
	AliasNames(35)="getweapon SniperRifle"
	AliasNames(36)="getweapon ripper"
	AliasNames(37)="getweapon minigun2"
	AliasNames(38)="getweapon UT_FlakCannon"
	AliasNames(39)="getweapon UT_Eightball"
	AliasNames(40)="getweapon WarheadLauncher"
	AliasNames(41)="ViewPlayerNum 0"
	AliasNames(42)="ViewPlayerNum 1"
	AliasNames(43)="ViewPlayerNum 2"
	AliasNames(44)="ViewPlayerNum 3"
	AliasNames(45)="ViewPlayerNum 4"
	AliasNames(46)="ViewPlayerNum 5"
	AliasNames(47)="ViewPlayerNum 6"
	AliasNames(48)="ViewPlayerNum 7"
	AliasNames(49)="ViewPlayerNum 8"
	AliasNames(50)="ViewPlayerNum 9"
	AliasNames(51)="GrowHUD"
	AliasNames(52)="ShrinkHUD"
	AliasNames(53)="None"
	AliasNames(54)="Type"
	LabelList(0)="Controls,Fire"
	LabelList(1)="Alternate Fire"
	LabelList(2)="Move Forward"
	LabelList(3)="Move Backward"
	LabelList(4)="Strafe Left"
	LabelList(5)="Strafe Right"
	LabelList(6)="Turn Left"
	LabelList(7)="Turn Right"
	LabelList(8)="Jump/Up"
	LabelList(9)="Crouch/Down"
	LabelList(10)="Mouse Look"
	LabelList(11)="Look Up"
	LabelList(12)="Look Down"
	LabelList(13)="Center View"
	LabelList(14)="Walk"
	LabelList(15)="Strafe"
	LabelList(16)="Feign Death"
	LabelList(17)="Taunts / Chat,Say"
	LabelList(18)="Team Say"
	LabelList(19)="Show Voice Menu"
	LabelList(20)="Thrust"
	LabelList(21)="Wave"
	LabelList(22)="Victory1"
	LabelList(23)="Victory2"
	LabelList(24)="Weapons,Next Weapon"
	LabelList(25)="Previous Weapon"
	LabelList(26)="Throw Weapon"
	LabelList(27)="Select Best Weapon"
	LabelList(28)="Translocator"
	LabelList(29)="Chainsaw"
	LabelList(30)="Impact Hammer"
	LabelList(31)="Enforcer"
	LabelList(32)="Shock Rifle"
	LabelList(33)="Biorifle"
	LabelList(34)="PulseGun"
	LabelList(35)="Sniper Rifle"
	LabelList(36)="Ripper"
	LabelList(37)="Minigun"
	LabelList(38)="Flak Cannon"
	LabelList(39)="Rocket Launcher"
	LabelList(40)="Redeemer"
	LabelList(41)="View from Teammate,Teammate 1"
	LabelList(42)="Teammate 2"
	LabelList(43)="Teammate 3"
	LabelList(44)="Teammate 4"
	LabelList(45)="Teammate 5"
	LabelList(46)="Teammate 6"
	LabelList(47)="Teammate 7"
	LabelList(48)="Teammate 8"
	LabelList(49)="Teammate 9"
	LabelList(50)="Teammate 10"
	LabelList(51)="HUD,Increase HUD"
	LabelList(52)="Decrease HUD"
	LabelList(53)="Console,Console Key"
	LabelList(54)="Quick Console Key"
	VoiceKeyNumber=19
	ConsoleKeyNumber=53
}