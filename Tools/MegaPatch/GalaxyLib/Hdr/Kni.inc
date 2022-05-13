; KNI Macros for MASM 6.xx - Release 0.02  21-Jan-1999
; Copyright (C) Clive Turvey 1999 (clive@tbcnet.com)
;
; FREEWARE:
;
;    This software may NOT be distributed or bundled with any product
;    that is sold for commercial profit without the explicit permission
;    of the author. In cases where the author has consented, the PKUNZIP(tm)
;    authentication message which normally reads :
;
;        Authentic files Verified!   # EYC098
;        Tenth Planet Software International
;
;    will additionally indicate the commercial entity to which permission
;    has been granted. If authentication is not present, please contact
;    the author to obtain a bona fide copy.
;
; Disclaimer:
;
;    The author hereby disclaims all warranties relating to this software,
;    whether express or implied, including without limitation any implied
;    warranties of merchantability or fitness for a particular purpose.
;    The author will not be liable for any special, incidental,
;    consequential, indirect or similar damages due to loss of data or any
;    other reason, even if the author or an agent of the author has been
;    advised of the possibility of such damages.  In no event shall the
;    author's liability for any damages ever exceed the price paid for
;    the software, regardless of the form of the claim.  The person
;    using the software bears all risk as to the quality and performance
;    of the software.
;
; KNI.INC
;
;    THIS IS A BETA RELEASE. IT GIVES COMPLETE COVERAGE OF THE KATMAI
;    INSTRUCTION SET. I HAVE VALIDATED IT TO THE BEST OF MY ABILITY,
;    HOWEVER IT DOES NOT DO A THOROUGH SYNTAX CHECK OF THE INSTRUCTIONS
;

	.XLIST

_mm		MACRO	pin, pout
IFIDNI		<_MM0>, <pin>
pout		EQU	<eax>
ELSEIFIDNI	<_MM1>, <pin>
pout		EQU	<ecx>
ELSEIFIDNI	<_MM2>, <pin>
pout		EQU	<edx>
ELSEIFIDNI	<_MM3>, <pin>
pout		EQU	<ebx>
ELSEIFIDNI	<_MM4>, <pin>
pout		EQU	<esp>
ELSEIFIDNI	<_MM5>, <pin>
pout		EQU	<ebp>
ELSEIFIDNI	<_MM6>, <pin>
pout		EQU	<esi>
ELSEIFIDNI	<_MM7>, <pin>
pout		EQU	<edi>
ELSE
pout		EQU	<*&pin>
ENDIF
	ENDM

_mmmem		MACRO	pin, pout
IFIDNI		<_MM0>, <pin>
pout		EQU	<eax>
ELSEIFIDNI	<_MM1>, <pin>
pout		EQU	<ecx>
ELSEIFIDNI	<_MM2>, <pin>
pout		EQU	<edx>
ELSEIFIDNI	<_MM3>, <pin>
pout		EQU	<ebx>
ELSEIFIDNI	<_MM4>, <pin>
pout		EQU	<esp>
ELSEIFIDNI	<_MM5>, <pin>
pout		EQU	<ebp>
ELSEIFIDNI	<_MM6>, <pin>
pout		EQU	<esi>
ELSEIFIDNI	<_MM7>, <pin>
pout		EQU	<edi>
ELSE
pout		EQU	<pin>
ENDIF
	ENDM

_xmm		MACRO	pin, pout
IFIDNI		<XMM0>, <pin>
pout		EQU	<eax>
ELSEIFIDNI	<XMM1>, <pin>
pout		EQU	<ecx>
ELSEIFIDNI	<XMM2>, <pin>
pout		EQU	<edx>
ELSEIFIDNI	<XMM3>, <pin>
pout		EQU	<ebx>
ELSEIFIDNI	<XMM4>, <pin>
pout		EQU	<esp>
ELSEIFIDNI	<XMM5>, <pin>
pout		EQU	<ebp>
ELSEIFIDNI	<XMM6>, <pin>
pout		EQU	<esi>
ELSEIFIDNI	<XMM7>, <pin>
pout		EQU	<edi>
ELSE
pout		EQU	<*&pin>
;%err		Syntax Error
ENDIF
		ENDM

_xmmmem		MACRO	pin, pout
IFIDNI		<XMM0>, <pin>
pout		EQU	<eax>
ELSEIFIDNI	<XMM1>, <pin>
pout		EQU	<ecx>
ELSEIFIDNI	<XMM2>, <pin>
pout		EQU	<edx>
ELSEIFIDNI	<XMM3>, <pin>
pout		EQU	<ebx>
ELSEIFIDNI	<XMM4>, <pin>
pout		EQU	<esp>
ELSEIFIDNI	<XMM5>, <pin>
pout		EQU	<ebp>
ELSEIFIDNI	<XMM6>, <pin>
pout		EQU	<esi>
ELSEIFIDNI	<XMM7>, <pin>
pout		EQU	<edi>
ELSE
pout		EQU	<pin>
ENDIF
		ENDM

_addps		MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmm	p1, o1
%		_xmmmem	p2, o2
l1:
		btc	o2, o1
l2:
		org	l1 + 1
		db	058h
		org	l2
		ENDM

_addss		MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmm	p1, o1
%		_xmmmem	p2, o2
		db	0F3h
l1:
		btc	o2, o1
l2:
		org	l1 + 1
		db	058h
		org	l2
		ENDM

_andnps		MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmm	p1, o1
%		_xmmmem	p2, o2
l1:
		btc	o2, o1
l2:
		org	l1 + 1
		db	055h
		org	l2
		ENDM

_andps		MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmm	p1, o1
%		_xmmmem	p2, o2
l1:
		btc	o2, o1
l2:
		org	l1 + 1
		db	054h
		org	l2
		ENDM

_cmpeqps		MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmm	p1, o1
%		_xmmmem	p2, o2
l1:
		btc	o2, o1
		db	000h
l2:
		org	l1 + 1
		db	0C2h
		org	l2
		ENDM

_cmpeqss		MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmm	p1, o1
%		_xmmmem	p2, o2
		db	0F3h
l1:
		btc	o2, o1
		db	000h
l2:
		org	l1 + 1
		db	0C2h
		org	l2
		ENDM

_cmpltps		MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmm	p1, o1
%		_xmmmem	p2, o2
l1:
		btc	o2, o1
		db	001h
l2:
		org	l1 + 1
		db	0C2h
		org	l2
		ENDM

_cmpltss		MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmm	p1, o1
%		_xmmmem	p2, o2
		db	0F3h
l1:
		btc	o2, o1
		db	001h
l2:
		org	l1 + 1
		db	0C2h
		org	l2
		ENDM

_cmpleps		MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmm	p1, o1
%		_xmmmem	p2, o2
l1:
		btc	o2, o1
		db	002h
l2:
		org	l1 + 1
		db	0C2h
		org	l2
		ENDM

_cmpless		MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmm	p1, o1
%		_xmmmem	p2, o2
		db	0F3h
l1:
		btc	o2, o1
		db	002h
l2:
		org	l1 + 1
		db	0C2h
		org	l2
		ENDM

_cmpunordps	MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmm	p1, o1
%		_xmmmem	p2, o2
l1:
		btc	o2, o1
		db	003h
l2:
		org	l1 + 1
		db	0C2h
		org	l2
		ENDM

_cmpunordss	MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmm	p1, o1
%		_xmmmem	p2, o2
		db	0F3h
l1:
		btc	o2, o1
		db	003h
l2:
		org	l1 + 1
		db	0C2h
		org	l2
		ENDM

_cmpneqps	MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmm	p1, o1
%		_xmmmem	p2, o2
l1:
		btc	o2, o1
		db	004h
l2:
		org	l1 + 1
		db	0C2h
		org	l2
		ENDM

_cmpneqss	MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmm	p1, o1
%		_xmmmem	p2, o2
		db	0F3h
l1:
		btc	o2, o1
		db	004h
l2:
		org	l1 + 1
		db	0C2h
		org	l2
		ENDM

_cmpnltps	MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmm	p1, o1
%		_xmmmem	p2, o2
l1:
		btc	o2, o1
		db	005h
l2:
		org	l1 + 1
		db	0C2h
		org	l2
		ENDM

_cmpnltss	MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmm	p1, o1
%		_xmmmem	p2, o2
		db	0F3h
l1:
		btc	o2, o1
		db	005h
l2:
		org	l1 + 1
		db	0C2h
		org	l2
		ENDM

_cmpnleps	MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmm	p1, o1
%		_xmmmem	p2, o2
l1:
		btc	o2, o1
		db	006h
l2:
		org	l1 + 1
		db	0C2h
		org	l2
		ENDM

_cmpnless	MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmm	p1, o1
%		_xmmmem	p2, o2
		db	0F3h
l1:
		btc	o2, o1
		db	006h
l2:
		org	l1 + 1
		db	0C2h
		org	l2
		ENDM

_cmpordps	MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmm	p1, o1
%		_xmmmem	p2, o2
l1:
		btc	o2, o1
		db	007h
l2:
		org	l1 + 1
		db	0C2h
		org	l2
		ENDM

_cmpordss	MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmm	p1, o1
%		_xmmmem	p2, o2
		db	0F3h
l1:
		btc	o2, o1
		db	007h
l2:
		org	l1 + 1
		db	0C2h
		org	l2
		ENDM

_comiss		MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmm	p1, o1
%		_xmmmem	p2, o2
l1:
		btc	o2, o1
l2:
		org	l1 + 1
		db	02Fh
		org	l2
		ENDM

_cvtpi2ps	MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmm	p1, o1
%		_mmmem	p2, o2
l1:
		btc	o2, o1
l2:
		org	l1 + 1
		db	02Ah
		org	l2
		ENDM

_cvtps2pi	MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_mm	p1, o1
%		_xmmmem	p2, o2
l1:
		btc	o2, o1
l2:
		org	l1 + 1
		db	02Dh
		org	l2
		ENDM

_cvtsi2ss	MACRO	p1, p2
		LOCAL	o1, l1, l2
%		_xmm	p1, o1
		db	0F3h
l1:
		btc	p2, o1
l2:
		org	l1 + 1
		db	02Ah
		org	l2
		ENDM

_cvtss2si	MACRO	p1, p2
		LOCAL	o2, l1, l2
%		_xmmmem	p2, o2
		db	0F3h
l1:
		btc	o2, p1
l2:
		org	l1 + 1
		db	02Dh
		org	l2
		ENDM

_cvttps2pi	MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_mm	p1, o1
%		_xmmmem	p2, o2
l1:
		btc	o2, o1
l2:
		org	l1 + 1
		db	02Ch
		org	l2
		ENDM

_cvttss2si	MACRO	p1, p2
		LOCAL	o2, l1, l2
%		_xmmmem	p2, o2
		db	0F3h
l1:
		btc	o2, p1
l2:
		org	l1 + 1
		db	02Ch
		org	l2
		ENDM

_divps		MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmm	p1, o1
%		_xmmmem	p2, o2
l1:
		btc	o2, o1
l2:
		org	l1 + 1
		db	05Eh
		org	l2
		ENDM

_divss		MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmm	p1, o1
%		_xmmmem	p2, o2
		db	0F3h
l1:
		btc	o2, o1
l2:
		org	l1 + 1
		db	05Eh
		org	l2
		ENDM

_fxrstor		MACRO	p1
		LOCAL	l1, l2
l1:
		btc	p1, ecx
l2:
		org	l1 + 1
		db	0AEh
		org	l2
		ENDM

_fxsave		MACRO	p1
		LOCAL	l1, l2
l1:
		btc	p1, eax
l2:
		org	l1 + 1
		db	0AEh
		org	l2
		ENDM

_ldmxcsr		MACRO	p1
		LOCAL	l1, l2
l1:
		btc	p1, edx
l2:
		org	l1 + 1
		db	0AEh
		org	l2
		ENDM

_maskmovq	MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_mm	p1, o1
%		_mm	p2, o2
l1:
		btc	o2, o1
l2:
		org	l1 + 1
		db	0F7h
		org	l2
		ENDM

_maxps		MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmm	p1, o1
%		_xmmmem	p2, o2
l1:
		btc	o2, o1
l2:
		org	l1 + 1
		db	05Fh
		org	l2
		ENDM

_maxss		MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmm	p1, o1
%		_xmmmem	p2, o2
		db	0F3h
l1:
		btc	o2, o1
l2:
		org	l1 + 1
		db	05Fh
		org	l2
		ENDM

_minps		MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmm	p1, o1
%		_xmmmem	p2, o2
l1:
		btc	o2, o1
l2:
		org	l1 + 1
		db	05Dh
		org	l2
		ENDM

_minss		MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmm	p1, o1
%		_xmmmem	p2, o2
		db	0F3h
l1:
		btc	o2, o1
l2:
		org	l1 + 1
		db	05Dh
		org	l2
		ENDM

_movaps		MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmmmem	p1, o1
%		_xmmmem	p2, o2
l1:
%	IFIDN <o1>, <p1>
		btc	o1, o2
l2:
		org	l1 + 1
		db	029h
	ELSE
		btc	o2, o1
l2:
		org	l1 + 1
		db	028h
	ENDIF
		org	l2
		ENDM

_movhlps		MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmm	p1, o1
%		_xmm	p2, o2
l1:
		btc	o2, o1
l2:
		org	l1 + 1
		db	012h
		org	l2
		ENDM

_movhps		MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmmmem	p1, o1
%		_xmmmem	p2, o2
l1:
%	IFIDN <o1>, <p1>
		btc	o1, o2
l2:
		org	l1 + 1
		db	017h
	ELSE
		btc	o2, o1
l2:
		org	l1 + 1
		db	016h
	ENDIF
		org	l2
		ENDM

_movlhps		MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmm	p1, o1
%		_xmm	p2, o2
l1:
		btc	o2, o1
l2:
		org	l1 + 1
		db	016h
		org	l2
		ENDM

_movlps		MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmmmem	p1, o1
%		_xmmmem	p2, o2
l1:
%	IFIDN <o1>, <p1>
		btc	o1, o2
l2:
		org	l1 + 1
		db	013h
	ELSE
		btc	o2, o1
l2:
		org	l1 + 1
		db	012h
	ENDIF
		org	l2
		ENDM

_movmskps	MACRO	p1, p2
		LOCAL	o2, l1, l2
%		_xmmmem	p2, o2
l1:
		btc	o2, p1
l2:
		org	l1 + 1
		db	050h
		org	l2
		ENDM

_movntps		MACRO	p1, p2
		LOCAL	o2, l1, l2
%		_xmm	p2, o2
l1:
		btc	p1, o2
l2:
		org	l1 + 1
		db	02Bh
		org	l2
		ENDM

_movntq		MACRO	p1, p2
		LOCAL	o2, l1, l2
%		_mm	p2, o2
l1:
		btc	p1, o2
l2:
		org	l1 + 1
		db	0E7h
		org	l2
		ENDM

_movss		MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmmmem	p1, o1
%		_xmmmem	p2, o2
		db	0F3h
l1:
%	IFIDN <o1>, <p1>
		btc	o1, o2
l2:
		org	l1 + 1
		db	011h
	ELSE
		btc	o2, o1
l2:
		org	l1 + 1
		db	010h
	ENDIF
		org	l2
		ENDM

_movups		MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmmmem	p1, o1
%		_xmmmem	p2, o2
l1:
%	IFIDN <o1>, <p1>
		btc	o1, o2
l2:
		org	l1 + 1
		db	011h
	ELSE
		btc	o2, o1
l2:
		org	l1 + 1
		db	010h
	ENDIF
		org	l2
		ENDM

_mulps		MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmm	p1, o1
%		_xmmmem	p2, o2
l1:
		btc	o2, o1
l2:
		org	l1 + 1
		db	059h
		org	l2
		ENDM

_mulss		MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmm	p1, o1
%		_xmmmem	p2, o2
		db	0F3h
l1:
		btc	o2, o1
l2:
		org	l1 + 1
		db	059h
		org	l2
		ENDM

_orps		MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmm	p1, o1
%		_xmmmem	p2, o2
l1:
		btc	o2, o1
l2:
		org	l1 + 1
		db	056h
		org	l2
		ENDM

_pavgb		MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_mm	p1, o1
%		_mmmem	p2, o2
l1:
		btc	o2, o1
l2:
		org	l1 + 1
		db	0E0h
		org	l2
		ENDM

_pavgw		MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_mm	p1, o1
%		_mmmem	p2, o2
l1:
		btc	o2, o1
l2:
		org	l1 + 1
		db	0E3h
		org	l2
		ENDM

_pextrw		MACRO	p1, p2, p3
		LOCAL	o2, l1, l2
%		_mm	p2, o2
l1:
		btc	o2, p1
		db	p3
l2:
		org	l1 + 1
		db	0C5h
		org	l2
		ENDM

_pinsrw		MACRO	p1, p2, p3
		LOCAL	o1, l1, l2
%		_mm	p1, o1
l1:
		btc	p2, o1
		db	p3
l2:
		org	l1 + 1
		db	0C4h
		org	l2
		ENDM

_pmaxsw		MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_mm	p1, o1
%		_mmmem	p2, o2
l1:
		btc	o2, o1
l2:
		org	l1 + 1
		db	0EEh
		org	l2
		ENDM

_pmaxub		MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_mm	p1, o1
%		_mmmem	p2, o2
l1:
		btc	o2, o1
l2:
		org	l1 + 1
		db	0DEh
		org	l2
		ENDM

_pminsw		MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_mm	p1, o1
%		_mmmem	p2, o2
l1:
		btc	o2, o1
l2:
		org	l1 + 1
		db	0EAh
		org	l2
		ENDM

_pminub		MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_mm	p1, o1
%		_mmmem	p2, o2
l1:
		btc	o2, o1
l2:
		org	l1 + 1
		db	0DAh
		org	l2
		ENDM

_pmovmskb	MACRO	p1, p2
		LOCAL	o2, l1, l2
%		_mm	p2, o2
l1:
		btc	o2, p1
l2:
		org	l1 + 1
		db	0D7h
		org	l2
		ENDM

_pmulhuw		MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_mm	p1, o1
%		_mmmem	p2, o2
l1:
		btc	o2, o1
l2:
		org	l1 + 1
		db	0E4h
		org	l2
		ENDM

_prefetchnta	MACRO	p1
		LOCAL	l1, l2
l1:
		btc	p1, eax
l2:
		org	l1 + 1
		db	018h
		org	l2
		ENDM

_prefetcht0	MACRO	p1
		LOCAL	l1, l2
l1:
		btc	p1, ecx
l2:
		org	l1 + 1
		db	018h
		org	l2
		ENDM

_prefetcht1	MACRO	p1
		LOCAL	l1, l2
l1:
		btc	p1, edx
l2:
		org	l1 + 1
		db	018h
		org	l2
		ENDM

_prefetcht2	MACRO	p1
		LOCAL	l1, l2
l1:
		btc	p1, ebx
l2:
		org	l1 + 1
		db	018h
		org	l2
		ENDM

_psadbw		MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_mm	p1, o1
%		_mmmem	p2, o2
l1:
		btc	o2, o1
l2:
		org	l1 + 1
		db	0F6h
		org	l2
		ENDM

_pshufw		MACRO	p1, p2, p3
		LOCAL	o1, o2, l1, l2
%		_mm	p1, o1
%		_mmmem	p2, o2
l1:
		btc	o2, o1
		db	p3
l2:
		org	l1 + 1
		db	070h
		org	l2
		ENDM

_rcpps		MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmm	p1, o1
%		_xmmmem	p2, o2
l1:
		btc	o2, o1
l2:
		org	l1 + 1
		db	053h
		org	l2
		ENDM

_rcpss		MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmm	p1, o1
%		_xmmmem	p2, o2
		db	0F3h
l1:
		btc	o2, o1
l2:
		org	l1 + 1
		db	053h
		org	l2
		ENDM

_rsqrtps		MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmm	p1, o1
%		_xmmmem	p2, o2
l1:
		btc	o2, o1
l2:
		org	l1 + 1
		db	052h
		org	l2
		ENDM

_rsqrtss		MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmm	p1, o1
%		_xmmmem	p2, o2
		db	0F3h
l1:
		btc	o2, o1
l2:
		org	l1 + 1
		db	052h
		org	l2
		ENDM

_sfence		MACRO
		db	00Fh,0AEh,0FFh
		ENDM

_shufps		MACRO	p1, p2, p3
		LOCAL	o1, o2, l1, l2
%		_xmm	p1, o1
%		_xmmmem	p2, o2
l1:
		btc	o2, o1
		db	p3
l2:
		org	l1 + 1
		db	0C6h
		org	l2
		ENDM

_sqrtps		MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmm	p1, o1
%		_xmmmem	p2, o2
l1:
		btc	o2, o1
l2:
		org	l1 + 1
		db	051h
		org	l2
		ENDM

_sqrtss		MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmm	p1, o1
%		_xmmmem	p2, o2
		db	0F3h
l1:
		btc	o2, o1
l2:
		org	l1 + 1
		db	051h
		org	l2
		ENDM

_stmxcsr		MACRO	p1
		LOCAL	l1, l2
l1:
		btc	p1, ebx
l2:
		org	l1 + 1
		db	0AEh
		org	l2
		ENDM

_subps		MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmm	p1, o1
%		_xmmmem	p2, o2
l1:
		btc	o2, o1
l2:
		org	l1 + 1
		db	05Ch
		org	l2
		ENDM

_subss		MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmm	p1, o1
%		_xmmmem	p2, o2
		db	0F3h
l1:
		btc	o2, o1
l2:
		org	l1 + 1
		db	05Ch
		org	l2
		ENDM

_ucomiss		MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmm	p1, o1
%		_xmmmem	p2, o2
l1:
		btc	o2, o1
l2:
		org	l1 + 1
		db	02Eh
		org	l2
		ENDM

_unpckhps	MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmm	p1, o1
%		_xmmmem	p2, o2
l1:
		btc	o2, o1
l2:
		org	l1 + 1
		db	015h
		org	l2
		ENDM

_unpcklps	MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmm	p1, o1
%		_xmmmem	p2, o2
l1:
		btc	o2, o1
l2:
		org	l1 + 1
		db	014h
		org	l2
		ENDM

_xorps		MACRO	p1, p2
		LOCAL	o1, o2, l1, l2
%		_xmm	p1, o1
%		_xmmmem	p2, o2
l1:
		btc	o2, o1
l2:
		org	l1 + 1
		db	057h
		org	l2
		ENDM

	.LIST

