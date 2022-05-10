/*
 * FILE:
 *   fortify.c
 *
 * DESCRIPTION:
 *     A fortified shell for malloc, realloc, calloc and free.
 *     To use Fortify, each source file will need to #include "fortify.h".  To
 * enable  Fortify,  define the symbol FORTIFY.  If FORTIFY is not defined, it
 * will compile away to nothing.  If you do not have stdout available, you may
 * wish  to  set  an  alternate output function.  See Fortify_SetOutputFunc(),
 * below.
 *     You will also need to link in fortify.o
 *
 *     None of the functions in this file should really be called
 *   directly; they really should be called through the macros
 *   defined in fortify.h
 *
 */
#ifdef FORTIFY
 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <ctype.h>

#define __FORTIFY_C__ /* So fortify.h knows to not define the fortify macros */
#include "fortify.h"

#include "ufortify.h" /* the user's options */

struct Header
{
	char          *File;   /* The sourcefile of the caller   */
	unsigned long  Line;   /* The sourceline of the caller   */
	size_t         Size;   /* The size of the malloc'd block */
	struct Header *Prev,   /* List pointers                  */
                  *Next; 
	int            Scope;
	int            Checksum;  /* For validating the Header structure; see ChecksumHeader() */
};

static int CheckBlock(struct Header *h, char *file, unsigned long line);
static int CheckFortification(unsigned char *ptr, unsigned char value, size_t size);
static void SetFortification(unsigned char *ptr, unsigned char value, size_t size);
static void OutputFortification(unsigned char *ptr, unsigned char value, size_t size);
static int IsHeaderValid(struct Header *h);
static void MakeHeaderValid(struct Header *h);
static int ChecksumHeader(struct Header *h);
static int IsOnList(struct Header *h);
static void OutputHeader(struct Header *h);
static void OutputMemory(struct Header *h);

static void st_DefaultOutput(char *String)
{
	printf(String);
}

static struct Header *st_Head = 0; /* Head of alloc'd memory list */
static OutputFuncPtr  st_Output = st_DefaultOutput; /* Output function for errors */
static char st_Buffer[256];       /* Temporary buffer for sprintf's */
static int st_Disabled = 0;       /* If true, Fortify is inactive */
static int st_MallocFailRate = 0; /* % of the time to fail mallocs */

static char          *st_LastVerifiedFile = "unknown";
static unsigned long  st_LastVerifiedLine = 0;
static int            st_Scope            = 0;
static void           OutputLastVerifiedPoint(void);

/*
 * Fortify_malloc() - Allocates a block of memory, with extra bits for
 *                    misuse protection/detection. 
 *
 *    Features:
 *     +  Adds the malloc'd memory onto Fortify's own private list.
 *        (With a checksum'd header to detect corruption of the memory list)
 *     +  Places sentinals on either side of the user's memory with
 *        known data in them, to detect use outside of the bounds
 *        of the block
 *     +  Initializes the malloc'd memory to some "nasty" value, so code
 *        can't rely on it's contents.
 *     +  Can check all sentinals on every malloc.
 *     +  Can generate a warning message on a malloc fail.
 *     +  Can randomly "fail" at a set fail rate
 */
void *FORTIFY_STORAGE
Fortify_malloc(size_t size, char *file, unsigned long line)
{
	unsigned char *ptr;
	struct Header *h;

	FORTIFY_LOCK();

	if(st_Disabled)
	{
		ptr = malloc(size);
		FORTIFY_UNLOCK();
		return(ptr);
	}

#ifdef CHECK_ALL_MEMORY_ON_MALLOC
	Fortify_CheckAllMemory(file, line);
#endif  

	if(size == 0)
	{
#ifdef WARN_ON_ZERO_MALLOC
    	sprintf(st_Buffer, 
        	    "\nFortify: %s.%ld\n         malloc(0) attempted failed\n",
            	file, line);
		st_Output(st_Buffer);
#endif

		FORTIFY_UNLOCK();
		return(0);       
	}

	if(st_MallocFailRate > 0)
	{
		if(rand() % 100 < st_MallocFailRate)
		{
#ifdef WARN_ON_FALSE_FAIL
			sprintf(st_Buffer, 
					"\nFortify: %s.%ld\n         malloc(%ld) \"false\" failed\n",
							file, line, (unsigned long)size);
			st_Output(st_Buffer);
#endif
			FORTIFY_UNLOCK();
			return(0);
		}
	}
  
	/*
	 * malloc the memory, including the space for the header and fortification
	 * buffers
	 */  
#ifdef WARN_ON_SIZE_T_OVERFLOW               
	{
		size_t private_size = sizeof(struct Header) 
							+ FORTIFY_BEFORE_SIZE + size + FORTIFY_AFTER_SIZE;

		if(private_size < size) /* Check to see if the added baggage is larger than size_t */
		{
			sprintf(st_Buffer, 
					"\nFortify: %s.%ld\n         malloc(%ld) has overflowed size_t.\n",
					file, line, (unsigned long)size);
			st_Output(st_Buffer);                      
			FORTIFY_UNLOCK();
			return(0);
		}                              
	}
#endif                              

	ptr = malloc(sizeof(struct Header) + 
				 FORTIFY_BEFORE_SIZE + size + FORTIFY_AFTER_SIZE);
	if(!ptr)
	{
#ifdef WARN_ON_MALLOC_FAIL
		sprintf(st_Buffer, "\nFortify: %s.%ld\n         malloc(%ld) failed\n",
				file, line, (unsigned long)size);
		st_Output(st_Buffer);
#endif

		FORTIFY_UNLOCK();
		return(0);       
	}

	/*
	 * Initialize and validate the header
	 */
	h = (struct Header *)ptr;

	h->Size = size;
  
	h->File = file;
	h->Line = line;  
 
	h->Next = st_Head;
	h->Prev = 0;
	
	h->Scope = st_Scope;

	if(st_Head)
	{
		st_Head->Prev = h;
		MakeHeaderValid(st_Head);  
	}

	st_Head = h;
  
	MakeHeaderValid(h);


	/*
	 * Initialize the fortifications
	 */    
	SetFortification(ptr + sizeof(struct Header),
	                 FORTIFY_BEFORE_VALUE, FORTIFY_BEFORE_SIZE);
	SetFortification(ptr + sizeof(struct Header) + FORTIFY_BEFORE_SIZE + size,
	                 FORTIFY_AFTER_VALUE, FORTIFY_AFTER_SIZE);

#ifdef FILL_ON_MALLOC 
	/*
	 * Fill the actual user memory
	 */  
	SetFortification(ptr + sizeof(struct Header) + FORTIFY_BEFORE_SIZE,
	                 FILL_ON_MALLOC_VALUE, size);
#endif

	/*
	 * We return the address of the user's memory, not the start of the block,
	 * which points to our magic cookies
	 */

	FORTIFY_UNLOCK();

	return(ptr + sizeof(struct Header) + FORTIFY_BEFORE_SIZE);
}

/* 
 * Fortify_free() - This free must be used for all memory allocated with
 *                  Fortify_malloc().
 *
 *   Features:
 *     + Pointers are validated before attempting a free - the pointer
 *       must point to a valid malloc'd bit of memory.
 *     + Detects attempts at freeing the same block of memory twice
 *     + Can clear out memory as it is free'd, to prevent code from using
 *       the memory after it's been freed.
 *     + Checks the sentinals of the memory being freed.
 *     + Can check the sentinals of all memory.
 */
 
void FORTIFY_STORAGE
Fortify_free(void *uptr, char *file, unsigned long line)
{
	unsigned char *ptr = (unsigned char *)uptr - sizeof(struct Header) - FORTIFY_BEFORE_SIZE;
	struct Header *h = (struct Header *)ptr;

	FORTIFY_LOCK();
  
	if(st_Disabled)
	{
		free(uptr);
		FORTIFY_UNLOCK();
		return;
	}

#ifdef CHECK_ALL_MEMORY_ON_FREE
	Fortify_CheckAllMemory(file, line);
#endif  

#ifdef PARANOID_FREE
	if(!IsOnList(h))
	{
		sprintf(st_Buffer, 
		 "\nFortify: %s.%ld\n         Invalid pointer, corrupted header, or possible free twice\n",
				file, line);
		st_Output(st_Buffer);
		OutputLastVerifiedPoint();
		goto fail;
	}
#endif

	if(!CheckBlock(h, file, line))
		goto fail;
    
	/*
	 * Remove the block from the list
	 */
	if(h->Prev)
	{
		if(!CheckBlock(h->Prev, file, line))
			goto fail;
      
		h->Prev->Next = h->Next;
		MakeHeaderValid(h->Prev);
	}
	else
		st_Head = h->Next;
  
	if(h->Next)
	{
		if(!CheckBlock(h->Next, file, line))
			goto fail;

		h->Next->Prev = h->Prev;
		MakeHeaderValid(h->Next);    
	}    

#ifdef FILL_ON_FREE
	/*
	 * Nuke out all memory that is about to be freed
	 */
	SetFortification(ptr, FILL_ON_FREE_VALUE, 
	                 sizeof(struct Header) + FORTIFY_BEFORE_SIZE + h->Size + FORTIFY_AFTER_SIZE);
#endif               

	/*
	 * And do the actual free
	 */
	free(ptr);
	FORTIFY_UNLOCK();
	return;

fail:
	sprintf(st_Buffer, "         free(%p) failed\n", uptr);
	st_Output(st_Buffer);  
	FORTIFY_UNLOCK();
}

/*
 * Fortify_realloc() - Uses Fortify_malloc() and Fortify_free() to implement
 *                     realloc().
 *
 *   Features: 
 *        + The realloc'd block is ALWAYS moved.
 *        + The pointer passed to realloc() is verified in the same way that 
 *          Fortify_free() verifies pointers before it frees them.
 *        + All the Fortify_malloc() and Fortify_free() protection
 */
void *FORTIFY_STORAGE
Fortify_realloc(void *ptr, size_t new_size, char *file, unsigned long line)
{
	void *new_ptr;
	struct Header *h = (struct Header *)
	                   ((unsigned char *)ptr - sizeof(struct Header) - FORTIFY_BEFORE_SIZE);

	if(st_Disabled)
	{
		FORTIFY_LOCK();
		new_ptr = realloc(ptr, new_size);
		FORTIFY_UNLOCK();
		return(new_ptr);
	}

	if(!ptr)
		return(Fortify_malloc(new_size, file, line));
    
	FORTIFY_LOCK();

	if(!IsOnList(h))
	{
		sprintf(st_Buffer, 
				"\nFortify: %s.%ld\n         Invalid pointer or corrupted header passed to realloc\n",
				file, line);
		st_Output(st_Buffer);
		goto fail;
	}

	if(!CheckBlock(h, file, line))
		goto fail;
  
	new_ptr = Fortify_malloc(new_size, file, line);
	if(!new_ptr)
	{
		FORTIFY_UNLOCK();
		return(0);
	}
  
	if(h->Size < new_size) 
		memcpy(new_ptr, ptr, h->Size);
	else
		memcpy(new_ptr, ptr, new_size);

	Fortify_free(ptr, file, line);
	FORTIFY_UNLOCK();
	return(new_ptr);
  
fail:
	sprintf(st_Buffer, "         realloc(%p, %ld) failed\n", ptr, (unsigned long)new_size);
	st_Output(st_Buffer);  
	FORTIFY_UNLOCK();
	return (NULL);
}     

/*
 * Fortifty_calloc() - Uses Fortify_malloc() to implement calloc(). Much
 *                     the same protection as Fortify_malloc().
 */
void *FORTIFY_STORAGE
Fortify_calloc(size_t num, size_t size, char *file, unsigned long line)
{
	void *ptr;

	ptr = Fortify_malloc(num * size, file, line);
  
	if(ptr)
		memset(ptr, 0, num * size);

	return(ptr);
}

/*
 * Fortify_CheckPointer() - Returns true if the uptr points to a valid
 *   piece of Fortify_malloc()'d memory. The memory must be on the malloc'd
 *   list, and it's sentinals must be in tact.
 *     If anything is wrong, an error message is issued.
 *
 *   (Note - if fortify is disabled, this function always returns true).
 */
int FORTIFY_STORAGE
Fortify_CheckPointer(void *uptr, char *file, unsigned long line)
{
	unsigned char *ptr = (unsigned char *)uptr - sizeof(struct Header) - FORTIFY_BEFORE_SIZE;
	int r;
  
	if(st_Disabled)
		return(1);

	FORTIFY_LOCK();

	if(!IsOnList((struct Header *)ptr))
	{
		sprintf(st_Buffer, 
		       "\nFortify: %s.%ld\n         Invalid pointer or corrupted header detected (%p)\n",
		       file, line, uptr);
		st_Output(st_Buffer);
		FORTIFY_UNLOCK();
		return(0);
	}

	r = CheckBlock((struct Header *)ptr, file, line);
	FORTIFY_UNLOCK();
	return r;
}

/*
 * Fortify_SetOutputFunc(OutputFuncPtr Output) - Sets the function used to
 *   output all error and diagnostic messages by fortify. The output function 
 *   takes a single unsigned char * argument, and must be able to handle newlines.
 *     The function returns the old pointer.
 */
#pragma warning(disable : 4090 4028)
Fortify_OutputFuncPtr FORTIFY_STORAGE
Fortify_SetOutputFunc(Fortify_OutputFuncPtr Output)
{
	OutputFuncPtr Old = st_Output;

	st_Output = Output;
  
	return(Old);
}

/*
 * Fortify_SetMallocFailRate(int Percent) - Fortify_malloc() will make the
 *   malloc attempt fail this Percent of the time, even if the memory is
 *   available. Useful to "stress-test" an application. Returns the old
 *   value. The fail rate defaults to 0.
 */
int FORTIFY_STORAGE
Fortify_SetMallocFailRate(int Percent)
{
	int Old = st_MallocFailRate;
  
	st_MallocFailRate = Percent;
  
	return(Old);
}

 
/*
 * Fortify_CheckAllMemory() - Checks the sentinals of all malloc'd memory.
 *   Returns the number of blocks that failed. 
 *
 *  (If Fortify is disabled, this function always returns 0).
 */
int FORTIFY_STORAGE
Fortify_CheckAllMemory(char *file, unsigned long line)
{
	struct Header *curr = st_Head;
	int count = 0;

	if(st_Disabled)
		return(0);

	FORTIFY_LOCK();

	while(curr)
	{
		if(!CheckBlock(curr, file, line))
			count++;

		curr = curr->Next;      
	}
  
	if(file)
	{
		st_LastVerifiedFile = file;
		st_LastVerifiedLine = line;
	}

	FORTIFY_UNLOCK();
	return(count);
}

/* Fortify_EnterScope - enters a new Fortify scope level. 
 * returns the new scope level.
 */
int FORTIFY_STORAGE
Fortify_EnterScope(char *file, unsigned long line)
{
	return(++st_Scope);
}

/* Fortify_LeaveScope - leaves a Fortify scope level,
 * also prints a memory dump of all non-freed memory that was allocated
 * during the scope being exited.
 */
int FORTIFY_STORAGE
Fortify_LeaveScope(char *file, unsigned long line)
{
	struct Header *curr = st_Head;
	int count = 0;
	unsigned long size = 0;

	if(st_Disabled)
		return(0);

	FORTIFY_LOCK();

	st_Scope--;
	while(curr)
	{
		if(curr->Scope > st_Scope)
		{
			if(count == 0)
			{
				sprintf(st_Buffer, "\nFortify: Memory Dump at %s.%ld\n", file, line);
				st_Output(st_Buffer);
				OutputLastVerifiedPoint();
				sprintf(st_Buffer, "%11s %8s %s\n", "Address", "Size", "Allocator");
				st_Output(st_Buffer);
			}
			
			OutputHeader(curr);
			count++;
			size += curr->Size;
		}

		curr = curr->Next;      
	}

	if(count)
	{
		sprintf(st_Buffer, "%11s %8ld bytes overhead\n", "and",
						(unsigned long)(count * (sizeof(struct Header) + FORTIFY_BEFORE_SIZE + FORTIFY_AFTER_SIZE)));
						st_Output(st_Buffer);

		sprintf(st_Buffer,"%11s %8ld bytes in %d blocks\n", "total", size, count);
		st_Output(st_Buffer);
	}

	FORTIFY_UNLOCK();
	return(count);
}

/*
 * Fortify_OutputAllMemory() - Outputs the entire list of currently
 *     malloc'd memory. For each malloc'd block is output it's Address,
 *   Size, and the SourceFile and Line that allocated it.
 *
 *   If there is no memory on the list, this function outputs nothing.
 *
 *   It returns the number of blocks on the list, unless fortify has been
 *   disabled, in which case it always returns 0.
 */
int FORTIFY_STORAGE
Fortify_OutputAllMemory(char *file, unsigned long line)
{
	struct Header *curr = st_Head;
	int count = 0;
	unsigned long size = 0;

	if(st_Disabled)
		return(0);

	FORTIFY_LOCK();

	if(curr)
	{
		sprintf(st_Buffer, "\nFortify: Memory Dump at %s.%ld\n", file, line);
		st_Output(st_Buffer);
		OutputLastVerifiedPoint();
		sprintf(st_Buffer, "%11s %8s %s\n", "Address", "Size", "Allocator");
		st_Output(st_Buffer);
                                
		while(curr)
		{
			OutputHeader(curr);
			count++;
			size += curr->Size;
			curr = curr->Next;      
		}
                     
		sprintf(st_Buffer, "%11s %8ld bytes overhead\n", "and", 
				(unsigned long)(count * (sizeof(struct Header) + FORTIFY_BEFORE_SIZE + FORTIFY_AFTER_SIZE)));
		st_Output(st_Buffer);

		sprintf(st_Buffer,"%11s %8ld bytes in %d blocks\n", "total", size, count);  
		st_Output(st_Buffer);
	}
  
	FORTIFY_UNLOCK();
	return(count);
}

/* Fortify_DumpAllMemory(Scope) - Outputs the entire list of currently
 * new'd memory within the specified scope. For each new'd block is output
 * it's Address, Size, the SourceFile and Line that allocated it, a hex dump
 * of the contents of the memory and an ascii dump of printable characters.
 *
 * If there is no memory on the list, this function outputs nothing.
 *
 * It returns the number of blocks on the list, unless Fortify has been
 * disabled, in which case it always returns 0.
 */
int FORTIFY_STORAGE
Fortify_DumpAllMemory(int scope, char *file, unsigned long line)
{
	struct Header *curr = st_Head;
	int count = 0;
	unsigned long size = 0;

	if(st_Disabled)
		return(0);

	FORTIFY_LOCK();

	while(curr)
	{
		if(curr->Scope >= scope)
		{
			if(count == 0)
			{
				sprintf(st_Buffer, "\nFortify: Memory Dump at %s.%ld\n", file, line);
				st_Output(st_Buffer);
				OutputLastVerifiedPoint();
				sprintf(st_Buffer, "%11s %8s %s\n", "Address", "Size", "Allocator");
				st_Output(st_Buffer);
			}

			OutputHeader(curr);
			OutputMemory(curr);
			st_Output("\n");
			count++;
			size += curr->Size;
		}

		curr = curr->Next;
	}

	if(count)
	{
		sprintf(st_Buffer, "%11s %8ld bytes overhead\n", "and",
						(unsigned long)(count * (sizeof(struct Header) + FORTIFY_BEFORE_SIZE + FORTIFY_AFTER_SIZE)));
						st_Output(st_Buffer);

		sprintf(st_Buffer,"%11s %8ld bytes in %d blocks\n", "total", size, count);
		st_Output(st_Buffer);
	}

	FORTIFY_UNLOCK();
	return(count);
}

/*
 * Fortify_Disable() - This function provides a mechanism to disable Fortify
 *   without recompiling all the sourcecode. It can only be called, though,
 *   when there is no memory on the Fortify malloc'd list. (Ideally, at the 
 *   start of the program before any memory has been allocated). If you
 *   call this function when there IS memory on the Fortify malloc'd list,
 *   it will issue an error, and fortify will not be disabled.
 */
int FORTIFY_STORAGE
Fortify_Disable(char *file, unsigned long line)
{
	int result;
	FORTIFY_LOCK();

	if(st_Head)
	{
		sprintf(st_Buffer, "Fortify: %s.%d\n", file, line);
		st_Output(st_Buffer);
		st_Output("         Fortify_Disable failed\n");
		st_Output("         (because there is memory on the Fortify memory list)\n");
    
		Fortify_OutputAllMemory(file, line);
		result = 0;            
	}
	else
	{
		st_Disabled = 1;
		result = 1;
	}
  
	FORTIFY_UNLOCK();
	return(result);
}

/* 
 * Check a block's header and fortifications.
 */
static int CheckBlock(struct Header *h, char *file, unsigned long line)
{   
	unsigned char *ptr = (unsigned char *)h;
	int result = 1;

	if(!IsHeaderValid(h))
	{
		sprintf(st_Buffer, 
				"\nFortify: %s.%ld\n         Invalid pointer or corrupted header detected (%p)\n",
				file, line, ptr + sizeof(struct Header) + FORTIFY_BEFORE_SIZE);
		st_Output(st_Buffer);
		OutputLastVerifiedPoint();
		return(0);
	}

	if(!CheckFortification(ptr + sizeof(struct Header),
		                   FORTIFY_BEFORE_VALUE, FORTIFY_BEFORE_SIZE))
	{
		sprintf(st_Buffer,
		        "\nFortify: %s.%ld\n         Memory overrun detected before block\n",
		        file, line);
		st_Output(st_Buffer);

		sprintf(st_Buffer,"         (%p,%ld,%s.%ld)\n",
		        ptr + sizeof(struct Header) + FORTIFY_BEFORE_SIZE,
		       (unsigned long)h->Size, h->File, h->Line);
		st_Output(st_Buffer);
    
		OutputFortification(ptr + sizeof(struct Header),
		                    FORTIFY_BEFORE_VALUE, FORTIFY_BEFORE_SIZE);
		OutputLastVerifiedPoint();
		result = 0;                        
	}
                           
	if(!CheckFortification(ptr + sizeof(struct Header) + FORTIFY_BEFORE_SIZE + h->Size,
	                       FORTIFY_AFTER_VALUE, FORTIFY_AFTER_SIZE))
	{
		sprintf(st_Buffer, "\nFortify: %s.%ld\n         Memory overrun detected after block\n",
		                   file, line);
		st_Output(st_Buffer);

		sprintf(st_Buffer,"         (%p,%ld,%s.%ld)\n",
		                  ptr + sizeof(struct Header) + FORTIFY_BEFORE_SIZE,
		                 (unsigned long)h->Size, h->File, h->Line);
		st_Output(st_Buffer);

		OutputFortification(ptr + sizeof(struct Header) + FORTIFY_BEFORE_SIZE + h->Size,
		                    FORTIFY_AFTER_VALUE, FORTIFY_AFTER_SIZE);
		OutputLastVerifiedPoint();
		result = 0;
	}
 
	return(result);    
}

/*
 * Checks if the _size_ bytes from _ptr_ are all set to _value_
 */
static int CheckFortification(unsigned char *ptr, unsigned char value, size_t size)
{
	while(size--)
		if(*ptr++ != value)
			return(0);
      
	return(1);      
}

/*
 * Set the _size_ bytes from _ptr_ to _value_.
 */
static void SetFortification(unsigned char *ptr, unsigned char value, size_t size)
{
	memset(ptr, value, size);
}

/*
 * Output the corrupted section of the fortification 
 */
// Output the corrupted section of the fortification
static void
OutputFortification(unsigned char *ptr, unsigned char value, size_t size)
{
	unsigned long offset, column;
	char	ascii[17];

	st_Output("Address     Offset Data");

	offset = 0;
	column = 0;

	while(offset < size)
	{
		if(column == 0)
		{
			sprintf(st_Buffer, "\n%8p %8d ", ptr, offset);
			st_Output(st_Buffer);
		}

		sprintf(st_Buffer, "%02x ", *ptr);
		st_Output(st_Buffer);

		ascii[ column ] = isprint( *ptr ) ? (char)(*ptr) : (char)(' ');
		ascii[ column + 1 ] = '\0';

		ptr++;
		offset++;
		column++;

		if(column == 16)
		{
			st_Output( "   \"" );
			st_Output( ascii );
			st_Output( "\"" );
			column = 0;
		}
	}

	if ( column != 0 )
	{
		while ( column ++ < 16 )
		{
			st_Output( "   " );
		}
		st_Output( "   \"" );
		st_Output( ascii );
		st_Output( "\"" );
	}

	st_Output("\n");
}

/*
 * Returns true if the supplied pointer does indeed point to a real Header
 */
static int IsHeaderValid(struct Header *h)                                
{
	return(!ChecksumHeader(h));
}

/*
 * Updates the checksum to make the header valid
 */
static void MakeHeaderValid(struct Header *h)
{
	h->Checksum = 0;
	h->Checksum = -ChecksumHeader(h);
}

/*
 * Calculate (and return) the checksum of the header. (Including the Checksum
 * variable itself. If all is well, the checksum returned by this function should
 * be 0.
 */
static int ChecksumHeader(struct Header *h)
{
	int c, checksum, *p;
  
	for(c = 0, checksum = 0, p = (int *)h; c < sizeof(struct Header)/sizeof(int); c++)
		checksum += *p++;  
    
	return(checksum);
}                  

/* 
 * Examines the malloc'd list to see if the given header is on it.
 */  
static int IsOnList(struct Header *h)
{
	struct Header *curr;
  
	curr = st_Head;
	while(curr)
	{
		if(curr == h)
			return(1);
      
		curr = curr->Next;
	}
  
	return(0);
}

/*
 * Hex and ascii dump the memory
 */
static void
OutputMemory(struct Header *h)
{
	OutputFortification((unsigned char*)h + sizeof(struct Header) + FORTIFY_BEFORE_SIZE,
						0, h->Size);
}


/*
 * Output the header...
 */
static void OutputHeader(struct Header *h)
{
	sprintf(st_Buffer, "%11p %8ld %s.%ld (%d)\n", 
	                   (unsigned char*)h + sizeof(struct Header) + FORTIFY_BEFORE_SIZE,
	                   (unsigned long)h->Size,
	                   h->File, h->Line, h->Scope);
	st_Output(st_Buffer);
}

static void OutputLastVerifiedPoint()
{
	sprintf(st_Buffer, "\nLast Verified point: %s.%ld\n", 
	                   st_LastVerifiedFile,
	                   st_LastVerifiedLine);
	st_Output(st_Buffer);
}


#endif /* FORTIFY */
