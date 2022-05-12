class SpeechButton expands NotifyButton;

var float FadeFactor;
var bool bHighlightButton;
var texture SelectedTexture;
var int Type;

function Paint(Canvas C, float X, float Y)
{
	local float Wx, Hy;
	local int W, H;
	local color HUDColor;

	// Set the color to that of the HUD.
	HUDColor.R = 255;
	HUDColor.G = 255;
	HUDColor.B = 255;
	if (GetPlayerOwner().MyHUD.IsA('ChallengeHUD'))
	{
		if (ChallengeHUD(GetPlayerOwner().MyHUD).Style != 3)
			C.Style = 2;
		else
			C.Style = 3;
		if (ChallengeHUD(GetPlayerOwner().MyHUD).bUseTeamColor)
		{
			if (GetPlayerOwner().MyHUD.IsA('ChallengeTeamHUD'))
			{
				HUDColor = ChallengeTeamHUD(GetPlayerOwner().MyHUD).TeamColor[GetPlayerOwner().PlayerReplicationInfo.Team];
			} else {
				HUDColor = ChallengeHUD(GetPlayerOwner().MyHUD).FavoriteHUDColor;
			}
		} else {
			HUDColor = ChallengeHUD(GetPlayerOwner().MyHUD).FavoriteHUDColor;
		}
		if (ChallengeHUD(GetPlayerOwner().MyHUD).Opacity != 16)
		{
			HUDColor.R = HUDColor.R * (ChallengeHUD(GetPlayerOwner().MyHUD).Opacity + 0.9);
			HUDColor.G = HUDColor.G * (ChallengeHUD(GetPlayerOwner().MyHUD).Opacity + 0.9);
			HUDColor.B = HUDColor.B * (ChallengeHUD(GetPlayerOwner().MyHUD).Opacity + 0.9);
		} else {
			HUDColor.R *= 15.9;
			HUDColor.G *= 15.9;
			HUDColor.B *= 15.9;
		}
	}
	C.DrawColor = HUDColor;
	if (MouseIsOver() && bHighlightButton)
	{
		C.DrawColor.R = Clamp(C.DrawColor.R + 100, 0, 255);
		C.DrawColor.G = Clamp(C.DrawColor.G + 100, 0, 255);
		C.DrawColor.B = Clamp(C.DrawColor.B + 100, 0, 255);
		TextColor.R = 255;
		TextColor.G = 255;
		TextColor.B = 0;
	} else {
		TextColor.R = 255;
		TextColor.G = 255;
		TextColor.B = 255;
	}

	Super.Paint(C, X, Y);

	W = WinWidth / 4;
	H = W;

	if(W > 256 || H > 256)
	{
		W = 256;
		H = 256;
	}

	if (LabelWidth == 0)
		LabelWidth = WinWidth;

	if (LabelHeight == 0)
		LabelHeight = WinHeight;

	C.DrawColor = TextColor;
	C.DrawColor.R = C.DrawColor.R * FadeFactor;
	C.DrawColor.G = C.DrawColor.G * FadeFactor;
	C.DrawColor.B = C.DrawColor.B * FadeFactor;
	C.Font = MyFont;
	TextSize(C, Text, Wx, Hy);
	if (bLeftJustify)
		ClipText(C, XOffset, 0, Text);
	else
		ClipText(C, (LabelWidth - Wx)/2, (LabelHeight - Hy)/2, Text);
}
