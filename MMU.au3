#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Outfile=..\asd.Exe
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs ----------------------------------------------------------------------------

	AutoIt Version: 3.3.15.0 (Beta)
	Author:         Borja Live

	UDF Function:
	Simulacion de algoritmos de remplazo

#ce ----------------------------------------------------------------------------

#include <Array.au3>

#Region CONSTTANTS
$SWAP_ALGORITHM_OPTIMUS = 1
$SWAP_ALGORITHM_FIFO = 2
$SWAP_ALGORITHM_LRU = 3
$SWAP_ALGORITHM_NRU = 4
$SWAP_ALGORITHM_AGING = 5
$SWAP_ALGORITHM_CLOCK = 6
$SWAP_ALGORITHM_LFU = 7
$SWAP_ALGORITHM_MFU = 8
$SWAP_ALGORITHM_CLOCK_LINUX = 9
#Region ERRORS
$ERROR_NO_ERROR = 0
$ERROR_INCORRECT_REFERENCE_FORMAT = 1
$ERROR_INVALID_INITIAL_FRAMES_NUMBER = 2
$ERROR_TOO_MANY_INICIALICED_PAGES = 3
$ERROR_INVALID_INICIALICATION = 4
#EndRegion ERRORS
#Region INICIALIZATION_PARAMETERS
Dim $SPECTED_INICIALIZATION_PARAMETERS[10] = [0, 1, 2, 2, 3, 3, 3, 2, 2, 3]
#cs
	0 : Page
	OPTIMUS
		NONE
	FIFO
		InitialFifo
	LRU
		InitialPT(COUNTER)
	NRU
		InitialPT(BR BM [COUNTER]) Modifications
	AGING
		BufferSize InicialBuffer
	CLOCK
		InitialPT(BR) InitialFifo
	LFU
		InitialPT(COUNTER [ENTRANCE])
	MFU
		InitialPT(COUNTER [ENTRANCE])
	CLOCK LINUX
		InitialPT(COUNTER) InitialFifo
#ce
#EndRegion INICIALIZATION_PARAMETERS
#EndRegion CONSTTANdTS

;___Test_1()
;___Test_2()
;___Test_3()
;___Test_4()
;___Test_5()
;___Test_6()
;___Test_7()
;___Test_8()

#Region INTERFACE
Func _MMUsolve($algorithm, $references, $initialFrames, $wsResetsBR = False, $workingSetS = 0, $wsPolitic = 1, $inicializacion = 0)
	If IsArray($inicializacion) Then
		$initialPages = $inicializacion[0]
	Else
		$initialPages = 0
	EndIf

	;Verificar la integridad de los datos
	If (Not IsArray($references)) Then Return SetError($ERROR_INCORRECT_REFERENCE_FORMAT)
	If ($initialFrames < 1) Then Return SetError($ERROR_INVALID_INITIAL_FRAMES_NUMBER)
	If (IsArray($initialPages) And $initialFrames < UBound($initialPages)) Then Return SetError($ERROR_TOO_MANY_INICIALICED_PAGES)
	If (IsArray($inicializacion) And UBound($inicializacion) <> $SPECTED_INICIALIZATION_PARAMETERS[$algorithm]) Then Return SetError($ERROR_INVALID_INICIALICATION)

	;Inicializar el terreno
	If $workingSetS > $initialFrames Then
		Local $resoult[$workingSetS + 1][UBound($references)]
	Else
		Local $resoult[$initialFrames + 1][UBound($references)]
	EndIf
	For $i = 1 To UBound($resoult, 1) - 1
		$resoult[$i][0] = "BLOCK"
	Next
	For $i = 1 To $initialFrames
		$resoult[$i][0] = "NULL"
	Next
	If IsArray($initialPages) Then
		For $i = 0 To UBound($initialPages) - 1
			$resoult[$i + 1][0] = $initialPages[$i]
		Next
	EndIf
	For $i = 0 To UBound($references) - 1
		$resoult[0][$i] = ""
	Next
	If $wsPolitic == 1 Then
		$wsPolitic = $algorithm
	Else
		$wsPolitic = -$wsPolitic
	EndIf

	;Ejecutar el algoritmo
	Switch ($algorithm)
		Case $SWAP_ALGORITHM_OPTIMUS
			__MMU_optimus($references, $wsPolitic, $workingSetS, $resoult)
		Case $SWAP_ALGORITHM_FIFO
			__MMU_FIFO($references, $wsPolitic, $workingSetS, IsArray($inicializacion) ? $inicializacion[1] : 0, $resoult)
		Case $SWAP_ALGORITHM_LRU
			__MMU_LRU($references, $wsPolitic, $workingSetS, IsArray($inicializacion) ? $inicializacion[1] : 0, $resoult)
		Case $SWAP_ALGORITHM_NRU
			__MMU_NRU($references, $wsPolitic, $wsResetsBR, $workingSetS, IsArray($inicializacion) ? $inicializacion[2] : 0, IsArray($inicializacion) ? $inicializacion[1] : 0, $resoult)
		Case $SWAP_ALGORITHM_AGING
			__NMU_AGING($references, $wsPolitic, $workingSetS, IsArray($inicializacion) ? $inicializacion[1] : 8, IsArray($inicializacion) ? $inicializacion[2] : 0, $resoult)
		Case $SWAP_ALGORITHM_CLOCK
			__MMU_CLOCK($references, $wsPolitic, $wsResetsBR, $workingSetS, IsArray($inicializacion) ? $inicializacion[1] : 0, IsArray($inicializacion) ? $inicializacion[2] : 0, $resoult)
		Case $SWAP_ALGORITHM_LFU
			__MMU_XFU($references, $wsPolitic, $workingSetS, IsArray($inicializacion) ? $inicializacion[1] : 0, $resoult, 1)
		Case $SWAP_ALGORITHM_MFU
			__MMU_XFU($references, $wsPolitic, $workingSetS, IsArray($inicializacion) ? $inicializacion[1] : 0, $resoult, 0)
		Case $SWAP_ALGORITHM_CLOCK_LINUX
			__MMU_CLOCK_LINUX($references, $wsPolitic, $wsResetsBR, $workingSetS, IsArray($inicializacion) ? $inicializacion[1] : 0, IsArray($inicializacion) ? $inicializacion[2] : 0, $resoult)
	EndSwitch

	If @error Then SetError(@error, @extended, $resoult)
	Return $resoult
EndFunc   ;==>_MMUsolve
#EndRegion INTERFACE

#Region SUB_UDF
Func __MMU_optimus($references, $wsP, $workingSetS, ByRef $resoult)
	Local $o[1]
	For $instant = 0 To UBound($references) - 1
		___WorkingSetCalcule($references, $instant, $workingSetS, $wsP, $resoult, $o)

		If Not ___obiousSolution($resoult, $instant, $references) Then
			$resoult[___FindOptimusReplacement($resoult, $instant, $references)][$instant] = $references[$instant]
			$resoult[0][$instant] = "**"
		EndIf
		___prepareNext($resoult, $instant)
	Next
EndFunc   ;==>__MMU_optimus
Func __MMU_FIFO($references, $wsP, $workingSetS, $inicialFifo, ByRef $resoult)
	If ___FIFOisfifo($inicialFifo) Then
		$fifo = $inicialFifo
	Else
		$fifo = ___FIFOcreate()
	EndIf

	Local $o[1]
	For $instant = 0 To UBound($references) - 1
		$o[0] = $fifo
		___WorkingSetCalcule($references, $instant, $workingSetS, $wsP, $resoult, $o)
		$fifo = $o[0]

		If Not ___isPresent($resoult, $instant, $references) Then
			If Not ___asignateFreeFrame($resoult, $instant, $references) Then
				$replacement = ___FindFifoReplacement($resoult, $instant, $fifo)
				$resoult[$replacement][$instant] = $references[$instant]
				$resoult[0][$instant] = "**"
			EndIf
			___FIFOadd($fifo, $references[$instant])
		EndIf
		___prepareNext($resoult, $instant)
	Next
EndFunc   ;==>__MMU_FIFO
Func __MMU_LRU($references, $wsP, $workingSetS, $inicialCounters, ByRef $resoult)
	If ___PTispt($inicialCounters) And ___PThasColum($inicialCounters, "Counter") Then
		$pageTable = $inicialCounters
	Else
		$pageTable = ___PTcreate()
		___PTaddColum($pageTable, "Counter")
	EndIf

	$HWcounter = 1

	Local $o[1]
	For $instant = 0 To UBound($references) - 1
		$o[0] = $pageTable
		___WorkingSetCalcule($references, $instant, $workingSetS, $wsP, $resoult, $o)
		$pageTable = $o[0]

		If Not ___obiousSolution($resoult, $instant, $references) Then
			$replacement = ___FindCounterReplacement($resoult, $instant, $pageTable)
			$resoult[$replacement][$instant] = $references[$instant]
			$resoult[0][$instant] = "**"
		EndIf
		___PTsetValue($pageTable, "Counter", $references[$instant], $HWcounter)
		;____PTdesglose($pageTable)
		___prepareNext($resoult, $instant)
		$HWcounter += 1
	Next
EndFunc   ;==>__MMU_LRU
Func __MMU_NRU($references, $wsP, $wsResetsBR, $workingSetS, $moficications, $inicialPageTable, ByRef $resoult)
	If ___PTispt($inicialPageTable) And ___PThasColum($inicialPageTable, "R") And ___PThasColum($inicialPageTable, "M") Then
		$pageTable = $inicialPageTable
		If Not ___PThasColum($inicialPageTable, "Counter") Then
			___PTaddColum($pageTable, "Counter")
		EndIf
	Else
		$pageTable = ___PTcreate()
		___PTaddColum($pageTable, "R")
		___PTaddColum($pageTable, "M")
		___PTaddColum($pageTable, "Counter")
	EndIf
	$HWcounter = 1

	Local $o[1]
	For $instant = 0 To UBound($references) - 1
		$o[0] = $pageTable
		___WorkingSetCalcule($references, $instant, $workingSetS, $wsP, $resoult, $o)
		$pageTable = $o[0]

		If ___WorkingSetIsTime($instant, $workingSetS) And $wsResetsBR Then ___PTsetValue($pageTable, "R", "ALL", 0)
		If Not ___obiousSolution($resoult, $instant, $references) Then
			$replacement = ___FindRMCReplacement($resoult, $instant, $pageTable)
			___PTsetValue($pageTable, "R", $resoult[$replacement][$instant], 0)
			___PTsetValue($pageTable, "M", $resoult[$replacement][$instant], 0)
			$resoult[$replacement][$instant] = $references[$instant]
			$resoult[0][$instant] = "**"
		EndIf
		___PTsetValue($pageTable, "Counter", $references[$instant], $HWcounter)
		___PTsetValue($pageTable, "R", $references[$instant], 1)
		If $moficications[$instant] == 1 Then ___PTsetValue($pageTable, "M", $references[$instant], 1)
		___prepareNext($resoult, $instant)
		$HWcounter += 1
	Next
EndFunc   ;==>__MMU_NRU
Func __NMU_AGING($references, $wsP, $workingSetS, $bufferSize, $inicialBuffer, ByRef $resoult)
	If ___Bufferisbuffer($inicialBuffer, $bufferSize, UBound($resoult, 1) - 1) Then
		$buffer = $inicialBuffer
	Else
		$buffer = ___BufferCreate($bufferSize, UBound($resoult, 1) - 1)
	EndIf

	Local $o[1]
	For $instant = 0 To UBound($references) - 1
		$o[0] = $buffer
		___WorkingSetCalcule($references, $instant, $workingSetS, $wsP, $resoult, $o)
		$buffer = $o[0]

		$present = ___isPresent($resoult, $instant, $references)
		If $present Then
			___BufferUpdate($buffer, $present - 1)
		Else
			$free = ___asignateFreeFrame($resoult, $instant, $references)
			If $free Then
				___BufferUpdate($buffer, $free - 1)
			Else
				$replacement = ___FindBufferReplacement($resoult, $instant, $buffer)
				$resoult[$replacement][$instant] = $references[$instant]
				$resoult[0][$instant] = "**"
				___BufferUpdate($buffer, $replacement - 1)
			EndIf
		EndIf
		___prepareNext($resoult, $instant)
	Next
EndFunc   ;==>__NMU_AGING
Func __MMU_CLOCK($references, $wsP, $wsResetsBR, $workingSetS, $inicialPageTable, $inicialFifo, ByRef $resoult)
	If ___PTispt($inicialPageTable) And ___PThasColum($inicialPageTable, "R") Then
		$pageTable = $inicialPageTable
	Else
		$pageTable = ___PTcreate()
		___PTaddColum($pageTable, "R")
	EndIf
	If ___FIFOisfifo($inicialFifo) Then
		$fifo = $inicialFifo
	Else
		$fifo = ___FIFOcreate()
	EndIf

	Local $o[2]
	For $instant = 0 To UBound($references) - 1
		$o[0] = $pageTable
		$o[1] = $fifo
		___WorkingSetCalcule($references, $instant, $workingSetS, $wsP, $resoult, $o)
		$pageTable = $o[0]
		$fifo = $o[1]


		If ___WorkingSetIsTime($instant, $workingSetS) Then ___PTsetValue($pageTable, "R", "ALL", 0)
		If Not ___isPresent($resoult, $instant, $references) Then
			If Not ___asignateFreeFrame($resoult, $instant, $references) Then
				$replacement = ___FindClockReplacement($resoult, $instant, $pageTable, $fifo)
				$resoult[$replacement][$instant] = $references[$instant]
				$resoult[0][$instant] = "**"
			EndIf
			___FIFOadd($fifo, $references[$instant])
		EndIf
		___PTsetValue($pageTable, "R", $references[$instant], 1)
		___prepareNext($resoult, $instant)
	Next
EndFunc   ;==>__MMU_CLOCK
Func __MMU_XFU($references, $wsP, $workingSetS, $inicialCounters, ByRef $resoult, $LFUxMFU)
	If ___PTispt($inicialCounters) And ___PThasColum($inicialCounters, "Counter") Then
		$pageTable = $inicialCounters
		If Not ___PThasColum($pageTable, "Entrance") Then
			___PTaddColum($pageTable, "Entrance")
		EndIf
	Else
		$pageTable = ___PTcreate()
		___PTaddColum($pageTable, "Counter")
		___PTaddColum($pageTable, "Entrance")
	EndIf

	$HWcounter = 1
	Local $o[3]
	For $instant = 0 To UBound($references) - 1
		$o[0] = $pageTable
		$o[1] = $LFUxMFU
		$o[2] = $HWcounter
		___WorkingSetCalcule($references, $instant, $workingSetS, $wsP, $resoult, $o)
		$pageTable = $o[0]
		$LFUxMFU = $o[1]
		$HWcounter = $o[2]

		If Not ___isPresent($resoult, $instant, $references) Then
			$free = ___asignateFreeFrame($resoult, $instant, $references)
			If Not $free Then
				$replacement = ___FindXFUReplacement($resoult, $instant, $pageTable, $LFUxMFU)
				___PTsetValue($pageTable, "Counter", $resoult[$replacement][$instant], 0)
				$resoult[$replacement][$instant] = $references[$instant]
				$resoult[0][$instant] = "**"
				___PTsetValue($pageTable, "Entrance", $references[$instant], $HWcounter)
			EndIf
			___PTsetValue($pageTable, "Entrance", $references[$instant], $HWcounter)
		EndIf
		___PTsetValue($pageTable, "Counter", $references[$instant], ___PTgetValue($pageTable, "Counter", $references[$instant]) + 1)
		ConsoleWrite(___PTgetValue($pageTable, "Counter", $resoult[1][$instant]) & " " & ___PTgetValue($pageTable, "Counter", $resoult[2][$instant]) & " " & ___PTgetValue($pageTable, "Counter", $resoult[3][$instant]) & "    ")
		ConsoleWrite(___PTgetValue($pageTable, "Entrance", $resoult[1][$instant]) & " " & ___PTgetValue($pageTable, "Entrance", $resoult[2][$instant]) & " " & ___PTgetValue($pageTable, "Entrance", $resoult[3][$instant]) & @CRLF)
		___prepareNext($resoult, $instant)
		$HWcounter += 1
	Next
EndFunc   ;==>__MMU_XFU
Func __MMU_CLOCK_LINUX($references, $wsP, $wsResetsBR, $workingSetS, $inicialPageTable, $inicialFifo, ByRef $resoult)
	If ___PTispt($inicialPageTable) And ___PThasColum($inicialPageTable, "Chances") Then
		$pageTable = $inicialPageTable
	Else
		$pageTable = ___PTcreate()
		___PTaddColum($pageTable, "Chances")
	EndIf
	If ___FIFOisfifo($inicialFifo) Then
		$fifo = $inicialFifo
	Else
		$fifo = ___FIFOcreate()
	EndIf

	Local $o[2]
	For $instant = 0 To UBound($references) - 1
		$o[0] = $pageTable
		$o[1] = $fifo
		___WorkingSetCalcule($references, $instant, $workingSetS, $wsP, $resoult, $o)
		$pageTable = $o[0]
		$fifo = $o[1]

		If ___WorkingSetIsTime($instant, $workingSetS) Then ___PTsetValue($pageTable, "Chances", "ALL", 0)
		If Not ___isPresent($resoult, $instant, $references) Then
			If Not ___asignateFreeFrame($resoult, $instant, $references) Then
				$replacement = ___FindLinuxReplacement($resoult, $instant, $pageTable, $fifo)
				$resoult[$replacement][$instant] = $references[$instant]
				$resoult[0][$instant] = "**"
			EndIf
			___FIFOadd($fifo, $references[$instant])
		EndIf
		___PTsetValue($pageTable, "Chances", $references[$instant], ___PTgetValue($pageTable, "Chances", $references[$instant]) + 1)
		___prepareNext($resoult, $instant)
	Next
EndFunc   ;==>__MMU_CLOCK_LINUX

Func ___FindOptimusReplacement(ByRef $resoult, $instant, ByRef $references)
	$bestFrame = 0
	$bestScore = -1
	For $frame = 1 To UBound($resoult, 1)-1
		If Not ___FrameIsAvailable($resoult[$frame][$instant]) Then ContinueLoop

		$score = $instant + 1
		While $score < UBound($references) And $references[$score] <> $resoult[$frame][$instant]
			$score += 1
		WEnd
		;MsgBox(0, "Score: "&$resoult[$frame][$instant], $score)
		If $bestScore == -1 Or $score > $bestScore Then
			$bestFrame = $frame
			$bestScore = $score
		EndIf
	Next
	Return $bestFrame
EndFunc   ;==>___FindOptimusReplacement
Func ___FindFifoReplacement(ByRef $resoult, $instant, ByRef $fifo)
	While Not ___FIFOempty($fifo)
		$lastPage = ___FIFOremove($fifo)
		For $i = 1 To UBound($resoult, 1)-1
			If $resoult[$i][$instant] == $lastPage Then Return $i
		Next
	WEnd
	Return 1
EndFunc   ;==>___FindFifoReplacement
Func ___FindCounterReplacement(ByRef $resoult, $instant, ByRef $pageTable)
	$lowestPage = 0
	$lowestCounter = -1
	For $i = 1 To UBound($resoult, 1)-1
		If Not ___FrameIsAvailable($resoult[$i][$instant]) Then ContinueLoop

		$value = ___PTgetValue($pageTable, "Counter", $resoult[$i][$instant])
		If $lowestCounter == -1 Or $value < $lowestCounter Then
			$lowestCounter = $value
			$lowestPage = $i
		EndIf
	Next

	Return $lowestPage
EndFunc   ;==>___FindCounterReplacement
Func ___FindRMCReplacement(ByRef $resoult, $instant, ByRef $pageTable)
	$lowestFrame = 0
	$lowestCounter = -1
	$lowestBits = -1

	For $i = 1 To UBound($resoult, 1)-1
		If Not ___FrameIsAvailable($resoult[$i][$instant]) Then ContinueLoop

		$page = $resoult[$i][$instant]
		$value = ___PTgetValue($pageTable, "Counter", $page)
		$bits = ___PTgetValue($pageTable, "R", $page) * 2 + ___PTgetValue($pageTable, "M", $page)
		If $lowestCounter == -1 Or $bits < $lowestBits Or ($bits == $lowestBits And $value < $lowestCounter) Then
			$lowestCounter = $value
			$lowestBits = $bits
			$lowestFrame = $i
		EndIf
	Next
	;If $instant == 5 Then MsgBox(0, "Menor "&$lowestFrame, $lowestBits&"  "&$lowestCounter)
	Return $lowestFrame
EndFunc   ;==>___FindRMCReplacement
Func ___FindBufferReplacement(ByRef $resoult, $instant, ByRef $buffer)
	$lowestValue = -1
	$lowestFrame = 0

	For $i = 1 To UBound($resoult, 1)-1
		If Not ___FrameIsAvailable($resoult[$i][$instant]) Then ContinueLoop

		$value = ___BufferGetValue($buffer, $i - 1)
		If $lowestValue == -1 Or $value < $lowestValue Then
			$lowestValue = $value
			$lowestFrame = $i
		EndIf
	Next

	Return $lowestFrame
EndFunc   ;==>___FindBufferReplacement
Func ___FindClockReplacement(ByRef $resoult, $instant, ByRef $pageTable, ByRef $fifo)
	$bestPage = ""
	$i = 0

	While $bestPage == ""
		$page = ___FIFOget($fifo, $i)
		;TODO: Comprobar tambien se la pagina esta entre las presentes
		If ___PTgetValue($pageTable, "R", $page) == 0 Then
			$bestPage = $page
			___FIFOremove($fifo, $i)
		Else
			___PTsetValue($pageTable, "R", $page, 0)
			$i += 1
			If $i == ___FIFOsize($fifo) Then $i = 0
		EndIf
	WEnd

	For $i = 1 To UBound($resoult, 1)-1
		If $resoult[$i][$instant] == $bestPage Then Return $i
	Next
	Return 0
EndFunc   ;==>___FindClockReplacement
Func ___FindXFUReplacement(ByRef $resoult, $instant, ByRef $pageTable, $LFUxMFU)
	$bestFrame = 0
	$bestEntrance = 0
	$bestScore = -1

	For $i = 1 To UBound($resoult, 1)-1
		If Not ___FrameIsAvailable($resoult[$i][$instant]) Then ContinueLoop

		$score = ___PTgetValue($pageTable, "Counter", $resoult[$i][$instant])
		$entrance = ___PTgetValue($pageTable, "Entrance", $resoult[$i][$instant])
		If $bestScore == -1 Or (($score > $bestScore Or ($score == $bestScore And $entrance < $bestEntrance)) And $LFUxMFU == 0) Or (($score < $bestScore Or ($score == $bestScore And $entrance < $bestEntrance)) And $LFUxMFU == 1) Then
			;If $bestScore <> -1 Then MsgBox(0,"Gana",$score&" a "&$bestScore&@CRLF&$entrance&" a "&$bestEntrance&@CRLF&$i&" a "&$bestFrame&" en "&$instant)
			$bestScore = $score
			$bestEntrance = $entrance
			$bestFrame = $i
		EndIf
	Next

	Return $bestFrame
EndFunc   ;==>___FindXFUReplacement
Func ___FindLinuxReplacement(ByRef $resoult, $instant, ByRef $pageTable, ByRef $fifo)
	$bestPage = ""
	$i = 0

	While $bestPage == ""
		$page = ___FIFOget($fifo, $i)
		;TODO: Comprobar tambien se la pagina esta entre las presentes
		If ___PTgetValue($pageTable, "Chances", $page) == 0 Then
			$bestPage = $page
			___FIFOremove($fifo, $i)
		Else
			___PTsetValue($pageTable, "Chances", $page, ___PTgetValue($pageTable, "Chances", $page) - 1)
			$i += 1
			If $i == ___FIFOsize($fifo) Then $i = 0
		EndIf
	WEnd

	For $i = 1 To UBound($resoult, 1)-1
		If $resoult[$i][$instant] == $bestPage Then Return $i
	Next
	Return 0
EndFunc   ;==>___FindLinuxReplacement

Func ___obiousSolution(ByRef $resoult, $instant, $references)
	Return ___isPresent($resoult, $instant, $references) Or ___asignateFreeFrame($resoult, $instant, $references)
EndFunc   ;==>___obiousSolution
Func ___isPresent(ByRef $resoult, $instant, $references)
	For $i = 1 To UBound($resoult, 1)-1
		If $resoult[$i][$instant] == $references[$instant] Then Return $i
	Next
	Return False
EndFunc   ;==>___isPresent
Func ___asignateFreeFrame(ByRef $resoult, $instant, $references)
	For $i = 1 To UBound($resoult, 1)-1
		If $resoult[$i][$instant] == "NULL" Then
			$resoult[$i][$instant] = $references[$instant]
			$resoult[0][$instant] = "*"
			Return $i
		EndIf
	Next
	Return False
EndFunc   ;==>___asignateFreeFrame
Func ___prepareNext(ByRef $resoult, $instant)
	If $instant < UBound($resoult, 2) - 1 Then
		For $i = 1 To UBound($resoult, 1) - 1
			$resoult[$i][$instant + 1] = $resoult[$i][$instant]
		Next
	EndIf
EndFunc   ;==>___prepareNext
Func ___FrameIsAvailable($frame)
	If $frame == "BLOCK" Then
		Return False
	ElseIf $frame == "NULL" Then
		MsgBox(16, 0, "Error no controlado", "Se ha producido una situacion que no deberia ser posible."&@CRLF&"Se ha ejecutado un algoritmo de remplazo habiendo tramas libres")
	EndIf
	Return True
EndFunc

Func ___WorkingSetCalcule(ByRef $references, $instant, $S, $wsP, ByRef $resoult, ByRef $o)
	If Not ___WorkingSetIsTime($instant, $S) Then Return

	Local $pages[$S]
	$nFrames = 0; Los que debe tener
	For $i = $instant - 1 To $instant - $S Step -1
		$found = False
		For $j = 0 To $nFrames - 1
			If $pages[$j] == $references[$i] Then $found = True
		Next
		If Not $found And $nFrames < $S Then
			$pages[$nFrames] = $references[$i]
			$nFrames += 1
		EndIf
	Next

	$aFrames = 0; Los que tiene ahora
	For $i = 1 To UBound($resoult, 1)-1
		If $resoult[$i][$instant] <> "BLOCK" Then $aFrames += 1
	Next

	While $aFrames < $nFrames
		For $i = 1 To UBound($resoult, 1)-1
			If $resoult[$i][$instant] == "BLOCK" Then
				$aFrames += 1
				$resoult[$i][$instant] = "NULL"
				ExitLoop
			EndIf
		Next
	WEnd
	While $aFrames > $nFrames
		For $i = 1 To UBound($resoult, 1)-1
			If $resoult[$i][$instant] == "NULL" Then
				$aFrames -= 1
				$resoult[$i][$instant] = "BLOCK"
				ExitLoop(2)
			EndIf
		Next

		Switch($wsP)
			Case -2
				For $i = 1 To UBound($resoult, 1)-1
					If $resoult[$i][$instant] <> "BLOCK" Then
						$aFrames -= 1
						$resoult[$i][$instant] = "BLOCK"
						ExitLoop
					EndIf
				Next
			Case -3
				For $i = UBound($resoult, 1)-1 To 1 Step -1
					If $resoult[$i][$instant] <> "BLOCK" Then
						$aFrames -= 1
						$resoult[$i][$instant] = "BLOCK"
						ExitLoop
					EndIf
				Next
			Case Else
				Switch($wsP)
					Case $SWAP_ALGORITHM_OPTIMUS
						$replacement = ___FindOptimusReplacement($resoult, $instant, $references)
					Case $SWAP_ALGORITHM_FIFO
						$replacement = ___FindFifoReplacement($resoult, $instant, $o[0])
					Case $SWAP_ALGORITHM_LRU
						$replacement = ___FindCounterReplacement($resoult, $instant, $o[0])
					Case $SWAP_ALGORITHM_NRU
						$replacement = ___FindRMCReplacement($resoult, $instant, $o[0])
						___PTsetValue($o[0], "R", $resoult[$replacement][$instant], 0)
						___PTsetValue($o[0], "M", $resoult[$replacement][$instant], 0)
					Case $SWAP_ALGORITHM_AGING
						$replacement = ___FindBufferReplacement($resoult, $instant, $o[0])
						___BufferUpdate($o[0], $replacement - 1)
					Case $SWAP_ALGORITHM_CLOCK
						$replacement = ___FindClockReplacement($resoult, $instant, $o[0], $o[1])
					Case $SWAP_ALGORITHM_LFU, $SWAP_ALGORITHM_MFU
						$replacement = ___FindXFUReplacement($resoult, $instant, $o[0], $o[1])
						___PTsetValue($o[0], "Counter", $resoult[$replacement][$instant], 0)
						___PTsetValue($o[0], "Entrance", $references[$instant], $o[2])
					Case $SWAP_ALGORITHM_CLOCK_LINUX
						$replacement = ___FindLinuxReplacement($resoult, $instant, $o[0], $o[1])
				EndSwitch
				$resoult[$replacement][$instant] = "BLOCK"
				$aFrames -= 1
		EndSwitch
	WEnd
EndFunc   ;==>___WorkingSetCalcule
Func ___WorkingSetIsTime($instant, $S)
	Return $S <> 0 And $instant <> 0 And Mod($instant, $S) == 0
EndFunc   ;==>___WorkingSetIsTime

Func ___PTcreate()
	Dim $table[1]

	Dim $header[2] = [0, 0]
	$table[0] = $header

	Return $table
EndFunc   ;==>___PTcreate
Func ___PTaddColum(ByRef $table, $name)
	$header = $table[0]
	$nCols = $header[1] + 1
	$nPages = $header[0]
	ReDim $header[$nCols + 2]
	$header[1] = $nCols
	$header[$nCols + 1] = $name
	$table[0] = $header

	For $i = 1 To $nPages
		$row = $table[$i]
		ReDim $row[$nCols + 1]
		$row[$nCols] = ""
		$table[$i] = $row
	Next
EndFunc   ;==>___PTaddColum
Func ___PTaddPage(ByRef $table, $name)
	$header = $table[0]
	$nCols = $header[1]
	$nPages = $header[0] + 1
	$header[0] = $nPages
	$table[0] = $header
	ReDim $table[$nPages + 1]

	Dim $row[$nCols + 1]
	$row[0] = $name
	$table[$nPages] = $row
EndFunc   ;==>___PTaddPage
Func ___PTgetValue(ByRef $table, $colum, $page)
	$header = $table[0]
	$nPages = $header[0]
	$nCols = $header[1]

	$iCol = -1
	For $i = 2 To $nCols + 1
		If $header[$i] == $colum Then $iCol = $i - 1
	Next
	If $iCol == -1 Then Return 0

	For $i = 1 To $nPages
		$row = $table[$i]
		If $row[0] == $page Then Return $row[$iCol]
	Next

	Return 0
EndFunc   ;==>___PTgetValue
Func ___PTsetValue(ByRef $table, $colum, $page, $value)
	If Not ___PTexist($table, $page) Then ___PTaddPage($table, $page)

	$header = $table[0]
	$nPages = $header[0]
	$nCols = $header[1]

	$iCol = -1
	For $i = 2 To $nCols + 1
		If $header[$i] == $colum Then $iCol = $i - 1
	Next
	If $iCol == -1 Then Return False

	For $i = 1 To $nPages
		$row = $table[$i]
		If $page == "ALL" Or $row[0] == $page Then
			$row[$iCol] = $value
			$table[$i] = $row
		EndIf
	Next

	Return True
EndFunc   ;==>___PTsetValue
Func ___PTexist(ByRef $table, $page)
	$header = $table[0]
	$nPages = $header[0]

	For $i = 1 To $nPages
		$row = $table[$i]
		If $row[0] == $page Then Return True
	Next

	Return False
EndFunc   ;==>___PTexist
Func ___PTispt(ByRef $table)
	If Not IsArray($table) Then Return False
	$header = $table[0]
	If Not IsArray($header) Then Return False
	If $header[0] <> UBound($table) - 1 Then Return False
	If $header[1] <> UBound($header) - 2 Then Return False
	For $i = 1 To $header[0]
		$row = $table[$i]
		If Not IsArray($row) Then Return False
		If UBound($row) <> $header[1] + 1 Then Return False
	Next
	Return True
EndFunc   ;==>___PTispt
Func ___PThasColum(ByRef $table, $name)
	$header = $table[0]
	For $i = 2 To $header[1] + 1
		If $header[$i] == $name Then Return True
	Next
	Return False
EndFunc   ;==>___PThasColum
Func ___PTgetValueI(ByRef $table, $colum, $n)
	$header = $table[0]
	$nPages = $header[0]
	$nCols = $header[1]

	$iCol = -1
	For $i = 2 To $nCols + 1
		If $header[$i] == $colum Then $iCol = $i - 1
	Next
	If $iCol == -1 Then Return 0

	$row = $table[$n+1]

	Return $row[$iCol]
EndFunc

Func ___FIFOcreate()
	Dim $fifo[1]

	$fifo[0] = 0

	Return $fifo
EndFunc   ;==>___FIFOcreate
Func ___FIFOadd(ByRef $fifo, $name)
	$size = $fifo[0] + 1
	$fifo[0] = $size
	ReDim $fifo[$size + 1]
	$fifo[$size] = $name
EndFunc   ;==>___FIFOadd
Func ___FIFOget(ByRef $fifo, $pos = 0)
	If $pos >= $fifo[0] Then Return ""
	Return $fifo[$pos + 1]
EndFunc   ;==>___FIFOget
Func ___FIFOremove(ByRef $fifo, $pos = 0)
	If $fifo[0] < 1 Then Return ""
	$value = $fifo[1]
	$size = $fifo[0]
	For $i = $pos + 2 To $size
		$fifo[$i - 1] = $fifo[$i]
	Next
	$size -= 1
	$fifo[0] = $size
	ReDim $fifo[$size + 1]
	Return $value
EndFunc   ;==>___FIFOremove
Func ___FIFOempty(ByRef $fifo)
	Return $fifo[0] == 0
EndFunc   ;==>___FIFOempty
Func ___FIFOisfifo(ByRef $fifo)
	Return IsArray($fifo) And $fifo[0] == UBound($fifo) - 1
EndFunc   ;==>___FIFOisfifo
Func ___FIFOsize(ByRef $fifo)
	Return $fifo[0]
EndFunc   ;==>___FIFOsize

Func ___BufferCreate($size, $channels)
	Dim $buffer[$channels][$size]
	For $i = 0 To $size - 1
		For $j = 0 To $channels - 1
			$buffer[$j][$i] = 0
		Next
	Next
	Return $buffer
EndFunc   ;==>___BufferCreate
Func ___BufferUpdate(ByRef $buffer, $channel)
	For $i = 0 To UBound($buffer, 2) - 2
		For $j = 0 To UBound($buffer, 1) - 1
			$buffer[$j][$i] = $buffer[$j][$i + 1]
		Next
	Next
	For $j = 0 To UBound($buffer, 1) - 1
		$buffer[$j][UBound($buffer, 2) - 1] = $j == $channel ? 1 : 0
	Next
EndFunc   ;==>___BufferUpdate
Func ___BufferGetValue(ByRef $buffer, $channel)
	$value = 0
	For $i = 0 To UBound($buffer, 2) - 1
		$value += $buffer[$channel][$i] * (2 ^ $i)
	Next
	Return $value
EndFunc   ;==>___BufferGetValue
Func ___Bufferisbuffer(ByRef $buffer, $size = 0, $channels = 0)
	If Not IsArray($buffer) Then Return False
	If $size <> 0 And UBound($buffer, 1) <> $channels Then Return False
	If $channels <> 0 And UBound($buffer, 2) <> $size Then Return False
	Return True
EndFunc   ;==>___Bufferisbuffer
#EndRegion SUB_UDF


#Region TESTS
Func ___Test_1()
	Local $references[] = [7, 0, 1, 2, 0, 3, 0, 4, 2, 3, 0, 3, 2, 1, 2, 0, 1, 7, 0, 1]
	Local $goodResoult[][] = [["*", "*", "*", "**", "", "**", "", "**", "", "", "**", "", "", "**", "", "", "", "**", "", ""], [7, 7, 7, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 7, 7, 7], ["NULL", 0, 0, 0, 0, 0, 0, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], ["NULL", "NULL", 1, 1, 1, 3, 3, 3, 3, 3, 3, 3, 3, 1, 1, 1, 1, 1, 1, 1]]
	;Local $inicializacion[][] = [["p1", "p2"]]
	$resoult = _MMUsolve($SWAP_ALGORITHM_OPTIMUS, $references, 3)
	If @error Then MsgBox(0, "Error", @error)
	;_ArrayDisplay($resoult)
	MsgBox(0, "Resultado Test 1", ____Compare($resoult, $goodResoult) ? "Correcto" : "Incorrecto")
EndFunc   ;==>___Test_1
Func ___Test_2()
	Local $references[] = [7, 0, 1, 2, 0, 3, 0, 4, 2, 3, 0, 3, 2, 1, 2, 0, 1, 7, 0, 1]
	Local $goodResoult[][] = [["*", "*", "*", "**", "", "**", "**", "**", "**", "**", "**", "", "", "**", "**", "", "", "**", "**", "**"], [7, 7, 7, 2, 2, 2, 2, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 7, 7, 7], ["NULL", 0, 0, 0, 0, 3, 3, 3, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 0, 0], ["NULL", "NULL", 1, 1, 1, 1, 0, 0, 0, 3, 3, 3, 3, 3, 2, 2, 2, 2, 2, 1]]
	;Local $iniPages = [1, "1"]
	;Local $inicializacion[] = [0, $iniPages]
	$resoult = _MMUsolve($SWAP_ALGORITHM_FIFO, $references, 3)
	If @error Then MsgBox(0, "Error", @error)
	;_ArrayDisplay($resoult)
	MsgBox(0, "Resultado Test 2", ____Compare($resoult, $goodResoult) ? "Correcto" : "Incorrecto")
EndFunc   ;==>___Test_2
Func ___Test_3()
	Local $references[] = [7, 0, 1, 2, 0, 3, 0, 4, 2, 3, 0, 3, 2, 1, 2, 0, 1, 7, 0, 1]
	Local $goodResoult[][] = [["*", "*", "*", "**", "", "**", "", "**", "**", "**", "**", "", "", "**", "", "**", "", "**", "", ""], [7, 7, 7, 2, 2, 2, 2, 4, 4, 4, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1], ["NULL", 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 3, 3, 3, 3, 0, 0, 0, 0, 0], ["NULL", "NULL", 1, 1, 1, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 7, 7, 7]]
	$table = ___PTcreate()
	;___PTaddColum($table, "Counter")
	;Local $inicializacion[] = [0, $table]
	$resoult = _MMUsolve($SWAP_ALGORITHM_LRU, $references, 3)
	If @error Then MsgBox(0, "Error", @error)
	_ArrayDisplay($resoult)
	MsgBox(0, "Resultado Test 3", ____Compare($resoult, $goodResoult) ? "Correcto" : "Incorrecto")
EndFunc   ;==>___Test_3
Func ___Test_4()
	Local $references[] = [7, 0, 1, 2, 0, 3, 0, 4, 2, 3, 0, 3, 2, 1, 2, 0, 1, 7, 0, 1]
	Local $modificati[] = [0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0]
	Local $goodResoult[][] = [["*", "*", "*", "**", "", "**", "", "**", "**", "**", "", "", "**", "**", "**", "", "**", "**", "", "**"], [7, 7, 7, 2, 2, 2, 2, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4], ["NULL", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], ["NULL", "NULL", 1, 1, 1, 3, 3, 3, 2, 3, 3, 3, 2, 1, 2, 2, 1, 7, 7, 1]]
	;_ArrayDisplay($goodResoult)
	Local $inicializacion[] = [0, 0, $modificati]
	$resoult = _MMUsolve($SWAP_ALGORITHM_NRU, $references, 3, False, 0, 0, $inicializacion)
	If @error Then MsgBox(0, "Error", @error)
	;_ArrayDisplay($resoult)
	MsgBox(0, "Resultado Test 4", ____Compare($resoult, $goodResoult) ? "Correcto" : "Incorrecto")
EndFunc   ;==>___Test_4
Func ___Test_5()
	Local $references[] = [7, 0, 1, 2, 0, 3, 0, 4, 2, 3, 0, 3, 2, 1, 2, 0, 1, 7, 0, 1]
	Local $goodResoult[][] = [["*", "*", "*", "**", "", "**", "", "**", "**", "**", "", "", "**", "**", "**", "", "**", "**", "", "**"], [7, 7, 7, 2, 2, 2, 2, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4], ["NULL", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], ["NULL", "NULL", 1, 1, 1, 3, 3, 3, 2, 3, 3, 3, 2, 1, 2, 2, 1, 7, 7, 1]]
	_ArrayDisplay($goodResoult)
	;TODO: Modificar el resultado correcto
	Local $initial[3] = [0, 3, 0]
	$resoult = _MMUsolve($SWAP_ALGORITHM_AGING, $references, 3, False, 0, 0, $initial)
	If @error Then MsgBox(0, "Error", @error)
	_ArrayDisplay($resoult)
	MsgBox(0, "Resultado Test 5", ____Compare($resoult, $goodResoult) ? "Correcto" : "Incorrecto")
EndFunc   ;==>___Test_5
Func ___Test_6()
	Local $references[] = [7, 0, 1, 2, 0, 3, 0, 4, 2, 3, 0, 3, 2, 1, 2, 0, 1, 7, 0, 1]
	Local $goodResoult[][] = [["*", "*", "*", "**", "", "**", "", "**", "**", "**", "", "", "**", "**", "**", "", "**", "**", "", "**"], [7, 7, 7, 2, 2, 2, 2, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4], ["NULL", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], ["NULL", "NULL", 1, 1, 1, 3, 3, 3, 2, 3, 3, 3, 2, 1, 2, 2, 1, 7, 7, 1]]
	;_ArrayDisplay($goodResoult)
	$resoult = _MMUsolve($SWAP_ALGORITHM_CLOCK, $references, 3)
	If @error Then MsgBox(0, "Error", @error)
	;_ArrayDisplay($resoult)
	MsgBox(0, "Resultado Test 6", ____Compare($resoult, $goodResoult) ? "Correcto" : "Incorrecto")
EndFunc   ;==>___Test_6
Func ___Test_7()
	Local $references[] = [7, 0, 1, 2, 0, 3, 0, 4, 2, 3, 0, 3, 2, 1, 2, 0, 1, 7, 0, 1]
	Local $goodResoult[][] = [["*", "*", "*", "**", "", "**", "", "**", "**", "**", "", "", "", "**", "", "", "", "**", "", ""], [7, 7, 7, 2, 2, 2, 2, 4, 4, 3, 3, 3, 3, 1, 1, 1, 1, 7, 7, 1], ["NULL", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], ["NULL", "NULL", 1, 1, 1, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]]
	;Se conoce que hay un error en los apuntes
	;_ArrayDisplay($goodResoult)
	$resoult = _MMUsolve($SWAP_ALGORITHM_LFU, $references, 3)
	If @error Then MsgBox(0, "Error", @error)
	;_ArrayDisplay($resoult)
	MsgBox(0, "Resultado Test 7", ____Compare($resoult, $goodResoult) ? "Correcto" : "Incorrecto")
EndFunc   ;==>___Test_7
Func ___Test_8()
	Local $references[] = [7, 0, 1, 2, 0, 3, 0, 4, 2, 3, 0, 3, 2, 1, 2, 0, 1, 7, 0, 1]
	Local $goodResoult[][] = [["*", "*", "*", "**", "", "**", "", "**", "**", "**", "", "", "", "**", "", "", "", "**", "", ""], [7, 7, 7, 2, 2, 2, 2, 4, 4, 3, 3, 3, 3, 1, 1, 1, 1, 7, 7, 1], ["NULL", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], ["NULL", "NULL", 1, 1, 1, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]]
	;_ArrayDisplay($goodResoult)
	$resoult = _MMUsolve($SWAP_ALGORITHM_CLOCK_LINUX, $references, 3)
	If @error Then MsgBox(0, "Error", @error)
	;_ArrayDisplay($resoult)
	MsgBox(0, "Resultado Test 7", ____Compare($resoult, $goodResoult) ? "Correcto" : "Incorrecto")
EndFunc   ;==>___Test_8

Func ____Bufferdump($b)
	If Not ___Bufferisbuffer($b) Then MsgBox(0, "Error", "No es un buffer")
	Local $tmp[UBound($b, 1)][UBound($b, 2)]
	For $i = 0 To UBound($b, 1)-1
		For $j = 0 To UBound($b, 2)-1
			$tmp[$i][$j] = $b[$i][UBound($b, 2)-$j-1]
		Next
	Next
	_ArrayDisplay($tmp)
EndFunc
Func ____FIFOdump($f)
	If Not ___FIFOisfifo($f) Then MsgBox(0, "Error", "No es una FIFO")
	Local $tmp[UBound($f)-1]
	For $i = 1 To $f[0]
		$tmp[$i-1] = $f[$i]
	Next
	_ArrayDisplay($tmp)
EndFunc
Func ____PTdump($t)
	If Not ___PTispt($t) Then MsgBox(0, "Error", "No es una Tabla de Paginas")
	$header = $t[0]
	$nFil = $header[0]
	$nCol = $header[1]
	Local $a[$nFil + 1][$nCol + 1]
	$a[0][0] = "Elementos"
	For $i = 1 To $nCol
		$a[0][$i] = $header[$i + 1]
	Next
	For $i = 1 To $nFil
		$row = $t[$i]
		For $j = 0 To $nCol
			$a[$i][$j] = $row[$j]
		Next
	Next
	_ArrayDisplay($a)
EndFunc   ;==>____PTdesglose
Func ____Compare($res1, $res2)
	If UBound($res1, 1) <> UBound($res2, 1) Or UBound($res1, 2) <> UBound($res2, 2) Then Return False
	For $i = 0 To UBound($res1) - 1
		For $j = 0 To UBound($res1, 2) - 1
			If $res1[$i][$j] <> $res2[$i][$j] Then Return False
		Next
	Next
	Return True
EndFunc   ;==>____Compare
#EndRegion TESTS
