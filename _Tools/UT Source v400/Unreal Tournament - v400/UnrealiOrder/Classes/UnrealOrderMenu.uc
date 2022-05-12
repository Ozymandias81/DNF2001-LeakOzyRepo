//=============================================================================
// UnrealOrderMenu.
//=============================================================================
class UnrealOrderMenu extends UnrealMenu;

#exec OBJ LOAD FILE=Textures\OrderGfx.utx PACKAGE=UnrealiOrder.OrderGfx

var int CurOrigin,CurOrigin2, OClipX, OClipY;
var bool bDrawPicAfter;
var() localized string OrderText[70];
var() localized string HelpInfo;

function MenuProcessInput( byte KeyNum, byte ActionNum )
{
	if( KeyNum==EInputKey.IK_Escape )
	{
		PlayEnterSound();
		ExitMenu();
		return;
	}	
	else if( KeyNum==EInputKey.IK_Down || KeyNum==EInputKey.IK_Right || KeyNum==EInputKey.IK_MouseWheelDown )
	{
		CurOrigin -= 32;
	}
	else if( KeyNum==EInputKey.IK_Up || KeyNum==EInputKey.IK_Left || KeyNum==EInputKey.IK_MouseWheelUp )
	{
		CurOrigin += 32;		
	}
	else if( KeyNum==EInputKey.IK_PageDown )
	{
		PlaySelectSound();
		CurOrigin -= OClipY-40;
	}
	else if( KeyNum == EInputKey.IK_PageUp )
	{
		PlaySelectSound();
		CurOrigin += OClipY -40;		
	}	

	if( bExitAllMenus )
		ExitAllMenus(); 
}

function DrawBackGround(canvas Canvas, bool bNoLogo)
{
	local int StartX;	

	StartX = 0.5 * Canvas.ClipX - 256;
	if (StartX<0) StartX= 0.5 * Canvas.ClipX - 128;
	Canvas.Style = 1;
	Canvas.SetPos(StartX,0);
	Canvas.DrawIcon(texture'Menu2', 1.0);
	
	if (Canvas.ClipY>256)
	{
		Canvas.SetPos(StartX,256);
		Canvas.DrawIcon(texture'Menu2', 1.0);
		
		if (Canvas.ClipY>512)	
		{
			Canvas.SetPos(StartX,512);
			Canvas.DrawIcon(texture'Menu2', 1.0);
		}
	}
}

function DrawMenu(canvas Canvas)
{
	local int StartEdge, StartX, StartY, Spacing, SecSpace, i;
	
	Canvas.bNoSmooth = True;
	OClipX = Canvas.ClipX;
	OClipY = Canvas.ClipY;

	DrawBackGround(Canvas, (Canvas.ClipY < 320));
	
	StartEdge = Canvas.ClipX * 0.5 -256;
	Canvas.Font = Canvas.MedFont;			
	if (StartEdge<0) 
	{
		StartEdge = 0.5 * Canvas.ClipX - 128;
		Canvas.SetClip(246,Canvas.ClipY-34);			
		bDrawPicAfter=True;		
	}	
	else 
	{
		bDrawPicAfter=False;
		Canvas.SetClip(246,Canvas.ClipY-34);
	}
	
	if (CurOrigin>0) CurOrigin=0;	
	if (CurOrigin<(-5885+OClipy)&& bDrawPicAfter) CurOrigin=-5885+OClipy;
	if (CurOrigin<(-3263+OClipy) && !bDrawPicAfter) CurOrigin=-3263+OClipy;
	
	Canvas.SetOrigin(StartEdge+5,CurOrigin);		

	StartX = 0.5 * Canvas.ClipX - 80;
	StartY = 2;
	Canvas.SetPos(StartX, StartY );
	Canvas.DrawText(MenuTitle, False);	
	
	StartX = 0.5 * Canvas.ClipX - 120;
	StartY = 16;
	Canvas.DrawColor.R = 130;
	Canvas.DrawColor.G = 130;
	Canvas.DrawColor.B = 130;
		
	Canvas.SetPos(StartX, StartY+2);
	Canvas.DrawText(OrderText[0], True);

	Canvas.DrawColor.R = 0;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 255;

	Canvas.SetPos(StartX, StartY+58);
	Canvas.DrawText(OrderText[1], True);

	Canvas.DrawColor.R = 255;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 255;
	
	Canvas.SetPos(StartX, StartY+98);
	Canvas.DrawText(OrderText[2], True);	

	Canvas.DrawColor.R = 130;
	Canvas.DrawColor.G = 130;
	Canvas.DrawColor.B = 130;

	Canvas.SetPos(StartX, StartY+125);
	Canvas.DrawText(OrderText[3], True);
	
	Canvas.SetPos(StartX, StartY+150);
	Canvas.DrawText(OrderText[4], True);	
	
	Canvas.SetPos(StartX, StartY+175);
	Canvas.DrawText(OrderText[5], True);	
	
	Canvas.SetPos(StartX, StartY+212);
	Canvas.DrawText(OrderText[6], True);

	Canvas.SetPos(StartX, StartY+238);
	Canvas.DrawText(OrderText[7], True);	
	
	Canvas.SetPos(StartX, StartY+263);
	Canvas.DrawText(OrderText[8], True);	

	Canvas.SetPos(StartX, StartY+325);
	Canvas.DrawText(OrderText[8], True);	
	
	Canvas.SetPos(StartX, StartY+386);
	Canvas.DrawText(OrderText[9], True);	

	Canvas.SetPos(StartX, StartY+420);
	Canvas.DrawText(OrderText[10], True);	

	Canvas.DrawColor.R = 255;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 255;
	
	Canvas.SetPos(StartX, StartY+512);
	Canvas.DrawText(OrderText[11], True);	

	Canvas.DrawColor.R = 130;
	Canvas.DrawColor.G = 130;
	Canvas.DrawColor.B = 130;
	
	Canvas.SetPos(StartX, StartY+545);
	Canvas.DrawText(OrderText[12], True);	
	
	Canvas.SetPos(StartX, StartY+570);
	Canvas.DrawText(OrderText[13], True);		
	
	Canvas.SetPos(StartX, StartY+605);
	Canvas.DrawText(OrderText[14], True);
	
	Canvas.SetPos(StartX, StartY+650);
	Canvas.DrawText(OrderText[15], True);
	
	Canvas.SetPos(StartX, StartY+675);
	Canvas.DrawText(OrderText[16], True);			
	
	Canvas.SetPos(StartX, StartY+725);
	Canvas.DrawText(OrderText[17], True);	

	Canvas.Font = Canvas.SmallFont;
	Canvas.DrawColor.R = 10;
	Canvas.DrawColor.G = 90;
	Canvas.DrawColor.B = 10;

	Canvas.SetPos(StartX, StartY+750);
	Canvas.DrawText(OrderText[18], True);
	
	Canvas.Font = Canvas.MedFont;	
	Canvas.DrawColor.R = 255;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 255;
	
	Canvas.SetPos(StartX, StartY+815);
	Canvas.DrawText(OrderText[19], True);	

	Canvas.DrawColor.R = 130;
	Canvas.DrawColor.G = 130;
	Canvas.DrawColor.B = 130;
	
	Canvas.SetPos(StartX, StartY+850);
	Canvas.DrawText(OrderText[20], True);	
	
	Canvas.SetPos(StartX, StartY+875);
	Canvas.DrawText(OrderText[21], True);	
	
	Canvas.SetPos(StartX, StartY+910);
	Canvas.DrawText(OrderText[22], True);	

	Canvas.Font = Canvas.SmallFont;
	Canvas.DrawColor.R = 10;
	Canvas.DrawColor.G = 90;
	Canvas.DrawColor.B = 10;	
	
	Canvas.SetPos(StartX, StartY+953);
	Canvas.DrawText(OrderText[23], True);	

	Canvas.Font = Canvas.MedFont;	
	Canvas.DrawColor.R = 130;
	Canvas.DrawColor.G = 130;
	Canvas.DrawColor.B = 130;	
	
	Canvas.SetPos(StartX, StartY+990);
	Canvas.DrawText(OrderText[24], True);	
	
	Canvas.SetPos(StartX, StartY+1050);
	Canvas.DrawText(OrderText[25], True);	
	
	Canvas.DrawColor.R = 255;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 255;
	
	Canvas.SetPos(StartX, StartY+1120);  // USA / Canada
	Canvas.DrawText(OrderText[26], True);

	Canvas.DrawColor.R = 130;
	Canvas.DrawColor.G = 130;
	Canvas.DrawColor.B = 130;
	
	Canvas.SetPos(StartX, StartY+1138);
	Canvas.DrawText(OrderText[27], True);

	Canvas.DrawColor.R = 0;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 255;

	Canvas.SetPos(StartX, StartY+1167);
	Canvas.DrawText(OrderText[28], True);

	Canvas.DrawColor.R = 130;
	Canvas.DrawColor.G = 130;
	Canvas.DrawColor.B = 130;

	Canvas.SetPos(StartX, StartY+1249);
	Canvas.DrawText(OrderText[29], True);
	
	Canvas.DrawColor.R = 255;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 255;

	Canvas.SetPos(StartX, StartY+1300);  // United Kingdom
	Canvas.DrawText(OrderText[30], True);

	Canvas.DrawColor.R = 130;
	Canvas.DrawColor.G = 130;
	Canvas.DrawColor.B = 130;

	Canvas.SetPos(StartX, StartY+1320);
	Canvas.DrawText(OrderText[31], True);

	Canvas.DrawColor.R = 255;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 255;

	Canvas.SetPos(StartX, StartY+1407); //Other contries
	Canvas.DrawText(OrderText[32], True);

	Canvas.DrawColor.R = 130;
	Canvas.DrawColor.G = 130;
	Canvas.DrawColor.B = 130;

	Canvas.SetPos(StartX, StartY+1428);
	Canvas.DrawText(OrderText[33], True);

	Canvas.DrawColor.R = 255;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 255;

	Canvas.SetPos(StartX, StartY+1515);  //Our online partners
	Canvas.DrawText(OrderText[34], True);

	Canvas.DrawColor.R = 130;
	Canvas.DrawColor.G = 130;
	Canvas.DrawColor.B = 130;

	Canvas.SetPos(StartX, StartY+1535);  // Check out...
	Canvas.DrawText(OrderText[35], True);
	
	Canvas.SetPos(StartX, StartY+1590);  //Mplayer
	Canvas.DrawText(OrderText[36], True);	
	
	Canvas.SetPos(StartX, StartY+1677);  
	Canvas.DrawText(OrderText[37], True);	
	
	Canvas.SetPos(StartX, StartY+1717);  //WON
	Canvas.DrawText(OrderText[38], True);	
	
	Canvas.SetPos(StartX, StartY+1797);  
	Canvas.DrawText(OrderText[39], True);
	
	Canvas.SetPos(StartX, StartY+1865);  // Wireplay
	Canvas.DrawText(OrderText[40], True);	
	
	Canvas.SetPos(StartX, StartY+1951);
	Canvas.DrawText(OrderText[41], True);	

	Canvas.SetPos(StartX, StartY+2000);  // HEAT
	Canvas.DrawText(OrderText[42], True);	
	
	Canvas.SetPos(StartX, StartY+2070);
	Canvas.DrawText(OrderText[43], True);	
	
	Canvas.SetPos(StartX, StartY+2112); 
	Canvas.DrawText(OrderText[44], True);	// AT&T
	
	Canvas.SetPos(StartX, StartY+2160);
	Canvas.DrawText(OrderText[45], True);	
	
	Canvas.SetPos(StartX, StartY+2225);  // Gamespy
	Canvas.DrawText(OrderText[46], True);	
	
	Canvas.SetPos(StartX, StartY+2283);
	Canvas.DrawText(OrderText[47], True);	
	
	Canvas.DrawColor.R = 255;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 255;

	Canvas.SetPos(StartX, StartY+2350);  //Order Cool
	Canvas.DrawText(OrderText[48], True);

	Canvas.DrawColor.R = 130;
	Canvas.DrawColor.G = 130;
	Canvas.DrawColor.B = 130;	

	Canvas.SetPos(StartX, StartY+2370);  
	Canvas.DrawText(OrderText[49], True);	

	Canvas.DrawColor.R = 255;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 255;

	Canvas.SetPos(StartX, StartY+2470);  //Special Offers
	Canvas.DrawText(OrderText[50], True);

	Canvas.DrawColor.R = 130;
	Canvas.DrawColor.G = 130;
	Canvas.DrawColor.B = 130;	

	Canvas.SetPos(StartX, StartY+2490);  
	Canvas.DrawText(OrderText[51], True);		

	// Now draw images

	Canvas.Reset();	
	Canvas.bNoSmooth = True;	

	Canvas.SetPos(StartEdge, CurOrigin+2595);
	Canvas.DrawIcon(texture'att', 1.0);	
	Canvas.SetPos(StartEdge+128, CurOrigin+2595);
	Canvas.DrawIcon(texture'heat', 1.0);		
	Canvas.SetPos(StartEdge, CurOrigin+2595+128);
	Canvas.DrawIcon(texture'mplay', 1.0);	
	Canvas.SetPos(StartEdge+128, CurOrigin+2595+128);
	Canvas.DrawIcon(texture'won', 1.0);		
	Canvas.SetPos(StartEdge, CurOrigin+2595+256);
	Canvas.DrawIcon(texture'gamespy', 1.0);	
	Canvas.SetPos(StartEdge+128, CurOrigin+2595+256);
	Canvas.DrawIcon(texture'wireplay', 1.0);

	CurOrigin2 = Curorigin;
	if (bDrawPicAfter)
	{
		StartEdge -= 256;
		CurOrigin2 += 2595+256+128;
	}

	Canvas.SetPos(StartEdge+256,CurOrigin2);
	Canvas.DrawIcon(texture'CallNow', 1.0);
	Canvas.SetPos(StartEdge+256,64+CurOrigin2);
	Canvas.DrawIcon(texture'krall', 1.0);
	Canvas.SetPos(StartEdge+256,64+256+CurOrigin2);
	Canvas.DrawIcon(texture'DanteO', 1.0);
	Canvas.SetPos(StartEdge+256,64+256*2+CurOrigin2);	
	Canvas.DrawIcon(texture'CallNow', 1.0);	
	Canvas.SetPos(StartEdge+256,64*2+256*2+CurOrigin2);
	Canvas.DrawIcon(texture'Shot1', 1.0);	
	Canvas.SetPos(StartEdge+256,64*2+256*3+CurOrigin2);
	Canvas.DrawIcon(texture'Weapons', 1.0);	
	Canvas.SetPos(StartEdge+256,64*2+256*4+CurOrigin2);	
	Canvas.DrawIcon(texture'CallNow', 1.0);	
	Canvas.SetPos(StartEdge+256,64*3+256*4+CurOrigin2);
	Canvas.DrawIcon(texture'Shot2', 1.0);	

	Canvas.SetPos(StartEdge+256,64*3+256*4+CurOrigin2);
	Canvas.DrawIcon(texture'Shot3', 1.0);	
	Canvas.SetPos(StartEdge+256,64*3+256*5+CurOrigin2);	
	Canvas.DrawIcon(texture'CallNow', 1.0);	
	Canvas.SetPos(StartEdge+256,64*4+256*5+CurOrigin2);
	Canvas.DrawIcon(texture'Shot4', 1.0);
	
	Canvas.SetPos(StartEdge+256,64*4+256*6+CurOrigin2);
	Canvas.DrawIcon(texture'Shot3a', 1.0);	
	Canvas.SetPos(StartEdge+256,64*4+256*7+CurOrigin2);	
	Canvas.DrawIcon(texture'CallNow', 1.0);	
	Canvas.SetPos(StartEdge+256,64*5+256*7+CurOrigin2);
	Canvas.DrawIcon(texture'Shot5', 1.0);	

	Canvas.SetPos(StartEdge+256,64*5+256*8+CurOrigin2);
	Canvas.DrawIcon(texture'Shot6', 1.0);	
	Canvas.SetPos(StartEdge+256,64*5+256*9+CurOrigin2);	
	Canvas.DrawIcon(texture'CallNow', 1.0);	
	Canvas.SetPos(StartEdge+256,64*6+256*9+CurOrigin2);
	Canvas.DrawIcon(texture'Shot7', 1.0);
	Canvas.SetPos(StartEdge+256,64*6+256*10+CurOrigin2);
	Canvas.DrawIcon(texture'Shot8', 1.0);	
	Canvas.SetPos(StartEdge+256,64*6+256*11+CurOrigin2);
	Canvas.DrawIcon(texture'CallNow', 1.0);	


	if (!bDrawPicAfter) Canvas.SetPos(StartEdge,OClipY-32);
	else Canvas.SetPos(StartEdge+256,OClipY-32);
	Canvas.DrawIcon(texture'PageUp', 1.0);	
}

defaultproperties
{
     OrderText(0)="The Shareware version of Unreal that you have just played is only a small taste of what awaits you when you buy the full version of Unreal."
     OrderText(1)="In USA and Canada call  TOLL-FREE 1-877-4UNREAL  (1-877-486-7325) to Order Unreal NOW."
     OrderText(2)="With the full version of Unreal you get:"
     OrderText(3)="- Over 30 incredible single player levels"
     OrderText(4)="- 11 Specially designed multiplayer maps"
     OrderText(5)="- All ten weapons each with 2 firing modes and some with special moves too!  "
     OrderText(6)="- Over 30 Unreal creatures to encounter"
     OrderText(7)="- Discover a multitude of new inventory items"
     OrderText(8)="- Several varieties of internet, local area network and single player Bot Match play: Darkmatch, Deathmatch, King of the Hill, Team play and Cooperative"
     OrderText(9)="- Choose from 6 different player models and a large variety of model skins."
     OrderText(10)="- Access to all of the Unreal levels and add-ons found on the internet created by Unreal fans all over the world.  We created Unreal to be easily expandable and only days after being released, user created modifications began to appear on the Web."
     OrderText(11)="You also receive a fully functional ** Beta version of the Unreal Editor:"
     OrderText(12)="- Probably the easiest-to-use 3D level design tool ever created!"
     OrderText(13)="- Uses Constructive Solid Geometry - make rooms by simply cutting blocks out of solid shapes"
     OrderText(14)="- Allows users to import their own textures, objects, music and sound effect using industry file formats such WAV, DXF, BMP etc."
     OrderText(15)="- Create your own maps or modify ours to your liking"
     OrderText(16)="- Includes the UnrealScript the completely integrated object-oriented programming language we've used to create the majority of Unreal gameplay."
     OrderText(17)="- Distribute your maps freely on the internet for others to play"
     OrderText(18)="** Although Epic and GT do not support the beta Unreal Editor there are several support sites on the internet you can find by checking the links page at http://www.unreal.com - many of these sites have tutorials and examples to get you started."
     OrderText(19)="And you'll have the full Unreal Server and Internet play capability"
     OrderText(20)="- Run your own dedicated Unreal Server"
     OrderText(21)="- Be a non-dedicated server by allowing others to join in to a game you're playing"
     OrderText(22)="- Host your own Unreal Lobby levels with links to other Unreal Servers and World Wide Web sites* that act like 3D web pages"
     OrderText(23)="* Web linking from Unreal levels requires those accessing the level to have an Unreal-supported web browser."
     OrderText(24)="You can buy Unreal at your local software retailer or order it directly from Epic MegaGames. Here's how you order directly from Epic... "
     OrderText(25)="You can place credit cards orders directly from our web site using our secure ordering page at http://www.epicgames.com/UnrealOrders  "
     OrderText(26)="USA / Canada"
     OrderText(27)="Unreal is $39.95 US dollars includes shipping & handling"
     OrderText(28)="In USA and Canada call TOLL-FREE 1-877-4UNREAL (1-877-486-7325). Note this call is a FREE call from anywhere in the USA or Canada. You can also fax your orders to (301) 299-3841 - the orderform is located in the file ORDERUSA.TXT. We accept VISA and Mast"
     OrderText(29)="Or order from our secure ordering page at http://www.epicgames.com/UnrealOrders"
     OrderText(30)="United Kingdom  & Europe"
     OrderText(31)="Unreal is 29.99 pounds which includes VAT and all postage and handling charges. Call +44 1202 52 10 11 to order. Non EC counties please add 2 extra for postage. You can also fax your orders to +44 1202 52 10 12 - the orderform is located in the file ORDE"
     OrderText(32)="Other Countries"
     OrderText(33)="Unreal can be ordered from our head office in Maryland, USA for the prices of US$39.95 plus US$6 shipping and handling. Call +1 (301) 468-6012 to order. You are responsible for any duties or taxes charged by your country. You can also fax your orders to "
     OrderText(34)="Our Online Partners"
     OrderText(35)="Check out the web sites and Unreal game servers offered by these outstanding online partners:"
     OrderText(36)="MPLAYER.COM - The world's Hottest FREE multi-player game service on the Internet. With mplayer.com, you'll play Unreal against thousands of real, live, unpredictable human opponents. People you'll match wits, reflexes, and adrenaline surges with. "
     OrderText(37)="People who'll deliver a whole new level of excitement to Unreal."
     OrderText(38)="WON.NET - The World Opponent Network is the easiest way to jump into a FREE Unreal Deathmatch over the Internet. With IE4.0 or Netscape 4.0, a 'one-button' launch to FREE fragging awaits you at http://www.won.net/unreal."
     OrderText(39)="Join the growing Unreal community via level building contests, message boards, links, low ping times, new skins and levels and FREE online play... it's Unreal on WON."
     OrderText(40)="WIREPLAY - The ultimate dial-up gaming experience. While most rival services utilise clunky Internet connections, Wireplay hooks up gamers via the telephone system and its own cutting edge network platform for blistering multiplayer performance."
     OrderText(41)="Wireplay is currently operating in Europe and Australia.  For more information visit http:// www.wireplay.com/uk/unreal"
     OrderText(42)="Heat.Net - Looking to get paid to play Unreal?  Log into HEAT and earn points redeemable for free games in HEAT's on-line store.  You don't have to be an Unreal God to win - HEAT awards points to players of all skill levels - just for playing games."
     OrderText(43)="http://www.heat.net - free kick-ass Internet gaming."
     OrderText(44)="AT&T WorldNet - Play Unreal on AT&T's GameHub server--over a T3 trunk line entirely on AT&T WorldNet's backbone - promising fast and reliable gaming for you."
     OrderText(45)="www.gamehub.net/unreal  GameHub - you complete Internet gaming service: chat rooms, email, online game magazines, tournaments and top multiplayer online games."
     OrderText(46)="GameSpy 3D is an Internet service browser.  It crawls all over the net and finds you the best servers to play Unreal on:  the ones with the fastest connection to your machine."
     OrderText(47)="Just fire it up, pick a game you want to play, double-click, and wham!  You're kicking some Internet butt!  http://www.gamespy.com for more information."
     OrderText(48)="Order Cool Unreal Merchandise "
     OrderText(49)="Check out http://www.epicgames.com/UnrealOrders for information on some of the cool Unreal gear that can be ordered directly from Epic MegaGames. You can get hats, shirts, mouse pads, mugs, posters and more at very reasonable prices. "
     OrderText(50)="Special Offers "
     OrderText(51)="From time to time Epic MegaGames may offer special offers which may be combinations of Unreal software products and/or Unreal merchandise. Be sure to check http://www.unreal.com for up to the minute information and pricing.  "
     MenuTitle="ORDERING INFORMATION"
}
