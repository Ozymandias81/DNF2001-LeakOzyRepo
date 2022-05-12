class FontInfo expands Info;

var float SavedWidth[7];
var font SavedFont[7];

function font GetHugeFont(float Width)
{
	if ( (SavedFont[6] != None) && (Width == SavedWidth[6]) )
		return SavedFont[6];

	SavedWidth[6] = Width;
	SavedFont[6] = GetStaticHugeFont(Width);
	return SavedFont[6];
}

static function font GetStaticHugeFont(float Width)
{
	if (Width < 512)
		return Font'SmallFont';
	else if (Width < 640)
		return Font(DynamicLoadObject("LadderFonts.UTLadder16", class'Font'));
	else if (Width < 800)
		return Font(DynamicLoadObject("LadderFonts.UTLadder20", class'Font'));
	else if (Width < 1024)
		return Font(DynamicLoadObject("LadderFonts.UTLadder22", class'Font'));
	else
		return Font(DynamicLoadObject("LadderFonts.UTLadder30", class'Font'));
}

function font GetBigFont(float Width)
{
	if ( (SavedFont[5] != None) && (Width == SavedWidth[5]) )
		return SavedFont[5];

	SavedWidth[5] = Width;
	SavedFont[5] = GetStaticBigFont(Width);
	return SavedFont[5];
}

static function font GetStaticBigFont(float Width)
{
	if (Width < 512)
		return Font'SmallFont';
	else if (Width < 640)
		return Font(DynamicLoadObject("LadderFonts.UTLadder16", class'Font'));
	else if (Width < 800)
		return Font(DynamicLoadObject("LadderFonts.UTLadder18", class'Font'));
	else if (Width < 1024)
		return Font(DynamicLoadObject("LadderFonts.UTLadder20", class'Font'));
	else
		return Font(DynamicLoadObject("LadderFonts.UTLadder22", class'Font'));
}

function font GetMediumFont(float Width)
{
	if ( (SavedFont[4] != None) && (Width == SavedWidth[4]) )
		return SavedFont[4];

	SavedWidth[4] = Width;
	SavedFont[4] = GetStaticMediumFont(Width);
	return SavedFont[4];
}

static function font GetStaticMediumFont(float Width)
{
	if (Width < 512)
		return Font'SmallFont';
	else if (Width < 800)
		return Font(DynamicLoadObject("LadderFonts.UTLadder16", class'Font'));
	else
		return Font(DynamicLoadObject("LadderFonts.UTLadder22", class'Font'));
}

function font GetSmallFont(float Width)
{
	if ( (SavedFont[3] != None) && (Width == SavedWidth[3]) )
		return SavedFont[3];

	SavedWidth[3] = Width;
	SavedFont[3] = GetStaticSmallFont(Width);
	return SavedFont[3];
}

static function font GetStaticSmallFont(float Width)
{
	if (Width < 640)
		return Font'SmallFont';
	else if (Width < 800)
		return Font(DynamicLoadObject("LadderFonts.UTLadder10", class'Font'));
	else if (Width < 1024)
		return Font(DynamicLoadObject("LadderFonts.UTLadder14", class'Font'));
	else
		return Font(DynamicLoadObject("LadderFonts.UTLadder16", class'Font'));
}

function font GetSmallestFont(float Width)
{
	if ( (SavedFont[2] != None) && (Width == SavedWidth[2]) )
		return SavedFont[2];

	SavedWidth[2] = Width;
	SavedFont[2] = GetStaticSmallestFont(Width);
	return SavedFont[2];
}

static function font GetStaticSmallestFont(float Width)
{
	if (Width < 640)
		return Font'SmallFont';
	else if (Width < 800)
		return Font(DynamicLoadObject("LadderFonts.UTLadder10", class'Font'));
	else if (Width < 1024)
		return Font(DynamicLoadObject("LadderFonts.UTLadder12", class'Font'));
	else
		return Font(DynamicLoadObject("LadderFonts.UTLadder14", class'Font'));
}

function font GetAReallySmallFont(float Width)
{
	if ( (SavedFont[1] != None) && (Width == SavedWidth[1]) )
		return SavedFont[1];

	SavedWidth[1] = Width;
	SavedFont[1] = GetStaticAReallySmallFont(Width);
	return SavedFont[1];
}

static function font GetStaticAReallySmallFont(float Width)
{
	if (Width < 800)
		return Font'SmallFont';
	else if (Width < 1024)
		return Font(DynamicLoadObject("LadderFonts.UTLadder8", class'Font'));
	else
		return Font(DynamicLoadObject("LadderFonts.UTLadder10", class'Font'));
}

function font GetACompletelyUnreadableFont(float Width)
{
	if ( (SavedFont[0] != None) && (Width == SavedWidth[0]) )
		return SavedFont[0];

	SavedWidth[0] = Width;
	SavedFont[0] = GetStaticACompletelyUnreadableFont(Width);
	return SavedFont[0];
}

static function font GetStaticACompletelyUnreadableFont(float Width)
{
	if (Width < 800)
		return Font'SmallFont';
	else
		return Font(DynamicLoadObject("LadderFonts.UTLadder8", class'Font'));
}
