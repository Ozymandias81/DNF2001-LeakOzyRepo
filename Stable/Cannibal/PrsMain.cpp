//****************************************************************************
//**
//**    PRSMAIN.CPP
//**    Parsing
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#include "Kernel.h"
#include "LogMain.h"
#include "MemMain.h"
#include "LexMain.h"
#include "PrsMain.h"

//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
typedef NDword dword;
typedef NSDword sdword;
typedef NByte byte;
typedef NWord word;

#define ALLOC(type, size) MEM_Malloc(type, size)
#define FREE MEM_Free
#define ERROR LOG_Errorf
#define WARNING LOG_Warnf

// rule flags
enum
{
	RULEF_TERMINAL	= 0x00000001,	// auto-added to terminal rules
	RULEF_CLOSURE	= 0x00000002,	// temporary flag, rule has been processed for state closure
	RULEF_GENERATED	= 0x00000004,	// auto-added to generated terminals
};

// production event flags
enum
{
	PEVF_MAX		= 0x8000
};

enum
{
	PRODTOKEN_INVALID=0,
	PRODTOKEN_CHARACTER,
	PRODTOKEN_STRING,
	PRODTOKEN_IDENTIFIER,
    PRODTOKEN_POUND,
};

static ILexLexer* cc_prodLexer=NULL;
static NChar cc_errorStr[1024] = {0};
static NDword cc_errorLine=0, cc_errorColumn=0;

//============================================================================
//    CLASSES / STRUCTURES
//============================================================================

// Parse tree node structure
class CPrsNode
: public IPrsNode
{
public:    
	IPrsAttr* attribute;
    CPrsNode* parent; // parent node, created by reduction
    CPrsNode* firstChild; // first child of this parent, source of reduction
    CPrsNode* nextSibling; // subsequent children in same parent
    SLexToken token; // used by terminals only, lexer token for this rule
    void* ruleInternal; // internal use only - left-side rule this node represents
    void* prodInternal; // internal use only - for nonterminals, production which led to this rule (null for terminals)

	void* operator new (size_t size) { return(ALLOC(NByte, size)); }
	void operator delete (void* ptr) { FREE(ptr); }

	CPrsNode()
	{
		attribute = NULL;
		parent = firstChild = nextSibling = NULL;
		token.tag = 0;
		ruleInternal = prodInternal = NULL;
	}
	~CPrsNode()
	{
		while (firstChild)
		{
			CPrsNode* next = firstChild->nextSibling;
			delete firstChild;
			firstChild = next;
		}
	}

	// IPrsNode
	NBool Destroy()
	{
		delete this;
		return(1);
	}
	IPrsAttr* GetAttr() { return(attribute); }
	NBool SetAttr(IPrsAttr* inAttr) { attribute = inAttr; return(1); }
	SLexToken* GetToken() { return(&token); }
	IPrsNode* GetParent() { return(parent); }
	IPrsNode* GetFirstChild() { return(firstChild); }
	IPrsNode* GetNext() { return(nextSibling); }
};

//-----------------------------------------------
// PRODUCTIONS / RULES
//-----------------------------------------------
class parseRule_t;

class parseProd_t
{
public:
    class parseProdEvent_t
	{
	public:
// #pragma pack(push,1)
		FPrsProdFunc eventFunc;
// #pragma pack(pop)
	};
	
	parseProd_t* next; // next production for same rule
    parseRule_t* parentRule; // rule this production is a member of
    dword numItems; // number of items in this production
    parseProdEvent_t* itemEvents; // [numItems+1] array of in-between-item semantic callback events, zero means no event

    // valid before finalize
    char* definition; // string production definition
    SLexToken* itemTokens; // [numItems] array of item tokens pointing into definition

    // valid after finalize
    parseRule_t** itemRules; // [numItems] array of item rule links

    int operator == (parseProd_t& p)
    {
        if (parentRule != p.parentRule)
            return(0);
        for (dword i=0;i<numItems;i++)
        {
            if (itemRules[i] != p.itemRules[i])
                return(0);
        }
        return(1);
    }
};

class parseRule_t
{
public:
    char* ruleName; // rule name (left-hand side result)
	char* ruleNameOrg; // original rule name (no wacky prefixes etc)
	char* ruleAlias; // rule alias, if any
    dword flags; // RULEF_ flags
    dword index; // index in rule pool
    dword lexTag; // lexer tag (terminals only)
    parseProd_t* firstProduction; // first in list of productions (nonterminals only)

    void SetName(char* name)
    {
        if (ruleName)
        {
            FREE(ruleName);
            ruleName = NULL;
        }
        if (!name)
            return;
        ruleName = ALLOC(char, strlen(name)+1);
        strcpy(ruleName, name);
    }

    void SetOrgName(char* name)
    {
        if (ruleNameOrg)
        {
            FREE(ruleNameOrg);
            ruleNameOrg = NULL;
        }
        if (!name)
            return;
        ruleNameOrg = ALLOC(char, strlen(name)+1);
        strcpy(ruleNameOrg, name);
    }

    void SetAlias(char* name)
    {
        if (ruleAlias)
        {
            FREE(ruleAlias);
            ruleAlias = NULL;
        }
        if (!name)
            return;
        ruleAlias = ALLOC(char, strlen(name)+1);
        strcpy(ruleAlias, name);
    }

    parseRule_t() { ruleName = ruleNameOrg = ruleAlias = NULL; firstProduction = NULL; flags = index = lexTag = 0; }
    ~parseRule_t() { SetName(NULL); SetOrgName(NULL); SetAlias(NULL); }
};

//-----------------------------------------------
// STATES / STATE PRODUCTIONS
//-----------------------------------------------
class parser_t;

class parseStateProd_t
{
public:
    parseStateProd_t* next; // next kernel item production
    parseProd_t* prod; // actual rule production
    dword dotPos; // closure dot position (0=start, prod->numItems=end)
    int closureFlag; // closure has been performance (used during state generation)

    void* operator new(size_t size, parser_t* parser, dword numRules);
    
    inline int Matches(parseStateProd_t& p, dword dotAdd) // same as == but with unknown comparison dotPos
    {
        return((*prod == *p.prod) && (dotPos==(p.dotPos+dotAdd)));
    }
};

class parseState_t
{
private:	
	static int ProdSortCompare(const void* arg1, const void* arg2)
	{
		parseStateProd_t* p1 = *((parseStateProd_t**)arg1);
		parseStateProd_t* p2 = *((parseStateProd_t**)arg2);
		if (p1->prod->parentRule->index > p2->prod->parentRule->index)
			return(-1);
		else if (p1->prod->parentRule->index < p2->prod->parentRule->index)
			return(1);
		return(0);
	}

public:
    parseStateProd_t* firstProd; // first kernel item production
    parseState_t** nextRuleStates; // [numRules]
    bool partitioningFlag; // used during partitioning stage

	void *operator new(size_t size, parser_t* parser, dword numRules);

	~parseState_t() { if (nextRuleStates) FREE(nextRuleStates); }

	int Matches(parseState_t& s, int groupMatch, dword dotAdd)
	{
		// see if this contains the set of kernel items (w/adjusted dotPos) in s's given group
		parseStateProd_t *prod, *prod2;
		for (prod2=s.firstProd;prod2;prod2=prod2->next)
		{			
			if ((s.partitioningFlag) && (prod2->closureFlag != groupMatch))
				continue;
			for (prod=firstProd;prod;prod=prod->next)
			{
				if (prod->Matches(*prod2, dotAdd))
					break;
			}
			if (!prod)
				return(0); // didn't find a match for prod2
		}
		return(1);
	}

	void SortStateProductions()
	{
		static parseStateProd_t* prodArray[1024]; // hc
		parseStateProd_t* prod;
		dword i, count;
		for (i=0,prod=firstProd; prod; i++,prod=prod->next)
			prodArray[i] = prod;
		count = i;
		qsort(prodArray, count, sizeof(parseStateProd_t*), ProdSortCompare);
		for (i=0; i<count-1; i++)
			prodArray[i]->next = prodArray[i+1];
		prodArray[i]->next = NULL;
		firstProd = prodArray[0];
	}
};

//-----------------------------------------------
// PARSER
//-----------------------------------------------
#define PARSER_MAXRULES 512 // hc
#define PARSER_MAXSTATES 1024 // hc
#define PARSER_MAXSTATEPRODS 16384 // hc

class parser_t
: public IPrsParser
{
public:
    parseRule_t rulePool[PARSER_MAXRULES];
    dword rulePoolIndex;
    parseState_t statePool[PARSER_MAXSTATES];
    dword statePoolIndex;
    parseStateProd_t stateProdPool[PARSER_MAXSTATEPRODS];
    dword stateProdPoolIndex;

    ILexLexer* lexer;
    bool finalized;
	dword lookaheadLimit;
    FPrsTermFunc terminalEventCallback;

    parseRule_t* MakeRule(char* name, bool* existed, bool addable)
    {
	    parseRule_t* rule;
	    for (dword i=0;i<rulePoolIndex;i++)
	    {
		    if (!strcmp(name, rulePool[i].ruleName))
		    {
			    if (existed)
				    *existed = 1;
			    return(&rulePool[i]);
		    }
	    }
	    if (!addable)
	    {
		    if (existed)
			    *existed = 0;
		    return(NULL);
	    }
	    if (rulePoolIndex >= PARSER_MAXRULES)
		    ERROR("parser_t::MakeRule: Exceeded maximum rule count");
	    rule = &rulePool[rulePoolIndex];
	    rule->SetName(name);
        rule->flags = 0;
	    rule->index = rulePoolIndex;
	    rule->lexTag = 0;
	    rule->firstProduction = NULL;
	    rulePoolIndex++;
	    if (existed)
		    *existed = 0;
	    return(rule);    
    }

    parseRule_t* RuleForLexTag(dword tag)
    {
	    for (dword i=0;i<rulePoolIndex;i++)
	    {
		    if (rulePool[i].lexTag == tag)
			    return(&rulePool[i]);
	    }
        return(NULL);
    }

    void RegisterTerminal(char* name, dword tag)
    {
        if (!name || !tag)
            return; // zero tags are auto-skipped by the lexer and shouldn't be registered
        bool existed;
        parseRule_t* rule = MakeRule(name, &existed, 1);
        if (existed)
            ERROR("parser_t::RegisterTerminal: Rule \"%s\" already exists; terminal tags cannot share rules (share tags instead)", name);
        parseRule_t* tagRule;
        if (tagRule = RuleForLexTag(tag))
            ERROR("parser_t::RegisterTerminal: Rule \"%s\" has same tag as rule \"%s\"", name, tagRule->ruleName);
        rule->flags |= RULEF_TERMINAL;
        rule->lexTag = tag;
    }

    void InitProductionLexer()
    {
        if (!cc_prodLexer)
        {
            if (!(cc_prodLexer = LEX_CreateLexer()))
                ERROR("parser_t::RegisterNonTerminal: Cannot create production lexer");
            
            cc_prodLexer->TokenPriority(0);
            cc_prodLexer->RegisterToken(0, "."); // trash monster
            cc_prodLexer->TokenPriority(1);
            cc_prodLexer->RegisterToken(0, "[ \\t\\n]*"); // skip whitespace
            cc_prodLexer->RegisterToken(PRODTOKEN_CHARACTER, "'(\\\\.|[^\\\\'])+'");
            cc_prodLexer->RegisterToken(PRODTOKEN_STRING, "\\\"(\\\\.|[^\\\\\"])*\\\"");
            cc_prodLexer->RegisterToken(PRODTOKEN_IDENTIFIER, "[a-zA-Z_!]([a-zA-Z_!]|[0-9])*");
            cc_prodLexer->RegisterToken(PRODTOKEN_POUND, "\\#");
            cc_prodLexer->Finalize();
        }    
    }

    dword GetNonTerminalEventCount(char* definition)
    {
        static SLexToken token;
        dword eventCount = 0;

        InitProductionLexer();

        cc_prodLexer->SetText(definition, 0, 0, 0);
        while (cc_prodLexer->GetToken(&token))
        {
            if (token.tag == PRODTOKEN_POUND)
                eventCount++;
        }
        return(eventCount);
    }

    void RegisterNonTerminal(char* name, char* definition, FPrsProdFunc* events)
    {
        static SLexToken tempTokens[256]; // temporary token buffer, maximum production tokens
        static SLexToken token;
        parseRule_t* rule;
        parseProd_t* prod;

        InitProductionLexer();

        if (!name || !definition)
            return;
        rule = MakeRule(name, NULL, 1);
        if (rule->flags & RULEF_TERMINAL)
            ERROR("parser_t::RegisterNonTerminal: Rule \"%s\" is used by a terminal", name);

        prod = ALLOC(parseProd_t, 1);
        prod->next = NULL;
        prod->parentRule = rule;
        prod->numItems = 0;
        prod->definition = ALLOC(char, strlen(definition)+1);
        strcpy(prod->definition, definition);
        prod->itemTokens = NULL;
        prod->itemRules = NULL;
        prod->itemEvents = NULL;

        // first pass, determine number of production items
        cc_prodLexer->SetText(prod->definition, 0, 0, 0);
        while (cc_prodLexer->GetToken(&token))
        {
            if (token.tag == PRODTOKEN_POUND)
                continue; // ignore pound events during first pass
		    // anything else is an identifier, character, or string (all copied as-is and dealt with at finalize)
		    tempTokens[prod->numItems] = token;
		    prod->numItems++;
        }
        if (!prod->numItems)
            ERROR("parser_t::RegisterNonTerminal: Rule \"%s\" has production with no valid items", name);
        prod->itemTokens = ALLOC(SLexToken, prod->numItems);
        prod->itemEvents = ALLOC(parseProd_t::parseProdEvent_t, prod->numItems+1);
        for (dword i=0;i<prod->numItems;i++)
        {
            prod->itemTokens[i] = tempTokens[i];
            prod->itemEvents[i].eventFunc = NULL;
			//prod->itemEvents[i].eventFlags = 0;
        }
		prod->itemEvents[i].eventFunc = NULL;
		//prod->itemEvents[i].eventFlags = 0;

        prod->next = rule->firstProduction;
        rule->firstProduction = prod;

        // second pass, check for any event signals
        dword eventItem = 0, inEventItem = 0;

        cc_prodLexer->SetText(prod->definition, 0, 0, 0);
        while (cc_prodLexer->GetToken(&token))
        {
            if (token.tag == PRODTOKEN_POUND)
            {
                prod->itemEvents[eventItem].eventFunc = events[inEventItem++];
                //printf("Registered event %X (index %d) at item %d\n", events[inEventItem-1], inEventItem-1, eventItem);
                continue;
            }
            eventItem++;
        }
    }

    void ResolveProductionItemRules()
    {
	    for (dword i=0;i<rulePoolIndex;i++)
	    {
		    for (parseProd_t* prod = rulePool[i].firstProduction; prod; prod = prod->next)
		    {
			    prod->itemRules = ALLOC(parseRule_t*, prod->numItems);
			    for (dword k=0;k<prod->numItems;k++)
			    {
				    SLexToken* token = &prod->itemTokens[k];
				    static char buf[1024];
				    bool existed;

				    if ((token->lexeme[0] != '\'') && (token->lexeme[0] != '"'))
				    { // identifier, match up to rule
					    sprintf(buf, "%0.*s", token->lexemeLen, token->lexeme);
					    prod->itemRules[k] = MakeRule(buf, &existed, 0);
					    if (!existed)
						    ERROR("parser_t::ResolveProductionItemRules: Unknown terminal/nonterminal \"%s\"", buf);
				    }
				    else
				    {
					    static char namebuf[256];

					    sprintf(buf, "%0.*s", token->lexemeLen, token->lexeme);
					    // generated "immediate" terminals, above highest priority.
					    // these might override existing terminal matches, so relays are used when
					    // necessary to say that a token could resolve to either the generated rule terminal
					    // or the original (relayed) terminal.
					    
					    // since $ is not a legal character in a rule name, it is used to identify generated terminals
					    
					    if (buf[0] == '\'')
					    {
						    // character, forced to literal
						    // Does NOT accept escape sequences
						    namebuf[0] = '$';
						    namebuf[1] = '\\';
						    namebuf[2] = buf[1];
						    namebuf[3] = 0;
					    }
					    else
					    {
						    // string, force all regex symbols to literal since these are not supposed to be regexs
						    // Does NOT accept escape sequences
						    static char* literals = "|*+?()[]^-\\.";
						    char* iptr = buf, *optr = namebuf, *litptr;

						    *optr++ = '$';
						    iptr++; // skip initial quote
						    while((*iptr) && (*iptr != '"'))
						    {
							    for (litptr=literals;*litptr;litptr++)
							    {
								    if (*iptr == *litptr)
								    {
									    *optr++ = '\\';
									    break;
								    }
							    }
							    *optr++ = *iptr++;
						    }
						    *optr = 0;
					    }
					    
					    parseRule_t* rule = MakeRule(namebuf, &existed, 0);
					    if (!existed)
					    {
							// register the new immediate terminal
							RegisterTerminal(namebuf, 0xFFFF5150);
                            rule = MakeRule(namebuf, NULL, 0);
                            rule->lexTag = rule->index | 0x40000000; // make it high to guarantee no conflicts
							rule->flags |= RULEF_GENERATED;
						    byte oldPriority = lexer->TokenPriority(255); // priority 255 is reserved for generated terminals
                            if (!lexer->RegisterToken(rule->lexTag, namebuf+1))
                                ERROR("parser_t::ResolveProductionItemRules: RegisterToken failure on \"%s\", tag %d",
                                    namebuf+1, rule->lexTag);
                            lexer->TokenPriority(oldPriority);
					    }
					    prod->itemRules[k] = rule;
						sprintf(buf, "%0.*s", token->lexemeLen, token->lexeme);
						rule->SetOrgName(buf);
				    } // else
			    } // for k			    
                FREE(prod->itemTokens); prod->itemTokens = NULL;
			    FREE(prod->definition); prod->definition = NULL;
		    } // for prod
	    } // for i
    }

    void GenerateStates()
    {
	    parseRule_t* startRule = MakeRule("!start", 0, 0);
	    if (!startRule)
		    ERROR("parser_t::GenerateStates: No start rule");
	    parseState_t* startState = new(this, rulePoolIndex) parseState_t;

	    // add all startRule productions as kernel productions
	    startRule->flags |= RULEF_CLOSURE;
	    for (parseProd_t* prod = startRule->firstProduction; prod; prod = prod->next)
	    {
		    parseStateProd_t* sprod = new(this, rulePoolIndex) parseStateProd_t;
		    sprod->prod = prod;
		    sprod->dotPos = 0;
            sprod->closureFlag = 0;
		    sprod->next = startState->firstProd;
		    startState->firstProd = sprod;
	    }

	    int lastIndex = 0; // initialize to zero so the start state will be pending
	    while ((int)statePoolIndex != lastIndex)
	    {		
		    int old = lastIndex;
		    lastIndex = statePoolIndex;
		    for (int i=old; i<lastIndex; i++) // start at the first of the new states
		    {
			    parseState_t* state = &statePool[i];
			    // add all closure productions from these
			    bool gotone;
			    do
			    {
				    gotone = 0;
				    for (parseStateProd_t* sprod = state->firstProd; sprod; sprod = sprod->next)
				    {
					    if (sprod->closureFlag)
						    continue;
					    sprod->closureFlag = 1;
					    if (sprod->dotPos == sprod->prod->numItems)
						    continue; // dot is at the far right, no rule to process
					    parseRule_t *rule = sprod->prod->itemRules[sprod->dotPos];
					    if (rule->flags & RULEF_CLOSURE)
						    continue;
					    rule->flags |= RULEF_CLOSURE;
					    for (prod = rule->firstProduction; prod; prod = prod->next)
					    {
						    // add all productions for the rule with the closure nonterminal to the right of the dot
						    // obviously only relevant to nonterminals (terminals don't have productions)
						    parseStateProd_t* sp2 = new(this, rulePoolIndex) parseStateProd_t;
						    sp2->prod = prod;
						    sp2->dotPos = sp2->closureFlag = 0;
						    sp2->next = state->firstProd;
						    state->firstProd = sp2; // fortunately, putting it at the top won't affect sprod
						    gotone = 1;
					    }
				    }
			    } while (gotone);
			    // remove the rule closure flags
			    for (int k=0;k<(int)rulePoolIndex;k++)
				    rulePool[k].flags &= ~RULEF_CLOSURE;

			    // partition the state kernel productions into groups based on closure dot symbol
			    // use closureflag to denote group number for simplicity (-1 means not assigned, 0 means far right dot)
			    for (parseStateProd_t* sprod = state->firstProd; sprod; sprod = sprod->next)
				    sprod->closureFlag = -1;
			    int curgroup = 1;
			    do
			    {
				    gotone = 0;
				    for (sprod = state->firstProd; sprod; sprod = sprod->next)
				    {
					    if (sprod->closureFlag >= 0)
						    continue; // already has a group
					    gotone = 1;
					    // check for far right dot, i.e. the no-new-state group
					    if (sprod->dotPos == sprod->prod->numItems)
					    {
						    sprod->closureFlag = 0;
						    continue;
					    }
					    // check for existing groups
					    for (parseStateProd_t* sp2 = state->firstProd; sp2; sp2 = sp2->next)
					    {
						    if (sp2->closureFlag <= 0)
							    continue; // doesn't have group yet, or has far right group
						    if (sprod->prod->itemRules[sprod->dotPos] == sp2->prod->itemRules[sp2->dotPos])
						    {
							    sprod->closureFlag = sp2->closureFlag; // group match
							    break;
						    }
					    }
					    if (sprod->closureFlag >= 0)
						    continue; // existing group was found
					    // create a new group
					    sprod->closureFlag = curgroup;
					    curgroup++;
				    }
			    } while (gotone);
			    // all groups from 1 and above are new states, create them and add the appropriate items
			    
			    state->partitioningFlag = 1;
			    
			    for (k=1;k<curgroup;k++)
			    {
				    parseState_t* nstate = NULL;
				    parseRule_t *transRule = NULL;

				    // determine the transition rule
				    for (sprod = state->firstProd; sprod; sprod = sprod->next)
				    {
					    if (sprod->closureFlag == k)
					    {
						    transRule = sprod->prod->itemRules[sprod->dotPos];
						    break;
					    }
				    }
				    if (!transRule)
					    ERROR("parser_t::GenerateStates: No TransRule"); // should never happen since group index must have at least one member

				    // if a state already exists with the group set of kernel items (each at dotPos+1), use it
				    for (int m=0; m<(int)statePoolIndex; m++)
				    {
					    if (statePool[m].Matches(*state, k, 1))
					    {
						    nstate = &statePool[m];
						    break;
					    }
				    }

				    // make a new state
				    if (!nstate)
				    {
					    nstate = new(this, rulePoolIndex) parseState_t;
					    for (sprod = state->firstProd; sprod; sprod = sprod->next)
					    {
						    if (sprod->closureFlag != k)
							    continue; // different group
						    parseStateProd_t* sp2 = new(this, rulePoolIndex) parseStateProd_t;
						    sp2->prod = sprod->prod;
						    sp2->dotPos = sprod->dotPos+1; // move it over by one in the new state
						    sp2->closureFlag = 0;
						    sp2->next = nstate->firstProd;
						    nstate->firstProd = sp2;
					    }
				    }
				    // link to the new state on the group's transition symbol
				    sprod = nstate->firstProd;
				    if (!sprod)
					    ERROR("parser_t::GenerateStates: No production to link on");
				    state->nextRuleStates[transRule->index] = nstate;
			    }
			    
			    state->partitioningFlag = 0;

			    // clear out the closure flags
			    for (sprod = state->firstProd; sprod; sprod = sprod->next)
				    sprod->closureFlag = 0;
		    }
	    }

		// sort all the productions in the states by reversed rule order
		for (dword i=0;i<statePoolIndex;i++)
			statePool[i].SortStateProductions();
    }

    void FireTerminalEvent(CPrsNode* outNode, SLexToken* inToken)
    {
        if (terminalEventCallback)
            terminalEventCallback(outNode, inToken);
    }

    void FireNonTerminalEvent(IPrsNode* outNode, IPrsNode** inNodes, FPrsProdFunc inEvent)
    {        
        if (inEvent)
            inEvent(outNode, inNodes);
    }

    void RecursiveFireEvents(CPrsNode* node)
    {
	    int i;
	    IPrsNode *n, *childStack[256];
	    parseProd_t* p = (parseProd_t*)(node->prodInternal);

	    for (i=0,n=node->firstChild; n; i++,n=n->GetNext())
		    childStack[i] = n;
        if (node->GetToken()->tag)
            FireTerminalEvent(node, node->GetToken());
	    for (i=0,n=node->firstChild; n; i++,n=n->GetNext())
	    {
		    if ((i==1) && p && childStack[0])
                node->SetAttr(childStack[0]->GetAttr()); // $$ = $1, default action
            if (p && p->itemEvents[i].eventFunc)
			    FireNonTerminalEvent(node, childStack/*-1*/, p->itemEvents[i].eventFunc);
		    RecursiveFireEvents((CPrsNode*)n);
	    }
		if ((i==1) && p && childStack[0])
            node->SetAttr(childStack[0]->GetAttr()); // $$ = $1, default action
        if (p && p->itemEvents[i].eventFunc)
            FireNonTerminalEvent(node, childStack/*-1*/, p->itemEvents[i].eventFunc);
    }

    void FinalizeParser(char* startRuleName="start")
    {
	    char buf[256];
		RegisterNonTerminal("!start", "!eoi", NULL); // allow an empty input string
	    sprintf(buf, "%s !eoi", startRuleName);
	    RegisterNonTerminal("!start", buf, NULL);
	    
        //printf("Finalize: Resolving productions...\n");
        ResolveProductionItemRules();
        //printf("Finalize: Generating states...\n");
	    GenerateStates();
        //printf("Finalize: Finalizing lexer...\n");
	    lexer->Finalize();

	    finalized = 1;
    }

	void DestroyParseNode(CPrsNode* node)
	{
		CPrsNode *p, *prev = NULL;
		if (node->parent)
		{
			for (p = node->parent->firstChild; p && (p != node); p = p->nextSibling)
				prev = p;
			if (!prev && (node != node->parent->firstChild))
				ERROR("DestroyParseNode: Badly formed node tree\n");
		}
		if (prev)
			prev->nextSibling = node->nextSibling;
		else if ((node->parent) && (node->parent->firstChild == node))
			node->parent->firstChild = node->nextSibling;
		for (p=node->firstChild; p; p=p->nextSibling)
			p->parent = NULL; // this is a bottom-up parse node removal; the children are created before the parents
	}

    CPrsNode* Parse(char* text, dword inTabSpacing, char* outError, dword* outErrorLine, dword* outErrorColumn)
    {
	    SLexToken token;
	    parseRule_t* startRule;
	    parseState_t* state, *nextState;

	    startRule = MakeRule("!start", NULL, 0);
	    if (!startRule)
		    ERROR("parser_t::Parse: No start rule");	    
	    if (!finalized)
		    FinalizeParser();

        class parsePosition_t
		{
		public:
			dword stackDepth;
			int* stateStack;
			CPrsNode** nodeStack;
			parseStateProd_t* reduction;
			char* lexPtr;
			dword lexLine, lexColumn;
			parsePosition_t* next;
			CPrsNode* createdNodes;
			dword lexTokenCount;

			parsePosition_t(dword inStackDepth, int* inStateStack, CPrsNode** inNodeStack, parseStateProd_t* inReduction, char* inLexPtr, dword inLexLine, dword inLexColumn)
			{
				stackDepth = inStackDepth;
				stateStack = ALLOC(int, stackDepth);
				if (inStateStack)
					memcpy(stateStack, inStateStack, stackDepth*sizeof(int));
				nodeStack = ALLOC(CPrsNode*, stackDepth);
				if (inNodeStack)
					memcpy(nodeStack, inNodeStack, stackDepth*sizeof(CPrsNode*));
				reduction = inReduction;
				lexPtr = inLexPtr;
				lexLine = 0;
				lexColumn = 0;
				next = NULL;
				createdNodes = NULL;
				lexTokenCount = 0;
			}

			void CopyFrom(const parsePosition_t& inP, bool inConstruct)
			{
				stackDepth = inP.stackDepth;
				if (inConstruct)
					stateStack = ALLOC(int, stackDepth);
				memcpy(stateStack, inP.stateStack, stackDepth*sizeof(int));
				if (inConstruct)
					nodeStack = ALLOC(CPrsNode*, stackDepth);
				memcpy(nodeStack, inP.nodeStack, stackDepth*sizeof(CPrsNode*));
				reduction = inP.reduction;
				lexPtr = inP.lexPtr;
				lexLine = inP.lexLine;
				lexColumn = inP.lexColumn;
				next = NULL;
				createdNodes = inP.createdNodes;
				lexTokenCount = inP.lexTokenCount;
			}

			parsePosition_t(const parsePosition_t& inP) { CopyFrom(inP, 1); }
			parsePosition_t& operator = (const parsePosition_t& inP) { CopyFrom(inP, 0); return(*this); }

			~parsePosition_t()
			{
				if (stateStack)
					FREE(stateStack);
				if (nodeStack)
					FREE(nodeStack);
			}
			
		    void* operator new(size_t size) { return(ALLOC(char, size)); }
			void operator delete(void* ptr) { FREE(ptr); }
		};

		// conflict position stack logs positions at conflict points in the parse
		parsePosition_t* conflictPositionStack = NULL;
		dword conflictPositionStackDepth = 0;

		// initialize active parse position, not allocated to an existing stack depth but the maximum
		parsePosition_t activePos(1024, NULL, NULL, NULL, text, 0, 0); // hc
	    activePos.stackDepth = 0;
	    // push on the start state
		activePos.stateStack[activePos.stackDepth] = 0; // 0 is start state
	    activePos.nodeStack[activePos.stackDepth] = NULL;
	    activePos.stackDepth++;

	    while (1)
	    {
		    // assuming we're not set up for infinite lookahead, eliminate any conflicts in the conflict stack beyond our lookahead limit
			if (conflictPositionStack && (lookaheadLimit != 0xFFFFFFFF))
			{
				parsePosition_t* posprev = NULL;
				for (parsePosition_t* pos = conflictPositionStack; pos; pos = pos->next)
				{
					if ((pos->lexTokenCount + lookaheadLimit) < activePos.lexTokenCount)
						break;
					posprev = pos;
				}
				if (pos)
				{
					// everything at pos and after will die, so unlink now
					if (posprev)
						posprev->next = NULL;
					else
						conflictPositionStack = NULL;
					// kill off the old stuff
					while (pos)
					{
						parsePosition_t* posnext = pos->next;
						delete pos;
						pos = posnext;
						conflictPositionStackDepth--;
					}
				}
			}
			
			// retrieve the next token
			lexer->SetText(activePos.lexPtr, activePos.lexLine, activePos.lexColumn, inTabSpacing);

			if (!lexer->GetToken(&token))
			{
				token.tag = MakeRule("!eoi", NULL, 0)->lexTag;
				token.lexeme = "(eoi)";
				token.lexemeLen = 5;
			}
		    
		    parseRule_t* tagRule = RuleForLexTag(token.tag);
            if (!tagRule)
                ERROR("parser_t::Parse: No rule matching terminal tag %d", token.tag);

			{
				char* rname;
				if (tagRule->ruleNameOrg)
					rname = tagRule->ruleNameOrg;
				else
					rname = tagRule->ruleName;
				//printf("Debug: Grabbing token \"%0.*s\" (Rule %s) at Line %d Column %d\n", token.lexemeLen, token.lexeme, rname, activePos.lexLine, activePos.lexColumn);
			}

		    state = &statePool[activePos.stateStack[activePos.stackDepth-1]];

			// if we don't have a predetermined reduction, build up possibilities for shifting and reducing
			if (!activePos.reduction)
			{
				bool canShift=0, canReduce=0;
				bool isShifting=0, isReducing=0;
				
				// if there's a next state from this one on the current terminal rule, then we can shift
				nextState = state->nextRuleStates[tagRule->index];
				if (nextState)
					canShift = 1;

				// check for possible reductions
				dword numReduce=0;
				for (parseStateProd_t* prod=state->firstProd; prod; prod=prod->next)
				{
					if (prod->dotPos != prod->prod->numItems)
						continue; // not a reduction
					numReduce++;
					activePos.reduction = prod; // last production in the chain is the first one defined, top priority
				}

				// if there's at least one reduction, we can reduce
				if (activePos.reduction)
					canReduce = 1;

				// if there's more than one possibility, push the conflicts (assuming we're not LR(0))
				if (((canShift && canReduce) || (numReduce > 1)) && (lookaheadLimit))
				{			
					// reduce/reduce conflicts
					if (numReduce > 1)
					{
						//printf("Debug: Logging %d reduction conflicts\n", numReduce);

						// since these are used last, push them on in reverse order (the last listed production gets pushed first)
						// push all reductions except the first (if we have a shift/reduce conflict as well, it'll push the first
						for (prod=state->firstProd; prod && prod->next; prod=prod->next)
						{
							if (prod->dotPos != prod->prod->numItems)
								continue; // not a reduction				
							parsePosition_t* pos = new parsePosition_t(activePos);
							pos->reduction = prod;
							pos->next = conflictPositionStack;
							conflictPositionStack = pos;
							conflictPositionStackDepth++;
							activePos.createdNodes = NULL;
						}
					}
					// shift/reduce conflicts
					if (canShift && canReduce)
					{
						//printf("Debug: Logging a shift/reduce conflict\n", numReduce);

						parsePosition_t* pos = new parsePosition_t(activePos);
						pos->reduction = activePos.reduction;
						pos->next = conflictPositionStack;
						conflictPositionStack = pos;
						conflictPositionStackDepth++;
						activePos.createdNodes = NULL;
					}

					//printf("Debug: Conflict depth is now %d\n", conflictPositionStackDepth);
				}

				// on the other end of the spectrum, if there's no possibilities, then try and pop a conflict back up
				if (!(canShift || canReduce))
				{
					if (conflictPositionStackDepth)
					{
						//printf("Debug: Backing up at conflict depth %d\n", conflictPositionStackDepth);

						// destroy all tree nodes that were formed since this action was chosen
						CPrsNode* nextNode;
						for (CPrsNode* node = activePos.createdNodes; node; node = nextNode)
						{
							nextNode = (CPrsNode*)(node->attribute);
							//printf("Destroying node %X\n", node);
							DestroyParseNode(node);
						}
						
						//printf("Debug: Tree obliterated, continue backtrack...\n");

						// pop the most recent conflict
						activePos = *conflictPositionStack;
						parsePosition_t* nextConflict = conflictPositionStack->next;
						delete conflictPositionStack;
						conflictPositionStack = nextConflict;
						conflictPositionStackDepth--;
						continue; // start over
					}
					
					if (outError)
					{
						sprintf(outError, "Found \"%0.*s\"", token.lexemeLen, token.lexeme); // bad transition
						dword rcount=0;
						for (dword r=0;r<rulePoolIndex;r++)
						{
							if (!state->nextRuleStates[r])
								continue;
							char* rname = rulePool[r].ruleAlias;
							if (!rname)// && (!(rulePool[r].flags & RULEF_GENERATED)))
								continue;
							if (!rname)
								rname = rulePool[r].ruleNameOrg;
							if (!rname)
								rname = rulePool[r].ruleName;
							if (!rcount)
								sprintf(outError+strlen(outError), ", expecting %s", rname);
							else
								sprintf(outError+strlen(outError), ", %s", rname);
							rcount++;
						}
						//sprintf(outError+strlen(outError), "\n");
						
						if (outErrorLine)
							*outErrorLine = token.textLine+1;
						if (outErrorColumn)
							*outErrorColumn = token.textColumn+1;
					}
					return(NULL);
				}

				if (canShift)
					activePos.reduction = NULL; // the default action in a shift/reduce conflict is to shift
			}

			// if we still don't have a reduction, then that means we should shift
			if (!activePos.reduction)
		    {			    
				//printf("Debug: Shifting\n");

	            // the token read sticks on shifts
				activePos.lexPtr = lexer->GetText(&activePos.lexLine, &activePos.lexColumn);
				activePos.lexTokenCount++;

			    //CPrsNode* node = ALLOC(CPrsNode, 1);
				CPrsNode* node = new CPrsNode;
				//printf("Created node %X\n", node);

			    node->parent = NULL;
			    node->firstChild = NULL;
			    node->nextSibling = NULL;
			    node->attribute = NULL;
                node->token = token;
			    node->prodInternal = NULL;
			    node->ruleInternal = tagRule;

				node->attribute = (IPrsAttr*)activePos.createdNodes; // log the action that created this node incase we need to nuke it
				activePos.createdNodes = node;

			    activePos.nodeStack[activePos.stackDepth] = node;
			    activePos.stateStack[activePos.stackDepth] = (int)(nextState - statePool);
			    activePos.stackDepth++;

		    }
			else
		    {
				// we have a reduction
				//printf("Debug: Reduction present: %s -> ", activePos.reduction->prod->parentRule->ruleName);
				//for (dword prule=0;prule<activePos.reduction->prod->numItems;prule++)
				//	printf("%s ", activePos.reduction->prod->itemRules[prule]->ruleName);
				//printf("\n");
				activePos.stackDepth -= activePos.reduction->dotPos;
                state = &statePool[activePos.stateStack[activePos.stackDepth-1]];

			    if (activePos.reduction->prod->parentRule == startRule)
				    break; // accept (we're done!)
			    
			    nextState = state->nextRuleStates[activePos.reduction->prod->parentRule->index];
			    if (!nextState)
			    {
				    if (outError)
                    {
                        
						//sprintf(outError, "Bad reduction to \"%s\": \"%0.*s\"", activePos.reduction->prod->parentRule->ruleName,
                        //    token.lexemeLen, token.lexeme);
						sprintf(outError, "Found \"%0.*s\"", token.lexemeLen, token.lexeme);
						dword rcount=0;
						for (dword r=0;r<rulePoolIndex;r++)
						{
							if (!state->nextRuleStates[r])
								continue;
							char* rname = rulePool[r].ruleAlias;
							if (!rname)// && (!(rulePool[r].flags & RULEF_GENERATED)))
								continue;
							if (!rname)
								rname = rulePool[r].ruleNameOrg;
							if (!rname)
								rname = rulePool[r].ruleName;
							if (!rcount)
								sprintf(outError+strlen(outError), ", expecting %s", rname);
							else
								sprintf(outError+strlen(outError), ", %s", rname);
							rcount++;
						}
                        if (outErrorLine)
                            *outErrorLine = token.textLine+1;
                        if (outErrorColumn)
                            *outErrorColumn = token.textColumn+1;
                    }
					// get rid of the conflict stack memory
					while (conflictPositionStack)
					{
						parsePosition_t* nextConflict = conflictPositionStack->next;
						delete conflictPositionStack;
						conflictPositionStack = nextConflict;
					}

				    return(NULL);
			    }

			    //CPrsNode* node = ALLOC(CPrsNode, 1);
				CPrsNode* node = new CPrsNode;
				//printf("Created node %X\n", node);

			    node->parent = NULL;
			    node->firstChild = NULL;
			    node->nextSibling = NULL;
			    node->attribute = NULL;
                node->token.tag = 0;
                node->token.lexeme = "";
                node->token.lexemeLen = 0;
                node->token.textLine = node->token.textColumn = 0;
			    node->prodInternal = activePos.reduction->prod;
			    node->ruleInternal = activePos.reduction->prod->parentRule;

				node->attribute = (IPrsAttr*)activePos.createdNodes; // log the action that created this node incase we need to nuke it
				activePos.createdNodes = node;

			    node->firstChild = activePos.nodeStack[activePos.stackDepth];
			    for (dword i=activePos.stackDepth;i<(activePos.stackDepth+activePos.reduction->dotPos-1);i++)
				{
					activePos.nodeStack[i]->parent = node;
				    activePos.nodeStack[i]->nextSibling = activePos.nodeStack[i+1];
				}
				activePos.nodeStack[i]->parent = node;
				activePos.nodeStack[i]->nextSibling = NULL;

				//printf("Debug: Reduction pushing state %d\n", (int)(nextState - statePool));

			    activePos.nodeStack[activePos.stackDepth] = node;
			    activePos.stateStack[activePos.stackDepth] = (int)(nextState - statePool);
			    activePos.stackDepth++;

				activePos.reduction = NULL;
		    }
	    }

		// get rid of the conflict stack memory
		while (conflictPositionStack)
		{
			parsePosition_t* nextConflict = conflictPositionStack->next;
			delete conflictPositionStack;
			conflictPositionStack = nextConflict;
		}
		
        RecursiveFireEvents(activePos.nodeStack[1]);
	    return(activePos.nodeStack[1]);
    }

	parser_t()
	{		
		rulePoolIndex = statePoolIndex = stateProdPoolIndex = 0;
		memset(statePool, 0, PARSER_MAXSTATEPRODS*sizeof(parseState_t));
		memset(stateProdPool, 0, PARSER_MAXSTATEPRODS*sizeof(parseStateProd_t));
        
        if (!(lexer = LEX_CreateLexer()))
            ERROR("parser_t::parser_t(): Cannot create terminal lexer");
        finalized = 0;
		lookaheadLimit = 1;
        terminalEventCallback = NULL;
		
		// rule 0 is always the empty (epsilon) rule
		RegisterNonTerminal("NULL", "NULL", NULL); // heh
		
		// rule 1 is always the eoi terminal, never generated by lexer but stubbed
        // in by parser on lexical failure.  Uses a tag that's extremely unlikely to be
        // used directly.
        RegisterTerminal("!eoi", 0xFFFF1234);
	}

    ~parser_t()
    {
        lexer->Destroy();
		lexer = NULL;
    }

	// IPrsParser
	NBool Destroy()
	{
		delete this;
		return 1;
	}
	ILexLexer* GetLexer()
	{
		return(lexer);
	}
	NBool RegisterTerm(NChar* inRule, NDword inLexTag)
	{
		RegisterTerminal(inRule, inLexTag);
		return(1);
	}
	NBool RegisterProd(NChar* inRule, NChar* inProduction, /*FPrsProdFunc inEvents*/... )
	{
		static FPrsProdFunc events[256]; // max events    
		NDword numEvents = GetNonTerminalEventCount(inProduction);
		va_list args;
		va_start(args, inProduction);
		for (dword i=0;i<numEvents;i++)
			events[i] = va_arg(args, FPrsProdFunc);
		va_end(args);
		RegisterNonTerminal(inRule, inProduction, events);
		return(1);
	}
	NBool SetRuleAlias(NChar* inRule, NChar* inAlias)
	{
		if (!inRule)
			return(0);
		bool existed;
		parseRule_t* r = MakeRule(inRule, &existed, 0);
		if (!r)
			return(0);
		r->SetAlias(inAlias);
		return(1);
	}
	NBool SetTermFunc(FPrsTermFunc inTermFunc)
	{
		terminalEventCallback = inTermFunc;
		return(1);
	}
	NBool Finalize()
	{
		FinalizeParser();
		return(1);
	}
	IPrsNode* Execute(NChar* inText, NDword inTabSpacing)
	{
		return(Parse(inText, inTabSpacing, cc_errorStr, &cc_errorLine, &cc_errorColumn));
	}
};

void *parseState_t::operator new(size_t size, parser_t* parser, dword numRules)
{
	if (parser->statePoolIndex >= PARSER_MAXSTATES)
		ERROR("parseState_t: Too many states");
	parseState_t *res = &parser->statePool[parser->statePoolIndex];
	parser->statePoolIndex++;
	res->firstProd = NULL;
	res->nextRuleStates = ALLOC(parseState_t*, numRules);
	memset(res->nextRuleStates, 0, numRules*sizeof(parseState_t*));
	res->partitioningFlag = 0;
	return(res);
}

void *parseStateProd_t::operator new(size_t size, parser_t* parser, dword numRules)
{
	if (parser->stateProdPoolIndex >= PARSER_MAXSTATEPRODS)
		ERROR("parseStateProd_t: Too many state kernel productions");
	parseStateProd_t *res = &parser->stateProdPool[parser->stateProdPoolIndex];
	parser->stateProdPoolIndex++;
	res->next = NULL;
	res->prod = NULL;
	res->dotPos = res->closureFlag = 0;
	return(res);
}

//============================================================================
//    PRIVATE DATA
//============================================================================
//============================================================================
//    GLOBAL DATA
//============================================================================
//============================================================================
//    PRIVATE FUNCTIONS
//============================================================================
//============================================================================
//    GLOBAL FUNCTIONS
//============================================================================
KRN_API IPrsParser* PRS_CreateParser(NDword inLookAhead)
{
	parser_t* prs = new parser_t;
	prs->lookaheadLimit = inLookAhead;
	return(prs);
}
KRN_API NChar* PRS_GetLastError(NDword* outLine, NDword* outColumn)
{
    if (outLine) *outLine = cc_errorLine;
    if (outColumn) *outColumn = cc_errorColumn;
    return(cc_errorStr);	
}

//============================================================================
//    CLASS METHODS
//============================================================================

//****************************************************************************
//**
//**    END MODULE PRSMAIN.CPP
//**
//****************************************************************************

