//=============================================================================
// DebugAnimView
// Display for debugging animation information.
//=============================================================================
class DebugAnimView expands DebugView
    transient;

var int animCnt;

exec function AnimCount(int count)
{
    animCnt = count;
}

simulated function PostRender(canvas Canvas)
{
    local int i, posX, posY;
    local string s;
	local vector CamLoc;
	local rotator CamRot;
	local float f;
    local MeshInstance Minst;

    Canvas.SetPos(posX, posY);
    Canvas.Font         = Canvas.SmallFont;
    Canvas.Style        = ERenderStyle.STY_Normal;
    Canvas.DrawColor.R  = 0;
    Canvas.DrawColor.G  = 255;
    Canvas.DrawColor.B  = 0;
    Canvas.SpaceY       = 0;
    
    if (WatchTarget != None)
    {        
        Canvas.DrawText("Animation Info:"$WatchTarget );
        
        posY = 20;        
        posX = 150;
        
        Canvas.CurY = posY;

        Minst = WatchTarget.GetMeshInstance();

        if ( Minst == None )
        {
            Canvas.DrawText("Watch Target has no mesh instance",false);
            Canvas.CurX = posX;
            return;
        }

        for ( i=0; i<animCnt; i++ )
        {
            Canvas.CurX = posX;
            Canvas.DrawText( "  AnimSequence["$i$"]:"$Minst.MeshChannels[i].AnimSequence, false );
            Canvas.CurX = posX;
            Canvas.DrawText( "  AnimFrame["$i$"]:"$Minst.MeshChannels[i].AnimFrame, false );
            Canvas.CurX = posX;
            Canvas.DrawText( "  AnimRate["$i$"]:"$Minst.MeshChannels[i].AnimRate, false );
            Canvas.CurX = posX;            
            Canvas.DrawText( "  AnimBlend["$i$"]:"$Minst.MeshChannels[i].AnimBlend, false );
            Canvas.CurX = posX;            
            Canvas.DrawText( "  TweenRate["$i$"]:"$Minst.MeshChannels[i].TweenRate, false );
            Canvas.CurX = posX;            
            Canvas.DrawText( "  AnimLast["$i$"]:"$Minst.MeshChannels[i].AnimLast, false );
            Canvas.CurX = posX;            
            Canvas.DrawText( "  AnimMinRate["$i$"]:"$Minst.MeshChannels[i].AnimMinRate, false );
            Canvas.CurX = posX;            
            Canvas.DrawText( "  OldAnimRate["$i$"]:"$Minst.MeshChannels[i].OldAnimRate, false );
            Canvas.CurX = posX;            
            Canvas.DrawText( "  bAnimFinished["$i$"]:"$Minst.MeshChannels[i].bAnimFinished, false );
            Canvas.CurX = posX;            
            Canvas.DrawText( "  bAnimLoop["$i$"]:"$Minst.MeshChannels[i].bAnimLoop, false );
            Canvas.CurX = posX;            
            Canvas.DrawText( "  bAnimNotify["$i$"]:"$Minst.MeshChannels[i].bAnimNotify, false );
            Canvas.CurX = posX;            
            Canvas.DrawText( "  bAnimBlendAdditive["$i$"]:"$Minst.MeshChannels[i].bAnimBlendAdditive, false );
            Canvas.CurX = posX;            
            Canvas.DrawText( "  SimAnim["$i$"].X:"$Minst.MeshChannels[i].SimAnim.X, false );
            Canvas.CurX = posX;            
            Canvas.DrawText( "  SimAnim["$i$"].Y:"$Minst.MeshChannels[i].SimAnim.Y, false );
            Canvas.CurX = posX;            
            Canvas.DrawText( "  SimAnim["$i$"].Z:"$Minst.MeshChannels[i].SimAnim.Z, false );
            Canvas.CurX = posX;            
            Canvas.DrawText( "  SimAnim["$i$"].W:"$Minst.MeshChannels[i].SimAnim.W, false );
            Canvas.CurX = posX;
            Canvas.CurY += 15;

            if ( i==3 )
            {
                Canvas.CurY = PosY;
                posX += 250;
            }
       }
    }
    else
    {
        Canvas.DrawText("No Watch Target",false);
        Canvas.CurX = posX;
    }
}

defaultproperties
{
    animCnt=2
}
