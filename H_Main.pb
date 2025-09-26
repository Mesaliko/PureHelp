;- TOP

;=============================================================================
;
;                              PURE HELP
;
; Entry point of PUREHELP (Main file)
; ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
; Author: Mesa and pbsians from the forum : No AI ! ! ! (All is Handmade)
;
; Version: 1.0
;
; Windows : From Windows XP to Windows 11: Windows XP and Windows 10 tested ok
; Linux and MacOS should work, but not tested
; TODO : Test with other Windows, Linux and MacOS
;
; 2025
;==============================================================================

; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.

EnableExplicit

;- Includes
;Os specific gaadgets trics (from Hex0r)
XIncludeFile "H_OSfixes.pbi"

;Declare and initialize Structures, Globals, ...
XIncludeFile "H_Initialization.pbi"

;Preferences use the "PureHelp.prefs" file
XIncludeFile "H_Preferences.pbi"

;Languages module: Translation Fr,En,De
XIncludeFile "H_Language.pbi"

;Dialog Gui
XIncludeFile "PureHelp.xml.dd.pbi"

;Windows XP tricks to search strings in a html file
CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  XIncludeFile "COMatePLUS.pbi"
  XIncludeFile "COMatePLUS_Residents.pbi"
CompilerEndIf


;- Constants GUI from Ddialog
Enumeration ExtraStuff
  ;images toolbar buttons
  #im_image_Maskpanel = #PB_Compiler_EnumerationValue
  #im_imagepressed_Maskpanel
  #im_buttonimage_Previous
  #im_buttonimage_Next
  #im_buttonimage_Home
  #im_buttonimage_Print
  #im_buttonimage_Search
  #im_buttonimage_Options
  ;images treegadget
  #im_tree_BookClosed
  #im_tree_BookOpen
  #im_tree_Books
  #im_tree_File
  
  ;id popup menu names
  #MainForm_ToolBar_OptionPopUp
  #MainForm_Treeview_PopUp
  ;id popup menus
  #ToolBar_OptionPopUp_Refresh
  #ToolBar_OptionPopUp_Stop
  #ToolBar_OptionPopUp_Font
  #ToolBar_OptionPopUp_FontSizeOnly
  #ToolBar_OptionPopUp_FontList
  #ToolBar_OptionPopUp_FontListColour
  #ToolBar_OptionPopUp_FontListSizeOnly
  #ToolBar_OptionPopUp_FontDefault
  #ToolBar_OptionPopUp_Icons
  #ToolBar_OptionPopUp_IconsSize
  #ToolBar_OptionPopUp_SummaryDefault
  #ToolBar_OptionPopUp_SummaryMesa
  #ToolBar_OptionPopUp_SummaryOpen
  #ToolBar_OptionPopUp_SummaryCreate
  #ToolBar_OptionPopUp_IndexDefault
  #ToolBar_OptionPopUp_IndexOpen
  #ToolBar_OptionPopUp_IndexCreate
  #ToolBar_OptionPopUp_Fr
  #ToolBar_OptionPopUp_En
  #ToolBar_OptionPopUp_De
  #ToolBar_OptionPopUp_Update
  #ToolBar_OptionPopUp_About
  ;id treegadget popup menus
  #Treeview_Popup_ExpandAll
  #Treeview_Popup_CollapseAll
  #Treeview_Popup_Print
  #Treeview_Popup_ItemTextColor
  #Treeview_Popup_ItemBkgColor
  #Treeview_Popup_ItemResetColor
  #Treeview_Popup_AllItemResetColor
  
  ;Accelerators (Keyboard shortcuts)
  ;TODO (accelerators are not implemented)
  #DummyMenu
  #Acc_TB_Options
  #Acc_Panel_TabSummary
  #Acc_Panel_TabIndex
  #Acc_Panel_TabSearch
  #Acc_Panel_TabFavorites
  #Acc_Panel_StringSearch
  #Acc_Panel_ButtonDisplay
  #Acc_Panel_ButtonListRubric
  #Acc_Panel_Rubric
  #Acc_Panel_ButtonDel
  #Acc_Panel_StringRubric
  #Acc_Panel_ButtonAdd
  
EndEnumeration

;- Include Misc. procedures
XIncludeFile "H_Procedures.pbi"

;- Include Runtimes procedures (gadgets' events)
XIncludeFile "H_Runtimes.pbi"


;-
;- Entry point Open Gui and lift offfffff !
Define i, R, ok
Define a$ = GetXMLString()

If ParseXML(0, a$) And XMLStatus(0) = #PB_XML_Success
  For i = 1 To #DD_WindowCount
    CreateDialog(i)
    CompilerIf #DD_UseExtraStuff
      UsePNGImageDecoder()
      R = DEX::InitDialog(i, 0, DD_WindowNames(i), 1)
    CompilerElse
      R = OpenXMLDialog(i, 0, DD_WindowNames(i))
    CompilerEndIf
    If R
      ;>>>>>>>>>>post init (see H_Procedures.pbi)
      Init()
      
      HideWindow(DialogWindow(i), 0)
      ok = #True
      InitSplitter() ;set splitter position from preference
      
    Else
      Debug DialogError(i)
    EndIf
  Next i
  CompilerIf Defined(PB_OS_Web, #PB_Constant) = 0 Or #PB_Compiler_OS <> #PB_OS_Web
    If ok
      
      While WaitWindowEvent() <> #PB_Event_CloseWindow : Wend
      
    EndIf
  CompilerEndIf
Else
  Debug XMLStatus(0)
  Debug XMLError(0)
EndIf
CompilerIf #DD_UseExtraStuff
  DEX::DeInit()
CompilerEndIf

;If virtualdrive on, then close it (windows only)
DelVirtualDrive(VirtualDrive + ":")
;Update preferences
PreferencesUpdate()



; IDE Options = PureBasic 6.30 beta 2 (Windows - x64)
; CursorPosition = 35
; FirstLine = 12
; Folding = -
; EnableAsm
; EnableXP
; CompileSourceDirectory