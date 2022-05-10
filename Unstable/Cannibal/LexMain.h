#ifndef __LEXMAIN_H__
#define __LEXMAIN_H__
//****************************************************************************
//**
//**    LEXMAIN.H
//**    Header - Lexical Analysis
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#include "Kernel.h"
//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
//============================================================================
//    CLASSES / STRUCTURES
//============================================================================

// Lexer token structure
struct SLexToken
{
    NDword tag; // user tag value for token type, passed in at registration
                  // always non-zero for tokens returned by PeekToken/GetToken
    NChar* lexeme; // pointer to beginning of lexeme within source buffer
    NDword lexemeLen; // length of lexeme string
    NDword textLine, textColumn; // zero-based line and column where the
                                   // token begins within the text
};

/*
	ILexLexer
*/
class ILexLexer
{
public:
	// Destroy - Destroy and free the interface	
	virtual NBool Destroy()=0;

	// CaseSensitivity - sets whether the token retrieval should be case sensitive or not
	//					 The default is 1 (case sensitive)
	virtual NBool CaseSensitivity(NBool inIsCaseSensitive)=0;

	// RegisterToken - registers a token type for lexer recognition, associated with
	//                 a nonzero tag value which is returned by the PeekToken and
	//                 GetToken functions (and set inside the token structure).
	//                 A tag value of zero indicates an "ignored" token, which is
	//                 automatically skipped over by the lexer (used for whitespace,
	//                 skip-over characters, comments, etc).
	virtual NBool RegisterToken(NDword inTag, NChar* inRegex)=0;

	// TokenPriority - sets the token priority level for subsequent RegisterToken calls
	//                 (the priority is zero by default).  When more than one possible
	//                 tag match is available for the lexer to choose from, the one with
	//                 the highest priority is chosen.  Use this to distinguish constant
	//                 keywords from identifiers, for example.  Returns the previous
	//                 priority level.
	virtual NByte TokenPriority(NByte inPriority)=0;

	// TokenIntercept - sets a function which, when the given tag is recognized by
	//                  PeekToken/GetToken, is called to give the user a chance to
	//                  change the token results before the function returns.
	//                  Useful for things like "simulated tags", where a tag can
	//                  be returned that the lexer would never recognize otherwise,
	//                  for example distinguishing type names from normal identifiers
	//                  based on user symbol table data.  Only affects tokens with this
	//                  tag which are registered BEFORE this function is called, not after.
	virtual NBool TokenIntercept(NDword inTag, void (*inIntercept)(ILexLexer*, SLexToken*))=0;

	// Finalize - performs irreversable calculations and optimizations on the lexer
	//            recognition data.  Only done once, optional, and VERY slow.
	//            If this is used, no more calls to RegisterToken are allowed after,
	//            but scanning speed will increase by several orders of magnitude.
	//            Recommended for large scans or other cases where initialization
	//            time is not important, but scanning speed is.
	virtual NBool Finalize()=0;

	// SaveDFA/LoadDFA - saves and loads finalized calculations to/from a file
	virtual NBool SaveFinalization(FILE* inFP)=0;
	virtual NBool LoadFinalization(FILE* inFP)=0;

	// SetText/GetText - sets or gets the current input stream for the next
	//                   pending read.  SetText must be used at least once before
	//                   any characters or tokens are read, so the lexer can scan
	//                   from valid data.  The line and column counts are typically
	//                   initialized to zero when the text is first set.  The tab
	//                   column parameter sets how many columns should equate to one
	//                   tab character (\t) in the text.  A value of zero assumes the
	//                   default column count of 8.
	virtual NBool SetText(NChar* inText, NDword inLine, NDword inColumn, NDword inTabColumns)=0;
	virtual NChar* GetText(NDword* outLine, NDword* outColumn)=0;

	// PeekChar/GetChar - reads a character from the input stream, either advancing
	//                    the stream (GetChar) or not (PeekChar).
	virtual NChar PeekChar()=0;
	virtual NChar GetChar()=0;

	// PeekToken/GetToken - reads a token from the input stream, either advancing
	//                      the stream (GetToken) or not (PeekToken).  Returns the
	//                      tag value from the recognized token.  The outToken
	//                      parameter is filled with the token data if non-null.
	//                      Skips over any tokens registered with a zero tag before
	//                      returning.  Will return zero at the end of the input
	//                      stream (i.e. a null character).
	virtual NDword PeekToken(SLexToken* outToken)=0;
	virtual NDword GetToken(SLexToken* outToken)=0;
};

//============================================================================
//    GLOBAL DATA
//============================================================================
//============================================================================
//    GLOBAL FUNCTIONS
//============================================================================
// CreateLexer - Create a lexer interface
KRN_API ILexLexer* LEX_CreateLexer();

// GetLastError - returns a descriptive error string when functions return failure
//                Currently only used with regex errors reported by RegisterToken.
KRN_API NChar* LEX_GetLastError();

//============================================================================
//    INLINE CLASS METHODS
//============================================================================
//============================================================================
//    TRAILING HEADERS
//============================================================================

//****************************************************************************
//**
//**    END HEADER LEXMAIN.H
//**
//****************************************************************************
#endif // __LEXMAIN_H__
