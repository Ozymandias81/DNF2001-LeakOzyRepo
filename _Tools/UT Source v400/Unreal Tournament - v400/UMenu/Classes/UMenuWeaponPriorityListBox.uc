class UMenuWeaponPriorityListBox extends UWindowListBox;

var string WeaponClassParent;
var UMenuWeaponPriorityMesh MeshWindow;

var localized string WeaponPriorityHelp;

function Created()
{
	local name PriorityName;
	local string WeaponClassName;
	local class<Weapon> WeaponClass;
	local int WeaponNum, i;
	local UMenuWeaponPriorityList L;
	local PlayerPawn P;

	Super.Created();

	SetHelpText(WeaponPriorityHelp);

	P = GetPlayerOwner();

	// Load weapons into the list
	for(i=0;i<20;i++)
	{
		PriorityName = P.WeaponPriority[i];
		if(PriorityName == 'None') break;
		L = UMenuWeaponPriorityList(Items.Insert(ListClass));
		L.PriorityName = PriorityName;
		L.WeaponName = "(unk) "$PriorityName;
	}

	WeaponNum = 1;
	WeaponClassName = P.GetNextInt(WeaponClassParent, 0);
	while( WeaponClassName != "" && WeaponNum < 50 )
	{
		for(L = UMenuWeaponPriorityList(Items.Next); L != None; L = UMenuWeaponPriorityList(L.Next))
		{
			if( string(L.PriorityName) ~= P.GetItemName(WeaponClassName) )
			{
				L.WeaponClassName = WeaponClassName;
				L.bFound = True;
				if( L.ShowThisItem() )
				{
					WeaponClass = class<Weapon>(DynamicLoadObject(WeaponClassName, class'Class'));
					ReadWeapon(L, WeaponClass);
				}
				else
					L.bFound = False;
				break;
			}
		}

		WeaponClassName = P.GetNextInt(WeaponClassParent, WeaponNum);
		WeaponNum++;
	}
}

function ReadWeapon(UMenuWeaponPriorityList L, class<Weapon> WeaponClass)
{
	L.WeaponName = WeaponClass.default.ItemName;
	L.WeaponMesh = WeaponClass.default.Mesh;
	L.WeaponSkin = WeaponClass.default.Skin;
}

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	if(UMenuWeaponPriorityList(Item).bSelected)
	{
		C.DrawColor.r = 0;
		C.DrawColor.g = 0;
		C.DrawColor.b = 128;
		DrawStretchedTexture(C, X, Y, W, H-1, Texture'WhiteTexture');
		C.DrawColor.r = 255;
		C.DrawColor.g = 255;
		C.DrawColor.b = 255;
	}
	else
	{
		C.DrawColor.r = 0;
		C.DrawColor.g = 0;
		C.DrawColor.b = 0;
	}


	C.Font = Root.Fonts[F_Normal];

	ClipText(C, X+1, Y, UMenuWeaponPriorityList(Item).WeaponName);
}

function SaveConfigs()
{
	local int i;
	local UMenuWeaponPriorityList L;
	local PlayerPawn P;

	P = GetPlayerOwner();
	
	for(L = UMenuWeaponPriorityList(Items.Last); L != None && L != Items; L = UMenuWeaponPriorityList(L.Prev))
	{
		P.WeaponPriority[i] = L.PriorityName;
		i++;
	}
	while(i<20)
	{
		P.WeaponPriority[i] = 'None';
		i++;
	}
	P.UpdateWeaponPriorities();
	P.SaveConfig();
	Super.SaveConfigs();
}

function LMouseDown(float X, float Y)
{
	Super.LMouseDown(X, Y);

	if(SelectedItem != None)
		SelectWeapon();
}

function SelectWeapon()
{
	if(MeshWindow == None)
		MeshWindow = UMenuWeaponPriorityMesh(GetParent(class'UMenuWeaponPriorityCW').FindChildWindow(class'UMenuWeaponPriorityMesh'));

	MeshWindow.MeshActor.Mesh = UMenuWeaponPriorityList(SelectedItem).WeaponMesh;
	MeshWindow.MeshActor.Skin = UMenuWeaponPriorityList(SelectedItem).WeaponSkin;
}


defaultproperties
{
	ListClass=class'UMenuWeaponPriorityList'
	ItemHeight=13
	WeaponClassParent="Engine.Weapon"
	bCanDrag=True
	WeaponPriorityHelp="Click and drag a weapon name in the list on the left to change its priority.  Weapons higher in the list have higher priority."
}
