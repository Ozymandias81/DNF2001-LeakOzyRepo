class UMenuConsoleWindow extends UWindowConsoleWindow;

function Created() 
{
	Super.Created();

	UWindowConsoleClientWindow(ClientArea).TextArea.Font = F_Normal;
}

function Close(optional bool bByParent)
{
	Super.Close(bByParent);

	if(Root.bQuickKeyEnable)
		Root.Console.CloseUWindow();
}