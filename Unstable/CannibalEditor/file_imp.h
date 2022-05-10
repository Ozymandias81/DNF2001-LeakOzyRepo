#ifndef __FILE_IMP_H__
#define __FILE_IMP_H__
//****************************************************************************
//**
//**    FILE_IMP.H
//**    Header - Files - General Import Loaders
//**
//****************************************************************************
//----------------------------------------------------------------------------
//    Headers
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Definitions
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Class Prototypes
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Required External Class References
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Structures
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Public Data Declarations
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Public Function Declarations
//----------------------------------------------------------------------------
int FI_Load3DS(char *filename,
			   int *numframes, int *numverts, vector_t **frameVerts,
			   int *numfaces, int **faces, char **frameNames); // faces listed in index triplets
int FI_LoadMDL(char *filename,
			   int *numframes, int *numverts, vector_t **frameVerts,
			   int *numfaces, int **faces, char **frameNames);
int FI_LoadMD2(char *filename,
			   int *numframes, int *numverts, vector_t **frameVerts,
			   int *numfaces, int **faces, char **frameNames);
int FI_LoadMXB(char *filename,
			   int *numframes, int *numverts, vector_t **frameVerts,
			   int *numfaces, int **faces, char **frameNames);
int FI_LoadGMA(char *filename,
			   int *numframes, int *numverts, vector_t **frameVerts,
			   int *numfaces, int **faces, char **frameNames);
int FI_LoadLWO(char *filename,
			   int *numframes, int *numverts, vector_t **frameVerts,
			   int *numfaces, int **faces, char **frameNames);
//----------------------------------------------------------------------------
//    Class Headers
//----------------------------------------------------------------------------


//****************************************************************************
//**
//**    END HEADER FILE_IMP.H
//**
//****************************************************************************
#endif // __FILE_IMP_H__
