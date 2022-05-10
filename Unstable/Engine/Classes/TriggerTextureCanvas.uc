//=============================================================================
// TriggerTextureCanvas. (NJS)	
//=============================================================================
class TriggerTextureCanvas expands Triggers;

var () TextureCanvas DrawCanvas;

var () enum EDrawType
{
	TC_DrawClear,	// Clears the canvas to ColorIndex
	TC_DrawPixel,
	TC_DrawLine,
	TC_DrawString,
	TC_DrawBitmap,
	TC_DrawCircle,
	TC_DrawRectangle,
	TC_DrawStatic
} DrawType;

var () byte			ColorIndex;
var () texture		SourceTexture;
var () int			x,y,x1,y1,radius;
var () int			left,right,top,bottom;
var () font			StringFont;
var () string		Message;
var () bool			Filled;
var () bool			Proportional, Wrap;
var () bool			Masking;
var () name			VariableX, VariableY;
var () name			MessageFromVariable;

function Trigger( actor Other, pawn EventInstigator )
{
	local variable v;

	if(DrawCanvas==none) return;

	// Should I get my x value from a variable?
	if(VariableX!='')
		foreach allactors(class'Variable',v,VariableX)
		{
			x=v.Value;
			break;
		}

	// Should I get my y value from a variable?
	if(VariableY!='')
		foreach allactors(class'Variable',v,VariableY)
		{
			y=v.Value;
			break;
		}

	// Should I get my message from a variable's value?
	if(MessageFromVariable!='')
		foreach allactors(class'Variable',v,MessageFromVariable)
		{
			Message=string(v.Value);
			break;
		}
		
	switch(DrawType)
	{
		case TC_DrawClear:	DrawCanvas.DrawClear(ColorIndex); 		break;
		case TC_DrawPixel:	DrawCanvas.DrawPixel(x,y,ColorIndex); 		break;
		case TC_DrawLine:	DrawCanvas.DrawLine(x,y,x1,y1,ColorIndex); 	break;

		case TC_DrawString: if(bool(StringFont))
								DrawCanvas.DrawString(StringFont,x,y,Message,Proportional,Wrap,Masking);
							break;

		// Draw a bitmap section (left,top)-(right,bottom) of SourceTexture at x,y. 
		case TC_DrawBitmap: if(bool(SourceTexture))
							{
								if(!bool(left)&&!bool(right)) right=SourceTexture.USize-1;
								if(!bool(top)&&!bool(bottom)) bottom=SourceTexture.VSize-1;
								DrawCanvas.DrawBitmap(x,y,left,top,right,bottom,SourceTexture,Masking,Wrap); 
							}
							break;

		case TC_DrawCircle:	   DrawCanvas.DrawCircle(x,y,radius,ColorIndex,filled); break;
		case TC_DrawRectangle: DrawCanvas.DrawRectangle(left,top,right,bottom,ColorIndex,filled); break;
		case TC_DrawStatic:	   DrawCanvas.DrawStatic(); break;
	}
}

defaultproperties
{
     Texture=Texture'Engine.S_TrigTextCanvas'

}
