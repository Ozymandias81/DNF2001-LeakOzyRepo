#include "stdd3d.h"

#define SHADOW

U32 calc_vsize(U32 fvf_flags)
{
	if (fvf_flags & D3DFVF_PSIZE)
		xxx_fatal("calc_vsize: Unhandled vertex format type");

	U32 size=0;
	if (fvf_flags & D3DFVF_DIFFUSE)
		size+=1;
	if (fvf_flags & D3DFVF_NORMAL)
		size+=3;
	if (fvf_flags & D3DFVF_SPECULAR)
		size+=1;
	if (fvf_flags & D3DFVF_XYZ)
		size+=3;
	if (fvf_flags & D3DFVF_XYZRHW)
		size+=4;
	/* add vertex blending weights */
	if ((fvf_flags & D3DFVF_XYZB1)==D3DFVF_XYZB1)
		size+=1;
	else if ((fvf_flags & D3DFVF_XYZB2)==D3DFVF_XYZB2)
		size+=2;
	else if ((fvf_flags & D3DFVF_XYZB3)==D3DFVF_XYZB3)
		size+=3;
	else if ((fvf_flags & D3DFVF_XYZB4)==D3DFVF_XYZB4)
		size+=4;
	else if ((fvf_flags & D3DFVF_XYZB5)==D3DFVF_XYZB5)
		size+=5;
	/* add texture coordinates */
	size+=(fvf_flags & 0xF00)>>7;

	return size;
}

VBuffer::VBuffer(IDirect3DDevice8 *Dev,U32 fvf_flags,U32 Count) : dev(Dev),fvf(fvf_flags),count(Count),cur_off(0)
{
	D_ASSERT(dev);
	D_ASSERT(count<32000);

	if (count>32000)
		count=32000;
	
	state.vsize=calc_vsize(fvf_flags);
	size=count*state.vsize*4;
#if 0
	if (dev->CreateVertexBuffer(size+512,D3DUSAGE_WRITEONLY|D3DUSAGE_DYNAMIC,fvf,D3DPOOL_DEFAULT,&vbuffer)!=D3D_OK)
		xxx_fatal("Unable to create vertex buffer");
#else
	if (dev->CreateVertexBuffer(size+512,D3DUSAGE_DYNAMIC,fvf,D3DPOOL_DEFAULT,&vbuffer)!=D3D_OK)
		xxx_fatal("Unable to create vertex buffer");
#endif

#ifdef SHADOW
	shadow=(char *)xmalloc(size);
#endif
	state.begin=TRUE;

	lock_end=cur_off=0;
}

VBuffer::~VBuffer(void)
{
	vbuffer->Release();
	
	vbuffer=null;
	count=0;
}

/* mark vertex buffer done for rest of frame */
void VBuffer::finished(void)
{
	state.is_finished=TRUE;
}

void VBuffer::begin_frame(void)
{
	state.is_finished=FALSE;
	state.begin=TRUE;
	lock_end=cur_off=0;
#ifdef SHADOW
	scur32=(U32 *)shadow.get_ptr();
#endif
}

void VBuffer::select(void)
{
	/* NOTE: Order may be important */
	if (dev->SetStreamSource(0,vbuffer,state.vsize*4)!=D3D_OK)
		xxx_fatal("Unable to set stream source");
	if (dev->SetVertexShader(fvf)!=D3D_OK)
		xxx_fatal("Unable to set stream source");
}

VManager::VManager(VidD3D *Vid,IDirect3DDevice8 *Dev,U32 num_buffers,U32 count,U32 fvf_flags) : vid(Vid),dev(Dev),def_count(count),fvf(fvf_flags)
{
	D_ASSERT(vid);D_ASSERT(dev);

	VBuffer *obj=new VBuffer(dev,fvf,def_count);
	insert_after(null,obj);
	obj->select();
	vindex=0;

	while(((I32)(num_buffers-=1))>0)
	{
		obj=new VBuffer(dev,fvf,def_count);
		insert_after(cur,obj);
	}

	prims=new PrimBuffer;
	
	U32 vbuffer_room=obj->get_room();
	room=vbuffer_room;
}

void PrimBuffer::begin_frame(void)
{
	D_ASSERT(prim==(PrimD3D *)base);
	
	reset();
}

void VManager::BeginNewFrame(void)
{
	VBuffer *start;

	prims->begin_frame();

	start=cur;
	do
	{
		cur->begin_frame();
		cur=cur->next;
	}while(start!=cur);

	cur=start->next;
	cur->select();
	vindex=0;
	room=cur->get_room();
}

VBuffer *VManager::alloc_vbuffer(VBuffer *after,U32 need)
{
	VBuffer *obj=new VBuffer(dev,cur->fvf,cur->count);

	insert_after(after,obj);

	return obj;
}

void VManager::MakeRoom(U32 need)
{
	do
	{
		I32 vb_room=cur->get_room();

		room=vb_room;

		/* we actually have enough room */
		if ((room-=need)>=0)
			return;

		/* flush existing data */
		flush();
		/* mark current vbuffer as finished for this frame */
		cur->finished();
		/* loop through looking for a vbuffer that is unfinished */
		VBuffer *tmp=cur;
		cur=cur->next;
		while(tmp!=cur)
		{
			if (!cur->is_finished())
				break;
			cur=cur->next;
		}
		if (cur->is_finished())
			cur=alloc_vbuffer(tmp,need);
		/* select buffer for rendering */
		cur->select();
		vindex=0;
	}while(1);
}

void VManager::flush(void)
{
}

void VManager::EndScene(void)
{
}