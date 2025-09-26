;- TOP

;=============================================================================
;
;                              PURE HELP
;
; Initialization of Globals, Declare, Structure, etc.
; ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
; Author: Mesa : No AI ! ! ! (All is Handmade)
;
; Version: 1.0
;
; Windows : All
; Linux and MacOS should work, but not tested
; 
;
; 2025
;=============================================================================


;- ImageDecoder
UsePNGImageDecoder()

;- CONSTANTS
#H_PrefFile = "PureHelp.prefs"
#version    = 621

;*********** Main_Form.pbi ************************
;- Globals, struct, prototype
Global WebDisplay
Global Path$       = GetPath()                    ; Path exe
Global PathIcon$   = Path$ + "Icons" + #PS$       ; icons for the gui
Global PathHelpHD$ = Path$ + "Help" + #PS$        ; Help HTML files on hard drive
Global PathHelp$   = Path$ + "Help" + #PS$        ; Help HTML files on hard drive or virtualdrive
Global PathHTMLHD$ = PathHelp$
Global PathHTML$   = PathHelp$
Global PathLang$   = Path$ + "Lang" + #PS$
Global PathDLL$    = Path$ + "Dll" + #PS$         ; Not used

Global CurrentLink.s
Global CurrentPath.s

Global VirtualDrive.s = "Z"
Global Zoom.f
Global Preference$ = Path$ + #H_PrefFile


Global DefaultSummary.s
Global CurrentSummary.s
Global MesaSummary.s
Global Summary3D
Global DefaultIndex.s
Global CurrentIndex.s


CompilerSelect #PB_Compiler_OS
  CompilerCase #PB_OS_Windows
    PathHTML$   = ReplaceString(PathHTML$, "\", "/")
    PathHTMLHD$ = PathHTML$
    
    ;XP
    If OSVersion() <= #PB_OS_Windows_XP
      Global ShowSearch = 0, WebReady = 0
      Global WebObject.IWebBrowser2
      Global Searchbox$
    EndIf
CompilerEndSelect

CompilerIf #PB_Compiler_Version >= 610
  UseDialogWebGadget()
  UseDialogWebViewGadget()
CompilerEndIf


; *********** H_Procedures.pbi ******************
;reading contents and indexes
Structure Struct_Contents
  Node.s
  Path.s
  Link.s
  Level.l
EndStructure

Global NewList Contents.Struct_Contents()
Global NewList Index.Struct_Contents()
Global NewList History()
Global NewList Favorites.Struct_Contents()
Global NewList Searched_Files.s()
Global NewList Searched_FilesSize.q()
Global NewList Searched_FilesSizefr.q()
Global NewList Searched_FilesSizeen.q()
Global NewList Searched_FilesSizede.q() 
Global NewList Searched_Items.Struct_Contents()
Global Searched$
Global *RamDisk
Global Dim SearchArray.q(0)
Global Dim OffSet.q(0)
CompilerIf Not Defined(PB_EventType_ReturnKey, #PB_Constant); Return key launch a procedure from a stringgadget
    #PB_EventType_ReturnKey = $501
CompilerEndIf
#MenuEvent_ReturnKey = 1000
Global MenuReturnKey ; A menu only for manage the returnkey

; *********** UserLanguage.pbi ********************
Global UserLanguage
Global UserLanguage$;fr en de

; *********** Preferences.pbi *********************
Global MainWindows_X, MainWindows_Y, MainWindows_W, MainWindows_H
Global Language$
Global Icons$ = Path$ + "Icons" + #PS$ + "Items" + #PS$
Global Ini, CountInit
Global NewMap Preferences.s()
  
;- Prototype
;Tab Search: Needed to search a word inside files recurvely and quickly
Prototype clbSearchFile(lType.l, sName.s)

;tree
Global Tree_Double_Click
;tree big icons
CompilerSelect #PB_Compiler_OS
  CompilerCase #PB_OS_Windows
    Global ImageList, IconSize
    ;   CompilerCase #PB_OS_Linux
    ;   CompilerCase #PB_OS_MacOS
    ;   CompilerDefault
CompilerEndSelect
Structure ColorItem
  item.i
  textcolor.i
  bkgcolor.i
  EndStructure
Global NewList ItemColor.ColorItem()
Global ItemColorTxt.i = 0; Keep original color
Global ItemColorBkg.i = 16777215; Keep original color

;- Declare
Declare TreeParentChild(Tree)
Declare PopUpMenus()
Declare SendKeys(handle, window$, keys$)

; IDE Options = PureBasic 6.03 LTS (Windows - x86)
; CursorPosition = 111
; FirstLine = 109
; Folding = -
; EnableAsm
; EnableXP
; CompileSourceDirectory