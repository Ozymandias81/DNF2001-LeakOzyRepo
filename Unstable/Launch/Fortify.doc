
         Fortify - fortified memory allocation shell for C and C++
         ---------------------------------------------------------
                        written by Simon P. Bullen
                               Cybergraphic
                               
                           Release 1.0, 2/2/1995




           This  software  is  not  public domain.  All material in
       this  archive  is  ©  Copyright  1995 Simon P.  Bullen.  The
       software  is freely distrubtable, with the condition that no
       more than a nominal fee is charged for media.  Everything in
       this  distrubution  must  be  kept  together,  in  original,
       unmodified form.
           The files may be modified for your own personal use, but
       modified files may not be distributed.
           The material is provided "as is" without warranty of any
       kind.  The author accepts no responsibilty for damage caused
       by this software.



                       email: sbullen@ozemail.com.au
                       snail: Simon P. Bullen
                              PO BOX 12138
                              A'Beckett St
                              Melbourne 3000
                              Australia



    CONTENTS
    --------
    Your archive should have the following files:

               file_id.diz
               fortify.c       
               fortify.doc     
               fortify.h
               read.me
               test.c          
               ufortify.h    
               ufortify.hpp
               zfortify.cpp
               zfortify.hpp
               ztest.cpp     




    OVERVIEW
    --------        
    Fortify  is  a  descendant of a library I wrote way back in 1990 called
SafeMem.   It is a (fortified) shell for memory allocations.  It works with
the  malloc/free family of functions, as well as new/delete in C++.  It can
be  adapted  to  most  memory management functions; the original version of
SafeMem  worked  only  with  the  Amiga's AllocMem/FreeMem.  I haven't been
writing  much  Amiga  specific  software  lately,  so  the Amiga version of
Fortify is way out of date, hence it's absense from this archive.

    Fortify  is  designed  to  detect  bad things happening, or at the very
least encourage intermittent problems to occur all the time.  It is capable
of  detecting  memory  leaks,  writes  beyond and before memory blocks, and
breaks  software  that  relies  on  the  state of uninitialized memory, and
software that uses memory after it's been freed.

    It  works  by  allocating  extra  space on each block.  This includes a
private  header (which is used to keep track of Fortify's list of allocated
memory),  and  two  "fortification"  zones  or sentinals (which are used to
detect writing outside the bound of the user's memory).




    Fortify VERSUS ZFortify
    -----------------------
    Fortify  provides  fortification  for malloc/realloc/free, and ZFortify
provides  fortifications  for  new/delete.   It  is  possible  to  use both
versions  in  the one program, if you are mixing C and C++.  Just make sure
(as  you  already  should  be)  that you never free() memory you new'd, and
other such illegal mismatching.
    (Why _Z_ fortify? It's a long story...)



    Fortify INSTALLATION (C)
    ------------------------
    To use Fortify, each source file will need to #include "fortify.h".  To
enable  Fortify,  define the symbol FORTIFY.  If FORTIFY is not defined, it
will compile away to nothing.  If you do not have stdout available, you may
wish  to  set  an  alternate output function.  See Fortify_SetOutputFunc(),
below.
    You will also need to link in fortify.o




    ZFortify INSTALLATION (C++)
    ---------------------------
    The  minimum  you  need  to  do  for  ZFortify  is to define the symbol
ZFORTIFY,  and  link  zfortify.o.   Each  source  file  should also include
"zfortify.hpp",  but  this  isn't  strictly  necessary.   If a file doesn't
#include  "Fortify.hpp",  then  it's  allocations  will still be fortified,
however  you  will  not  have  any source-code details in any of the output
messages (this will be the case for all libraries, etc, unless you have the
source for the library and can recompile it with Fortify).
    If  you  do not have stdout available, you may wish to set an alternate
output    function,    or    turn    on    the    AUTOMATIC_LOGFILE.    See
ZFortify_SetOutputFunc() and AUTOMATIC_LOGFILE, below.




    COMPILE TIME CUSTOMIZATIONS
    ---------------------------
    The  files "ufortify.h" and "ufortify.hpp" contain a number of #defines
that  you  can use to customize Fortify's behavior.  


    #define ZFORTIFY_PROVIDE_ARRAY_NEW

    Some C++ compilers have a separate operator for newing arrays.  If your
compiler  does,  you  will  need to define this symbol.  If you are unsure,
dont  worry  about  it too much, your program won't compile or link without
the  correct setting.  GCC 2.6.3 and Borland C++ 4.5 both need this symbol.
Microsoft C++ 1.5 and SAS 6.5 C++ both dont.


    #define FORTIFY_STORAGE

    #define ZFORTIFY_STORAGE

You  can  use  this  to apply a storage type to all of Fortify's exportable
functions.   If  you  are putting Fortify in an export library for example,
you may need to put __export here, or some such rubbish.


    #define FORTIFY_BEFORE_SIZE       32
    #define FORTIFY_BEFORE_VALUE    0xA3
                      
    #define FORTIFY_AFTER_SIZE        32
    #define FORTIFY_AFTER_VALUE     0xA5

    #define ZFORTIFY_BEFORE_SIZE      32
    #define ZFORTIFY_BEFORE_VALUE   0xA3
                      
    #define ZFORTIFY_AFTER_SIZE       32
    #define ZFORTIFY_AFTER_VALUE    0xA5

    These  values  define  how  much  "fortification" is placed around each
memory  block you allocate.  Fortify will place _BEFORE_SIZE bytes worth of
memory  right  before  your  allocation  block, and _AFTER_SIZE bytes worth
after your allocation block, and these will be initialized to _BEFORE_VALUE
and  _AFTER_VALUE  respectively.   If your program then accidentally writes
too  far  beyond the end of the block, for example, Fortify will be able to
detect this (so long as you didn't happen to write in _AFTER_VALUE!).

    If  you  don't  want  these  fortifications  to be allocated, specify a
_SIZE of 0.  Note that the _VALUE parameters are 8 bits.



    #define FILL_ON_MALLOC
    #define FILL_ON_MALLOC_VALUE    0xA7

    #define FILL_ON_NEW
    #define FILL_ON_NEW_VALUE       0xA7

    Programs  often  rely  on  uninitialized  memory  being  certain values
(usually  0).   If  you define FILL_ON_NEW, all memory that you new will be
initialized to FILL_ON_NEW_VALUE, which you should define to be some horrid
value  (definately  NOT  0).   This  will encourage all code that relies on
uninitialized memory to behave rather differently when Fortify is running.



    #define FILL_ON_FREE
    #define FILL_ON_FREE_VALUE       0xA9 

    #define FILL_ON_DELETE
    #define FILL_ON_DELETE_VALUE     0xA9 

    Programmers  often  try to use memory after they've freed it, which can
sometimes  work  (so long as noboby else has modified the memory before you
look  at  it), but is incredibly dangerous and definately bad practice.  If
FILL_ON_DELETE  is  defined,  all  memory you free will be stomped out with
FILL_ON_DELETE_VALUE,  which  ensures that any attempt to read freed memory
will give incorrect results.



    #define CHECK_ALL_MEMORY_ON_MALLOC
    #define CHECK_ALL_MEMORY_ON_FREE

    #define CHECK_ALL_MEMORY_ON_NEW 
    #define CHECK_ALL_MEMORY_ON_DELETE

    CHECK_ALL_MEMORY_ON...   means  that for every single memory allocation
or  deallocation,  every  single block of memory will be checked.  This can
considerably  slow  down  programs  if  you  have  a large number of blocks
allocated.   You would normally only need to turn this on if you are trying
to pinpoint where a corruption was occurring.
    A  block  of  memory  is  always  checked  when  it  is  freed,  so  if
CHECK_ALL...    isn't   turned  on,  corruptions  will  still  be  detected
eventually.
    You  can  also  force  Fortify  to  check  all  memory  with  a call to
Fortify_CheckAllMemory().   If you have a memory corruption you can't find,
sprinkling these through the suspect code will help narrow it down.



    #define PARANOID_FREE

    #define PARANOID_DELETE

    PARANOID_...   -  This means that zFortify traverses the memory list to
ensure  the  memory  you are about to free was really allocated by it.  You
probably  only need this in extreme circumstances.  Not having this defined
will  still  trap  attempts  to  free  memory that wasn't allocated, unless
someone is deliberately trying to fool zFortify.
    Paranoid  mode adds considerable overhead to freeing memory, especially
if  you  are  freeing things in the same order you allocated them (Paranoid
mode  is most efficient if you are freeing things in the reverse order they
were allocated).



    #define WARN_ON_MALLOC_FAIL
    #define WARN_ON_ZERO_MALLOC
    #define WARN_ON_FALSE_FAIL
    #define WARN_ON_UNSIGNED_LONG_OVERFLOW

    #define WARN_ON_NEW_FAIL
    #define WARN_ON_ZERO_NEW

    These defines enable the output of warning that aren't strictly errors,
but can be useful to determine what lead to a program crashing.
    WARN_ON_NEW_FAIL causes a debug to be issued whenever new fails.
    WARN_ON_ZERO_NEW  causes  a debug to be issued whenever a new of a zero
byte object is attempted.  This is fairly unlikely in C++, and is much more
likely when using malloc().
    WARN_ON_FALSE_FAIL  causes  a  debug to be issued when a new is "false"
failed.  ZSee Fortify_SetNewFailRate() for more information.
    WARN_ON_UNSIGNED_LONG_OVERFLOW causes Fortify to check for breaking the
32  bit  limit.   This  was  more of a problem in 16-bit applications where
breaking  the  16  bit  limit  was  much  more likely.  The problem is that
Fortify  adds  a small amount of overhead to a memory block; so in a 16-bit
size_t  environment,  if you tried to allocate 64K, Fortify would make that
block bigger than 64K and your allocation would fail due to the presence of
Fortify.   With size_t being 32 bits for all environments worth programming
in,  this  problem  is  extremely  unlikely  (Unless you plan to allocate 4
gigabytes).


    #define AUTOMATIC_LOG_FILE
    #define LOG_FILENAME            "fortify.log"
    #define FIRST_ERROR_FUNCTION    

    If  AUTOMATIC_LOG_FILE  is  defined  (C++ version /ZFortify only), then
Fortify will be automatically started for you, Fortify messages sent to the
named  log  file, and a list of unfreed memory dumped on termination (where
the  log  file  will  be  automatically  closed for you.  If no Fortify was
output,  the log file will not be altered.  There are timestamps in the log
file to ensure you're reading the correct messages.
    FIRST_ERROR_FUNCTION  will  be  called  upon  generation  of  the first
Fortify  message,  so  that  the  user  can  tell a Fortify report has been
generated.   Otherwise,  Fortify  would quietly write all this useful stuff
out to the log file, and no-one would know to look there!
                                           


    #define FORTIFY_LOCK()
    #define FORTIFY_UNLOCK()

    #define ZFORTIFY_LOCK()
    #define ZFORTIFY_UNLOCK()

    In  a  multi-threaded  environment,  we need to arbitrate access to the
foritfy  memory  list.   This is what ZFORTIFY_LOCK() and ZFORTIFY_UNLOCK()
are  used  for.   The  calls  to ZFORTIFY_LOCK() and ZFORTIFY_UNLOCK() must
nest.  If no two threads/tasks/processes will be using the same Fortify at
the  same  time,  then  ZFORTIFY_LOCK() and ZFORTIFY_UNLOCK() can safely be
#defined away to nothing.




    RUN TIME CONTROL
    ----------------
    Fortify  can  also  be  controlled  at  run  time  with  a  few special
functions,  which  compile away to nothing if FORTIFY isn't defined, and do
nothing  if  Fortify  has  been  disabled  with  Fortify_Disable().   These
functions  all  apply  to  ZFortify  as  well (The ZFortify versions have a
ZFortify_ prefix, of course).

    Fortify_Disable()  -  This  function  provides  a  mechanism to disable
Fortify  without  recompiling  all  the sourcecode.  It can only be called,
though,  when  there  is  no  memory on the Fortify list.  (Ideally, at the
start  of  the  program before any memory has been allocated).  If you call
this  function  when  there IS memory on the Fortify list, it will issue an
error, and Fortify will not be disabled.
  
    Fortify_SetOutputFunc(Fortify_OutputFuncPtr Output) - Sets the function
used  to  output  all error and diagnostic messages by Fortify.  The output
function takes a single (const char *) argument, and must be able to handle
newlines.  The function returns the old pointer.
    The  default output func is a printf() to stdout.  Unless you are using
AUTOMATIC_LOG_FILE, where the default is to output to the log file.

    Fortify_SetNewFailRate(int  Percent)  - Fortify will make a new attempt
"fail" this "Percent" of the time, even if the memory IS available.  Useful
to  "stress-test"  an  application.   Returns the old value.  The fail rate
defaults to 0.
  


    DIAGNOSTIC FUNCTIONS
    --------------------
    Fortify also provides some additional diagnostic functions which can be
used  to  track  down  memory  corruption  and memory leaks.  If Fortify is
disabled,  these functions do nothing.  If calling these functions directly
from  a debugger, remember to add the "char *file" and "unsigned long line"
paramters  to  each  of  the  calls.  (The ZFortify versions have a
ZFortify_ prefix, of course).
   
    Fortify_CheckPointer(void *uptr) - Returns true if the uptr points to a
valid piece of Fortify'd memory.  The memory must be on Fortify's list, and
it's  sentinals must be in tact.  If anything is wrong, an error message is
issued (Note - if Fortify is disabled, this function always returns true).
  
    Fortify_CheckAllMemory() - Checks the sentinals of all malloc'd memory.
Returns  the  number  of blocks that failed.  (If Fortify is disabled, this
function always returns 0).
  
    Fortify_OutputAllMemory()  -  Outputs  the  entire  list  of  currently
allocated  memory.   For  each  block  is  output  it's  Address, Size, the
SourceFile and Line that allocated it, and the fortify scope from within it
was  allocated.   If  there is no memory on the list, this function outputs
nothing.   It  returns the number of blocks on the list, unless Fortify has
been disabled, in which case it always returns 0.

    Fortify_DumpAllMemory(scope)   -   Just  like  Fortify_OutputAllMemory,
except  all memory inside the given scope is output, and a hex dump of each
block is included in the output.

    Fortify_EnterScope()  -  enters  a level of fortify scope.  Returns the
new scope level.

    Fortify_LeaveScope()  - leaves a level of fortify scope, it also prints
a  dump  of  all memory allocated within the scope being left.  This can be
very  useful  in tracking down memory leaks in a part of a program.  If you
place  a  EnterScope/LeaveScope  pair around a set of functions that should
have  no memory allocated when it's done, Fortify will let you know if this
isn't the case.


    PROBLEMS WITH THE new AND delete MACROS
    ---------------------------------------
    Due  to  limitations  of  the  preprocessor,  getting caller sourcecode
information  isn't as easy as it is for malloc() and free().  The macro for
"new" which adds this information onto the new call causes syntax errors if
you  try  to  declare  a  custom new operator.  The actual Fortifying works
fine, it's just the macro expansion which causes problems.
    If  this  happens, you will need to place #undef's and #define's around
the   offending   code   (sorry).   Alternatively,  you  can  not  #include
"zfortify.hpp"  for  the  offending  file.   But  remember that none of the
allocation done in that file will have sourcecode information.

eg.
#undef new 
void *X::operator new(size_t) { return malloc(size_t); }
#define new Fortify_New


    Due  to a limitation with delete, Fortify has limited information about
where  delete  is  being called called from, and so the the line and source
information will often say "delete.0".  If a delete is occuring from within
another  delete,  Fortify will always endeavour to report the highest level
delete as the caller.

    It  should  be  possible to replace the "new.0" and "delete.0" with the
return  address  of the function, which would be useful when in a debugger,
but  this  would  be  highly  architecture dependant, so I leave that as an
exercise for the students :-).



    WHEN TO USE FORTIFY
    -------------------
    The  simple  answer  to  this  is  "All The Time".  You should never be
without  Fortify  when you're actually developing software.  It will detect
your  bugs _as_you_write_them_, which makes them a lot easier to find.  One
programmer  who  recently  started using Fortify when he had a very strange
memory  problem,  spent  at  least 3 or 4 days tracking down _other_ memory
corruption  bugs that he wasn't even aware of before the program would stay
up  long enough to get to his original problem.  If he'd been using Fortify
from the beginning, this wouldn't have been a problem.
    Leave  fortify  enabled  until  the  final  test  and  release  of your
software.   You  probably  won't  want  some of the slower options, such as
CHECK_ALL_MEMORY_ON_FREE,  and  PARANOID_FREE.  With the exception of those
options,  Fortify doesn't have a great deal of overhead.  If posing a great
problem,  this  overhead can be greatly reduced by cutting down on the size
of  the  fortifications, and turning off the pre/post fills, but each thing
you  turn  off gives fortify less information to work with in tracking your
bugs.

