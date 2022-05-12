class UTServerAdminSpectator extends MessagingSpectator
	config;

struct PlayerMessage
{
	var PlayerReplicationInfo 	PRI;
	var String					Text;
	var Name					Type;
	var PlayerMessage 			Next;	// pointer to next message
};

var ListItem MessageList;

var byte ReceivedMsgNum;
var config byte ReceivedMsgMax;

var config bool bClientMessages;
var config bool bTeamMessages;
var config bool bVoiceMessages;
var config bool bLocalizedMessages;

function AddMessage(PlayerReplicationInfo PRI, String S, name Type)
{
	local ListItem TempMsg;
	
	TempMsg = new(None) class'ListItem';
	TempMsg.Data = FormatMessage(PRI, S, Type);
	
	if (MessageList == None)
		MessageList = TempMsg;
	else
		MessageList.AddElement(TempMsg);
		
	if ((ReceivedMsgNum++) >= ReceivedMsgMax)
		MessageList.DeleteElement(MessageList); // delete the first element
}

	
function String FormatMessage(PlayerReplicationInfo PRI, String Text, name Type)
{
	local String Message;
	
	// format Say and TeamSay messages
	if (PRI != None) {
		if (Type == 'Say')
			Message = PRI.PlayerName$": "$Text;
		else if (Type == 'TeamSay')
			Message = "["$PRI.PlayerName$"]: "$Text;
		else
			Message = "("$Type$") "$Text;
	}
	else if (Type == 'Console')
		Message = Text;
	else
		Message = "("$Type$") "$Text;
		
	return Message;
}

function ClientMessage( coerce string S, optional name Type, optional bool bBeep )
{
	if (bClientMessages)
		AddMessage(None, S, Type); 
}

function TeamMessage( PlayerReplicationInfo PRI, coerce string S, name Type, optional bool bBeep )
{
	if (bTeamMessages)
		AddMessage(PRI, S, Type);
}

function ClientVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID)
{
	// do nothing?
}

function ReceiveLocalizedMessage( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	// do nothing?
}

defaultproperties
{
	bClientMessages=True
	bTeamMessages=True
	bVoiceMessages=False
	bLocalizedMessages=True
	ReceivedMsgMax=32;
}