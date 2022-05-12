class LadderButton extends NotifyButton;

var bool bTop;
var bool bBottom;

var bool bSelected;

function BeforePaint(Canvas C, float X, float Y)
{
	Super.BeforePaint(C, X, Y);

	if (bSelected)
	{
		if (bTop && bBottom)
		{
			UpTexture = Texture(DynamicLoadObject("UTMenu.PlateYellow2", Class'Texture'));
			OverTexture = Texture(DynamicLoadObject("UTMenu.PlateYellow2", Class'Texture'));
			DownTexture = Texture(DynamicLoadObject("UTMenu.PlateYellow2", Class'Texture'));
			DisabledTexture = Texture(DynamicLoadObject("UTMenu.PlateYellow2", Class'Texture'));
		} else if (bTop) {
			UpTexture = Texture(DynamicLoadObject("UTMenu.PlateYellowCap", Class'Texture'));
			OverTexture = Texture(DynamicLoadObject("UTMenu.PlateYellowCap", Class'Texture'));
			DownTexture = Texture(DynamicLoadObject("UTMenu.PlateYellowCap", Class'Texture'));
			DisabledTexture = Texture(DynamicLoadObject("UTMenu.PlateYellowCap", Class'Texture'));
		} else if (bBottom) {
			UpTexture = Texture(DynamicLoadObject("UTMenu.PlateYellowLowCap", Class'Texture'));
			OverTexture = Texture(DynamicLoadObject("UTMenu.PlateYellowLowCap", Class'Texture'));
			DownTexture = Texture(DynamicLoadObject("UTMenu.PlateYellowLowCap", Class'Texture'));
			DisabledTexture = Texture(DynamicLoadObject("UTMenu.PlateYellowLowCap", Class'Texture'));
		} else {
			UpTexture = Texture(DynamicLoadObject("UTMenu.PlateYellow", Class'Texture'));
			OverTexture = Texture(DynamicLoadObject("UTMenu.PlateYellow", Class'Texture'));
			DownTexture = Texture(DynamicLoadObject("UTMenu.PlateYellow", Class'Texture'));
			DisabledTexture = Texture(DynamicLoadObject("UTMenu.PlateYellow", Class'Texture'));
		}
	} else {
		if (bTop && bBottom)
		{
			UpTexture = Texture(DynamicLoadObject("UTMenu.Plate2", Class'Texture'));
			OverTexture = Texture(DynamicLoadObject("UTMenu.Plate2", Class'Texture'));
			DownTexture = Texture(DynamicLoadObject("UTMenu.Plate2", Class'Texture'));
			DisabledTexture = Texture(DynamicLoadObject("UTMenu.Plate2", Class'Texture'));
		} else if (bTop) {
			UpTexture = Texture(DynamicLoadObject("UTMenu.Plate3Cap", Class'Texture'));
			OverTexture = Texture(DynamicLoadObject("UTMenu.PlateCap", Class'Texture'));
			DownTexture = Texture(DynamicLoadObject("UTMenu.PlateCap", Class'Texture'));
			DisabledTexture = Texture(DynamicLoadObject("UTMenu.Plate3Cap", Class'Texture'));
		} else if (bBottom) {
			UpTexture = Texture(DynamicLoadObject("UTMenu.Plate3LowCap", Class'Texture'));
			OverTexture = Texture(DynamicLoadObject("UTMenu.PlateLowCap", Class'Texture'));
			DownTexture = Texture(DynamicLoadObject("UTMenu.PlateLowCap", Class'Texture'));
			DisabledTexture = Texture(DynamicLoadObject("UTMenu.Plate3LowCap", Class'Texture'));
		} else {
			UpTexture = Texture(DynamicLoadObject("UTMenu.Plate3", Class'Texture'));
			OverTexture = Texture(DynamicLoadObject("UTMenu.Plate", Class'Texture'));
			DownTexture = Texture(DynamicLoadObject("UTMenu.Plate", Class'Texture'));
			DisabledTexture = Texture(DynamicLoadObject("UTMenu.Plate3", Class'Texture'));
		}
	}
}
