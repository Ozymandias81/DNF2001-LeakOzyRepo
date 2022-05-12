class UMenuSaveGameClientWindow extends UMenuSlotClientWindow;

var localized string CantSave;

function Created()
{
	Super.Created();

	if ( Root.GetPlayerOwner().Health <= 0 )
		UWindowFramedWindow(ParentWindow).WindowTitle = CantSave;
}

function Notify(UWindowDialogControl C, byte E)
{
	local int I;
	local int Selection;

	Super.Notify(C, E);

	switch(E)
	{
	case DE_Click:
		if ( GetPlayerOwner().Health <= 0 )
			return;

		if ( GetLevel().Minute < 10 )
			UMenuRaisedButton(C).SetText(GetLevel().Title@GetLevel().Hour$"\:0"$GetLevel().Minute$" "$MonthNames[GetLevel().Month - 1]@GetLevel().Day);
		else
			UMenuRaisedButton(C).SetText(GetLevel().Title@GetLevel().Hour$"\:"$GetLevel().Minute@MonthNames[GetLevel().Month - 1]@GetLevel().Day);

		if ( GetLevel().NetMode != NM_Standalone )
			UMenuRaisedButton(C).SetText("Net:"$UMenuRaisedButton(C).Text);

		for (I=0; I<9; I++)
			if (C == Slots[I])
				Selection = I;

		SlotNames[Selection] = UMenuRaisedButton(C).Text;
		SaveConfig();

		Root.GetPlayerOwner().ConsoleCommand("SaveGame "$Selection);
		Close();
		break;
	}
}

defaultproperties
{
	CantSave="Cannot Save: You are dead."
}