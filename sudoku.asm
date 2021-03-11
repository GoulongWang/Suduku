INCLUDE Irvine32.inc
main	EQU start@0

;<proto>

judgeRow PROTO
judgeColumn PROTO
judgeCube PROTO


;</proto>

;外框大小
BoxWidth = 80
BoxHeight = 35
;表格大小
inputMapLength = 19
; Play 的外框大小 26 * 7
smallBoxWidth = 26
smallBoxHeight = 7

; SetConsoleWindowInfo用的結構
SMALL_RECT STRUCT
  Left 	 WORD ?
  Top 	 WORD ?
  Right  WORD ?
  Bottom WORD ?
SMALL_RECT ENDS
 
.data
header   BYTE "1 2 3 4 5 6 7 8 9"
contentJudge BYTE 9 DUP(0)
mapValueIndex DWORD ?
mapColorIndex DWORD ?
;紀錄表格內每一格的數值
mapValue BYTE  81 DUP(?)
mapIndex WORD ?			;紀錄目前指到array哪一個數的index
mapTemp  BYTE ?			;存放user填入表格內的數值

;這是題目的答案
taskAnswer   BYTE "147253968",
				  "238469175",
				  "695781234",
				  "456138729",
				  "379624581",
				  "812597346",
				  "923816457",
				  "564972813",
				  "781345692"

;用於填入位置的能否，如果為1，則將其在程式打開時印出			
mapValueBool BYTE "010110001",
				  "010101110",
				  "000011100",
				  "001000110",
				  "000101000",
				  "011000100",
				  "001110000",
				  "011101010",
				  "100011010"
;用於判定每個位置該填入的顏色				  
mapColor	 BYTE "000111000",
				  "000111000",
				  "000111000",
				  "111000111",
				  "111000111",
				  "111000111",
				  "000111000",
				  "000111000",
				  "000111000"

;設定游標位置
consoleHandle     DWORD ?

;清空輸入的數值用
clearBuffer 	  BYTE "                                                       "

xyInit COORD <0,0>			;用於游標重製到左上，清空輸入的數值用
xyPos COORD <?,?>			;用來儲存user指定表格的x跟y位置
xyInit2 COORD <33, 13>		;用來儲存表格內<1, 1>的xy位置
xyCur COORD <33,13>			;用來紀錄當前的位置，也用於array的指定

;SetConsoleWindowInfo用的變數
consoleRect SMALL_RECT <0, 0, 85, 40>

;用於顯示程式標題
titleStr  BYTE "Sudoku",0

;於外框的
boxTop    BYTE 0C9h, (BoxWidth - 2) DUP(0CDh), 0BBh
boxBody   BYTE 0BAh, (BoxWidth - 2) DUP(' '), 0BAh
boxBottom BYTE 0C8h, (BoxWidth - 2) DUP(0CDh),0BCh
; 要印出的邊的字元，用於 PLAY 的外框
smallboxTop    BYTE 0C9h, (smallBoxWidth - 2) DUP(0CDh), 0BBh
smallboxBody   BYTE 0BAh, (smallBoxWidth - 2) DUP(' '), 0BAh
smallboxBottom BYTE 0C8h, (smallBoxWidth - 2) DUP(0CDh),0BCh

; 開始畫面的字
charWidth = 10 ; 每個字的寬度
smallCharWidth = 5 ; 小的字母寬度
;  ******  ' 
; *      * 
;*        *     
;  *           
;    *    
;      *  
;        * 
;*        * 
; *      *
;  ******
S1 BYTE 2 DUP(' '), 6 DUP('*'), 2 DUP(' ')
S2 BYTE ' ', '*', 6 DUP(' '), '*', ' '
S3 BYTE '*', 8 DUP(' '), '*'
S4 BYTE 2 DUP(' '), '*', 7 DUP(' ') 
S5 BYTE 4 DUP(' '), '*', 5 DUP(' ') 
S6 BYTE 6 DUP(' '), '*', 3 DUP(' ')
S7 BYTE 8 DUP(' '), '*', ' '
S8 BYTE '*', 8 DUP(' '), '*'
S9 BYTE ' ', '*', 6 DUP(' '), '*', ' '
S10 BYTE 2 DUP(' '), 6 DUP('*'), 2 DUP(' ')	  
;*        *
;*        *
;*        *
;*        *
;*        *
;*        *
;*        *
;*        *  
; *      *
;  ******
U1_8 BYTE '*', 8 DUP(' '), '*'
U9 BYTE ' ', '*', 6 DUP(' '), '*', ' '
U10 BYTE 2 DUP(' '), 6 DUP('*'), 2 DUP(' ')
;******
;*      *
;*       *
;*        *
;*        *
;*        *
;*        *
;*       *
;*      *
;******
D1 BYTE 5 DUP('*'), 5 DUP(' ')
D2 BYTE '*', 6 DUP(' '), '*', 2 DUP(' ')
D3 BYTE '*', 7 DUP(' '), '*', ' '
D4 BYTE '*', 8 DUP(' '), '*'
;  ******  
; *      *
;*        *
;*        *
;*        *
;*        *
;*        *
;*        *  
; *      *
;  ******
O1 BYTE 2 DUP(' '), 6 DUP('*'), 2 DUP(' ')
O2 BYTE ' ', '*', 6 DUP(' '), '*', ' '
O3 BYTE '*', 8 DUP(' '), '*'
;*        * 
;*      *  
;*    *   
;*  *
;**
;**
;*  *
;*    *
;*      *
;*        *
K1 BYTE '*', 8 DUP(' '), '*'
K2 BYTE '*', 6 DUP(' '), '*', 2 DUP(' ')
K3 BYTE '*', 4 DUP(' '), '*', 4 DUP(' ')
K4 BYTE '*', 2 DUP(' '), '*', 6 DUP(' ')
K5 BYTE 2 DUP('*'), 8 DUP(' ')
;****
;*   *
;****
;*
;*
P1and3 BYTE 4 DUP('*'), ' '
P2 BYTE '*', 3 DUP(' '), '*'
P4and5 BYTE '*', 4 DUP(' ')
;*
;*
;*
;*
;*****
L1_4 BYTE '*', 4 DUP(' ')
L5 BYTE 5 DUP('*')
;  *
; * *
;*   *
;*****
;*   *
A1 BYTE 2 DUP(' '), '*', 2 DUP(' ')
A2 BYTE ' ', '*', ' ', '*', ' '
A3and5 BYTE '*', 3 DUP(' '), '*'
A4 BYTE 5 DUP('*')
;*   *
; * *
;  *
;  *
;  *
Y1 BYTE '*', 3 DUP(' '), '*'
Y2 BYTE ' ', '*', ' ', '*', ' '
Y3_5 BYTE 2 DUP(' '), '*', 2 DUP(' ')
; 外框的顏色，藍色
attributes_0 WORD BoxWidth DUP(0Bh) 			; 上面 + 下面的邊
attributes_1 WORD (BoxWidth-1) DUP(0Bh), 0Bh ; 左右的邊
smallBoxColor WORD smallBoxWidth DUP(0Eh)   		; 上面 + 下面的邊
smallBoxColor2 WORD (smallBoxWidth-1) DUP(0Eh), 0Eh ;左右的邊

;用來製作數獨的版面
inputMapTop BYTE 0C9h, 0CDh, 0CBh, 0CDh, 0CBh, 0CDh, 0CBh, 0CDh, 0CBh, 0CDh, 0CBh, 0CDh, 0CBh, 0CDh, 0CBh, 0CDh, 0CBh, 0CDh, 0BBh		
inputMapBody1 BYTE 0BAh, ' ', 0BAh, ' ', 0BAh, ' ', 0BAh, ' ', 0BAh, ' ', 0BAh, ' ', 0BAh, ' ', 0BAh, ' ', 0BAh, ' ', 0BAh
inputMapBody2 BYTE 0CCh, 0CDh, 0CEh, 0CDh, 0CEh, 0CDh, 0CEh, 0CDh, 0CEh, 0CDh, 0CEh, 0CDh, 0CEh, 0CDh, 0CEh, 0CDh, 0CEh, 0CDh, 0B9h
inputMapBottom BYTE 0C8h, 0CDh, 0CAh, 0CDh, 0CAh, 0CDh, 0CAh, 0CDh, 0CAh, 0CDh, 0CAh, 0CDh, 0CAh, 0CDh, 0CAh, 0CDh, 0CAh, 0CDh, 0BCh 

;用於印出1~3和7~9列的顏色
attributes0 WORD white, 5 DUP(white+lightblue*16), white, 5 DUP(black+white*16), white, 5 DUP(white+lightblue*16), white
;用於印出4~6列的顏色
attributes1 WORD white, 5 DUP(black+white*16), white, 5 DUP(white+lightblue*16), white, 5 DUP(black+white*16), white
 
outputHandle DWORD 0	;存放印出事件處理
xyPosition COORD <2,5>	;用於印出外框和表格
 
cellsWritten DWORD ?	;用於所有的印出事件
          
.code
main PROC
	INVOKE SetConsoleTitle, ADDR titleStr	;改變標題
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE ; Get the console ouput handle
	mov outputHandle, eax 				   ; save console handle
    call Clrscr
    
	; 畫出 box 的第一行
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, BoxWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter,
		   outputHandle,   	 ; console output handle
		   ADDR boxTop,   	 ; pointer to the top box line
		   BoxWidth,   		 ; size of box line
		   xyPosition,   	 ; coordinates of first char
		   ADDR cellsWritten ; output count
 
    inc xyPosition.y 		 ; 座標換到下一行位置
	
    mov ecx, (BoxHeight-2)   ; number of lines in body
OuterBody: 
	push ecx  				 ; save counter 避免invoke 有使用到這個暫存器
    ; 畫出 box body
	INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_1, BoxWidth, xyPosition, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR boxBody, BoxWidth, xyPosition, ADDR cellsWritten 
    inc xyPosition.y   		 ; next line
    pop ecx   				 ; restore counter
    loop OuterBody
 
	; draw bottom of the box
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, BoxWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR boxBottom, BoxWidth, xyPosition, ADDR cellsWritten 

	; 視窗上半部會印出大寫字形 SUDOKU
	; 把 xyPosition 的位置移到要開始畫 S 的地方
	mov xyPosition.X, 10
	mov xyPosition.Y, 10
	
DrawSUDOKU:
	; 畫出 S
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, charWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR S1, charWidth, xyPosition, ADDR cellsWritten
    inc xyPosition.y
	INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, charWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR S2, charWidth, xyPosition, ADDR cellsWritten
    inc xyPosition.y
	INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, charWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR S3, charWidth, xyPosition, ADDR cellsWritten
    inc xyPosition.y
	INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, charWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR S4, charWidth, xyPosition, ADDR cellsWritten
    inc xyPosition.y
	INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, charWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR S5, charWidth, xyPosition, ADDR cellsWritten
    inc xyPosition.y
	INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, charWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR S6, charWidth, xyPosition, ADDR cellsWritten
    inc xyPosition.y
	INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, charWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR S7, charWidth, xyPosition, ADDR cellsWritten
    inc xyPosition.y
	INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, charWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR S8, charWidth, xyPosition, ADDR cellsWritten
    inc xyPosition.y
	INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, charWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR S9, charWidth, xyPosition, ADDR cellsWritten
    inc xyPosition.y
	INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, charWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR S10, charWidth, xyPosition, ADDR cellsWritten
	
	; 畫出 U
	; 把 xyPosition 的位置移到要開始畫 U 的地方
	mov xyPosition.X, 21
	mov xyPosition.Y, 10
	mov ecx, 8
	U: 
		push ecx
		INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, charWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR U1_8, charWidth, xyPosition, ADDR cellsWritten
		inc xyPosition.y
		pop ecx
    loop U
	INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, charWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR U9, charWidth, xyPosition, ADDR cellsWritten
    inc xyPosition.y
	INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, charWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR U10, charWidth, xyPosition, ADDR cellsWritten
	
	; 畫出 D
	; 把 xyPosition 的位置移到要開始畫 D 的地方
	mov xyPosition.X, 32
	mov xyPosition.Y, 10
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, charWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR D1, charWidth, xyPosition, ADDR cellsWritten
    inc xyPosition.y
	INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, charWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR D2, charWidth, xyPosition, ADDR cellsWritten
    inc xyPosition.y
	INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, charWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR D3, charWidth, xyPosition, ADDR cellsWritten
    inc xyPosition.y
	mov ecx, 4
	D: 
		push ecx
		INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, charWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR D4, charWidth, xyPosition, ADDR cellsWritten
		inc xyPosition.y
		pop ecx
    loop D
	INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, charWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR D3, charWidth, xyPosition, ADDR cellsWritten
    inc xyPosition.y
	INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, charWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR D2, charWidth, xyPosition, ADDR cellsWritten
    inc xyPosition.y
	INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, charWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR D1, charWidth, xyPosition, ADDR cellsWritten
	
	; 畫出 O
	; 把 xyPosition 的位置移到要開始畫 O 的地方
	mov xyPosition.X, 43
	mov xyPosition.Y, 10
	INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, charWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR O1, charWidth, xyPosition, ADDR cellsWritten
    inc xyPosition.y
	INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, charWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR O2, charWidth, xyPosition, ADDR cellsWritten
    inc xyPosition.y
	mov ecx, 6
	O: 
		push ecx
		INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, charWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR O3, charWidth, xyPosition, ADDR cellsWritten
		inc xyPosition.y
		pop ecx
    loop O
	INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, charWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR O2, charWidth, xyPosition, ADDR cellsWritten
    inc xyPosition.y
	INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, charWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR O1, charWidth, xyPosition, ADDR cellsWritten
	
	; 畫出 K
	; 把 xyPosition 的位置移到要開始畫 K 的地方
	mov xyPosition.X, 54
	mov xyPosition.Y, 10
	INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, charWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR K1, charWidth, xyPosition, ADDR cellsWritten
    inc xyPosition.y
	INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, charWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR K2, charWidth, xyPosition, ADDR cellsWritten
    inc xyPosition.y
	INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, charWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR K3, charWidth, xyPosition, ADDR cellsWritten
    inc xyPosition.y
	INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, charWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR K4, charWidth, xyPosition, ADDR cellsWritten
    inc xyPosition.y
	INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, charWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR K5, charWidth, xyPosition, ADDR cellsWritten
    inc xyPosition.y
	INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, charWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR K5, charWidth, xyPosition, ADDR cellsWritten
    inc xyPosition.y
	INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, charWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR K4, charWidth, xyPosition, ADDR cellsWritten
    inc xyPosition.y
	INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, charWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR K3, charWidth, xyPosition, ADDR cellsWritten
    inc xyPosition.y
	INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, charWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR K2, charWidth, xyPosition, ADDR cellsWritten
    inc xyPosition.y
	INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, charWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR K1, charWidth, xyPosition, ADDR cellsWritten
	
	; 畫出 U
	; 把 xyPosition 的位置移到要開始畫 U 的地方
	mov xyPosition.X, 65
	mov xyPosition.Y, 10
	mov ecx, 8
	U2: 
		push ecx
		INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, charWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR U1_8, charWidth, xyPosition, ADDR cellsWritten
		inc xyPosition.y
		pop ecx
    loop U2
	INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, charWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR U9, charWidth, xyPosition, ADDR cellsWritten
    inc xyPosition.y
	INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, charWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR U10, charWidth, xyPosition, ADDR cellsWritten
	
DrawSmallBox:
	mov xyPosition.X, 30
	mov xyPosition.Y, 29
	; 畫出 SmallBox 的第一行
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR smallBoxColor, smallBoxWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR smallboxTop, smallBoxWidth, xyPosition, ADDR cellsWritten
    inc xyPosition.y

    mov ecx, (smallBoxHeight - 2)
	smallBox: 
		push ecx
		; 畫出 smallBox body
		INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR smallBoxColor2, smallBoxWidth, xyPosition, ADDR cellsWritten
		INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR smallboxBody, smallBoxWidth, xyPosition, ADDR cellsWritten 
		inc xyPosition.y   		 
		pop ecx
    loop smallBox
 
	; draw bottom of the smallBox
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR smallBoxColor, smallBoxWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR smallboxBottom, smallBoxWidth, xyPosition, ADDR cellsWritten 

DrawPLAY:
	; 畫出 P
	; 把 xyPosition 的位置移到要開始畫 P 的地方
	mov xyPosition.X, 32
	mov xyPosition.Y, 30
	INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, smallCharWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR P1and3, smallCharWidth, xyPosition, ADDR cellsWritten
    inc xyPosition.y
	INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, smallCharWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR P2, smallCharWidth, xyPosition, ADDR cellsWritten
    inc xyPosition.y
	INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, smallCharWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR P1and3, smallCharWidth, xyPosition, ADDR cellsWritten
    inc xyPosition.y
	INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, smallCharWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR P4and5, smallCharWidth, xyPosition, ADDR cellsWritten
    inc xyPosition.y
	INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, smallCharWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR P4and5, smallCharWidth, xyPosition, ADDR cellsWritten
	
	; 畫出 L
	mov xyPosition.X, 38
	mov xyPosition.Y, 30
	mov ecx, 4
	L: 
		push ecx
		INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, smallCharWidth, xyPosition, ADDR cellsWritten
		INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR L1_4, smallCharWidth, xyPosition, ADDR cellsWritten
		inc xyPosition.y
		pop ecx
    loop L
	INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, smallCharWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR L5, smallCharWidth, xyPosition, ADDR cellsWritten
	
	; 畫出 A
	mov xyPosition.X, 44
	mov xyPosition.Y, 30
	INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, smallCharWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR A1, smallCharWidth, xyPosition, ADDR cellsWritten
    inc xyPosition.y
	INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, smallCharWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR A2, smallCharWidth, xyPosition, ADDR cellsWritten
    inc xyPosition.y
	INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, smallCharWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR A3and5, smallCharWidth, xyPosition, ADDR cellsWritten
    inc xyPosition.y
	INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, smallCharWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR A4, smallCharWidth, xyPosition, ADDR cellsWritten
    inc xyPosition.y
	INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, smallCharWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR A3and5, smallCharWidth, xyPosition, ADDR cellsWritten
    inc xyPosition.y
	
	; 畫出 Y
	mov xyPosition.X, 50
	mov xyPosition.Y, 30
	INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, smallCharWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR Y1, smallCharWidth, xyPosition, ADDR cellsWritten
    inc xyPosition.y
	INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, smallCharWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR Y2, smallCharWidth, xyPosition, ADDR cellsWritten
    inc xyPosition.y
	mov ecx, 3
	Y: 
		push ecx
		INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_0, smallCharWidth, xyPosition, ADDR cellsWritten
		INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR Y3_5, smallCharWidth, xyPosition, ADDR cellsWritten
		inc xyPosition.y
		pop ecx
    loop Y
	
	call ReadChar
    call Clrscr

	mov xyPosition.X, 2
	mov xyPosition.Y, 5
	
    INVOKE GetStdHandle, STD_OUTPUT_HANDLE  ;獲得印出處理事件
    mov outputHandle, eax 				    ;存放印出事件到outputHandle和consoleHandle
	mov consoleHandle, eax
    call Clrscr								;程式開始前先清空畫面
    ;畫出box的第一行
	  
	INVOKE SetConsoleWindowInfo,			;設定窗口大小
	  outputHandle,
	  1,
	  ADDR consoleRect
 
    INVOKE WriteConsoleOutputCharacter,		;印出外框上半
       outputHandle,   						
       ADDR boxTop,   						
       BoxWidth,  							
       xyPosition,  						
       ADDR cellsWritten   					
 
    inc xyPosition.y   						;座標換到下一行位置
 
    mov ecx, (BoxHeight-2)    				;外框body大小
 
   
 
L1: push ecx  								;save counter 避免invoke 有使用到這個暫存器
   
	INVOKE WriteConsoleOutputCharacter,		;印出外框身體
       outputHandle,
       ADDR boxBody,   						
       BoxWidth,
       xyPosition,
       ADDR cellsWritten 
 
    inc xyPosition.y   	 ;換到下一行
    pop ecx   			 ;重置ecx
    loop L1
 
    INVOKE WriteConsoleOutputCharacter,		;印出外框下半
       outputHandle,
       ADDR boxBottom,   
       BoxWidth,
       xyPosition,
       ADDR cellsWritten 
	
	mov xyPosition.X, 32					;表格初始位置xy
	mov xyPosition.Y, 12
	
	INVOKE WriteConsoleOutputCharacter,		;印出表格上半(此段不需要顏色設定)
       outputHandle,   						
       ADDR inputMapTop,   
       inputMapLength,   
       xyPosition,   
       ADDR cellsWritten    
	   
	inc xyPosition.y						;換到下一行
	
	mov ecx, 2								;設定印出表格所需的迴圈數
inputMapStage :	
	push ecx								;將counter存入stack避免其值被更動，影響迴圈
	
	INVOKE WriteConsoleOutputAttribute,		;設定表格身體上部顏色
      outputHandle,
      ADDR attributes0,
      inputMapLength,
      xyPosition,
      ADDR cellsWritten
	
	INVOKE WriteConsoleOutputCharacter,		;印出表格身體上部，此為第1、2列
       outputHandle,   
       ADDR inputMapBody1,   
       inputMapLength,   
       xyPosition,   
       ADDR cellsWritten    
	   
	inc xyPosition.y						;換到下一行
	
	  INVOKE WriteConsoleOutputAttribute,	;設定表格身體下部顏色
      outputHandle,
      ADDR attributes0,
      inputMapLength,
      xyPosition,
      ADDR cellsWritten
	
	INVOKE WriteConsoleOutputCharacter,		;印出表格身體下部
       outputHandle,   
       ADDR inputMapBody2,   
       inputMapLength,   
       xyPosition,   
       ADDR cellsWritten    
	
	inc xyPosition.y						;換到下一行
	pop ecx									;將原本存入的counter提出，保持其計算正確
	dec ecx									;迴圈次數-1
	cmp ecx, 0								;counter與0比對，如果不同則跳回印出表格身體階段
	jne inputMapStage						;由於loop 無法跳躍過長的距離，改以jmp的方式進行
	
	INVOKE WriteConsoleOutputAttribute,		;設定表格身體上部顏色
      outputHandle,
      ADDR attributes0,
      inputMapLength,
      xyPosition,
      ADDR cellsWritten
	
	INVOKE WriteConsoleOutputCharacter,		;印出表格身體上部，此為第3列
       outputHandle,   
       ADDR inputMapBody1,   
       inputMapLength,   
       xyPosition,   
       ADDR cellsWritten    
	   
	inc xyPosition.y						;換到下一行
	
	INVOKE WriteConsoleOutputCharacter,		;印出表格身體下部
       outputHandle,   
       ADDR inputMapBody2,   
       inputMapLength,   
       xyPosition,   
       ADDR cellsWritten    
	
	inc xyPosition.y						;換到下一行
	
	mov ecx, 2
inputMapStage2 :	
	push ecx								;將counter存入stack避免其值被更動
	
	INVOKE WriteConsoleOutputAttribute,		;設定表格身體上部顏色
      outputHandle,
      ADDR attributes1,
      inputMapLength,
      xyPosition,
      ADDR cellsWritten
	
	INVOKE WriteConsoleOutputCharacter,		;印出表格身體上部，此為4、5列
       outputHandle,   
       ADDR inputMapBody1,   
       inputMapLength,   
       xyPosition,   
       ADDR cellsWritten    
	   
	inc xyPosition.y						;換到下一行
	
	  INVOKE WriteConsoleOutputAttribute,	;設定表格身體下部顏色
      outputHandle,
      ADDR attributes1,
      inputMapLength,
      xyPosition,
      ADDR cellsWritten
	
	INVOKE WriteConsoleOutputCharacter,		;印出表格身體下部
       outputHandle,   
       ADDR inputMapBody2,   
       inputMapLength,   
       xyPosition,   
       ADDR cellsWritten    
	
	inc xyPosition.y						;換到下一行
	pop ecx									;將原本存入的counter提出，保持其計算正確
	dec ecx									;迴圈次數-1
	cmp ecx, 0								;counter與0比對，如果不同則跳回印出表格身體階段
	jne inputMapStage2
	
	INVOKE WriteConsoleOutputAttribute,		;設定表格身體上部顏色
      outputHandle,
      ADDR attributes1,
      inputMapLength,
      xyPosition,
      ADDR cellsWritten
	
	INVOKE WriteConsoleOutputCharacter,		;印出表格身體上部，此為第6列
       outputHandle,   
       ADDR inputMapBody1,   
       inputMapLength,   
       xyPosition,   
       ADDR cellsWritten    
	   
	inc xyPosition.y						;換到下一行
	
	INVOKE WriteConsoleOutputCharacter,		;印出表格身體下部
       outputHandle,   
       ADDR inputMapBody2,   
       inputMapLength,   
       xyPosition,   
       ADDR cellsWritten    
	
	inc xyPosition.y						;換到下一行
	
	mov ecx, 2								;設定印出表格所需的迴圈數
inputMapStage3 :	
	push ecx								;將counter存入stack避免其值被更動
	
	INVOKE WriteConsoleOutputAttribute,		;設定表格身體上部顏色
      outputHandle,
      ADDR attributes0,
      inputMapLength,
      xyPosition,
      ADDR cellsWritten
	
	INVOKE WriteConsoleOutputCharacter,		;印出表格身體上部，此為第7、8列
       outputHandle,   
       ADDR inputMapBody1,   
       inputMapLength,   
       xyPosition,   
       ADDR cellsWritten    
	   
	inc xyPosition.y						;換到下一行
	
	  INVOKE WriteConsoleOutputAttribute,	;設定表格身體下部顏色
      outputHandle,
      ADDR attributes0,
      inputMapLength,
      xyPosition,
      ADDR cellsWritten
	
	INVOKE WriteConsoleOutputCharacter,		;印出表格身體下部
       outputHandle,   
       ADDR inputMapBody2,   
       inputMapLength,   
       xyPosition,   
       ADDR cellsWritten    
	
	inc xyPosition.y						;換到下一行
	pop ecx									;將原本存入的counter提出，保持其計算正確
	dec ecx									;迴圈次數-1
	cmp ecx, 0								;counter與0比對，如果不同則跳回印出表格身體階段
	jne inputMapStage3
	
	INVOKE WriteConsoleOutputAttribute,		;設定表格身體上部顏色
      outputHandle,
      ADDR attributes0,
      inputMapLength,
      xyPosition,
      ADDR cellsWritten
	
	INVOKE WriteConsoleOutputCharacter,		;印出表格身體上半，此為第9列
       outputHandle,  
       ADDR inputMapBody1,   
       inputMapLength,   
       xyPosition,   
       ADDR cellsWritten   
		
	inc xyPosition.y						;換到下一行
	
	INVOKE WriteConsoleOutputCharacter,		;印出表格下半
       outputHandle,  
       ADDR inputMapBottom,   
       inputMapLength,  
       xyPosition,   
       ADDR cellsWritten   
	   
	mov xyPosition.x, 33
	mov xyPosition.y, 11
	INVOKE WriteConsoleOutputCharacter,		;印出上標頭，由於初始點為<33,13>，將Y-2為上標頭起始
       outputHandle,  
       ADDR header,   
       lengthof	header,  
       xyPosition,   
       ADDR cellsWritten
	   
	mov edi, offset header
	
	mov xyPosition.x, 31
	mov xyPosition.y, 13
	mov ecx, 9								;1~9共9個數字
printHeadLeft:
	push ecx
	INVOKE WriteConsoleOutputCharacter,		;印出左標頭，由於初始點為<33,13>，將X-2為左標頭起始
       outputHandle,  
       edi,   
       1,  
       xyPosition,   
       ADDR cellsWritten
	add edi, 2								;字串中有空白隔開，所以加二才是下一個數字
	add xyPosition.y, 2						;Y往下2才是往下一個表格位置
	pop ecx
	loop printHeadLeft
	
	mov ecx, 81								;設定要印出題目的判斷迴圈數
	mov edi, offset mapValue				;預設好表格值地址存入mapValueIndex
	mov mapValueIndex, edi
	mov edi, offset mapColor				;預設好表格顏色地址存入mapColorIndex
	mov mapColorIndex, edi
	mov edi, offset taskAnswer				;題目答案的array地址
	mov esi, offset mapValueBool			;是否印出數值的array地址
	mov xyCur.x, 33							;設定表格第一格xy位置
	mov xyCur.y, 13	
printTask:
	mov edx, 0								;清空edx
	mov dl, [esi]							;將此格題目印出
	.IF dl == '1'							;如果此格為題目，也就是判斷為'1'
		;設定位置到dh(x), dl(y)，設定印出位置
		mov eax, 0							
		mov ax, xyCur.x
		mov dl, al
		mov ax, xyCur.y
		mov dh, al
		call gotoxy
		;此段為判斷該格的顏色，先將edi存入stack保持其值，然後設定印出顏色
		push edi
		mov edi, mapColorIndex
		mov eax, 0
		mov al, [edi] 
		.IF al == '0'
			mov eax, white+(lightblue*16)
		.ENDIF
		.IF al == '1'
			mov eax, black+(white*16)
		.ENDIF
		call SetTextColor
		pop edi
		;將題目存入al後印出
		mov al, [edi]
		call writechar
		;將題目的值存入到表格值，之後判斷是否題目完成用
		push edi
		mov edi, mapValueIndex
		sub al, '0'							;減掉'0'會使其變成數值
		mov ebx, 0
		mov bl, al
		mov BYTE ptr [edi], bl
		pop edi
	.ENDIF
	mov ax, xyCur.x							;存入此格的x位置後將其指到右邊一格，如果x的位置超過表格大小，則將起指向下一行的開頭
	add ax, 2
	.IF ax > 49
		mov ax, 33
		mov bx,xyCur.y
		add bx, 2
		mov xyCur.y, bx
	.ENDIF
	mov xyCur.x, ax
	;答案、表格內的值、顏色判斷和題目判斷array指向下一位
	inc edi									
	push edi
	mov edi, mapValueIndex
	inc edi
	mov mapValueIndex, edi
	pop edi
	push edi
	mov edi, mapColorIndex
	inc edi
	mov mapColorIndex, edi
	pop edi
	inc esi
	dec ecx
	cmp ecx, 0
	jne printTask							;loop直到所有表格內容都判斷並印出
	;重置游標、顏色
	INVOKE SetConsoleCursorPosition, consoleHandle, xyInit		
	mov eax, white+(black*16)
	call SetTextColor
	
L2 :
	;此段為判斷跳出程式和user指定表格x位置，輸入完後重置游標和清除輸入
	mov eax, 0 
	call readint
	.IF eax <= 9
		mov xyPos.x, ax						;在xyPos中存入user輸入表格的X位置
	.ENDIF
	.IF eax == 10
		jmp END_stage
	.ENDIF
	INVOKE WriteConsoleOutputCharacter,
       outputHandle,   
       ADDR clearBuffer,   
       lengthof clearBuffer,   
       xyInit,  
       ADDR cellsWritten    
	INVOKE SetConsoleCursorPosition, consoleHandle, xyInit
	
	;此段為user指定表格y位置，輸入完後重置游標和清除輸入
	call readint
	.IF eax <= 9
		mov xyPos.y, ax						;在xyPos中存入user輸入表格的Y位置
	.ENDIF
	INVOKE WriteConsoleOutputCharacter,
       outputHandle,   
       ADDR clearBuffer,  
       lengthof clearBuffer,   
       xyInit,   
       ADDR cellsWritten   
	INVOKE SetConsoleCursorPosition, consoleHandle, xyInit
	
	;此段將user存入表格的數值紀錄下來
	call readint
	.IF eax <= 9
		mov mapTemp, al					    ;mapTemp存入user輸入的值
		mov edi, offset mapValue
		mov eax, 0
		mov ebx, 0
		;使用者輸入的y位置，將其減一並乘以9(由於陣列為9個一列，引數每加9就向下一列)
		mov ax, xyPos.y						
		dec ax
		mov bx, 9
		mul bx
		;使用者輸入的x位置，將其減一
		mov bx, xyPos.x
		dec bx
		add ax, bx
		;處理過後的x和y相加即是引數，用於表格值和顏色判斷
		mov mapIndex, ax
		mov ebx, 0
		mov bx, mapIndex
		add edi, ebx
		mov esi, offset mapValueBool
		add esi, ebx
		push esi
		mov esi, offset mapColor
		add esi, ebx
		mov mapColorIndex, esi
		pop esi
		mov al, [esi]
		;如果al為'0'，代表這題為user可輸入的地方
		.IF al == '0'
			mov ebx, 0
			mov bl, mapTemp
			mov BYTE ptr [edi], bl
		.ENDIF
        ;判斷表格內所有的值是否為正確
        INVOKE judgeRow
        .IF al == 1
            jmp END_stage
        .ENDIF
        INVOKE judgeColumn
        .IF al == 1
           jmp END_stage
        .ENDIF  
        INVOKE judgeCube
        .IF al == 1
           jmp END_stage
        .ENDIF
    
	.ENDIF
	

	;一樣清空輸入、重置游標
	INVOKE WriteConsoleOutputCharacter,
       outputHandle,   
       ADDR clearBuffer,   
       lengthof clearBuffer,   
       xyInit,   
       ADDR cellsWritten    
	INVOKE SetConsoleCursorPosition, consoleHandle, xyInit
	
	;指定表格的位置後將user指定的值填入表格
	mov eax, 0
	mov ax, xyPos.x
	dec eax
	mov ecx, 2
	mul ecx
	mov ebx, 0
	mov bx, xyInit2.x
	add ebx, eax
	mov xyCur.x, bx
	
	mov eax, 0
	mov ax, xyPos.y
	dec eax
	mov ecx, 2
	mul ecx
	mov ebx, 0
	mov bx, xyInit2.y
	add ebx, eax
	mov xyCur.y, bx
	
	;如果這一格是題目，則略過
	mov eax, 0
	mov al, [esi]
	.IF al == '0'
		mov eax, 0
		mov ax, xyCur.x
		mov dl, al
		mov ax, xyCur.y
		mov dh, al
		call gotoxy
		
		push esi
		mov esi, mapColorIndex
		mov eax, 0
		mov al, [esi]
		.IF al == '0'
			mov eax, lightblue*16
		.ENDIF
		.IF al == '1'
			mov eax, white*16
		.ENDIF
		push esi
		mov esi, offset taskAnswer
		mov ebx, 0
		mov bx, mapIndex
		add esi, ebx
		mov ebx, 0
		mov bl, mapTemp
		add bl, '0'
		push ecx
		mov ecx, 0
		mov cl, [esi]
		.IF bl == cl
			add eax, lightgreen
		.ENDIF
		.IF bl != cl
			add eax, red
		.ENDIF
		pop ecx
		pop esi
		
		call SetTextColor
		mov al, mapTemp
		or al, 00110000b
		call writechar
	.ENDIF
	INVOKE SetConsoleCursorPosition, consoleHandle, xyInit				;重置游標
	mov eax, white+(black*16)
	call SetTextColor
	
	jmp L2
END_stage :
    call WaitMsg
    call Clrscr
    exit
main ENDP


judgeRow PROC USES ebx ecx esi edi
    mov eax, 1
    mov edi, OFFSET mapValue
    mov ecx, 9
    rows:
    mov esi, OFFSET contentJudge

    push ecx
    mov ecx, 9
        clear:
        mov bl, 0
        mov [esi], bl
        add esi, 1
        loop clear

    mov esi, OFFSET contentJudge
    mov ecx, 9
        judge:
        push ecx
        mov ecx, 9
            oneOf:
            push esi
            cmp [edi], cl
            jne notDo
            add esi, ecx 
            dec esi
            mov bl, [esi]
            inc bl
            mov [esi], bl
            notDo:
            pop esi
            loop oneOf
        add edi, 1
        pop ecx
        loop judge

    mov ecx, 9
        rowIs:
        mov bl, [esi]
        mul bl
        inc esi
        loop rowIs
        
    pop ecx
    loop rows    
    ret
    ;最終結果存在eax(0錯1對)
judgeRow ENDP


judgeColumn PROC USES ecx esi edi
    mov eax, 1
    mov edi, OFFSET mapValue
    mov ecx, 9
    column:
    mov esi, OFFSET contentJudge

    push edi
    push ecx
    mov ecx, 9
        clear:
        mov bl, 0
        mov [esi], bl
        add esi, 1
        loop clear

    mov esi, OFFSET contentJudge
    mov ecx, 9
        judge:
        push ecx
        mov ecx, 9
            oneOf:
            push esi
            cmp [edi], cl
            jne notDo
            add esi, ecx 
            dec esi
            mov bl, [esi]
            inc bl
            mov [esi], bl
            notDo:
            pop esi
            loop oneOf
        add edi, 9
        pop ecx
        loop judge

    mov ecx, 9
        columnIs:
        mov bl, [esi]
        mul bl
        inc esi
        loop columnIs
        
    pop ecx
    pop edi
    inc edi
    loop column   
    ret
    ;最終結果存在eax(0錯1對)
judgeColumn ENDP


judgeCube PROC USES ecx esi edi
    mov eax, 1
    mov edi, OFFSET mapValue

    mov ecx, 3
    cubeColumn:                 ;如你所見 這是3*3大方塊的y軸

    push edi
    push ecx
    mov ecx, 3
        cubeRow:                ;如你所見 這是3*3大方塊的x軸

        mov esi, OFFSET contentJudge
        push edi
        push ecx
        mov ecx, 9
            clear:              ;如你所見 這是將數字計數器歸零
            mov bl, 0
            mov [esi], bl
            add esi, 1
            loop clear

        mov esi, OFFSET contentJudge
        mov ecx, 3
            judgeOfColumn:        ;如你所見 這是1*1小方塊的y軸

            push edi
            push ecx
            mov ecx,3
                judgeOfRow:       ;如你所見 這是1*1小方塊的x軸

                push ecx
                mov ecx, 9
                    oneOf:      ;如你所見 這是比對小方塊與數字計數器中的數字是否相同的迴圈
                    push esi
                    cmp [edi], cl
                    jne notDo
                    add esi, ecx 
                    dec esi
                    mov bl, [esi]
                    inc bl
                    mov [esi], bl
                    notDo:
                    pop esi
                    loop oneOf

                add edi, 1      ;如你所見 這是1*1小方塊的x軸的下一個小方塊
                pop ecx
                loop judgeOfRow

            
            pop ecx
            pop edi
            add edi, 9          ;如你所見 這是1*1小方塊的y軸的下一個小方塊
            loop judgeOfColumn

        mov ecx, 9
            columnIs:           ;如你所見 這是將數字計數器中的數字相乘以確認答案是否正確
            mov bl, [esi]
            mul bl              ;如果裡面有個數字重複，那麼一定會有一個數字的數量為0
            inc esi             ;如此一來，與al相乘起來結果必為0
            loop columnIs
            
        pop ecx
        pop edi
        add edi, 3              ;如你所見 這是3*3大方塊的x軸的下一個大方塊
        loop cubeRow

    pop ecx
    pop edi
    add edi, 27                 ;如你所見 這是3*3大方塊的y軸的下一個大方塊
    loop cubeColumn
    ret
    ;最終結果存在eax(0錯1對)
judgeCube ENDP
END main