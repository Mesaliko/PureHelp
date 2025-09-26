;- TOP

;===============================================================================
;
;                              PURE HELP
;
; This file = Specific OS Macro, Structure, Procedure, Constant (#EXT = "dll")
; ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
;
; Author: Hex0r 2024 + mksoft + pbsians : No AI ! ! ! (All is Handmade)
;
; Version: 1.0
;
; Windows : All
; Linux and MacOS should work, but not tested
; 
;
; 2025
;================================================================================



; TODO Delete unused things




;For qt: Global TreeForEach_Data.TREEVIEWDATA


CompilerSelect #PB_Compiler_OS
    
    ;- LINUX
    ;- ==========
  CompilerCase #PB_OS_Linux
    Macro GetLangDir()
      GetPathPart(ProgramFilename()) + "Languages" + #PS$
    EndMacro
    Macro GetDefPath()
      GetPathPart(ProgramFilename())
    EndMacro
    Macro GetThemePath()
      GetPathPart(ProgramFilename()) + "Themes" + #PS$
    EndMacro
    
    CompilerIf Subsystem("qt")
      Structure RECT
        x.i
        y.i
        w.i
        h.i
      EndStructure
      
      Procedure DoTreeAutoScroll(Gadget, yPos, SelectedIndex)
        ;TODO TreeAutoScroll for linux qt
        qtscript("gadget(" + Str(Gadget) + ").setCurrentIndex(" + Str(SelectedIndex) + ")")
        
      EndProcedure
      
      Procedure GetTreeItemBelowCursor(Gadget, x, y)
        ;TODO GetTreeItemBelowCursor for linux qt
      EndProcedure
      
      
    CompilerElse
      CompilerWarning "You should better use the qt subsystem on linux!"
      ImportC ""
        g_object_set(*object.GObject, property_name.p-utf8, *data, value = 0)
      EndImport
      ; 			ImportC "-gtk"
      ;   			gtk_window_set_opacity(*window.i, opacity.d);
      ;   			gtk_widget_is_composited (*widget)
      ; 			EndImport
      
      g_object_set(gtk_settings_get_default_(), "gtk-entry-select-on-focus", #False)
      
      ;- for TreeGadget. Conversion from PathString (e.g. 2:5:1) to continous ItemIndex (PB)
      Structure TREEVIEWDATA
        Path.l
        ;    SearchIndex.l
        ItemIndex.l
        PathString.s
      EndStructure
      
      Global TreeForEach_Data.TREEVIEWDATA
      
      ProcedureC Callback_TreeForEach2Index(*Model, *Path, *Iter, *userdata.TREEVIEWDATA);!
        If PeekS(gtk_tree_path_to_string_(*Path), - 1 , #PB_UTF8) = *userdata\PathString
          ProcedureReturn #True
        Else
          *userdata\ItemIndex + 1
          ProcedureReturn #False
        EndIf
      EndProcedure
      
      Procedure.i TV_ItemIndexFromPathString(Gadget, PathString.s)
        Protected iter.GtkTreeIter
        Protected tPath
        Protected *tModel = gtk_tree_view_get_model_(GadgetID(Gadget))
        
        gtk_tree_model_get_iter_first_(*tModel, @iter)
        tPath = gtk_tree_model_get_path_(*tModel, iter)
        If tPath
          TreeForEach_Data\ItemIndex  = 0
          TreeForEach_Data\Path       = tPath
          TreeForEach_Data\PathString = PathString
          gtk_tree_model_foreach_(*tModel, @Callback_TreeForEach2Index(), TreeForEach_Data)
          gtk_tree_path_free_(tPath); ???
        EndIf
        If TreeForEach_Data\ItemIndex >= CountGadgetItems(Gadget)
          TreeForEach_Data\ItemIndex = -1
        EndIf
        ProcedureReturn TreeForEach_Data\ItemIndex
      EndProcedure
      
      Procedure GetTreeItemBelowCursor(Gadget, x, y)
        Protected Result, *treepath, pos
        
        Result = -1
        gtk_tree_view_get_dest_row_at_pos_(GadgetID(Gadget), x, y, @*treepath, @pos)
        If *treepath
          ;for TreeGadgets (get hierarchic numbering on nodes like 2:5:1) ...
          If PeekS(gtk_tree_path_to_string_(*treepath), - 1, #PB_UTF8) <> ""; check necessary ?
            Result = TV_ItemIndexFromPathString(Gadget, PeekS(gtk_tree_path_to_string_(*treepath), - 1, #PB_UTF8))
          EndIf
          ;pos; is relative position see: https://developer.gnome.org/gtk3/stable/GtkTreeView.html#GtkTreeViewDropPosition
        EndIf
        
        ProcedureReturn Result
      EndProcedure
      
      Procedure DoTreeAutoScroll(Gadget, yPos, SelectedIndex)
        ;TODO TreeAutoScroll for linux
        
      EndProcedure
      
      
    CompilerEndIf
    
    #EXT = "so"
    ;-
    ;================================================================================
    
    
    ;- WINDOWS
    ;- ==========
  CompilerCase #PB_OS_Windows
    
    Macro GetLangDir()
      GetPathPart(ProgramFilename()) + "Languages" + #PS$
    EndMacro
    Macro GetDefPath()
      GetPathPart(ProgramFilename())
    EndMacro
    Macro GetThemePath()
      GetPathPart(ProgramFilename()) + "Themes" + #PS$
    EndMacro
    
    CompilerIf Defined(TVHITTESTINFO, #PB_Structure) = 0
      Structure TVHITTESTINFO
        pt.POINT
        flags.l
        hItem.i
      EndStructure
    CompilerEndIf
    
    Procedure GetTreeItemBelowCursor(Gadget, x, y)
      Protected Result, TVITEM.TVITEM, TVHT.TVHITTESTINFO
      
      Result       = -1
      TVITEM\mask  = #TVIF_PARAM
      TVHT\pt\x    = x
      TVHT\pt\y    = y
      TVITEM\hItem = SendMessage_(GadgetID(Gadget), #TVM_HITTEST, 0, @TVHT)
      If TVITEM\hItem
        SendMessage_(GadgetID(Gadget), #TVM_GETITEM, 0, TVITEM) ;thanks to RSBasic
        Result = TVITEM\lParam
      EndIf
      
      ProcedureReturn Result
    EndProcedure
    
    Procedure DoTreeAutoScroll(Gadget, yPos, SelectedIndex)
      Protected Count, j
      
      If SelectedIndex > - 1
        Count = CountGadgetItems(Gadget)
        If yPos > 0 And yPos < 30
          ;move it up
          j = SelectedIndex - 1
          If j >= 0
            SendMessage_(GadgetID(Gadget), #TVM_ENSUREVISIBLE, 0, GadgetItemID(Gadget, j))
          EndIf
        ElseIf yPos > GadgetHeight(Gadget) - 30
          ;move it down
          j = SelectedIndex + 1
          If j < Count
            SendMessage_(GadgetID(Gadget), #TVM_ENSUREVISIBLE, 0, GadgetItemID(Gadget, j))
          EndIf
        EndIf
      EndIf
    EndProcedure
    
    
    #EXT = "dll"
    ;-
    ;================================================================================
    
    
    ;- MACOS
    ;- ==========
  CompilerCase #PB_OS_MacOS
    ; from PathHelper v1.01 by mk-soft
    ; https://www.purebasic.fr/english/viewtopic.php?p=562634#p562634
    Procedure.s GetResourcesPath()
      ProcedureReturn GetPathPart(RTrim(GetPathPart(ProgramFilename()), #PS$)) + "Resources" + #PS$
    EndProcedure
    
    Macro GetLangDir()
      GetResourcesPath() + "Languages" + #PS$
    EndMacro
    Macro GetDefPath()
      GetResourcesPath()
    EndMacro
    Macro GetThemePath()
      GetResourcesPath() + "Themes" + #PS$
    EndMacro
    
    ;https://www.purebasic.fr/german/viewtopic.php?p=358656#p358656
    Macro _PB_(Function)
      Function
    EndMacro
    
    Procedure FixSetGadgetFont(Gadget, FontID)
      Static SystemFontID
      Protected FontSize.CGFloat
      If FontID = #PB_Default
        If Not SystemFontID
          CocoaMessage(@FontSize, 0, "NSFont systemFontSize") : FontSize - 1
          SystemFontID = CocoaMessage(0, 0, "NSFont systemFontOfSize:@", @FontSize)
        EndIf
        _PB_(SetGadgetFont)(Gadget, SystemFontID)
      Else
        _PB_(SetGadgetFont)(Gadget, FontID)
      EndIf
    EndProcedure
    
    Macro SetGadgetFont(Gadget, FontID)
      FixSetGadgetFont(Gadget, FontID)
    EndMacro
    
    ;TODO fix this damned procedure for MacOS
    
    Procedure GetTreeItemBelowCursor(Gadget, x, y)
      Protected H, Result, Frame.NSRect
      
      CocoaMessage(@Frame, GadgetID(Gadget), "frameOfOutlineCellAtRow:", 0)
      H      = Frame\size\height
      Result = Int(y / H)
      
      ProcedureReturn Result
    EndProcedure
    
    ;TODO TreeAutoScroll for MacOS
    
    Procedure DoTreeAutoScroll(Gadget, yPos, SelectedIndex)
    EndProcedure
    
    #EXT = "dylib"
    
CompilerEndSelect


Procedure.s GetPath()
  
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      ProcedureReturn GetPathPart(ProgramFilename())
    CompilerCase #PB_OS_Linux
      ProcedureReturn GetPathPart(ProgramFilename())
    CompilerCase #PB_OS_MacOS
      ProcedureReturn GetResourcesPath()
  CompilerEndSelect
EndProcedure

CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
  
  Macro CocoaString(NSString)
    PeekS(CocoaMessage(0, NSString, "UTF8String"), - 1, #PB_UTF8)
  EndMacro
  
CompilerEndIf

;mksoft
Procedure.s GetProgramPath()
  CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
    Static bundlePath.s
    Protected bundlePathPtr
    
    If Not Bool(bundlePath)
      bundlePathPtr = CocoaMessage(0, CocoaMessage(0, 0, "NSBundle mainBundle"), "bundlePath")
      If bundlePathPtr
        bundlePath = CocoaString(bundlePathPtr) + "/"
      EndIf
    EndIf
    ProcedureReturn bundlePath
  CompilerElse
    ProcedureReturn GetPathPart(ProgramFilename())
  CompilerEndIf
EndProcedure
;-
;================================================================================

;- Some os dependant macros
;- ==========================
Macro M_OS_InitializeSplitter(i)
  ;DDesign0r_v02.pb
  CompilerIf #PB_Compiler_OS <> #PB_OS_Linux Or Subsystem("qt")
    ;Linux is behaving strange here... better ignore the splitter for now
    SetGadgetState(DialogGadget(#Dialog_Main, "splitter"), i)
  CompilerEndIf
EndMacro

Macro M_OS_GadgetDrop
  ;DDesign0r_v02.pb
  CompilerIf #PB_Compiler_OS = #PB_OS_Linux
    If EventGadget() = DID("tree_objects")
      OnObjectTreeDrop()
    EndIf
  CompilerEndIf
EndMacro

Macro M_OS_InitSplitter
  ;DDesign0r_v02.pb
  CompilerIf #PB_Compiler_OS = #PB_OS_Linux And Subsystem("qt") = 0
    ;Damn linux, this crazy part below was the only chance to get the splitter correctly inititalized
    For j = i + 10 To i Step - 1
      SetGadgetState(DialogGadget(#Dialog_Main, "splitter"), j)
      While WindowEvent() : Wend
      Delay(20)
    Next j
    RefreshDialog(#Dialog_Main)
  CompilerEndIf
EndMacro

Macro M_OS_CloseSelectionWindows
  ;;DDesign0r_v02.pb,DD_internalProcedures.pbi, DD_RuntimeProcedures.pbi
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    ;Windows only! close the 4 micky mouse windows
    For j = 0 To 3
      If IsWindow(j)
        CloseWindow(j)
      EndIf
    Next j
  CompilerEndIf
EndMacro

; IDE Options = PureBasic 6.03 LTS (Windows - x86)
; CursorPosition = 18
; Folding = ------
; EnableXP
; EnableUser
; CompileSourceDirectory
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant