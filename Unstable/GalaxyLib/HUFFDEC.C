#include <stdio.h>
#include <string.h>
#include <conio.h>
#include <math.h>

int main(void)
{
  unsigned int len,n,treelen,xlen,ylen,linbits,v0,v1;
  unsigned char line[100],command[100],used[16][16];
  unsigned int entry,entry2,baseidx,idx,idx2,i,j;
  unsigned short *table[32],*tree[32],tableno;
  FILE *In,*Out,*Out2;
  float temp;

  temp=1.0f/3.0f;
  printf("%x",*((int *)(&temp)));


  exit(0);
  In=fopen("huffdec.txt","r");
  Out=fopen("hufftab.h","w");
  Out2=fopen("hufftab2.h","w");
  memset(line,0,100);
  memset(command,0,100);
  //read huffman decoder trees
  for (n=0;n<32;n++)
  {
    do
    {
      fgets(line,99,In);
    } while ((line[0] == '#') || (line[0] < ' '));
    fprintf(stderr,"%s\n",line);
    sscanf(line,"%s %u %u %u %u %u",command,&tableno,&treelen,&xlen,&ylen,&linbits);
    if (strcmp(command,".end")==0)
      return n;
    else if (strcmp(command,".table")!=0)
    {
      fprintf(stderr,"huffman table %u data corrupted\n",n);
      fclose(Out2);
      fclose(Out);
      fclose(In);
      return -1;
    }
    do {
      fgets(line,99,In);
    } while ((line[0] == '#') || (line[0] < ' '));
    sscanf(line,"%s %u",command,&i);
    if (strcmp(command,".reference")==0)
    {
      tree[n]=NULL;
      fgets(line,99,In);
    }
    else if (strcmp(command,".treedata")==0)
    {
      if (treelen)
        tree[n]=malloc(treelen*sizeof(unsigned short));
      else
        tree[n]=NULL;
      if ((tree[n] == NULL)&&(treelen != 0))
      {
    	fprintf(stderr, "heaperror at table %d\n",n);
        fclose(Out2);
        fclose(Out);
        fclose(In);
    	exit (-1);
      }
      for (i=0;i<treelen;i++)
      {
        fscanf(In,"%x %x",&v0,&v1);
        tree[n][i]=((v1<<8)|(v0));
      }
      fgets(line,99,In);
    }
    else
      fprintf(stderr,"huffman decodertable error at table %d\n",n);
  }
  //build huffman decoder tables
  for (n=0;n<32;n++)
  {
    if (tree[n])
    {
      idx2=0;
      memset(used,0,sizeof(used));
      fprintf(Out,"static const short huff%d[]={\n",n);
      fprintf(Out2,"static const long huff2_%d[]={\n",n);
      //build head table (8 bits)
      for (i=0;i<256;i++)
      {
        idx=len=0;
        while ((tree[n][idx]&255)&&(len<8))
        {
          while (((tree[n][idx]>>(8*((i>>(7-len))&1)))&255)>=250)
            idx+=(tree[n][idx]>>(8*((i>>(7-len))&1)))&255;
          idx+=(tree[n][idx]>>(8*((i>>(7-len))&1)))&255;
          len++;
        }
        if (tree[n][idx]&255)
        {
          baseidx=idx;
          entry=((0x88<<8)|idx2);
          for (j=0;j<2048;j++)
          {
            len=0;
            idx=baseidx;
            while ((tree[n][idx]&255)&&(len<11))
            {
              while (((tree[n][idx]>>(8*((j>>(10-len))&1)))&255)>=250)
                idx+=(tree[n][idx]>>(8*((j>>(10-len))&1)))&255;
              idx+=(tree[n][idx]>>(8*((j>>(10-len))&1)))&255;
              len++;
            }
            if (!used[(tree[n][idx]>>12)&0x0f][(tree[n][idx]>>8)&0x0f])
            {
              used[(tree[n][idx]>>12)&0x0f][(tree[n][idx]>>8)&0x0f]=1;
              entry2=(((j>>(11-len))<<16)|(len<<8)|(tree[n][idx]>>8));
              if ((idx2%4)==3)
                fprintf(Out2,"0x%08x,\n",entry2);
              else
                fprintf(Out2,"0x%08x,",entry2);
              idx2++;
            }
          }
        }
        else
          entry=((len<<8)|(tree[n][idx]>>8));
        if ((i%8)==7)
        {
          if (i==255)
            fprintf(Out,"0x%04x",entry);
          else
            fprintf(Out,"0x%04x,\n",entry);
        }
        else
          fprintf(Out,"0x%04x,",entry);
      }
      fprintf(Out,"};\n",n);
      fprintf(Out2,"};\n",n);
    }
  }
  fclose(Out2);
  fclose(Out);
  fclose(In);
  return 0;
}
