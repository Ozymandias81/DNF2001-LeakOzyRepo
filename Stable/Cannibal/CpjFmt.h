/*

Cannibal Project (CPJ)
File Format Specification v1.0
Author: Chris Hargrove
Last modified: 1/21/00


_____Overview

Cannibal Project Files (.CPJ) contain a collection of data chunks used
collectively to describe Cannibal-based polygonal models.  The chunks
represent several distinct aspects of a model's description, and have a
relatively small amount of direct interdependency beyond commonalities such
as triangle and vertex counts.  These chunks are combined together with
model actor configuration chunks, to form a combined model definition.

While the primary file extension used by the format is .CPJ, a variety of
extensions may be used depending on the contents of the project files.
Extensions such as .GEO, .SRF, .LOD, .SKL, .FRM, .SEQ, and .MAC are frequently
used with projects which have only one chunk present within, that chunk being
of the type corresponding to the extension (see the chunk descriptions below).
In other cases, like with full model descriptions and the like, the normal
.CPJ extension should be used.  Web sites and other format databases should
consider this document a reference for the .CPJ file format; all related file
extensions such as those listed above still use this same format.


_____Format

A project file is collection of chunks which, when combined amongst themselves
and other project files, represent a model in its entirety.  Project files are
RIFF (Resource Interchange File Format) compatible, with each chunk stored as
an RIFF chunk.  The first two 32-bit values of all chunks are a magic marker
and subsequent length value, to allow RIFF compatibility.

*/

#define CPJ_HDR_RIFF_MAGIC		"RIFF"
#define CPJ_HDR_FORM_MAGIC		"CPJB"

struct SCpjFileHeader
{
    unsigned long riffMagic; // CPJ_HDR_RIFF_MAGIC
    unsigned long lenFile; // length of file following this value
    unsigned long formMagic; // CPJ_HDR_FORM_MAGIC
};

struct SCpjChunkHeader
{
    unsigned long magic; // chunk-specific magic marker
    unsigned long lenFile; // length of chunk following this value
    unsigned long version; // chunk-specific format version
    unsigned long timeStamp; // time stamp of chunk creation
    unsigned long ofsName; // offset of chunk name string from start of chunk
                           // If this value is zero, the chunk is nameless
};

/*

Following this header are the data chunks, which continue until the file
ends according to the project header's file length value.  Any number of any
type of chunk may be present within the project.  Chunks with markers or
versions unrecognized by a loader may be skipped.  For the standard chunks
defined in this document, chunk names should be normal "identifier" strings,
which contain only alphanumeric characters and underscores and the like.
The use of symbolic characters or spaces could cause problems for chunk
addressing facilities and should be avoided (for example, chunk names should
not include backslashes, otherwise lookups from a MAC chunk would likely fail
to find it).

Important: In accordance with RIFF, if any chunk's length value is odd, an
additional byte not accounted for in the chunk length will follow the chunk,
to round the chunk to a word boundary (all RIFF chunks must have at least
16-bit word granularity).


_____Conventions

The coordinate system convention is a right-handed orthogonal frame such
that, from a model's perspective, the X axis points to the left, the Y axis
points upward, and the Z axis points forward.  From an exterior camera's
perspective looking at the model from the front, the X axis would point to
the right, Y would point upward, and Z towards the rear of the camera out of
the screen.

All coordinate systems are stored such that the order of operations is done
in translate-rotate-scale or scale-rotate-translate order, depending on the
direction of the transform.  This is representative of a coordinate system
where the translation represents the origin, the rotation determines the
directions of the three axes, and the scale is the length of each axis,
respectively.

Rotations are stored as four-float quaternions with the vector component
first followed by the scalar component.  Any rotations which don't use
quaternions will be specifically noted (such as animation sequences which
use 16-bit euler angles instead of quaternions).  Hierarchical transformation
information, including rotations, is stored relative to parent.

*/

#ifndef CPJVECTOR
struct SCpjVector
{
	float x, y, z; // cartesian axis components
};
#define CPJVECTOR SCpjVector
#endif

#ifndef CPJQUAT
struct SCpjQuat
{
	CPJVECTOR v; // quaternion vector component
	float s; // quaternion scalar component
};
#define CPJQUAT SCpjQuat
#endif


/*

_____Cannibal Model Actor Configuration Chunk (MAC)

A model actor represents a combination of various resources and represents
the model as a whole.  The initial configuration of a model actor is done
with model actor configuration chunks.  These chunks contain a series of
text commands which are executed to change the properties of the actor.
The commands are used to set up a model's active resource chunks as well as
any other miscellaneous properties desired.

The chunk is broken up into "sections", each of which contains a simple
set of text commands that are executed in order.  The separation into sections
allows user extension information to be stored with the actor, within a
different section.  Any sections not explicitly requested by an editing
program should be preserved intact without alteration.

Model actor chunks can be stored in files independent of a full model project
(using the .MAC extension; see the Overview section above), for the purposes
of import and export convenience.  Although they can be stored outside a
full project, they are often meaningless in such a state.  Actor chunks are
most useful within the context of the full project with which they are
associated.

*/

#define CPJ_MAC_MAGIC       "MACB"
#define CPJ_MAC_VERSION     1

struct SMacSection
{
    unsigned long ofsName; // offset of section name string in data block
    unsigned long numCommands; // number of command strings in section
    unsigned long firstCommand; // first command string index
};

struct SMacFile
{
    SCpjChunkHeader header; // header information
    
    // sections (array of SMacSection)
    unsigned long numSections; // number of sections
    unsigned long ofsSections; // offset of sections in data block

    // command strings (array of unsigned long, offsets into data block)
    unsigned long numCommands; // number of commands
    unsigned long ofsCommands; // offset of command strings in data block

    // data block
    unsigned char dataBlock[1]; // variable sized data block
};

/*

Command strings are case-insensitive.

Commands which refer to chunks contain file names of the project where the
chunk is located, followed by a backslash '\' and the name of the chunk.
This treats the project as a "virtual directory" with the chunk acting like
a file within that directory.  If a chunk does not have any backslashes in
the path, then it is assumed that a project file name is not present and thus
the chunk can be found within the same project file as this configuration
chunk.  Project file names are NOT stored using absolute directory paths,
as this would prevent the ability to transfer the model to another physical
location.  Instead, all projects are relative to a application-determined
directory which acts as the root of all project files.  The application will
prepend this root directory to all project file names in order to determine
the physical location of the project.

For example, if the application base path was "C:\Cannibal", and there is a
project file named "C:\Cannibal\Projects\Test.cpj" which contains a surface
chunk "TestSurface", then a path reference to this chunk would be stored as
"Projects\Test\TestSurface".  Within Test.cpj, the chunk name "TestSurface"
by itself would also suffice.  Note that the project file extension in these
names is allowed but not required.  Also be aware that implicit directories
"." and ".." are not permitted in these file names, as they could potentially
bypass the limits of the application base path.

Duke Nukem Forever Specific Note: The application subdirectory for DNF is the
"Meshes" directory directly below the game installation directory.  All
mesh-related files for DNF must be stored within this subdirectory tree.

Cannibal's stock section name is "autoexec".  Any time a model is saved,
this section's commands will be overwritten.  Extension commands should be
stored in a different section.  The standard commands for this section
are listed below.  Parameters are described within parentheses.  String
parameters must be enclosed within quotation marks.

SetAuthor (string authorName)
    Sets the name of the model author
SetDescription (string description)
    Sets description text about the model

SetOrigin (float x) (float y) (float z)
    Sets origin position, defaults to 0 0 0
SetScale (float x) (float y) (float z)
    Sets axis scale values, defaults to 1 1 1
SetRotation (float roll) (float pitch) (float yaw)
    Sets roll, pitch, and yaw rotations, in degrees (360), defaults to 0 0 0

SetGeometry (string chunkPath)
    Sets the geometry chunk, required for the model to work.
SetSurface (int index) (string chunkPath)
    Sets a surface chunk, where index is an integer zero or above.  An index
    value of 0 is the primary surface, and any additional surfaces are used
    for decals.  Surface chunks must be compatible with the geometry chunk.
SetLodData (string chunkPath)
    Sets the level of detail chunk if applicable, which must be compatible
    with the geometry and the primary surface.
SetSkeleton (string chunkPath)
    Sets the skeleton chunk if applicable, which must be compatible with the
    geometry chunk.
AddFrames (string projectPath)
    Adds the vertex frame chunks of the given project file to the frame
    search list for the actor.  Sequences which request vertex frames will
    attempt to locate the frames within the projects added by this command.
    The special projectPath name of "NULL" indicates the configuration project
    file.  Accepts the '*' wildcard, for example, AddFrames "MyFrames\*.cpj"
AddSequences (string projectPath)
    Adds the sequence chunks of the given project file to the sequence search
    list for the actor.  An actor will attempt to locate a sequence within
    the projects added by this command.  The special projectPath name of
    "NULL" indicates the configuration project file.  Accepts the '*'
    wildcard, for example, AddSequences "MySeqs\*.cpj"


_____Geometry Chunk (GEO)

These chunks contain a description of a model's triangular mesh geometry
boundary representation which is unchanged regardless of a model instance's
animation state.  It describes vertices, edges, triangles, and the
connections between them, as well any mount points associated with the
model geometry.

*/

enum
{
	GEOVF_LODLOCK	= 0x00000001 // vertex is locked during LOD processing
};

struct SGeoVert
{
    unsigned char flags; // GEOVF_ vertex flags
    unsigned char groupIndex; // group index for vertex frame compression
    unsigned short reserved; // reserved for future use, must be zero
    unsigned short numEdgeLinks; // number of edges linked to this vertex
    unsigned short numTriLinks; // number of triangles linked to this vertex
    unsigned long firstEdgeLink; // first edge index in object link array
    unsigned long firstTriLink; // first triangle index in object link array
    CPJVECTOR refPosition; // reference position of vertex
};

struct SGeoEdge
{
    unsigned short headVertex; // vertex list index of edge's head vertex
    unsigned short tailVertex; // vertex list index of edge's tail vertex
    unsigned short invertedEdge; // edge list index of inverted mirror edge
    unsigned short numTriLinks; // number of triangles linked to this edge
    unsigned long firstTriLink; // first triangle index in object link array
};

struct SGeoTri
{
    unsigned short edgeRing[3]; // edge list indices used by triangle, whose
                                // tail vertices are V0, V1, and V2, in order
    unsigned short reserved; // reserved for future use, must be zero
};

struct SGeoMount
{
    unsigned long ofsName; // offset of mount point name string in data block
    unsigned long triIndex; // triangle index of mount base
    CPJVECTOR triBarys; // barycentric coordinates of mount origin
    CPJVECTOR baseScale; // base transform scaling
    CPJQUAT baseRotate; // base transform rotation quaternion
    CPJVECTOR baseTranslate; // base transform translation

    // A mount's runtime transform is calculated as the base transform
    // shifted out of a second transform determined by the triangle on the
    // fly.  This transform has a unit scale, a translation of the point on
    // the triangle described by the given barycentric coordinates, and a
    // rotation described by a specific axial frame.  This axial frame has
    // a Y axis that is the normal of the triangle, a Z axis that is the
    // normalized vector from the mount origin point to the triangle's V0,
    // and a X axis that is the cross product of these Y and Z axes.
};

#define CPJ_GEO_MAGIC		"GEOB"
#define CPJ_GEO_VERSION     1

struct SGeoFile
{    
    SCpjChunkHeader header; // header information

    // vertices (array of SGeoVert)
    unsigned long numVertices; // number of vertices
    unsigned long ofsVertices; // offset of vertices in data block

    // edges (array of SGeoEdge)
    unsigned long numEdges; // number of edges
    unsigned long ofsEdges; // offset of edges in data block

    // triangles (array of SGeoTri)
    unsigned long numTris; // number of triangles
    unsigned long ofsTris; // offset of triangles in data block

    // mount points (array of SGeoMount)
    unsigned long numMounts; // number of mounts
    unsigned long ofsMounts; // offset of mounts in data block

    // object links (array of unsigned short)
    unsigned long numObjLinks; // number of object links
    unsigned long ofsObjLinks; // number of object links in data

    // data block
    unsigned char dataBlock[1]; // variable sized data block
};

/*

_____Surface Chunk (SRF)

The surface chunk of a model describes the surface properties of its
triangles for rendering and so forth.  It contains texture map coordinates,
texture names used by the triangles, various display-related flags, and other
supplemental information.  The number of triangles used should match the
number of triangles in the geometry chunk.  Surfaces can be stacked together
on top of a model, with the first surface acting as the primary "skin" of
the model and additional surfaces being used for decals (where non-decaled
triangles are flagged as inactive).

*/

struct SSrfTex
{
	unsigned long ofsName; // offset of texture name string in data block
	unsigned long ofsRefName; // offset of optional reference name in block
};

enum
{
    SRFTF_INACTIVE		= 0x00000001, // triangle is not active
    SRFTF_HIDDEN		= 0x00000002, // present but invisible
    SRFTF_VNIGNORE		= 0x00000004, // ignored in vertex normal calculations
    SRFTF_TRANSPARENT	= 0x00000008, // transparent rendering is enabled
    SRFTF_UNLIT			= 0x00000020, // not affected by dynamic lighting
    SRFTF_TWOSIDED		= 0x00000040, // visible from both sides
    SRFTF_MASKING		= 0x00000080, // color key masking is active
    SRFTF_MODULATED		= 0x00000100, // modulated rendering is enabled
    SRFTF_ENVMAP		= 0x00000200, // environment mapped
	SRFTF_NONCOLLIDE	= 0x00000400, // traceray won't collide with this surface
	SRFTF_TEXBLEND		= 0x00000800,
	SRFTF_ZLATER		= 0x00001000,
	SRFTF_RESERVED		= 0x00010000
};

enum ESrfGlaze
{
	SRFGLAZE_NONE=0,	// no glaze pass
	SRFGLAZE_SPECULAR	// fake specular glaze
};

struct SSrfTri
{
    unsigned short uvIndex[3]; // UV texture coordinate indices used
    unsigned char texIndex; // surface texture index
    unsigned char reserved; // reserved for future use, must be zero
    unsigned long flags; // SRFTF_ triangle flags
    unsigned char smoothGroup; // light smoothing group
    unsigned char alphaLevel; // transparent/modulated alpha level
    unsigned char glazeTexIndex; // second-pass glaze texture index if used
    unsigned char glazeFunc; // ESrfGlaze second-pass glaze function
};

struct SSrfUV
{
    float u; // texture U coordinate
    float v; // texture V coordinate
};

#define CPJ_SRF_MAGIC		"SRFB"
#define CPJ_SRF_VERSION     1

struct SSrfFile
{
    SCpjChunkHeader header; // header information

    // textures (array of SSrfTex)
    unsigned long numTextures; // number of textures
    unsigned long ofsTextures; // offset of textures in data block

    // triangles (array of SSrfTri)
    unsigned long numTris; // number of triangles
    unsigned long ofsTris; // offset of triangles in data block

    // UV texture coordinates (array of SSrfUV)
    unsigned long numUV; // number of UV texture coordinates
    unsigned long ofsUV; // offset of UV texture coordinates in data block

    // data block
    unsigned char dataBlock[1]; // variable sized data block
};

/*

_____Level Of Detail Chunk (LOD)

These chunks store level of detail reduction information based on a specific
combination of a geometry chunk and surface chunk.  The information describes
discrete levels of detail in the form of alternate geometry and primary
surface information to use at lower levels of detail, the level being one
at full detail and zero at lowest detail (maximum distance).  Each level
contains a vertex relay to the original geometry vertex indices, so that the
lower details can use the same frame and sequence chunks as the original.
The relay is a list of vertex index values into the original geometry, and
its count indicates the number of vertices used by the level.  The triangle
vertex indices are not actual geometry indices, but indices into the relay.
UV indices directly map to the UVs of the original surface.

Note that this form of LOD storage is not entirely compact, and is does not
permit full (continuous) level of detail reduction.  This is a deliberate
tradeoff of memory efficiency and flexibility in exchange for raw runtime
speed.

*/

struct SLodTri
{
    unsigned long srfTriIndex; // original surface triangle index
	unsigned short vertIndex[3]; // relayed vertex indices used by triangle
    unsigned short uvIndex[3]; // surface UV indices used by triangle
};

struct SLodLevel
{
	float detail; // maximum detail value of this level, from zero to one
	unsigned long numTriangles; // number of triangles in level
	unsigned long numVertRelay; // number of vertices in level relay
	unsigned long firstTriangle; // first triangle in triangle list
	unsigned long firstVertRelay; // first index in vertex relay
};

#define CPJ_LOD_MAGIC		"LODB"
#define CPJ_LOD_VERSION     3

struct SLodFile
{
    SCpjChunkHeader header; // header information

	// levels (array of SLodLevel)
    unsigned long numLevels; // number of levels
    unsigned long ofsLevels; // offset of levels in data block

	// triangles (array of SLodTri)
	unsigned long numTriangles; // number of triangles
	unsigned long ofsTriangles; // offset of triangles in data block

	// vertex relay (array of unsigned short)
	unsigned long numVertRelay; // number of vertices in relay
	unsigned long ofsVertRelay; // offset of vertex relay in data block

    // data block
    unsigned char dataBlock[1]; // variable sized data block
};

/*

_____Skeleton Chunk (SKL)

These chunks, if present, allow a model to be capable of skeletal-based
animation.  It contains a list of bones with their initial transforms and
hierarchical parents, as well as the vertex weights to use when applying a
matching geometry chunk.  All bone transforms are relative to their parents,
and the indices of the vertices should correspond to the vertices of the
geometry chunk being used.  These chunks also hold any mount points
associated with the skeleton.

*/

struct SSklBone
{
    unsigned long ofsName; // offset of bone name string in data block
    unsigned long parentIndex; // parent bone index, -1 if none
    CPJVECTOR baseScale; // base transform scaling
    CPJQUAT baseRotate; // base transform rotation quaternion
    CPJVECTOR baseTranslate; // base transform translation
    float length; // length of the bone, used for rotation adjustments
};

struct SSklVert
{
    unsigned short numWeights; // number of skeletal weights
    unsigned short firstWeight; // first index in skeletal weights
};

struct SSklWeight
{
    unsigned long boneIndex; // index of bone used by weight
    float weightFactor; // weighting factor, [0.0-1.0]
    CPJVECTOR offsetPos; // offset position vector
};

struct SSklMount
{
    unsigned long ofsName; // offset of mount point name string in data block
    unsigned long boneIndex; // bone index of mount base, -1 if origin
    CPJVECTOR baseScale; // base transform scaling
    CPJQUAT baseRotate; // base transform rotation quaternion
    CPJVECTOR baseTranslate; // base transform translation
};

#define CPJ_SKL_MAGIC		"SKLB"
#define CPJ_SKL_VERSION     1

struct SSklFile
{
    SCpjChunkHeader header; // header information

    // skeletal bones (array of SSklBone)
    unsigned long numBones; // number of skeletal bones
    unsigned long ofsBones; // offset of skeletal bones in data block

    // skeletal vertices (array of SSklVert)
    unsigned long numVerts; // number of skeletal vertices
    unsigned long ofsVerts; // offset of skeletal vertices in data block

    // skeletal weights (array of SSklWeight)
    unsigned long numWeights; // number of skeletal weights
    unsigned long ofsWeights; // offset of skeletal weights in data block

	// bone mounts (array of SSklMount)
	unsigned long numMounts; // number of bone mounts
	unsigned long ofsMounts; // offset of bone mounts in data block

    // data block
    unsigned char dataBlock[1]; // variable sized data block
};

/*

_____Vertex Frames Chunk (FRM)

A vertex frames chunk holds one or more vertex frames.  Each vertex frame
can be applied directly to the vertices of a geometry definition, for
frame-based animation.  The positions may either be raw uncompressed vectors,
or compressed into byte positions according to the vertex group indices.

*/

struct SFrmBytePos
{
    unsigned char group; // compression group number
    unsigned char pos[3]; // byte position
};

struct SFrmGroup
{
    CPJVECTOR byteScale; // scale byte positions by this
    CPJVECTOR byteTranslate; // add to positions after scale
};

struct SFrmFrame
{
    unsigned long ofsFrameName; // offset of frame name in data block

    // frame bounding box
    CPJVECTOR bbMin; // bounding box minimum
    CPJVECTOR bbMax; // bounding box maximum

    // byte compression groups (array of SFrmGroup)
    unsigned long numGroups; // number of byte compression groups, zero means
                             // frame is uncompressed, otherwise compressed
    unsigned long ofsGroups; // offset of groups in data block, if compressed

    // vertex positions
    // array of CPJVECTOR if uncompressed
    // array of SFrmBytePos if compressed
    unsigned long numVerts; // number of vertex positions
    unsigned long ofsVerts; // offset of vertex positions in data block
};

#define CPJ_FRM_MAGIC		"FRMB"
#define CPJ_FRM_VERSION     1

struct SFrmFile
{
    SCpjChunkHeader header; // header information

    // bounding box of all frames
    CPJVECTOR bbMin; // bounding box minimum
    CPJVECTOR bbMax; // bounding box maximum

    // vertex frames (array of SFrmFrame)
    unsigned long numFrames; // number of vertex frames
    unsigned long ofsFrames; // offset of vertex frames in data block

    // data block
    unsigned char dataBlock[1]; // variable sized data block
};

/*

_____Sequenced Animation Chunk (SEQ)

A sequenced animation chunk contains an animation sequence in the form frame
structures which hold the state of the animation at a given point in the
sequence, containing skeletal and/or frame-based animation information.
The sequence can be executed in one of a model instance's runtime animation
"channels" at a given frames per second playback rate, and can be combined
with other channels to produce composite animations.  In addition, the
sequence may contain a series of "events" to fire at a particular point
during playback.

Since sequenced animation data is independent of any particular project,
all model resources needed are referred to by name, which can be bound to
actual model resources at runtime.  Each frame may refer to a single vertex
frame for frame-based animations, and/or a collection of bones for skeletal
animation.  Most skeletal animations will only use the rotate component, and
as such it is compressed into 16-bit euler angles.  The translate and scale
components are still supported, but are less common and left at full
precision.  All skeletal transformations are relative to the initial
structure transformation of the corresponding bone (which is then relative
to the bone's parent), to allow the animation to be used by multiple skeleton
structures.  During playback, the usage of any bones that are not described
by the sequence is determined by the implementation.  The bones may be left
in their default state, or ignored entirely, depending on context.

*/

struct SSeqBoneInfo
{
    unsigned long ofsName; // offset of bone name string in data block
    float srcLength; // source skeleton bone length
};

struct SSeqBoneTranslate
{
    unsigned short boneIndex; // bone info index
    unsigned short reserved; // must be zero
    CPJVECTOR translate; // translation vector
};

struct SSeqBoneRotate
{
    unsigned short boneIndex; // bone info index
    signed short roll; // roll about Z axis in 64k degrees, followed by...
    signed short pitch; // pitch about X axis in 64k degrees, followed by...
    signed short yaw; // yaw about Y axis in 64k degrees
};

struct SSeqBoneScale
{
    unsigned short boneIndex; // bone info index
    unsigned short reserved; // must be zero
    CPJVECTOR scale; // component scaling values
};

#define CPJ_SEQEV_FOURCC(a,b,c,d) ((a)+((b)<<8)+((c)<<16)+((d)<<24))

enum ESeqEvent
{
    SEQEV_INVALID		=0,
	// string is a marker, not an actual event
	SEQEV_MARKER		=CPJ_SEQEV_FOURCC('M','R','K','R'),
    // fire a trigger notification string, application specific use
	SEQEV_TRIGGER		=CPJ_SEQEV_FOURCC('T','R','I','G'),
	// send a MAC chunk command to the backing actor
	SEQEV_ACTORCMD		=CPJ_SEQEV_FOURCC('A','C','M','D'),
	// triangle flag alteration, string is a character string of hex digits,
	// one byte per triangle (length should match surface chunk triangle
	// count), for 4 possible flags.  Hex digits A through F must be uppercase.
	// Bit 0: Triangle is hidden
	// Bit 1-3: Currently unused
	SEQEV_TRIFLAGS		=CPJ_SEQEV_FOURCC('T','F','L','G'),
};

struct SSeqFrame
{
    unsigned char reserved; // reserved for future use, must be zero
    unsigned char numBoneTranslate; // number of bone translations
    unsigned char numBoneRotate; // number of bone rotations
    unsigned char numBoneScale; // number of bone scalings
    unsigned long firstBoneTranslate; // first bone translation index
    unsigned long firstBoneRotate; // first bone rotation index
    unsigned long firstBoneScale; // first bone scaling index
    unsigned long ofsVertFrameName; // offset of vertex frame name in data
                                    // block or -1 if no vertex frame is used
};

struct SSeqEvent
{
    unsigned long eventType; // ESeqEvent event type
    float time; // sequence time of event, from zero to one
    unsigned long ofsParam; // offset of parameter string in data block,
                            // or -1 if string not used
};

#define CPJ_SEQ_MAGIC		"SEQB"
#define CPJ_SEQ_VERSION     1

struct SSeqFile
{
    SCpjChunkHeader header; // header information
    
    // global sequence information
	float playRate; // sequence play rate in frames per second

    // sequence frames
    unsigned long numFrames; // number of sequence frames
    unsigned long ofsFrames; // offset of sequence frames in data

    // sequence events, in chronological order
    unsigned long numEvents; // number of events
    unsigned long ofsEvents; // offset of events in data

    // bone info (array of SSeqBoneInfo)
    unsigned long numBoneInfo; // number of bone info
    unsigned long ofsBoneInfo; // offset of bone info in data block

    // bone translations (array of SSeqBoneTranslate)
    unsigned long numBoneTranslate; // number of bone translations
    unsigned long ofsBoneTranslate; // offset of bone translations in data

    // bone rotations (array of SSeqBoneRotate)
    unsigned long numBoneRotate; // number of bone rotations
    unsigned long ofsBoneRotate; // offset of bone rotations in data

    // bone scalings (array of SSeqBoneScale)
    unsigned long numBoneScale; // number of bone scalings
    unsigned long ofsBoneScale; // offset of bone scalings in data

    // data block
    unsigned char dataBlock[1]; // variable sized data block
};

/*

_____End of File

*/
