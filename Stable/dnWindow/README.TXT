////////////////////////
// README.TXT
//
//  DATE:   2000-02-02	TLW  
//
//
//  MODULE:  dnWindow
//  PURPOSE: To provide windowing support not found in UT for DNF
//
//  
//  Most of the stuff in dnWindow is in two parts, and probably could be two packages:
//		Menuing
//		DukeNet
//	but since DukeNet resides inside the menuing, I've left it as one.
//	
//
//	most of the stuff that was added sits on top of UT's windowing system 
//	(UWindow/UMenu/UBrowser) 
//
//	The code attempts to stay away from UTBrowser/UTMenu but some times it was unavoidable
//
//	Alot of hard-coded numbers and inflexible design of UT's windowing system was reworked
//	to get the additions to work, and make user mods that much easier. 
//	Most of those additions or changes that I did to stock Unreal scripts I tried to comment
//	out with the reason (searching for TLW: should find most of them) 
//
//	The majority of changes were made in:
//		- LookAndFeel structure for the new windowing look
//		- UWindowWindow's Draw<Vert/Hor>Tiles, Draw<Stretched/Clipped>Texture for transparancy effects
//		- structure for DialogControls text and ClipText routines for incremental text decoding 
//		- Playing sounds for different UI actions
//		- ability to set the color of text and windows in all the drawing functions
//		- cleaning up the existing code as I went
//
//---------------------------------------------------------


