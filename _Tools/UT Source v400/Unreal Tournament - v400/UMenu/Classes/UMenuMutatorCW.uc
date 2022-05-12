class UMenuMutatorCW expands UMenuDialogClientWindow;

var UMenuBotmatchClientWindow BotmatchParent;
var UWindowHSplitter Splitter;

var UMenuMutatorExclude Exclude;
var UMenuMutatorInclude Include;

var localized string ExcludeCaption;
var localized string ExcludeHelp;
var localized string IncludeCaption;
var localized string IncludeHelp;

var UWindowCheckbox KeepCheck;
var localized string KeepText;
var localized string KeepHelp;

var UMenuMutatorFrameCW FrameExclude;
var UMenuMutatorFrameCW FrameInclude;

var string MutatorBaseClass;

function Created()
{
	Super.Created();
	
	BotmatchParent = UMenuBotmatchClientWindow(OwnerWindow);

	KeepCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', 10, 2, 190, 1));
	KeepCheck.SetText(KeepText);
	KeepCheck.SetHelpText(KeepHelp);
	KeepCheck.SetFont(F_Normal);
	KeepCheck.bChecked = BotmatchParent.bKeepMutators;
	KeepCheck.Align = TA_Right;

	Splitter = UWindowHSplitter(CreateWindow(class'UWindowHSplitter', 0, 0, WinWidth, WinHeight));

	FrameExclude = UMenuMutatorFrameCW(Splitter.CreateWindow(class'UMenuMutatorFrameCW', 0, 0, 100, 100));
	FrameInclude = UMenuMutatorFrameCW(Splitter.CreateWindow(class'UMenuMutatorFrameCW', 0, 0, 100, 100));

	Splitter.LeftClientWindow  = FrameExclude;
	Splitter.RightClientWindow = FrameInclude;

	Exclude = UMenuMutatorExclude(CreateWindow(class'UMenuMutatorExclude', 0, 0, 100, 100, Self));
	FrameExclude.Frame.SetFrame(Exclude);
	Include = UMenuMutatorInclude(CreateWindow(class'UMenuMutatorInclude', 0, 0, 100, 100, Self));
	FrameInclude.Frame.SetFrame(Include);

	Exclude.Register(Self);
	Include.Register(Self);

	Exclude.SetHelpText(ExcludeHelp);
	Include.SetHelpText(IncludeHelp);

	Include.DoubleClickList = Exclude;
	Exclude.DoubleClickList = Include;

	Splitter.bSizable = False;
	Splitter.bRightGrow = True;
	Splitter.SplitPos = WinWidth/2;

	LoadMutators();
}

function Paint(Canvas C, float X, float Y)
{
	Super.Paint(C, X, Y);

	DrawUpBevel( C, 0, 20, WinWidth, 15, GetLookAndFeelTexture());

	C.Font = Root.Fonts[F_Normal];
	C.DrawColor.R = 0;
	C.DrawColor.G = 0;
	C.DrawColor.B = 0;

	ClipText(C, 10, 23, ExcludeCaption, True);
	ClipText(C, WinWidth/2 + 10, 23, IncludeCaption, True);
}

function Resized()
{
	Super.Resized();

	Splitter.WinTop = 35;
	Splitter.SetSize(WinWidth, WinHeight-35);
	Splitter.SplitPos = WinWidth/2;
}

function LoadMutators()
{
	local int NumMutatorClasses;
	local string NextMutator, NextDesc;
	local UMenuMutatorList I;
	local string MutatorList;
	local int j;
	local int k;

	GetPlayerOwner().GetNextIntDesc(MutatorBaseClass, 0, NextMutator, NextDesc);
	while( (NextMutator != "") && (NumMutatorClasses < 200) )
	{
		I = UMenuMutatorList(Exclude.Items.Append(class'UMenuMutatorList'));
		I.MutatorClass = NextMutator;

		k = InStr(NextDesc, ",");
		if(k == -1)
		{
			I.MutatorName = NextDesc;
			I.HelpText = "";
		}
		else
		{
			I.MutatorName = Left(NextDesc, k);
			I.HelpText = Mid(NextDesc, k+1);
		}

		NumMutatorClasses++;
		GetPlayerOwner().GetNextIntDesc(MutatorBaseClass, NumMutatorClasses, NextMutator, NextDesc);
	}

	MutatorList = BotmatchParent.MutatorList;

	while(MutatorList != "")
	{
		j = InStr(MutatorList, ",");
		if(j == -1)
		{
			NextMutator = MutatorList;
			MutatorList = "";
		}
		else
		{
			NextMutator = Left(MutatorList, j);
			MutatorList = Mid(MutatorList, j+1);
		}
		
		I = UMenuMutatorList(Exclude.Items).FindMutator(NextMutator);
		if(I != None)
		{
			I.Remove();
			Include.Items.AppendItem(I);
		}
		else
			Log("Unknown mutator in mutator list: "$NextMutator);
	}

	Exclude.Sort();
}

function SaveConfigs()
{
	local UMenuMutatorList I;
	local string MutatorList;

	Super.SaveConfigs();
	
	for(I = UMenuMutatorList(Include.Items.Next); I != None; I = UMenuMutatorList(I.Next))
	{
		if(MutatorList == "")
			MutatorList = I.MutatorClass;
		else
			MutatorList = MutatorList $ "," $I.MutatorClass;
	}
	BotmatchParent.MutatorList = MutatorList;
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	switch(E)
	{
	case DE_Change:
		switch(C)
		{
		case KeepCheck:
			BotmatchParent.bKeepMutators = KeepCheck.bChecked;
			break;
		}
		break;
	}
}

defaultproperties
{
	ExcludeCaption="Mutators not Used"
	ExcludeHelp="Click and drag a mutator to the right hand column to include that mutator in this game."
	IncludeCaption="Mutators Used"
	IncludeHelp="Click and drag a mutator to the left hand column to remove it from the mutator list, or drag it up or down to re-order it in the mutator list."
	MutatorBaseClass="Engine.Mutator"
	KeepText="Always use this Mutator configuration"
	KeepHelp="If checked, these Mutators will always be used when starting games."
}
