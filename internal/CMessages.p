/*
	@file: /internal/CMessages.p
	@author: 
		l0nger <l0nger.programmer@gmail.com>
		
	@licence: GPLv2
	
	(c) 2013-2014, <l0nger.programmer@gmail.com>
*/

static stock
	gs_sBufferMessages[160];
	
stock theplayer::sendMessage(playerid, color, text[], va_args<>) 
{
	gs_sBufferMessages[0]=EOS;
	string::copy(gs_sBufferMessages, text, sizeof(gs_sBufferMessages));
	
	new szColor[2]; // 0=normal, 1=highlight
	switch(color) {
		case COLOR_INFO1: 
		{
			szColor[0]=ConfigColorData[COLOR_INFO1][0];
			szColor[1]=ConfigColorData[COLOR_INFO1][1];
		}
		case COLOR_INFO2: 
		{
			szColor[0]=ConfigColorData[COLOR_INFO2][0];
			szColor[1]=ConfigColorData[COLOR_INFO2][1];
		}
		case COLOR_INFO3: 
		{
			szColor[0]=ConfigColorData[COLOR_INFO3][0];
			szColor[1]=ConfigColorData[COLOR_INFO3][1];
		}
		case COLOR_ERROR: 
		{
			szColor[0]=ConfigColorData[COLOR_ERROR][0];
			szColor[1]=ConfigColorData[COLOR_ERROR][1];
		}
		case COLOR_PM: 
		{
			szColor[0]=ConfigColorData[COLOR_PM][0];
			szColor[1]=ConfigColorData[COLOR_PM][1];
		}
		case COLOR_LOCAL: 
		{
			szColor[0]=ConfigColorData[COLOR_LOCAL][0];
			szColor[1]=ConfigColorData[COLOR_LOCAL][1];
		}
	}
	
	CMessages_BoldText(szColor, gs_sBufferMessages);
	if(numargs()>3) 
	{
		va_format(gs_sBufferMessages, sizeof(gs_sBufferMessages), text, va_start<3>);
		return SendClientMessage(playerid, szColor[0], gs_sBufferMessages);
	} else {
		return SendClientMessage(playerid, szColor[0], gs_sBufferMessages);
	}
}

stock theplayer::sendMessageToAll(color, text[], va_args<>) 
{
	gs_sBufferMessages[0]=EOS;
	string::copy(gs_sBufferMessages, text, sizeof(gs_sBufferMessages));
	
	new szColor[2]; // 0=normal, 1=highlight
	switch(color) 
	{
		case COLOR_INFO1:
		{
			szColor[0]=ConfigColorData[COLOR_INFO1][0];
			szColor[1]=ConfigColorData[COLOR_INFO1][1];
		}
		case COLOR_INFO2:
		{
			szColor[0]=ConfigColorData[COLOR_INFO2][0];
			szColor[1]=ConfigColorData[COLOR_INFO2][1];
		}
		case COLOR_INFO3: 
		{
			szColor[0]=ConfigColorData[COLOR_INFO3][0];
			szColor[1]=ConfigColorData[COLOR_INFO3][1];
		}
		case COLOR_ERROR: 
		{
			szColor[0]=ConfigColorData[COLOR_ERROR][0];
			szColor[1]=ConfigColorData[COLOR_ERROR][1];
		}
		case COLOR_PM: 
		{
			szColor[0]=ConfigColorData[COLOR_PM][0];
			szColor[1]=ConfigColorData[COLOR_PM][1];
		}
		case COLOR_LOCAL: 
		{
			szColor[0]=ConfigColorData[COLOR_LOCAL][0];
			szColor[1]=ConfigColorData[COLOR_LOCAL][1];
		}
	}
	
	CMessages_BoldText(szColor, gs_sBufferMessages);
	if(numargs()>2) 
	{
		va_format(gs_sBufferMessages, sizeof(gs_sBufferMessages), text, va_start<2>);
		return SendClientMessageToAll(szColor[0], gs_sBufferMessages);
	} else {
		return SendClientMessageToAll(szColor[0], gs_sBufferMessages);
	}
}

#define theadmins:: theadmins_

stock theadmins::sendMessage(color, levelmin=RANK_ADMIN, msg[], va_args<>) 
{
	new args=numargs();
	theplayer::foreach(i) 
	{
		if(theplayer::isAdmin(i, levelmin)) 
		{
			if(args>3) theplayer::sendMessage(i, color, msg, va_start<3>);
			else theplayer::sendMessage(i, color, msg);
		}
	}
}

stock CMessages_BoldText(szColors[2], text[]) 
{
	new 
		tmpBufColor[9],
		szBuffer[160];
	
	string::copy(szBuffer, text, sizeof(szBuffer));
	format(tmpBufColor, sizeof(tmpBufColor), "{%06x}", szColors[1]>>>8);
	string::replace(text, "<b>", tmpBufColor);
	format(tmpBufColor, sizeof(tmpBufColor), "{%06x}", szColors[0]>>>8);
	string::replace(text, "</b>", tmpBufColor);
}