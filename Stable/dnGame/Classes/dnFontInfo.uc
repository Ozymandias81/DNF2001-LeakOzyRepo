class dnFontInfo expands Info;

var config string FontName;

function font GetHugeFont(Canvas C)
{
	local float Width;

	Width = C.ClipX;
	if (Width < 640)
		return Font'SmallFont';
	else if (Width < 800)
		return C.CreateTTFont(FontName, 18);
	else if (Width < 1024)
		return C.CreateTTFont(FontName, 24);
	else if (Width < 1600)
		return C.CreateTTFont(FontName, 30);
	else
		return C.CreateTTFont(FontName, 40);
}

function font GetBigFont(Canvas C)
{
	local float Width;

	Width = C.ClipX;
	if (Width < 640)
		return Font'SmallFont';
	else if (Width < 800)
		return C.CreateTTFont(FontName, 18);
	else if (Width < 1024)
		return C.CreateTTFont(FontName, 18);
	else
		return C.CreateTTFont(FontName, 24);
}

function font GetMediumFont(Canvas C)
{
	local float Width;

	Width = C.ClipX;
	if (Width < 640)
		return Font'SmallFont';
	else if (Width < 800)
		return C.CreateTTFont(FontName, 12);
	else if (Width < 1024)
		return C.CreateTTFont(FontName, 12);
	else
		return C.CreateTTFont(FontName, 18);
}

function font GetSmallFont(Canvas C)
{
	local float Width;

	Width = C.ClipX;
	if (Width < 640)
		return Font'SmallFont';
	else if (Width < 800)
		return C.CreateTTFont(FontName, 10);
	else if (Width < 1024)
		return C.CreateTTFont(FontName, 10);
	else
		return C.CreateTTFont(FontName, 12);
}

function font GetVerySmallFont(Canvas C)
{
	local float Width;

	Width = C.ClipX;
	if (Width < 640)
		return Font'SmallFont';
	else if (Width < 800)
		return C.CreateTTFont(FontName, 10);
	else if (Width < 1024)
		return C.CreateTTFont(FontName, 10);
	else
		return C.CreateTTFont(FontName, 10);
}

defaultproperties
{
	FontName="Vibrocentric"
//	FontName="StoneSans"
//	FontName="Arial"
}