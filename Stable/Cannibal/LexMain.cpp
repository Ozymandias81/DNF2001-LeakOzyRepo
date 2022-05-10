//****************************************************************************
//**
//**    LEXMAIN.CPP
//**    Lexical Analysis
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#include "Kernel.h"
#include "LogMain.h"
#include "MemMain.h"
#include "LexMain.h"

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

#define CC_MEMOPERATORS \
    void* operator new(size_t size) { return(ALLOC(char, size)); } \
    void operator delete(void* ptr) { FREE(ptr); }

// nfa node flags
enum
{
    NFANF_EPSILON       = 0x00000001, // epsilon closure node
	NFANF_ACCEPTING     = 0x00000002, // accepting node
    NFANF_EDGESET       = 0x00000004, // multiple character edge set is used

    NFANF_MAX           = 0x80000000
};

typedef void (*tokenInterceptFunc_t)(ILexLexer*, SLexToken*);

//============================================================================
//    CLASSES / STRUCTURES
//============================================================================

static NChar lex_errorStr[1024] = {0};

//#define BITSET_RANGECHECK

class bitSet_t
{
public:
	byte *data;
	dword size, sizeInBytes;
    static dword defaultSize;
	
    void Init(int s)
	{
		size = s;
		sizeInBytes = (s + 7) >> 3;
		data = ALLOC(byte, sizeInBytes);
		memset(data, 0, sizeInBytes);
	}

    bitSet_t() { if (defaultSize) Init(defaultSize); else Init(2048); } // hc
    bitSet_t(int s) { Init(s); }
    ~bitSet_t() { if (data) FREE(data); }

	inline dword Num()
	{
		int count=0;
		for (dword i=0;i<size;i++)
			count += ((data[i >> 3] & (1 << (i & 7))) != 0);
		return(count);
	}
	inline bitSet_t& operator += (const dword v) // add element
	{
#ifdef BITSET_RANGECHECK
		if (v < size)
#endif
			data[v >> 3] |= (1 << (v & 7));
		return(*this);
	}
	inline bitSet_t& operator -= (const dword v) // remove element
	{
#ifdef BITSET_RANGECHECK
		if (v < size)
#endif
			data[v >> 3] &= ~(1 << (v & 7));
		return(*this);
	}
	inline bitSet_t& operator = (const bitSet_t& other) // assignment
	{
		dword lowest = sizeInBytes;
		if (other.sizeInBytes < lowest)
			lowest = other.sizeInBytes;
		memcpy(data, other.data, lowest);
		return(*this);
	}
	inline bitSet_t& operator |= (const bitSet_t& other) // union
	{
		dword lowest = sizeInBytes;
		if (other.sizeInBytes < lowest)
			lowest = other.sizeInBytes;
		for (dword i=0; i<lowest; i++)
			data[i] |= other.data[i];
		return(*this);
	}
	inline bitSet_t& operator &= (const bitSet_t& other) // intersection
	{
		dword lowest = sizeInBytes;
		if (other.sizeInBytes < lowest)
			lowest = other.sizeInBytes;
		for (dword i=0; i<lowest; i++)
			data[i] &= other.data[i];
		return(*this);
	}
	inline bitSet_t& operator -= (const bitSet_t& other) // difference
	{
		dword lowest = sizeInBytes;
		if (other.sizeInBytes < lowest)
			lowest = other.sizeInBytes;
		for (dword i=0; i<lowest; i++)
			data[i] ^= other.data[i];
		return(*this);
	}
	inline int operator < (const bitSet_t& other) // is subset of
	{
		dword lowest = sizeInBytes;
		if (other.sizeInBytes < lowest)
			lowest = other.sizeInBytes;
		for (dword i=0; i<lowest; i++)
			if ((data[i] & other.data[i]) != data[i])
				return(0);
		return(1);
	}
	inline int operator == (const bitSet_t& other) // equivalent
	{
		dword lowest = sizeInBytes;
		if (other.sizeInBytes < lowest)
			lowest = other.sizeInBytes;
		for (dword i=0; i<lowest; i++)
			if (data[i] != other.data[i])
				return(0);
		return(1);
	}
	inline int operator != (const bitSet_t& other)
	{
		return(!(*this == other));
	}
	inline int IsDisjoint(const bitSet_t& other) // have no elements in common
	{
		dword lowest = sizeInBytes;
		if (other.sizeInBytes < lowest)
			lowest = other.sizeInBytes;
		for (dword i=0; i<lowest; i++)
			if (data[i] & other.data[i])
				return(0);
		return(1);
	}
	inline int IsIntersecting(const bitSet_t& other) // have at least one element in common
	{
		dword lowest = sizeInBytes;
		if (other.sizeInBytes < lowest)
			lowest = other.sizeInBytes;
		for (dword i=0; i<lowest; i++)
			if (data[i] & other.data[i])
				return(1);
		return(0);
	}
	inline void Invert()
	{
		for (dword i=0; i<sizeInBytes; i++)
			data[i] ^= 0xFF;
	}
	inline void Empty()
	{
		memset(data, 0, sizeInBytes);
        //for (dword i=0; i<sizeInBytes; i++)
		//	data[i] = 0;
	}
	inline void Fill()
	{
		memset(data, 0xFF, sizeInBytes);
        //for (dword i=0; i<sizeInBytes; i++)
		//	data[i] = 0xFF;
	}
	inline int Contains(dword v)
	{
#ifdef BITSET_RANGECHECK
		if (v < size)
#endif
			return((data[v >> 3] & (1 << (v & 7))) != 0);
		return(0);
	}
	inline int IsEmpty()
	{
		for (dword i=0; i<sizeInBytes; i++)
		{
			if (data[i])
				return(0);
		}
		return(1);
	}
};

dword bitSet_t::defaultSize = 0;

//-----------------------------------------------
// NODES
//-----------------------------------------------
class nfaNode_t;

class nfaNodeFactory_t
{
public:
    dword numNodes, maxNodes;
    nfaNode_t* nodes;

    nfaNodeFactory_t(dword nodeCount);
    ~nfaNodeFactory_t();
    nfaNode_t* AllocNode();
    nfaNode_t* NodeForId(dword id);
    dword IdForNode(nfaNode_t* node);
};

class nfaNode_t
{
private:
    void* operator new(size_t size) { return(NULL); }
    void operator delete(void* ptr) { }
public:
	void* operator new(size_t size, void* ptr) { return(ptr); }
	void operator delete(void*, void*) { }
    void* operator new(size_t size, nfaNodeFactory_t& factory) { return(factory.AllocNode()); }
    void operator delete(void* ptr, nfaNodeFactory_t& factory) { ERROR("nfaNode_t: illegal operator delete"); }

    dword flags; // NFANF_ flags
    dword tag; // token tag
    byte edge; // single-character edge if flags indicate, zero if unused (since zero edges are illegal)
    byte priority; // priority level
    nfaNode_t* link1; // next node (null if none)
    nfaNode_t* link2; // another node for epsilon edges, null if unused
    tokenInterceptFunc_t tokenFunc; // intercept function, null if unused    
    bitSet_t edgeSet; // multiple-character set if flags indicate

    nfaNode_t()
        : edgeSet(256)
    {
        flags = tag = edge = priority = 0;
        link1 = link2 = NULL;
        tokenFunc = NULL;
    }
};

nfaNodeFactory_t::nfaNodeFactory_t(dword nodeCount) { numNodes = 0; maxNodes = nodeCount; nodes = ALLOC(nfaNode_t, maxNodes); /*for (dword i=0;i<maxNodes;i++) new(&nodes[i]) nfaNode_t;*/ }
nfaNodeFactory_t::~nfaNodeFactory_t() { if (nodes) FREE(nodes); }
nfaNode_t* nfaNodeFactory_t::AllocNode()
{
    if (numNodes >= maxNodes)
        ERROR("nfaNodeFactory_t: AllocNode limit exceeded (%d)", maxNodes);
    numNodes++;
    return(&nodes[numNodes-1]);
}
nfaNode_t* nfaNodeFactory_t::NodeForId(dword id) { return(&nodes[id]); }
dword nfaNodeFactory_t::IdForNode(nfaNode_t* node) { return((dword)(node - nodes)); }

//-----------------------------------------------
// EXPRS
//-----------------------------------------------
class nfaExpr_t;

class nfaExprFactory_t
{
public:
    dword numExprs, maxExprs;
    nfaExpr_t* exprs;

    nfaExprFactory_t(dword exprCount);
    ~nfaExprFactory_t();
    nfaExpr_t* AllocExpr();
    nfaExpr_t* ExprForId(dword id);
    dword IdForExpr(nfaExpr_t* expr);
};

class nfaExpr_t
{
private:
    void* operator new(size_t size) { return(NULL); }
    void operator delete(void* ptr) {}
public:
	void* operator new(size_t size, void* ptr) { return(ptr); }
	void operator delete(void*, void*) { }
    void* operator new(size_t size, nfaExprFactory_t& factory) { return(factory.AllocExpr()); }
    void operator delete(void* ptr, nfaExprFactory_t& factory) { ERROR("nfaExpr_t: illegal operator delete"); }

    nfaNode_t* first;
    nfaNode_t* last;

    nfaExpr_t() { first = last = NULL; }
};

nfaExprFactory_t::nfaExprFactory_t(dword exprCount) { numExprs = 0; maxExprs = exprCount; exprs = ALLOC(nfaExpr_t, maxExprs); /*for (dword i=0;i<maxExprs;i++) new(&exprs[i]) nfaExpr_t;*/ }
nfaExprFactory_t::~nfaExprFactory_t() { if (exprs) FREE(exprs); }
nfaExpr_t* nfaExprFactory_t::AllocExpr()
{
    if (numExprs >= maxExprs)
        ERROR("nfaExprFactory_t: AllocExpr limit exceeded (%d)", maxExprs);
    numExprs++;
    return(&exprs[numExprs-1]);
}
nfaExpr_t* nfaExprFactory_t::ExprForId(dword id) { return(&exprs[id]); }
dword nfaExprFactory_t::IdForExpr(nfaExpr_t* expr) { return((dword)(expr - exprs)); }

//-----------------------------------------------
// DFA CLASSES
//-----------------------------------------------
class dfaAcceptItem_t
{
public:
    dword tag;
    dword flags;
    tokenInterceptFunc_t tokenFunc;
    byte priority;

    inline dfaAcceptItem_t& operator = (const dfaAcceptItem_t& i)
    {
        tag = i.tag; flags = i.flags; tokenFunc = i.tokenFunc; priority = i.priority;
        return(*this);
    }
    inline int operator == (const dfaAcceptItem_t& i)
    {
        return( (tag == i.tag) && (flags == i.flags) && (tokenFunc == i.tokenFunc) && (priority == i.priority) );
    }
    inline int operator != (const dfaAcceptItem_t& i)
    {
        return(!(*this == i));
    }
};

class dfaTable_t
{
public:
    dword numChars, numStates;
    dword initialState;
    word* stateNext; // [numChars*numStates]
    sdword* stateParts; // [numStates], used during minimization only
    dfaAcceptItem_t* acceptTable; // [numStates]

    dfaTable_t()
    {
        numChars = numStates = initialState = 0;
        stateNext = NULL;
        stateParts = NULL;
        acceptTable = NULL;
    }
    ~dfaTable_t()
    {
        if (stateNext) FREE(stateNext);
        if (stateParts) FREE(stateParts);
        if (acceptTable) FREE(acceptTable);
    }


};

#define DFA_MAXSTATES 1024 // hc

class dfaPartitionSet_t;

class dfaPartition_t
{
private:
    sdword highest, count;
    sdword states[DFA_MAXSTATES];
    sdword partIndex;
    dfaTable_t* useDFA;
public:
    dfaPartition_t() { Init(); }
    void Init()
    {
        highest = count = partIndex = 0;
        useDFA = NULL;
        for (sdword i=0;i<DFA_MAXSTATES;i++)
            states[i] = -1;
    }
    bool Owns(sdword state, sdword* index)
    {
		for (sdword i=0;i<=highest;i++)
		{
			if (states[i] == state)
			{
				if (index)
                    *index = i;
				return(1);
			}
		}
		return(0);    
    }
    bool Add(sdword state)
    {
		if (Owns(state, NULL))
			return(0);
		if (useDFA->stateParts[state] != -1)
			return(0);
		for (sdword i=0;i<DFA_MAXSTATES;i++)
		{
			if (states[i] != -1)
                continue;
			states[i] = state;
			if (highest < i)
				highest = i;
			count++;
			useDFA->stateParts[state] = partIndex;
			return(1);
		}
        ERROR("dfaPartition_t::Add: Out of room for states");
		return(0);
    }
	bool Remove(sdword state)
	{
		sdword index;
		if (!Owns(state, &index))
			return(0);
		states[index] = -1;
		count--;
		useDFA->stateParts[state] = -1;
		return(1);
	}
	sdword Next(sdword start, sdword *nextstart=NULL)
	{
		sdword i;
		for (i=start; (i<=highest) && (states[i] == -1); i++)
			;
		if (i > highest)
			return(-1);
		if (nextstart)
			*nextstart = i+1;
		return(states[i]);
	}
    sdword Count() { return(count); }

    friend class dfaPartitionSet_t;
};

class dfaPartitionSet_t
{
private:
    dfaPartition_t partitions[DFA_MAXSTATES];
    sdword curPartition;
    bool partAdd;
    dfaTable_t* useDFA;
public:
    dfaPartitionSet_t() { Init(); }
    void Init()
    {
        curPartition = 0;
        partAdd = 0;
        useDFA = NULL;
        for (sdword i=0;i<DFA_MAXSTATES;i++)
        {
            partitions[i].Init();
            partitions[i].partIndex = i;
        }
    }
    inline dfaPartition_t& operator[] (int i)
    {
        return(partitions[i]);
    }
    inline dfaPartition_t* operator-> ()
    {
        if (partAdd)
            curPartition++;
        partAdd = 0;
        return(&partitions[curPartition]);
    }
    void Mark()
    {
        partAdd = 1;
    }
    void SetDFA(dfaTable_t* dfa)
    {
        useDFA = dfa;
        for (sdword i=0;i<DFA_MAXSTATES;i++)
            partitions[i].useDFA = dfa;
    }
    void MoveTo(sdword state, sdword part)
    {
        if (useDFA->stateParts[state] != -1)
            partitions[useDFA->stateParts[state]].Remove(state);
        partitions[part].Add(state);
    }
    void MoveToCurrent(sdword state)
    {
        if (partAdd)
            curPartition++;
        partAdd = 0;
        MoveTo(state, curPartition);
    }
    sdword Num()
    {
        return(curPartition+1);
    }
    sdword PendingCurrent()
    {
        if (partAdd)
            return(curPartition+1);
        return(curPartition);
    }
};

//-----------------------------------------------
// LEXER
//-----------------------------------------------
class lexer_t
: public ILexLexer
{
public:
    CC_MEMOPERATORS

    nfaNodeFactory_t nFact;
    nfaExprFactory_t eFact;

    char* textPtr;
    nfaNode_t* startNode;
    byte activePriority;
    dfaTable_t dfa;
    dword lineCount, columnCount, tabColumns;
    bool finalized, isCaseSensitive;
    bitSet_t edgesUsed;

    lexer_t()
        : nFact(2048), eFact(2048), edgesUsed(256) // hc
    {
        textPtr = NULL;
        startNode = new(nFact) nfaNode_t;
        activePriority = 0;
        lineCount = columnCount = 0;
        tabColumns = 8;
        finalized = 0;
		isCaseSensitive = 1;
        edgesUsed.Empty();
    }

    void SetIntercept(dword inTag, void (*inIntercept)(ILexLexer*, SLexToken*))
    {
        if (!inTag)
            return;
        if (!finalized)
		{
			for (dword i=0;i<nFact.numNodes;i++)
			{
				if (nFact.NodeForId(i)->tag == inTag)
					nFact.NodeForId(i)->tokenFunc = inIntercept;
			}
		}
		else
		{
			for (dword i=0;i<dfa.numStates;i++)
			{
				if (dfa.acceptTable[i].tag == inTag)
					dfa.acceptTable[i].tokenFunc = inIntercept;
			}
		}
    }

	void SaveDFAToFile(FILE* fp)
	{
		dword d;
		
		if (!finalized)
			FinalizeDFA();

		d = dfa.numChars; fwrite(&d, sizeof(d), 1, fp);
		d = dfa.numStates; fwrite(&d, sizeof(d), 1, fp);
		d = dfa.initialState; fwrite(&d, sizeof(d), 1, fp);
		fwrite(dfa.stateNext, sizeof(word), dfa.numChars*dfa.numStates, fp);
		for (dword i=0;i<dfa.numStates;i++)
		{
			d = dfa.acceptTable[i].tag; fwrite(&d, sizeof(d), 1, fp);
			d = dfa.acceptTable[i].flags; fwrite(&d, sizeof(d), 1, fp);
			d = dfa.acceptTable[i].priority; fwrite(&d, sizeof(d), 1, fp);
		}
	}

	void LoadDFAFromFile(FILE* fp)
	{
		dword d;

		fread(&d, sizeof(d), 1, fp); dfa.numChars = d;
		fread(&d, sizeof(d), 1, fp); dfa.numStates = d;
		fread(&d, sizeof(d), 1, fp); dfa.initialState = d;
		if (dfa.stateNext)
			FREE(dfa.stateNext);
		dfa.stateNext = ALLOC(word, dfa.numChars*dfa.numStates);
		fread(dfa.stateNext, sizeof(word), dfa.numChars*dfa.numStates, fp);
		if (dfa.acceptTable)
			FREE(dfa.acceptTable);
		dfa.acceptTable = ALLOC(dfaAcceptItem_t, dfa.numStates);
		for (dword i=0;i<dfa.numStates;i++)
		{
			fread(&d, sizeof(d), 1, fp); dfa.acceptTable[i].tag = d;
			fread(&d, sizeof(d), 1, fp); dfa.acceptTable[i].flags = d;
			fread(&d, sizeof(d), 1, fp); dfa.acceptTable[i].priority = (byte)d;
		}
		finalized = 1;
	}

// NFA Expressions -----------------------------------------

    nfaExpr_t* ExprCreate(byte inEdge)
    {
        nfaNode_t* n1;
        nfaNode_t* n2;
        nfaExpr_t* e;

		if ((!isCaseSensitive) && (inEdge >= 'A') && (inEdge <= 'Z'))
			inEdge = (inEdge - 'A') + 'a';
        edgesUsed += inEdge;
        e = new(eFact) nfaExpr_t;
        n1 = new(nFact) nfaNode_t;
        n2 = new(nFact) nfaNode_t;
        n1->edge = inEdge;
        n1->link1 = n2;
        e->first = n1;
        e->last = n2;
        return(e);
    }
    nfaExpr_t* ExprCreate(bitSet_t& inEdgeSet)
    {
        nfaNode_t* n1;
        nfaNode_t* n2;
        nfaExpr_t* e;

        edgesUsed |= inEdgeSet;
        e = new(eFact) nfaExpr_t;
        n1 = new(nFact) nfaNode_t;
        n2 = new(nFact) nfaNode_t;
        n1->edge = 0;
        n1->flags |= NFANF_EDGESET;
        n1->edgeSet = inEdgeSet;
        n1->link1 = n2;
        e->first = n1;
        e->last = n2;
        return(e);    
    }
    void ExprOr(nfaExpr_t* dest, nfaExpr_t* src)
    {
        nfaNode_t* n1;
        nfaNode_t* n2;

	    n1 = new(nFact) nfaNode_t;
	    n2 = new(nFact) nfaNode_t;
	    n1->edge = 0; n1->flags |= NFANF_EPSILON;
	    n1->link1 = dest->first;
	    n1->link2 = src->first;
	    dest->last->edge = 0; dest->last->flags |= NFANF_EPSILON;
	    src->last->edge = 0; src->last->flags |= NFANF_EPSILON;
	    dest->last->link1 = n2;
	    src->last->link1 = n2;
	    dest->last->link2 = src->last->link2 = NULL; // shouldn't be necessary
	    dest->first = n1;
	    dest->last = n2;
    }
    void ExprCat(nfaExpr_t* dest, nfaExpr_t* src)
    {
	    dest->last->edge = 0;
        dest->last->flags |= NFANF_EPSILON;
	    dest->last->link1 = src->first;
	    dest->last->link2 = NULL;
	    dest->last = src->last;
    }
    void ExprOneOrMore(nfaExpr_t* dest)
    {
        nfaNode_t* n1;
        nfaNode_t* n2;

	    n1 = new(nFact) nfaNode_t;
	    n2 = new(nFact) nfaNode_t;
	    n1->edge = 0; n1->flags |= NFANF_EPSILON;
	    n1->link1 = dest->first;
	    dest->last->edge = 0; dest->last->flags |= NFANF_EPSILON;
	    dest->last->link1 = n2;
	    dest->last->link2 = dest->first;
	    dest->first = n1;
	    dest->last = n2;
    }
    void ExprZeroOrMore(nfaExpr_t* dest)
    {
        nfaNode_t* n1;
        nfaNode_t* n2;

	    n1 = new(nFact) nfaNode_t;
	    n2 = new(nFact) nfaNode_t;
	    n1->edge = 0; n1->flags |= NFANF_EPSILON;
	    n1->link1 = dest->first;
        n1->link2 = n2;
	    dest->last->edge = 0; dest->last->flags |= NFANF_EPSILON;
	    dest->last->link1 = n2;
	    dest->last->link2 = dest->first;
	    dest->first = n1;
	    dest->last = n2;
    }
    void ExprZeroOrOne(nfaExpr_t* dest)
    {
        nfaNode_t* n1;
        nfaNode_t* n2;

	    n1 = new(nFact) nfaNode_t;
	    n2 = new(nFact) nfaNode_t;
	    n1->edge = 0; n1->flags |= NFANF_EPSILON;
	    n1->link1 = dest->first;
        n1->link2 = n2;
	    dest->last->edge = 0; dest->last->flags |= NFANF_EPSILON;
	    dest->last->link1 = n2;
	    dest->last->link2 = NULL;
	    dest->first = n1;
	    dest->last = n2;
    }
    nfaExpr_t* ExprString(char* str)
    {
        nfaExpr_t* e;
        nfaExpr_t* e2;

        if (!str)
            return(NULL);
        e = ExprCreate(*str);
        for (char* ptr = str+1; *ptr; ptr++)
        {
            e2 = ExprCreate(*ptr);
            ExprCat(e, e2);
        }
        return(e);
    }
    void RegisterExpr(nfaExpr_t* e, dword tag)
    {
        nfaNode_t* n;

        e->last->flags |= NFANF_ACCEPTING;
        e->last->tokenFunc = NULL;
        e->last->priority = activePriority;
        e->last->tag = tag;
        if (!startNode->link1)
        {
            startNode->edge = 0; startNode->flags |= NFANF_EPSILON;
            startNode->link1 = e->first;
            return;
        }
        n = new(nFact) nfaNode_t;
        n->edge = 0; n->flags |= NFANF_EPSILON;
        n->link1 = e->first;
        n->link2 = startNode->link2;
        startNode->link2 = n;
    }


// Regex Expressions -----------------------------------------

    byte RegexLetter(char*& regex, bool* outLiteral)
    {
        byte letter;

        *outLiteral = false;
        if (*regex == '\\')
        {
            *outLiteral = true;
            regex++;
            letter = *regex++;
            if (!letter)
                throw("Regex Syntax Error: Literal '\\' without character");
            switch(letter)
            {
            case 'n': letter = 10; break;
            case 't': letter = 9; break;
            default: break;
            }
            return(letter);
        }
        letter = *regex;
        if (!letter)
            return(0);
        regex++;
        return(letter);
    }
    bool RegexGroup(char*& regex, bitSet_t& s)
    {
        byte a, b;
        bool literal;

        a = RegexLetter(regex, &literal);
        if (!a)
            return(0);
        if (!literal)
        {
            if (a == '.')
            {
                for (byte i=1;i<254;i++)
                    s += i;
                s -= 10; // dot doesn't recognize \n
                return(1);
            }
		    else if (strchr("[]()*?+^|", a))
            {
                regex--;
                if (a != ']')
                    throw("Regex Syntax Error: Illegal character in group");
                return(0);
            }
        }
        if (*regex == '-')
        {
            regex++;
            b = RegexLetter(regex, &literal);
            if (!b)
                throw("Regex Syntax Error: '-' found in group without valid ending character");
            if (!literal)
            {
    		    if (strchr(".[]()*?+^|", a))
                {
                    regex--;
                    throw("Regex Syntax Error: Non-literal symbol is not a valid group character");
                }
            }
            for (byte i=a;i<=b;i++)
                s += i;
            return(1);
        }
        s += a;
        return(1);
    }
    nfaExpr_t* RegexRange(char*& regex)
    {
        bool negate = false;
        bitSet_t s(256);

        if (*regex == '^')
        {
            regex++;
            negate = true;
        }
        while (RegexGroup(regex, s))
            ;
        if (negate)
            s.Invert();
        return(ExprCreate(s));
    }
    nfaExpr_t* RegexFactorPrime(char*& regex)
    {
        nfaExpr_t* e;
        byte letter;
        bool literal;

        if (*regex == '(')
        {
            regex++;
            e = RegexExpr(regex);
            if (*regex != ')')
                throw("Regex Syntax Error: Expecting ')'");
            regex++;
            return(e);
        }
        if (*regex == '[')
        {
            regex++;
            e = RegexRange(regex);
            if (*regex != ']')
                throw("Regex Syntax Error: Expecting ']'");
            regex++;
            return(e);
        }
        letter = RegexLetter(regex, &literal);
        if (!letter)
            return(NULL);
        if (!literal)
        {
            if (letter == '.')
            {
                bitSet_t s(256);
                for (byte i=1;i<=254;i++)
                    s += i;
                s -= 10; // dot doesn't recognize \n
                e = ExprCreate(s);
                return(e);
            }
		    if (strchr("[]()*?+^|", letter))
            {
			    regex--;
                return(NULL);
            }
        }
        e = ExprCreate(letter);
        return(e);
    }
    nfaExpr_t* RegexFactor(char*& regex)
    {
        nfaExpr_t* e = RegexFactorPrime(regex);
        if (*regex == '*')
        {
            regex++;
            if (!e)
                throw("Regex Syntax Error: Modifier '*' without expression");
            ExprZeroOrMore(e);
            return(e);
        }
        if (*regex == '+')
        {
            regex++;
            if (!e)
                throw("Regex Syntax Error: Modifier '+' without expression");
            ExprOneOrMore(e);
            return(e);
        }
        if (*regex == '?')
        {
            regex++;
            if (!e)
                throw("Regex Syntax Error: Modifier '?' without expression");
            ExprZeroOrOne(e);
            return(e);
        }
        return(e);
    }
    nfaExpr_t* RegexTerm(char*& regex)
    {
        nfaExpr_t* e = RegexFactor(regex);
        nfaExpr_t* e2;
        if (!e)
            return(NULL);
        while (e2 = RegexFactor(regex))
            ExprCat(e, e2);
        return(e);
    }
    nfaExpr_t* RegexExpr(char*& regex)
    {
        nfaExpr_t* e = RegexTerm(regex);
        nfaExpr_t* e2;
        if (!e)
            return(NULL);
        while (*regex == '|')
        {
            regex++;
            e2 = RegexTerm(regex);
            if (!e2)
                throw("Regex Syntax Error: '|' without trailing term");
            ExprOr(e, e2);
        }
        return(e);
    }
    bool RegisterToken(char* inRegex, dword inTag, char* outError)
    {
        if (!inRegex)
        {
            if (outError)
                strcpy(outError, "Regex Syntax Error: NULL regex");
            return(0);
        }
        
        char* regex = inRegex;
        nfaExpr_t* e = NULL;
        try
        {
            e = RegexExpr(regex);
        }
        catch(char* exception)
        {
            if (outError)
                strcpy(outError, exception);
            return(0);
        }
        if (!e)
        {
            if (outError)
                strcpy(outError, "Regex Syntax Error: Nothing to register");
            return(0);
        }
        if (*regex)
        {
            if (outError)
                strcpy(outError, "Regex Syntax Error: Regex parse incomplete");
            return(0);
        }

        RegisterExpr(e, inTag);
        return(1);
    }


// Calculations -----------------------------------------

    inline void ComputeEpsilonClosure(bitSet_t& inSet)
    {
        static nfaNode_t* nodeStack[2048]; // hc
        nfaNode_t* n;
        dword nodeIndex=0;
        dword i;

        for (i=0;i<inSet.size;i++)
        {
            if (inSet.Contains(i))
                nodeStack[nodeIndex++] = nFact.NodeForId(i);
        }
        while (nodeIndex > 0)
        {
            nodeIndex--;
            n = nodeStack[nodeIndex];
            if (!(n->flags & NFANF_EPSILON))
                continue;
            if ((n->link1) && (!inSet.Contains(nFact.IdForNode(n->link1))))
            {
                inSet += nFact.IdForNode(n->link1);
                nodeStack[nodeIndex++] = n->link1;
            }
            if ((n->link2) && (!inSet.Contains(nFact.IdForNode(n->link2))))
            {
                inSet += nFact.IdForNode(n->link2);
                nodeStack[nodeIndex++] = n->link2;
            }
        }
    }

    inline void ComputeMove(bitSet_t& inSet, byte inEdge)
    {
        static bitSet_t outSet(2048); // hc
        nfaNode_t* n;
        dword i;

        if (!edgesUsed.Contains(inEdge))
        {
            inSet.Empty();
            return;
        }

        outSet.Empty();
        for (i=0;i<inSet.size;i++)
        {
            if (!inSet.Contains(i))
                continue;
            n = nFact.NodeForId(i);
            if (!n->link1)
                continue;
            if ((n->edge == inEdge) || ((n->flags & NFANF_EDGESET) && (n->edgeSet.Contains(inEdge))))
                outSet += nFact.IdForNode(n->link1);
        }
        inSet = outSet;
    }

    void MinimizeDFA()
    {        
	    static dfaPartitionSet_t parts;
        sdword i, k, m, p, first;
	    sdword trans, gfirst, gnext;

	    // initialize dfa stateParts array
	    dfa.stateParts = ALLOC(sdword, dfa.numStates);
	    for (i=0;i<(sdword)dfa.numStates;i++)
		    dfa.stateParts[i] = -1;
	    parts.Init();
	    parts.SetDFA(&dfa);

	    for (i=0;i<(sdword)dfa.numStates;i++)
		    parts.MoveToCurrent(i);
	    parts.Mark();

	    // split accepting states from nonaccepting states
	    for (i=0;i<(sdword)dfa.numStates;i++)
	    {
		    if (!(dfa.acceptTable[i].flags & NFANF_ACCEPTING))
			    continue;
		    for (k=1;k<parts.Num();k++)
		    {
			    m = parts[k].Next(0);
			    if (m == -1)
				    continue;
			    if ((i!=m) && (dfa.acceptTable[i] == dfa.acceptTable[m]))
			    {
				    parts.MoveTo(i, k);
				    break;
			    }
		    }
		    if (k >= parts.Num())
		    {
			    parts.MoveToCurrent(i);
			    parts.Mark();
		    }
	    }

	    // repeated column-by-column separation
	    do
	    {
		    trans = 0;
		    for (i=0;i<parts.Num();i++)
		    {			
			    for (p=0,first=k=parts[i].Next(0); k!=-1; k=parts[i].Next(p,&p))
			    {								
				    for (m=0;m<(sdword)dfa.numChars;m++)
				    {				
					    gfirst = dfa.stateNext[first*dfa.numChars+m];
					    gnext = dfa.stateNext[k*dfa.numChars+m];
					    if ((gfirst == 0xFFFF) && (gnext == 0xFFFF))
						    continue;
					    if (((gfirst == 0xFFFF) && (gnext != 0xFFFF))
					     || ((gfirst != 0xFFFF) && (gnext == 0xFFFF))
					     || (dfa.stateParts[gfirst] != dfa.stateParts[gnext]))
					    {						
						    if (dfa.stateParts[k] != parts.PendingCurrent())
						    {
							    trans = 1;
							    parts.MoveToCurrent(k);
						    }
					    }
				    }
			    }
			    parts.Mark();
		    }
	    } while (trans);

	    // partitioning complete; assign partitions as new states

	    word *nstateNext = ALLOC(word, parts.Num()*dfa.numChars);
	    dfaAcceptItem_t *naccept = ALLOC(dfaAcceptItem_t, parts.Num());
	    
	    for (i=0;i<parts.Num();i++)
	    {
		    memcpy(&nstateNext[i*dfa.numChars], &dfa.stateNext[parts[i].Next(0)*dfa.numChars],
			    dfa.numChars*sizeof(word));
		    for (k=0;k<(sdword)dfa.numChars;k++)
			    if (nstateNext[i*dfa.numChars+k] != 0xFFFF)
				    nstateNext[i*dfa.numChars+k] = (word)dfa.stateParts[nstateNext[i*dfa.numChars+k]];
		    naccept[i] = dfa.acceptTable[parts[i].Next(0)];
	    }
	    dfa.initialState = dfa.stateParts[0];
	    dfa.numStates = parts.Num();
	    FREE(dfa.stateNext);
	    dfa.stateNext = nstateNext;
	    FREE(dfa.acceptTable);
	    dfa.acceptTable = naccept;
	    FREE(dfa.stateParts);
	    dfa.stateParts = NULL;
    }

    void ComputeDFA()
    {	    
	    bool dmark[DFA_MAXSTATES];
	    sdword i, k, m, p, curDstate;
	    nfaNode_t *accNode, *tempNode;
	    bool done = 0;

        bitSet_t::defaultSize = nFact.numNodes;
	    bitSet_t tstate;
        bitSet_t dstates[DFA_MAXSTATES];
        bitSet_t::defaultSize = 0;

	    dfa.numChars = 256; // hc
	    dfa.numStates = 0;
	    dfa.stateNext = ALLOC(word, dfa.numChars * DFA_MAXSTATES);
	    dfa.acceptTable = ALLOC(dfaAcceptItem_t, DFA_MAXSTATES);

	    for (i=0;i<DFA_MAXSTATES;i++)
		    dmark[i] = 0;
	    dstates[0].Empty();
	    dstates[0] += nFact.IdForNode(startNode);
	    ComputeEpsilonClosure(dstates[0]);
	    curDstate = 0;

	    accNode = NULL;
	    for (p=0; p<(int)dstates[curDstate].size; p++)
	    {
		    if (!dstates[curDstate].Contains(p))
			    continue;
		    if (!(nFact.NodeForId(p)->flags & NFANF_ACCEPTING))
                continue;
		    if ((!accNode) || (accNode->priority <= nFact.NodeForId(p)->priority))
			    accNode = nFact.NodeForId(p);
	    }

	    dfa.acceptTable[curDstate].flags = 0;
	    if (accNode)
	    {
		    dfa.acceptTable[curDstate].priority = accNode->priority;
		    dfa.acceptTable[curDstate].tag = accNode->tag;
		    dfa.acceptTable[curDstate].flags = NFANF_ACCEPTING;
		    dfa.acceptTable[curDstate].tokenFunc = accNode->tokenFunc;
	    }
	    
	    curDstate = 1;

	    while(!done)
	    {
		    //printf("1");
            done = 1;
		    for (i=0;i<curDstate;i++)
		    {
			    if (dmark[i])
				    continue;
                //printf("2");
                //printf("\nDState %d", i);
			    done = 0;
			    dmark[i] = 1;			    
			    
			    for (k=0; k<(sdword)dfa.numChars; k++)
			    {
        		    if (!edgesUsed.Contains(k))
                    {
                        dfa.stateNext[i*dfa.numChars+k] = 0xFFFF;
                        continue;
                    }
                    
                    //printf("3");
                    //printf(".");
				    tstate = dstates[i];
				    
				    ComputeMove(tstate, (byte)k);
				    
				    ComputeEpsilonClosure(tstate);
				    
				    if (tstate.IsEmpty())
				    {
					    dfa.stateNext[i*dfa.numChars+k] = 0xFFFF;
					    continue;
				    }
				    for (m=0;m<curDstate;m++)
					    if (tstate == dstates[m])
						    break;
				    if (m == curDstate)
				    {
					    dstates[curDstate] = tstate;
					    accNode = NULL;
					    for (p=0; p<(sdword)dstates[curDstate].size; p++)
					    {
                		    //printf("4");
                            tempNode = nFact.NodeForId(p);
						    if (!(tempNode->flags & NFANF_ACCEPTING))
                                continue;
						    if (!dstates[curDstate].Contains(p))
							    continue;
						    if ((!accNode) || (accNode->priority <= tempNode->priority))
							    accNode = tempNode;
					    }
					    dfa.acceptTable[curDstate].flags = 0;
					    if (accNode)
					    {
						    dfa.acceptTable[curDstate].priority = accNode->priority;
						    dfa.acceptTable[curDstate].tag = accNode->tag;
						    dfa.acceptTable[curDstate].flags = NFANF_ACCEPTING;
						    dfa.acceptTable[curDstate].tokenFunc = accNode->tokenFunc;
					    }
					    curDstate++;
					    if (curDstate >= DFA_MAXSTATES)
						    ERROR("ComputeDFA: Too many DFA states");
				    }
				    dfa.stateNext[i*dfa.numChars+k] = (word)m;
			    }
		    }
	    }

	    dfa.numStates = curDstate;
    }

    void FinalizeDFA()
    {
	    if (finalized)
            return;
        ComputeDFA();
        MinimizeDFA();
        finalized = 1;
    }

// Token Retrieval -----------------------------------------

    dword GetTokenNFA(bool advance, SLexToken* outToken)
    {
        static bitSet_t nodeSet(2048); // hc
        nfaNode_t* acceptNode;
        nfaNode_t* acceptNodeCandidate;
        dword i, consumed, acceptConsumed;
        SLexToken token;
        char* startTextPtr = textPtr;
        dword startLineCount = lineCount;
        dword startColumnCount = columnCount;

        if (!textPtr)
            return(0);
        
        token.tag = 0;
        while (!token.tag)
        {
            acceptNode = NULL;
            acceptConsumed = 0;
            consumed = 0;
            
            nodeSet.Empty();
            nodeSet += nFact.IdForNode(startNode);
            ComputeEpsilonClosure(nodeSet);

            token.textLine = lineCount;
            token.textColumn = columnCount;

            while(1)
            {
                if (!textPtr[consumed])
                    break; // end of input stream
                if (textPtr[consumed] == 13)
                {
                    consumed++;
                    continue; // carriage returns are ignored, only \n line feeds are processed
                }
            
				if ((!isCaseSensitive) && (textPtr[consumed] >= 'A') && (textPtr[consumed] <= 'Z'))
					ComputeMove(nodeSet, (byte)((textPtr[consumed] - 'A') + 'a'));
				else
					ComputeMove(nodeSet, (byte)textPtr[consumed]);

                ComputeEpsilonClosure(nodeSet);
                if (nodeSet.IsEmpty())
                    break;

                columnCount++;
                if (textPtr[consumed] == 10)
                {
                    lineCount++; columnCount = 0;
                }
                else if (textPtr[consumed] == 9)
                    columnCount += tabColumns-1;
                consumed++;
                acceptNodeCandidate = NULL;
                for (i=0;i<nodeSet.size;i++)
                {
                    if ((!(nFact.NodeForId(i)->flags & NFANF_ACCEPTING)) || (!nodeSet.Contains(i)))
                        continue;
                    if ((!acceptNodeCandidate) || (acceptNodeCandidate->priority < nFact.NodeForId(i)->priority))
                        acceptNodeCandidate = nFact.NodeForId(i);
                }
                if (acceptNodeCandidate)
                {
                    acceptNode = acceptNodeCandidate;
                    acceptConsumed = consumed;
                }
            }
            if (!acceptNode)
            {
                if (outToken)
                {
                    outToken->tag = 0;
                    outToken->lexeme = NULL;
                    outToken->lexemeLen = 0;
                }
                if (!advance)
                {
                    textPtr = startTextPtr;
                    lineCount = startLineCount;
                    columnCount = startColumnCount;
                }
                return(0);
            }
            
            token.tag = acceptNode->tag;
            token.lexeme = textPtr;
            token.lexemeLen = acceptConsumed;

            textPtr += acceptConsumed;

            if (acceptNode->tokenFunc)
                acceptNode->tokenFunc(this, &token);
        }
        
        if (!advance)
        {
            textPtr = startTextPtr;
            lineCount = startLineCount;
            columnCount = startColumnCount;
        }
        if (outToken)
            *outToken = token;
        return(token.tag);
    }

    dword GetToken(bool advance, SLexToken* outToken)
    {
        dword consumed, acceptConsumed;
        word curstate;
        dfaAcceptItem_t* acc;
        SLexToken token;
        char* startTextPtr = textPtr;
        dword startLineCount = lineCount;
        dword startColumnCount = columnCount;

        if (!finalized)
            return(GetTokenNFA(advance, outToken));

        if (!textPtr)
            return(0);
        
        token.tag = 0;
        while (!token.tag)
        {
            acceptConsumed = 0;
            consumed = 0;
	        curstate = (word)dfa.initialState;
            acc = NULL;

            token.textLine = lineCount;
            token.textColumn = columnCount;

	        while (1)
	        {
                //printf("Processing %c\n", textPtr[consumed]);
				//if (!strncmp(textPtr, "0.4", 3))
				//	printf("Snargus!");
                
                if (!textPtr[consumed])
                    break; // end of input stream
                if (textPtr[consumed] == 13)
                {
                    consumed++;
                    continue; // carriage returns are ignored, only \n line feeds are processed
                }
            
				if ((!isCaseSensitive) && (textPtr[consumed] >= 'A') && (textPtr[consumed] <= 'Z'))
				{
					if ((curstate = dfa.stateNext[curstate*dfa.numChars+((textPtr[consumed] - 'A') + 'a')]) == 0xFFFF)
						break;
				}
				else
				{
					if ((curstate = dfa.stateNext[curstate*dfa.numChars+textPtr[consumed]]) == 0xFFFF)
						break;
				}

                columnCount++;
                if (textPtr[consumed] == 10)
                {
                    lineCount++; columnCount = 0;
                }
                else if (textPtr[consumed] == 9)
                    columnCount += tabColumns-1;
                consumed++;
		        if (dfa.acceptTable[curstate].flags & NFANF_ACCEPTING)
		        {
			        acc = &dfa.acceptTable[curstate];
			        acceptConsumed = consumed;
		        }
	        }
            if (!acc)
            {
                if (outToken)
                {
                    outToken->tag = 0;
                    outToken->lexeme = NULL;
                    outToken->lexemeLen = 0;
                }
                if (!advance)
                {
                    textPtr = startTextPtr;
                    lineCount = startLineCount;
                    columnCount = startColumnCount;
                }
                //printf("Returning no match\n");
                return(0);
            }            
            
            token.tag = acc->tag;
            token.lexeme = textPtr;
            token.lexemeLen = acceptConsumed;

            textPtr += acceptConsumed;

            if (acc->tokenFunc)
                acc->tokenFunc(this, &token);            
        }

        if (!advance)
        {
            textPtr = startTextPtr;
            lineCount = startLineCount;
            columnCount = startColumnCount;
        }
        if (outToken)
            *outToken = token;
        //printf("Returning tag %d\n", token.tag);
        return(token.tag);
    }

	// ILexLexer
	NBool Destroy()
	{
		delete this;
		return(1);
	}
	NBool CaseSensitivity(NBool inIsCaseSensitive)
	{
		isCaseSensitive = (inIsCaseSensitive!=0);
		return(1);
	}
	NBool RegisterToken(NDword inTag, NChar* inRegex)
	{
	    return(RegisterToken(inRegex, inTag, lex_errorStr));
	}
	NByte TokenPriority(NByte inPriority)
	{
		NByte oldPriority = activePriority;
		activePriority = inPriority;
		return(oldPriority);
	}
	NBool TokenIntercept(NDword inTag, void (*inIntercept)(ILexLexer*, SLexToken*))
	{
		SetIntercept(inTag, inIntercept);
		return(1);
	}
	NBool Finalize()
	{
		FinalizeDFA();
		return(1);
	}
	NBool SaveFinalization(FILE* inFP)
	{
		SaveDFAToFile(inFP);
		return(1);
	}
	NBool LoadFinalization(FILE* inFP)
	{
		LoadDFAFromFile(inFP);
		return(1);
	}
	NBool SetText(NChar* inText, NDword inLine, NDword inColumn, NDword inTabColumns)
	{
		textPtr = inText;
		lineCount = inLine;
		columnCount = inColumn;
		tabColumns = inTabColumns;
		if (!tabColumns)
			tabColumns = 8;
		return(1);
	}
	NChar* GetText(NDword* outLine, NDword* outColumn)
	{
		if (outLine) *outLine = lineCount;
		if (outColumn) *outColumn = columnCount;
		return(textPtr);
	}
	NChar PeekChar()
	{
		if (!textPtr)
			return(0);
		return(*textPtr);
	}
	NChar GetChar()
	{
		if (!textPtr)
			return(0);
		columnCount++;
		if (*textPtr == 10)
		{
			lineCount++;
			columnCount = 0;
		}
		textPtr++;
		return(textPtr[-1]);
	}
	NDword PeekToken(SLexToken* outToken)
	{
	    return(GetToken(false, outToken));
	}
	NDword GetToken(SLexToken* outToken)
	{
	    return(GetToken(true, outToken));
	}
};

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
KRN_API ILexLexer* LEX_CreateLexer()
{
	return(new lexer_t);
}
KRN_API NChar* LEX_GetLastError()
{
	return(lex_errorStr);
}

//============================================================================
//    CLASS METHODS
//============================================================================

//****************************************************************************
//**
//**    END MODULE LEXMAIN.CPP
//**
//****************************************************************************

