
;/////////////////////////////////////////////////////////////////////////
;//
;//  Water32.asm  -   P5 / PPro  self-modifying optimized code
;//
;//  version 1.1   December 1997
;//
;//  This is a part of the Unreal Texture Animation Engine code.
;//  Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.
;//
;/////////////////////////////////////////////////////////////////////////
;
;----------------------------------------------------------
; MASM 6.11d code   for Win95 VC++ 5.0 flat model
;
; Filename: WATER32.ASM
;
; default options : ML /c /Cx /coff  fire32.asm;
;
; Assemble/build syntax  from within Microsoft Developer Studio
;
;   Build->Settings->[select Fire32] ->Custom build:
;
;   ML /c /Cx /coff  /Fo$(OutDir)\fire32.obj fire32.asm
;
;
; add  /Zd /Zi /Zf  switches to generate debug/browser info.
;
; add  /W0 to ignore the 'line number info for non-CODE segment' warning.
;
;
;                       Speed (measured in CPU cycles per pixel)
;
; Classic fire algorithm:    Pentium120 =  5.0
;                            486DX66    = 11.0  ( about 33 for optimized C++ )
;
; Interpolated Water    :
;                            Pentium120 =  6.0     -> using cache-priming
;                            486DX66    = 14.0
;
;
;
; routine contents:
;
;in .DATA :
;
; BigWaterEven       water update code for even steps
; BigWaterOdd        water update code for odd  steps
;
;in .CODE :
;
; CalcWaterASM       entry for water algorithm, calls BigWater*
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



.586                 ; 
                     ; .MODEL ... C tells the assembler that parameters
.MODEL flat , C      ;            are pushed from right to left.


.DATA

assume CS: _DATA    ; needed for assembling code in the data segment

EXTERNDEF SpeedRindex:DWORD;

 MAXSPARKS = 1024   ; must be same as in FIRENGIN.H !

 DUMMY = 1    ; set to 0 to get rid of dummy cache warmin' reads...
              ; just leave it in, no problem for PII...

;==================================

 Advb EQU byte ptr [011111111h]   ;; dummy offsets to patch later
 Advw EQU word ptr [011111111h]

;==================================

  BW_WaterBitmap   DD 0 ; destination (size: X*4 by Y*4 )
  BW_WaveMaps      DD 0 ; map 1&2 size  x by y *2 (interleaved lines!)
  BW_RenderTable   DD 0 ; table with (palette) colors
  BW_WaveTable     DD 0 ; wave table [(B1+B2+B3+B4)-2*A )]
  BW_LineXSize     DD 0 ; x
  BW_LineYSize     DD 0 ; y
  BW_WaterID       DD 0 ; Unique ID for water maps (simply bitmap addr from caller)
 
  PatchEvenDetect  DD 0
  PatchOddDetect   DD 0
  LastBitMapEven   DD 0
  LastBitMapOdd    DD 0
  BW_TotalSize     DD 0

;;
;; Simple callable routine for every 4 pixels, INDICATE which ones
;; are to be reused in the caller-macro...
;; (Or make whole thing an 'inlined' macro; test which goes fastest...
;;

align 16
Output4Pix label near




COMMENT ~

void Output4Pix (
                  BYTE SourceA,
                  BYTE SourceC,
                  BYTE SourceE,
                  BYTE SourceG,
                  BYTE SourceB,
                  BYTE SourceD,
                  BYTE SourceF,
                  BYTE SourceH,
                  BYTE* DestCell,
                  BYTE* Dest1,
                  BYTE* Dest2,           //
                  BYTE* Dest3,           //  A C E.G    12
                  BYTE* Dest4,           //  B D F H    34
                  WaterParams* Pool      //  DestCell is in midst of EGFH
                 )                       //  dest 1234 are associated cells
                                         //  in visual output
{

 // only 1 pixel really calculated, 4 output pixels all interpolated
 *DestCell = *( Pool->WaveTable + 512 +
               ( (int)SourceE
               + (int)SourceG
               + (int)SourceF
               + (int)SourceH
               )
               - ( ((int)*DestCell)  << 1 )
               );

  int _EA = (int)SourceE-(int)SourceA;
  int _FB = (int)SourceF-(int)SourceB;
  int _GC = (int)SourceG-(int)SourceC;
  int _HD = (int)SourceH-(int)SourceD;

  *Dest2 = *( Pool->RenderTable + 512 +  _GC + _HD );
  *Dest3 = *( Pool->RenderTable + 512 +  _FB + _HD );
  *Dest1 = *( Pool->RenderTable + 512 + (_FB+_HD+_EA+_GC)/2 );
  *Dest4 = *( Pool->RenderTable + 512 +  _HD + _HD );


  // 2,3 step instead of '2,4' - sharper image, but blockier too


}


~







;===BIGWATER:  even, odd separate cycles..================================

;(interpolated 2x2 pixel 'physical' water calculation

;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;  all vars patchable
;;;;;;;;;;;;;;;;;;;;;;;;


  nil      EQU 0
  byteEBP  EQU byte ptr [   EBP + 011111111h ]
  byteEBP2 EQU byte ptr [ EBP*2 + 011111111h ]

  ColorTable EQU byte ptr [011111111h]

;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Select ODD/EVEN, then test for having done the patch already.
;; There is a patch for odd, and one for even; to spread
;; the effort, only patch the one needed at calling time.
;;
;; Scheme for calculating EVEN: *         * *
;;                                         o o
;;                                        * *
;; * first line:                           o o
;;
;;        Source              Output
;;    0   wrap up, 3/4 left    wrap up & left   \
;;    1   wrap up, 2/4 left    wrap up          /
;;
;;    (2  wrap up, 1/4 left   implied, entrance si/di vars)  wrap up  \
;;    n-2 wrap up              wrap up                                /
;;
;;
;;
;; * Y-1 rest of lines:
;;    0   wrap  3/4 left    wrap left     \
;;    1   wrap  2/4 left                  /
;;
;;    (2  wrap    1/4 left implied, entrance si/di)  \
;;    n-2 no wrap                                    /
;;
;;
;; Patching these 'wrapping' into non-wrapping: 8 outs, 4 + 2inputs
;; for odd: no OUTS to wrap, just 2 + 4 inputs...
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Scheme for ODD:  - no wrap for OUTPUT...
;;
;;
;; * Y-1 first lines:
;;
;;    last  wrap 1/4 right      \
;;    0     wrap 2/4 left       /
;;
;;    (1  wrap    1/4 left implied= entrance si/di)  \
;;    n-2 no wrap                                    /
;;
;;
;; * last line:
;;
;;    last  wrap down + 1/4 right      \
;;    0     wrap down + 2/4 left       /
;;
;;    (1  wrap down + 1/4 left implied= entrance si/di)  \
;;    n-2 wrap down                                      /
;;
;;;;;;;;;;;;;;;;;;;;;;;
;#
;#     A   Cn  E  nG      1: 2' + 2              2: G-C   + 4    ;;finer: G-E
;#
;#           1 2 X        3: 4' + 4              4:       H-D    ;;finer: H-F
;#           3 4
;#     B   Dn  F  nH
;#
;#
;
; The actual output is just one field, but with a 2x2 bilinear
; interpolation, which meshes together with the actual calculation-step.
; 2x2 bilinear interpolation makes waves travel faster, reduces processing
; and memory overhead, and looks really high-res.
;

PatchEven01 label NEAR  ;;

     MOV	EAX,BW_WaterID
     MOV	PatchEvenDetect,EAX ;; remember ID of task we patch for

     MOV	EAX,BW_WaterBitMap
     MOV	LastBitMapEven,EAX

     MOV	EAX,BW_WaveTable    ;; WAVE (algorithm) table patching
     ADD	EAX,512             ;; the regular OFFSET so negative nrs can be used too..

     MOV    WTablePatch0a,EAX
     MOV    WTablePatch0b,EAX
		
     MOV    WTablePatch1a,EAX
     MOV	WTablePatch1b,EAX
			
     MOV    WTablePatch2a,EAX
     MOV    WTablePatch2b,EAX

     MOV    WTablePatch3a,EAX
     MOV    WTablePatch3b,EAX


     MOV EAX,BW_RenderTable ;;RENDER (color output) table patching
     ADD EAX,512 ;; the regular OFFSET so negative nrs can be used too..

     MOV    CTablePatch0a,EAX
     MOV    CTablePatch0b,EAX
     MOV    CTablePatch0c,EAX
     MOV    CTablePatch0d,EAX
     MOV    CTablePatch0e,EAX
     MOV    CTablePatch0f,EAX
     MOV    CTablePatch0g,EAX
     MOV    CTablePatch0h,EAX

     MOV    CTablePatch1a,EAX
     MOV    CTablePatch1b,EAX
     MOV    CTablePatch1c,EAX
     MOV    CTablePatch1d,EAX
     MOV    CTablePatch1e,EAX
     MOV    CTablePatch1f,EAX
     MOV    CTablePatch1g,EAX
     MOV    CTablePatch1h,EAX

     MOV    CTablePatch2a,EAX
     MOV    CTablePatch2b,EAX
     MOV    CTablePatch2c,EAX
     MOV    CTablePatch2d,EAX
     MOV    CTablePatch2e,EAX
     MOV    CTablePatch2f,EAX
     MOV    CTablePatch2g,EAX
     MOV    CTablePatch2h,EAX

     MOV    CTablePatch3a,EAX
     MOV    CTablePatch3b,EAX
     MOV    CTablePatch3c,EAX
     MOV    CTablePatch3d,EAX
     MOV    CTablePatch3e,EAX
     MOV    CTablePatch3f,EAX
     MOV    CTablePatch3g,EAX
     MOV    CTablePatch3h,EAX

     ;;;;;;;;;;;;;;;;;;;;;;;;;;


     ;;  C E   G    C' E'  G'   G'=G+1 etc, BUT EBP gets +2 in between
     ;;      x           x'
     ;;  D F   H    D' F'  H'   so it's -1 really.
     ;;
     ;;  some 'DROPS' and 'output' need no patching as they're always == [EBP+c]
     ;;
     ;; 2nd line = + xdimension*2 (usually)
     ;;;;;; 2 & 3 are the main Y-loop,DROPS ... no UP wraps

     MOV ECX,BW_WaveMaps
     MOV EAX,ECX           ;; all 'drops'  'RELATIVE to DESTCELL'
     MOV EDX,BW_LineXSize

     MOV     DropX0a,EAX   ;;   0
     MOV     DropX1a,EAX   ;;   0
     MOV     DropX2a,EAX   ;;   0
     MOV     DropX3a,EAX   ;;   0

     MOV     DropX0b,EAX   ;;   0
     MOV     DropX1b,EAX   ;;   0
     MOV     DropX2b,EAX   ;;   0


     DEC EAX
     MOV     DropG2a_,EAX  ;; -1
     MOV     DropX0d,EAX   ;; -1
     MOV     DropX1d,EAX   ;; -1
     MOV     DropX2d,EAX   ;; -1
     MOV     DropX3d,EAX   ;; -1
     MOV     DropX0c,EAX   ;; -1
     MOV     DropX1c,EAX   ;; -1
     MOV     DropX2c,EAX   ;; -1
     MOV     DropX3c,EAX   ;; -1
     DEC EAX
     MOV     DropC2a,EAX   ;;-2
     MOV     DropX3b_,EAX  ;; 0  -2 ;;
     DEC EAX
     MOV     DropC2a_,EAX  ;;-3
     MOV     DropC2b,EAX   ;;-1  -2 ;;


     MOV EAX,ECX ;;BW_WaveMaps
     ADD EAX,BW_TotalSize

     DEC EAX
     MOV     DropG0a_,EAX  ;;  -1 + TotalSize
     DEC EAX
     MOV     DropC0a,EAX   ;;  -2 + TotalSize
     DEC EAX
     MOV     DropC0b,EAX   ;;-1-2 + TotalSize
     MOV     DropC0a_,EAX  ;;  -3 + TotalSize

     MOV EAX,ECX ;;BW_WaveMaps
     ADD EAX,EDX ;;BW_LineXSize

     MOV     DropH0a,EAX   ;;   0 + Xdimension
     MOV     DropH0b,EAX   ;;   0 + Xdimension
     MOV     DropH1a,EAX   ;;   0 + Xdimension
     MOV     DropH1b,EAX   ;;   0 + Xdimension
     MOV     DropH2a,EAX   ;;   0 + Xdimension
     MOV     DropH2b,EAX   ;;   0 + Xdimension
     MOV     DropH3a,EAX   ;;   0 + Xdimension
     MOV     DropH3b,EAX   ;;   0 + Xdimension
     DEC EAX
     MOV     DropH0c,EAX   ;;-1 0 + Xdimension
     MOV     DropH0d,EAX   ;;-1 0 + Xdimension
     MOV     DropH1c,EAX   ;;-1 0 + Xdimension
     MOV     DropH1d,EAX   ;;-1 0 + Xdimension
     MOV     DropH2c,EAX   ;;-1 0 + Xdimension
     MOV     DropH2d,EAX   ;;-1 0 + Xdimension
     MOV     DropH3c,EAX   ;;-1 0 + Xdimension
     MOV     DropH3d,EAX   ;;-1 0 + Xdimension
     DEC EAX
     MOV     DropD1a,EAX   ;;  -2 + Xdimension
     MOV     DropD3a,EAX   ;;  -2 + Xdimension
     MOV     DropD3a__,EAX   ;;  -2 + Xdimension
     DEC EAX
     MOV     DropD1b,EAX   ;;-1-2 + Xdimension
     MOV     DropD3b,EAX   ;;-1-2 + Xdimension

     MOV EAX,ECX  ;;BW_WaveMaps
     ADD EAX,EDX  ;;BW_LineXSize
     ADD EAX,EDX  ;;BW_LineXSize

     DEC EAX
     MOV     DropH0a_,EAX  ;;  -1 + Xdimension*2
     MOV     DropH2a_,EAX  ;;  -1 + Xdimension*2
     DEC EAX
     MOV     DropD0a,EAX   ;;  -2 + Xdimension*2
     MOV     DropD2a,EAX   ;;  -2 + Xdimension*2
     DEC EAX
     MOV     DropD0a_,EAX  ;;  -3 + Xdimension*2
     MOV     DropD2a_,EAX  ;;  -3 + Xdimension*2
     MOV     DropD0b,EAX   ;;-1-2 + Xdimension*2
     MOV     DropD2b,EAX   ;;-1-2 + Xdimension*2

     MOV EAX,ECX ;;BW_WaveMaps
     SUB EAX,EDX ;;BW_LineXSize

     MOV     DropG2a,EAX   ;;   0 - Xdimension
     MOV     DropG3a,EAX   ;;   0 - Xdimension
     DEC EAX
     MOV     DropG2b,EAX   ;;-1 0 - Xdimension
     MOV     DropG3b,EAX   ;;-1 0 - Xdimension
     DEC EAX
     MOV     DropC3a,EAX   ;;  -2 - Xdimension
     DEC EAX
     MOV     DropC3b,EAX   ;;-1-2 - Xdimension

     ADD EAX,3
     ADD EAX,BW_TotalSize

     MOV     DropG0a,EAX   ;;   0 - Xdimension  + TotalSize
     MOV     DropG1a,EAX   ;;   0 - Xdimension  + TotalSize
     DEC EAX
     MOV     DropG0b,EAX   ;;-1 0 - Xdimension  + TotalSize
     MOV     DropG1b,EAX   ;;-1 0 - Xdimension  + TotalSize
     DEC EAX
     MOV     DropC1a,EAX   ;;  -2 - Xdimension  + TotalSize
     DEC EAX
     MOV     DropC1b,EAX   ;;-1-2 - Xdimension  + TotalSize


   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

      MOV EBX,BW_WaterBitmap

      MOV EDX,BW_LineXSize
      MOV ECX,BW_TotalSize

      ADD EDX,EDX ;;Xdimension*2 in EDX
      ADD ECX,ECX ;;TotalSize*2 in ECX


     ;;  12  12    results: differ 2 ,use EBP*2, EBP gets+2, so now -2 diff
     ;;  34  34    2nd line =+ xdimension*2 (usually)
     ;;
     ;;  first line (0,1) 1&2 wrap up for all, and 1&3 wrap left for first pix
     ;; most lines only  1&3 wrap left for first pix
     ;;;;;;;;;;;;;;;;;;;;;;;

     MOV EAX,EBX ;BW_WaterBitmap

     MOV     Result4_0a,EAX  ;;   0
     MOV     Result4_1a,EAX  ;;   0
    if DUMMY
    MOV     Result4_1a__,EAX  ;;
    endif
     MOV     Result4_2a,EAX  ;;   0
     MOV     Result4_3a,EAX  ;;   0
    if DUMMY
    MOV     Result4_3a__,EAX  ;;
    endif
     DEC EAX
     MOV     Result3_1a,EAX  ;;  -1
     MOV     Result1_2a,EAX  ;;  -1
     MOV     Result3_3a,EAX  ;;  -1
     DEC EAX
     MOV     Result4_0b,EAX  ;;-2+0
     MOV     Result4_1b,EAX  ;;-2+0
     MOV     Result4_2b,EAX  ;;-2+0
     MOV     Result4_3b,EAX  ;;-2+0
     DEC EAX
     MOV     Result3_0b,EAX  ;;-2-1
     MOV     Result3_1b,EAX  ;;-2-1
     MOV     Result3_2b,EAX  ;;-2-1
     MOV     Result3_3b,EAX  ;;-2-1

     ADD EAX,2
     ADD EAX,EDX ;;Xdim*2

     MOV     Result3_0a,EAX  ;;  -1 + Xdimension*2
     MOV     Result3_2a,EAX  ;;  -1 + Xdimension*2

     MOV EAX,EBX ;; BW_WaterMap
     SUB EAX,EDX ;; Xdim*2

     MOV     Result2_2a,EAX  ;;   0 - Xdimension*2
    if DUMMY
     MOV     Result2_3a__,EAX  ;;   0 - Xdimension*2
    endif
     ;;;MOV     Result2_3a,EAX  ;;   0 - Xdimension*2 -4
     DEC EAX
     MOV     Result1_3a,EAX  ;;  -1 - Xdimension*2
     DEC EAX
     MOV     Result2_2b,EAX  ;;-2+0 - Xdimension*2
     MOV     Result2_3b,EAX  ;;-2+0 - Xdimension*2
     DEC EAX
     MOV     Result1_2b,EAX  ;;-2-1 - Xdimension*2
     MOV     Result1_3b,EAX  ;;-2-1 - Xdimension*2
     DEC EAX
     MOV     Result2_3a_,EAX  ;;   0 - Xdimension*2 -4 ;;


     MOV EAX,EBX
     SUB EAX,EDX ;;Xdim*2
     ADD EAX,ECX ;;BW_TotalSize*2

     MOV     Result2_0a,EAX  ;;   0 - Xdimension*2 + TotalSize*2
     MOV     Result2_1a,EAX  ;;   0 - Xdimension*2 + TotalSize*2
    if DUMMY
     MOV     Result2_1a__,EAX  ;;  0 - Xdimension*2 + TotalSize*2
    endif

     DEC EAX
     MOV     Result1_1a,EAX  ;;  -1 - Xdimension*2 + TotalSize*2
     DEC EAX
     MOV     Result2_0b,EAX  ;;-2+0 - Xdimension*2 + TotalSize*2
     MOV     Result2_1b,EAX  ;;-2+0 - Xdimension*2 + TotalSize*2
     DEC EAX
     MOV     Result1_0b,EAX  ;;-2-1 - Xdimension*2 + TotalSize*2
     MOV     Result1_1b,EAX  ;;-2-1 - Xdimension*2 + TotalSize*2

     MOV EAX,EBX
     ADD EAX,ECX
     DEC EAX

     MOV     Result1_0a,EAX  ;;  -1                + TotalSize*2
     ;;;;;;;;;;;;;;;;;;;;;;;

   RETN


align 16
BigWaterEven PROC ;;; EVEN field: CALCULATE it, but get info/pix from ODD field
    ;;;;;;;;;;;;;;;;;;;;;;

    ;; only patch this if ID # differs from last OR if bitmap dest changed..

    MOV EAX,PatchEvenDetect
    CMP EAX,BW_WaterID
    JNE DoPatchEven

    MOV EAX,LastBitMapEven
    CMP EAX,BW_WaterBitMap
    JE SkipPatchEven     

    DoPatchEven:
     Call PatchEven01

    SkipPatchEven:

    ;;;;;;;;;;;;;;;;;;;;;;

     MOV EAX,BW_LineXSize   ; calculating the EVEN ones
     MOV EndLine0 ,EAX
     MOV EndLine1 ,EAX
     XOR EBP,EBP ;;start at very first pix (=even)

     XOR EBX,EBX
     XOR ECX,ECX

    Call Even0DoLine

    ;;;;;;;;;;;;;;;;;;;;;;

     MOV EAX,BW_TotalSize  ;;
     SUB EAX,BW_LineXSize  ;; point just beyond last EVEN pixel..
     MOV [EndField1],EAX   ;; end of whole field...

    ;; continue with last EBP...

     XOR EBX,EBX
     XOR ECX,ECX

    Call Even1RepeatLines  ;; bumps up EBP and Endline1 every time too...

     RETN

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;; FIRST tuple:
;;;;;;;;;;;;;  assume ECX = EBX = EAX = 0, at least the upper 24 bits.
;;;;;;;;;;;;;  EDX = sum of left two cells (E + F)
;;;;;;;;;;;;;
;;;;;;;;;;;;;  EBP at right cell
;;;;;;;;;;;;;
;;;;;;;;;;;;; last '4' = ESI =  H-D
;;;;;;;;;;;;; last '2' = EDI =  G-C + 4
;;;;;;;;;;;;; last sup = G+H

;;;; first EBP and [endline0] set appropriately by caller !
;;;; EBX and ECX zero'd by caller

Even0Doline label NEAR      ;;   very first Y entry

  XOR EAX,EAX

  ;;;; prepare ESI/EDI

  MOV AL,[byteEBP]
         org $-4
         DropH0a_ DD nil

  MOV EDX,EAX ;; EDX needs G+H

  MOV BL,[byteEBP]
         org $-4
         DropD0a_ DD nil

  SUB EAX,EBX
  MOV ESI,EAX

  MOV BL,[byteEBP]
         org $-4
         DropG0a_ DD nil
  ADD EAX,EBX
  ADD EDX,EBX  ;; EDX now G+H = 'E+F last sum' for next

  MOV BL,[byteEBP]
         org $-4
         DropC0a_ DD nil
  SUB EAX,EBX

  SAR EAX,1    ;; /2, signed

  MOV EDI,EAX

  XOR EAX,EAX

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;\\8 pixels..

  MOV CL,[byteEBP]
          org $-4
          DropD0a DD nil

  MOV BL,[byteEBP]  ;;
          org $-4
          DropH0a DD nil
  MOV AL,[byteEBP]   ;LL
          org $-4
          DropX0a DD nil

   SUB EBX,ECX     ;; 4 = H-D
  SUB EDX,EAX      ;LL EDX last sum E+F

   MOV CL,[byteEBP]  ;;
          org $-4
          DropC0a DD nil
  SUB EDX,EAX      ;LL

   MOV AL,ColorTable[ESI+EBX]  ;; nr 3 only one to use  4'
          org $-4
          CTablePatch0a DD nil
   MOV ESI,EBX     ;; save 4

   SUB EBX,ECX     ;;  3 = 4' + 4
   MOV CL,[byteEBP]  ;;
          org $-4
          DropG0a DD nil

   MOV [byteEBP2],AL  ;;
          org $-4
          Result3_0a DD nil
   ADD EBX,ECX     ;;  2 = 4 +  G-C

   SAR EBX,1       ;; must be shifted right.. cuz COMPOUND index. 1/4 cyc per pix xtra
  MOV AL,[byteEBP]   ;LL ECX already G
          org $-4
          DropH0b DD nil

  ADD ECX,EAX      ;LL ECX now G+H    ;; ECX no longer ooooxxxx !
   MOV AL,ColorTable[ESI*2]   ;; 4
          org $-4
          CTablePatch0b DD nil

   MOV [byteEBP2],AL
          org $-4
          Result4_0a DD nil
   MOV AL,ColorTable[EDI+EBX] ;; 2' + 2
          org $-4
          CTablePatch0c DD nil

   MOV EDI,EBX
   MOV [byteEBP2],AL
          org $-4
          Result1_0a DD nil

   MOV AL,ColorTable[EBX*2]     ;; 2
          org $-4
          CTablePatch0d DD nil

  MOV BL,[AdvB+EDX+ECX] ;LL  EAX= result    ECX is new E+F, only one worth save
          org $-4
          WTablePatch0a DD nil
   MOV [byteEBP2],AL
          org $-4
          Result2_0a DD nil

  MOV [byteEBP],BL   ;LL  'main' save;
          org $-4
          DropX0b DD nil

 ADD EBP,2                       ;; EBP increase....

   XOR EDX,EDX
  XOR EBX,EBX

 ;;;;;;;;;;;;;;;;;;;;;;;;;

   MOV DL,[byteEBP]
          org $-4
          DropD0b DD nil

   MOV BL,[byteEBP]  ;;
          org $-4
          DropH0c DD nil
  MOV AL,[byteEBP]   ;LL
          org $-4
          DropX0c DD nil

   SUB EBX,EDX     ;; 4 = H-D
  SUB ECX,EAX      ;LL ECX last sum E+F

   MOV DL,[byteEBP]  ;;
          org $-4
          DropC0b DD nil
  SUB ECX,EAX      ;LL

   MOV AL,ColorTable[ESI+EBX]  ;; nr 3 only one to use  4'
          org $-4
          CTablePatch0e DD nil
   MOV ESI,EBX     ;; save 4

   SUB EBX,EDX     ;;  3 = 4' + 4
   MOV DL,[byteEBP]  ;;
          org $-4
          DropG0b DD nil

   MOV [byteEBP2],AL  ;;
          org $-4
          Result3_0b DD nil
   ADD EBX,EDX     ;;  2 = 4 +  G-C

   SAR EBX,1       ;; must be shifted right.. cuz COMPOUND index. 1/4 cyc per pix xtra
                   ;; U-pipe pairable
  MOV AL,[byteEBP]   ;LL EDX already G
          org $-4
          DropH0d DD nil

  ADD EDX,EAX      ;LL EDX now G+H    ;; EDX no longer ooooxxxx !
   MOV AL,ColorTable[ESI*2]   ;; 4
          org $-4
          CTablePatch0f DD nil

   MOV [byteEBP2],AL
          org $-4
          Result4_0b DD nil
   MOV AL,ColorTable[EDI+EBX] ;; 2' + 2
          org $-4
          CTablePatch0g DD nil

   MOV EDI,EBX
   MOV [byteEBP2],AL
          org $-4
          Result1_0b DD nil

   MOV AL,ColorTable[EBX*2]     ;; 2
          org $-4
          CTablePatch0h DD nil
  MOV BL,[AdvB+ECX+EDX] ;LL  EAX= result    EDX is new E+F, only one worth save
          org $-4
          WTablePatch0b DD nil

   MOV [byteEBP2],AL
          org $-4
          Result2_0b DD nil
   XOR ECX,ECX

  MOV [byteEBP],BL   ;;LL  'main' save;
          org $-4
          DropX0d DD nil
  XOR EBX,EBX

  jmp Even0RepeatCore


align 16 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

           ;;\\  X loop start
Even0RepeatCore label NEAR ;;\\ vars 0, subindex A or B...

 ;;;  dummy reads from RESULT locations
 ;;;  to load the 32-byte cache lines

 if DUMMY
  MOV BL,[byteEBP2]
          org $-4
          Result2_1a__ DD nil;; primes the P5 cache for WRITES ..
  MOV AL,[byteEBP2]
          org $-4
          Result4_1a__ DD nil
 endif


  MOV CL,[byteEBP]
          org $-4
          DropD1a DD nil

  MOV BL,[byteEBP]  ;;
          org $-4
          DropH1a DD nil
  MOV AL,[byteEBP]   ;LL
          org $-4
          DropX1a DD nil

   SUB EBX,ECX     ;; 4 = H-D
  SUB EDX,EAX      ;LL EDX last sum E+F

   MOV CL,[byteEBP]  ;;
          org $-4
          DropC1a DD nil
  SUB EDX,EAX      ;LL

   MOV AL,ColorTable[ESI+EBX]  ;; nr 3 only one to use  4'
          org $-4
          CTablePatch1a DD nil
   MOV ESI,EBX     ;; save 4

   SUB EBX,ECX     ;;  3 = 4' + 4
   MOV CL,[byteEBP]  ;;
          org $-4
          DropG1a DD nil

   MOV [byteEBP2],AL  ;;
          org $-4
          Result3_1a DD nil
   ADD EBX,ECX     ;;  2 = 4 +  G-C

   SAR EBX,1       ;; must be shifted right.. cuz COMPOUND index. 1/4 cyc per pix xtra
  MOV AL,[byteEBP]   ;LL ECX already G
          org $-4
          DropH1b DD nil

  ADD ECX,EAX      ;LL ECX now G+H    ;; ECX no longer ooooxxxx !
   MOV AL,ColorTable[ESI*2]   ;; 4
          org $-4
          CTablePatch1b DD nil

   MOV [byteEBP2],AL
          org $-4
          Result4_1a DD nil
   MOV AL,ColorTable[EDI+EBX] ;; 2' + 2
          org $-4
          CTablePatch1c DD nil

   MOV EDI,EBX
   MOV [byteEBP2],AL
          org $-4
          Result1_1a DD nil

   MOV AL,ColorTable[EBX*2]     ;; 2
          org $-4
          CTablePatch1d DD nil

  MOV BL,[AdvB+EDX+ECX] ;LL  EAX= result    ECX is new E+F, only one worth save
          org $-4
          WTablePatch1a DD nil
   MOV [byteEBP2],AL
          org $-4
          Result2_1a DD nil

  MOV [byteEBP],BL   ;LL  'main' save;
          org $-4
          DropX1b DD nil
 ADD EBP,2                       ;; EBP increase....

   XOR EDX,EDX
  XOR EBX,EBX

 ;;;;;;;;;;;;;;;;;;;;;;;;;

   MOV DL,[byteEBP]
          org $-4
          DropD1b DD nil

   MOV BL,[byteEBP]  ;;
          org $-4
          DropH1c DD nil
  MOV AL,[byteEBP]   ;LL
          org $-4
          DropX1c DD nil

   SUB EBX,EDX     ;; 4 = H-D
  SUB ECX,EAX      ;LL ECX last sum E+F

   MOV DL,[byteEBP]  ;;
          org $-4
          DropC1b DD nil
  SUB ECX,EAX      ;LL

   MOV AL,ColorTable[ESI+EBX]  ;; nr 3 only one to use  4'
          org $-4
          CTablePatch1e DD nil
   MOV ESI,EBX     ;; save 4

   SUB EBX,EDX     ;;  3 = 4' + 4
   MOV DL,[byteEBP]  ;;
          org $-4
          DropG1b DD nil

   MOV [byteEBP2],AL  ;;
          org $-4
          Result3_1b DD nil
   ADD EBX,EDX     ;;  2 = 4 +  G-C

   SAR EBX,1       ;; must be shifted right.. cuz COMPOUND index. 1/4 cyc per pix xtra
                   ;; U-pipe pairable
  MOV AL,[byteEBP]   ;LL EDX already G
          org $-4
          DropH1d DD nil

  ADD EDX,EAX      ;LL EDX now G+H    ;; EDX no longer ooooxxxx !
   MOV AL,ColorTable[ESI*2]   ;; 4
          org $-4
          CTablePatch1f DD nil

   MOV [byteEBP2],AL
          org $-4
          Result4_1b DD nil
   MOV AL,ColorTable[EDI+EBX] ;; 2' + 2
          org $-4
          CTablePatch1g DD nil

   MOV EDI,EBX
   MOV [byteEBP2],AL
          org $-4
          Result1_1b DD nil

   MOV AL,ColorTable[EBX*2]     ;; 2
          org $-4
          CTablePatch1h DD nil
  MOV BL,[AdvB+ECX+EDX] ;LL  EAX= result    EDX is new E+F, only one worth save
          org $-4
          WTablePatch1b DD nil

   MOV [byteEBP2],AL
          org $-4
          Result2_1b DD nil
   XOR ECX,ECX

  MOV [byteEBP],BL   ;;LL  'main' save;
          org $-4
          DropX1d DD nil
  XOR EBX,EBX

  CMP EBP,011111111h ;; Endline
          org $-4
          EndLine0 DD nil

  JB  Even0RepeatCore           ;;// X loop end

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; 32 cycles theoretically / 2 'source pixels -> 8 output
  ;; -> theory: 4 cycles/pixel;  really:  5 cycles/pixel
  ;; = about 8 penalty cycles.. / or resulting from side stuff...
  ;;

RETN ;;// EVEN0



;;///////// EVEN 1
Even1RepeatLines label NEAR      ;; \\ Y loop start

  ;;;calc. new end-of-line value & EBP

  MOV EAX,BW_LineXsize
  ADD EBP,EAX ;;+BW_LineXSize ;; 'skip' a line, which is the other field.

  ADD EAX,EAX
  ADD [EndLine1],EAX ;; end-of ODD only/ EVEN only, 2 lines onward.

;;;; first EBP and [endline1] and [endfield1] set appropriately by caller !
;;;; EBX and ECX zero'd by caller

;;Even1Doline:        ;;   very first Y entry

  XOR EAX,EAX

  ;;;; prepare ESI/EDI

  MOV AL,[byteEBP]
         org $-4
         DropH2a_ DD nil

  MOV EDX,EAX ;; EDX needs G+H

  MOV BL,[byteEBP]
         org $-4
         DropD2a_ DD nil

  SUB EAX,EBX
  MOV ESI,EAX

  MOV BL,[byteEBP]
         org $-4
         DropG2a_ DD nil
  ADD EAX,EBX
  ADD EDX,EBX  ;; EDX now G+H = 'E+F last sum' for next

  MOV BL,[byteEBP]
         org $-4
         DropC2a_ DD nil
  SUB EAX,EBX

  SAR EAX,1    ;; /2, signed

  MOV EDI,EAX

  XOR EAX,EAX

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;\\8 pixels..

  MOV CL,[byteEBP]
          org $-4
          DropD2a DD nil

  MOV BL,[byteEBP]  ;;
          org $-4
          DropH2a DD nil
  MOV AL,[byteEBP]   ;LL
          org $-4
          DropX2a DD nil

   SUB EBX,ECX     ;; 4 = H-D
  SUB EDX,EAX      ;LL EDX last sum E+F

   MOV CL,[byteEBP]  ;;
          org $-4
          DropC2a DD nil
  SUB EDX,EAX      ;LL

   MOV AL,ColorTable[ESI+EBX]  ;; nr 3 only one to use  4'
          org $-4
          CTablePatch2a DD nil
   MOV ESI,EBX     ;; save 4

   SUB EBX,ECX     ;;  3 = 4' + 4
   MOV CL,[byteEBP]  ;;
          org $-4
          DropG2a DD nil

   MOV [byteEBP2],AL  ;;
          org $-4
          Result3_2a DD nil
   ADD EBX,ECX     ;;  2 = 4 +  G-C

   SAR EBX,1       ;; must be shifted right.. cuz COMPOUND index. 1/4 cyc per pix xtra
  MOV AL,[byteEBP]   ;LL ECX already G
          org $-4
          DropH2b DD nil

  ADD ECX,EAX      ;LL ECX now G+H    ;; ECX no longer ooooxxxx !
   MOV AL,ColorTable[ESI*2]   ;; 4
          org $-4
          CTablePatch2b DD nil

   MOV [byteEBP2],AL
          org $-4
          Result4_2a DD nil
   MOV AL,ColorTable[EDI+EBX] ;; 2' + 2
          org $-4
          CTablePatch2c DD nil

   MOV EDI,EBX
   MOV [byteEBP2],AL
          org $-4
          Result1_2a DD nil

   MOV AL,ColorTable[EBX*2]     ;; 2
          org $-4
          CTablePatch2d DD nil

  MOV BL,[AdvB+EDX+ECX] ;LL  EAX= result    ECX is new E+F, only one worth save
          org $-4
          WTablePatch2a DD nil
   MOV [byteEBP2],AL
          org $-4
          Result2_2a DD nil

  MOV [byteEBP],BL   ;LL  'main' save;
          org $-4
          DropX2b DD nil
 ADD EBP,2                       ;; EBP increase....

   XOR EDX,EDX
  XOR EBX,EBX

 ;;;;;;;;;;;;;;;;;;;;;;;;;

   MOV DL,[byteEBP]
          org $-4
          DropD2b DD nil

   MOV BL,[byteEBP]  ;;
          org $-4
          DropH2c DD nil
  MOV AL,[byteEBP]   ;LL
          org $-4
          DropX2c DD nil

   SUB EBX,EDX     ;; 4 = H-D
  SUB ECX,EAX      ;LL ECX last sum E+F

   MOV DL,[byteEBP]  ;;
          org $-4
          DropC2b DD nil
  SUB ECX,EAX      ;LL

   MOV AL,ColorTable[ESI+EBX]  ;; nr 3 only one to use  4'
          org $-4
          CTablePatch2e DD nil
   MOV ESI,EBX     ;; save 4

   SUB EBX,EDX     ;;  3 = 4' + 4
   MOV DL,[byteEBP]  ;;
          org $-4
          DropG2b DD nil

   MOV [byteEBP2],AL  ;;
          org $-4
          Result3_2b DD nil
   ADD EBX,EDX     ;;  2 = 4 +  G-C

   SAR EBX,1       ;; must be shifted right.. cuz COMPOUND index. 1/4 cyc per pix xtra
                   ;; U-pipe pairable
  MOV AL,[byteEBP]   ;LL EDX already G
          org $-4
          DropH2d DD nil

  ADD EDX,EAX      ;LL EDX now G+H    ;; EDX no longer ooooxxxx !
   MOV AL,ColorTable[ESI*2]   ;; 4
          org $-4
          CTablePatch2f DD nil

   MOV [byteEBP2],AL
          org $-4
          Result4_2b DD nil
   MOV AL,ColorTable[EDI+EBX] ;; 2' + 2
          org $-4
          CTablePatch2g DD nil

   MOV EDI,EBX
   MOV [byteEBP2],AL
          org $-4
          Result1_2b DD nil

   MOV AL,ColorTable[EBX*2]     ;; 2
          org $-4
          CTablePatch2h DD nil
  MOV BL,[AdvB+ECX+EDX] ;LL  EAX= result    EDX is new E+F, only one worth save
          org $-4
          WTablePatch2b DD nil

   MOV [byteEBP2],AL
          org $-4
          Result2_2b DD nil
   XOR ECX,ECX

  MOV [byteEBP],BL   ;;LL  'main' save;
          org $-4
          DropX2d DD nil
  XOR EBX,EBX

   MOV CL,[byteEBP]
          org $-4
          DropD3a DD nil

  jmp Even1RepeatCore


align 16
           ;;\\  X loop start
Even1RepeatCore label NEAR ;;\\ vars 0, subindex A or B...

 ;;;  dummy reads from RESULT locations
 ;;;  to load the 32-byte cache lines

 if DUMMY
  MOV AL,[byteEBP2]
          org $-4
          Result4_3a__ DD nil;; primes the P5 cache for WRITES ..
 endif


  ;;MOV CL,[byteEBP]
  ;;        org $-4
  ;;        DropD3a DD nil

  MOV BL,[byteEBP]  ;;
          org $-4
          DropH3a DD nil


  MOV AL,[byteEBP]   ;LL
          org $-4
          DropX3a DD nil

   SUB EBX,ECX     ;; 4 = H-D

  if DUMMY
  MOV CL,[byteEBP2]
          org $-4
          Result2_3a__ DD nil
  endif

  SUB EDX,EAX      ;LL EDX last sum E+F


   MOV CL,[byteEBP]  ;;
          org $-4
          DropC3a DD nil
  SUB EDX,EAX      ;LL

   MOV AL,ColorTable[ESI+EBX]  ;; nr 3 only one to use  4'
          org $-4
          CTablePatch3a DD nil
   MOV ESI,EBX     ;; save 4

   SUB EBX,ECX     ;;  3 = 4' + 4
   MOV CL,[byteEBP]  ;;
          org $-4
          DropG3a DD nil

   MOV [byteEBP2],AL  ;;
          org $-4
          Result3_3a DD nil
   ADD EBX,ECX     ;;  2 = 4 +  G-C

   SAR EBX,1       ;; must be shifted right.. cuz COMPOUND index. 1/4 cyc per pix xtra
  MOV AL,[byteEBP]   ;LL ECX already G
          org $-4
          DropH3b DD nil

  ADD ECX,EAX      ;LL ECX now G+H    ;; ECX no longer ooooxxxx !
   MOV AL,ColorTable[ESI*2]   ;; 4
          org $-4
          CTablePatch3b DD nil

   MOV [byteEBP2],AL
          org $-4
          Result4_3a DD nil
   MOV AL,ColorTable[EDI+EBX] ;; 2' + 2
          org $-4
          CTablePatch3c DD nil

   MOV EDI,EBX
   MOV [byteEBP2],AL
          org $-4
          Result1_3a DD nil

   ADD EBP,2                       ;; EBP increase....
   MOV AL,ColorTable[EBX*2]     ;; 2
          org $-4
          CTablePatch3d DD nil

  MOV BL,[AdvB+EDX+ECX] ;LL  EAX= result    ECX is new E+F, only one worth save
          org $-4
          WTablePatch3a DD nil
  XOR EDX,EDX

  MOV [byteEBP],BL   ;LL  'main' save;
          org $-4
          DropX3b_ DD nil        ;; EBP now BEFORE it  -> patch with -2..
  XOR EBX,EBX


  MOV DL,[byteEBP]        ;;.
          org $-4         ;;.
          DropD3b DD nil  ;;.

  MOV [byteEBP2],AL
          org $-4
          Result2_3a_ DD nil     ;; EBP now BEFORE it  -> patch with -4..
 ;;;;;;;;;;;;;;;;;;;;;;;;;

  MOV AL,[byteEBP]   ;LL
          org $-4
          DropX3c DD nil
   MOV BL,[byteEBP]  ;;
          org $-4
          DropH3c DD nil

  SUB ECX,EAX      ;LL ECX last sum E+F
   SUB EBX,EDX     ;; 4 = H-D

   MOV DL,[byteEBP]  ;;
          org $-4
          DropC3b DD nil
  SUB ECX,EAX      ;LL

   MOV AL,ColorTable[ESI+EBX]  ;; nr 3 only one to use  4'
          org $-4
          CTablePatch3e DD nil
   MOV ESI,EBX     ;; save 4

   SUB EBX,EDX     ;;  3 = 4' + 4
   MOV DL,[byteEBP]  ;;
          org $-4
          DropG3b DD nil

   MOV [byteEBP2],AL  ;;
          org $-4
          Result3_3b DD nil
   ADD EBX,EDX     ;;  2 = 4 +  G-C


   SAR EBX,1       ;; must be shifted right.. cuz COMPOUND index. 1/4 cyc per pix xtra
                   ;; U-pipe pairable
  MOV AL,[byteEBP]   ;LL EDX already G
          org $-4
          DropH3d DD nil


  ADD EDX,EAX      ;LL EDX now G+H    ;; EDX no longer ooooxxxx !
   MOV AL,ColorTable[ESI*2]   ;; 4
          org $-4
          CTablePatch3f DD nil


   MOV [byteEBP2],AL
          org $-4
          Result4_3b DD nil
   MOV AL,ColorTable[EDI+EBX] ;; 2' + 2
          org $-4
          CTablePatch3g DD nil

   MOV EDI,EBX
   MOV [byteEBP2],AL
          org $-4
          Result1_3b DD nil

   MOV AL,ColorTable[EBX*2]     ;; 2
          org $-4
          CTablePatch3h DD nil
  MOV BL,[AdvB+ECX+EDX] ;LL  EAX= result    EDX is new E+F, only one worth save
          org $-4
          WTablePatch3b DD nil

   MOV [byteEBP2],AL
          org $-4
          Result2_3b DD nil
   XOR ECX,ECX

  MOV [byteEBP],BL   ;; LL  'main' save;
          org $-4
          DropX3d DD nil
  XOR EBX,EBX

  CMP EBP,011111111h ;; Endline
          org $-4
          EndLine1 DD nil
  MOV CL,[byteEBP]
          org $-4
          DropD3a__ DD nil      ;; Duplicate, patch same as original

  JB  Even1RepeatCore           ;; // X loop end
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  CMP EBP,011111111h ;; EndField
          org $-4
          EndField1 DD nil
  JB  Even1RepeatLines

  ;;;;;;;;;;;;;;;;;;;;;;;;;;; about 29 cyc/ 8 pix = 3.7 per pixel theoretically


  RETN ;;//EVEN1



BigWaterEven ENDP

;============================================================================












;============================================================================

PatchOdd01 label NEAR  ;;

     MOV EAX,BW_WaterID
     MOV PatchOddDetect,EAX ;; remember ID of task we patch for

     MOV EAX,BW_WaterBitmap
     MOV LastBitMapOdd,EAX

     MOV EAX,BW_WaveTable    ;; WAVE (algorithm) table patching
     ADD EAX,512 ;; the regular OFFSET so negative nrs can be used too..

     MOV     WTbOddPatch0a,EAX
     MOV     WTbOddPatch0b,EAX

     MOV     WTbOddPatch1a,EAX
     MOV     WTbOddPatch1b,EAX

     MOV     WTbOddPatch2a,EAX
     MOV     WTbOddPatch2b,EAX

     MOV     WTbOddPatch3a,EAX
     MOV     WTbOddPatch3b,EAX


     MOV EAX,BW_RenderTable ;;RENDER (color output) table patching
     ADD EAX,512 ;; the regular OFFSET so negative nrs can be used too..

     MOV     CTbOddPatch0a,EAX
     MOV     CTbOddPatch0b,EAX
     MOV     CTbOddPatch0c,EAX
     MOV     CTbOddPatch0d,EAX
     MOV     CTbOddPatch0e,EAX
     MOV     CTbOddPatch0f,EAX
     MOV     CTbOddPatch0g,EAX
     MOV     CTbOddPatch0h,EAX

     MOV     CTbOddPatch1a,EAX
     MOV     CTbOddPatch1b,EAX
     MOV     CTbOddPatch1c,EAX
     MOV     CTbOddPatch1d,EAX
     MOV     CTbOddPatch1e,EAX
     MOV     CTbOddPatch1f,EAX
     MOV     CTbOddPatch1g,EAX
     MOV     CTbOddPatch1h,EAX

     MOV     CTbOddPatch2a,EAX
     MOV     CTbOddPatch2b,EAX
     MOV     CTbOddPatch2c,EAX
     MOV     CTbOddPatch2d,EAX
     MOV     CTbOddPatch2e,EAX
     MOV     CTbOddPatch2f,EAX
     MOV     CTbOddPatch2g,EAX
     MOV     CTbOddPatch2h,EAX

     MOV     CTbOddPatch3a,EAX
     MOV     CTbOddPatch3b,EAX
     MOV     CTbOddPatch3c,EAX
     MOV     CTbOddPatch3d,EAX
     MOV     CTbOddPatch3e,EAX
     MOV     CTbOddPatch3f,EAX
     MOV     CTbOddPatch3g,EAX
     MOV     CTbOddPatch3h,EAX

     ;;;;;;;;;;;;;;;;;;;;;;;;;;


     ;;  C E   G    C' E'  G'   G'=G+1 etc, BUT EBP gets +2 in between
     ;;      x           x'
     ;;  D F   H    D' F'  H'   so it's -1 really.
     ;;
     ;;  some 'DpOddS' and 'output' need no patching as they're always == [EBP+c]
     ;;
     ;; 2nd line = + xdimension*2 (usually)
     ;;;;;; 2 & 3 are the main Y-loop,DpOddS ... no UP wraps

     ;;;; remem: start with LAST odd line
     ;;; ALSO new for ODD: not pixel 0,1 special, but last+0

     MOV EBX,BW_WaveMaps
     MOV EAX,EBX           ;; all 'DpOdds'  'RELATIVE to DESTCELL'
     MOV EDX,BW_LineXSize
     MOV ECX,BW_TotalSize

     ;;;;;;;;;;;;;;;;;;;;; 64 patches total (8x7 + 4 + 4)

     MOV     DpOddG0a_,EAX  ;;   0
     MOV     DpOddG2a_,EAX  ;;   0
     MOV     DpOddX1b,EAX   ;;   0
     ;;MOV     DpOddX3b_,EAX   ;;   0 -2
     MOV     DpOddX1a,EAX   ;;   0           = destcell = EBP...
     MOV     DpOddX3a,EAX   ;;   0           = destcell = EBP...
     DEC EAX
     MOV     DpOddX0c,EAX   ;;-1
     MOV     DpOddX0d,EAX   ;;-1
     MOV     DpOddX1d,EAX   ;;-1
     MOV     DpOddX2c,EAX   ;;-1
     MOV     DpOddX2d,EAX   ;;-1
     MOV     DpOddX3d,EAX   ;;-1
     MOV     DpOddX1c,EAX   ;;-1           = destcell+1, EBP=-2 so -1..
     MOV     DpOddX3c,EAX   ;;-1           = destcell+1, EBP=-2 so -1..
     MOV     DpOddC0a,EAX   ;;  -1
     MOV     DpOddC2a,EAX   ;;  -1
     DEC EAX
     MOV     DpOddX3b_,EAX  ;;   0 -2
     MOV     DpOddC0a_,EAX  ;;  -2
     MOV     DpOddC2a_,EAX  ;;  -2
     MOV     DpOddC0b,EAX   ;;-1 -1   (- Xdimension + Xdimension) (wrap)
     MOV     DpOddC2b,EAX   ;;-1 -1   (- Xdimension + Xdimension) (wrap)

     MOV EAX,EBX
     ADD EAX,EDX ;+LineXsize
     INC EAX

     MOV     DpOddH2a,EAX   ;;  +1 + Xdimension  (wrap)
     MOV     DpOddH2b,EAX   ;;  +1 + Xdimension  (wrap)
     MOV     DpOddH3a,EAX   ;;  +1 + Xdimension
     MOV     DpOddH3b,EAX   ;;  +1 + Xdimension
     DEC EAX
     MOV     DpOddX0a,EAX   ;;   0 + Xdimension
     MOV     DpOddX0b,EAX   ;;   0 + Xdimension
     MOV     DpOddX2a,EAX   ;;   0 + Xdimension
     MOV     DpOddX2b,EAX   ;;   0 + Xdimension
     MOV     DpOddH2c,EAX   ;;-1+1 + Xdimension
     MOV     DpOddH2d,EAX   ;;-1+1 + Xdimension
     MOV     DpOddH3c,EAX   ;;-1+1 + Xdimension
     MOV     DpOddH3d,EAX   ;;-1+1 + Xdimension
     DEC EAX
     MOV     DpOddD3a,EAX   ;;  -1 + Xdimension
     MOV     DpOddD3a__,EAX   ;;  -1 + Xdimension
     DEC EAX
     MOV     DpOddD3b,EAX   ;;-1-1 + Xdimension

     MOV EAX,EBX
     SUB EAX,EDX ;-Xdimension=lineXsize
     INC EAX

     MOV     DpOddG0a,EAX   ;;  +1 - Xdimension (wrap)
     MOV     DpOddG2a,EAX   ;;  +1 - Xdimension (wrap)
     MOV     DpOddG1a,EAX   ;;  +1 - Xdimension
     MOV     DpOddG3a,EAX   ;;  +1 - Xdimension
     DEC EAX
     MOV     DpOddG0b,EAX   ;;-1+1 - Xdimension
     MOV     DpOddG1b,EAX   ;;-1+1 - Xdimension
     MOV     DpOddG2b,EAX   ;;-1+1 - Xdimension
     MOV     DpOddG3b,EAX   ;;-1+1 - Xdimension
     DEC EAX
     MOV     DpOddC1a,EAX   ;;  -1 - Xdimension
     MOV     DpOddC3a,EAX   ;;  -1 - Xdimension
     DEC EAX
     MOV     DpOddC1b,EAX   ;;-1-1 - Xdimension
     MOV     DpOddC3b,EAX   ;;-1-1 - Xdimension

     MOV EAX,EBX
     ADD EAX,EDX ;+Xdim
     SUB EAX,ECX ;-Totalsize
     INC EAX

     MOV     DpOddH0a,EAX   ;;  +1 + Xdimension  (wrap)      - TotalSize
     MOV     DpOddH0b,EAX   ;;  +1 + Xdimension  (wrap)      - TotalSize
     MOV     DpOddH1a,EAX   ;;  +1 + Xdimension - TotalSize
     MOV     DpOddH1b,EAX   ;;  +1 + Xdimension - TotalSize
     DEC EAX
     MOV     DpOddH0d,EAX   ;;-1+1 + Xdimension - TotalSize
     MOV     DpOddH0c,EAX   ;;-1+1 + Xdimension - TotalSize
     MOV     DpOddH1d,EAX   ;;-1+1 + Xdimension - TotalSize
     MOV     DpOddH1c,EAX   ;;-1+1 + Xdimension - TotalSize
     DEC EAX
     MOV     DpOddD1a,EAX   ;;  -1 + Xdimension - TotalSize
     DEC EAX
     MOV     DpOddD1b,EAX   ;;-1-1 + Xdimension - TotalSize

     MOV EAX,EBX
     ADD EAX,EDX
     ADD EAX,EDX ;+Xdim*2
     SUB EAX,ECX ;-totalssize

     MOV     DpOddH0a_,EAX  ;;   0 + Xdimension*2          - TotalSize
     DEC EAX
     MOV     DpOddD0a,EAX   ;;  -1 + Xdimension*2          - TotalSize
     DEC EAX
     MOV     DpOddD0b,EAX   ;;-1-1 + Xdimension*2          - TotalSize   (wrap)
     MOV     DpOddD0a_,EAX  ;;  -2 + Xdimension*2          - TotalSize


     MOV EAX,EBX
     ADD EAX,EDX
     ADD EAX,EDX ;+Xdim*2

     MOV     DpOddH2a_,EAX  ;;   0 + Xdimension*2
     DEC EAX
     MOV     DpOddD2a,EAX   ;;  -1 + Xdimension*2
     DEC EAX
     MOV     DpOddD2b,EAX   ;;-1-1 + Xdimension*2    (wrap)
     MOV     DpOddD2a_,EAX  ;;  -2 + Xdimension*2

     ;;;;;;;;;;;;;;;;;;;



     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

      MOV EBX,BW_WaterBitmap

      MOV EDX,BW_LineXSize
      ADD EDX,EDX ;;Xdimension*2 in EDX


     ;;  12  12    ResOdds: differ 2 ,use EBP*2, EBP gets+2, so now -2 diff
     ;;  34  34    2nd line =+ xdimension*2 (usually)
     ;;
     ;;  first line (0,1) 1&2 wrap up for all, and 1&3 wrap left for first pix
     ;; most lines only  1&3 wrap left for first pix
     ;;;;;;;;;;;;;;;;;;;;;;;

     MOV EAX,EBX ;BW_WaterBitmap

     MOV     ResOdd1_2a,EAX  ;;  -1 - Xdimension*2 +1      + Xdimension*2
     MOV     ResOdd1_0a,EAX  ;;  -1 - Xdimension*2 +1      + Xdimension*2

     INC EAX
     MOV     ResOdd4_1a,EAX  ;;   0                +1
     MOV     ResOdd4_3a,EAX  ;;   0                +1
     MOV     ResOdd2_0a,EAX  ;;   0 - Xdimension*2 +1      + Xdimension*2
     MOV     ResOdd2_2a,EAX  ;;   0 - Xdimension*2 +1      + Xdimension*2
     DEC EAX
     MOV     ResOdd3_1a,EAX  ;;  -1                +1
    if DUMMY
     MOV     ResOdd3_1a__,EAX  ;;  -1                +1
    endif
     MOV     ResOdd3_3a,EAX  ;;  -1                +1
    if DUMMY
     MOV     ResOdd3_3a__,EAX  ;;  -1                +1
    endif
     DEC EAX
     MOV     ResOdd4_0b,EAX  ;;-2 0                +1
     MOV     ResOdd4_1b,EAX  ;;-2 0                +1
     MOV     ResOdd4_2b,EAX  ;;-2 0                +1
     MOV     ResOdd4_3b,EAX  ;;-2 0                +1
     DEC EAX
     MOV     ResOdd3_0b,EAX  ;;-2-1                +1
     MOV     ResOdd3_1b,EAX  ;;-2-1                +1
     MOV     ResOdd3_2b,EAX  ;;-2-1                +1
     MOV     ResOdd3_3b,EAX  ;;-2-1                +1

     MOV EAX,EBX
     ADD EAX,EDX

     MOV     ResOdd3_0a,EAX  ;;  -1                +1      + Xdimension*2
     MOV     ResOdd3_2a,EAX  ;;  -1                +1      + Xdimension*2
     INC EAX
     MOV     ResOdd4_0a,EAX  ;;   0                +1      + Xdimension*2
     MOV     ResOdd4_2a,EAX  ;;   0                +1      + Xdimension*2

     MOV EAX,EBX
     SUB EAX,EDX

     INC EAX
     MOV     ResOdd2_1a,EAX  ;;   0 - Xdimension*2 +1
     ;;
     DEC EAX
     MOV     ResOdd1_1a,EAX  ;;  -1 - Xdimension*2 +1
    if DUMMY
     MOV     ResOdd1_1a__,EAX  ;;  -1 - Xdimension*2 +1
    endif
     MOV     ResOdd1_3a,EAX  ;;  -1 - Xdimension*2 +1
    if DUMMY
     MOV     ResOdd1_3a__,EAX  ;;  -1 - Xdimension*2 +1
    endif

     DEC EAX
     MOV     ResOdd2_0b,EAX  ;;-2 0 - Xdimension*2 +1
     MOV     ResOdd2_1b,EAX  ;;-2 0 - Xdimension*2 +1
     MOV     ResOdd2_2b,EAX  ;;-2 0 - Xdimension*2 +1
     MOV     ResOdd2_3b,EAX  ;;-2 0 - Xdimension*2 +1
     DEC EAX
     MOV     ResOdd1_0b,EAX  ;;-2-1 - Xdimension*2 +1
     MOV     ResOdd1_1b,EAX  ;;-2-1 - Xdimension*2 +1
     MOV     ResOdd1_2b,EAX  ;;-2-1 - Xdimension*2 +1
     MOV     ResOdd1_3b,EAX  ;;-2-1 - Xdimension*2 +1
     DEC EAX
     MOV     ResOdd2_3a_,EAX  ;;   0 - Xdimension*2 +1  -4 ;;

     MOV EAX,EBX
     ADD EAX,EDX
     ADD EAX,EDX


   RETN

   ;  MOV     ResOdd1_0a,EAX  ;;  -1                +1      + Xdimension*2
   ;  MOV     ResOdd3_0a,EAX  ;;  -1 + Xdimension*2 +1      + Xdimension*2
   ;  MOV     ResOdd1_2a,EAX  ;;  -1                +1      + Xdimension*2
   ;  MOV     ResOdd3_2a,EAX  ;;  -1 + Xdimension*2 +1      + Xdimension*2

align 16
BigWaterOdd PROC ;;; Odd field: CALCULATE it, but get info/pix from EVEN field
    ;;;;;;;;;;;;;;;;;;;;;;

    MOV EAX,PatchOddDetect
    CMP EAX,BW_WaterID
    JNE DoPatchOdd

    MOV EAX,LastBitMapOdd
    CMP EAX,BW_WaterBitmap
    JE SkipPatchOdd

    DoPatchOdd:
     Call PatchOdd01

    SkipPatchOdd:

    ;;;;;;;;;;;;;;;;;;;;;;
     MOV EBP,-1  ;; bumped to 'first odd -1' = 'last odd on that line-xsize'
     MOV [EndLineOdd1],EBP  ;; -EOL: will be bumped with xsize*2= 'line end..'

     MOV EAX,BW_TotalSize ;;
     MOV EBX,BW_LineXSize ;; END is at LAST-1 line of odd cells...
     SUB EAX,EBX
     SUB EAX,EBX
     DEC EAX
     MOV [EndFieldOdd1],EAX   ;; end of whole field...

     XOR EBX,EBX
     XOR ECX,ECX

    Call Odd1RepeatLines   ;; bumps up EBP and Endlineodd1 every time too...

    ;;;;;;;;;;;;;;;;;;;;;;;;;

                MOV EBX,BW_LineXSize
     MOV EAX,[EndLineOdd1] ;; last boundary..
     ADD EAX,EBX
     ADD EAX,EBX
     MOV [EndLineOdd0] ,EAX

     ;;; EBP remains where we ended,+ BW_LineXSize..
     ADD EBP,EBX

     XOR EBX,EBX
     XOR ECX,ECX

    Call Odd0DoLine

    ;;;;;;;;;;;;;;;;;;;;;;

    RETN

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;; FIRST tuple:
;;;;;;;;;;;;;  assume ECX = EBX = EAX = 0, at least the upper 24 bits.
;;;;;;;;;;;;;  EDX = sum of left two cells (E + F)
;;;;;;;;;;;;;
;;;;;;;;;;;;;  EBP at right cell
;;;;;;;;;;;;;
;;;;;;;;;;;;; last '4' = ESI =  H-D
;;;;;;;;;;;;; last '2' = EDI =  G-C + 4
;;;;;;;;;;;;; last sup = G+H

;;;; first EBP and [endlineodd0] set appropriately by caller !
;;;; EBX and ECX zero'd by caller

Odd0Doline label NEAR      ;;   very first Y entry

  XOR EAX,EAX

  ;;;; prepare ESI/EDI

  MOV AL,[byteEBP]
         org $-4
         DpOddH0a_ DD nil

  MOV EDX,EAX ;; EDX needs G+H

  MOV BL,[byteEBP]
         org $-4
         DpOddD0a_ DD nil

  SUB EAX,EBX
  MOV ESI,EAX

  MOV BL,[byteEBP]
         org $-4
         DpOddG0a_ DD nil
  ADD EAX,EBX
  ADD EDX,EBX  ;; EDX now G+H = 'E+F last sum' for next

  MOV BL,[byteEBP]
         org $-4
         DpOddC0a_ DD nil
  SUB EAX,EBX

  SAR EAX,1    ;; /2, signed

  MOV EDI,EAX

  XOR EAX,EAX

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;\\8 pixels..

  MOV CL,[byteEBP]
          org $-4
          DpOddD0a DD nil

  MOV BL,[byteEBP]  ;;
          org $-4
          DpOddH0a DD nil
  MOV AL,[byteEBP]   ;LL
          org $-4
          DpOddX0a DD nil

   SUB EBX,ECX     ;; 4 = H-D
  SUB EDX,EAX      ;LL EDX last sum E+F

   MOV CL,[byteEBP]  ;;
          org $-4
          DpOddC0a DD nil
  SUB EDX,EAX      ;LL

   MOV AL,ColorTable[ESI+EBX]  ;; nr 3 only one to use  4'
          org $-4
          CTbOddPatch0a DD nil
   MOV ESI,EBX     ;; save 4

   SUB EBX,ECX     ;;  3 = 4' + 4
   MOV CL,[byteEBP]  ;;
          org $-4
          DpOddG0a DD nil

   MOV [byteEBP2],AL  ;;
          org $-4
          ResOdd3_0a DD nil
   ADD EBX,ECX     ;;  2 = 4 +  G-C

   SAR EBX,1       ;; must be shifted right.. cuz COMPOUND index. 1/4 cyc per pix xtra
  MOV AL,[byteEBP]   ;LL ECX already G
          org $-4
          DpOddH0b DD nil

  ADD ECX,EAX      ;LL ECX now G+H    ;; ECX no longer ooooxxxx !
   MOV AL,ColorTable[ESI*2]   ;; 4
          org $-4
          CTbOddPatch0b DD nil

   MOV [byteEBP2],AL
          org $-4
          ResOdd4_0a DD nil
   MOV AL,ColorTable[EDI+EBX] ;; 2' + 2
          org $-4
          CTbOddPatch0c DD nil

   MOV EDI,EBX
   MOV [byteEBP2],AL
          org $-4
          ResOdd1_0a DD nil

   MOV AL,ColorTable[EBX*2]     ;; 2
          org $-4
          CTbOddPatch0d DD nil

  MOV BL,[AdvB+EDX+ECX] ;LL  EAX= ResOdd    ECX is new E+F, only one worth save
          org $-4
          WTbOddPatch0a DD nil
   MOV [byteEBP2],AL
          org $-4
          ResOdd2_0a DD nil

  MOV [byteEBP],BL   ;LL  'main' save;
          org $-4
          DpOddX0b DD nil

 ADD EBP,2                       ;; EBP increase....

   XOR EDX,EDX
  XOR EBX,EBX

 ;;;;;;;;;;;;;;;;;;;;;;;;;

   MOV DL,[byteEBP]
          org $-4
          DpOddD0b DD nil

   MOV BL,[byteEBP]  ;;
          org $-4
          DpOddH0c DD nil
  MOV AL,[byteEBP]   ;LL
          org $-4
          DpOddX0c DD nil

   SUB EBX,EDX     ;; 4 = H-D
  SUB ECX,EAX      ;LL ECX last sum E+F

   MOV DL,[byteEBP]  ;;
          org $-4
          DpOddC0b DD nil
  SUB ECX,EAX      ;LL

   MOV AL,ColorTable[ESI+EBX]  ;; nr 3 only one to use  4'
          org $-4
          CTbOddPatch0e DD nil
   MOV ESI,EBX     ;; save 4

   SUB EBX,EDX     ;;  3 = 4' + 4
   MOV DL,[byteEBP]  ;;
          org $-4
          DpOddG0b DD nil

   MOV [byteEBP2],AL  ;;
          org $-4
          ResOdd3_0b DD nil
   ADD EBX,EDX     ;;  2 = 4 +  G-C

   SAR EBX,1       ;; must be shifted right.. cuz COMPOUND index. 1/4 cyc per pix xtra
                   ;; U-pipe pairable
  MOV AL,[byteEBP]   ;LL EDX already G
          org $-4
          DpOddH0d DD nil

  ADD EDX,EAX      ;LL EDX now G+H    ;; EDX no longer ooooxxxx !
   MOV AL,ColorTable[ESI*2]   ;; 4
          org $-4
          CTbOddPatch0f DD nil

   MOV [byteEBP2],AL
          org $-4
          ResOdd4_0b DD nil
   MOV AL,ColorTable[EDI+EBX] ;; 2' + 2
          org $-4
          CTbOddPatch0g DD nil

   MOV EDI,EBX
   MOV [byteEBP2],AL
          org $-4
          ResOdd1_0b DD nil

   MOV AL,ColorTable[EBX*2]     ;; 2
          org $-4
          CTbOddPatch0h DD nil
  MOV BL,[AdvB+ECX+EDX] ;LL  EAX= ResOdd    EDX is new E+F, only one worth save
          org $-4
          WTbOddPatch0b DD nil

   MOV [byteEBP2],AL
          org $-4
          ResOdd2_0b DD nil
   XOR ECX,ECX

  MOV [byteEBP],BL   ;;LL  'main' save;
          org $-4
          DpOddX0d DD nil
  XOR EBX,EBX

  jmp Odd0RepeatCore


align 16 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

           ;;\\  X loop start
Odd0RepeatCore label NEAR ;;\\ vars 0, subindex A or B...

 ;;;  dummy reads from RESULT locations
 ;;;  to load the 32-byte cache lines

 if DUMMY
  MOV BL,[byteEBP2]
          org $-4
          ResOdd1_1a__ DD nil;; primes the P5 cache for WRITES ..
  MOV AL,[byteEBP2]
          org $-4
          ResOdd3_1a__ DD nil
 endif



  MOV CL,[byteEBP]
          org $-4
          DpOddD1a DD nil

  MOV BL,[byteEBP]  ;;
          org $-4
          DpOddH1a DD nil
  MOV AL,[byteEBP]   ;LL
          org $-4
          DpOddX1a DD nil

   SUB EBX,ECX     ;; 4 = H-D
  SUB EDX,EAX      ;LL EDX last sum E+F

   MOV CL,[byteEBP]  ;;
          org $-4
          DpOddC1a DD nil
  SUB EDX,EAX      ;LL

   MOV AL,ColorTable[ESI+EBX]  ;; nr 3 only one to use  4'
          org $-4
          CTbOddPatch1a DD nil
   MOV ESI,EBX     ;; save 4

   SUB EBX,ECX     ;;  3 = 4' + 4
   MOV CL,[byteEBP]  ;;
          org $-4
          DpOddG1a DD nil

   MOV [byteEBP2],AL  ;;
          org $-4
          ResOdd3_1a DD nil
   ADD EBX,ECX     ;;  2 = 4 +  G-C

   SAR EBX,1       ;; must be shifted right.. cuz COMPOUND index. 1/4 cyc per pix xtra
  MOV AL,[byteEBP]   ;LL ECX already G
          org $-4
          DpOddH1b DD nil

  ADD ECX,EAX      ;LL ECX now G+H    ;; ECX no longer ooooxxxx !
   MOV AL,ColorTable[ESI*2]   ;; 4
          org $-4
          CTbOddPatch1b DD nil

   MOV [byteEBP2],AL
          org $-4
          ResOdd4_1a DD nil
   MOV AL,ColorTable[EDI+EBX] ;; 2' + 2
          org $-4
          CTbOddPatch1c DD nil

   MOV EDI,EBX
   MOV [byteEBP2],AL
          org $-4
          ResOdd1_1a DD nil

   MOV AL,ColorTable[EBX*2]     ;; 2
          org $-4
          CTbOddPatch1d DD nil

  MOV BL,[AdvB+EDX+ECX] ;LL  EAX= ResOdd    ECX is new E+F, only one worth save
          org $-4
          WTbOddPatch1a DD nil
   MOV [byteEBP2],AL
          org $-4
          ResOdd2_1a DD nil

  MOV [byteEBP],BL   ;LL  'main' save;
          org $-4
          DpOddX1b DD nil
 ADD EBP,2                       ;; EBP increase....

   XOR EDX,EDX
  XOR EBX,EBX

 ;;;;;;;;;;;;;;;;;;;;;;;;;

   MOV DL,[byteEBP]
          org $-4
          DpOddD1b DD nil

   MOV BL,[byteEBP]  ;;
          org $-4
          DpOddH1c DD nil
  MOV AL,[byteEBP]   ;LL
          org $-4
          DpOddX1c DD nil

   SUB EBX,EDX     ;; 4 = H-D
  SUB ECX,EAX      ;LL ECX last sum E+F

   MOV DL,[byteEBP]  ;;
          org $-4
          DpOddC1b DD nil
  SUB ECX,EAX      ;LL

   MOV AL,ColorTable[ESI+EBX]  ;; nr 3 only one to use  4'
          org $-4
          CTbOddPatch1e DD nil
   MOV ESI,EBX     ;; save 4

   SUB EBX,EDX     ;;  3 = 4' + 4
   MOV DL,[byteEBP]  ;;
          org $-4
          DpOddG1b DD nil

   MOV [byteEBP2],AL  ;;
          org $-4
          ResOdd3_1b DD nil
   ADD EBX,EDX     ;;  2 = 4 +  G-C

   SAR EBX,1       ;; must be shifted right.. cuz COMPOUND index. 1/4 cyc per pix xtra
                   ;; U-pipe pairable
  MOV AL,[byteEBP]   ;LL EDX already G
          org $-4
          DpOddH1d DD nil

  ADD EDX,EAX      ;LL EDX now G+H    ;; EDX no longer ooooxxxx !
   MOV AL,ColorTable[ESI*2]   ;; 4
          org $-4
          CTbOddPatch1f DD nil

   MOV [byteEBP2],AL
          org $-4
          ResOdd4_1b DD nil
   MOV AL,ColorTable[EDI+EBX] ;; 2' + 2
          org $-4
          CTbOddPatch1g DD nil

   MOV EDI,EBX
   MOV [byteEBP2],AL
          org $-4
          ResOdd1_1b DD nil

   MOV AL,ColorTable[EBX*2]     ;; 2
          org $-4
          CTbOddPatch1h DD nil
  MOV BL,[AdvB+ECX+EDX] ;LL  EAX= ResOdd    EDX is new E+F, only one worth save
          org $-4
          WTbOddPatch1b DD nil

   MOV [byteEBP2],AL
          org $-4
          ResOdd2_1b DD nil
   XOR ECX,ECX

  MOV [byteEBP],BL   ;;LL  'main' save;
          org $-4
          DpOddX1d DD nil
  XOR EBX,EBX

  CMP EBP,011111111h ;; EndlineOdd
          org $-4
          EndLineOdd0 DD nil

  JB  Odd0RepeatCore           ;;// X loop end
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RETN ;;// Odd0





;;///////// Odd 1

Odd1RepeatLines label NEAR      ;; \\ Y loop start

  ;;;calc. new end-of-line value & EBP

  MOV EAX,BW_LineXsize
  ADD EBP,EAX ;;+BW_LineXSize ;; 'skip' a line, which is the other field.

  ADD EAX,EAX
  ADD [EndLineOdd1],EAX ;; end-of ODD only/ Odd only, 2 lines onward.

;;;; first EBP and [endlineOdd1] and [endfieldOdd1] set appropriately by caller !
;;;; EBX and ECX zero'd by caller

;;Odd1Doline:        ;;   very first Y entry

  XOR EAX,EAX

  ;;;; prepare ESI/EDI

  MOV AL,[byteEBP]
         org $-4
         DpOddH2a_ DD nil

  MOV EDX,EAX ;; EDX needs G+H

  MOV BL,[byteEBP]
         org $-4
         DpOddD2a_ DD nil

  SUB EAX,EBX
  MOV ESI,EAX

  MOV BL,[byteEBP]
         org $-4
         DpOddG2a_ DD nil
  ADD EAX,EBX
  ADD EDX,EBX  ;; EDX now G+H = 'E+F last sum' for next

  MOV BL,[byteEBP]
         org $-4
         DpOddC2a_ DD nil
  SUB EAX,EBX

  SAR EAX,1    ;; /2, signed

  MOV EDI,EAX

  XOR EAX,EAX

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;\\8 pixels..

  MOV CL,[byteEBP]
          org $-4
          DpOddD2a DD nil

  MOV BL,[byteEBP]  ;;
          org $-4
          DpOddH2a DD nil
  MOV AL,[byteEBP]   ;LL
          org $-4
          DpOddX2a DD nil

   SUB EBX,ECX     ;; 4 = H-D
  SUB EDX,EAX      ;LL EDX last sum E+F

   MOV CL,[byteEBP]  ;;
          org $-4
          DpOddC2a DD nil
  SUB EDX,EAX      ;LL

   MOV AL,ColorTable[ESI+EBX]  ;; nr 3 only one to use  4'
          org $-4
          CTbOddPatch2a DD nil
   MOV ESI,EBX     ;; save 4

   SUB EBX,ECX     ;;  3 = 4' + 4
   MOV CL,[byteEBP]  ;;
          org $-4
          DpOddG2a DD nil

   MOV [byteEBP2],AL  ;;
          org $-4
          ResOdd3_2a DD nil
   ADD EBX,ECX     ;;  2 = 4 +  G-C

   SAR EBX,1       ;; must be shifted right.. cuz COMPOUND index. 1/4 cyc per pix xtra
  MOV AL,[byteEBP]   ;LL ECX already G
          org $-4
          DpOddH2b DD nil

  ADD ECX,EAX      ;LL ECX now G+H    ;; ECX no longer ooooxxxx !
   MOV AL,ColorTable[ESI*2]   ;; 4
          org $-4
          CTbOddPatch2b DD nil

   MOV [byteEBP2],AL
          org $-4
          ResOdd4_2a DD nil
   MOV AL,ColorTable[EDI+EBX] ;; 2' + 2
          org $-4
          CTbOddPatch2c DD nil

   MOV EDI,EBX
   MOV [byteEBP2],AL
          org $-4
          ResOdd1_2a DD nil

   MOV AL,ColorTable[EBX*2]     ;; 2
          org $-4
          CTbOddPatch2d DD nil

  MOV BL,[AdvB+EDX+ECX] ;LL  EAX= ResOdd    ECX is new E+F, only one worth save
          org $-4
          WTbOddPatch2a DD nil
   MOV [byteEBP2],AL
          org $-4
          ResOdd2_2a DD nil

  MOV [byteEBP],BL   ;LL  'main' save;
          org $-4
          DpOddX2b DD nil
 ADD EBP,2                       ;; EBP increase....

   XOR EDX,EDX
  XOR EBX,EBX

 ;;;;;;;;;;;;;;;;;;;;;;;;;

   MOV DL,[byteEBP]
          org $-4
          DpOddD2b DD nil

   MOV BL,[byteEBP]  ;;
          org $-4
          DpOddH2c DD nil
  MOV AL,[byteEBP]   ;LL
          org $-4
          DpOddX2c DD nil

   SUB EBX,EDX     ;; 4 = H-D
  SUB ECX,EAX      ;LL ECX last sum E+F

   MOV DL,[byteEBP]  ;;
          org $-4
          DpOddC2b DD nil
  SUB ECX,EAX      ;LL

   MOV AL,ColorTable[ESI+EBX]  ;; nr 3 only one to use  4'
          org $-4
          CTbOddPatch2e DD nil
   MOV ESI,EBX     ;; save 4

   SUB EBX,EDX     ;;  3 = 4' + 4
   MOV DL,[byteEBP]  ;;
          org $-4
          DpOddG2b DD nil

   MOV [byteEBP2],AL  ;;
          org $-4
          ResOdd3_2b DD nil
   ADD EBX,EDX     ;;  2 = 4 +  G-C

   SAR EBX,1       ;; must be shifted right.. cuz COMPOUND index. 1/4 cyc per pix xtra
                   ;; U-pipe pairable
  MOV AL,[byteEBP]   ;LL EDX already G
          org $-4
          DpOddH2d DD nil

  ADD EDX,EAX      ;LL EDX now G+H    ;; EDX no longer ooooxxxx !
   MOV AL,ColorTable[ESI*2]   ;; 4
          org $-4
          CTbOddPatch2f DD nil

   MOV [byteEBP2],AL
          org $-4
          ResOdd4_2b DD nil
   MOV AL,ColorTable[EDI+EBX] ;; 2' + 2
          org $-4
          CTbOddPatch2g DD nil

   MOV EDI,EBX
   MOV [byteEBP2],AL
          org $-4
          ResOdd1_2b DD nil

   MOV AL,ColorTable[EBX*2]     ;; 2
          org $-4
          CTbOddPatch2h DD nil
  MOV BL,[AdvB+ECX+EDX] ;LL  EAX= ResOdd    EDX is new E+F, only one worth save
          org $-4
          WTbOddPatch2b DD nil

   MOV [byteEBP2],AL
          org $-4
          ResOdd2_2b DD nil
   XOR ECX,ECX

  MOV [byteEBP],BL   ;;LL  'main' save;
          org $-4
          DpOddX2d DD nil
  XOR EBX,EBX

  MOV CL,[byteEBP]
          org $-4
          DpOddD3a DD nil

  jmp Odd1RepeatCore


align 16 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

           ;;\\  X loop start
Odd1RepeatCore label NEAR ;;\\ vars 0, subindex A or B...

 ;;;  dummy reads from RESULT locations
 ;;;  to load the 32-byte cache lines

 if DUMMY
 MOV AL,[byteEBP2]
         org $-4
         ResOdd3_3a__ DD nil;; primes the P5 cache for WRITES ..
 endif



  MOV BL,[byteEBP]  ;;
          org $-4
          DpOddH3a DD nil


  MOV AL,[byteEBP]   ;LL
          org $-4
          DpOddX3a DD nil

   SUB EBX,ECX     ;; 4 = H-D


 if DUMMY
 MOV CL,[byteEBP2]
         org $-4
         ResOdd1_3a__ DD nil ;; primes P5 cache
 endif


  SUB EDX,EAX      ;LL EDX last sum E+F


   MOV CL,[byteEBP]  ;;
          org $-4
          DpOddC3a DD nil
  SUB EDX,EAX      ;LL

   MOV AL,ColorTable[ESI+EBX]  ;; nr 3 only one to use  4'
          org $-4
          CTbOddPatch3a DD nil
   MOV ESI,EBX     ;; save 4

   SUB EBX,ECX     ;;  3 = 4' + 4
   MOV CL,[byteEBP]  ;;
          org $-4
          DpOddG3a DD nil

   MOV [byteEBP2],AL  ;;
          org $-4
          ResOdd3_3a DD nil
   ADD EBX,ECX     ;;  2 = 4 +  G-C

   SAR EBX,1       ;; must be shifted right.. cuz COMPOUND index. 1/4 cyc per pix xtra
   MOV AL,[byteEBP]   ;LL ECX already G
          org $-4
          DpOddH3b DD nil

   ADD ECX,EAX      ;LL ECX now G+H    ;; ECX no longer ooooxxxx !
   MOV AL,ColorTable[ESI*2]   ;; 4
          org $-4
          CTbOddPatch3b DD nil

   MOV [byteEBP2],AL
          org $-4
          ResOdd4_3a DD nil
   MOV AL,ColorTable[EDI+EBX] ;; 2' + 2
          org $-4
          CTbOddPatch3c DD nil

   MOV EDI,EBX
   MOV [byteEBP2],AL
          org $-4
          ResOdd1_3a DD nil

   ADD EBP,2                       ;; EBP increase....
   MOV AL,ColorTable[EBX*2]     ;; 2
          org $-4
          CTbOddPatch3d DD nil

  MOV BL,[AdvB+EDX+ECX] ;LL  EAX= ResOdd    ECX is new E+F, only one worth save
          org $-4
          WTbOddPatch3a DD nil
  XOR EDX,EDX

  MOV [byteEBP],BL   ;LL  'main' save;
          org $-4
          DpOddX3b_ DD nil      ;; EBP now BEFORE it  -> patch with -2..
  XOR EBX,EBX


   MOV DL,[byteEBP]        ;;.
          org $-4          ;;.
          DpOddD3b DD nil  ;;.
  MOV [byteEBP2],AL
          org $-4
          ResOdd2_3a_ DD nil    ;; EBP now BEFORE it  -> patch with -4..
 ;;;;;;;;;;;;;;;;;;;;;;;;;

  MOV AL,[byteEBP]   ;LL
          org $-4
          DpOddX3c DD nil
   MOV BL,[byteEBP]  ;;
          org $-4
          DpOddH3c DD nil

  SUB ECX,EAX      ;LL ECX last sum E+F
   SUB EBX,EDX     ;; 4 = H-D

   MOV DL,[byteEBP]  ;;
          org $-4
          DpOddC3b DD nil
  SUB ECX,EAX      ;LL

   MOV AL,ColorTable[ESI+EBX]  ;; nr 3 only one to use  4'
          org $-4
          CTbOddPatch3e DD nil
   MOV ESI,EBX     ;; save 4

   SUB EBX,EDX     ;;  3 = 4' + 4
   MOV DL,[byteEBP]  ;;
          org $-4
          DpOddG3b DD nil

   MOV [byteEBP2],AL  ;;
          org $-4
          ResOdd3_3b DD nil
   ADD EBX,EDX     ;;  2 = 4 +  G-C

   SAR EBX,1       ;; must be shifted right.. cuz COMPOUND index. 1/4 cyc per pix xtra
                   ;; U-pipe pairable
  MOV AL,[byteEBP]   ;LL EDX already G
          org $-4
          DpOddH3d DD nil

  ADD EDX,EAX      ;LL EDX now G+H    ;; EDX no longer ooooxxxx !
   MOV AL,ColorTable[ESI*2]   ;; 4
          org $-4
          CTbOddPatch3f DD nil

   MOV [byteEBP2],AL
          org $-4
          ResOdd4_3b DD nil
   MOV AL,ColorTable[EDI+EBX] ;; 2' + 2
          org $-4
          CTbOddPatch3g DD nil

   MOV EDI,EBX
   MOV [byteEBP2],AL
          org $-4
          ResOdd1_3b DD nil

   MOV AL,ColorTable[EBX*2]     ;; 2
          org $-4
          CTbOddPatch3h DD nil
  MOV BL,[AdvB+ECX+EDX] ;LL  EAX= ResOdd    EDX is new E+F, only one worth save
          org $-4
          WTbOddPatch3b DD nil

   MOV [byteEBP2],AL
          org $-4
          ResOdd2_3b DD nil
   XOR ECX,ECX

  MOV [byteEBP],BL   ;;LL  'main' save;
          org $-4
          DpOddX3d DD nil
  XOR EBX,EBX


  CMP EBP,011111111h ;; EndlineOdd
          org $-4
          EndLineOdd1 DD nil
  MOV CL,[byteEBP]
          org $-4
          DpOddD3a__ DD nil     ;; Duplicate! patch same as original

  JB  Odd1RepeatCore            ;; // X loop end
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


  CMP EBP,011111111h ;; EndFieldOdd
          org $-4
          EndFieldOdd1 DD nil
  JB  Odd1RepeatLines

;;;;;;;;;;;;;;;;;;;;;;;;;;; about 29 cyc/ 8 pix = 3.7 per pixel..



  RETN ;;//Odd1


BigWaterOdd ENDP

;============================================================================





.CODE

CalcWaterASM PROC      PBitmap:DWORD, \
                       PWavMap:DWORD, \
                    PRendTable:DWORD, \
                    PWaveTable:DWORD, \
                          XVar:DWORD, \
                          YVar:DWORD, \
                        Parity:DWORD

 ;; VARIABLES: Bitmap pointer,
 ;;            Table pointer,
 ;;            Remap-palette pointer,
 ;;            Xsize,
 ;;            Ysize

 MOV EAX,PBitmap
 MOV EDX,PWavMap
 MOV BW_WaterBitmap  ,EAX
 MOV BW_WaveMaps     ,EDX

 MOV EAX,PRendTable
 MOV ECX,PWaveTable
 MOV BW_RenderTable  ,EAX
 MOV BW_WaveTable ,ECX

 MOV EAX,XVar
 MOV EDX,YVar

 SHR EAX,1 ; 3 out of 4 pixels are interpolated so use 1/2 sized wave bitmap !
 SHR EDX,1 ;

 MOV BW_LineXSize ,EAX
 MOV BW_LineYSize ,EDX

   MUL EDX ;; calculate total size... *2 since ODD and EVEN in one field !
   ADD EAX,EAX
   MOV BW_TotalSize,EAX

 MOV EAX,PBitmap        ;; use bitmap address as ID code.
 MOV BW_WaterID,EAX

  PUSH EBX
  PUSH EBP
  PUSH ESI
  PUSH EDI

  Test byte ptr [Parity],1
  jz GoEven
  Call BigWaterOdd
  jmp short OverEven

  GoEven:
  Call BigWaterEven
  OverEven:

  POP EDI
  POP ESI
  POP EBP
  POP EBX

 RET

CalcWaterASM ENDP

END


