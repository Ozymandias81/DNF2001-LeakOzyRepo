class SpeechBinderCW expands UMenuDialogClientWindow;

var UWindowComboControl TypeCombo[16];
var UWindowComboControl ChoiceCombo[16];
var UWindowComboControl TargetCombo[16];
var UMenuRaisedButton BinderButton[16];
var UMenuLabelControl BinderLabel[16];

var class<ChallengeVoicePack> V;

var bool bInitialized, bSetReady;

var localized string LabelText;
var localized string NotApplicable;
var localized string AllString;
var localized string LeaderString;
var localized string PlayerString;
var localized string NotBound;

var UMenuRaisedButton SelectedButton;
var int Selection;
var bool bPolling;

var UWindowSmallButton DefaultsButton;
var localized string DefaultsText;
var localized string DefaultsHelp;

var int MaxBindings;

function Created()
{
	local int ButtonWidth, ButtonLeft, ButtonTop;
	local int LabelWidth, LabelLeft;
	local int i, j;
	local int TypeLeft, ChoiceLeft, TargetLeft;
	local int ChoiceWidth;

	MaxBindings = 16;

	V = class<ChallengeVoicePack>(GetPlayerOwner().PlayerReplicationInfo.VoiceType);
	if (V == None)
	{
		Log("SpeechBinder: Critical Error, V is None.");
	}

	bIgnoreLDoubleClick = True;
	bIgnoreMDoubleClick = True;
	bIgnoreRDoubleClick = True;

	Super.Created();

	SetAcceptsFocus();

	ChoiceWidth = WinWidth / 4;
	TypeLeft = (WinWidth - (ChoiceWidth*3 + 20))/2;
	ChoiceLeft = TypeLeft + ChoiceWidth + 10;
	TargetLeft = ChoiceLeft + ChoiceWidth + 10;

	LabelWidth = 60;
	LabelLeft = TypeLeft;

	ButtonWidth = WinWidth/5;
	ButtonLeft = LabelLeft + LabelWidth + 20;

	// Defaults Button
	DefaultsButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 30, 10, 48, 16));
	DefaultsButton.SetText(DefaultsText);
	DefaultsButton.SetFont(F_Normal);
	DefaultsButton.SetHelpText(DefaultsHelp);

	ButtonTop = 35;
	for (i=0; i<MaxBindings; i++)
	{
		TypeCombo[i] = UWindowComboControl(CreateControl(class'UWindowComboControl', TypeLeft, ButtonTop, ChoiceWidth, 1));
		TypeCombo[i].bAcceptsFocus = False;
		TypeCombo[i].EditBoxWidth = ChoiceWidth;
		for (j=0; j<class'SpeechWindow'.Default.NumOptions-2; j++)
		{
			TypeCombo[i].AddItem(class'SpeechWindow'.Default.Options[j]);
		}
		TypeCombo[i].SetSelectedIndex(0);

		ChoiceCombo[i] = UWindowComboControl(CreateControl(class'UWindowComboControl', ChoiceLeft, ButtonTop, ChoiceWidth, 1));
		ChoiceCombo[i].bAcceptsFocus = False;
		ChoiceCombo[i].EditBoxWidth = ChoiceWidth;

		TargetCombo[i] = UWindowComboControl(CreateControl(class'UWindowComboControl', TargetLeft, ButtonTop, ChoiceWidth, 1));
		TargetCombo[i].bAcceptsFocus = False;
		TargetCombo[i].EditBoxWidth = ChoiceWidth;

		ButtonTop += 22;

		BinderLabel[i] = UMenuLabelControl(CreateControl(class'UMenuLabelControl', LabelLeft, ButtonTop+3, LabelWidth, 1));
		BinderLabel[i].SetText(LabelText);
		BinderLabel[i].SetFont(F_Normal);

		BinderButton[i] = UMenuRaisedButton(CreateControl(class'UMenuRaisedButton', ButtonLeft, ButtonTop, ButtonWidth, 1));
		BinderButton[i].bAcceptsFocus = False;
		BinderButton[i].bIgnoreLDoubleClick = True;
		BinderButton[i].bIgnoreMDoubleClick = True;
		BinderButton[i].bIgnoreRDoubleClick = True;
		BinderButton[i].Text = NotBound;
		BinderButton[i].Index = i;
		ButtonTop += 35;
	}

	bInitialized = True;

	j = LoadExistingKeys();

	for (i=j; i<MaxBindings; i++)
		TypeChanged(i);

	bSetReady = True;

	DesiredHeight = ButtonTop + 45;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int ButtonWidth, ButtonLeft, ButtonTop;
	local int LabelWidth, LabelLeft;
	local int i;
	local int TypeLeft, ChoiceLeft, TargetLeft;
	local int TypeLeft2, ChoiceLeft2;
	local int ChoiceWidth;
	local int ChoiceWidth2;

	Super.BeforePaint(C, X, Y);

	ChoiceWidth = WinWidth / 4;
	TypeLeft = (WinWidth - (ChoiceWidth*3 + 20))/2;
	ChoiceLeft = TypeLeft + ChoiceWidth + 10;
	TargetLeft = ChoiceLeft + ChoiceWidth + 10;

	ChoiceWidth2 = WinWidth / 3;
	TypeLeft2 = (WinWidth - (ChoiceWidth2*2 + 10))/2;
	ChoiceLeft2 = TypeLeft2 + ChoiceWidth2 + 10;

	LabelWidth = 60;
	LabelLeft = TypeLeft;

	ButtonWidth = WinWidth/5;
	ButtonLeft = LabelLeft + LabelWidth + 20;

	DefaultsButton.AutoWidth(C);
	DefaultsButton.WinLeft = 30;
	DefaultsButton.WinTop = 10;

	ButtonTop = 35;
	for (i=0; i<MaxBindings; i++)
	{
		if (TargetCombo[i].WindowIsVisible())
		{
			TypeCombo[i].WinLeft = TypeLeft;
			TypeCombo[i].WinTop = ButtonTop;
			TypeCombo[i].SetSize(ChoiceWidth, 1);
			TypeCombo[i].EditBoxWidth = ChoiceWidth;

			ChoiceCombo[i].WinLeft = ChoiceLeft;
			ChoiceCombo[i].WinTop = ButtonTop;
			ChoiceCombo[i].SetSize(ChoiceWidth, 1);
			ChoiceCombo[i].EditBoxWidth = ChoiceWidth;

			TargetCombo[i].WinLeft = TargetLeft;
			TargetCombo[i].WinTop = ButtonTop;
			TargetCombo[i].SetSize(ChoiceWidth, 1);
			TargetCombo[i].EditBoxWidth = ChoiceWidth;
		} else {
			TypeCombo[i].WinLeft = TypeLeft2;
			TypeCombo[i].WinTop = ButtonTop;
			TypeCombo[i].SetSize(ChoiceWidth2, 1);
			TypeCombo[i].EditBoxWidth = ChoiceWidth2;

			ChoiceCombo[i].WinLeft = ChoiceLeft2;
			ChoiceCombo[i].WinTop = ButtonTop;
			ChoiceCombo[i].SetSize(ChoiceWidth2, 1);
			ChoiceCombo[i].EditBoxWidth = ChoiceWidth2;
		}

		ButtonTop += 22;

		BinderLabel[i].WinLeft = LabelLeft;
		BinderLabel[i].WinTop = ButtonTop+3;
		BinderLabel[i].SetSize(LabelWidth, 1);

		BinderButton[i].WinLeft = ButtonLeft;
		BinderButton[i].WinTop = ButtonTop;
		BinderButton[i].SetSize(ButtonWidth, 1);
		ButtonTop += 35;
	}
}

function int LoadExistingKeys()
{
	local int i, j, pos;
	local int Type, Choice, Target;
	local string KeyName;
	local string Alias;
	local string Rest;

	for (i=0; i<255; I++)
	{
		KeyName = GetPlayerOwner().ConsoleCommand( "KEYNAME "$i );
		if ( KeyName != "" )
		{
			Alias = GetPlayerOwner().ConsoleCommand( "KEYBINDING "$KeyName );
			if ( Alias != "" )
			{
				pos = InStr(Alias, "speech ");
				if (pos != -1)
				{
					BinderButton[j].Text = KeyName;

					Rest = Right(Alias, Len(Alias) - 7);
					pos = InStr(Rest, " ");
					Type = int(Left(Rest, pos));
					TypeCombo[j].SetSelectedIndex(Type);

					Rest = Right(Rest, Len(Rest) - pos - 1);
					pos = InStr(Rest, " ");
					Choice = int(Left(Rest, pos));
					ChoiceCombo[j].SetSelectedIndex(Choice);

					Rest = Right(Rest, Len(Rest) - pos - 1);
					Target = int(Rest);
					TargetCombo[j].SetSelectedIndex(Target+1);

					j++;
					if (j > 7)
						return j;
				}
			}
		}
	}
	return j;
}

function KeyDown( int Key, float X, float Y )
{
	if (bPolling)
	{
		ProcessMenuKey( Key, mid(string(GetEnum(enum'EInputKey',Key)),3) );
		bPolling = False;
		SelectedButton.bDisabled = False;
	}
}

function ResetAllKeys()
{
	local int i;

	for (i=0; i<MaxBindings; i++)
	{
		if (BinderButton[i].Text != NotBound)
		{
			GetPlayerOwner().ConsoleCommand("SET Input"@BinderButton[i].Text);
			BinderButton[i].Text = NotBound;
			bSetReady = False;
			TypeCombo[i].SetSelectedIndex(0);
			ChoiceCombo[i].SetSelectedIndex(0);
			TargetCombo[i].SetSelectedIndex(0);
			bSetReady = True;
		}
	}
	GetPlayerOwner().SaveConfig();
}

function RemoveExistingKey(int KeyNo, string KeyName)
{
	local int i;
	local int Type, Choice, Target;
	local string KeyName2, Alias, Binding;

	// Unbind this key.
	for (i=0; i<MaxBindings; i++)
	{
		if (BinderButton[i].Text == KeyName)
		{
			GetPlayerOwner().ConsoleCommand("SET Input"@BinderButton[i].Text);
			BinderButton[i].Text = "";
		}
	}

	// Find what we are binding and remove all others of that type.
	Type = TypeCombo[SelectedButton.Index].GetSelectedIndex();
	Choice = ChoiceCombo[SelectedButton.Index].GetSelectedIndex();
	if (Type == 2) // Orders
		Target = TargetCombo[SelectedButton.Index].GetSelectedIndex() - 1;
	else
		Target = 0;
	Binding = "speech"@Type@Choice@Target;
	for (i=0; i<255; i++)
	{
		KeyName2 = GetPlayerOwner().ConsoleCommand( "KEYNAME "$i );
		if ( KeyName2 != "" )
		{
			Alias = GetPlayerOwner().ConsoleCommand( "KEYBINDING "$KeyName2 );
			if ( Alias ~= Binding )
				GetPlayerOwner().ConsoleCommand("SET Input"@KeyName2);
		}
	}			
}

function SetKey(int KeyNo, string KeyName)
{
	local int Type, Choice, Target;

	Type = TypeCombo[SelectedButton.Index].GetSelectedIndex();
	Choice = ChoiceCombo[SelectedButton.Index].GetSelectedIndex();
	if (Type == 2) // Orders
		Target = TargetCombo[SelectedButton.Index].GetSelectedIndex() - 1;
	else
		Target = 0;

	GetPlayerOwner().ConsoleCommand("SET Input"@KeyName@"speech"@Type@Choice@Target);
	SelectedButton.Text = KeyName;
	GetPlayerOwner().SaveConfig();
}

function ProcessMenuKey( int KeyNo, string KeyName )
{
	if ( (KeyName == "") || (KeyName == "Escape")
		|| ((KeyNo >= 0x70 ) && (KeyNo <= 0x79)) // function keys
		|| ((KeyNo >= 0x30 ) && (KeyNo <= 0x39))) // number keys
		return;

	RemoveExistingKey(KeyNo, KeyName);
	SetKey(KeyNo, KeyName);
}

function Notify(UWindowDialogControl C, byte E)
{
	local int i;

	Super.Notify(C, E);

	switch(E)
	{
	case DE_Change:
		for (i=0; i<MaxBindings; i++)
		{
			if (C == TypeCombo[i])
				TypeChanged(i);
			if (C == ChoiceCombo[i])
				ChoiceChanged(i);
			if (C == TargetCombo[i])
				TargetChanged(i);
		}
	case DE_Click:
		if (C == DefaultsButton)
			ResetAllKeys();
		for (i=0; i<MaxBindings; i++)
		{
			if (C == BinderButton[i])
			{
				SelectedButton = UMenuRaisedButton(C);
				Selection = i;
				bPolling = True;
				SelectedButton.bDisabled = True;
			}
		}
	}
}

function TypeChanged(int i)
{
	local int j;
	local class<ChallengeVoicePack> V;

	if (!bInitialized)
		return;

	V = class<ChallengeVoicePack>(GetPlayerOwner().PlayerReplicationInfo.VoiceType);

	// Update the choices.
	ChoiceCombo[i].Clear();
	switch (TypeCombo[i].GetSelectedIndex())
	{
		case 0: // Acks
			for (j=0; j<V.Default.NumAcks; j++)
			{
				ChoiceCombo[i].AddItem(V.Static.GetAckString(j));
			}
			break;
		case 1: // Friendly Fire
			for (j=0; j<V.Default.NumFFires; j++)
			{
				ChoiceCombo[i].AddItem(V.Static.GetFFireString(j));
			}
			break;
		case 2: // Orders
			for (j=0; j<5; j++)
			{
				ChoiceCombo[i].AddItem(V.Static.GetOrderString(j, ""));
			}
			break;
		case 3: // Taunts
			for (j=0; j<V.Default.NumTaunts; j++)
			{
				ChoiceCombo[i].AddItem(V.Static.GetTauntString(j));
			}
			break;
		case 4: // Other
			for (j=0; j<32; j++)
			{
				if (V.Static.GetOtherString(j) != "")
					ChoiceCombo[i].AddItem(V.Static.GetOtherString(j));
			}
			break;
	}
	ChoiceCombo[i].SetSelectedIndex(0);
	ChoiceChanged(i);
}

function ChoiceChanged(int i)
{
	local int j;

	if (!bInitialized)
		return;

	TargetCombo[i].Clear();
	switch (TypeCombo[i].GetSelectedIndex())
	{
		case 0: // Acks
			TargetCombo[i].AddItem(NotApplicable);
			TargetCombo[i].HideWindow();
			break;
		case 1: // Friendly Fire
			TargetCombo[i].AddItem(NotApplicable);
			TargetCombo[i].HideWindow();
			break;
		case 2: // Orders
			TargetCombo[i].AddItem(AllString);
			TargetCombo[i].AddItem(LeaderString);
			TargetCombo[i].ShowWindow();
			for (j=2; j<16; j++)
				TargetCombo[i].AddItem(PlayerString@j);
			break;
		case 3: // Taunts
			TargetCombo[i].AddItem(NotApplicable);
			TargetCombo[i].HideWindow();
			break;
		case 4: // Other
			TargetCombo[i].AddItem(NotApplicable);
			TargetCombo[i].HideWindow();
			break;
	}
	TargetCombo[i].SetSelectedIndex(0);
	TargetChanged(i);
}

function TargetChanged(int i)
{
	if (!bInitialized)
		return;

	if (BinderButton[i].Text != NotBound)
	{
		SelectedButton = BinderButton[i];
		if (bSetReady)
			SetKey(0, BinderButton[i].Text);
	}
}

defaultproperties
{
	LabelText="Bind to Key:"
	NotApplicable="N/A"
	AllString="All"
	LeaderString="Team Leader"
	PlayerString="Team Mate"
	NotBound="Unbound"
	DefaultsText="Reset"
	DefaultsHelp="Unbind all speech keys."
}