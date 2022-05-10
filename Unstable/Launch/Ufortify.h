/*
 * FILE:
 *   ufortify.h
 *
 * DESCRIPTION:
 *   User options for fortify. Changes to this file require fortify.c to be
 * recompiled, but nothing else.
 */

#define FORTIFY_STORAGE

#define FORTIFY_BEFORE_SIZE      16  /* Bytes to allocate before block */
#define FORTIFY_BEFORE_VALUE   0xA3  /* Fill value before block        */
                      
#define FORTIFY_AFTER_SIZE       16  /* Bytes to allocate after block  */
#define FORTIFY_AFTER_VALUE    0xA5  /* Fill value after block         */

#define FILL_ON_MALLOC               /* Nuke out malloc'd memory       */
#define FILL_ON_MALLOC_VALUE   0xA7  /* Value to initialize with       */

#define FILL_ON_FREE                 /* free'd memory is cleared       */
#define FILL_ON_FREE_VALUE     0xA9  /* Value to de-initialize with    */

#define CHECK_ALL_MEMORY_ON_MALLOC  
#define CHECK_ALL_MEMORY_ON_FREE   
#define PARANOID_FREE              

#define WARN_ON_MALLOC_FAIL    /* A debug is issued on a failed malloc */
//#define WARN_ON_ZERO_MALLOC    /* A debug is issued on a malloc(0)     */
#define WARN_ON_FALSE_FAIL     /* See Fortify_SetMallocFailRate        */
#define WARN_ON_SIZE_T_OVERFLOW/* Watch for breaking the 64K limit in  */
                               /* some braindead architectures...      */

#define FORTIFY_LOCK()   
#define FORTIFY_UNLOCK()  
