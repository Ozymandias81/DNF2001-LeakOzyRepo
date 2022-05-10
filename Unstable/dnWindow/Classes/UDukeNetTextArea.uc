//=============================================================================
// 
// FILE:			UDukeNetTextArea.uc
// 
// AUTHOR:			Timothy L. Weisser
// 
// DESCRIPTION:		DNF UI Script file
// 
// NOTES:			UWindowDynamicTextArea works fine for Channel text, but
//					wanted a unique color for each users text to help distinguish
//					(unlike BattleNet that only had a color for user name and color for text)
//					if the text passed to DrawTextLine() is a UDukeColoredDynamicTextRow
//					its drawn in two parts, label and body, otherwise UWindowDynamicTextArea's
//					version is called
//
// MOD HISTORY:		
//	2000-01-??		Another request was for the text to not scroll, unless
//					the player hasn't scrolled the text to read something
//					(i.e. its at the default location at the bottom)
// 
//==========================================================================
class UDukeNetTextArea extends UWindowDynamicTextArea;

var() int fontLabel;		//Default:	F_Bold = 1;	
var() int fontBody;			//Default:  F_Normal = 0;

var() bool bScrollOnlyIfPosAtDefaultLoc;	//only scrolls text, if the indicator is at the max pos

function float DrawTextLine(Canvas C, UWindowDynamicTextRow L, float Y)
{
	local float fStart_X;
	local UDukeColoredDynamicTextRow dnTextRow;
	local String strPartial;
	local color colorOld;
	local font fontOld;
	local float fTextWidth,
				fTextHeight;

	dnTextRow = UDukeColoredDynamicTextRow(L);

	//Change the text color, if the UWindowDynamicTextRow is a UDukeColoredDynamicTextRow
	if(dnTextRow != None && dnTextRow.iLengthOfLabel > 0)  {
		colorOld = C.DrawColor;
		fontOld = C.Font;
		fStart_X = FindTextLineStartingPos(C, dnTextRow.Text);
		
		strPartial = Left(dnTextRow.Text, dnTextRow.iLengthOfLabel);
		C.DrawColor = dnTextRow.colorLabelText;
		C.Font = Root.Fonts[fontLabel];
		TextAreaClipText(C, 
						 fStart_X, 
						 Y, 
						 strPartial
		);

		TextAreaTextSize(C, strPartial, fTextWidth, fTextHeight);

		strPartial = Mid(dnTextRow.Text, dnTextRow.iLengthOfLabel);
		C.DrawColor = dnTextRow.colorBodyText;
		C.Font = Root.Fonts[fontBody];
		TextAreaClipText(C, 
						 fStart_X + fTextWidth, 
						 Y, 
						 strPartial
		);

		C.DrawColor = colorOld;
		C.Font = fontOld;
		return DefaultTextHeight;
	}
//	else
		return Super.DrawTextLine(C, L, Y);
}

function bool ScrollOnResize()
{
	if(bScrollOnlyIfPosAtDefaultLoc)  {
		if(bTopCentric)  
			return (VertSB.Pos == 0); 
	//	else  
			return (VertSB.Pos == VertSB.MaxPos);
	}
	else
		Super.ScrollOnResize();
}

defaultproperties
{
     fontLabel=1
     bScrollOnlyIfPosAtDefaultLoc=True
     MaxLines=128
     RowClass=Class'dnWindow.UDukeColoredDynamicTextRow'
}
