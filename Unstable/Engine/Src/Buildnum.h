/* buildnum.h*/


#ifndef BUILDNUM_H
#define BUILDNUM_H
/* NOTE: To change build number, change the definitions
 * of both BN_BN and BUILD_NUMBER. The rest will use
 * the BN_BN definition.
 *
 * Change log:
 */
#define BN_BN   2512
#define BN_MAJOR   4
#define BN_STR  "2512"
#ifndef BUILD_NUMBER
#define BUILD_NUMBER "4.0.4." BN_STR "\0"
#endif

#ifndef JUSTDEFINES
char gszBuildNumber[] = "@(#) Microsoft Speech Build " BUILD_NUMBER;
#endif

#ifndef BN_PRODUCT_VERSION
#define BN_PRODUCT_VERSION 4,0,4,BN_BN
#endif

#ifndef BN_FILE_VER
#define BN_FILE_VERSION BN_PRODUCT_VERSION
#else
#define BN_FILE_VERSION BN_FILE_VER,BN_BN
#endif//BN_FILE_VER

#ifndef BN_FILE_STR
#define BN_FILE_VERSION_STR BUILD_NUMBER
#else
#define BN_FILE_VERSION_STR BN_FILE_STR " " BN_STR "\0"
#endif

#ifndef BN_FLAGS
    #ifdef _DEBUG
        #define BN_FLAGS VS_FF_DEBUG
    #else
        #ifdef TEST
            #define BN_FLAGS VS_FF_PRERELEASE
        #else
            #define BN_FLAGS 0
        #endif
    #endif
#endif

#ifndef BN_FLAGSMASK
#define BN_FLAGSMASK VS_FF_PRERELEASE | VS_FF_DEBUG
#endif//BN_FLAGSMASK

#ifndef BN_PRODUCTNAME
#define BN_PRODUCTNAME "Microsoft Speech\0"
#endif//BN_PRODUCTNAME

#ifndef BN_COPYRIGHT
#define BN_COPYRIGHT "Copyright © 1991-1998 Microsoft Corporation\0"
#endif//BN_COPYRIGHT

#endif // BUILDNUM_H
