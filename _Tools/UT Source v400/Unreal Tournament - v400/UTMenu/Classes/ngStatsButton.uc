class ngStatsButton extends UWindowSmallButton;

function Created()
{
	Super.Created();
	SetText("ngStats");
}

function Paint(Canvas C, float X, float Y)
{
	local float XL, YL;

	C.Font = Root.Fonts[Font];

	if(bDisabled) {
		if(DisabledTexture != None)
		{
			if(bUseRegion)
				DrawStretchedTextureSegment( C, ImageX, ImageY, DisabledRegion.W*RegionScale, DisabledRegion.H*RegionScale, 
											DisabledRegion.X, DisabledRegion.Y, 
											DisabledRegion.W, DisabledRegion.H, DisabledTexture );
			else if(bStretched)
				DrawStretchedTexture( C, ImageX, ImageY, WinWidth, WinHeight, DisabledTexture );
			else
				DrawClippedTexture( C, ImageX, ImageY, DisabledTexture);
		}
	} else {
		if(bMouseDown)
		{
			if(DownTexture != None)
			{
				if(bUseRegion)
					DrawStretchedTextureSegment( C, ImageX, ImageY, DownRegion.W*RegionScale, DownRegion.H*RegionScale, 
												DownRegion.X, DownRegion.Y, 
												DownRegion.W, DownRegion.H, DownTexture );
				else if(bStretched)
					DrawStretchedTexture( C, ImageX, ImageY, WinWidth, WinHeight, DownTexture );
				else
					DrawClippedTexture( C, ImageX, ImageY, DownTexture);
			}
		} else {
			if(MouseIsOver()) {
				if(OverTexture != None)
				{
					if(bUseRegion)
						DrawStretchedTextureSegment( C, ImageX, ImageY, OverRegion.W*RegionScale, OverRegion.H*RegionScale, 
													OverRegion.X, OverRegion.Y, 
													OverRegion.W, OverRegion.H, OverTexture );
					else if(bStretched)
						DrawStretchedTexture( C, ImageX, ImageY, WinWidth, WinHeight, OverTexture );
					else
						DrawClippedTexture( C, ImageX, ImageY, OverTexture);
				}
			} else {
				if(UpTexture != None)
				{
					if(bUseRegion)
						DrawStretchedTextureSegment( C, ImageX, ImageY, UpRegion.W*RegionScale, UpRegion.H*RegionScale, 
													UpRegion.X, UpRegion.Y, 
													UpRegion.W, UpRegion.H, UpTexture );
					else if(bStretched)
						DrawStretchedTexture( C, ImageX, ImageY, WinWidth, WinHeight, UpTexture );
					else
						DrawClippedTexture( C, ImageX, ImageY, UpTexture);
				}
			}
		}
	}

	if(Text != "")
	{
		C.DrawColor.R = 255;
		C.DrawColor.G = 0;
		C.DrawColor.B = 0;
		ClipText(C, TextX, TextY, "ng");
		TextSize(C, "ng", XL, YL);
		C.DrawColor.R = 0;
		C.DrawColor.G = 0;
		C.DrawColor.B = 255;
		ClipText(C, TextX+XL, TextY, "Stats");
		C.DrawColor.R = 255;
		C.DrawColor.G = 255;
		C.DrawColor.B = 255;
	}
}
