#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\Downloads\Dryicons-Aesthetica-2-Page-swap.ico
#AutoIt3Wrapper_Outfile=..\AutoMMU.exe
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.15.0 (Beta)
 Author:         Borja Live

 Script Function:
	Simulador de algoritmos de remplazo con interfaz grafica

#ce ----------------------------------------------------------------------------
#EndRegion

#include <Array.au3>
#include <ColorConstants.au3>
#include <GUIConstantsEx.au3>
#include <GUIConstants.au3>
#include <EditConstants.au3>
#include <GuiEdit.au3>
#include <WindowsConstants.au3>
#include "MMU.au3"

#Region GUI
#Region MAIN
$GUI_main = GUICreate("AutoMMU", 400, 520)

GUISetFont(14)

$main_menu_file = GUICtrlCreateMenu("Archivo")
$main_menu_help = GUICtrlCreateMenu("Ayuda")
$main_menu_load = GUICtrlCreateMenuItem('Abrir', $main_menu_file)
$main_menu_save = GUICtrlCreateMenuItem('Guardar', $main_menu_file)
$main_menu_clear = GUICtrlCreateMenuItem('Reiniciar', $main_menu_file)
$main_menu_exit = GUICtrlCreateMenuItem('Salir', $main_menu_file)
$main_menu_help = GUICtrlCreateMenuItem('Manual', $main_menu_help)
$main_menu_credicts = GUICtrlCreateMenuItem('Creditos', $main_menu_help)

GUICtrlCreateLabel("Algoritmo de remplazo:", 10,12)
$main_combo_algorith = GUICtrlCreateCombo("", 240, 10, 150, 20)
GUICtrlSetData($main_combo_algorith, "Optimo|FIFO|LRU|NRU|Aging|Reloj|LFU|MFU|Reloj Linux", "Optimo")

$main_check_ws = GUICtrlCreateCheckbox("Working Set", 15, 67)
GUICtrlCreateLabel("S:", 150,70)
$main_input_wss = GUICtrlCreateInput("0", 180, 68, 50)
GUICtrlCreateUpdown($main_input_wss)
GUICtrlCreateLabel("Iniciales:", 250,70)
$main_input_iniT = GUICtrlCreateInput("0", 330, 68, 50)
GUICtrlCreateUpdown($main_input_iniT)

GUICtrlCreateGroup("Opciones extra", 15, 120, 370, 80)

$main_label_bufferSize = GUICtrlCreateLabel("Tamaño del buffer: ", 50, 155)
$main_input_bufferSize = GUICtrlCreateInput("0", 220, 152, 50)
$main_updown_bufferSize = GUICtrlCreateUpdown($main_input_bufferSize)
GUICtrlSetState($main_input_bufferSize, $GUI_HIDE)
GUICtrlSetState($main_label_bufferSize, $GUI_HIDE)
GUICtrlSetState($main_updown_bufferSize, $GUI_HIDE)
$main_label_noMoreConfig = GUICtrlCreateLabel("No se requiere configuracion adicional", 50, 155)
GUICtrlSetColor($main_label_noMoreConfig, $COLOR_GRAY)

GUICtrlCreateGroup("Datos iniciales", 15, 220, 370, 150)
$main_label_inicialFifo = GUICtrlCreateLabel("FIFO:", 30, 255)
$main_label_inicialBuffer = GUICtrlCreateLabel("Buffer:", 30, 290)
$main_label_inicialPT = GUICtrlCreateLabel("Tabla de paginas:", 30, 325)
$main_button_inicialFifo = GUICtrlCreateButton("Iniciar", 200, 252, 80)
$main_button_inicialBuffer = GUICtrlCreateButton("Iniciar", 200, 287, 80)
$main_button_inicialPT = GUICtrlCreateButton("Iniciar", 200, 322, 80)
$main_label_iniciatedFifo = GUICtrlCreateLabel("Sin datos", 290, 255)
$main_label_iniciatedBuffer = GUICtrlCreateLabel("Sin datos", 290, 290)
$main_label_iniciatedPT = GUICtrlCreateLabel("Sin datos", 290, 325)
GUICtrlSetState($main_label_inicialFifo, $GUI_HIDE)
GUICtrlSetState($main_label_inicialBuffer, $GUI_HIDE)
GUICtrlSetState($main_label_inicialPT, $GUI_HIDE)
GUICtrlSetState($main_button_inicialFifo, $GUI_HIDE)
GUICtrlSetState($main_button_inicialBuffer, $GUI_HIDE)
GUICtrlSetState($main_button_inicialPT, $GUI_HIDE)
GUICtrlSetState($main_label_iniciatedFifo, $GUI_HIDE)
GUICtrlSetState($main_label_iniciatedBuffer, $GUI_HIDE)
GUICtrlSetState($main_label_iniciatedPT, $GUI_HIDE)
$main_label_noInicialization = GUICtrlCreateLabel("Nada que inicializar", 120, 290)
GUICtrlSetColor($main_label_noInicialization, $COLOR_GRAY)

$main_button_references = GUICtrlCreateButton("Introducir Referencias", 20, 385, 200)
$main_button_preasignation = GUICtrlCreateButton("Preasignacion", 240, 385, 140)

$main_button_run = GUICtrlCreateButton("Ejecutar", 50, 435, 300, 50)
GUICtrlSetFont($main_button_run, 20)

Opt("GUIOnEventMode", True)

GUICtrlSetOnEvent($main_button_run, "event_run")
GUICtrlSetOnEvent($main_menu_exit, "event_exit")
GUICtrlSetOnEvent($main_menu_clear, "event_clear")
GUICtrlSetOnEvent($main_menu_save, "event_save")
GUICtrlSetOnEvent($main_menu_load, "event_load")
GUICtrlSetOnEvent($main_menu_help, "event_help")
GUICtrlSetOnEvent($main_menu_credicts, "event_credicts")

GUICtrlSetOnEvent($main_button_inicialFifo, "event_show_fifo")
GUICtrlSetOnEvent($main_button_inicialBuffer, "event_show_buffer")
GUICtrlSetOnEvent($main_button_inicialPT, "event_show_pt")
GUICtrlSetOnEvent($main_button_references, "event_show_references")
GUICtrlSetOnEvent($main_button_preasignation, "event_show_preasignation")

GUICtrlSetOnEvent($main_combo_algorith, "event_change_algorithm")
GUISetOnEvent($GUI_EVENT_CLOSE, "event_exit")

GUISetState(@SW_SHOW, $GUI_main)
#EndRegion
#Region REFERENCES
$GUI_references = GUICreate("", 150, 520)

GUISetFont(14)

GUICtrlCreateLabel("Referencias", 25, 10)
$references_edit_references = GUICtrlCreateEdit("", 10, 40, 130, 410, BitOR($ES_WANTRETURN,$WS_VSCROLL))
$references_button_save = GUICtrlCreateButton("Guardar", 15, 470, 120)

GUICtrlSetOnEvent($references_button_save, "event_save_references")
GUISetOnEvent($GUI_EVENT_CLOSE, "close_references")

GUISetState(@SW_HIDE, $GUI_references)
#EndRegion
#Region FIFO
$GUI_fifo = GUICreate("", 150, 350)

GUISetFont(14)

GUICtrlCreateLabel("FIFO", 50, 10)
$fifo_edit_fifo = GUICtrlCreateEdit("", 10, 40, 130, 250, $ES_WANTRETURN)
$fifo_button_save = GUICtrlCreateButton("Guardar", 15, 305, 120)

GUICtrlSetOnEvent($fifo_button_save, "event_save_fifo")
GUISetOnEvent($GUI_EVENT_CLOSE, "close_fifo")

GUISetState(@SW_HIDE, $GUI_fifo)
#EndRegion
#Region BUFFER
$GUI_buffer = GUICreate("", 300, 250)

GUISetFont(14)

GUICtrlCreateLabel("Buffer", 125, 10)
$buffer_edit_buffer = GUICtrlCreateEdit("", 10, 40, 280, 160, $ES_WANTRETURN)
$buffer_button_save = GUICtrlCreateButton("Guardar", 95, 210, 120)

GUICtrlSetOnEvent($buffer_button_save, "event_save_buffer")
GUISetOnEvent($GUI_EVENT_CLOSE, "close_buffer")

GUISetState(@SW_HIDE, $GUI_buffer)
#EndRegion
#Region PT
$GUI_pt = GUICreate("", 340, 520)

GUISetFont(14)

GUICtrlCreateLabel("Pagina", 22, 50)
$pt_check_acBr = GUICtrlCreateCheckbox("BR", 110, 47)
$pt_check_acBm = GUICtrlCreateCheckbox("BM", 170, 47)
$pt_check_acCount = GUICtrlCreateCheckbox("Contador", 230, 47)

Dim $pt_input_pag[10]
Dim $pt_check_br[10]
Dim $pt_check_bm[10]
Dim $pt_input_cont[10]

For $i = 0 To 9
	$pt_input_pag[$i] = GUICtrlCreateInput("",10,85+(38*$i),80,25)
	$pt_check_br[$i] = GUICtrlCreateCheckbox(" ", 125, 82+(38*$i))
	$pt_check_bm[$i] = GUICtrlCreateCheckbox(" ", 195, 82+(38*$i))
	$pt_input_cont[$i] = GUICtrlCreateInput("",237,85+(38*$i),80,25)
Next

GUICtrlCreateLabel("Tabla de paginas", 100, 10)
$pt_button_save = GUICtrlCreateButton("Guardar", 108, 475, 120)

GUICtrlSetOnEvent($pt_button_save, "event_save_pt")
GUISetOnEvent($GUI_EVENT_CLOSE, "close_pt")

GUISetState(@SW_HIDE, $GUI_pt)
#EndRegion
#Region PREASIGNATION
$GUI_preasignation = GUICreate("", 150, 350)

GUISetFont(14)

GUICtrlCreateLabel("Preasignacion", 15, 10)
$preasignation_edit_preasignations = GUICtrlCreateEdit("", 10, 40, 130, 250, $ES_WANTRETURN)
$preasignation_button_save = GUICtrlCreateButton("Guardar", 15, 305, 120)

GUICtrlSetOnEvent($preasignation_button_save, "event_save_preasignation")
GUISetOnEvent($GUI_EVENT_CLOSE, "close_preasignation")

GUISetState(@SW_HIDE, $GUI_preasignation)
#EndRegion
#EndRegion

#Region DATA
$SELECTED_ALGORITHM = $SWAP_ALGORITHM_OPTIMUS
$OPEN_WINDOW = 0

Global $FIFO = 0
Global $BUFFER = 0
Global $PAGETABLE = 0
Global $REFERENCES = 0
Global $MODIFICATIONS = 0
Global $PREASIGNATIONS = 0
#EndRegion

While 1
	Sleep(10)
WEnd

GUIDelete($GUI_main)

#Region EVENTS
Func event_change_algorithm()
	Switch(GUICtrlRead($main_combo_algorith))
		Case "Optimo"
			$SELECTED_ALGORITHM = $SWAP_ALGORITHM_OPTIMUS
		Case "FIFO"
			$SELECTED_ALGORITHM = $SWAP_ALGORITHM_FIFO
		Case "LRU"
			$SELECTED_ALGORITHM = $SWAP_ALGORITHM_LRU
		Case "NRU"
			$SELECTED_ALGORITHM = $SWAP_ALGORITHM_NRU
		Case "Aging"
			$SELECTED_ALGORITHM = $SWAP_ALGORITHM_AGING
		Case "Reloj"
			$SELECTED_ALGORITHM = $SWAP_ALGORITHM_CLOCK
		Case "LFU"
			$SELECTED_ALGORITHM = $SWAP_ALGORITHM_LFU
		Case "MFU"
			$SELECTED_ALGORITHM = $SWAP_ALGORITHM_MFU
		Case "Reloj Linux"
			$SELECTED_ALGORITHM = $SWAP_ALGORITHM_CLOCK_LINUX
		Case Else
			$SELECTED_ALGORITHM = $SWAP_ALGORITHM_OPTIMUS
	EndSwitch

	If $SELECTED_ALGORITHM == $SWAP_ALGORITHM_AGING Then
		GUICtrlSetState($main_input_bufferSize, $GUI_SHOW)
		GUICtrlSetState($main_label_bufferSize, $GUI_SHOW)
		GUICtrlSetState($main_updown_bufferSize, $GUI_SHOW)
		GUICtrlSetState($main_label_noMoreConfig, $GUI_HIDE)
	Else
		GUICtrlSetState($main_input_bufferSize, $GUI_HIDE)
		GUICtrlSetState($main_label_bufferSize, $GUI_HIDE)
		GUICtrlSetState($main_updown_bufferSize, $GUI_HIDE)
		GUICtrlSetState($main_label_noMoreConfig, $GUI_SHOW)
	EndIf

	If $SELECTED_ALGORITHM == $SWAP_ALGORITHM_FIFO Or $SELECTED_ALGORITHM == $SWAP_ALGORITHM_CLOCK Or $SELECTED_ALGORITHM == $SWAP_ALGORITHM_CLOCK_LINUX Then
		GUICtrlSetState($main_label_inicialFifo, $GUI_SHOW)
		GUICtrlSetState($main_button_inicialFifo, $GUI_SHOW)
		GUICtrlSetState($main_label_iniciatedFifo, $GUI_SHOW)

	Else
		GUICtrlSetState($main_label_inicialFifo, $GUI_HIDE)
		GUICtrlSetState($main_button_inicialFifo, $GUI_HIDE)
		GUICtrlSetState($main_label_iniciatedFifo, $GUI_HIDE)
	EndIf

	If $SELECTED_ALGORITHM == $SWAP_ALGORITHM_LRU Or $SELECTED_ALGORITHM == $SWAP_ALGORITHM_NRU Or $SELECTED_ALGORITHM == $SWAP_ALGORITHM_CLOCK Or $SELECTED_ALGORITHM == $SWAP_ALGORITHM_LFU Or $SELECTED_ALGORITHM == $SWAP_ALGORITHM_MFU Or $SELECTED_ALGORITHM == $SWAP_ALGORITHM_CLOCK_LINUX Then
		GUICtrlSetState($main_label_inicialPT, $GUI_SHOW)
		GUICtrlSetState($main_button_inicialPT, $GUI_SHOW)
		GUICtrlSetState($main_label_iniciatedPT, $GUI_SHOW)
	Else
		GUICtrlSetState($main_label_inicialPT, $GUI_HIDE)
		GUICtrlSetState($main_button_inicialPT, $GUI_HIDE)
		GUICtrlSetState($main_label_iniciatedPT, $GUI_HIDE)
	EndIf

	If $SELECTED_ALGORITHM == $SWAP_ALGORITHM_AGING Then
		GUICtrlSetState($main_label_inicialBuffer, $GUI_SHOW)
		GUICtrlSetState($main_button_inicialBuffer, $GUI_SHOW)
		GUICtrlSetState($main_label_iniciatedBuffer, $GUI_SHOW)

	Else
		GUICtrlSetState($main_label_inicialBuffer, $GUI_HIDE)
		GUICtrlSetState($main_button_inicialBuffer, $GUI_HIDE)
		GUICtrlSetState($main_label_iniciatedBuffer, $GUI_HIDE)
	EndIf

	If $SELECTED_ALGORITHM == $SWAP_ALGORITHM_OPTIMUS Then
		GUICtrlSetState($main_label_noInicialization, $GUI_SHOW)
	Else
		GUICtrlSetState($main_label_noInicialization, $GUI_HIDE)
	EndIf
EndFunc

Func event_run()
	Local $inicialization[1]
	$inicialization[0] = $PREASIGNATIONS

	Switch($SELECTED_ALGORITHM)
		Case $SWAP_ALGORITHM_OPTIMUS
		Case $SWAP_ALGORITHM_FIFO
			ReDim $inicialization[2]
			$inicialization[1] = $FIFO
		Case $SWAP_ALGORITHM_LRU
			ReDim $inicialization[2]
			$inicialization[1] = $PAGETABLE
		Case $SWAP_ALGORITHM_NRU
			ReDim $inicialization[3]
			$inicialization[1] = $PAGETABLE
			$inicialization[2] = $MODIFICATIONS
		Case $SWAP_ALGORITHM_AGING
			ReDim $inicialization[3]
			$inicialization[1] = GUICtrlRead($main_input_bufferSize)
			$inicialization[2] = $BUFFER
		Case $SWAP_ALGORITHM_CLOCK, $SWAP_ALGORITHM_CLOCK_LINUX
			ReDim $inicialization[3]
			$inicialization[1] = $PAGETABLE
			$inicialization[2] = $FIFO
		Case $SWAP_ALGORITHM_LFU, $SWAP_ALGORITHM_MFU
			ReDim $inicialization[2]
			$inicialization[1] = $PAGETABLE
	EndSwitch

	$resoult = _MMUsolve($SELECTED_ALGORITHM, $REFERENCES, GUICtrlRead($main_input_iniT), GUICtrlRead($main_check_ws)==$GUI_CHECKED, GUICtrlRead($main_input_wss), $inicialization)
	If @error Then
		MsgBox(16, "Error", "Codigo de error: "&@error&@CRLF&"Informacion extendida: "&@extended&@CRLF&"Esto es una alpha, acostumbrate.")
		Return
	EndIf
	;_ArrayDisplay($resoult)

	$width = UBound($resoult, 2)
	$height = UBound($resoult, 1)-1
	$nF = 0
	$nNF = 0
	$nR = 0
	Global $GUI_resoult = GUICreate("AutoMMU Resultado", 40+$width*45, 150+($height-1)*25)
	GUISetBkColor(0xFFFFFF, $GUI_resoult)
	For $frame = 1 To UBound($resoult, 1)-1
		For $instant = 0 To UBound($resoult, 2)-1
			If $resoult[$frame][$instant]=="NULL" Then $resoult[$frame][$instant] = ""
			GUICtrlCreateInput($resoult[$frame][$instant], 20+$instant*45, 35+($frame-1)*25, 40, 20, BitOR($ES_READONLY, $ES_CENTER))
			If $instant > 0 And $resoult[$frame][$instant-1] <> $resoult[$frame][$instant] Then GUICtrlSetColor(-1, 0xFF0000)
			GUICtrlSetFont(-1,9,550)
		Next
	Next
	For $instant = 0 To UBound($REFERENCES)-1
		GUICtrlCreateInput($REFERENCES[$instant], 20+$instant*45, 40+($height)*25, 40, 20, BitOR($ES_READONLY, $ES_CENTER))
		GUICtrlSetBkColor(-1, 0xFFFFFF)
		If $MODIFICATIONS[$instant] == 1 Then GUICtrlSetFont(-1, 8, 600)
	Next
	For $instant = 0 To UBound($resoult, 2)-1
		If $resoult[0][$instant] == "" Then
			$nNF += 1
		ElseIf $resoult[0][$instant] == "*" Then
			$nF += 1
		ElseIf $resoult[0][$instant] == "**" Then
			$nF += 1
			$nR += 1
		EndIf
		GUICtrlCreateInput($resoult[0][$instant], 20+$instant*45, 10, 40, 20, BitOR($ES_READONLY, $ES_CENTER))
		GUICtrlSetColor(-1, 0xFF0000)
		GUICtrlSetFont(-1, 12, 600)
		GUICtrlSetBkColor(-1, 0xFFFFFF)
	Next

	GUICtrlCreateLabel("Numero de no fallos: "&$nNF&"  Numeo de fallos: "&$nF&" Numero de remplazos: "&$nR, 20, 70+($height)*25, $width*45)
	GUICtrlSetFont(-1, 10)

	GUISetOnEvent($GUI_EVENT_CLOSE, "event_closeResoult")
	GUISetState(@SW_SHOW, $GUI_resoult)
	GUISetState(@SW_HIDE, $GUI_main)

EndFunc
Func event_save()
	$file = FileOpen(FileSaveDialog("Selecciona un lugar para guardar el archivo.", @DesktopDir, "AutoMMU (*.mmu)"), 2)

	FileWrite($file, _FIFO2Text($FIFO)&@CRLF)
	FileWrite($file, _Buffer2Text($BUFFER)&@CRLF)
	FileWrite($file, _PT2Text($PAGETABLE)&@CRLF)
	FileWrite($file, _Array2Text($REFERENCES)&@CRLF)
	FileWrite($file, _Array2Text($MODIFICATIONS)&@CRLF)
	FileWrite($file, _Array2Text($PREASIGNATIONS)&@CRLF)
	FileWrite($file, $SELECTED_ALGORITHM&@CRLF)
	FileWrite($file, (GUICtrlRead($main_check_ws)==$GUI_CHECKED?1:0)&@CRLF)
	FileWrite($file, GUICtrlRead($main_input_wss)&@CRLF)
	FileWrite($file, GUICtrlRead($main_input_iniT)&@CRLF)
	FileWrite($file, GUICtrlRead($main_input_bufferSize))

	FileClose($file)
EndFunc
Func event_load()
	$file = FileOpen(FileOpenDialog("Selecciona un lugar para guardar el archivo.", @DesktopDir, "AutoMMU (*.mmu)"), 0)

	$FIFO = _Text2FIFO(FileReadLine($file))
	$BUFFER = _Text2Buffer(FileReadLine($file))
	$PAGETABLE = _Text2PT(FileReadLine($file))
	$REFERENCES = _Text2Array(FileReadLine($file))
	$MODIFICATIONS = _Text2Array(FileReadLine($file))
	$PREASIGNATIONS = _Text2Array(FileReadLine($file))

	$SELECTED_ALGORITHM = FileReadLine($file)
	Switch($SELECTED_ALGORITHM)
		Case $SWAP_ALGORITHM_OPTIMUS
			GUICtrlSetData($main_combo_algorith, "Optimo")
		Case $SWAP_ALGORITHM_FIFO
			GUICtrlSetData($main_combo_algorith, "FIFO")
		Case $SWAP_ALGORITHM_LRU
			GUICtrlSetData($main_combo_algorith, "LRU")
		Case $SWAP_ALGORITHM_NRU
			GUICtrlSetData($main_combo_algorith, "NRU")
		Case $SWAP_ALGORITHM_AGING
			GUICtrlSetData($main_combo_algorith, "Aging")
		Case $SWAP_ALGORITHM_CLOCK
			GUICtrlSetData($main_combo_algorith, "Reloj")
		Case $SWAP_ALGORITHM_LFU
			GUICtrlSetData($main_combo_algorith, "LFU")
		Case $SWAP_ALGORITHM_MFU
			GUICtrlSetData($main_combo_algorith, "MFU")
		Case $SWAP_ALGORITHM_CLOCK_LINUX
			GUICtrlSetData($main_combo_algorith, "Reloj Linux")
	EndSwitch

	GUICtrlSetState($main_check_ws, FileReadLine($file)=="1"?$GUI_CHECKED:$GUI_UNCHECKED)
	GUICtrlSetData($main_input_wss, FileReadLine($file))
	GUICtrlSetData($main_input_iniT, FileReadLine($file))
	GUICtrlSetData($main_input_bufferSize, FileReadLine($file))

	FileClose($file)

	_actLabels()
	event_change_algorithm()

	If ___FIFOisfifo($FIFO) Then
		$text = ""
		For $i = 1 To $FIFO[0]
			$text &= $FIFO[$i]&@CRLF
		Next
		GUICtrlSetData($fifo_edit_fifo, StringTrimRight($text, 2))
	EndIf

	If ___Bufferisbuffer($BUFFER) Then
		$text = ""
		For $i = 0 To UBound($BUFFER, 1)-1
			For $j = 0 To UBound($BUFFER, 2)-1
				$text &= $BUFFER[$i][$j]
			Next
			$text &= @CRLF
		Next
		GUICtrlSetData($buffer_edit_buffer, StringTrimRight($text, 2))
	EndIf

	If ___PTispt($PAGETABLE) Then
		$n = UBound($PAGETABLE)-1
		For $i = 1 To $n
			$row = $PAGETABLE[$i]
			GUICtrlSetData($pt_input_pag[$i-1], $row[0])
		Next
		If ___PThasColum($PAGETABLE, "R") Then
			GUICtrlSetState($pt_check_acBr, $GUI_CHECKED)
			For $i = 0 To $n-1
				GUICtrlSetState($pt_check_br[$i], ___PTgetValueI($PAGETABLE, "R", $i)==1?$GUI_CHECKED:$GUI_UNCHECKED)
			Next
		EndIf
		If ___PThasColum($PAGETABLE, "M") Then
			GUICtrlSetState($pt_check_acBm, $GUI_CHECKED)
			For $i = 0 To $n-1
				GUICtrlSetState($pt_check_bm[$i], ___PTgetValueI($PAGETABLE, "M", $i)==1?$GUI_CHECKED:$GUI_UNCHECKED)
			Next
		EndIf
		If ___PThasColum($PAGETABLE, "Counter") Then
			GUICtrlSetState($pt_check_acCount, $GUI_CHECKED)
			For $i = 0 To $n-1
				GUICtrlSetData($pt_input_cont[$i], ___PTgetValueI($PAGETABLE, "Counter", $i))
			Next
		EndIf
	EndIf

	If IsArray($REFERENCES) And IsArray($MODIFICATIONS) And UBound($REFERENCES) == UBound($MODIFICATIONS) Then
		$text = ""
		For $i = 0 To UBound($REFERENCES)-1
			$text &= $REFERENCES[$i] & ($MODIFICATIONS[$i]==1?"*":"") & @CRLF
		Next
		GUICtrlSetData($references_edit_references, StringTrimRight($text, 2))
	EndIf

	If IsArray($PREASIGNATIONS) Then
		$text = ""
		For $i = 0 To UBound($PREASIGNATIONS)-1
			$text &= $PREASIGNATIONS[$i]&@CRLF
		Next
		GUICtrlSetData($preasignation_edit_preasignations, StringTrimRight($text, 2))
	EndIf
EndFunc
Func event_clear()
	Run(@AutoItExe)
	Exit
EndFunc
Func event_help()
	;TODO: Crear una pagina en github con la documentacion
	ShellExecute("https://github.com/BorjaLive/AutoMMU")
EndFunc
Func event_credicts()
	Global $GUI_credits = GUICreate("AutoMMU", 200, 150)

	GUICtrlCreateLabel("AutoMMU", 10,8,180,50)
	GUICtrlSetFont(-1, 28, 800)
	GUICtrlCreateLabel("Automatizador de"&@CRLF&"algoritmos de remplazo", 10,55,180,50, $ES_CENTER)
	GUICtrlSetFont(-1, 12, 400)
	GUICtrlCreateLabel("B0vE (Borja López Pineda)"&@CRLF&"UHU ETSI Ingeniería Informática"&@CRLF&"GNU GLP 3  2019", 5,105,180,50)

	GUISetOnEvent($GUI_EVENT_CLOSE, "event_closeCredits")
	GUISetState(@SW_SHOW, $GUI_credits)
EndFunc

Func event_save_references()
	$arr = StringSplit(StringReplace(GUICtrlRead($references_edit_references), " ",""),@CRLF, 1)
	Global $REFERENCES[0]
	Global $MODIFICATIONS[0]
	For $i = 1 To $arr[0]
		If $arr[$i] <> "" Then
			ReDim $REFERENCES[UBound($REFERENCES)+1]
			$REFERENCES[UBound($REFERENCES)-1] = StringReplace($arr[$i], "*", "")
			ReDim $MODIFICATIONS[UBound($MODIFICATIONS)+1]
			$MODIFICATIONS[UBound($MODIFICATIONS)-1] = StringInStr($arr[$i], "*")?1:0
		EndIf
	Next
	;_ArrayDisplay($REFERENCES)
	close_references()
EndFunc
Func event_save_fifo()
	$text = StringReplace(GUICtrlRead($fifo_edit_fifo), " ","")
	If $text == "" Then
		$FIFO = 0
	Else
		$arr = StringSplit($text, @CRLF, 1)
		$FIFO = ___FIFOcreate()
		For $i = 1 To $arr[0]
			If $arr[$i] <> "" Then ___FIFOadd($FIFO, $arr[$i])
		Next
	EndIf
	;____FIFOdump($FIFO)
	close_fifo()
EndFunc
Func event_save_buffer()
	$text = StringReplace(GUICtrlRead($buffer_edit_buffer), " ","")
	If $text == "" Then
		$BUFFER = 0
	Else
		$arr = StringSplit($text, @CRLF, 1)
		$len = StringLen($arr[1])
		For $i = 2 To $arr[0]
			If StringLen($arr[$i]) <> $len Then
				$len = -1
				ExitLoop
			EndIf
		Next
		If $len == -1 Then
			$BUFFER = 0
		Else
			$BUFFER = ___Buffercreate($len, $arr[0])
			For $i = $len To 1 Step -1
				For $j = 1 To $arr[0]
					If StringMid($arr[$j], $i, 1) == 1 Then
						___BufferUpdate($BUFFER, $j-1)
						ExitLoop
					EndIf
				Next
			Next
		EndIf
	EndIf
	;____Bufferdump($BUFFER)
	close_buffer()
EndFunc
Func event_save_pt()
	For $i = 0 To 9
		GUICtrlSetData($pt_input_pag[$i], StringReplace(GUICtrlRead($pt_input_pag[$i]), " ", ""))
		GUICtrlSetData($pt_input_cont[$i], StringReplace(GUICtrlRead($pt_input_cont[$i]), " ", ""))
	Next
	$n = 0
	For $i = 0 To 9
		If GUICtrlRead($pt_input_pag[$i]) <> "" Then
			$n += 1
		Else
			ExitLoop
		EndIf
	Next
	If $n == 0 Then
		$PAGETABLE = 0
	Else
		$PAGETABLE = ___PTcreate()
		If GuiCtrlRead($pt_check_acBr) == $GUI_CHECKED Then ___PTaddColum($PAGETABLE, "R")
		If GuiCtrlRead($pt_check_acBm) == $GUI_CHECKED Then ___PTaddColum($PAGETABLE, "M")
		If GuiCtrlRead($pt_check_acCount) == $GUI_CHECKED Then ___PTaddColum($PAGETABLE, "Counter")
		For $i = 0 To $n-1
			___PTaddPage($PAGETABLE, GUICtrlRead($pt_input_pag[$i]))
			If GuiCtrlRead($pt_check_acBr) == $GUI_CHECKED Then
				___PTsetValue($PAGETABLE, "R", GUICtrlRead($pt_input_pag[$i]), GUICtrlRead($pt_check_br[$i])==$GUI_CHECKED?1:0)
			EndIf
			If GuiCtrlRead($pt_check_acBm) == $GUI_CHECKED Then
				___PTsetValue($PAGETABLE, "M", GUICtrlRead($pt_input_pag[$i]), GUICtrlRead($pt_check_bm[$i])==$GUI_CHECKED?1:0)
			EndIf
			If GuiCtrlRead($pt_check_acCount) == $GUI_CHECKED Then
				___PTsetValue($PAGETABLE, "Counter", GUICtrlRead($pt_input_pag[$i]), GUICtrlRead($pt_input_cont[$i]))
			EndIf
		Next
	EndIf
	;____PTdump($PAGETABLE)
	close_pt()
EndFunc
Func event_save_preasignation()
	$text = StringReplace(GUICtrlRead($preasignation_edit_preasignations), " ","")
	If $text = "" Then
		$PREASIGNATIONS = 0
	Else
		$arr = StringSplit($text,@CRLF, 1)
		Global $PREASIGNATIONS[0]
		For $i = 1 To $arr[0]
			If $arr[$i] <> "" Then
				ReDim $PREASIGNATIONS[UBound($PREASIGNATIONS)+1]
				$PREASIGNATIONS[UBound($PREASIGNATIONS)-1] = $arr[$i]
			EndIf
		Next
	EndIf
	;_ArrayDisplay($PREASIGNATIONS)
	close_preasignation()
EndFunc

Func event_show_references()
	_swap_main($GUI_references)
EndFunc
Func event_show_fifo()
	_swap_main($GUI_fifo)
EndFunc
Func event_show_buffer()
	_swap_main($GUI_buffer)
EndFunc
Func event_show_pt()
	_swap_main($GUI_pt)
EndFunc
Func event_show_preasignation()
	_swap_main($GUI_preasignation)
EndFunc

Func event_closeResoult()
	GUISetState(@SW_HIDE, $GUI_resoult)
	GUIDelete($GUI_resoult)
	GUISetState(@SW_SHOW, $GUI_main)
EndFunc
Func event_closeCredits()
	GUISetState(@SW_HIDE, $GUI_credits)
	GUIDelete($GUI_credits)
EndFunc

Func event_exit()
	Exit
EndFunc
Func close_references()
	_restore_main()
	GUISetState(@SW_HIDE, $GUI_references)
EndFunc
Func close_fifo()
	_restore_main()
	GUISetState(@SW_HIDE, $GUI_fifo)
	_actLabels()
EndFunc
Func close_buffer()
	_restore_main()
	GUISetState(@SW_HIDE, $GUI_buffer)
	_actLabels()
EndFunc
Func close_pt()
	_restore_main()
	GUISetState(@SW_HIDE, $GUI_pt)
	_actLabels()
EndFunc
Func close_preasignation()
	_restore_main()
	GUISetState(@SW_HIDE, $GUI_preasignation)
EndFunc
#EndRegion

#Region UDF
Func _FIFO2Text($f)
	If Not ___FIFOisfifo($f) Then Return "0"
	Return _Array2Text($f)
EndFunc
Func _Buffer2Text($b)
	If Not ___Bufferisbuffer($b) Then Return "0"
	$text = UBound($b, 1)&"|"&UBound($b, 2)&"|"
	For $i = 0 To UBound($b, 1)-1
		For $j = 0 To UBound($b, 2)-1
			$text &= $b[$i][$j]
		Next
	Next
	Return $text
EndFunc
Func _PT2Text($p)
	If Not ___PTispt($p) Then Return "0"
	$text = ""
	For $i = 0 To UBound($p)-1
		$row = $p[$i]
		For $j = 0 To UBound($row)-1
			$text &= $row[$j]&"|"
		Next
		$text = StringTrimRight($text, 1)&"||"
	Next
	Return StringTrimRight($text, 2)
EndFunc
Func _Array2Text($a)
	If Not IsArray($a) Then Return "0"
	$text = ""
	For $i = 0 To UBound($a)-1
		$text &= $a[$i]&"|"
	Next
	Return StringTrimRight($text, 1)
EndFunc

Func _Text2FIFO($t)
	If $t == "0" Then Return 0
	Return _Text2Array($t)
EndFunc
Func _Text2Buffer($t)
	If $t == "0" Then Return 0
	$part = StringSplit($t, "|", 3)
	Dim $b[$part[0]][$part[1]]
	For $i = 0 To UBound($b, 1)-1
		For $j = 0 To UBound($b, 2)-1
			$b[$i][$j] = StringMid($part[2], ($i*UBound($b, 2))+$j+1, 1)
		Next
	Next
	Return $b
EndFunc
Func _Text2PT($t)
	If $t == "0" Then Return 0
	$rows = StringSplit($t, "||", 3)
	Dim $p[UBound($rows)]
	For $i = 0 To UBound($rows)-1
		$p[$i] = StringSplit($rows[$i], "|", 3)
	Next
	Return $p
EndFunc
Func _Text2Array($t)
	If $t == "0" Then Return 0
	Return StringSplit($t, "|", 3)
EndFunc

Func _actLabels()
	If ___FIFOisfifo($FIFO) Then
		GUICtrlSetData($main_label_iniciatedFifo, "Cargado")
	Else
		GUICtrlSetData($main_label_iniciatedFifo, "Sin datos")
	EndIf
	If ___Bufferisbuffer($BUFFER) Then
		GUICtrlSetData($main_label_iniciatedBuffer, "Cargado")
	Else
		GUICtrlSetData($main_label_iniciatedBuffer, "Sin datos")
	EndIf
	If ___PTispt($PAGETABLE) Then
		GUICtrlSetData($main_label_iniciatedPT, "Cargado")
	Else
		GUICtrlSetData($main_label_iniciatedPT, "Sin datos")
	EndIf
EndFunc
Func _swap_main($window)
	_restore_main()
	$Mainpos = WinGetPos($GUI_main)
	$CurPos = WinGetPos($window)
	WinMove($GUI_main, "", $Mainpos[0]-($CurPos[2]/2), $Mainpos[1])
	WinMove($window, "", $Mainpos[0]+$Mainpos[2]+10-($CurPos[2]/2), $Mainpos[1])
	GUISetState(@SW_SHOW, $window)
	$OPEN_WINDOW = $window
EndFunc
Func _restore_main()
	If $OPEN_WINDOW <> 0 Then
		GUISetState(@SW_HIDE, $OPEN_WINDOW)
		$CurPos = WinGetPos($OPEN_WINDOW)
		$Mainpos = WinGetPos($GUI_main)
		WinMove($GUI_main, "", $Mainpos[0]+($CurPos[2]/2), $Mainpos[1])
		$OPEN_WINDOW = 0
	EndIf
EndFunc
#EndRegion