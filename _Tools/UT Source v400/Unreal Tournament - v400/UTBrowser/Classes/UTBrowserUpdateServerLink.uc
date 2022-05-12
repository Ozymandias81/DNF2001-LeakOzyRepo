class UTBrowserUpdateServerLink expands UBrowserUpdateServerLink;

function SetupURIs()
{
	if( class'GameInfo'.default.DemoBuild != 0 )
	{
		MaxURI = 3;
		URIs[3] = "/UpdateServer/utdemomotd"$Level.EngineVersion$".html";
		URIs[2] = "/UpdateServer/utdemomotdfallback.html";
		URIs[1] = "/UpdateServer/utdemomasterserver.txt";
		URIs[0] = "/UpdateServer/utdemoircserver.txt";
	}
	else
	{
		MaxURI = 3;
		URIs[3] = "/UpdateServer/utmotd"$Level.EngineVersion$".html";
		URIs[2] = "/UpdateServer/utmotdfallback.html";
		URIs[1] = "/UpdateServer/utmasterserver.txt";
		URIs[0] = "/UpdateServer/utircserver.txt";
	}
}
