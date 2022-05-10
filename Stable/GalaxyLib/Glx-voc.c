/*Ä- Internal revision no. 5.00b  -ÄÄÄ Last revision at  1:46 on 23-09-1999 -ÄÄ

                             The 32 bit LPC C source

                ÛÛÛßßÛÛÛ ÛÛÛßÛÛÛ ÛÛÛ    ÛÛÛßÛÛÛ ÛÛÛ  ÛÛÛ ÛÛÛ ÛÛÛ
                ÛÛÛ  ßßß ÛÛÛ ÛÛÛ ÛÛÛ    ÛÛÛ ÛÛÛ  ßÛÛÛÛß  ÛÛÛ ÛÛÛ
                ÛÛÛ ÜÜÜÜ ÛÛÛÜÛÛÛ ÛÛÛ    ÛÛÛÜÛÛÛ    ÛÛ     ßÛÛÛß
                ÛÛÛ  ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛ    ÛÛÛ ÛÛÛ  ÜÛÛÛÛÜ    ÛÛÛ
                ÛÛÛÜÜÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛÜÜÜ ÛÛÛ ÛÛÛ ÛÛÛ  ÛÛÛ   ÛÛÛ

                               .. MUSIC SYSTEM ..
                This document contains confidential information
                     Copyright (c) 1993-99 Carlo Vogelsang

  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Û²± COPYRIGHT NOTICE ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±²Û³
  ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
  ³ This source file, GLX-VOC.C is Copyright  (c)  1993-99 by Carlo Vogelsang ³
  ³ You may not copy, distribute,  duplicate or clone this file  in any form, ³
  ³ modified or non-modified. It belongs to the author.  By copying this file ³
  ³ you are violating laws and will be punished. I will knock your brains in  ³
  ³ myself or you will be sued to death..                                     ³
  ³                                                                     Carlo ³
  ÀÄ( How the fuck did you get this file anyway? )ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
#include <math.h>
#include <memory.h>
#include "hdr\glx-voc.h"

#define LPCORDER		8
#define FRAMELENGTH		160
#define SUBFRAMELENGTH	40
#define PI				4.0*atan(1.0)

short __inline float2short(float Value)
{
	double temp;
	long i;

	temp=Value+(((65536.0*65536.0*16.0)+(65536.0*65536.0*8.0))*65536.0);
	i=(*((long *)&temp));
	if (i>32767)
		i=32767;
	else if (i<-32768)
		i=-32768;
	return ((short)i);
}

void hammingWindow(short *input,float *output)
{
	static float window[FRAMELENGTH];
	static int initialised=0;
	int i;
	
	if (!initialised)
	{
		//Calculate Hamming window
		for (i=0;i<FRAMELENGTH;i++)
			window[i]=1.0f;//(float)(0.54-0.46*cos((2.0*PI*i)/(FRAMELENGTH-1)));
		//hammingWindow routine initialised
		initialised=1;
	}

	//Apply Hamming window
	for (i=0;i<FRAMELENGTH;i++)
		output[i]=(float)input[i]*window[i];
}

void autoCorrelation(float *input,float *auto_correlation)
{
	int i,j;

	for (i=0;i<LPCORDER+1;i++)
	{
		auto_correlation[i]=0.0f;
		for (j=i;j<FRAMELENGTH;j++)
			auto_correlation[i]+=input[j]*input[j-i];
	}
}

float energyCalculation(float *input,int length)
{
	float energy;
	int i;

	energy=0.0f;
	for (i=0;i<length;i++)
		energy+=input[i]*input[i];
	return energy;
}

void crossCorrelation(float *input1,float *input2,float *cross_correlation)
{
	int i,j;

	for (i=0;i<SUBFRAMELENGTH*2;i++)
	{
		cross_correlation[i]=0.0f;
		for (j=0;j<SUBFRAMELENGTH;j++)
			cross_correlation[i]+=input1[j]*input2[j-i];
	}
}

//This one doesn't work properly!!
float levinsonDurbin(float *auto_correlation,float *lp_coefficient,float *ref_coefficient)
{
	float error=0.0f;
	float tmp;
	int i,j;

	//Clear output arrays
	memset(lp_coefficient,0,LPCORDER*sizeof(float));
	memset(ref_coefficient,0,LPCORDER*sizeof(float));
	if (auto_correlation[0])
	{
		// Set initial error
		error=auto_correlation[0];
		// Iterate
		for (i=0;i<LPCORDER;i++)
		{
			// Sum up this iteration's reflection coefficient
			tmp=auto_correlation[i+1];
			for (j=0;j<i;j++)
				tmp+=auto_correlation[i-j]*lp_coefficient[j];
			ref_coefficient[i]=-tmp/error;
			error*=(1-ref_coefficient[i]*ref_coefficient[i]);
			// Update LP coefficients
			lp_coefficient[i]=ref_coefficient[i];
			for (j=0;j<i/2;j++)
			{
				tmp				      =lp_coefficient[j];
				lp_coefficient[j	] =ref_coefficient[i]*lp_coefficient[i-1-j];
				lp_coefficient[i-1-j]+=ref_coefficient[i]*tmp;
			}
			if (i&1)
				lp_coefficient[j	]+=ref_coefficient[i]*lp_coefficient[j];
		}
	}
	return error;
}

float schur(float *auto_correlation,float *ref_coefficient) 
{
	float G[2][LPCORDER];    
	float r,error=0.0;
    int i,j;  

	//Clear output arrays
	memset(ref_coefficient,0,LPCORDER*sizeof(float));
	if (auto_correlation[0])
	{
		// Set initial error
		error=auto_correlation[0];
		// Initialize the rows of the generator matrix G to auto_correlation[1...p].
		for (i=0;i<LPCORDER;i++) 
			G[0][i]=G[1][i]=auto_correlation[i+1];
		for (i=0;i<LPCORDER;i++) 
		{
			// Calculate this iteration's reflection coefficient and error.
			ref_coefficient[i]=r=-G[1][0]/error;        
			error+=G[1][0]*r;
			// Update the generator matrix.
			for (j=0;j<LPCORDER-i;j++) 
			{
				G[1][j]=G[1][j+1]+r*G[0][j];
				G[0][j]=G[1][j+1]*r+G[0][j];        
			}    
		}
	}
	return error;
}

void lpInterpolate(float *oldlp_coefficient,float *newlp_coefficient,float *lp_coefficient,float weight)
{
	int i;

	for (i=0;i<LPCORDER+1;i++)
		lp_coefficient[i]=(((1.0f-weight)*oldlp_coefficient[i])+((weight)*newlp_coefficient[i]));
}


void lpSynthesisFilter(float *lp_coefficient,float *input,float *output,int length)
{
	static float z[LPCORDER+1];
	int i,j;

	for (i=0;i<length;i++)
	{
		z[0]=input[i];
		for (j=LPCORDER;j>0;j--)
		{
			z[0]-=lp_coefficient[j]*z[j];
			z[j] =z[j-1];
		}
		output[i]=z[0];
	}
}

void refSynthesisFilter(float *ref_coefficient,float *input,float *output,int length)
{
	static float z[LPCORDER+1];
	float temp;
	int i,j;

	for (i=0;i<length;i++)
	{
		temp=input[i];
		for (j=LPCORDER-1;j>=0;j--)
		{
			temp  -=ref_coefficient[j]*z[j];
			z[j+1] =ref_coefficient[j]*temp+z[j];
		}
		output[i]=z[0]=temp;
	}
}

void lpWhiteningFilter(float *lp_coefficient,float *input,float *output,int length)
{
	static float z[LPCORDER+1];
	float temp;
	int i,j;

	for (i=0;i<length;i++)
	{
		z[0]=input[i];
		temp=lp_coefficient[0]*z[0];
		for (j=LPCORDER;j>0;j--)
		{
			temp+=lp_coefficient[j]*z[j];
			z[j] =z[j-1];
		}
		output[i]=temp;
	}
}

void refWhiteningFilter(float *ref_coefficient,float *input,float *output,int length)
{
	static float z[LPCORDER+1];
	float temp,temp2,zj;
	int i,j;

	for (i=0;i<length;i++)
	{
		temp=temp2=input[i];
		for (j=0;j<LPCORDER;j++)
		{
			zj=z[j];
			z[j]=temp2;
			temp2=ref_coefficient[j]*temp+zj;
			temp+=ref_coefficient[j]*zj;
		}
		output[i]=temp;
	}
}

void residualWeighting(float *input,float *output)
{
	float gsm_h[11]={  -0.0163574f,-0.0456542f,0.0f, 0.2507324f, 0.7008056f,
						1.0f,
						0.7008056f, 0.2507324f,0.0f,-0.0456542f,-0.0163574f};
	float work[50];
	float temp;
	int i,j;

	memset(work,0,sizeof(float)*50);
	memcpy(work+5,input,sizeof(float)*40);
	for (i=0;i<SUBFRAMELENGTH;i++)
	{
		temp=0.0f;
		for (j=0;j<11;j++)
			temp+=work[i+j]*gsm_h[j];
		output[i]=temp+0.5f;
	}
}

void packFrame(float *ref_coefficient,int *lag,float *gain,int *grid,float samples[4][13],char *frame)
{
	int i;

	//Pack frame global info
		
	//Pack subframe local info
	for (i=0;i<FRAMELENGTH/SUBFRAMELENGTH;i++)
	{
	


	}
}

void unpackFrame(char *frame,float *ref_coefficient,int *lag,float *gain,int *grid,float samples[4][13])
{
	int i;

	//Unpack frame global info		

	//Unpack subframe local info
	for (i=0;i<FRAMELENGTH/SUBFRAMELENGTH;i++)
	{
	


	}
}

void lpAnalysis(short *input,short *output)
{
	float windowed_input[FRAMELENGTH];
	float temp_output[FRAMELENGTH];
	float auto_correlation[LPCORDER+1];
	static float oldref_coefficient[LPCORDER+1];
	float newref_coefficient[LPCORDER+1];
	float ref_coefficient[LPCORDER+1];
	float residual[FRAMELENGTH];
	float cross_correlation[SUBFRAMELENGTH*2];
	static float past_residual[SUBFRAMELENGTH*3];
	float gain[FRAMELENGTH/SUBFRAMELENGTH];	
	int lag[FRAMELENGTH/SUBFRAMELENGTH];
	int grid[FRAMELENGTH/SUBFRAMELENGTH];
	float samples[FRAMELENGTH/SUBFRAMELENGTH][13];

	float crosscorrelation,energy,maxenergy;
	static int init=0;
	float temp[13];
	char *data;
	int i,j,k;
	
	if (!init)
	{
		memset(past_residual,0,sizeof(float)*SUBFRAMELENGTH*3);
		memset(oldref_coefficient,0,sizeof(float)*(LPCORDER+1));
		init++;
	}

	///////////////////////////////////////////////////////////////////////////////
	//Spectral anlysis based on 8th order Linear Prediction filter, once per frame
	
	//Preprocess input
	hammingWindow(input,windowed_input);
	//Calculate auto-correlation
	autoCorrelation(windowed_input,auto_correlation);
	//Schur or Levinson-Durbin to find reflection and/or prediction coefficients
	schur(auto_correlation,newref_coefficient);
	//Calculate short term residual
	lpInterpolate(oldref_coefficient,newref_coefficient,ref_coefficient,0.25f);
	refWhiteningFilter(ref_coefficient,windowed_input   ,residual   , 13);
	
	lpInterpolate(oldref_coefficient,newref_coefficient,ref_coefficient,0.50f);
	refWhiteningFilter(ref_coefficient,windowed_input+13,residual+13, 14);
	
	lpInterpolate(oldref_coefficient,newref_coefficient,ref_coefficient,0.75f);
	refWhiteningFilter(ref_coefficient,windowed_input+27,residual+27, 13);
	
	lpInterpolate(oldref_coefficient,newref_coefficient,ref_coefficient,1.00f);
	refWhiteningFilter(ref_coefficient,windowed_input+40,residual+40,120);

	///////////////////////////////////////////////////////////////////////////////
	//Handle each subframe
	for (i=0;i<FRAMELENGTH/SUBFRAMELENGTH;i++)
	{
		//Calculate cross correlations between subframe and past two subframes
		crossCorrelation(residual+i*SUBFRAMELENGTH,past_residual+2*SUBFRAMELENGTH,cross_correlation);
		//Find optimal lag through maximum cross correlation
		crosscorrelation=cross_correlation[lag[i]=0];
		for (j=1;j<SUBFRAMELENGTH*2;j++)
			if (crosscorrelation<cross_correlation[j])
				crosscorrelation=cross_correlation[lag[i]=j];
		lag[i]+=SUBFRAMELENGTH;
		//Calculate gain
		energy=energyCalculation(past_residual+3*SUBFRAMELENGTH-lag[i],SUBFRAMELENGTH);
		gain[i]=energy?crosscorrelation/energy:1.0f;
		//Calculate long term residual
		for (j=0;j<SUBFRAMELENGTH;j++)
			residual[i*SUBFRAMELENGTH+j]-=gain[i]*past_residual[3*SUBFRAMELENGTH-lag[i]+j];
		//Weight residual
		residualWeighting(residual+i*SUBFRAMELENGTH,residual+i*SUBFRAMELENGTH);
		//Select proper 13 value sequence by max. energy
		energy=maxenergy=0.0f;
		for (j=0;j<4;j++)
		{
			for (k=0;k<13;k++)
				temp[k]=residual[i*SUBFRAMELENGTH+j+k*3];
			energy=energyCalculation(temp,13);
			if (energy>maxenergy)
			{
				maxenergy=energy;
				grid[i]=j;
			}
		}
		for (j=0;j<13;j++) samples[i][j]=residual[i*SUBFRAMELENGTH+j*3+grid[i]];
		
		//Simulate en/decoding of residual
		for (j=0;j<13;j++)
			temp[j]=residual[i*SUBFRAMELENGTH+j*3+grid[i]];
		memset(residual+i*SUBFRAMELENGTH,0,SUBFRAMELENGTH*sizeof(float));
		for (j=0;j<13;j++)
			residual[i*SUBFRAMELENGTH+j*3+grid[i]]=temp[j];
	
		//Reconstruct short term residual
		for (j=0;j<SUBFRAMELENGTH;j++)
			residual[i*SUBFRAMELENGTH+j]+=gain[i]*past_residual[3*SUBFRAMELENGTH-lag[i]+j];
		//Copy reconstructed subframe into past
		memcpy(past_residual,past_residual+SUBFRAMELENGTH,sizeof(float)*SUBFRAMELENGTH*2);
		memcpy(past_residual+SUBFRAMELENGTH*2,residual+i*SUBFRAMELENGTH,sizeof(float)*SUBFRAMELENGTH);
	
	}

	//Encode frame
	//packFrame(newref_coefficient,lag,gain,grid,samples,data);

	//Dencode frame
	//unpackFrame(data,newref_coefficient,lag,gain,grid,samples);

	//Synthesize output
	lpInterpolate(oldref_coefficient,newref_coefficient,ref_coefficient,0.25f);
	refSynthesisFilter(ref_coefficient,residual   ,temp_output   , 13);

	lpInterpolate(oldref_coefficient,newref_coefficient,ref_coefficient,0.50f);
	refSynthesisFilter(ref_coefficient,residual+13,temp_output+13, 14);
	
	lpInterpolate(oldref_coefficient,newref_coefficient,ref_coefficient,0.75f);
	refSynthesisFilter(ref_coefficient,residual+27,temp_output+27, 13);
	
	lpInterpolate(oldref_coefficient,newref_coefficient,ref_coefficient,1.00f);
	refSynthesisFilter(ref_coefficient,residual+40,temp_output+40,120);
	
	for (i=0;i<FRAMELENGTH;i++)
		output[i]=float2short(temp_output[i]);
	
	memcpy(oldref_coefficient,newref_coefficient,sizeof(float)*(LPCORDER+1));

}
