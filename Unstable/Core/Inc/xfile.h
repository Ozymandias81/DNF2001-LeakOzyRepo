/******************************************************************************
 XFILE 1.0 - Virtualized eXtended FILEsystem driver system. (Width: 79 Tab: 4)
*******************************************************************************
ToDo:
- Document core functionality and driver structure and implementation here.
- Add additional formats.
******************************************************************************/

#ifndef __XFILE_H__                           /* Extended file system header */
#define __XFILE_H__                    /* Make sure we don't come here again */

#include <stdio.h>                    /* Needed for portable file operations */

#ifdef __cplusplus							/* If we're compiling under C++. */
extern "C" {				   /* Make sure C++ treats these as C functions. */
#endif

struct XFILE_Archive;                /* Forward declaration of XFILE_Archive */

/******************************************************************************
                     XFILE Memory Allocation Subsystem:
******************************************************************************/
extern void *(*xfallocvector)(size_t bytes);       /* User memory allocator. */
extern void (*xffreevector)(void *buffer);       /* User memory deallocator. */

#define xfalloc(SIZE)  (xfallocvector?(*xfallocvector)((SIZE)):malloc((SIZE)))
#define xffree(BUFFER) (xffreevector?(*xffreevector)((BUFFER)):free((BUFFER)))

/******************************************************************************
                          XFILE Error Handler:
******************************************************************************/
extern  void (*xferrorvector)(char *message); /* Function to call, NULL uses default */
extern  void xfdefaultErrorHandler(char *message);  /* Default error handler */
#define xferror(MESSAGE) (xferrorvector?xferrorvector(MESSAGE):xfdefaultErrorHandler(MESSAGE))

/******************************************************************************
                        XFILE Handle definition:
******************************************************************************/
#define XFILE_HandleMagic 'XHan'   /* Used to tell an XFILE handle from dirt */
typedef struct XFILE                               /* File handle definition */
{
    unsigned long magic;                         /* Set to XFILE_HandleMagic */
    struct XFILE_Archive *archive; /* If inArchive is NULL, the the following handle is valid */
    void *driverData;                                /* Driver specific data */
} XFILE;

XFILE *xfallochandle(struct XFILE_Archive *archive); /* Allocates XFILE handle */
void   xffreehandle(XFILE *handle);                 /* Frees an XFILE handle */
#define xfvalidate(handle)   /* validates XFILE handle and errs out on fail */\
    (((handle)->magic!=XFILE_HandleMagic)?(xferror("Invalid handle!")),1:0)

/******************************************************************************
                                XFILE_FIND:
******************************************************************************/
#define XFILE_FindMagic 'XFnd'/* Used to tell an XFILE_FIND handle from dirt */
typedef struct XFILE_FIND
{
    unsigned long magic;                         /* Equal to XFILE_FindMagic */
    struct XFILE_Archive *archive;   /* The archive I'm currently finding in */
    void *driverData;                                /* driver specific data */

    char filespec[128],             /* filespec this handle is searching for */
         filename[128];                            /* Current found filename */
} XFILE_FIND;

XFILE_FIND *xfallocfinddata(char *filespec);
void        xffreefindhandle(XFILE_FIND *handle);

/******************************************************************************
                        XFILE Driver structure
******************************************************************************/
#define XFILE_DriverMagic 'XDrv'
typedef struct XFILE_Driver
{
    unsigned long magic;     /* Set to XFILE_DriverMagic to ensure freshness */
    char extension[4]; /* Filesystem extension this driver handles (zip\0, pak\0, etc) */

    int (*xfmount)(struct XFILE_Archive *archive);
    int (*xfunmount)(struct XFILE_Archive *archive);

    XFILE *(*xfopen)( struct XFILE_Archive *archive, const char *filename, const char *mode );
    int    (*xfclose)( XFILE *stream );

    size_t (*xfread)( void *buffer, size_t size, size_t count, XFILE *stream );
    size_t (*xfwrite)( const void *buffer, size_t size, size_t count, XFILE *stream );

    int    (*xfseek)( XFILE *stream, long offset, int origin );
    long   (*xftell)( XFILE *stream );

    XFILE_FIND *(*xffindfile)(struct XFILE_Archive *archive, char *filespec, XFILE_FIND *found);

    struct XFILE_Driver *next, *prev;
} XFILE_Driver;

/* register driver for given file extension, 'driver' must be statically allocated: */
int xfadddriver(XFILE_Driver *driver);

/* register a driver for a given file extension: */
int xfremovedriver(char *extension);

/* Locates a driver based on the extension it supports: */
XFILE_Driver *xffindDriver(char *extension);

/******************************************************************************
                XFILE archive manipulation functions:
******************************************************************************/
#define XFILE_ArchiveMagic 'XArc'                /* Magicical archive number */
typedef struct XFILE_Archive
{
    unsigned long magic;                      /* Equal to XFILE_ArchiveMagic */
    char *name;                        /* NUL terminated name of the archive */

    XFILE_Driver *driver;          /* The filesystem driver for this archive */
    void         *driverData;       /* Driver specific data for this archive */
    XFILE        *handle;                      /* The handle to this archive */
    struct XFILE_Archive *prev, *next;         /* Next archives in the stack */
} XFILE_Archive;

int xfmount(char *archive);  /* Mount the given archive filesystem */
int xfunmount(char *archive);  /* Dismount the given archive filesystem */
XFILE_Archive *xfismounted(char *archive);  /* Returns archive handle if archive is mounted */

/******************************************************************************
                    XFILE file manipulation functions:
******************************************************************************/
#define xfCall(NAME,ARGS,STREAM) (((STREAM)->archive->driver->NAME)?((STREAM)->archive->driver->NAME ARGS):0)
 XFILE *xfopen( const char *filename, const char *mode );

#define xfclose(stream)                   xfCall(xfclose,(stream),(stream))
#define xfread(buffer,size,count,stream)  xfCall(xfread,((buffer),(size),(count),(stream)),(stream))
#define xfwrite(buffer,size,count,stream) xfCall(xfwrite,((buffer),(size),(count),(stream)),(stream))

#define XSEEK_CUR SEEK_CUR                     /* Seek from current position */
#define XSEEK_END SEEK_END                                  /* Seek from EOF */
#define XSEEK_SET SEEK_SET                    /* Seek from beginning of file */

#define xfseek(stream,offset,origin) xfCall(xfseek,((stream),(offset),(origin)),(stream))
#define xftell(stream)               xfCall(xftell,((stream)),(stream))

XFILE_FIND *xffindfile(char *filespec, XFILE_FIND *found);

/* Convenient utility functions that don't directly interact with the driver */

/* void *xfload(char *filename, void *buffer, size_t *length)
   Block loads *length bytes of the given filename into the given buffer, and returns size read in length.
   if ( *length == 0 ) or ( length == NULL ) then the entire file is loaded.
   if ( buffer == NULL ) then a buffer is allocated for the size read and a pointer to it returned

   xfload returns the pointer to the buffer that the file was read into on success or NULL on failure.
   on success, *length is set to the size read if not NULL

   examples:
   {
		size_t length=0;
		void *fileBuffer;

		fileBuffer=xfload("fun.key",	// Filename to load, this is my favorite file.
						  NULL,			// Tell it to allocate the buffer.
						  &length);		// Where to store the size, length=0 intially, so read the whole file.
  }
*/
void  *xfload(char *filename, void *buffer, size_t *length);
size_t xfsave(char *filename, void *buffer, size_t  length);
long   xfsize(XFILE *handle);   /* Returns the size of the given file handle */

/* xfcompare compares the files passed to it, and returns 1 if they contain the same data,
   and zero if not.  VERY inefficiently implemented at the moment.
*/
int    xfcompare(char *filename1, char *filename2);
void   xfdelete(char *filename);	/* Deletes the file matching filename. */

/******************************************************************************
                   XFILE virtual filesystem driver functions:
*******************************************************************************
	VFS is basically a 'driver driver' meant to simplify creation of drivers 
for simpler formats.  (Formats in which all data is linearly stored at a given
offset, ex. PAK) To write a driver for a particular archive format to VFS, all 
you have to do is write the 'mount' function and pass it, along with the archive 
extension it supports, to the VFS_BuildDriver function.  All the mount function 
has to do is pass the names of all the files contained in the archive, with 
their corresponding offsets and lengths to the VFS_AddEntryToArchive function 
and VFS handles the rest.
******************************************************************************/
typedef struct VFSDirectoryEntry
{
    char *filename;                                      /* File name + path */
    long offsetStart,                                     /* Starting offset */
		 length;                                 /* File's length from start */

    struct VFSDirectoryEntry *less, *greater;  /* Other entries on the btree */

} VFSDirectoryEntry;

VFSDirectoryEntry **VFS_FindDirectoryEntry(XFILE_Archive *archive, char *filename);

void VFS_AddEntryToArchive(XFILE_Archive *archive,
                           char *filename,
                           unsigned long offsetStart, unsigned long length);

void VFS_FreeDirectory(VFSDirectoryEntry *directoryTree);
void VFS_DumpDirectory(VFSDirectoryEntry *directoryTree);

typedef struct VFSHandle							   /* A VFS file handle. */
{
    VFSDirectoryEntry *inFile;                 /* The file this handle is in */
    long               offset;         /* The current offset within the file */
    unsigned int       canRead  : 1, /* If this handle is opened for reading */
                       canWrite : 1, /* If this handle is opened for writing */
                       isBinary : 1;   /* If this is a text or binary handle */
} VFSHandle;

/* VFS_BuildDriver constructs and returns a pointer to a VFS based XFILE driver.
   Pass the extension the driver is to handle, and the registration function
   that builds the VFS tree, and a valid driver will be returned (or NULL)
*/
XFILE_Driver *VFS_BuildDriver(char extension[4],
                              int (*VFS_xfmount)(struct XFILE_Archive *));

/******************************************************************************
                            XFILE misc functions:
******************************************************************************/
char *xfextension(char *filename);  /* returns a statically allocated buffer
                                       holding the extension of the given
                                       filename */

/* xstricmp(pattern,string)
   attempts to match string 'str' to pattern 'pat' where
   pattern can include DOS style wildcard characters such as '?' and '*'.
   The match is case insensitive.

   Example: "te?t"   will match "test", "text", "teft", "telt", etc.
			"bla*"   will match "blah", "blargo", etc.
			"this.*" will match "this.txt", "this.zip", etc.
*/
int xstricmp(const char *pat, const char *str);

/******************************************************************************
                       Various VFS filesystem Drivers:
******************************************************************************/
int LZH_xfmount(struct XFILE_Archive *archive);     /* LZH Filesystem driver */
int PAK_xfmount(struct XFILE_Archive *archive);     /* PAK Filesystem driver */
int ZIP_xfmount(struct XFILE_Archive *archive);     /* ZIP Filesystem driver */
//int ARJ_xfmount(struct XFILE_Archive *archive);   /* ARJ Filesystem driver */

/******************************************************************************
                     XFILE initialization and shutdown:
******************************************************************************/
void xfinit(char *baseDir); /* Initializes XFILE and registers above filesystems */
void xfshutdown(); /* Shuts down XFILE  */

#ifdef __cplusplus							/* If we're compiling under C++. */
};
#endif

#endif
