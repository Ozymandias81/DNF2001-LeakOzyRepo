class UTImageServer expands ImageServer;

event Query(WebRequest Request, WebResponse Response)
{
	local string AdminUsername, AdminPassword, AdminRealm;

	AdminUsername = class'UTServerAdmin'.default.AdminUsername;
	AdminPassword = class'UTServerAdmin'.default.AdminPassword;
	AdminRealm    = class'UTServerAdmin'.default.AdminRealm;

	// Check authentication:
	if ((AdminUsername != "" && Caps(Request.Username) != Caps(AdminUsername)) || (AdminPassword != "" && Caps(Request.Password) != Caps(AdminPassword))) {
		Response.FailAuthentication(AdminRealm);
		return;
	}

	Super.Query(Request, Response);
}
