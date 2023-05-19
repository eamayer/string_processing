TITLE String Primatives    (Proj6_mayerel.asm)

; Author: Elizabeth Mayer
; Last Modified: 14Mar2021
; OSU email address: mayerel@oregonstate.edu
; Course number/section:   CS271 Section 401
; Project Number: 6                Due Date: 16Mar2021
; Description: This program gets 10 signed integers that will fit in 32-bit register from the user,
; prints the integers back to the user, along with the sum of the values and the average (always floor rounded)
;


INCLUDE Irvine32.inc

; ---------------------------------------------------------------------------------
; Name: mGetString
;
; Displays prompt for user to enter a valid number (signed intger) and then get's users keyboard input. Stores the
; users value they entered and how many bytes it is.
;
; Preconditions: do not use edx, ecx, eax as arguments. prompt is bytes, valueEntered is bytes, maxValue is SDWORD,
; byteCount is SDWORD
;
; Receives:
; prompt = prompt address (input parameter, by reference)
; valueEntered = valueEntered address (output parameter, by reference)
; maxValue = maxValue (input parameter, by value)
; byteCount = byteCount address (output parameter, by reference)
;
; returns: valueEntered = valueEntered by the user
;			byteCount = how many bytes the value entered is
; ---------------------------------------------------------------------------------

mGetString MACRO prompted:REQ, valueEnter:REQ, maxValued:REQ, byteCounts:REQ, byteAddress

; ---------------------------------------------------------------------------------
;Display a prompt using the mDisplayString macro, gets the user�s keyboard input and places into a memory location.
; Also stores how many bytes the value entered is.
; ---------------------------------------------------------------------------------

	PUSHAD

	mDisplayString  prompted
	MOV		EDX, valueEnter
	MOV		ECX, maxValued			; buffer required for ReadString
	CALL	ReadString
	MOV		byteCounts, EAX		; store the bytes in memory
	CALL	CrLF

	POPAD

ENDM

; ---------------------------------------------------------------------------------
; Name: mDisplayString
;
; Prints a string which is stored in a specified memory location
;
; Preconditions: do not use edx as arguments, array is BYTES
;
; Receives:
; array = array address (input parameter, by reference)
;
; returns: None
; ---------------------------------------------------------------------------------

mDisplayString MACRO array:REQ

	PUSHAD

	; writes array that was input
	MOV	EDX, array
	CALL WriteString

	POPAD

ENDM


ARRAYLENGTH = 10


.data
programTitle		BYTE	'Low-level Procedures by Elizabeth Mayer', 13, 10, 0
programDescription	BYTE	'Please enter 10 decimals that are positive or negative.', 13, 10,
							'Each number needs to be small enough ',
							'to fit in a 32-bit register. After you enter 10 valid numbers, ', 13, 10,
							'I will display the full list of all the numbers plus',
							' give you the sum and average of the numbers. ', 13, 10 , 0
prompt				BYTE	'. Please enter a signed integer: ', 0
errorMsg			BYTE	'That is not a valid number. It is either too big ', 13, 10,
							'or contains characters. Let us try that again.', 13, 10, 0
errorMsgprompt		BYTE	'. Please try again: ', 0
asciiArray			BYTE	33 DUP(?)
orderedASCIIArray	BYTE	33 DUP(?)
spacecomma			BYTE	', ', 0																		; used for printing values back to user																																				; used f
printNumsText		BYTE	'The valid numbers you entered were: ', 13, 10, 0
sumText				BYTE	'The sum of the numbers is: ', 0
roundedAveText		BYTE	'The rounded average is:', 0
runningTotalText	BYTE	'. The running total is: ', 0
valueEntered		BYTE	33 DUP(0)
extraCredit			BYTE	'**EC Description 1: Number each line of user input and display a running ', 13, 10,
							'subtotal of the users valid numbers', 13, 10, 0
numArray			DWORD	ARRAYLENGTH DUP (0)
count				DWORD	1																			; start at 1 to use for printing values entered
sum					SDWORD	0
average				SDWORD	0
numArrayLength		DWORD	LENGTHOF numArray
maxValue			DWORD	SIZEOF valueEntered
byteCount			DWORD	?
convertedValue		SDWORD	?


.code
main PROC


; display the introduction to user by showing program description and title and extra credit
_displayIntro:
	PUSH OFFSET	extraCredit
	PUSH OFFSET programDescription
	PUSH OFFSET programTitle
	CALL displayInstructions


;-----------------------------------------------------------------------
; Test Program that get 10 valid integers from the user. Throws an
; error message if the value is not valid. Reprompts for new number.
; numbers the lines with the number of values and shows the running total.
; Stores these numeric values in an array.
; Display the integers, their sum, and their average.
;-----------------------------------------------------------------------

_testProgram:

;-----------------------------------------------------------------------
; gets 10 values from user and stores them in array
;-----------------------------------------------------------------------
	; set up to be able to write numbers to array
	MOV	ESI, OFFSET numArray

	; gets validated value from user
	_readValLoop:

		PUSH OFFSET runningTotalText
		PUSH OFFSET errorMsgPrompt
		PUSH OFFSET orderedASCIIArray
		PUSH OFFSET asciiArray
		PUSH sum
		PUSH count
		PUSH OFFSET errorMsg
		PUSH OFFSET convertedValue
		PUSH maxValue
		PUSH OFFSET valueEntered
		PUSH OFFSET byteCount
		PUSH OFFSET prompt
		CALL readVal

	; adds value to the array and keeps track
	_writeValueToArray:
		MOV	EAX, convertedValue
		MOV	[ESI], EAX
		ADD	ESI, 4

	; adds value to the sum and determines is array is complete
	_trackSumAndArrayLength:
		ADD sum, EAX
		INC count
		CMP count, ARRAYLENGTH
		JLE _readValLoop

;-----------------------------------------------------------------------
; Displays the values back to the user with a space and comma inbetwen each value
;-----------------------------------------------------------------------
	_writeVal:
		MOV  ECX, numArrayLength
		MOV  ESI, OFFSET numArray

	; runs through each value in the array and prints it
	_writeValLoop:
		MOV	 EDX, [ESI]					; move value from array into EDX
		MOV	 convertedValue, EDX		; move into variable
		PUSH OFFSET orderedASCIIArray
		PUSH convertedValue
		PUSH OFFSET asciiArray
		CALL writeVal

		;adds a comma and space between printed values
		_addCommaAndSpace:
			mDisplayString  OFFSET spacecomma

		; move to next value to print
		_nextValueToPrint:
			ADD	ESI, 4
			LOOP _writeValLoop
			CALL Crlf
			CALL Crlf

;----------------------------------------------------------------------
; Calculates the average with using floor rounding
;-----------------------------------------------------------------------

	_calculateAverage:
		MOV	 EAX, sum
		CDQ
		IDIV numArrayLength
		MOV	 average, EAX
		CMP  EAX, 0
		JGE  _writeSumText
		CMP  EDX, 0
		JE   _writeSumText

	_floorNegativeAverage:
		DEC  average

;----------------------------------------------------------------------
; Displays the sum and average back to the user
; along with text telling them what is being displayed
;-----------------------------------------------------------------------

	_writeSumText:
		mDisplayString OFFSET sumText
		CALL CrLF

	; print the value for the sum
	_writeSum:
		PUSH OFFSET orderedASCIIArray
		PUSH sum
		PUSH OFFSET asciiArray
		CALL writeVal
		CALL CrLF
		CALL CrLF

	;write the text for rounded average
	_writeAverageText:
		mDisplayString OFFSET roundedAveText
		CALL CrLF

	;write the rounded average
	_writeAverage:
		PUSH OFFSET orderedASCIIArray
		PUSH average
		PUSH OFFSET asciiArray
		CALL writeVal
		CALL CrLF


	Invoke ExitProcess,0	; exit to operating system
main ENDP

; ---------------------------------------------------------------------------------
; Name: introduction
;
; Prints the program title, my name, and the program description
;
; Preconditions: program title and name must be a BYTE and program description must be a BYTE
;
; Postconditions: None
;
; Receives:
; [EBP + 8] = name of the program and author address
; [EBP + 12] = description of program address
; [EBP + 16] = extra credit address

;
; Returns: None
;
; ---------------------------------------------------------------------------------

displayInstructions PROC
;
	PUSH	EBP
	MOV		EBP, ESP
	PUSHAD

	mDisplayString [EBP + 8]			; name and program title
	CALL	CrLF

	mDisplayString [EBP + 12]			; program description
	CALL	CrLF

	mDisplayString [EBP + 16]			; extra credit
	CALL	CrLF

	POPAD
	POP		EBP
	RET 12

displayInstructions ENDP


; ---------------------------------------------------------------------------------
; Name: readVal
;
; Invoke getString macro to read user input, converts using string primatives from ascii to numeric value (SDWORD),
; validates the number (signed integer that will fit in 32-Bit register), if value is not valid it gives an error
; message and prompts user for another value. Stores value in memory. Shows the running total of the sums of the values
; entered prior. Numbers each line with the the number of values that have been entered so far, including the one
; they are about to enter
;
; Preconditions: prompt	is BYTE, errorMsg is BYTE, errorMsgprompt is BYTE, asciiArray is BYTE, orderedASCIIArray is BYTE,
;sumTextis BYTE, runningTotalText is BYTE, valueEntered is BYTE, convertedValue is SDWORD, count is SDWORD,  runningTotal is SDWORD,
;
; Postconditions: None
;
; Receives:
; [EBP + 8] = prompt address
; [EBP + 12] = byeCount address
; [EBP + 16] = enteredValue address
; [EBP + 20] = maxValue value (used for buffer for readString)
; [EBP + 24] = covertedValue address
; [EBP + 28] = error message address
; [EBP + 32] = count (number of values entered [including the one about to be entered])
; [EBP + 36] = running sum of the total (sum)
; [EBP + 40] = asciiArray address
; [EBP + 44] = orderedasciiarray
; [EBP + 48] = errorMsgPrompt
; [EBP + 52] = runningTotalText
;
; Returns:  valueEntered = value entered as a string
;			convertedValue = valid number entered by user converted to integer
;			byteCounter = how many bytes are in the user's value
;
; ---------------------------------------------------------------------------------


readVal PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSHAD

; ---------------------------------------------------------------------------------
; Displays the number of the value they are about to enter (1, 2, 3....) and the running total
; and then propmts for the user to enter a number.
;
; Example of what is displayed to user: 1. The running sum is : 0. Please enter a number: (user enter number)
; ---------------------------------------------------------------------------------

_displayNumberForLine:
	PUSH	[EBP + 40]							; orderedASCIIArray address
	PUSH	[EBP + 32]							; number of value they are about to enter
	PUSH	[EBP + 44]							; asciiArray address
	CALL writeVal


_displayRunningSum:

	mdisplayString [EBP + 52]					; running total text

	; display the running sum
	PUSH	[EBP + 40]							; orderedASCIIArray address
	PUSH	[EBP + 36]							; running sum of values entered
	PUSH	[EBP + 44]							; asciiArray address
	CALL writeVal


_promptforNumber:

;	MOV		EBX, [EBP + 12]						; byte address


	mGetString [EBP + 8], DWORD PTR [EBP+16], [EBP + 20], [EBP + 12]	; prompt:REQ, valueEntered:REQ, maxValue:REQ, byteCount:REQ

; ---------------------------------------------------------------------------------
; Changes valueEntered from a string to an integer through taking each element
; adding 48 to it and either adding or subtractint it from 10 * previous running total
; depending on the sign.
; If number is positive: (element - 48) + (10*running total)
; If number is negative: (element - 48) - (10*running total)
; Validates each element to make sure it is a number and that the number will fit in a
; 32-bit register (high of 2147483,647 and low of -2147483648).
;
; Example of valid inputs: -154, 234, +43243
; Example of invalid inputs: -15+4, f2g34, +4gd3243
; ---------------------------------------------------------------------------------

	_checkNumber:
	MOV		ESI, [EBP + 16]						; move entered value into a ESI to be able to tranverse to convert it to a number
	MOV		ECX, [EBP + 12]						; byteCount value
	MOV		EBX, 0								; EBX is used to accumulate the total as we go
	MOV		EAX, 0
	MOV		EDX, 0

	cld											; clear the direction flag

	LODSB										; load first element to determine whether + or - or none

	CMP		AL, 45								; check if negative sign
	JE		_checkBytesNegative
	CMP		AL, 43								; check if positive sign
	JE		_checkBytesPositive
	JMP		_validateElement					; neither + or - is first element, ready to validate

	_checkBytesNegative:
		CMP		ECX, 1
		JNE		_setAsNegativeNumber			; value entered was just "-"
		JMP		_error

	_checkBytesPositive:
		CMP		ECX, 1							; value entered was just "+"
		JNE		_validateLoopCheck
		JMP		_error

_validateLoop:
	MOV		EAX, 0								; clear EAX to allow for loading element into AL
	LODSB										; puts byte in AL

	_validateElement:
		CMP		AL, 57
		JG		_error
		CMP		AL, 48
		JL		_error

		SUB		AL, 48							; convert from ascii to integer by subtractin 48

		CMP		EDX, 1							; detemine if number is negative
		JE		_negativeNumberLoop

		_postiveNumberLoop:
			IMUL	EBX, 10
			JO		_error
			ADD		EBX, EAX
			JO		_error
			JMP		_validateLoopCheck

		_negativeNumberLoop:
			IMUL	EBX, 10
			JO		_error
			SUB		EBX, EAX
			JO		_error

	_validateLoopCheck:							; checks whether ready to add to memory
		LOOP	_validateLoop
		JMP		_addToMemory

_setAsNegativeNumber:							; sets EDX as 1 to allow for tracking negative
	MOV		EDX, 1
	DEC		ECX
	JMP		_validateLoop

; ---------------------------------------------------------------------------------
; Display an error message, then show prompt for an additional value.
; The prompt message line  begins with the number of the value they are about to enter
; Example if about to enter 5th value: "5. Please try again:"
; ---------------------------------------------------------------------------------

_error:
	mDisplayString [EBP + 28]					; error message
	CALL CrLF

	; display the number of the value they are about to enter
	PUSH [EBP + 40]								; orderedASCIIArray address
	PUSH [EBP + 32]								; running number of values entered
	PUSH [EBP + 44]								; asciiArray address
	CALL writeVal

	; reprompt for number

	mGetString [EBP + 48], DWORD PTR [EBP+16], [EBP + 20], [EBP + 12] ; prompt:REQ, valueEntered:REQ, maxValue:REQ, byteCount:REQ

	JMP	 _checkNumber				; get next value from user

_addToMemory:
	MOV		ECX, [EBP + 24]						; convertedValue address
	MOV		[ECX], EBX							; store value in convertedValue


	POPAD

	POP		EBP
	RET		28

readVal ENDP


; ---------------------------------------------------------------------------------
; Name: writeVal
;
; Converts a value from SDWORD to a string of ascii digits which gets printed. Converts from SDWORD
; to ascii through dividing by 10 and adding 48 to the remainder and placing into orderedArray until quotient is 0.
; Then reverses the array by placing into new array. Adds a null terminator to the end.
;
; Preconditions: value to convert is an SDWORD, asciiArray is BYTE, orderedArray is BYTE
;
; Postconditions: EAX, EBX and ESI are changed.
;
; Receives:
;			[EBP+8]  = asciiArray address (input/output parameter, by reference)
;			[EBP+12] = SDWORD value (input parameter, by value)
;			[EBP+16] = orderedArray address (input/output parameter, by reference)
;
; Returns:
;		orderedArray = SDWORD converted to array of BYTES
;		asciiArray = reversed SDWORD converted to array of BYTES
;
; ---------------------------------------------------------------------------------

writeVal  PROC

	PUSH	EBP
	MOV		EBP, ESP
	PUSHAD

; ---------------------------------------------------------------------------------
; prepare the asciiArray for writing and determie if number is negative,
; if negative, it will begate the numbe prior to conversion
; ---------------------------------------------------------------------------------

	MOV EDI, [EBP+8]			; asciiArray address
	MOV EAX, [EBP+12]			; SDWORD value
	MOV ECX, 0
	CMP EAX, 0					; determine if number is negative
	JGE _convertLoop
	NEG EAX						; turn the number from negative to positive too allow for ascii conversion
	MOV ESI, -1

; ---------------------------------------------------------------------------------
; convert the integer into the ascii representation
; through dividing by 10 and placing remainder into asciiArray until quotient is 0.
; Determine if a "-" sign is required to be added to the asciiArray based on whether
; the SDWORD is negative or not
; ---------------------------------------------------------------------------------
	cld

_convertLoop:

	MOV EDX, 0
	MOV EBX, 10
	DIV EBX

	ADD EDX, 48
	PUSH EAX					; preserve quotient for negative compare to be able to use STOSB
	MOV EAX, EDX
	STOSB
	INC ECX
	POP EAX
	CMP EAX, 0					; compare quotient to 0, if it is 0 then time to reverse
	JE _checkSign
	JMP _convertLoop

_checkSign:
	MOV EAX, [EBP+12]			;SDWORD
	CMP EAX, 0
	JGE _reverse_String

	MOV EDX, 45					; add 45 at the end of asciiArray to add a "-" sign
	MOV	EAX, EDX
	STOSB						; add to string
	INC ECX						; increase loops to include the addition of "-" sign

; ---------------------------------------------------------------------------------
; reverse the asciiArray through traversing via string primative
; and place into the orderedArray with a null terminator at the end
; ---------------------------------------------------------------------------------
_reverse_string:
	MOV ESI, [EBP+8]			; move asciiArray into ESI to serve as source
	ADD ESI, ECX				; move to the end of asciiArray
	DEC ESI
	MOV EDI, [EBP+16]			; move orderedArray into EDI to serve as destination

	_reverseLoop:
		STD
		LODSB
		CLD
		STOSB
	LOOP   _reverseLoop


	MOV	EDX, 0h					; add null terminator at end of orderedArray
	MOV [EDI], EDX


	mDisplayString  [EBP+16]	;invoke mDisplayString macro to print the ascii representation of SDWORD value to the output

	POPAD
	POP   EBP
	RET   12

writeVal ENDP

END main
