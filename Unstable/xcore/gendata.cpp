#include <xtypes.h>
#include <stdio.h>

#include <xcore.h>

using namespace NS_STRING;

U8 misc_char_flags[256];

void init_char_flags(void)
{
	U32 i;
	U8 *post=(U8 *)&misc_char_flags[0];

	memset(post,0,sizeof(misc_char_flags));

	post['\n']|=KEY_NEWLINE|KEY_WHITE;
	post['\r']|=KEY_NEWLINE|KEY_WHITE;
	post[' ']|=KEY_WHITE;
	post['\t']|=KEY_WHITE;
	post['\'']|=KEY_QUOTE;
	post['\"']|=KEY_QUOTE;

	for (i=48;i<58;i++){post[i]|=KEY_DIGIT;}
	for (i=64;i<71;i++){post[i]|=KEY_ALPHA|KEY_UPPER|KEY_HEX_ALPHA;}
	for (i=71;i<91;i++){post[i]|=KEY_ALPHA|KEY_UPPER;}
	for (i=97;i<103;i++){post[i]|=KEY_ALPHA|KEY_LOWER|KEY_HEX_ALPHA;}
	for (i=103;i<123;i++){post[i]|=KEY_ALPHA|KEY_LOWER;}
}

int main(void)
{
	U32 i;

	init_char_flags();

	printf("#include \"stdcore.h\"\n\n");
	printf("CU8 _app_char_flags[]=\n");
	printf("{\n");
	for (i=0;i<256;i+=8)
	{
		printf("\t0x%02X,0x%02X,0x%02X,0x%02X,0x%02X,0x%02X,0x%02X,0x%02X",
				misc_char_flags[i],misc_char_flags[i+1],
				misc_char_flags[i+2],misc_char_flags[i+3],
				misc_char_flags[i+4],misc_char_flags[i+5],
				misc_char_flags[i+6],misc_char_flags[i+7]);
		if (i!=248)
			printf(",\n");
		else
			printf("\n");
	}
	printf("};\n");

	fflush(stdout);
	return 0;
}