class UTMenuBotmatchCW expands UMenuBotmatchClientWindow;

function CreatePages()
{
	local class<UWindowPageWindow> PageClass;

	Pages = UMenuPageControl(CreateWindow(class'UMenuPageControl', 0, 0, WinWidth, WinHeight));
	Pages.SetMultiLine(True);
	Pages.AddPage(StartMatchTab, class'UTMenuStartMatchSC');

	PageClass = class<UWindowPageWindow>(DynamicLoadObject(GameClass.Default.RulesMenuType, class'Class'));
	if(PageClass != None)
		Pages.AddPage(RulesTab, PageClass);

	PageClass = class<UWindowPageWindow>(DynamicLoadObject(GameClass.Default.SettingsMenuType, class'Class'));
	if(PageClass != None)
		Pages.AddPage(SettingsTab, PageClass);

	PageClass = class<UWindowPageWindow>(DynamicLoadObject(GameClass.Default.BotMenuType, class'Class'));
	if(PageClass != None)
		Pages.AddPage(BotConfigTab, PageClass);
}
