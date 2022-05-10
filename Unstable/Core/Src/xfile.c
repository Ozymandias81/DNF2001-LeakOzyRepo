#include <io.h>
#include <memory.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <process.h>

#include "xfile.h"

#pragma warning (disable : 4706)  /* assignment within conditional expression. */
#pragma warning (disable : 4711)  /* function '' selected for automatic inline expansion. */
#pragma warning (disable : 4701)  /* local variable '' may be used without having been initialized. */

/******************************************************************************
                     XFILE Memory Allocation Subsystem:
******************************************************************************/
void *(*xfallocvector)(size_t bytes)=NULL;
void (*xffreevector)(void *buffer)  =NULL;

/******************************************************************************
                          XFILE Error Handler:
******************************************************************************/
void (*xferrorvector)(char *message)=NULL;

void xfdefaultErrorHandler(char *message)
{
    puts(message);                              /* Display the error message */
    exit(EXIT_FAILURE);                                              /* Flee */
}

/******************************************************************************
                  XFILE Base Handle Allocation and Management:
******************************************************************************/
XFILE *xfallochandle(struct XFILE_Archive *archive) /* Allocates XFILE handle */
{
    XFILE *handle;

    if(!(handle=(XFILE *)xfalloc(sizeof(*handle))))   /* allocate the handle */
        xferror("Failed to allocate handle.");                    /* Failure */

    memset(handle,0,sizeof(*handle));                        /* Clear it out */
    handle->magic=XFILE_HandleMagic;                        /* Set the magic */
    handle->archive=archive;
    return handle;                                       /* Back to the user */
}

void xffreehandle(XFILE *handle)                    /* Frees an XFILE handle */
{
    xfvalidate(handle);                               /* Validate the handle */
    handle->magic=0;                                    /* Obliterate handle */
    xffree(handle);                        /* Release the handle to the void */
}

/******************************************************************************
                                XFILE_FIND:
******************************************************************************/
XFILE_FIND *xfallocfinddata(char *filespec)
{
    XFILE_FIND *handle;

    if(!(handle=(XFILE_FIND *)xfalloc(sizeof(*handle))))  /* allocate handle */
        xferror("Failed to allocate handle");                     /* Failure */

    memset(handle,0,sizeof(*handle));                        /* Clear it out */
    handle->magic=XFILE_FindMagic;                          /* Set the magic */

    strcpy(handle->filespec,filespec);               /* Copy in the filespec */
    return handle;                                       /* Back to the user */
}

void xffreefindhandle(XFILE_FIND *handle)
{
	if(!handle) xferror("Invalid handle.");
    handle->magic=0;
    xffree(handle);
}

/******************************************************************************
                       Stdio Filesystem Driver:
******************************************************************************/
extern XFILE_Archive XFILE_StdioArchive;

static XFILE *stdio_xfopen(struct XFILE_Archive *archive,const char *filename,const char *mode)
{
    FILE *handle;                                    /* Standard file handle */
    XFILE *returnHandle;

    /* Attempt to open the given file: */
    if(!(handle=fopen(filename,mode)))
        return NULL;                                 /* Failure, return NULL */

    returnHandle=xfallochandle(archive);                /* Allocate a handle */
    returnHandle->driverData=(void *)handle;               /* Set the handle */

    return returnHandle;
}

static int stdio_xfclose( XFILE *stream )
{
    int returnValue;

    returnValue=fclose((FILE *)stream->driverData);                /* close  */
    xffreehandle(stream);                              /* Release the handle */
    return returnValue;                        /* The return value of fclose */
}

static size_t stdio_xfread( void *buffer, size_t size, size_t count, XFILE *stream )
{
    return fread(buffer,size,count,(FILE *)stream->driverData);
}

static size_t stdio_xfwrite( const void *buffer, size_t size, size_t count, XFILE *stream )
{
    return fwrite(buffer,size,count,(FILE *)stream->driverData);
}

static int stdio_xfseek( XFILE *stream, long offset, int origin )
{
    return fseek((FILE *)stream->driverData,offset,origin);
}

static long stdio_xftell( XFILE *stream )
{
    return ftell((FILE *)stream->driverData);
}

static XFILE_FIND *stdio_xffindfile(XFILE_Archive *archive, char *filespec, XFILE_FIND *found)
{
    struct _finddata_t fileinfo;

    if(!found)                                /* Is this a findfirst request */
    {
        long result;

        if((result=_findfirst(filespec, &fileinfo ))==-1)
            return NULL;                    /* Failed to find the first file */

        found=xfallocfinddata(filespec);              /* alloc a find handle */
        found->archive=archive;                        /* Set up the archive */
        found->driverData=(void *)result;                 /* Save the handle */
    } else                                                /* Try a findnext  */
    {
        /* Attempt to find the next file in line */
        if(_findnext((long)found->driverData,&fileinfo)==-1)
        {
            _findclose((long)found->driverData);    /* Close the find handle */
            xffreefindhandle(found);        /* Failed, toast the find handle */
            return NULL;
        }
    }

    /* Copy the filename over */
    strcpy(found->filename,fileinfo.name);

    /* If this file is one of the ones we don't care about "." or "..",
       try to get another one */
    if((!strcmpi(found->filename,".."))
     ||(!strcmpi(found->filename,".")))
        return stdio_xffindfile(archive,filespec,found);

    return found;
}

static XFILE_Driver XFILE_StdioDriver =
{
    XFILE_DriverMagic,
    "   ",

    NULL,                             /* No need for a registration function */
    NULL,                           /* No need for a deregistration function */

    stdio_xfopen,
    stdio_xfclose,

    stdio_xfread,
    stdio_xfwrite,

    stdio_xfseek,
    stdio_xftell,

    stdio_xffindfile,

    NULL, NULL                                        /* Empty list pointers */
};

XFILE_Archive XFILE_StdioArchive =             /* The standard stdio archive */
{
    XFILE_ArchiveMagic,                                           /* Magical */
    "",                                                /* Not a real archive */

    &XFILE_StdioDriver,									   /* Driver to use. */
    NULL,
    NULL,

    NULL,NULL
};

/******************************************************************************
                         XFILE driver management:
******************************************************************************/
static XFILE_Driver *registeredDrivers=&XFILE_StdioDriver; /* List of currently registered drivers */

int xfadddriver(XFILE_Driver *driver) /* register a driver for a given file extension */
{
    xfremovedriver(driver->extension); /* make sure I don't already have this driver registered */

    driver->prev=NULL;                  /* Going to put self at head of list */
    driver->next=registeredDrivers;         /* Rest of list is previous list */

    if(registeredDrivers)               /* If there was a previous list head */
        registeredDrivers->prev=driver;  /* Point his previous pointer to me */

    registeredDrivers=driver;   /* and set myself up as the head of the list */

    return 1;                                                     /* success */
}

int xfremovedriver(char *extension)   /* register driver for given extension */
{
    XFILE_Driver *driver;

    if(driver=xffindDriver(extension))       /* Attempt to locate the driver */
    {
        if(driver->prev) driver->prev->next=driver->next; /* Update previous */
        if(driver->next) driver->next->prev=driver->prev;     /* Update next */

        /* If I'm the head of the list, bump it down one (or off) */
        if(registeredDrivers==driver)
            registeredDrivers=driver->next;

        return 1;							 /* Driver successfully removed. */
    }

    return 0;
}

XFILE_Driver *xffindDriver(char *extension)
{
    XFILE_Driver *iterator;

    if(!extension) return NULL;                   /* validate my input param */

    for(iterator=registeredDrivers;iterator;iterator=iterator->next)  /* run through all registered drivers */
        if(!strcmpi(iterator->extension,extension)) /* does this extension match? */
            break;                                        /* look no further */

    return iterator;                          /* return found driver or NULL */
}

/******************************************************************************
                XFILE archive stack manipulation functions:
******************************************************************************/
static XFILE_Archive *archiveStack=&XFILE_StdioArchive;  /* Current stack of archives */

int xfmount(char *archive)
{
    XFILE_Archive *newArchive;

    if(!archive) return 0;                     /* ensure archive is non null */

    /* Allocate space for the new archive header */
    if(!(newArchive=(XFILE_Archive *)xfalloc(sizeof(XFILE_Archive))))
        return 0;

    memset(newArchive,0,sizeof(*newArchive));                /* Clear it out */

    newArchive->magic=XFILE_ArchiveMagic;         /* Set up the magic number */
    if(!(newArchive->name=strdup(archive)))   /* copy the archive's filename */
    {
        xffree(newArchive);                            /* FAILURE!, cleanup  */
        return 0;
    }

    /* Try to get a handle for this archive */
    if(!(newArchive->handle=xfopen(archive,"rb+")))
    {
        xffree(newArchive->name);              /* Couldn't find it, clean up */
        xffree(newArchive);
        return 0;                                                 /* Failure */
    }

    /* try to find the driver for this archive */
    if(!(newArchive->driver=xffindDriver(xfextension(archive))))
    {
        xffree(newArchive->name);              /* Couldn't find it, clean up */
        xffree(newArchive);                       /* Free the archive handle */
        return 0;                                                 /* Failure */
    }

    if(newArchive->driver->xfmount)    /* Do I have a registration function? */
        if(!(newArchive->driver->xfmount(newArchive)))             /* Try it */
        {
            xffree(newArchive->name);          /* Couldn't find it, clean up */
            xffree(newArchive);                   /* Free the archive handle */
            return 0;                                             /* Failure */
        }

    /* Hook myself up to the list */
    newArchive->prev=NULL;             /* attaching at head of list, no prev */
    newArchive->next=archiveStack;                /* Attach to archive stack */

    if(archiveStack)                    /* If there was a previous list head */
        archiveStack->prev=newArchive;   /* Point his previous pointer to me */

    archiveStack=newArchive;    /* and set myself up as the head of the list */

    return 1;
}

int xfunmount(char *archive)
{
    XFILE_Archive *iterator;

    if(!archive) return 0;                     /* ensure archive is non null */

    for(iterator=archiveStack;iterator;iterator=iterator->next)  /* Search for archive */
        if(!strcmpi(iterator->name,archive))                  /* Is this it? */
        {
            if(iterator->driver->xfunmount) /* Do I have deregistration function? */
                iterator->driver->xfunmount(iterator);            /* Call it */

            xfclose(iterator->handle);           /* Close the archive handle */

            /* Found the archive, detach it from the list */
            if(iterator->next) iterator->next->prev=iterator->prev;
            if(iterator->prev) iterator->prev->next=iterator->next;
            if(iterator==archiveStack)         /* Am I the head of the list? */
            {
                archiveStack=iterator->next;        /* Point to my successor */
                if(iterator->next) iterator->prev=NULL;     /* And remove me */
            }

            iterator->magic=0;                   /* Obliterate archive magic */
            xffree(iterator->name);                 /* Free the archive's name */
            xffree(iterator);               /* free the archive's memory block */
            return 1;
        }

    return 0;
}

XFILE_Archive *xfismounted(char *archive)  /* Returns archive handle if archive is mounted */
{
    XFILE_Archive *iterator;

    for(iterator=archiveStack;iterator;iterator=iterator->next) /* Search for archive */
        if(!strcmpi(iterator->name,archive))                    /* Is this it? */
            return iterator;                                    /* Return the found archive */

    return NULL;
}

/******************************************************************************
                    XFILE file manipulation functions:
******************************************************************************/
XFILE *xfopen( const char *filename, const char *mode )
{
    XFILE_Archive *iterator;
    XFILE *handle;

    if(!filename||!mode) return NULL;                 /* Validate parameters */

    /* Traverse the archive stack, attempting fopen() at each layer. */
    for(iterator=archiveStack;iterator;iterator=iterator->next) /* Search for the archive */
        if(iterator->driver->xfopen)        /* Does my driver have an fopen? */
            if(handle=iterator->driver->xfopen(iterator,filename,mode))
                return handle; /* If suceeded in opening file, return handle */

    return NULL;                   /* Couldn't open the file, so return NULL */
}


/* found is a previously found file */
XFILE_FIND *xffindfile(char *filespec, XFILE_FIND *found)
{
    XFILE_Archive *iterator;
    XFILE_FIND *handle;

    /* If a parameter is supplied, try to do a 'findnext' */
    if(found)                 /* Make sure I'm non NULL (NULL == first time) */
        if(found->archive)                 /* If my archive pointer is valid */
            if(found->archive->driver->xffindfile) /* If I have an xffindnextfile function */
                if((handle=found->archive->driver->xffindfile(found->archive,filespec, found)))  /* Did it find another file? */
                    return handle; /* Yep, return it */

    /* Try to find the first applicable archive that returns a file */
    if(!found)
        iterator=archiveStack; /* If found is NULL, start at beginning */
    else
        iterator=found->archive->next;   /* Otherwise, move to next archive */

    handle=NULL;                                           /* Assume failure */

    for(;iterator;iterator=iterator->next) /* scan through remaining archives */
        if((handle=iterator->driver->xffindfile(iterator,filespec,NULL))) /* Does it work with this archive? */
            break;                                      /* return the handle */

    return handle;
}

/* utility functions that don't interact directly with the driver */
void *xfload(char *filename,void *buffer, size_t *length)
{
    XFILE *handle;
    size_t internalLength;

    if(!filename) xferror("No filename passed to xfload!");

    /* attempt to open the file */
    if(!(handle=xfopen(filename,"rb")))
        return NULL;

    internalLength=xfsize(handle);            /* grab the length of the file */

    if(!length)           /* If length isn't specified, set it up internally */
        length=&internalLength;       /* assume big enough to store the file */
    else if(!*length)
        *length=internalLength;

    /* make sure I don't write past the end of the allocated buffer */
    if(internalLength>=*length) internalLength=*length;

    if(!buffer)                               /* If the buffer doesn't exist */
        if(!(buffer=xfalloc(*length)))                         /* Allocate it */
            xferror("Failed to allocate buffer for xfload!");

    xfread(buffer,*length,1,handle);                          /* Do the read */
    xfclose(handle);                                       /* close the file */

    return buffer;
}

size_t xfsave(char *filename, void *buffer, size_t length)
{
    XFILE *handle;

    /* attempt to open the file */
    if(!(handle=xfopen(filename,"wb+")))
        return 0;

    length=xfwrite(buffer,length,1,handle);               /* Write the file  */
    xfclose(handle);                                       /* close the file */

    return length;
}

long xfsize(XFILE *handle)      /* Returns the size of the given file handle */
{
    long originalPosition, length;

    originalPosition=xftell(handle);           /* snag the original position */
    xfseek(handle,0,XSEEK_END);               /* Seek to the end of the file */
    length=xftell(handle);                     /* get the length of the file */
    xfseek(handle,originalPosition,XSEEK_SET); /* Seek back to original position */

    return length;
}

int xfcompare(char *filename1, char *filename2)
{
    XFILE *file1=NULL, *file2=NULL;
    unsigned char file1Data=0, file2Data=0;
    long size;
    int result=1;                                          /* Assume success */

    file1=xfopen(filename1,"rb");
    file2=xfopen(filename2,"rb");

    size=xfsize(file1);
    if(size!=xfsize(file2))
        result=0;

    for(;size&&result;size--)
    {
        xfread(&file1Data,1,1,file1);
        xfread(&file2Data,1,1,file2);

        if(file1Data!=file2Data) result=0;
    }

    xfclose(file1);
    xfclose(file2);

    return result;
}

void xfdelete(char *filename)
{
    remove(filename);
}


/******************************************************************************
                   XFILE virtual filesystem driver functions:
******************************************************************************/
/* Parse through the binary tree of directory entries to find the entry for the given filename */
VFSDirectoryEntry **VFS_FindDirectoryEntry(XFILE_Archive *archive, char *filename)
{
    VFSDirectoryEntry **iterator=(VFSDirectoryEntry **)&archive->driverData;
    if(!archive) xferror("Invalid archive pointer.");

    while(*iterator!=NULL)
    {
        int compareResult;

        /* compare filename at the current node to the one I'm looking for */
        compareResult=strcmpi((*iterator)->filename,filename);
        if(compareResult==0) break;               /* It's the same, found it */
        if(compareResult>0) iterator=&((*iterator)->less);
        if(compareResult<0) iterator=&((*iterator)->greater);
    }

    return iterator;
}

void VFS_AddEntryToArchive(XFILE_Archive *archive,
                           char *filename,
                           unsigned long offsetStart, unsigned long length)
{
    VFSDirectoryEntry **entryPointer;
    if(!archive) xferror("Invalid archive pointer.");


    entryPointer=VFS_FindDirectoryEntry(archive,filename);
    if(*entryPointer) return;                     /* An entry already exists */

    *entryPointer=(VFSDirectoryEntry *)xfalloc(sizeof(**entryPointer));
    memset(*entryPointer,0,sizeof(**entryPointer));
    (*entryPointer)->filename=strdup(filename);
    (*entryPointer)->offsetStart=offsetStart;
    (*entryPointer)->length=length;
}

void VFS_FreeDirectory(VFSDirectoryEntry *directoryTree)
{
    if(!directoryTree) return;

    /* Free my children first */
    VFS_FreeDirectory(directoryTree->less);
    VFS_FreeDirectory(directoryTree->greater);

    xffree(directoryTree->filename);                     /* Kill my filename */
    xffree(directoryTree);                                    /* Kill myself */
}


/* Display the directory hierarchy indicated by directoryTree */
void VFS_DumpDirectory(VFSDirectoryEntry *directoryTree)
{
    if(!directoryTree) return;
    VFS_DumpDirectory(directoryTree->less);
    printf("filename:%s offsetStart:%i length:%i\n",directoryTree->filename,directoryTree->offsetStart,directoryTree->length);
    VFS_DumpDirectory(directoryTree->greater);
}

static int VFSnextIsFilename=0;
static VFSDirectoryEntry *VFS_FindNextRecurse(VFSDirectoryEntry *current,char *filespec, char *filename)
{
    VFSDirectoryEntry *temp;
    if(!current) return NULL;

    if(!filename)                       /* Next is always filename */
    {
        if(temp=VFS_FindNextRecurse(current->less,filespec,filename))
            return temp;

        if(xstricmp(filespec,current->filename))  /* If matches spec, return */
            return current;

        return VFS_FindNextRecurse(current->greater,filespec,filename);
    }

    /* If the next node is the filename we're looking for, and I'm the next
       node, then I must be it.
    */
    if(VFSnextIsFilename)
        if(xstricmp(filespec,current->filename))  /* If matches spec, return */
            return current;

    if(temp=VFS_FindNextRecurse(current->less,filespec,filename))
        return temp;        /* If any non-null values showed up, return them */

    /* Is this the file I'm looking for? (filename) */
    if(!strcmpi(current->filename,filename))
        VFSnextIsFilename=1;

    return VFS_FindNextRecurse(current->greater,filespec,filename);
}

static char *VFS_FindNext(XFILE_Archive *archive, char *filespec, char *filename)
{
    VFSDirectoryEntry *entry;
    VFSnextIsFilename=!filename; /* reset file found flag (if !filename, then grab first file) */
    entry=VFS_FindNextRecurse((VFSDirectoryEntry *)archive->driverData,filespec,filename);

    if(!entry) return NULL;
    return entry->filename;
}

/* VFS_SeekToHandle positions the physical file pointer appropriately for the
   given handle.
*/
static void VFS_SeekToHandle(XFILE *stream)
{
    VFSHandle *handle = (VFSHandle *)stream->driverData;

    /* Seek to my current position in my parent's archive */
    xfseek(stream->archive->handle,
           handle->inFile->offsetStart+handle->offset,
           XSEEK_SET);
}

static int VFS_xfunmount(struct XFILE_Archive *archive)
{
    VFS_FreeDirectory((VFSDirectoryEntry *)archive->driverData);
    return 1;
}

static XFILE *VFS_xfopen( struct XFILE_Archive *archive, const char *filename, const char *mode )
{
    XFILE *handle;
    VFSHandle *internalHandle;
    VFSDirectoryEntry **fileEntry;

    fileEntry=VFS_FindDirectoryEntry(archive, (char *)filename);/* Look for the file */
    if(!*fileEntry) return NULL;      /* If I didn't find it, get outta here */

    handle=xfallochandle(archive);             /* Allocate a standard handle */

    /* Allocate space for the internal handle */
    handle->driverData=xfalloc(sizeof(*internalHandle));
	internalHandle=(VFSHandle *)handle->driverData;

    /* Make sure the pointer is valid */
    if(!internalHandle)
        xferror("Failed to allocate internal handle!");

    memset(internalHandle,0,sizeof(*internalHandle));        /* Clear it out */

    internalHandle->inFile=*fileEntry;     /* Set the file I'm indexing into */

    /* Set the read/write bits from the mode */
    if(strchr(mode,'r')||strchr(mode,'R')) internalHandle->canRead=1;
    if(strchr(mode,'w')||strchr(mode,'W')) internalHandle->canWrite=1;
    if(strchr(mode,'b')||strchr(mode,'B')) internalHandle->isBinary=1;

    return handle;                                      /* return the sucker */
}

static int VFS_xfclose( XFILE *stream )
{
    xffree(stream->driverData);                       /* Free my internal data */
    xffreehandle(stream);                        /* Dump the handle normally */
    return 0;                                  /* The return value of fclose */
}

static size_t VFS_xfread( void *buffer, size_t size, size_t count, XFILE *stream )
{
    VFSHandle *handle = (VFSHandle *)stream->driverData;
    size_t totalReadSize;

    totalReadSize=size*count;                     /* compute total read size */

    /* Clamp if I'm reading over: */
    if(totalReadSize>(size_t)handle->inFile->length-handle->offset)
        totalReadSize=(size_t)handle->inFile->length-handle->offset;

    /* Make sure we're actually reading something */
    if(totalReadSize<=0) return 0;

    /* Seek to my current position in my owning archive */
    VFS_SeekToHandle(stream);

    /* Perform the read */
    xfread(buffer,totalReadSize,1,stream->archive->handle);

    /* Update my current offset */
    handle->offset+=totalReadSize;

    /* Return total amount read */
    return totalReadSize;
}

static size_t VFS_xfwrite( const void *buffer, size_t size, size_t count, XFILE *stream )
{
    VFSHandle *handle = (VFSHandle *)stream->driverData;
    size_t totalWriteSize;

    totalWriteSize=size*count;                     /* compute total read size */

    /* Clamp if I'm writing over: (only for the vfs filesystem) */
    if(totalWriteSize>(size_t)handle->inFile->length-handle->offset)
        totalWriteSize=handle->inFile->length-handle->offset;

    /* Make sure we're actually reading something */
    if(totalWriteSize<=0) return 0;

    /* Seek to my current position in my owning archive */
    VFS_SeekToHandle(stream);

    /* Perform the read */
    xfwrite(buffer,totalWriteSize,1,stream->archive->handle);

    /* Update my current offset */
    handle->offset+=totalWriteSize;

    /* Return total amount read */
    return totalWriteSize;

}

static int VFS_xfseek( XFILE *stream, long offset, int origin )
{
    VFSHandle *handle = (VFSHandle *)stream->driverData;

    switch(origin)
    {
        case XSEEK_SET: handle->offset=offset;  break;
        case XSEEK_CUR: handle->offset+=offset; break;
        case XSEEK_END: handle->offset=(handle->inFile)->length-offset; break;
        default:        xferror("unknown seek type!"); break;
    }

    /* Clip the offset */
    if(handle->offset<0) handle->offset=0;                      /* Clamp low */
    else if(handle->offset>=(handle->inFile)->length) handle->offset=(handle->inFile)->length-1;

    return handle->offset;
}

static long VFS_xftell( XFILE *stream )
{
    return ((VFSHandle *)stream->driverData)->offset;
}

static XFILE_FIND *VFS_xffindfile(struct XFILE_Archive *archive, char *filespec, XFILE_FIND *found)
{
    char *filename=NULL;

    /* If I have a filename from a previous search use it */
    if(found) filename=found->filename;

    /* Find the next file in line */
    filename=VFS_FindNext(archive,filespec,filename);

    if(filename)                                  /* If I got a valid result */
    {
        if(!found)                          /* Create a handle if I need one */
        {
            found=xfallocfinddata(filespec);          /* alloc a find handle */
            found->archive=archive;                    /* Set up the archive */
            strcpy(found->filespec,filespec);       /* copy in the filespec  */
        }

        strcpy(found->filename,filename);                  /* Copy in result */

        return found;                           /* Return the updated handle */
    }

    /* I didn't get a valid result */
    if(found) xffreefindhandle(found);    /* Destroy the handle if it exists */
    return NULL;                                               /* Outta here */
}

/* VFS_BuildDriver constructs and returns a pointer to a VFS based XFILE driver.
   Pass the extension the driver is to handle, and the registration function
   that builds the VFS tree, and a valid driver will be returned (or NULL)
*/
XFILE_Driver *VFS_BuildDriver(char extension[4],
                              int (*VFS_xfmount)(struct XFILE_Archive *))
{
    XFILE_Driver *driver;

    /* Validate my parameters */
    if(!VFS_xfmount)
        xferror("VFS_register cannot be NULL!");

    /* allocate space for the driver */
    if(!(driver=(XFILE_Driver *)xfalloc(sizeof(*driver))))
        xferror("failed to allocate memory for driver!");

    memset(driver,0,sizeof(*driver));       /* clear out the allocated space */

    driver->magic=XFILE_DriverMagic;                     /* Set up the magic */
    strcpy(driver->extension,extension);                /* And the extension */

    /* Set up the various driver functions */
    driver->xfmount=VFS_xfmount;
    driver->xfunmount=VFS_xfunmount;

    driver->xfopen=VFS_xfopen;
    driver->xfclose=VFS_xfclose;

    driver->xfread=VFS_xfread;
    driver->xfwrite=VFS_xfwrite;

    driver->xfseek=VFS_xfseek;
    driver->xftell=VFS_xftell;

    driver->xffindfile=VFS_xffindfile;

    return driver;                          /* return the constructed driver */
}

/******************************************************************************
                            XFILE misc functions:
******************************************************************************/
char *xfextension(char *filename) /* returns a statically allocated buffer holding the extension of the given filename */
{
    static char extension[4];
    int index;

    if(!(filename=strchr(filename,'.'))) return NULL;	/* If I didn't find a '.' there's no extension */
    filename++;                                         /* Skip the '.' */

    /* Grab the next three characters of the filename */
    for(index=0;index<3;index++)
    {
        if(*filename) /* If this character is Non null */
        {
            /* Append it to the growing extension */
            extension[index]=*filename; filename++;
        } else
            extension[index]='\0'; /* Otherwise, append a NUL */
    }

    extension[3]='\0';									/* Terminating NUL */

    return extension;
}

/* xstricmp(pattern,string)
   attempts to match string 's' to pattern 'p' where
   pattern can include dos wildcard characters '?' '*'.
   The match is case insensitive.
*/
int xstricmp(const char *p, const char *s)
{
      /* Attempt to match the first character or metacharacter of the pattern: */
      switch(*p)
      {
            case '\0': return !*s;
            case '*' : return xstricmp(p+1,s)||*s&&xstricmp(p,s+1);
            case '?' : return *s&&xstricmp(p+1,s+1);
            default  : return (toupper(*p)==toupper(*s))&&xstricmp(p+1,s+1);
      }
}

/******************************************************************************
                       LZH Filesystem Driver:
******************************************************************************/

#pragma pack (1)                                     /* Force byte alignment */

typedef struct LZHFileHeader
{
    unsigned char headerSize,                /* Size of archived file header */
                  headerChecksum,             /* Checksum of remaining bytes */
                  ID[3],                                   /* '-lh' or '-lz' */
                  compression,          /* Compression methods used 0 = none */
                  dash;                                               /* '-' */
    unsigned long compressedSize,
                  uncompressedSize,
                  dateTime;                       /* Original file date/time */
    unsigned short fileAttributes;
    unsigned char  filenameLength;        /* Filename / path length in bytes */
    unsigned char  filename[1];          /* The start of the actual filename */
} LZHFileHeader;

#pragma pack ()                                             /* Pop alignment */

int LZH_xfmount(struct XFILE_Archive *archive)
{
    unsigned char headerBuffer[512];
    LZHFileHeader *header=(LZHFileHeader *)headerBuffer;
    long currentPosition;

    /* Scan through the .LZH archive: */
    while(xfread(&header->headerSize,1,1,archive->handle))
    {
        if(!header->headerSize) /* Have I come to an invalid directory or the end of the file? */
            break;                                  /* Yep, finished looping */

        /* Read in the rest of the header */
        xfread(headerBuffer+sizeof(header->headerSize),1,header->headerSize,archive->handle);

        /* Make sure this file isn't compressed */
        if(header->compressedSize!=header->uncompressedSize)
            xferror("Only uncompressed .LZH files are supported");

        /* Validate this header */
        if((header->dash!='-')||(header->ID[0]!='-')||(header->ID[1]!='l'))
            xferror("LZH header is invalid.");

        /* Add the filename to the directory: */
        header->filename[header->filenameLength]='\0';
        currentPosition=xftell(archive->handle);
        if(currentPosition%2) currentPosition++;/* Word align the file start */

        VFS_AddEntryToArchive(archive, (char *)header->filename,
                              currentPosition, header->compressedSize+1);

        /* Seek to the next file header */
        xfseek(archive->handle,header->compressedSize+1,SEEK_CUR);
    }

    return 1;
}

/******************************************************************************
                       PAK Filesystem Driver:
******************************************************************************/
#pragma pack (1)                                     /* Force byte alignment */

typedef struct
{
  char magic[4];              /* Equal to "PACK". Name of the new WAD format */
  long diroffset,            /* Position of WAD directory from start of file */
       dirsize;                        /* Number of entries * 0x40 (64 char) */
} pakheader_t;

typedef struct
{
  char filename[0x38];      /* Name of the file, Unix style, with extension, */
                                              /* 50 chars, padded with '\0'. */
  long offset,                         /* Position of the entry in PACK file */
       size;                               /* Size of the entry in PACK file */
} pakentry_t;

#pragma pack ()                                             /* Pop alignment */

int PAK_xfmount(struct XFILE_Archive *archive)      /* The basic .PAK driver */
{
    pakheader_t header;
    pakentry_t  entry;
    int         index;

    /* Scan through the .LZH archive: */
    xfread(&header,sizeof(header),1,archive->handle);     /* Read the header */
    if(strncmp(header.magic,"PACK",4))                /* Validate the header */
        xferror("Invalid .PAK format");           /* Not a valid .PAK header */

    xfseek(archive->handle,header.diroffset,SEEK_SET);  /* Seek to directory */

    for(index=0;index<header.dirsize;index+=sizeof(entry))/* Read each entry */
    {
        /* Read the directory entry */
        xfread(&entry,sizeof(entry),1,archive->handle);

        /* Add it to the VFS file table */
        VFS_AddEntryToArchive(archive, entry.filename,entry.offset,entry.size);
    }

    return 1;
}

/******************************************************************************
                       ZIP Filesystem Driver:
******************************************************************************/
#pragma pack (1)                                     /* Force byte alignment */

typedef struct ZIPLocalFileHeader
{

    unsigned long signature;           /* local file header signature     4 bytes  (0x04034b50) */
    unsigned short extractWithVersion, /* version needed to extract       2 bytes */
                   flags,              /* general purpose bit flag        2 bytes */
                   compression,        /* compression method              2 bytes */
                   time,               /* last mod file time              2 bytes */
                   date;               /* last mod file date              2 bytes */
    unsigned long  crc,                /* crc-32                          4 bytes */
                   compressedSize,     /* compressed size                 4 bytes */
                   uncompressedSize;   /* uncompressed size               4 bytes */
    unsigned short filenameLength,     /* filename length                 2 bytes */
                   extraFieldLength;   /* extra field length              2 bytes */

} ZIPLocalFileHeader;

#define ZIPCentralDirectorySignature 0x02014b50

typedef struct ZIPCentralDirectoryEntry                  /* Zip header entry */
{
    unsigned long signature;           /* central file header signature   4 bytes  (0x02014b50) */
    unsigned short createdByVersion,   /* version made by                 2 bytes */
                   extractWithVersion, /* version needed to extract       2 bytes */
                   flags,              /* general purpose bit flag        2 bytes */
                   compression,        /* compression method              2 bytes */
                   time,               /* last mod file time              2 bytes */
                   date;               /* last mod file date              2 bytes */
    unsigned long  crc,                /* crc-32                          4 bytes */
                   compressedSize,     /* compressed size                 4 bytes */
                   uncompressedSize;   /* uncompressed size               4 bytes */
    unsigned short filenameLength,     /* filename length                 2 bytes */
                   extraFieldLength,   /* extra field length              2 bytes */
                   fileCommentLength,  /* file comment length             2 bytes */
                   diskNumberStart,    /* disk number start               2 bytes */
                   internalAttributes; /* internal file attributes        2 bytes */
    unsigned long  externalAttributes, /* external file attributes        4 bytes */
                   localHeaderOffset;  /* relative offset of local header 4 bytes */

} ZIPCentralDirectoryEntry;

#define ZIPEndOfCentralDirectorySignature 0x06054b50

typedef struct ZIPEndOfCentralDirectory
{
    unsigned long signature;                        /* end of central dir signature    4 bytes  (0x06054b50) */
    unsigned short diskNumber,                      /* number of this disk             2 bytes */
                   centralDirectoryDiskNumber,      /* number of the disk with the start of the central directory  2 bytes */
                   centralDirectoryEntriesThisDisk, /* total number of entries in the central dir on this disk    2 bytes */
                   centralDirectoryEntries;         /* total number of entries in the central dir                 2 bytes */
    unsigned long  centralDirectorySize,            /*size of the central directory   4 bytes */
                   centralDirectoryOffset;          /* offset of start of central directory with respect to the starting disk number 4 bytes */
    unsigned short commentLength;                   /* zipfile comment length          2 bytes */

} ZIPEndOfCentralDirectory;

#pragma pack ()                                             /* Pop alignment */

int ZIP_xfmount(struct XFILE_Archive *archive)      /* The basic .PAK driver */
{
    ZIPEndOfCentralDirectory EndOfCentralDirectory;
    ZIPCentralDirectoryEntry CentralDirectoryEntry;
    int index;
    char filename[256];

    /* Find the central directory: */
    xfseek(archive->handle,-(long)(sizeof(EndOfCentralDirectory)),XSEEK_END);
    xfread(&EndOfCentralDirectory,sizeof(EndOfCentralDirectory),1,archive->handle);

    /* Verify that we've actually got the central directory */
    if(EndOfCentralDirectory.signature!=ZIPEndOfCentralDirectorySignature)
        xferror("Invalid .ZIP format!");

    /* Seek to the start of the central directory: */
    xfseek(archive->handle,EndOfCentralDirectory.centralDirectoryOffset,XSEEK_SET);

    for(index=0;index<EndOfCentralDirectory.centralDirectoryEntries;index++)
    {
        /* Read in a directory entry */
        xfread(&CentralDirectoryEntry,sizeof(CentralDirectoryEntry),1,archive->handle);

        /* Read until we hit the end of the central directory */
        if(CentralDirectoryEntry.signature!=ZIPCentralDirectorySignature)
            break;

        /* Read the filename */
        xfread(filename,1,CentralDirectoryEntry.filenameLength,archive->handle);
        filename[CentralDirectoryEntry.filenameLength]='\0';

        /* Seek past the end of this record */
        xfseek(archive->handle,CentralDirectoryEntry.extraFieldLength+CentralDirectoryEntry.fileCommentLength,XSEEK_CUR);

        /* Add it to the VFS file table */
        VFS_AddEntryToArchive(archive, filename,
                              CentralDirectoryEntry.localHeaderOffset+sizeof(ZIPLocalFileHeader)+CentralDirectoryEntry.filenameLength+CentralDirectoryEntry.extraFieldLength,
                              CentralDirectoryEntry.uncompressedSize);

    }

    return 1;
}

/******************************************************************************
                       ARJ Filesystem Driver:
******************************************************************************/
#pragma pack (1)                                     /* Force byte alignment */

typedef struct ARJMainHeader
{
    unsigned short id,      /* 2   header id (main and local file) = 0x60 0xEA */
                   size;    /* 2   basic header size (from 'first_hdr_size' thru 'comment' below)
                                   = first_hdr_size + strlen(filename) + 1 + strlen(comment) + 1
                                   = 0 if end of archive
                                   maximum header size is 2600 */

    /* 1   first_hdr_size (size up to and including 'extra data')   
       1   archiver version number   
       1   minimum archiver version to extract   
       1   host OS   (0 = MSDOS, 1 = PRIMOS, 2 = UNIX, 3 = AMIGA, 4 = MAC-OS)
		     (5 = OS/2, 6 = APPLE GS, 7 = ATARI ST, 8 = NEXT)
             (9 = VAX VMS)   
       1   arj flags
		     (0x01 = NOT USED)
		     (0x02 = OLD_SECURED_FLAG)
		     (0x04 = VOLUME_FLAG)  indicates presence of succeeding volume
		     (0x08 = NOT USED)
		     (0x10 = PATHSYM_FLAG) indicates archive name translated ("\" changed to "/")
		     (0x20 = BACKUP_FLAG) indicates backup type archive
             (0x40 = SECURED_FLAG)   
       1   security version (2 = current)   
       1   file type        (must equal 2)   
       1   reserved   
       4   date time when original archive was created   
       4   date time when archive was last modified   
       4   archive size (currently used only for secured archives)   
       4   security envelope file position   
       2   filespec position in filename   
       2   length in bytes of security envelope data   
       2   (currently not used)   
       ?   (currently none)   

       ?   filename of archive when created (null-terminated string)   
       ?   archive comment  (null-terminated string)   

       4   basic header CRC   

       2   1st extended header size (0 if none)   
       ?   1st extended header (currently not used)   
       4   1st extended header's CRC (not present when 0 extended header size) 
	*/

} ARJMainHeader;

#pragma pack ()                                      /* Force byte alignment */

/* Not quite ready yet */
int ARJ_xfmount(struct XFILE_Archive *archive)      /* ARJ Filesystem driver */
{
	archive=archive;
    return 1;
}


/******************************************************************************
                     XFILE initialization and shutdown:
******************************************************************************/
void xfinit(char *baseDir)
{
	baseDir=baseDir;						 /* Exciting amounts of nothing! */

    xfadddriver(VFS_BuildDriver("lzh",LZH_xfmount));          /* LZH support */
    xfadddriver(VFS_BuildDriver("pak",PAK_xfmount));         /* .PAK support */
    xfadddriver(VFS_BuildDriver("zip",ZIP_xfmount));         /* .ZIP support */
}

void xfshutdown()                                       /* Shuts down XFILE  */
{
}

/******************************************************************************
                            XFILE usage example:
******************************************************************************/

#ifdef TEST

/* xfexcercise stress tests the given archive, and all supported
   subarchives contained within it.
*/

#define MAX_ARCHIVES 256
void xfexcercise(char *archiveName)
{
    char buffer[256];
    char archiveFiles[MAX_ARCHIVES][128];
    int archiveMounted;
    XFILE_FIND *findHandle;
    XFILE *readHandle, *writeHandle;
    char *fileBuffer;
    size_t size;

    do
    {
        findHandle=NULL; archiveMounted=0;  /* Reset found */

        /* Scan through the directory, and mount any supported archives I find: */
        while(findHandle=xffindfile("*",findHandle))
        {
            if(xffindDriver(xfextension(findHandle->filename))) /* Is this format supported? */
                if(!xfismounted(findHandle->filename)) /* Make sure it isn't already mounted */
                {
                    printf("mounting %s...\n",archiveName);

                    if(!xfmount(archiveName))/* Attempt to mount the beastie */
                    {
                        sprintf(buffer,"Failed to mount %s\n",archiveName);
                        xferror(buffer);
                    }
                    archiveMounted=1;
                }
        }
    } while(archiveMounted);

    findHandle=NULL;

    while(findHandle=xffindfile("*",findHandle))
    {
        printf("Processing:%s\n",findHandle->filename);

        puts("loading...");
        size=0;
        fileBuffer=xfload(findHandle->filename,NULL,&size);

        puts("saving...");
        xfsave("test.out", fileBuffer, size);

        puts("freeing buffer...");
        free(fileBuffer);

        puts("comparing...");
        if(!(xfcompare(findHandle->filename,"test.out")))
        {
            sprintf(buffer,"%s and test.out don't match!\n",findHandle->filename);
            xferror(buffer);
        }

        puts("toasting temp file...");
        xfdelete("test.out");
    }
}

void main(int argc, char *argv[])
{
    XFILE *handle;
    char *buffer;

    xfinit(".\\");
    xfexcercise("test.zip");                   /* Excercise the test proggie */
    xfshutdown();
}
#endif
