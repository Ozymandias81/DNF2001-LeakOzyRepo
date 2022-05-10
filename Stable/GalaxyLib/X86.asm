; ƒ- Internal revision no. 5.00b -ƒƒƒƒ Last revision at 13:54 on 31-03-1999 -ƒƒ
;
;                      The 32 bit x86 DSP Assembly source
;
;               €€€ﬂﬂ€€€ €€€ﬂ€€€ €€€    €€€ﬂ€€€ €€€  €€€ €€€ €€€
;               €€€  ﬂﬂﬂ €€€ €€€ €€€    €€€ €€€  ﬂ€€€€ﬂ  €€€ €€€
;               €€€ ‹‹‹‹ €€€‹€€€ €€€    €€€‹€€€    €€     ﬂ€€€ﬂ
;               €€€  €€€ €€€ €€€ €€€    €€€ €€€  ‹€€€€‹    €€€
;               €€€‹‹€€€ €€€ €€€ €€€‹‹‹ €€€ €€€ €€€  €€€   €€€
;
;                               MUSIC SYSTEM 
;               This document contains confidential information
;                    Copyright (c) 1993-98 Carlo Vogelsang
;
; ⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
; ≥€≤± COPYRIGHT NOTICE ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±≤€≥
; √ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥
; ≥ This source file, X86.ASM    is Copyright (c) 1993-99 by Carlo Vogelsang. ≥
; ≥ You may not copy, distribute,  duplicate or clone this file  in any form, ≥
; ≥ modified or non-modified. It belongs to the author.  By copying this file ≥
; ≥ you are violating laws and will be punished. I will knock your brains in  ≥
; ≥ myself or you will be sued to death..                                     ≥
; ≥                                                                     Carlo ≥
; ¿ƒ( How the fuck did you get this file anyway? )ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
;
.486
.MODEL          FLAT

EXTRN C			glxVolumeTableBase : DWord

.CODE

include			hdr\galaxy.ah

;******************************************************************************
;Lightspeed ]I[ mixing routines, x86 optimized, 32 bit signed mono.
;******************************************************************************

x86MixerMono    PROC      NEAR C Dry: DWord, EffectA: DWord, EffectB: DWord, Count: DWord, SampleInt: DWord, SampleFrac: Word, PitchShift: DWord, LeftVolume: Word, RightVolume: Word, LeftEffectA: Word, RightEffectA: Word, LeftEffectB: Word, RightEffectB: Word, Mode: Byte
                pushad

                movzx     ebx,LeftVolume

				add       bx,RightVolume
				mov       esi,SampleInt

				shr		  ebx,3+1
                mov       edi,Dry

                mov       dx,word ptr SampleFrac
				mov		  bh,[ebx+Lin2Log]		

                shl       edx,16
                and       ebx,3f00h                    

                mov       dx,word ptr Count
                mov		  TempESP,esp					

                test      Mode,1                        
                jnz       @@MonoMix16                  

;******************************************************************************
;Lightspeed ]I[ mixing routines, x86 optimized, 8 bit unsigned input samples.
;******************************************************************************

@@MonoMix8:
				mov		  sp,word ptr PitchShift       
                mov       al,Mode

                sal       esp,16
                mov       ebp,PitchShift

				sar		  ebp,16
                mov       ecx,glxVolumeTableBase          

                test      eax,2
                jnz       @@MonoMix8Main2
@@MonoMix8Main1:
                sub       dx,8h
                js        @@MonoMix8End1
@@MonoMix8MainLoop1:
                add       edx,esp
                mov       bl,[esi]

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+0],eax

                add       edx,esp
                mov       bl,[esi]

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+4],eax

                add       edx,esp
                mov       bl,[esi]

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+8],eax

                add       edx,esp
                mov       bl,[esi]

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+12],eax

                add       edx,esp
                mov       bl,[esi]

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+16],eax

                add       edx,esp
                mov       bl,[esi]

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+20],eax

                add       edx,esp
                mov       bl,[esi]

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+24],eax

                add       edx,esp
                mov       bl,[esi]

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+28],eax
                add       edi,32

                sub       dx,8h
                jns       @@MonoMix8MainLoop1
@@MonoMix8End1:
                add       dx,8h-1h
                js        @@MonoMixDone
@@MonoMix8EndLoop1:
                add       edx,esp
                mov       bl,[esi]

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+0],eax
                add       edi,4

                sub       dx,1h
                jns       @@MonoMix8EndLoop1

                jmp       @@MonoMixDone

@@MonoMix8Main2:
                sub       dx,8h
                js        @@MonoMix8End2
@@MonoMix8MainLoop2:
                mov       eax,edx

                shr       eax,20

                mov       al,[esi]

                mov       bl,[eax+eax+0c0dec0deh]
MonoMix8SMC1_2=$
                mov       al,[esi+1]

                add       bl,[eax+eax+0c0dec0deh]
MonoMix8SMC1_3=$
                add       edx,esp

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+0],eax
                mov       eax,edx

                shr       eax,20

                mov       al,[esi]

                mov       bl,[eax+eax+0c0dec0deh]
MonoMix8SMC2_2=$
                mov       al,[esi+1]

                add       bl,[eax+eax+0c0dec0deh]
MonoMix8SMC2_3=$
                add       edx,esp

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+4],eax
                mov       eax,edx

                shr       eax,20

                mov       al,[esi]

                mov       bl,[eax+eax+0c0dec0deh]
MonoMix8SMC3_2=$
                mov       al,[esi+1]

                add       bl,[eax+eax+0c0dec0deh]
MonoMix8SMC3_3=$
                add       edx,esp

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+8],eax
                mov       eax,edx

                shr       eax,20

                mov       al,[esi]

                mov       bl,[eax+eax+0c0dec0deh]
MonoMix8SMC4_2=$
                mov       al,[esi+1]

                add       bl,[eax+eax+0c0dec0deh]
MonoMix8SMC4_3=$
                add       edx,esp

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+12],eax
                mov       eax,edx

                shr       eax,20

                mov       al,[esi]

                mov       bl,[eax+eax+0c0dec0deh]
MonoMix8SMC5_2=$
                mov       al,[esi+1]

                add       bl,[eax+eax+0c0dec0deh]
MonoMix8SMC5_3=$
                add       edx,esp

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+16],eax
                mov       eax,edx

                shr       eax,20

                mov       al,[esi]

                mov       bl,[eax+eax+0c0dec0deh]
MonoMix8SMC6_2=$
                mov       al,[esi+1]

                add       bl,[eax+eax+0c0dec0deh]
MonoMix8SMC6_3=$
                add       edx,esp

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+20],eax
                mov       eax,edx

                shr       eax,20

                mov       al,[esi]

                mov       bl,[eax+eax+0c0dec0deh]
MonoMix8SMC7_2=$
                mov       al,[esi+1]

                add       bl,[eax+eax+0c0dec0deh]
MonoMix8SMC7_3=$
                add       edx,esp

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+24],eax
                mov       eax,edx

                shr       eax,20

                mov       al,[esi]

                mov       bl,[eax+eax+0c0dec0deh]
MonoMix8SMC8_2=$
                mov       al,[esi+1]

                add       bl,[eax+eax+0c0dec0deh]
MonoMix8SMC8_3=$
                add       edx,esp

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+28],eax
                add       edi,32

                sub       dx,8h
                jns       @@MonoMix8MainLoop2
@@MonoMix8End2:
                add       dx,8h-1h
                js        @@MonoMixDone
@@MonoMix8EndLoop2:
                mov       eax,edx

                shr       eax,20

                mov       al,[esi]

                mov       bl,[eax+eax+0c0dec0deh]
MonoMix8SMC9_2=$
                mov       al,[esi+1]

                add       bl,[eax+eax+0c0dec0deh]
MonoMix8SMC9_3=$
                add       edx,esp

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+0],eax
                add       edi,4

                sub       dx,1h
                jns       @@MonoMix8EndLoop2

                jmp       @@MonoMixDone

;******************************************************************************
;Lightspeed ]I[ mixing routines, x86 optimized, 16 bit input samples.
;******************************************************************************

@@MonoMix16:
				mov		  sp,word ptr PitchShift       
                mov       al,Mode

                sal       esp,16
                mov       ebp,PitchShift

				sar		  ebp,16
                mov       ecx,glxVolumeTableBase          

;               test      eax,2
;               jnz       @@MonoMix16Main2
@@MonoMix16Main1:
                sub       dx,8h
                js        @@MonoMix16End1
@@MonoMix16MainLoop1:
                add       edx,esp
                mov       bl,[esi+esi+1]

                mov       eax,[ebx*4+ecx]
                mov       bl,[esi+esi]

                adc       esi,ebp
                add       eax,[ebx*4+ecx+64*1024]

                add       [edi+0],eax

                add       edx,esp
                mov       bl,[esi+esi+1]

                mov       eax,[ebx*4+ecx]
                mov       bl,[esi+esi]

                adc       esi,ebp
                add       eax,[ebx*4+ecx+64*1024]

                add       [edi+4],eax

                add       edx,esp
                mov       bl,[esi+esi+1]

                mov       eax,[ebx*4+ecx]
                mov       bl,[esi+esi]

                adc       esi,ebp
                add       eax,[ebx*4+ecx+64*1024]

                add       [edi+8],eax

                add       edx,esp
                mov       bl,[esi+esi+1]

                mov       eax,[ebx*4+ecx]
                mov       bl,[esi+esi]

                adc       esi,ebp
                add       eax,[ebx*4+ecx+64*1024]

                add       [edi+12],eax

                add       edx,esp
                mov       bl,[esi+esi+1]

                mov       eax,[ebx*4+ecx]
                mov       bl,[esi+esi]

                adc       esi,ebp
                add       eax,[ebx*4+ecx+64*1024]

                add       [edi+16],eax

                add       edx,esp
                mov       bl,[esi+esi+1]

                mov       eax,[ebx*4+ecx]
                mov       bl,[esi+esi]

                adc       esi,ebp
                add       eax,[ebx*4+ecx+64*1024]

                add       [edi+20],eax

                add       edx,esp
                mov       bl,[esi+esi+1]

                mov       eax,[ebx*4+ecx]
                mov       bl,[esi+esi]

                adc       esi,ebp
                add       eax,[ebx*4+ecx+64*1024]

                add       [edi+24],eax

                add       edx,esp
                mov       bl,[esi+esi+1]

                mov       eax,[ebx*4+ecx]
                mov       bl,[esi+esi]

                adc       esi,ebp
                add       eax,[ebx*4+ecx+64*1024]

                add       [edi+28],eax
                add       edi,32

                sub       dx,8h
                jns       @@MonoMix16MainLoop1
@@MonoMix16End1:
                add       dx,8h-1h
                js        @@MonoMixDone
@@MonoMix16EndLoop1:
                add       edx,esp
                mov       bl,[esi+esi+1]

                mov       eax,[ebx*4+ecx]
                mov       bl,[esi+esi]

                adc       esi,ebp
                add       eax,[ebx*4+ecx+64*1024]

                add       [edi+0],eax
                add       edi,4

                sub       dx,1h
                jns       @@MonoMix16EndLoop1
@@MonoMixDone:
				mov		  esp,TempESP

                popad

                ret
x86MixerMono    ENDP

x86MixerMonoSize equ    $-x86MixerMono

;******************************************************************************
;Lightspeed ]I[ mixing routines, x86 optimized, 32 bit stereo.
;******************************************************************************

x86MixerStereo  PROC      NEAR C Dry: DWord, EffectA: DWord, EffectB: DWord, Count: DWord, SampleInt: DWord, SampleFrac: Word, PitchShift: DWord, LeftVolume: Word, RightVolume: Word, LeftEffectA: Word, RightEffectA: Word, LeftEffectB: Word, RightEffectB: Word, Mode: Byte
                pushad

                movzx     ecx,LeftVolume

				shr		  ecx,3							
				mov       esi,SampleInt

                movzx     ebx,RightVolume				

				shr		  ebx,3							
                mov       edi,Dry

                mov       dx,word ptr SampleFrac
				mov		  ch,[ecx+Lin2Log]		

                shl       edx,16
				mov		  bh,[ebx+Lin2Log]				
			
                and       ebx,3f00h                    
                and       ecx,3f00h                     

                mov       dx,word ptr Count
				sub       ecx,ebx                       ; ECX=LeftVol-RightVol

                sal       ecx,2                         ; ECX=(Left-Right)*4
                mov		  TempESP,esp					; Save ESP

                test      Mode,1                        ; Need 16 bit mixing ?
                jnz       @@Mix16                       ; Yope ? Do it..

;******************************************************************************
;Lightspeed ]I[ mixing routines, x86 optimized, 8 bit input samples.
;******************************************************************************

@@Mix8:
				mov		  sp,word ptr PitchShift       
				mov       al,Mode
                
                sal       esp,16
                mov       ebp,PitchShift

				sar		  ebp,16
				add       ecx,glxVolumeTableBase           

                test      eax,4
                jnz       @@Mix8Surround
@@Mix8Normal:
                test      eax,2
                jnz       @@Mix8Main2
@@Mix8Main1:
                sub       dx,8h
                js        @@Mix8End1
@@Mix8MainLoop1:
                add       edx,esp
                mov       bl,[esi]

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+0],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix8SMC1_1=$
                add       [edi+4],eax

                add       edx,esp
                mov       bl,[esi]

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+8],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix8SMC2_1=$
                add       [edi+12],eax

                add       edx,esp
                mov       bl,[esi]

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+16],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix8SMC3_1=$
                add       [edi+20],eax

                add       edx,esp
                mov       bl,[esi]

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+24],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix8SMC4_1=$
                add       [edi+28],eax

                add       edx,esp
                mov       bl,[esi]

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+32],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix8SMC5_1=$
                add       [edi+36],eax

                add       edx,esp
                mov       bl,[esi]

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+40],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix8SMC6_1=$
                add       [edi+44],eax

                add       edx,esp
                mov       bl,[esi]

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+48],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix8SMC7_1=$
                add       [edi+52],eax

                add       edx,esp
                mov       bl,[esi]

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+56],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix8SMC8_1=$
                add       [edi+60],eax
                add       edi,64

                sub       dx,8h
                jns       @@Mix8MainLoop1
@@Mix8End1:
                add       dx,8h-1h
                js        @@Mix8Done
@@Mix8EndLoop1:
                add       edx,esp
                mov       bl,[esi]

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+0],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix8SMC9_1=$
                add       [edi+4],eax
                add       edi,8

                sub       dx,1h
                jns       @@Mix8EndLoop1

                jmp       @@Mix8Done

@@Mix8Main2:
                sub       dx,8h
                js        @@Mix8End2
@@Mix8MainLoop2:
                mov       eax,edx

                shr       eax,20

                mov       al,[esi]

                mov       bl,[eax+eax+0c0dec0deh]
Mix8SMC1_2=$
                mov       al,[esi+1]

                add       bl,[eax+eax+0c0dec0deh]
Mix8SMC1_3=$
                add       edx,esp

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+0],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix8SMC10_1=$
                add       [edi+4],eax
                mov       eax,edx

                shr       eax,20

                mov       al,[esi]

                mov       bl,[eax+eax+0c0dec0deh]
Mix8SMC2_2=$
                mov       al,[esi+1]

                add       bl,[eax+eax+0c0dec0deh]
Mix8SMC2_3=$
                add       edx,esp

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+8],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix8SMC11_1=$
                add       [edi+12],eax
                mov       eax,edx

                shr       eax,20

                mov       al,[esi]

                mov       bl,[eax+eax+0c0dec0deh]
Mix8SMC3_2=$
                mov       al,[esi+1]

                add       bl,[eax+eax+0c0dec0deh]
Mix8SMC3_3=$
                add       edx,esp

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+16],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix8SMC12_1=$
                add       [edi+20],eax
                mov       eax,edx

                shr       eax,20

                mov       al,[esi]

                mov       bl,[eax+eax+0c0dec0deh]
Mix8SMC4_2=$
                mov       al,[esi+1]

                add       bl,[eax+eax+0c0dec0deh]
Mix8SMC4_3=$
                add       edx,esp

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+24],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix8SMC13_1=$
                add       [edi+28],eax
                mov       eax,edx

                shr       eax,20

                mov       al,[esi]

                mov       bl,[eax+eax+0c0dec0deh]
Mix8SMC5_2=$
                mov       al,[esi+1]

                add       bl,[eax+eax+0c0dec0deh]
Mix8SMC5_3=$
                add       edx,esp

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+32],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix8SMC14_1=$
                add       [edi+36],eax
                mov       eax,edx

                shr       eax,20

                mov       al,[esi]

                mov       bl,[eax+eax+0c0dec0deh]
Mix8SMC6_2=$
                mov       al,[esi+1]

                add       bl,[eax+eax+0c0dec0deh]
Mix8SMC6_3=$
                add       edx,esp

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+40],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix8SMC15_1=$
                add       [edi+44],eax
                mov       eax,edx

                shr       eax,20

                mov       al,[esi]

                mov       bl,[eax+eax+0c0dec0deh]
Mix8SMC7_2=$
                mov       al,[esi+1]

                add       bl,[eax+eax+0c0dec0deh]
Mix8SMC7_3=$
                add       edx,esp

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+48],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix8SMC16_1=$
                add       [edi+52],eax
                mov       eax,edx

                shr       eax,20

                mov       al,[esi]

                mov       bl,[eax+eax+0c0dec0deh]
Mix8SMC8_2=$
                mov       al,[esi+1]

                add       bl,[eax+eax+0c0dec0deh]
Mix8SMC8_3=$
                add       edx,esp

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+56],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix8SMC17_1=$
                add       [edi+60],eax
                add       edi,64

                sub       dx,8h
                jns       @@Mix8MainLoop2
@@Mix8End2:
                add       dx,8h-1h
                js        @@Mix8Done
@@Mix8EndLoop2:
                mov       eax,edx

                shr       eax,20

                mov       al,[esi]

                mov       bl,[eax+eax+0c0dec0deh]
Mix8SMC9_2=$
                mov       al,[esi+1]

                add       bl,[eax+eax+0c0dec0deh]
Mix8SMC9_3=$
                add       edx,esp

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+0],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix8SMC18_1=$
                add       [edi+4],eax
                add       edi,8

                sub       dx,1h
                jns       @@Mix8EndLoop2

                jmp       @@Mix8Done

@@Mix8Surround:
                test      eax,2
                jnz       @@Mix8Main4
@@Mix8Main3:
                sub       dx,8h
                js        @@Mix8End3
@@Mix8MainLoop3:
                add       edx,esp
                mov       bl,[esi]

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+0],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix8SMC19_1=$
                sub       [edi+4],eax

                add       edx,esp
                mov       bl,[esi]

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+8],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix8SMC20_1=$
                sub       [edi+12],eax

                add       edx,esp
                mov       bl,[esi]

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+16],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix8SMC21_1=$
                sub       [edi+20],eax

                add       edx,esp
                mov       bl,[esi]

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+24],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix8SMC22_1=$
                sub       [edi+28],eax

                add       edx,esp
                mov       bl,[esi]

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+32],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix8SMC23_1=$
                sub       [edi+36],eax

                add       edx,esp
                mov       bl,[esi]

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+40],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix8SMC24_1=$
                sub       [edi+44],eax

                add       edx,esp
                mov       bl,[esi]

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+48],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix8SMC25_1=$
                sub       [edi+52],eax

                add       edx,esp
                mov       bl,[esi]

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+56],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix8SMC26_1=$
                sub       [edi+60],eax
                add       edi,64

                sub       dx,8h
                jns       @@Mix8MainLoop3
@@Mix8End3:
                add       dx,8h-1h
                js        @@Mix8Done
@@Mix8EndLoop3:
                add       edx,esp
                mov       bl,[esi]

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+0],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix8SMC27_1=$
                sub       [edi+4],eax
                add       edi,8

                sub       dx,1h
                jns       @@Mix8EndLoop3

                jmp       @@Mix8Done

@@Mix8Main4:
                sub       dx,8h
                js        @@Mix8End4
@@Mix8MainLoop4:
                mov       eax,edx

                shr       eax,20

                mov       al,[esi]

                mov       bl,[eax+eax+0c0dec0deh]
Mix8SMC10_2=$
                mov       al,[esi+1]

                add       bl,[eax+eax+0c0dec0deh]
Mix8SMC10_3=$
                add       edx,esp

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+0],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix8SMC28_1=$
                sub       [edi+4],eax

                mov       eax,edx

                shr       eax,20

                mov       al,[esi]

                mov       bl,[eax+eax+0c0dec0deh]
Mix8SMC11_2=$
                mov       al,[esi+1]

                add       bl,[eax+eax+0c0dec0deh]
Mix8SMC11_3=$
                add       edx,esp

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+8],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix8SMC29_1=$
                sub       [edi+12],eax

                mov       eax,edx

                shr       eax,20

                mov       al,[esi]

                mov       bl,[eax+eax+0c0dec0deh]
Mix8SMC12_2=$
                mov       al,[esi+1]

                add       bl,[eax+eax+0c0dec0deh]
Mix8SMC12_3=$
                add       edx,esp

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+16],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix8SMC30_1=$
                sub       [edi+20],eax

                mov       eax,edx

                shr       eax,20

                mov       al,[esi]

                mov       bl,[eax+eax+0c0dec0deh]
Mix8SMC13_2=$
                mov       al,[esi+1]

                add       bl,[eax+eax+0c0dec0deh]
Mix8SMC13_3=$
                add       edx,esp

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+24],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix8SMC31_1=$
                sub       [edi+28],eax

                mov       eax,edx

                shr       eax,20

                mov       al,[esi]

                mov       bl,[eax+eax+0c0dec0deh]
Mix8SMC14_2=$
                mov       al,[esi+1]

                add       bl,[eax+eax+0c0dec0deh]
Mix8SMC14_3=$
                add       edx,esp

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+32],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix8SMC32_1=$
                sub       [edi+36],eax

                mov       eax,edx

                shr       eax,20

                mov       al,[esi]

                mov       bl,[eax+eax+0c0dec0deh]
Mix8SMC15_2=$
                mov       al,[esi+1]

                add       bl,[eax+eax+0c0dec0deh]
Mix8SMC15_3=$
                add       edx,esp

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+40],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix8SMC33_1=$
                sub       [edi+44],eax

                mov       eax,edx

                shr       eax,20

                mov       al,[esi]

                mov       bl,[eax+eax+0c0dec0deh]
Mix8SMC16_2=$
                mov       al,[esi+1]

                add       bl,[eax+eax+0c0dec0deh]
Mix8SMC16_3=$
                add       edx,esp

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+48],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix8SMC34_1=$
                sub       [edi+52],eax

                mov       eax,edx

                shr       eax,20

                mov       al,[esi]

                mov       bl,[eax+eax+0c0dec0deh]
Mix8SMC17_2=$
                mov       al,[esi+1]

                add       bl,[eax+eax+0c0dec0deh]
Mix8SMC17_3=$
                add       edx,esp

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+56],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix8SMC35_1=$
                sub       [edi+60],eax
                add       edi,64

                sub       dx,8h
                jns       @@Mix8MainLoop4
@@Mix8End4:
                add       dx,8h-1h
                js        @@Mix8Done
@@Mix8EndLoop4:
                mov       eax,edx

                shr       eax,20

                mov       al,[esi]

                mov       bl,[eax+eax+0c0dec0deh]
Mix8SMC18_2=$
                mov       al,[esi+1]

                add       bl,[eax+eax+0c0dec0deh]
Mix8SMC18_3=$
                add       edx,esp

                adc       esi,ebp
                mov       eax,[ebx*4+ecx]

                add       [edi+0],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix8SMC36_1=$
                sub       [edi+4],eax
                add       edi,8

                sub       dx,1h
                jns       @@Mix8EndLoop4
@@Mix8Done:
				mov		  esp,TempESP

                popad

                ret

;******************************************************************************
;Lightspeed ]I[ mixing routines, x86 optimized, 16 bit input samples.
;******************************************************************************

@@Mix16:
				mov		  sp,word ptr PitchShift       
                mov       al,Mode

                sal       esp,16
                mov       ebp,PitchShift

				sar		  ebp,16
				add       ecx,glxVolumeTableBase           

                test      eax,4
                jnz       @@Mix16Surround
@@Mix16Normal:
;               test      eax,2
;               jnz       @@Mix16Main2
@@Mix16Main1:
                sub       dx,8h
                js        @@Mix16End1
@@Mix16MainLoop1:
                mov       bl,[esi+esi+1]

                mov       eax,[ebx*4+ecx]

                add       [edi+0],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix16SMC1_1=$
                add       edx,esp
                mov       bl,[esi+esi]

                adc       esi,ebp
                add       eax,[ebx*4+0c0dec0deh]
Mix16SMC1_4=$
                add       [edi+4],eax
                mov       eax,[ebx*4+ecx+64*1024]

                add       [edi+0],eax

                mov       bl,[esi+esi+1]

                mov       eax,[ebx*4+ecx]

                add       [edi+8],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix16SMC2_1=$
                add       edx,esp
                mov       bl,[esi+esi]

                adc       esi,ebp
                add       eax,[ebx*4+0c0dec0deh]
Mix16SMC2_4=$
                add       [edi+12],eax
                mov       eax,[ebx*4+ecx+64*1024]

                add       [edi+8],eax

                mov       bl,[esi+esi+1]

                mov       eax,[ebx*4+ecx]

                add       [edi+16],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix16SMC3_1=$
                add       edx,esp
                mov       bl,[esi+esi]

                adc       esi,ebp
                add       eax,[ebx*4+0c0dec0deh]
Mix16SMC3_4=$
                add       [edi+20],eax
                mov       eax,[ebx*4+ecx+64*1024]

                add       [edi+16],eax

                mov       bl,[esi+esi+1]

                mov       eax,[ebx*4+ecx]

                add       [edi+24],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix16SMC4_1=$
                add       edx,esp
                mov       bl,[esi+esi]

                adc       esi,ebp
                add       eax,[ebx*4+0c0dec0deh]
Mix16SMC4_4=$
                add       [edi+28],eax
                mov       eax,[ebx*4+ecx+64*1024]

                add       [edi+24],eax

                mov       bl,[esi+esi+1]

                mov       eax,[ebx*4+ecx]

                add       [edi+32],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix16SMC5_1=$
                add       edx,esp
                mov       bl,[esi+esi]

                adc       esi,ebp
                add       eax,[ebx*4+0c0dec0deh]
Mix16SMC5_4=$
                add       [edi+36],eax
                mov       eax,[ebx*4+ecx+64*1024]

                add       [edi+32],eax

                mov       bl,[esi+esi+1]

                mov       eax,[ebx*4+ecx]

                add       [edi+40],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix16SMC6_1=$
                add       edx,esp
                mov       bl,[esi+esi]

                adc       esi,ebp
                add       eax,[ebx*4+0c0dec0deh]
Mix16SMC6_4=$
                add       [edi+44],eax
                mov       eax,[ebx*4+ecx+64*1024]

                add       [edi+40],eax

                mov       bl,[esi+esi+1]

                mov       eax,[ebx*4+ecx]

                add       [edi+48],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix16SMC7_1=$
                add       edx,esp
                mov       bl,[esi+esi]

                adc       esi,ebp
                add       eax,[ebx*4+0c0dec0deh]
Mix16SMC7_4=$
                add       [edi+52],eax
                mov       eax,[ebx*4+ecx+64*1024]

                add       [edi+48],eax

                mov       bl,[esi+esi+1]

                mov       eax,[ebx*4+ecx]

                add       [edi+56],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix16SMC8_1=$
                add       edx,esp
                mov       bl,[esi+esi]

                adc       esi,ebp
                add       eax,[ebx*4+0c0dec0deh]
Mix16SMC8_4=$
                add       [edi+60],eax
                mov       eax,[ebx*4+ecx+64*1024]

                add       [edi+56],eax
                add       edi,64

                sub       dx,8h
                jns       @@Mix16MainLoop1
@@Mix16End1:
                add       dx,8h-1h
                js        @@Mix16Done
@@Mix16EndLoop1:
                mov       bl,[esi+esi+1]

                mov       eax,[ebx*4+ecx]

                add       [edi+0],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix16SMC9_1=$
                add       edx,esp
                mov       bl,[esi+esi]

                adc       esi,ebp
                add       eax,[ebx*4+0c0dec0deh]
Mix16SMC9_4=$
                add       [edi+4],eax
                mov       eax,[ebx*4+ecx+64*256*4]

                add       [edi+0],eax
                add       edi,8

                sub       dx,1h
                jns       @@Mix16EndLoop1

                jmp       @@Mix16Done

@@Mix16Surround:
;               test      eax,2
;               jnz       @@Mix16Main4
@@Mix16Main3:
                sub       dx,8h
                js        @@Mix16End3
@@Mix16MainLoop3:
                mov       bl,[esi+esi+1]

                mov       eax,[ebx*4+ecx]

                add       [edi+0],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix16SMC19_1=$
                add       edx,esp
                mov       bl,[esi+esi]

                adc       esi,ebp
                add       eax,[ebx*4+0c0dec0deh]
Mix16SMC19_4=$
                sub       [edi+4],eax
                mov       eax,[ebx*4+ecx+64*1024]

                add       [edi+0],eax

                mov       bl,[esi+esi+1]

                mov       eax,[ebx*4+ecx]

                add       [edi+8],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix16SMC20_1=$
                add       edx,esp
                mov       bl,[esi+esi]

                adc       esi,ebp
                add       eax,[ebx*4+0c0dec0deh]
Mix16SMC20_4=$
                sub       [edi+12],eax
                mov       eax,[ebx*4+ecx+64*1024]

                add       [edi+8],eax

                mov       bl,[esi+esi+1]

                mov       eax,[ebx*4+ecx]

                add       [edi+16],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix16SMC21_1=$
                add       edx,esp
                mov       bl,[esi+esi]

                adc       esi,ebp
                add       eax,[ebx*4+0c0dec0deh]
Mix16SMC21_4=$
                sub       [edi+20],eax
                mov       eax,[ebx*4+ecx+64*1024]

                add       [edi+16],eax

                mov       bl,[esi+esi+1]

                mov       eax,[ebx*4+ecx]

                add       [edi+24],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix16SMC22_1=$
                add       edx,esp
                mov       bl,[esi+esi]

                adc       esi,ebp
                add       eax,[ebx*4+0c0dec0deh]
Mix16SMC22_4=$
                sub       [edi+28],eax
                mov       eax,[ebx*4+ecx+64*1024]

                add       [edi+24],eax

                mov       bl,[esi+esi+1]

                mov       eax,[ebx*4+ecx]

                add       [edi+32],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix16SMC23_1=$
                add       edx,esp
                mov       bl,[esi+esi]

                adc       esi,ebp
                add       eax,[ebx*4+0c0dec0deh]
Mix16SMC23_4=$
                sub       [edi+36],eax
                mov       eax,[ebx*4+ecx+64*1024]

                add       [edi+32],eax

                mov       bl,[esi+esi+1]

                mov       eax,[ebx*4+ecx]

                add       [edi+40],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix16SMC24_1=$
                add       edx,esp
                mov       bl,[esi+esi]

                adc       esi,ebp
                add       eax,[ebx*4+0c0dec0deh]
Mix16SMC24_4=$
                sub       [edi+44],eax
                mov       eax,[ebx*4+ecx+64*1024]

                add       [edi+40],eax

                mov       bl,[esi+esi+1]

                mov       eax,[ebx*4+ecx]

                add       [edi+48],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix16SMC25_1=$
                add       edx,esp
                mov       bl,[esi+esi]

                adc       esi,ebp
                add       eax,[ebx*4+0c0dec0deh]
Mix16SMC25_4=$
                sub       [edi+52],eax
                mov       eax,[ebx*4+ecx+64*1024]

                add       [edi+48],eax

                mov       bl,[esi+esi+1]

                mov       eax,[ebx*4+ecx]

                add       [edi+56],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix16SMC26_1=$
                add       edx,esp
                mov       bl,[esi+esi]

                adc       esi,ebp
                add       eax,[ebx*4+0c0dec0deh]
Mix16SMC26_4=$
                sub       [edi+60],eax
                mov       eax,[ebx*4+ecx+64*1024]

                add       [edi+56],eax
                add       edi,64

                sub       dx,8h
                jns       @@Mix16MainLoop3
@@Mix16End3:
                add       dx,8h-1h
                js        @@Mix16Done
@@Mix16EndLoop3:
                mov       bl,[esi+esi+1]

                mov       eax,[ebx*4+ecx]

                add       [edi+0],eax
                mov       eax,[ebx*4+0c0dec0deh]
Mix16SMC27_1=$
                add       edx,esp
                mov       bl,[esi+esi]

                adc       esi,ebp
                add       eax,[ebx*4+0c0dec0deh]
Mix16SMC27_4=$
                sub       [edi+4],eax
                mov       eax,[ebx*4+ecx+64*256*4]

                add       [edi+0],eax
                add       edi,8

                sub       dx,1h
                jns       @@Mix16EndLoop3
@@Mix16Done:
				mov		  esp,TempESP

				popad

                ret
x86MixerStereo  ENDP

x86MixerStereoSize equ    $-x86MixerStereo

;******************************************************************************
;Lightspeed ]I[ digital effects routines, x86 optimized, 24 bit input samples.
;******************************************************************************

x86Reverb		PROC	  NEAR C DSPDestBuffer: DWord, DSPSourceBuffer, DSPBufferSize: DWord
				pushad

				popad
				ret
x86Reverb		ENDP

;******************************************************************************
;Lightspeed ]I[ post process routines, x86 optimized, 24 bit input samples.
;******************************************************************************

                EXTRN C   glxPostProcTable : DWord

x86Convert      PROC      NEAR C InBuffer: DWord, InCount: DWord, OutBuffer: DWord, Mode: Byte
                pushad

                mov       al,Mode
                mov       esi,InBuffer

                mov       cl,al
                mov       edi,OutBuffer

                and       cl,1
                mov       ebp,InCount

                shl       ebp,cl
                mov       edx,glxPostProcTable

				test	  ebp,ebp
				jz		  @@Conv32Done	

				test	  al,64							; Add to output ?
				jz		  @@okthen2	

				push	  eax 
				push	  edx		
				push	  ebp
				
			    xor		  ecx,ecx						; Source
				xor		  edx,edx						; Dest

				test	  al,2							; 16 bit output ?								
				jnz		  @@loadbuffer16	

@@loadbuffer8:	xor		  eax,eax
				;nop
				
				mov		  al,[edi+ecx]
				add		  ecx,1

				sub		  eax,80h
				;nop

				sal		  eax,8+8
				;nop

				add		  dword ptr [esi+edx],eax
				add		  edx,4

				sub		  ebp,1h
				jnz		  @@loadbuffer8

				jmp		  @@loaddone

@@loadbuffer16:	movsx	  eax,word ptr [edi+ecx]	
				add		  ecx,2
				
				sal		  eax,8	

				add		  dword ptr [esi+edx],eax
				add		  edx,4	
		
				sub		  ebp,1h
				jnz		  @@loadbuffer16
				
@@loaddone:		pop		  ebp 
				pop		  edx	
				pop		  eax

@@okthen2:      test      al,2
                jnz       @@Conv32Main2
@@Conv32Main1:
                sub       ebp,8h
                js        @@Conv32End1

                mov		  ebx,[esi]
				nop
				
				sar		  ebx,16
				mov       ecx,[esi+4]

@@Conv32MainLoop1:
				sar		  ecx,16
				xor		  eax,eax

				mov		  al,[ebx+edx+1000h]
				mov		  ebx,[esi+8]

				sar		  ebx,16
				mov		  ah,[ecx+edx+1000h]

				mov		  [edi+0],ax
				mov		  ecx,[esi+12]

				sar		  ecx,16
				xor		  eax,eax

				mov		  al,[ebx+edx+1000h]
				mov		  ebx,[esi+16]

				sar		  ebx,16
				mov		  ah,[ecx+edx+1000h]

				mov		  [edi+2],ax
				mov		  ecx,[esi+20]

				sar		  ecx,16
				xor		  eax,eax

				mov		  al,[ebx+edx+1000h]
				mov		  ebx,[esi+24]

				sar		  ebx,16
				mov		  ah,[ecx+edx+1000h]

				mov		  [edi+4],ax
				mov		  ecx,[esi+28]

				sar		  ecx,16
				xor		  eax,eax

				mov		  al,[ebx+edx+1000h]
				mov		  ebx,[esi+32]

				sar		  ebx,16
				mov		  ah,[ecx+edx+1000h]

				mov		  [edi+6],ax
				mov		  ecx,[esi+36]

				add		  esi,32
				add		  edi,8	

                sub       ebp,8h
                jns       @@Conv32MainLoop1
@@Conv32End1:
                add       ebp,8h-1h
                js        @@Conv32Done
@@Conv32EndLoop1:
				mov       ebx,[esi]
				add		  esi,4	

				sar		  ebx,16	
			   ;nop

				mov		  al,[ebx+edx+1000h]
			   ;nop

			    mov		  [edi],al
				inc		  edi					
          
                sub       ebp,1h
                jns       @@Conv32EndLoop1

                jmp       @@Conv32Done

@@Conv32Main2:
                sub       ebp,8h
                js        @@Conv32End2

                mov       ebx,[esi]
			   ;nop

			    add		  ebx,1 SHL 7
			   ;nop
@@Conv32MainLoop2:
			   ;nop	
				mov		  eax,ebx

				sar		  ebx,16
 			   ;nop
							
				sar       eax,8
  			    mov		  ecx,[esi+4]

				mov		  ah,[ebx+edx+1000h]
				add		  ecx,1 SHL 7

				mov		  [edi],ax
				mov		  eax,ecx

				sar		  ecx,16
 			   ;nop
							
				sar       eax,8
 			    mov       ebx,[esi+8]

				mov		  ah,[ecx+edx+1000h]
				add		  ebx,1 SHL 7 

				mov		  [edi+2],ax
				mov		  eax,ebx

				sar		  ebx,16
			   ;nop
							
				sar       eax,8
 			    mov		  ecx,[esi+12]

				mov		  ah,[ebx+edx+1000h]
				add		  ecx,1 SHL 7 

				mov		  [edi+4],ax
				mov		  eax,ecx
 
				sar		  ecx,16
			   ;nop
							
				sar       eax,8
 			    mov		  ebx,[esi+16]

				mov		  ah,[ecx+edx+1000h]
				add		  ebx,1 SHL 7

				mov		  [edi+6],ax
				mov		  eax,ebx

				sar		  ebx,16
 			   ;nop
							
				sar       eax,8
 			    mov       ecx,[esi+20]

				mov		  ah,[ebx+edx+1000h]
				add		  ecx,1 SHL 7 

				mov		  [edi+8],ax
				mov		  eax,ecx

				sar		  ecx,16
			   ;nop
							
				sar       eax,8
 			    mov		  ebx,[esi+24]

				mov		  ah,[ecx+edx+1000h]
				add		  ebx,1 SHL 7
				
				mov		  [edi+10],ax
				mov		  eax,ebx

				sar		  ebx,16
			   ;nop
							
				sar       eax,8
 			    mov		  ecx,[esi+28]

				mov		  ah,[ebx+edx+1000h]
				add		  ecx,1 SHL 7  

				mov		  [edi+12],ax
				mov		  eax,ecx

				sar		  ecx,16
   			   ;nop
							
				sar       eax,8
   			    mov		  ebx,[esi+32]

				mov		  ah,[ecx+edx+1000h]
				add		  ebx,1 SHL 7  

				mov		  [edi+14],ax
  			   ;nop

				add       esi,32
                add       edi,16

                sub       ebp,8h
                jns       @@Conv32MainLoop2
@@Conv32End2:
                add       ebp,8h-1h
                js        @@Conv32Done
@@Conv32EndLoop2:
				mov		  ebx,[esi]
			   ;nop	
				
				add		  ebx,1 SHL 7
				add		  esi,4

				mov		  eax,ebx
			   ;nop

				sar		  ebx,16
			   ;nop
							
				sar       eax,8
 			   ;nop

				mov		  ah,[ebx+edx+1000h]
			   ;nop

				mov		  [edi],ax
				add		  edi,2
                
                sub       ebp,1h
                jns       @@Conv32EndLoop2
@@Conv32Done:
                popad

                ret
x86Convert      ENDP

x86ConvertSize  equ       $-x86Convert

;******************************************************************************
;Lightspeed ]I[ mixing init. routines, x86 optimized.
;******************************************************************************

                PUBLIC C  x86MixerInit

x86MixerInit    PROC      NEAR C MixType: Byte,VolumeBase: DWord,MixerBase: DWord
                push      ebx
                push      ecx
                push      edx
                push      esi
                push      edi
                test      [MixType],1
                jnz       @@x86StereoSetup
@@x86MonoSetup:
                cld
                mov       eax,[VolumeBase]
                mov       ebx,[MixerBase]
                mov       ecx,x86MixerMonoSize
                mov       esi,offset x86MixerMono
                mov       edi,ebx
                rep       movsb
                sub       ebx,offset x86MixerMono
;               mov       [ebx+offset MonoMix8SMC1_1-4],eax
                add       eax,64*256*4+64*256*4+2*16*256
                mov       [ebx+offset MonoMix8SMC1_2-4],eax
                mov       [ebx+offset MonoMix8SMC2_2-4],eax
                mov       [ebx+offset MonoMix8SMC3_2-4],eax
                mov       [ebx+offset MonoMix8SMC4_2-4],eax
                mov       [ebx+offset MonoMix8SMC5_2-4],eax
                mov       [ebx+offset MonoMix8SMC6_2-4],eax
                mov       [ebx+offset MonoMix8SMC7_2-4],eax
                mov       [ebx+offset MonoMix8SMC8_2-4],eax
                mov       [ebx+offset MonoMix8SMC9_2-4],eax
                inc       eax
                mov       [ebx+offset MonoMix8SMC1_3-4],eax
                mov       [ebx+offset MonoMix8SMC2_3-4],eax
                mov       [ebx+offset MonoMix8SMC3_3-4],eax
                mov       [ebx+offset MonoMix8SMC4_3-4],eax
                mov       [ebx+offset MonoMix8SMC5_3-4],eax
                mov       [ebx+offset MonoMix8SMC6_3-4],eax
                mov       [ebx+offset MonoMix8SMC7_3-4],eax
                mov       [ebx+offset MonoMix8SMC8_3-4],eax
                mov       [ebx+offset MonoMix8SMC9_3-4],eax
                mov       eax,edi
                mov       ecx,x86ConvertSize
                mov       esi,offset x86Convert
                rep       movsb
                pop       edi
                pop       esi
                pop       edx
                pop       ecx
                pop       ebx
                ret
@@x86StereoSetup:
                cld
                mov       eax,[VolumeBase]
                mov       ebx,[MixerBase]
                mov       ecx,x86MixerStereoSize
                mov       esi,offset x86MixerStereo
                mov       edi,ebx
                rep       movsb
                sub       ebx,offset x86MixerStereo
                mov       [ebx+offset Mix8SMC1_1-4],eax
                mov       [ebx+offset Mix8SMC2_1-4],eax
                mov       [ebx+offset Mix8SMC3_1-4],eax
                mov       [ebx+offset Mix8SMC4_1-4],eax
                mov       [ebx+offset Mix8SMC5_1-4],eax
                mov       [ebx+offset Mix8SMC6_1-4],eax
                mov       [ebx+offset Mix8SMC7_1-4],eax
                mov       [ebx+offset Mix8SMC8_1-4],eax
                mov       [ebx+offset Mix8SMC9_1-4],eax
                mov       [ebx+offset Mix8SMC10_1-4],eax
                mov       [ebx+offset Mix8SMC11_1-4],eax
                mov       [ebx+offset Mix8SMC12_1-4],eax
                mov       [ebx+offset Mix8SMC13_1-4],eax
                mov       [ebx+offset Mix8SMC14_1-4],eax
                mov       [ebx+offset Mix8SMC15_1-4],eax
                mov       [ebx+offset Mix8SMC16_1-4],eax
                mov       [ebx+offset Mix8SMC17_1-4],eax
                mov       [ebx+offset Mix8SMC18_1-4],eax
                mov       [ebx+offset Mix8SMC19_1-4],eax
                mov       [ebx+offset Mix8SMC20_1-4],eax
                mov       [ebx+offset Mix8SMC21_1-4],eax
                mov       [ebx+offset Mix8SMC22_1-4],eax
                mov       [ebx+offset Mix8SMC23_1-4],eax
                mov       [ebx+offset Mix8SMC24_1-4],eax
                mov       [ebx+offset Mix8SMC25_1-4],eax
                mov       [ebx+offset Mix8SMC26_1-4],eax
                mov       [ebx+offset Mix8SMC27_1-4],eax
                mov       [ebx+offset Mix8SMC28_1-4],eax
                mov       [ebx+offset Mix8SMC29_1-4],eax
                mov       [ebx+offset Mix8SMC30_1-4],eax
                mov       [ebx+offset Mix8SMC31_1-4],eax
                mov       [ebx+offset Mix8SMC32_1-4],eax
                mov       [ebx+offset Mix8SMC33_1-4],eax
                mov       [ebx+offset Mix8SMC34_1-4],eax
                mov       [ebx+offset Mix8SMC35_1-4],eax
                mov       [ebx+offset Mix8SMC36_1-4],eax
                mov       [ebx+offset Mix16SMC1_1-4],eax
                mov       [ebx+offset Mix16SMC2_1-4],eax
                mov       [ebx+offset Mix16SMC3_1-4],eax
                mov       [ebx+offset Mix16SMC4_1-4],eax
                mov       [ebx+offset Mix16SMC5_1-4],eax
                mov       [ebx+offset Mix16SMC6_1-4],eax
                mov       [ebx+offset Mix16SMC7_1-4],eax
                mov       [ebx+offset Mix16SMC8_1-4],eax
                mov       [ebx+offset Mix16SMC9_1-4],eax
                mov       [ebx+offset Mix16SMC19_1-4],eax
                mov       [ebx+offset Mix16SMC20_1-4],eax
                mov       [ebx+offset Mix16SMC21_1-4],eax
                mov       [ebx+offset Mix16SMC22_1-4],eax
                mov       [ebx+offset Mix16SMC23_1-4],eax
                mov       [ebx+offset Mix16SMC24_1-4],eax
                mov       [ebx+offset Mix16SMC25_1-4],eax
                mov       [ebx+offset Mix16SMC26_1-4],eax
                mov       [ebx+offset Mix16SMC27_1-4],eax
                add       eax,64*256*4
                mov       [ebx+offset Mix16SMC1_4-4],eax
                mov       [ebx+offset Mix16SMC2_4-4],eax
                mov       [ebx+offset Mix16SMC3_4-4],eax
                mov       [ebx+offset Mix16SMC4_4-4],eax
                mov       [ebx+offset Mix16SMC5_4-4],eax
                mov       [ebx+offset Mix16SMC6_4-4],eax
                mov       [ebx+offset Mix16SMC7_4-4],eax
                mov       [ebx+offset Mix16SMC8_4-4],eax
                mov       [ebx+offset Mix16SMC9_4-4],eax
                mov       [ebx+offset Mix16SMC19_4-4],eax
                mov       [ebx+offset Mix16SMC20_4-4],eax
                mov       [ebx+offset Mix16SMC21_4-4],eax
                mov       [ebx+offset Mix16SMC22_4-4],eax
                mov       [ebx+offset Mix16SMC23_4-4],eax
                mov       [ebx+offset Mix16SMC24_4-4],eax
                mov       [ebx+offset Mix16SMC25_4-4],eax
                mov       [ebx+offset Mix16SMC26_4-4],eax
                mov       [ebx+offset Mix16SMC27_4-4],eax
                add       eax,64*256*4+2*16*256
                mov       [ebx+offset Mix8SMC1_2-4],eax
                mov       [ebx+offset Mix8SMC2_2-4],eax
                mov       [ebx+offset Mix8SMC3_2-4],eax
                mov       [ebx+offset Mix8SMC4_2-4],eax
                mov       [ebx+offset Mix8SMC5_2-4],eax
                mov       [ebx+offset Mix8SMC6_2-4],eax
                mov       [ebx+offset Mix8SMC7_2-4],eax
                mov       [ebx+offset Mix8SMC8_2-4],eax
                mov       [ebx+offset Mix8SMC9_2-4],eax
                mov       [ebx+offset Mix8SMC10_2-4],eax
                mov       [ebx+offset Mix8SMC11_2-4],eax
                mov       [ebx+offset Mix8SMC12_2-4],eax
                mov       [ebx+offset Mix8SMC13_2-4],eax
                mov       [ebx+offset Mix8SMC14_2-4],eax
                mov       [ebx+offset Mix8SMC15_2-4],eax
                mov       [ebx+offset Mix8SMC16_2-4],eax
                mov       [ebx+offset Mix8SMC17_2-4],eax
                mov       [ebx+offset Mix8SMC18_2-4],eax
                inc       eax
                mov       [ebx+offset Mix8SMC1_3-4],eax
                mov       [ebx+offset Mix8SMC2_3-4],eax
                mov       [ebx+offset Mix8SMC3_3-4],eax
                mov       [ebx+offset Mix8SMC4_3-4],eax
                mov       [ebx+offset Mix8SMC5_3-4],eax
                mov       [ebx+offset Mix8SMC6_3-4],eax
                mov       [ebx+offset Mix8SMC7_3-4],eax
                mov       [ebx+offset Mix8SMC8_3-4],eax
                mov       [ebx+offset Mix8SMC9_3-4],eax
                mov       [ebx+offset Mix8SMC10_3-4],eax
                mov       [ebx+offset Mix8SMC11_3-4],eax
                mov       [ebx+offset Mix8SMC12_3-4],eax
                mov       [ebx+offset Mix8SMC13_3-4],eax
                mov       [ebx+offset Mix8SMC14_3-4],eax
                mov       [ebx+offset Mix8SMC15_3-4],eax
                mov       [ebx+offset Mix8SMC16_3-4],eax
                mov       [ebx+offset Mix8SMC17_3-4],eax
                mov       [ebx+offset Mix8SMC18_3-4],eax
                mov       eax,edi
                mov       ecx,x86ConvertSize
                mov       esi,offset x86Convert
                rep       movsb
                pop       edi
                pop       esi
                pop       edx
                pop       ecx
                pop       ebx
                ret
x86MixerInit    ENDP

;******************************************************************************
;Lightspeed ]I[ mixing init. routines, x86 optimized.
;******************************************************************************

                PUBLIC C  x86EffectsInit

x86EffectsInit  PROC      NEAR C MixType: Byte,VolumeBase: DWord,EfxBase: DWord,EfxDesc: DWord
                pushad
                popad
                ret
x86EffectsInit  ENDP

.DATA

TempEBP			dd		  0
TempESP			dd		  0

Lin2Log 		db        0, 1, 1, 1, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3
				db        4, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5
				db        5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
				db        6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7
				db        8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8
				db        8, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
				db        9, 9, 9, 9,10,10,10,10,10,10,10,10,10,10,10,10
				db       10,10,10,10,10,10,10,10,10,11,11,11,11,11,11,11
				db       11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11
				db       12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12
				db       12,12,12,12,12,12,12,12,12,13,13,13,13,13,13,13
				db       13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13
				db       13,13,13,13,14,14,14,14,14,14,14,14,14,14,14,14
				db       14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14
				db       14,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15
				db       15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15
				db       16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16
				db       16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16
				db       16,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17
				db       17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17
				db       17,17,17,17,18,18,18,18,18,18,18,18,18,18,18,18
				db       18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18
				db       18,18,18,18,18,18,18,18,18,19,19,19,19,19,19,19
				db       19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19
				db       19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19
				db       20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20
				db       20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20
				db       20,20,20,20,20,20,20,20,20,21,21,21,21,21,21,21
				db       21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21
				db       21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21
				db       21,21,21,21,22,22,22,22,22,22,22,22,22,22,22,22
				db       22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22
				db       22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22
				db       22,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23
				db       23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23
				db       23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23
				db       24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24
				db       24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24
				db       24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24
				db       24,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25
				db       25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25
				db       25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25
				db       25,25,25,25,26,26,26,26,26,26,26,26,26,26,26,26
				db       26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26
				db       26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26
				db       26,26,26,26,26,26,26,26,26,27,27,27,27,27,27,27
				db       27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27
				db       27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27
				db       27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27
				db       28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28
				db       28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28
				db       28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28
				db       28,28,28,28,28,28,28,28,28,29,29,29,29,29,29,29
				db       29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29
				db       29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29
				db       29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29
				db       29,29,29,29,30,30,30,30,30,30,30,30,30,30,30,30
				db       30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30
				db       30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30
				db       30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30
				db       30,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31
				db       31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31
				db       31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31
				db       31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31
				db       32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
				db       32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
				db       32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
				db       32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
				db       32,33,33,33,33,33,33,33,33,33,33,33,33,33,33,33
				db       33,33,33,33,33,33,33,33,33,33,33,33,33,33,33,33
				db       33,33,33,33,33,33,33,33,33,33,33,33,33,33,33,33
				db       33,33,33,33,33,33,33,33,33,33,33,33,33,33,33,33
				db       33,33,33,33,34,34,34,34,34,34,34,34,34,34,34,34
				db       34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34
				db       34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34
				db       34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34
				db       34,34,34,34,34,34,34,34,34,35,35,35,35,35,35,35
				db       35,35,35,35,35,35,35,35,35,35,35,35,35,35,35,35
				db       35,35,35,35,35,35,35,35,35,35,35,35,35,35,35,35
				db       35,35,35,35,35,35,35,35,35,35,35,35,35,35,35,35
				db       35,35,35,35,35,35,35,35,35,35,35,35,35,35,35,35
				db       36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36
				db       36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36
				db       36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36
				db       36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36
				db       36,36,36,36,36,36,36,36,36,37,37,37,37,37,37,37
				db       37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37
				db       37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37
				db       37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37
				db       37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37
				db       37,37,37,37,38,38,38,38,38,38,38,38,38,38,38,38
				db       38,38,38,38,38,38,38,38,38,38,38,38,38,38,38,38
				db       38,38,38,38,38,38,38,38,38,38,38,38,38,38,38,38
				db       38,38,38,38,38,38,38,38,38,38,38,38,38,38,38,38
				db       38,38,38,38,38,38,38,38,38,38,38,38,38,38,38,38
				db       38,39,39,39,39,39,39,39,39,39,39,39,39,39,39,39
				db       39,39,39,39,39,39,39,39,39,39,39,39,39,39,39,39
				db       39,39,39,39,39,39,39,39,39,39,39,39,39,39,39,39
				db       39,39,39,39,39,39,39,39,39,39,39,39,39,39,39,39
				db       39,39,39,39,39,39,39,39,39,39,39,39,39,39,39,39
				db       40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40
				db       40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40
				db       40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40
				db       40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40
				db       40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40
				db       40,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41
				db       41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41
				db       41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41
				db       41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41
				db       41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41
				db       41,41,41,41,42,42,42,42,42,42,42,42,42,42,42,42
				db       42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42
				db       42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42
				db       42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42
				db       42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42
				db       42,42,42,42,42,42,42,42,42,43,43,43,43,43,43,43
				db       43,43,43,43,43,43,43,43,43,43,43,43,43,43,43,43
				db       43,43,43,43,43,43,43,43,43,43,43,43,43,43,43,43
				db       43,43,43,43,43,43,43,43,43,43,43,43,43,43,43,43
				db       43,43,43,43,43,43,43,43,43,43,43,43,43,43,43,43
				db       43,43,43,43,43,43,43,43,43,43,43,43,43,43,43,43
				db       44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44
				db       44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44
				db       44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44
				db       44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44
				db       44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44
				db       44,44,44,44,44,44,44,44,44,45,45,45,45,45,45,45
				db       45,45,45,45,45,45,45,45,45,45,45,45,45,45,45,45
				db       45,45,45,45,45,45,45,45,45,45,45,45,45,45,45,45
				db       45,45,45,45,45,45,45,45,45,45,45,45,45,45,45,45
				db       45,45,45,45,45,45,45,45,45,45,45,45,45,45,45,45
				db       45,45,45,45,45,45,45,45,45,45,45,45,45,45,45,45
				db       45,45,45,45,46,46,46,46,46,46,46,46,46,46,46,46
				db       46,46,46,46,46,46,46,46,46,46,46,46,46,46,46,46
				db       46,46,46,46,46,46,46,46,46,46,46,46,46,46,46,46
				db       46,46,46,46,46,46,46,46,46,46,46,46,46,46,46,46
				db       46,46,46,46,46,46,46,46,46,46,46,46,46,46,46,46
				db       46,46,46,46,46,46,46,46,46,46,46,46,46,46,46,46
				db       46,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47
				db       47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47
				db       47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47
				db       47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47
				db       47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47
				db       47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47
				db       48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48
				db       48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48
				db       48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48
				db       48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48
				db       48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48
				db       48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48
				db       48,49,49,49,49,49,49,49,49,49,49,49,49,49,49,49
				db       49,49,49,49,49,49,49,49,49,49,49,49,49,49,49,49
				db       49,49,49,49,49,49,49,49,49,49,49,49,49,49,49,49
				db       49,49,49,49,49,49,49,49,49,49,49,49,49,49,49,49
				db       49,49,49,49,49,49,49,49,49,49,49,49,49,49,49,49
				db       49,49,49,49,49,49,49,49,49,49,49,49,49,49,49,49
				db       49,49,49,49,50,50,50,50,50,50,50,50,50,50,50,50
				db       50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50
				db       50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50
				db       50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50
				db       50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50
				db       50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50
				db       50,50,50,50,50,50,50,50,50,51,51,51,51,51,51,51
				db       51,51,51,51,51,51,51,51,51,51,51,51,51,51,51,51
				db       51,51,51,51,51,51,51,51,51,51,51,51,51,51,51,51
				db       51,51,51,51,51,51,51,51,51,51,51,51,51,51,51,51
				db       51,51,51,51,51,51,51,51,51,51,51,51,51,51,51,51
				db       51,51,51,51,51,51,51,51,51,51,51,51,51,51,51,51
				db       51,51,51,51,51,51,51,51,51,51,51,51,51,51,51,51
				db       52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52
				db       52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52
				db       52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52
				db       52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52
				db       52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52
				db       52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52
				db       52,52,52,52,52,52,52,52,52,53,53,53,53,53,53,53
				db       53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53
				db       53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53
				db       53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53
				db       53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53
				db       53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53
				db       53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53
				db       53,53,53,53,54,54,54,54,54,54,54,54,54,54,54,54
				db       54,54,54,54,54,54,54,54,54,54,54,54,54,54,54,54
				db       54,54,54,54,54,54,54,54,54,54,54,54,54,54,54,54
				db       54,54,54,54,54,54,54,54,54,54,54,54,54,54,54,54
				db       54,54,54,54,54,54,54,54,54,54,54,54,54,54,54,54
				db       54,54,54,54,54,54,54,54,54,54,54,54,54,54,54,54
				db       54,54,54,54,54,54,54,54,54,54,54,54,54,54,54,54
				db       54,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
				db       55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
				db       55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
				db       55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
				db       55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
				db       55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
				db       55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
				db       56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56
				db       56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56
				db       56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56
				db       56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56
				db       56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56
				db       56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56
				db       56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56
				db       56,57,57,57,57,57,57,57,57,57,57,57,57,57,57,57
				db       57,57,57,57,57,57,57,57,57,57,57,57,57,57,57,57
				db       57,57,57,57,57,57,57,57,57,57,57,57,57,57,57,57
				db       57,57,57,57,57,57,57,57,57,57,57,57,57,57,57,57
				db       57,57,57,57,57,57,57,57,57,57,57,57,57,57,57,57
				db       57,57,57,57,57,57,57,57,57,57,57,57,57,57,57,57
				db       57,57,57,57,57,57,57,57,57,57,57,57,57,57,57,57
				db       57,57,57,57,58,58,58,58,58,58,58,58,58,58,58,58
				db       58,58,58,58,58,58,58,58,58,58,58,58,58,58,58,58
				db       58,58,58,58,58,58,58,58,58,58,58,58,58,58,58,58
				db       58,58,58,58,58,58,58,58,58,58,58,58,58,58,58,58
				db       58,58,58,58,58,58,58,58,58,58,58,58,58,58,58,58
				db       58,58,58,58,58,58,58,58,58,58,58,58,58,58,58,58
				db       58,58,58,58,58,58,58,58,58,58,58,58,58,58,58,58
				db       58,58,58,58,58,58,58,58,58,59,59,59,59,59,59,59
				db       59,59,59,59,59,59,59,59,59,59,59,59,59,59,59,59
				db       59,59,59,59,59,59,59,59,59,59,59,59,59,59,59,59
				db       59,59,59,59,59,59,59,59,59,59,59,59,59,59,59,59
				db       59,59,59,59,59,59,59,59,59,59,59,59,59,59,59,59
				db       59,59,59,59,59,59,59,59,59,59,59,59,59,59,59,59
				db       59,59,59,59,59,59,59,59,59,59,59,59,59,59,59,59
				db       59,59,59,59,59,59,59,59,59,59,59,59,59,59,59,59
				db       60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60
				db       60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60
				db       60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60
				db       60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60
				db       60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60
				db       60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60
				db       60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60
				db       60,60,60,60,60,60,60,60,60,61,61,61,61,61,61,61
				db       61,61,61,61,61,61,61,61,61,61,61,61,61,61,61,61
				db       61,61,61,61,61,61,61,61,61,61,61,61,61,61,61,61
				db       61,61,61,61,61,61,61,61,61,61,61,61,61,61,61,61
				db       61,61,61,61,61,61,61,61,61,61,61,61,61,61,61,61
				db       61,61,61,61,61,61,61,61,61,61,61,61,61,61,61,61
				db       61,61,61,61,61,61,61,61,61,61,61,61,61,61,61,61
				db       61,61,61,61,61,61,61,61,61,61,61,61,61,61,61,61
				db       61,61,61,61,62,62,62,62,62,62,62,62,62,62,62,62
				db       62,62,62,62,62,62,62,62,62,62,62,62,62,62,62,62
				db       62,62,62,62,62,62,62,62,62,62,62,62,62,62,62,62
				db       62,62,62,62,62,62,62,62,62,62,62,62,62,62,62,62
				db       62,62,62,62,62,62,62,62,62,62,62,62,62,62,62,62
				db       62,62,62,62,62,62,62,62,62,62,62,62,62,62,62,62
				db       62,62,62,62,62,62,62,62,62,62,62,62,62,62,62,62
				db       62,62,62,62,62,62,62,62,62,62,62,62,62,62,62,62
				db       62,63,63,63,63,63,63,63,63,63,63,63,63,63,63,63
				db       63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,63
				db       63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,63
				db       63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,63
				db       63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,63
				db       63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,63
				db       63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,63
				db       63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,63

                END
