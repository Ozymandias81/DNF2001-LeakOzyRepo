;///////////////////////////////////////////////////////////////////////////
;//
;//  UnFire.asm  -  self-modifying code optimized for regular/MMX Pentiums.
;//
;//  version 1.1   December  1997
;//  version 1.2   September 1998 - fixed speculative read causing memory GPF
;//
;//  This is a part of the Unreal Texture Animation Engine code.
;//  Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.
;//
;////////////////////////////////////////////////////////////////////////////
;
;------------------------------------------------------------------
; MASM 6.11d code   for Win95 VC++ 5.0 flat model
;
; Filename: UnFire.ASM
;
; default options : ML /c /Cx /coff  UnFire.asm
;
; Assemble/build syntax  in Microsoft Developer Studio:
;
;   Build->Settings->[select UnFire] ->Custom build:
;
;   ML /c /Cx /coff  /Fo$(OutDir)\UnFire.obj UnFire.asm
;
; add  /Zd /Zi /Zf  switches to generate debug/browser info.
; add  /W0 to ignore the 'line number info for non-CODE segment' warning.
;
;
; Code contents:
;
; in .DATA :
;
; SelfModFire        fire update code
; SelfModFireWrap    fire update code with wraparound
;
; in .CODE :
;
; CalculateFire      entry for fire algorithm, calls SelfModFire
; CalcWrapFire       entry for fire algorithm, calls SelfModFireWrap
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


.586                 ; 
                     ; .MODEL ... C tells the assembler that 
.MODEL flat , C      ; parameters  are pushed from right to left.


.DATA

assume CS: _DATA    ; needed for assembling code in the data segment

EXTERNDEF SpeedRindex:DWORD;
EXTERNDEF PhaseTable:BYTE;    // actually = PHASETABLE ARRAY[0], 256 bytes.
EXTERNDEF LTimeTotal1:DWORD;  // extern DOUBLE LTimeTotal1, LTimeTotal2, LinePixels;
EXTERNDEF LTimeTotal2:DWORD;
EXTERNDEF LinePixels:DWORD;

;==================================

 Advb EQU byte ptr [011111111h]   ;; dummy offsets to patch later
 Advw EQU word ptr [011111111h]


;==================================

;; All variables here

align 16
Wrap2TempLines label DWORD
               DB (512 + 32) dup (0)

;;; misc temp pointers

 FireBitMap			DD 0
 RenderTable		DD 0
 LocalLineXSize		DD 0
 LocalLineYSize		DD 0
 EndLineCheck		DD 0
 WEndBitmapCheck	DD 0
 WBitmapSize		DD 0
 SWBitmapSize		DD 0
 FirstCellSaved     DD 0


;================================================================
;; separate code from data by at least a few cache-lines...
align 16
nop
align 16
nop
align 16
nop
align 16

SelfModFireWrap PROC

   ;;;;;;;;;;;;;;;
   ;;
   ;;             d1 d2       = BP    0 1
   ;;  cells    0  1  2  3    = SI -1 0 1 2         [+line]
   ;;              a  b       = DI    0 1           [+line+line]
   ;;
   ;; Bitmap:
   ;;  0 ....1n-1         xn = 'LastPixel'
   ;;  1n....2n-1
   ;;  2n....3n-1
   ;;  ..
   ;;  xn....
   ;;
   ;;;;;;;;;;;;;;;

   MOV EAX,RenderTable

   MOV WTable_Patch1,EAX
   MOV WTable_Patch1b,EAX
   MOV WTable_Patch2,EAX
   MOV WTable_Patch3,EAX
   MOV WTable_Patch4,EAX
   MOV WTable_Patch5,EAX

   ;.................... Patch all the indexes / line-increments

   Call CopyFirst2Lines  ;;! for perfect wrapping...

   ;.DO first Y-2 lines -.. ; init registers to jump into inner loop

   ;; Patch cell line 1
   MOV EAX,LocalLineXSize

   call PatchCellLine1

   ;;; Patch Cell Line 2

   MOV EAX,LocalLineXSize
   ADD EAX,EAX
   call PatchCellLine2

   MOV  EBP,FireBitMap

   MOV  EBX,LocalLineYSize


   SUB  EBX,2 ;; last 2 lines not calculated

   MOV  EAX,[LocalLineXSize]

   MUL  EBX   ;; result in (EDX):EAX

   MOV  WBitmapSize,EAX

   ADD  EAX,EBP ;; plus start of bitmap..

   MOV  [WEndBitmapCheck], EAX

   Call WstartYLoop  ; first Y-2 lines

   ;.......................
   ;.DO line Y-2 line

   ;; Patch cell line 1: normal, so leave unpatched..
   ;;MOV EAX,LocalLineXSize
   ;;call PatchCellLine1

   ;;; Patch Cell Line 2 ;; instead of + 2*Xsize, now "- (Ysize-2)*Xsize"

   ;;MOV EAX,WBitmapSize ;;== (Ysize-2)*Xsize
   ;;NEG EAX ;; use this negative to patch cell line 2
   ;;now it's  relative to access stored 2 lines: Wrap2TempLines

   mov  eax, offset Wrap2TempLines
   sub  eax, FireBitmap
   sub  eax, WBitmapSize

   call PatchCellLine2

   ;;;MOV  EBP,FireBitmap ;use EBP as it was returned...

   MOV  EAX,LocalLineXSize
   ADD  WEndBitmapCheck, EAX ;; new limit one line further...

   Call WstartYLoop  ; do line Y-2

   ;.......................
   ;.DO line Y-1 line

   ;;point celline1 to Wrap2TempLines...
   mov eax, offset Wrap2TempLines
   sub eax, FireBitmap
   sub eax, WBitmapSize
   sub eax, LocalLineXSize

   call PatchCellLine1

   ; cell line 2 already patched to wrap around..
   ; keep EBP as it was returned ...

   MOV  EAX,LocalLineXSize
   ADD  [WEndBitmapCheck], EAX ;; new limit one line further...

   Call WstartYLoop  ; do line Y-1
   ;.......................

   RET


;============================
CopyFirst2Lines label near
   MOV ECX,LocalLineXSize
   MOV ESI,FireBitMap
   MOV EDI,offset Wrap2TempLines
   SHR ECX,1              ;; /4 for dwords *2 for 2 lines

   ;;cmp ecx,128+10   ;; old check for size overflow
   ;;ja  skipmoveline

   ;;todo: - better to use cache warming...
   REP MOVSD           ;; forget it anyway if it's smaller than 4 pixels !
   ;; skipmoveline:

ret

;============================
 PatchCellLine1 label near

   MOV ECX,EAX ;save

   MOV WCell1_Patch0,EAX

   INC EAX
   MOV WCell2_Patch0,EAX
   MOV WCell2_Patch2,EAX

   MOV EBX,EAX
   ADD EBX,2
   MOV WCell2_Patch1_p2,EBX

   INC EAX
   MOV WCell3_Patch1,EAX

   SUB EAX,2
   MOV WCell3_Patch2_n2,EAX

   ;;;;;;;;;;;

   MOV EAX,ECX    ;; LocalLineXSize=EAX? -> not always!
   ADD EAX,LocalLineXSize ;; go to end of line, whatever ECX was...
   DEC EAX
   MOV WCell0_WrapPatch0,EAX ;; put in (+X-1) := as for Cell2 -2...
   ;;;like WCell1_Patch0 but +( Xsize -1)

   MOV EAX,ECX
   SUB EAX,LocalLineXSize ;; to beginning of line whatever ECX was

   ADD EAX,2 -2 ;; end of row, - Xsize (+2 for addressing cell3)
                ;; -2 for EBP bias.. ==0 !
   MOV WCell3_WrapPatch0_n2,EAX ;; put in (-X-?) := as for cell2 +1
   ;;;;;;;;;

 RETN

;============================
 PatchCellLine2 label near ;; 2xXSIZE first, neg WBITMAPSIZE(fromY-2) at last
                           ;; true wrap: do the STORED 2 lines here on 2nd go
                           ;; but: need RELATIVE to where they WOULD
                           ;; be which is WBITMAPSIZE+bitmap address !
   MOV WCellA_Patch0,EAX
   MOV WCellA_Patch1,EAX

   MOV EBX,EAX
   ADD EBX,2
   MOV WCellA_Patch2_p2,EBX

   INC EAX
   MOV WCellB_Patch1,EAX

   SUB EAX,2
   MOV WCellB_Patch2_n2,EAX
   MOV WCellB_Patch3_n2,EAX

 RETN
;============================




 ;;========= Y-loop \\
 align 4

 WstartYLoop label near
 WIntoCoreY:

 ;; EndLineCheck must be the loc. of next line..
 ;; ZERO the relevant registers

 MOV ECX,[LocalLineXSize]

   XOR EBX,EBX

 ADD ECX,EBP

   XOR EAX,EAX

 MOV [EndLineCheck],ECX

 ;;;;; EBP points to first destination-pixel in the line.

  MOV BL,Advb[EBP]
         org $-4
         WCell0_WrapPatch0 DD 0  ;; get WRAP-around left value = end of line..

  MOV AL,Advb[EBP]
         org $-4
         WCell1_Patch0 DD 0


  MOV ESI,EAX ;;Cell1

  MOV AL,Advb[EBP]
         org $-4
         WCell2_Patch0 DD 0


  MOV EDI,EBX ;; XOR EDI,EDI ;; Cell0 == 0, or wrap-around value

  MOV BL,Advb[EBP]          ;; CellA
         org $-4
         WCellA_Patch0 DD 0

  ADD ESI,EAX               ;; ESI has Cell1
  ADD EDI,EBX               ;; EDI has Cell0


  MOV DL,Advb[EDI+ESI] ;; ESI=Cell1+Cell2 , used in both lookups
         org $-4
         WTable_Patch1b DD 0     ;; AGI

  jmp short WEnterCoreX     ;; ecx = don't care




 align 4 

 WIntoCoreX:

  MOV   AL,Advb[EBP]   ;;Cell3 used twice - next 'Cell1'
         org $-4
         WCell3_Patch2_n2 DD 0

  MOV BL,Advb[EBP]   ;; UV
         org $-4
         WCellB_Patch2_n2 DD 0

  ADD ECX,EAX        ;; UV


  MOV ESI,EAX        ;; UV

  MOV AL,Advb[EBP]   ;;pre-load: Cell2  used twice - next 'Cell0'
         org $-4
         WCell2_Patch2 DD 0


  MOV DH,Advb[EBX+ECX]   ;;no AGI if pairing as expected
         org $-4
         WTable_Patch4 DD 0
  ;---------------------------- making pixel 0,1
  MOV BL,Advb[EBP]          ;; CellA
         org $-4
         WCellA_Patch1 DD 0

  ADD ESI,EAX               ;; ESI has Cell1
  ADD EDI,EBX               ;; EDI has Cell0

  ROL EDX,16
  NOP

  ;;MOV [EBP-2],DX    ;; U pipe only (16-bit prefix)
  MOV [EBP-4],EDX     ;;
  ;; WEnterCoreX:
  MOV DL,Advb[EDI+ESI] ;; ESI=Cell1+Cell2 , used in both lookups
         org $-4
         WTable_Patch1 DD 0     ;; AGI but shaded by 16-bit prefix...
WEnterCoreX:


  MOV EDI,EAX
  MOV AL,Advb[EBP]   ;;Cell3 used twice - next 'Cell1'
         org $-4
         WCell3_Patch1 DD 0


  MOV BL,Advb[EBP]   ;;CellB
         org $-4
         WCellB_Patch1 DD 0
  ADD ESI,EAX


  MOV ECX,EAX

  MOV AL,Advb[EBP]   ;;Cell2  used twice - next 'Cell0'
         org $-4
         WCell2_Patch1_p2 DD 0


  MOV DH,Advb[EBX+ESI] ;; no AGI if pairing as expected
         org $-4
         WTable_Patch2   DD 0
  ;---------------------------- making pixel 2,3
  MOV   BL,Advb[EBP]
            org $-4
            WCellA_Patch2_p2 DD 0

  ADD   ECX,EAX     ;;
  ADD   EDI,EBX     ;;

  ;;MOV   [EBP+0],DX  ;; U  #debug

  SHL   EDX,16
  ADD   EBP,4       ;;

  MOV   ESI,[EndLineCheck]
  MOV   DL,Advb[EDI+ECX] ;; ECX=Cell1+Cell2 , used in both lookups
         org $-4
         WTable_Patch3 DD 0

  MOV   EDI,EAX
  CMP   EBP,ESI


  JB    short WIntoCoreX   ;; bailout so last pixel sampled (cell3) == 0...


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

WOutCoreX:

;;========= finish the last 2  pixels in this line /
;  Need wrap-aroundignore AL/ CELL3...; AL has the wrong one !

  MOV   AL,Advb[EBP]   ;;Cell3 used twice - next 'Cell1'
         org $-4
         WCell3_WrapPatch0_n2 DD 0

  MOV   BL,Advb[EBP]   ;;CellB
         org $-4
         WCellB_Patch3_n2 DD 0


  ADD   ECX,EAX ; ECX should become cell 1,2,3 with cell3 a wraparound..
  MOV   ESI,[WEndBitmapCheck]

  ;;;;;;;;; EBP got advanced +LineLen ; check for end of whole bitmap now.

  ;; CMP   EBP,ESI ;;;  WEndBitmapCheck DD 0

  nop
  MOV   DH,Advb[EBX+ECX]
           org $-4
           WTable_Patch5 DD 0

  ROR EDX,16                ;; U only
  ;;MOV   [EBP+2-4],DX
  CMP   EBP,ESI ;;;  WEndBitmapCheck DD 0

  MOV   [EBP-4],EDX
  JB    WIntoCoreY


;========= Y-loop //

 RETN

;======================//

SelfModFireWrap ENDP
;================================================================



;================================================================

align 4

SelfModFireSlowWrap PROC

   ;;;;;;;;;;;;;;;
   ;;
   ;;             d1 d2       = BP    0 1
   ;;  cells    0  1  2  3    = SI -1 0 1 2         [+line]
   ;;              a  b       = DI    0 1           [+line+line]
   ;;
   ;; Bitmap:
   ;;  0 ....1n-1         xn = 'LastPixel'
   ;;  1n....2n-1
   ;;  2n....3n-1
   ;;  ..
   ;;  xn....
   ;;
   ;;;;;;;;;;;;;;;

   MOV EAX,RenderTable

   MOV SWTable_Patch1,EAX
   MOV SWTable_Patch1b,EAX
   MOV SWTable_Patch2,EAX
   MOV SWTable_Patch3,EAX
   MOV SWTable_Patch4,EAX
   MOV SWTable_Patch5,EAX

   ;.................... Patch all the indexes / line-increments

   Call SCopyFirst1Line  ;;! for perfect SlowWrapping...

   ;.DO first Y-2 lines -.. ; init registers to jump into inner loop

   ;;; Patch Cell Line 1

   MOV EAX,LocalLineXSize ;; go to end of line, whatever ECX was...
   DEC EAX
   MOV SWCell0_SlowWrapPatch0,EAX ;; put in (+X-1) := as for Cell2 -2...

   ;;; Patch Cell Line 2

   MOV EAX,LocalLineXSize
   ;;ADD EAX,EAX
   call SPatchCellLine2

   MOV  EBP,FireBitMap

   MOV  EBX,LocalLineYSize

   SUB  EBX,1 ;; last 1 line not calculated

   MOV  EAX,[LocalLineXSize]

   MUL  EBX   ;; result in (EDX):EAX

   MOV  SWBitmapSize,EAX

   ADD  EAX,EBP ;; plus start of bitmap..

   MOV  [WEndBitmapCheck], EAX

   Call SWstartYLoop  ; first Y-1 lines

   ;.......................
   ;.DO line Y-1 line

   ;; now patch it to use Wrap2TempLines as lower source

   mov eax, offset Wrap2TempLines
   sub eax, FireBitmap
   sub eax, SWBitmapSize

   Call SPatchCellLine2

   ;; use EBP as it was returned...

   MOV  EAX,LocalLineXSize
   ADD  WEndBitmapCheck, EAX ;; new limit one line further...

   Call SWstartYLoop  ; do last line " Y-1 "
   ;.......................

   RET


;============================
SCopyFirst1Line label near
   MOV ECX,LocalLineXSize
   MOV ESI,FireBitMap
   MOV EDI,offset Wrap2TempLines
   SHR ECX,2              ;; /4 for dwords *2 for 2 lines   /2 for 1 line
   ;;cmp ecx,128+10
   ;;ja  Sskipmoveline

   REP MOVSD           ;; forget it anyway if it's smaller than 4 pixels !
ret

;============================
SPatchCellLine2 label near ;; 2xXSIZE first, neg WBITMAPSIZE(fromY-2) at last
                           ;; true SlowWrap: do the STORED 2 lines here on 2nd go
                           ;; but: need RELATIVE to where they WOULD
                           ;; be which is WBITMAPSIZE+bitmap address !
   MOV SWCellA_Patch0,EAX
   MOV SWCellA_Patch1,EAX

   MOV EBX,EAX
   ADD EBX,2
   MOV SWCellA_Patch2_p2,EBX

   INC EAX
   MOV SWCellB_Patch1,EAX

   SUB EAX,2
   MOV SWCellB_Patch2_n2,EAX
   MOV SWCellB_Patch3_n2,EAX

 RETN
;============================


;;========= Y-loop \\
 align 4

 SWstartYLoop label near
 SWIntoCoreY:

 ;; EndLineCheck must be the loc. of next line..
 ;; ZERO the relevant registers

 MOV ECX,[LocalLineXSize]

   XOR EBX,EBX

 ADD ECX,EBP

   XOR EAX,EAX

 MOV [EndLineCheck],ECX

 ;;;;; EBP points to first destination-pixel in the line.

  MOV  AL,[EBP] ; Cell 1

  MOV  BL,Advb[EBP]
         org $-4
         SWCell0_SlowWrapPatch0 DD 0  ;; get SlowWrap-around left value = end of line..

  MOV FirstCellSaved,EAX

  MOV ESI,EAX ;;Cell1

  MOV  AL,[EBP+1]  ; Cell 2

  MOV EDI,EBX ;; XOR EDI,EDI ;; Cell0 == 0, or SlowWrap-around value

  MOV  BL,Advb[EBP]          ;; CellA
         org $-4
         SWCellA_Patch0 DD 0

  ADD ESI,EAX               ;; ESI has Cell1
  ADD EDI,EBX               ;; EDI has Cell0


  MOV DL,Advb[EDI+ESI] ;; ESI=Cell1+Cell2 , used in both lookups
         org $-4
         SWTable_Patch1b DD 0     ;; AGI

  jmp short SWEnterCoreX     ;; ecx = don't care




 align 4

 SWIntoCoreX:

  MOV  AL,[EBP]   ;;new 'Cell1'

  MOV  BL,Advb[EBP]   ;; UV
         org $-4
         SWCellB_Patch2_n2 DD 0

  ADD ECX,EAX        ;; UV


  MOV ESI,EAX        ;; UV

  MOV  AL,[EBP+1]     ;; pre-load: Cell2  used twice - next 'Cell0'

  MOV DH,Advb[EBX+ECX]   ;;no AGI if pairing as expected
         org $-4
         SWTable_Patch4 DD 0

  ;---------------------------- making pixel 0,1
  MOV  BL,Advb[EBP]          ;; CellA 
         org $-4
         SWCellA_Patch1 DD 0

  ADD ESI,EAX               ;; ESI has Cell1
  ADD EDI,EBX               ;; EDI has Cell0


  ROR EDX,16                ;; U only
  NOP

  ;;MOV [EBP-2],DX            ;; U pipe only (16-bit prefix)
  MOV [EBP-4],EDX

  MOV  DL,Advb[EDI+ESI] ;; ESI=Cell1+Cell2 , used in both lookups
         org $-4
         SWTable_Patch1 DD 0     ;; AGI but shaded by 16-bit prefix...

 SWEnterCoreX:

  MOV EDI,EAX

  MOV  AL,[EBP+2]   ;;Cell3 used twice - new 'Cell1'

  MOV  BL,Advb[EBP]   ;;CellB
         org $-4
         SWCellB_Patch1 DD 0

  ADD ESI,EAX


  MOV ECX,EAX

  MOV  AL,[EBP+3]   ;;Cell2  used twice - next 'Cell0'


  MOV DH,Advb[EBX+ESI] ;; no AGI if pairing as expected
         org $-4
         SWTable_Patch2   DD 0
  ;---------------------------- making pixel 2,3
  MOV  BL,Advb[EBP]
            org $-4
            SWCellA_Patch2_p2 DD 0

  ADD   ECX,EAX     ;;
  ADD   EDI,EBX     ;;

  ;;MOV   [EBP+0],DX  ;; U
  SHL   EDX,16      ;; U
  ADD   EBP,4       ;;

  MOV   ESI,[EndLineCheck]
  MOV   DL,Advb[EDI+ECX] ;; ECX=Cell1+Cell2 , used in both lookups
         org $-4
         SWTable_Patch3 DD 0

  MOV   EDI,EAX
  CMP   EBP,ESI

  JB    short SWIntoCoreX   ;; bailout so last pixel sampled (cell3) == 0...

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


SWOutCoreX:

;;========= Finish the last 2  pixels in this line.
;
;  Need SlowWrap-aroundignore AL/ CELL3...; AL has the wrong one !
;

;  MOV  AL,Advb[EBP]   ;;Cell3 used twice - next 'Cell1'
;         org $-4
;         SWCell3_SlowWrapPatch0_n2 DD 0

  MOV  EAX,FirstCellSaved

  MOV  BL,Advb[EBP]   ;;CellB
         org $-4
         SWCellB_Patch3_n2 DD 0


  ADD   ECX,EAX ; ECX should become cell 1,2,3 with cell3 a SlowWraparound..
  MOV   ESI,[WEndBitmapCheck]

;;========= EBP got advanced +LineLen ; check for end of whole bitmap now.

  nop
  MOV   DH,Advb[EBX+ECX]
           org $-4
           SWTable_Patch5 DD 0

  ROR EDX,16                ;; U only
  ;;MOV   [EBP+2-4],DX
  CMP   EBP,ESI ;;;  WEndBitmapCheck DD 0

  MOV   [EBP-4],EDX
  JB    SWIntoCoreY

;;========= Y-loop 
 RETN

;;======================//


SelfModFireSlowWrap ENDP
;================================================================





;================================================================
.CODE
;================================================================

CalcWrapFire PROC PBitmap:DWORD,  \
                    Ptable:DWORD, \
                      XVar:DWORD, \
                      YVar:DWORD
 ;;
 ;; VARIABLES: Bitmap pointer, Table pointer, Xsize, Ysize
 ;;
 ;; Uses a special 512 byte _temp_ buffer to make the lower lines wrap
 ;; correctly - since only temporary, keep it here in the data segment
 ;; near the code (less used for smaller bitmaps)
 ;; -> first to do is copy 'em here, then read from here
 ;;   almost exactly as you would 'ave done by wrapping...
 ;;

    mov eax,PBitmap
    mov ecx,PTable

    mov FireBitmap  ,eax
    mov RenderTable ,ecx

    mov eax,XVar
    mov ecx,YVar

    mov LocalLineXSize,eax
    mov LocalLineYSize,ecx


    push ebx
    push ebp
    push esi
    push edi

    call SelfModFireWrap

    pop edi
    pop esi
    pop ebp
    pop ebx

RET

CalcWrapFire ENDP


;=======================================================================

CalcSlowFire PROC PBitmap:DWORD,  \
                    Ptable:DWORD, \
                      XVar:DWORD, \
                      YVar:DWORD

    ;;
    ;; As CalcWrapFire; but the destination-line is also the source-line.
    ;;

    mov eax,PBitmap
    mov ecx,PTable

	mov FireBitmap ,eax
	mov RenderTable ,ecx

	mov eax,XVar
	mov ecx,YVar

	mov LocalLineXSize,eax
	mov LocalLineYSize,ecx

	push ebx
	push ebp
	push esi
	push edi

	call SelfModFireSlowWrap

	pop edi
	pop esi
	pop ebp
	pop ebx

	RET

CalcSlowFire ENDP

;==================================================================

END
