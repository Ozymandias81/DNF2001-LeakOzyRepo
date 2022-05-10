#include <windows.h>
#include <conapp.h>
#include <stdio.h>

class TestApp : public XConApp
{
	U32 main(void);
};

TestApp _testapp;

U32 TestApp::main(void)
{
	SetCurrentDirectory("f:\\duke4");
	XFindFile find;

	U32 depth;
	XFindInfo *info;

	autochar tmpstr=(char *)xmalloc(256);

	fstrcpy(tmpstr,"f:\\duke4\\filename.blah");
	fset_extension(tmpstr,"bmp");

	fstrcpy(tmpstr,"f:\\duke4\\filename");
	fset_extension(tmpstr,"123");

	fstrcpy(tmpstr,"f:\\duke4\\filename.");
	fset_extension(tmpstr,"321");

	fstrcpy(tmpstr,"blah_di_filename");
	fset_extension(tmpstr,"234");

	fstrcpy(tmpstr,"f:\\duke4\\");
	fset_extension(tmpstr,"432");

	autochar value;

	printf("Search 7\n");
	find.search("c:\\","*.sys");
	while(info=find.next(depth))
		printf("found %s\n",info->get_full_path());

	printf("Search 6\n");
	find.search("c:\\","*.dll",FIND_RECURSIVE);
	while(info=find.next(depth))
		printf("found %s\n",info->get_full_path());

	printf("Search 0\n");
	find.search(null,"x*.obj",FIND_RECURSIVE);
	while(info=find.next(depth))
		printf("found %s\n",info->get_full_path());

	printf("Search 0A\n");
	find.search(null,"x*.obj",FIND_RECURSIVE|FIND_WILD_ACROSS_SLASH);
	while(info=find.next(depth))
		printf("found %s\n",info->get_full_path());

	printf("Search 1\n");
	find.search(null,"*xmisc.cpp",FIND_RECURSIVE);
	while(info=find.next(depth))
		printf("found %s\n",info->get_full_path());

	printf("Search 2\n");
	find.search(null,"/obj/",FIND_RECURSIVE);
	while(info=find.next(depth))
		printf("found %s\n",info->get_full_path());

	printf("Search 3\n");
	find.search(null,"vidd3d/obj",FIND_RECURSIVE);
	while(info=find.next(depth))
		printf("found %s\n",info->get_full_path());

	printf("Search 4\n");
	find.search(null,"x*/obj",FIND_RECURSIVE);
	while(info=find.next(depth))
		printf("found %s\n",info->get_full_path());

	printf("Search 5\n");
	find.search(null,"w*n*l*p",FIND_RECURSIVE);
	while(info=find.next(depth))
		printf("found %s\n",info->get_full_path());
	
	return TRUE;
}