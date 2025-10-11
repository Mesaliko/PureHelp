;- TOP

;=============================================================================
;
;                              PURE HELP
;
; Procedures post-initialization: Do a lot of things after the GUI openning
; ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
; Author: Mesa and pbsians from the forum : No AI ! ! ! (All is Handmade)
;
; Version: 1.0
;
; Windows : All
; Linux and MacOS should work, but not tested
;
;
; 2025
;=============================================================================


;-
;- Declare
;Only to manage the udate() procedure
Declare Search_BrowseDirectory(sPath.s, *pClbFound = 0)
Declare Search_Files(Type, Name$)
Declare Search_Init()
Declare Init()
Declare TreeAllItemResetColor()
;-
;- : Web Transform html into brut text
;- ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
;Not used
Procedure.s html2txt(file$ = "", savefile$ = "")
  Protected f, g
  Protected tmp$, tmpp$, Result$
  Protected format, exp
  Protected NewList txt.s()
  
  If file$ = ""
    ProcedureReturn ""
  Else
    f = ReadFile(#PB_Any, file$)
    ; format = ReadStringFormat(f);bug
    format = #PB_UTF8
    
    exp = CreateRegularExpression(#PB_Any, "<[^>]*>")
    
    If savefile$
      g = CreateFile(#PB_Any, savefile$, format)
    EndIf
    
    While Eof(f) = 0
      tmp$ = ReadString(f, Format);
      If FindString(tmp$, "<body ", 0, #PB_String_NoCase) > 0
        Break
      EndIf
    Wend
    
    While Eof(f) = 0
      tmp$    = ReadString(f, format);
      tmpp$   = ReplaceString(tmp$, "&quot;", Chr(34))
      tmpp$   = ReplaceString(tmpp$, "&amp;", "&")
      Result$ = ReplaceRegularExpression(exp, tmpp$, "")
      AddElement(txt())
      txt() = Result$
      If savefile$
        WriteStringN(g, Result$, Format)
      EndIf
    Wend
    CloseFile(f)
    If savefile$
      CloseFile(g)
    EndIf
    FreeRegularExpression(exp)
  EndIf
  
EndProcedure


CompilerSelect #PB_Compiler_OS
  CompilerCase #PB_OS_Windows
    ;- .        -Windows
    
    ;Not used, Autor: freak
    Procedure WebGadget_Document(Gadget, *IID)
      Protected Document = 0
      Protected Browser.IWebBrowser2
      Protected DocumentDispatch.IDispatch
      
      Browser.IWebBrowser2 = GetWindowLongPtr_(GadgetID(Gadget), #GWL_USERDATA)
      If Browser
        If Browser\get_Document(@DocumentDispatch.IDispatch) = #S_OK And DocumentDispatch
          DocumentDispatch\QueryInterface(*IID, @Document)
          DocumentDispatch\Release()
        EndIf
      EndIf
      ProcedureReturn Document
      
    EndProcedure
    
    ;Not used
    Procedure.s WebGadget_PageText(Gadget, file$ = "")
      Protected Result$ = ""
      Protected Document.IHTMLDocument2
      Protected Body.IHTMLElement
      Protected bstr_text, Res
      
      Document.IHTMLDocument2 = WebGadget_Document(Gadget, ?IID_IHTMLDocument2)
      If Document
        If Document\get_body(@Body.IHTMLElement) = #S_OK
          If Body\get_innerText(@bstr_text) = #S_OK And bstr_text
            Result$ = PeekS(bstr_text, - 1, #PB_Unicode)
            SysFreeString_(bstr_text)
          EndIf
          Body\Release()
        EndIf
        Document\Release()
      EndIf
      
      If file$ = ""
        file$ = GetTemporaryDirectory() + "tmp.pb"
      EndIf
      
      If CreateFile(0, file$)
        Res = WriteString(0, Result$)
        ;TO DO if Res=0 then problem
        CloseFile(0)
      EndIf
      
    EndProcedure
    
    ;Don't move this declare anywhere else
    Declare WebEventProc(Object.COMateObject, eventName$, parameterCount)
    
    ;Special WebGadget init for Windows XP
    Procedure InitWebXP()
      ;Needed for Windows XP
      If OSVersion() <= #PB_OS_Windows_XP And CountInit = 0
        Global web.COMateObject       
        Protected iid.IID
        
        WebObject = GetWindowLong_(GadgetID(#Web), #GWL_USERDATA)
        web       = COMate_WrapCOMObject(GetWindowLongPtr_(GadgetID(#Web), #GWL_USERDATA))
        
        If COMate_GetIIDFromName("DWebBrowserEvents2", @iid) = #S_OK
          web\SetEventHandler(#COMate_CatchAllEvents, @WebEventProc(), 0, iid)
        EndIf
      EndIf
      
    EndProcedure
    
    ;Windows XP Webgadget callback and used to show the search box
    Procedure WebEventProc(Object.COMateObject, eventName$, parameterCount)
      
      ;#OLECMDID_FIND                = 32
      ;#OLECMDEXECOPT_DODEFAULT      = 0
      ;#OLECMDEXECOPT_PROMPTUSER     = 1
      ;#OLECMDEXECOPT_DONTPROMPTUSER = 2
      
      If ShowSearch
        If eventName$ = "DocumentComplete"
          WebObject\get_ReadyState(@WebReady)
          
          If WebReady > 2
            WebObject\ExecWB(32, 0, #Null, #Null)
            SendKeys(0, Searchbox$, Searched$)
          EndIf
        EndIf
      EndIf
      
    EndProcedure
    
    DataSection
      IID_IHTMLDocument2: ; {332C4425-26CB-11D0-B483-00C04FD90119}
      Data.l $332C4425
      Data.w $26CB, $11D0
      Data.b $B4, $83, $00, $C0, $4F, $D9, $01, $19
      IID_IHTMLDocument3: ; {3050F485-98B5-11CF-BB82-00AA00BDCE0B}
      Data.l $3050F485
      Data.w $98B5, $11CF
      Data.b $BB, $82, $00, $AA, $00, $BD, $CE, $0B
      ;       IID_NULL: ; {00000000-0000-0000-0000-000000000000}; Allready present in the included Comatexxx.pbi
      ;       Data.l $00000000
      ;       Data.w $0000, $0000
      ;       Data.b $00, $00, $00, $00, $00, $00, $00, $00
    EndDataSection
    
    
  CompilerCase #PB_OS_MacOS
    ;- .        -MacOS
    ; TODO test needed
    Procedure.s WebGadget_PageText(Gadget, file$ = "")
      html2txt(file$)
    EndProcedure
    
  CompilerCase #PB_OS_Linux
    ;- .        -Linux
    ; TODO test needed
    Procedure.s WebGadget_PageText(Gadget, file$ = "")
      html2txt(file$)
    EndProcedure
CompilerEndSelect

;-
;- Content (summary) and Index
;- ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
; Read a microsoft hhc table of contents file and Fill the treeview
Procedure Fill_hhc(gadget, hhc$)
  Protected level, f, format
  Protected contentsFile$, tmp$, tmpp$, tmppp$
  
  ClearGadgetItems(gadget)
  ClearList(contents())
  
  If FileSize(PathHTML$) <> - 2
    MessageRequester(Language::Get("Requesters", "ATTENTION"), Language::Get("Requesters", "HelpDirMissing"), #PB_MessageRequester_Error)
    ProcedureReturn 0
  EndIf
  
  If FileSize(hhc$) > 0
    contentsFile$  = hhc$
    CurrentSummary = contentsFile$
  Else
    MessageRequester(Language::Get("Requesters", "ATTENTION"), Language::Get("Requesters", "ContentsCorrupted"), #PB_MessageRequester_Error)
    ProcedureReturn 0
  EndIf
  
  level  = 0
  tmppp$ = ~"\">"
  level  = 0
  f      = ReadFile(#PB_Any, contentsFile$)
  
  If f
    format = ReadStringFormat(f)
    
    Repeat; jump to the first "<UL>"
      tmp$ = ReadString(f, format)
    Until FindString(tmp$, "<UL>") > 0
    
    While Eof(f) = 0
      
      tmp$ = ReadString(f, format)
      
      tmpp$ = ~"<param name=\"Name\" value=\"" ; For Linux and OSX, i don't change '\' into '/' because it arised from Windows
      If FindString(tmp$, tmpp$)
        tmp$ = RemoveString(tmp$, tmpp$)
        tmp$ = RemoveString(tmp$, tmppp$)
        AddElement(contents())
        contents()\Node  = Trim(tmp$)
        contents()\Level = level
        Continue
      EndIf
      
      tmpp$ = ~"<param name=\"Local\" value=\""
      If FindString(tmp$, tmpp$)
        tmp$             = RemoveString(tmp$, tmpp$)
        tmp$             = RemoveString(tmp$, tmppp$)
        contents()\Path  = Trim(tmp$)
        contents()\Link  = ReplaceString("file://" + PathHTML$ + Trim(tmp$), "\", "/")
        contents()\Level = level
        Continue
      EndIf
      
      If FindString(tmp$, "</UL>")
        level = level - 1
        Continue
      EndIf
      
      If FindString(tmp$, "<UL>")
        level = level + 1
        Continue
      EndIf
    Wend
    CloseFile(f)
    
    ;Fill the treeview
    ForEach contents()
      AddGadgetItem(gadget, - 1, contents()\Node, 0, contents()\Level)
    Next
    
    ;Select the first item
    SetGadgetItemState(gadget, 0, #PB_Tree_Selected)
    
  EndIf
  
EndProcedure

; Read a microsoft hhk index file and Fill the listview
Procedure Fill_hhk(gadget, hhk$)
  Protected f, indexFile$, tmppp$, tmp$, tmpp$
  
  ClearGadgetItems(gadget)
  ClearList(index())
  
  indexFile$ = hhk$
  
  If FileSize(indexFile$) = -1
    MessageRequester("ATTENTION", Language::Get("Requesters", "HKKCorrupted"), #PB_MessageRequester_Error)
    ProcedureReturn 1
  EndIf
  
  
  f = ReadFile(#PB_Any, indexFile$, #PB_Ascii)
  If f
    tmppp$ = ~"\">"
    While Eof(f) = 0
      tmp$  = ReadString(f)
      tmpp$ = ~"<param name=\"Name\" value=\""
      If FindString(tmp$, tmpp$)
        tmp$ = RemoveString(tmp$, tmpp$)
        tmp$ = RemoveString(tmp$, tmppp$)
        AddElement(index())
        index()\Node = Trim(tmp$)
        Continue
      EndIf
      tmpp$ = ~"<param name=\"Local\" value=\""
      If FindString(tmp$, tmpp$)
        tmp$         = RemoveString(tmp$, tmpp$)
        tmp$         = RemoveString(tmp$, tmppp$)
        index()\Path = Trim(tmp$)
        index()\Link = ReplaceString("file://" + PathHTML$ + Trim(tmp$), "\", "/")
        Continue
      EndIf
    Wend
    CloseFile(f)
  Else
    ProcedureReturn 1
  EndIf
  
  ; Sort ascending
  SortStructuredList(index(), #PB_Sort_Ascending, OffsetOf(Struct_Contents\Node), TypeOf(Struct_Contents\Node))
  
  ; Attention, some character like "|" have an ascii code > "z", so let's move them on the top.
  LastElement(index())
  While Asc(index()\Node) > Asc("Z")
    MoveElement(index(), #PB_List_First )
    LastElement(index())
  Wend
  
  ; &amp;
  ForEach index()
    If index()\Node = "&amp;"
      index()\Node = "&"
      Break
    EndIf
  Next
  
  ;Fill the treeview
  ForEach index()
    AddGadgetItem(gadget, - 1, index()\Node)
  Next
  
EndProcedure

;Recursive xml summary file treatment
Procedure XMLFile(*CurrentNode, CurrentSublevel, gadget, List thelist.Struct_Contents())
  ;<entry title="Introduction" url="mainguide/intro.html"/>
  Protected attr_name$, attr_value$
  Protected c, *ChildNode
  
  If XMLNodeType(*CurrentNode) = #PB_XML_Normal
    If ExamineXMLAttributes(*CurrentNode)
      While NextXMLAttribute(*CurrentNode)
        attr_name$ = Trim(XMLAttributeName(*CurrentNode))
        attr_value$ = Trim(XMLAttributeValue(*CurrentNode))
        c + 1
        Select c
          Case 1
            AddElement(thelist())
            thelist()\Node  = attr_value$
            thelist()\Level = CurrentSublevel
            AddGadgetItem(gadget, - 1, attr_value$, 0, CurrentSublevel)
            
          Case 2          
            thelist()\Path = PathHTML$ + attr_value$
            thelist()\Link = "file://" + PathHTML$ + attr_value$
            thelist()\Link = ReplaceString(thelist()\Link, "\", "/")
        EndSelect
      Wend
    EndIf
    
    ; Now get the first child node (if any)
    *ChildNode = ChildXMLNode(*CurrentNode)
    
    ; Loop through all available child nodes And call this Procedure again
    
    While *ChildNode <> 0
      XMLFile(*ChildNode, CurrentSublevel + 1, gadget,thelist())
      *ChildNode = NextXMLNode(*ChildNode)
    Wend
    
  EndIf
EndProcedure

;Fill the treegadget with a summary (*.sum) file in the summary tab
Procedure FillSummary(gadget, Summary$)
  Protected f, format, level = - 1, xml
  Protected file$, line$, Message$
  Protected *MainNode
  
  ClearGadgetItems(gadget)
  ClearList(contents())
  
  ;Open xml
  file$ = Summary$
  If LCase(GetExtensionPart(file$)) = "xml"
    If file$ <> ""
      If LoadXML(XML, file$)
        ; Display an error message if there was a markup error
        If XMLStatus(XML) <> #PB_XML_Success
          Message$ = "Error in the XML file:" + Chr(13)
          Message$ + "Message: " + XMLError(XML) + Chr(13)
          Message$ + "Line: " + Str(XMLErrorLine(XML)) + "   Character: " + Str(XMLErrorPosition(XML))
          MessageRequester("Error", Message$)
          MessageRequester("Error", "The file cannot be opened.")
          ProcedureReturn 0
        EndIf
        
        *MainNode = MainXMLNode(XML)
        If *MainNode
          XMLFile(*MainNode, -1, gadget, contents())
        EndIf
      EndIf
    Else
      MessageRequester("Error", "The file cannot be opened.")
      ProcedureReturn  0
    EndIf
    
  ElseIf LCase(GetExtensionPart(file$)) = "sum"
    If FileSize(file$) > 0
      f = ReadFile(#PB_Any, file$)
      If f
        ; format = ReadStringFormat(f)
        format = #PB_UTF8; a bug somewhere in ReadStringFormat or createfile
        line$  = ReadString(f, format);needed because of the BOM
        While Eof(f) = 0
          line$ = ReadString(f, format)
          If line$ = "+":level + 1
          ElseIf line$ = "-":level - 1
          Else
            AddElement(contents())
            contents()\Node  = line$
            contents()\Level = level
            AddGadgetItem(gadget, - 1, line$, 0, level)
            line$ = ReadString(f, format)
            If line$ = "+":level + 1
            ElseIf line$ = "-":level - 1
            Else
              contents()\Path = PathHTML$ + line$
              contents()\Link = "file://" + PathHTML$ + line$
              contents()\Link = ReplaceString(contents()\Link, "\", "/")
            EndIf
          EndIf
        Wend
        CloseFile(f)
      EndIf
    EndIf
    
  ElseIf LCase(GetExtensionPart(file$)) = "hhc"
    Fill_hhc(gadget, file$)
  EndIf
  
  If Summary3D
    SetMenuItemState(#MainForm_ToolBar_OptionPopUp, #ToolBar_OptionPopUp_SummaryMesa, #True)
    SetMenuItemState(#MainForm_ToolBar_OptionPopUp, #ToolBar_OptionPopUp_SummaryDefault, #False)
  EndIf
  
EndProcedure

;Fill the listviewgadget with an index ((*.xml or *.ind) file in the index tab
Procedure FillIndex(gadget, Index$)
  Protected f, format, level = - 1, XML
  Protected file$, line$, Message$
  Protected *MainNode
  
  ClearGadgetItems(gadget)
  ClearList(index())
  
  ;Open xml
  file$ = Index$
  If LCase(GetExtensionPart(file$)) = "xml"
    If file$ <> ""
      If LoadXML(XML, file$)
        ; Display an error message if there was a markup error
        If XMLStatus(XML) <> #PB_XML_Success
          Message$ = "Error in the XML file:" + Chr(13)
          Message$ + "Message: " + XMLError(XML) + Chr(13)
          Message$ + "Line: " + Str(XMLErrorLine(XML)) + "   Character: " + Str(XMLErrorPosition(XML))
          MessageRequester("Error", Message$)
          MessageRequester("Error", "The file cannot be opened.")
          ProcedureReturn 0
        EndIf
        
        *MainNode = MainXMLNode(XML)
        If *MainNode
          XMLFile(*MainNode, -1, gadget, index())
        EndIf
      EndIf
     
      ; Sort ascending
      SortStructuredList(index(), #PB_Sort_Ascending, OffsetOf(Struct_Contents\Node), TypeOf(Struct_Contents\Node))
      
      ; Attention, some character like "|" have an ascii code > "z", so let's move them on the top.
      LastElement(index())
      While Asc(index()\Node) > Asc("Z")
        MoveElement(index(), #PB_List_First )
        LastElement(index())
      Wend
      
      ;Fill the treeview
      ForEach index()
        AddGadgetItem(gadget, - 1, index()\Node)
      Next
    Else
      MessageRequester("Error", "The file cannot be opened.")
      ProcedureReturn  0
    EndIf
    
  ElseIf LCase(GetExtensionPart(file$)) = "ind"
    If FileSize(file$) > 0
      f = ReadFile(#PB_Any, file$, #PB_UTF8)
      If f
        line$ = ReadString(f);needed because of the BOM
        While Eof(f) = 0
          line$ = ReadString(f)
          AddElement(index())
          index()\Node    = line$
          line$           = ReadString(f)
          index()\Path    = line$
          index()\Link    = "file://" + PathHTML$ + line$
          index()\Link = ReplaceString(index()\Link, "\", "/")
        Wend
        CloseFile(f)
      EndIf
    EndIf
    
    ; Sort ascending
    SortStructuredList(index(), #PB_Sort_Ascending, OffsetOf(Struct_Contents\Node), TypeOf(Struct_Contents\Node))
    
    ; Attention, some character like "|" have an ascii code > "z", so let's move them on the top.
    LastElement(index())
    While Asc(index()\Node) > Asc("Z")
      MoveElement(index(), #PB_List_First )
      LastElement(index())
    Wend

    ;Fill the treeview
    ForEach index()
      AddGadgetItem(gadget, - 1, index()\Node)
    Next
    
  ElseIf LCase(GetExtensionPart(file$)) = "hhk"
    Fill_hhk(#listview_index, file$)
  EndIf
  
EndProcedure

Procedure MakeXMLFromHHC(openfile$, savefile$, overwrite = #False)
  ;TODO 
EndProcedure

; Make a Summary file from an HHC file
Procedure MakeSummaryFromHHC(openfile$, savefile$, overwrite = #False)
  Protected level, f, format, diff, CurrentLevel, i
  Protected contentsFile$, tmp$, tmpp$, tmppp$
  Protected message
  
  If openfile$ = "":ProcedureReturn 0:EndIf
  If savefile$ = "":ProcedureReturn 0:EndIf
  If FileSize(openfile$) <= 0:ProcedureReturn 0:EndIf
  If GetExtensionPart(savefile$) = "":savefile$ + ".sum":EndIf
  If FileSize(savefile$) >= 0 And overwrite = #False
    message = MessageRequester(Language::Get("Requesters", "Savefile"), Language::Get("Requesters", "Overwrite"), #PB_MessageRequester_YesNoCancel | #PB_MessageRequester_Info)
    Select message
      Case #PB_MessageRequester_Yes
        ;continue
      Case #PB_MessageRequester_No
        ;TODO re launch a requester
        ProcedureReturn 0
      Case #PB_MessageRequester_Cancel
        ProcedureReturn 0
    EndSelect
  EndIf
  
  NewList tmp_contents.Struct_Contents()
  
  level  = 0
  tmppp$ = ~"\">"
  level  = 0
  f      = ReadFile(#PB_Any, openfile$)
  
  If f
    format = ReadStringFormat(f)
    
    Repeat; jump to the first "<UL>"
      tmp$ = ReadString(f, format)
    Until FindString(tmp$, "<UL>") > 0
    
    While Eof(f) = 0
      
      tmp$ = ReadString(f, format)
      
      tmpp$ = ~"<param name=\"Name\" value=\""
      If FindString(tmp$, tmpp$)
        tmp$ = RemoveString(tmp$, tmpp$)
        tmp$ = RemoveString(tmp$, tmppp$)
        AddElement(tmp_contents())
        tmp_contents()\Node  = Trim(tmp$)
        tmp_contents()\Level = level
        Continue
      EndIf
      
      tmpp$ = ~"<param name=\"Local\" value=\""
      If FindString(tmp$, tmpp$)
        tmp$                 = RemoveString(tmp$, tmpp$)
        tmp$                 = RemoveString(tmp$, tmppp$)
        tmp_contents()\Path  = Trim(tmp$)
        tmp_contents()\Link  = ReplaceString("file://" + PathHTML$ + Trim(tmp$), "\", "/")
        tmp_contents()\Level = level
        Continue
      EndIf
      
      If FindString(tmp$, "</UL>")
        level = level - 1
        Continue
      EndIf
      
      If FindString(tmp$, "<UL>")
        level = level + 1
        Continue
      EndIf
    Wend
    CloseFile(f)
  Else
    ProcedureReturn 0
  EndIf
  
  f = CreateFile(#PB_Any, savefile$, #PB_UTF8)
  
  If FileSize(savefile$) = 0
    WriteStringFormat(f, #PB_UTF8)
    WriteStringN(f, ";Table of Contents", #PB_UTF8)
    WriteStringN(f, "+", #PB_UTF8)
    
    ForEach contents()
      diff = contents()\Level - CurrentLevel
      If diff = 0
        WriteStringN(f, contents()\Node, #PB_UTF8)
        WriteStringN(f, contents()\Path, #PB_UTF8)
      ElseIf diff < 0
        CurrentLevel = contents()\Level
        For i = 0 To Abs(diff) - 1
          WriteStringN(f, "-")
        Next i
        WriteStringN(f, contents()\Node, #PB_UTF8)
        WriteStringN(f, contents()\Path, #PB_UTF8)
      ElseIf diff > 0
        CurrentLevel = contents()\Level
        For i = 0 To diff - 1
          WriteStringN(f, "+")
        Next i
        WriteStringN(f, contents()\Node, #PB_UTF8)
        WriteStringN(f, contents()\Path, #PB_UTF8)
      EndIf
    Next
  Else
    ProcedureReturn 0
    CloseFile(f)
  EndIf
  
  ProcedureReturn 1
  
EndProcedure

; Make an index file from an HHK file
Procedure MakeIndexFromHHK(openfile$, savefile$, overwrite = #False)
  Protected f, indexFile$, message
  Protected tmppp$, tmp$, tmpp$
  
  If openfile$ = "":ProcedureReturn 0:EndIf
  If savefile$ = "":ProcedureReturn 0:EndIf
  If FileSize(openfile$) <= 0:ProcedureReturn 0:EndIf
  If GetExtensionPart(savefile$) = "":savefile$ + ".ind":EndIf
  If FileSize(savefile$) >= 0 And overwrite = #False
    message = MessageRequester(Language::Get("Requesters", "Savefile"), Language::Get("Requesters", "Overwrite"), #PB_MessageRequester_YesNoCancel | #PB_MessageRequester_Info)
    Select message
      Case #PB_MessageRequester_Yes
        ;continue
      Case #PB_MessageRequester_No
        ;TODO re-launch a requester
        ProcedureReturn 0
      Case #PB_MessageRequester_Cancel
        ProcedureReturn 0
    EndSelect
  EndIf
  
  NewList tmp_contents.Struct_Contents()
  
  f = ReadFile(#PB_Any, openfile$, #PB_UTF8)
  
  If f
    tmppp$ = ~"\">"
    While Eof(f) = 0
      tmp$  = ReadString(f)
      tmpp$ = ~"<param name=\"Name\" value=\""
      If FindString(tmp$, tmpp$)
        tmp$ = RemoveString(tmp$, tmpp$)
        tmp$ = RemoveString(tmp$, tmppp$)
        AddElement(tmp_contents())
        tmp_contents()\Node = Trim(tmp$)
        Continue
      EndIf
      tmpp$ = ~"<param name=\"Local\" value=\""
      If FindString(tmp$, tmpp$)
        tmp$                = RemoveString(tmp$, tmpp$)
        tmp$                = RemoveString(tmp$, tmppp$)
        tmp_contents()\Path = Trim(tmp$)
        tmp_contents()\Link = ReplaceString("file://" + PathHTML$ + Trim(tmp$), "\", "/")
        Continue
      EndIf
    Wend
    CloseFile(f)
  Else
    ProcedureReturn 0
  EndIf
  
  ; Sort ascending
  SortStructuredList(index(), #PB_Sort_Ascending, OffsetOf(Struct_Contents\Node), TypeOf(Struct_Contents\Node))
  
  ; Attention, some character like "|" have an ascii code > "z", so let's move them on the top.
  LastElement(index())
  While Asc(index()\Node) > Asc("Z")
    MoveElement(index(), #PB_List_First )
    LastElement(index())
  Wend
  
  ; &amp;
  ForEach index()
    If index()\Node = "&amp;"
      index()\Node = "&"
      Break
    EndIf
  Next
  
  f = CreateFile(#PB_Any, savefile$, #PB_UTF8)
  
  If FileSize(savefile$) = 0
    
    WriteStringFormat(f, #PB_UTF8)
    WriteStringN(f, ";Index", #PB_UTF8)
    
    ForEach Index()
      WriteStringN(f, Index()\Node, #PB_UTF8)
      WriteStringN(f, Index()\Path, #PB_UTF8)
    Next
    CloseFile(f)
  Else
    ProcedureReturn 0
  EndIf
  
  ProcedureReturn 1
  
EndProcedure

;-
;- IMAGES
;- ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
;Set/load icons for toolbar and treegadget
Procedure Images()
  
  ;Toolbar
  SetGadgetAttribute(#Maskpanel, #PB_Button_Image, LoadImage(#im_image_Maskpanel, Icons$ + "Maskpanel" + #PS$ + "#im_buttonimage_Maskpanel.png"))
  SetGadgetAttribute(#Maskpanel, #PB_Button_PressedImage, LoadImage(#im_imagepressed_Maskpanel, Icons$ + "Maskpanel" + #PS$ + "#im_buttonimagepressed_Maskpanel.png"))
  SetGadgetAttribute(#Previous, #PB_Button_Image, LoadImage(#im_buttonimage_Previous, Icons$ + "Previous" + #PS$ + "#im_buttonimage_Previous.png"))
  SetGadgetAttribute(#Next, #PB_Button_Image, LoadImage(#im_buttonimage_Next, Icons$ + "Next" + #PS$ + "#im_buttonimage_Next.png"))
  SetGadgetAttribute(#Home, #PB_Button_Image, LoadImage(#im_buttonimage_Home, Icons$ + "Home" + #PS$ + "#im_buttonimage_Home.png"))
  SetGadgetAttribute(#Print, #PB_Button_Image, LoadImage(#im_buttonimage_Print, Icons$ + "Print" + #PS$ + "#im_buttonimage_Print.png"))
  SetGadgetAttribute(#Search, #PB_Button_Image, LoadImage(#im_buttonimage_Search, Icons$ + "Search" + #PS$ + "#im_buttonimage_Search.png"))
  SetGadgetAttribute(#Options, #PB_Button_Image, LoadImage(#im_buttonimage_Options, Icons$ + "Options" + #PS$ + "#im_buttonimage_Options.png"))
  
  ;Tree
  LoadImage(#im_tree_BookClosed, Icons$ + "tree_summary" + #PS$ + "#im_tree_book_closed.png")
  LoadImage(#im_tree_BookOpen, Icons$ + "tree_summary" + #PS$ + "#im_tree_book_open.png")
  LoadImage(#im_tree_Books, Icons$ + "tree_summary" + #PS$ + "#im_tree_books.png")
  LoadImage(#im_tree_File, Icons$ + "tree_summary" + #PS$ + "#im_tree_file.png")
  
EndProcedure

;-
;- MISC.
;- ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
; Trick to refresh the main dialog
Procedure RefreshDialog2()
  Protected old = GetGadgetState(#splitter)
  
  RefreshDialog(1)
  SetGadgetState(#splitter, 100)
  RefreshDialog(1)
  SetGadgetState(#splitter, old)
  
EndProcedure

; On Windows, we use a webgadget for the compatibility with Windows XP but on linux & osx, we use a webviewgadget
Procedure SwitchWebGadget(web = #True, firsttime = #True)
  
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      WebDisplay = #web
      If OSVersion() < #PB_OS_Windows_10
        ProcedureReturn - 1
      Else
        If firsttime
          ProcedureReturn 0
        EndIf
        If web
          HideGadget(#webview, #True)
          HideGadget(#web, #False)
        Else
          HideGadget(#web, #True)
          HideGadget(#webview, #False)
        EndIf
        
      EndIf
      ;   CompilerCase #PB_OS_Linux
      ;   CompilerCase #PB_OS_MacOS
    CompilerDefault
      WebDisplay = #webview
      If firsttime:web = 0:EndIf
      If web
        HideGadget(#webview, #True)
        HideGadget(#web, #False)
      Else
        HideGadget(#web, #True)
        HideGadget(#webview, #False)
      EndIf
  CompilerEndSelect
  
EndProcedure

;Fix wrong display with underscored text in TextGadget, Windows only
Procedure UnderscoreTextGadget()
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      SetWindowLongPtr_(GadgetID(#text_index), #GWL_STYLE, GetWindowLongPtr_(GadgetID(#text_index), #GWL_STYLE) & ~#SS_NOPREFIX)
      SetGadgetText(#text_index, GetGadgetText(#text_index))
      SetWindowLongPtr_(GadgetID(#text_search), #GWL_STYLE, GetWindowLongPtr_(GadgetID(#text_search), #GWL_STYLE) & ~#SS_NOPREFIX)
      SetGadgetText(#text_search, GetGadgetText(#text_search))
      SetWindowLongPtr_(GadgetID(#text_selectsection), #GWL_STYLE, GetWindowLongPtr_(GadgetID(#text_selectsection), #GWL_STYLE) & ~#SS_NOPREFIX)
      SetGadgetText(#text_selectsection, GetGadgetText(#text_selectsection))
      SetWindowLongPtr_(GadgetID(#text_favorite), #GWL_STYLE, GetWindowLongPtr_(GadgetID(#text_favorite), #GWL_STYLE) & ~#SS_NOPREFIX)
      SetGadgetText(#text_favorite, GetGadgetText(#text_favorite))
      SetWindowLongPtr_(GadgetID(#text_sectioncurrent), #GWL_STYLE, GetWindowLongPtr_(GadgetID(#text_sectioncurrent), #GWL_STYLE) & ~#SS_NOPREFIX)
      SetGadgetText(#text_sectioncurrent, GetGadgetText(#text_sectioncurrent))
    CompilerCase #PB_OS_MacOS
      ; TODO if needed
    CompilerCase #PB_OS_Linux
      ; TODO if needed
  CompilerEndSelect
  
EndProcedure

;Needed to put big icons in the treegadget, Windows only
Procedure SetWindowsTheme()
  
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    If OSVersion() > #PB_OS_Windows_2000
      OpenLibrary(0, "uxtheme.dll")
      CallFunction(0, "SetWindowTheme", GadgetID(#tree_summary), @" ", @" ")
      SetThemeAppProperties_(1)
      CloseLibrary(0)
    EndIf
  CompilerEndIf
  
EndProcedure

;Make a StringGadget sensitive to the return key : From mk-soft
Procedure DoEventStringGadget()
   Protected gadget = EventGadget()
  If IsGadget(gadget)
    Select GadgetType(gadget)
      Case #PB_GadgetType_String
        Select EventType()
          Case  #PB_EventType_ReturnKey
            OnClick_button_searchlist(); Launch a search
          Case #PB_EventType_Focus
            CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
              ; Bugfix macOS event order with 'tab' key
              If EventData() = #False
                PostEvent(#PB_Event_Gadget, EventWindow(), EventGadget(), #PB_EventType_Focus, #True)
              Else
                AddKeyboardShortcut(DialogWindow(1), #PB_Shortcut_Return, #MenuEvent_ReturnKey)
              EndIf
            CompilerElse
              AddKeyboardShortcut(DialogWindow(1), #PB_Shortcut_Return, #MenuEvent_ReturnKey)
            CompilerEndIf
          Case #PB_EventType_LostFocus
            RemoveKeyboardShortcut(DialogWindow(1), #PB_Shortcut_Return)
        EndSelect
    EndSelect
  EndIf
EndProcedure

;launched after after a pressed Return key in a stringgadget
Procedure DoEventReturnKey()
  PostEvent(#PB_Event_Gadget, GetActiveWindow(), GetActiveGadget(), #PB_EventType_ReturnKey)
EndProcedure

;Init a menu to  launch the procedure StringGReturnKey() after a pressed Return key in a StringGadget
Procedure StringGReturnKeyInit()
  MenuReturnKey = CreateMenu(#PB_Any, WindowID(DialogWindow(1)))
  BindGadgetEvent(#string_Search, @DoEventStringGadget())
  BindMenuEvent(MenuReturnKey, #MenuEvent_ReturnKey, @DoEventReturnKey()) 
EndProcedure

;Used on Windows XP to search strings in html file using the search box
Procedure SendKeys(handle, window$, keys$)
  
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      ;ex w$="Search":SendKeys(0,w$,"{TAB}"):SendKeys(0,w$,"{ENTER}")
      
      Protected thread1, thread2, r, vk$, s, s$, vk, shifted
      Protected t1.q, t2.q
      
      If window$ <> "" :handle = FindWindow_(0, window$):EndIf
      
      If IsWindow_(handle) = 0
        ProcedureReturn 0
      Else
        ; This block gives the target window the focus before typing.
        thread1 = GetWindowThreadProcessId_(GetForegroundWindow_(), 0)
        thread2 = GetWindowThreadProcessId_(handle, 0)
        If thread1 <> thread2 : AttachThreadInput_(thread1, thread2, #True) : EndIf
        SetForegroundWindow_(handle) ; Target window now has the focus for typing.
        Delay(125)                   ; 1/8 second pause before typing, to prevent fast CPU problems.
                                     ; Now the actual typing starts.
        For r = 1 To Len(keys$)
          vk$ = Mid(keys$, r, 1)
          If vk$ = "{" ; Special key found.
            s  = FindString(keys$, "}", r + 1) - (r + 1) ; Get length of special key.
            s$ = Mid(keys$, r + 1, s)                    ; Get special key name.
            Select s$                                    ; Get virtual key code of special key.
              Case "ALTDOWN" : keybd_event_(#VK_MENU, 0, 0, 0) ; Hold ALT down.
              Case "ALTUP" : keybd_event_(#VK_MENU, 0, #KEYEVENTF_KEYUP, 0) ; Release ALT.
              Case "BACKSPACE" : vk = #VK_BACK
              Case "CONTROLDOWN" : keybd_event_(#VK_CONTROL, 0, 0, 0) ; Hold CONTROL down.
              Case "CONTROLUP" : keybd_event_(#VK_CONTROL, 0, #KEYEVENTF_KEYUP, 0) ; Release CONTROL.
              Case "DELETE" : vk = #VK_DELETE
              Case "DOWN" : vk = #VK_DOWN
              Case "END" : vk = #VK_END
              Case "ENTER" : vk = #VK_RETURN
              Case "F1" : vk = #VK_F1
              Case "F2" : vk = #VK_F2
              Case "F3" : vk = #VK_F3
              Case "F4" : vk = #VK_F4
              Case "F5" : vk = #VK_F5
              Case "F6" : vk = #VK_F6
              Case "F7" : vk = #VK_F7
              Case "F8" : vk = #VK_F8
              Case "F9" : vk = #VK_F9
              Case "F10" : vk = #VK_F10
              Case "F11" : vk = #VK_F11
              Case "F12" : vk = #VK_F12
              Case "ESCAPE" : vk = #VK_ESCAPE
              Case "HOME" : vk = #VK_HOME
              Case "INSERT" : vk = #VK_INSERT
              Case "LEFT" : vk = #VK_LEFT
              Case "PAGEDOWN" : vk = #VK_NEXT
              Case "PAGEUP" : vk = #VK_PRIOR
              Case "PRINTSCREEN" : vk = #VK_SNAPSHOT
              Case "RETURN" : vk = #VK_RETURN
              Case "RIGHT" : vk = #VK_RIGHT
              Case "SHIFTDOWN" : shifted = 1 : keybd_event_(#VK_SHIFT, 0, 0, 0) ; Hold SHIFT down.
              Case "SHIFTUP" : shifted = 0 : keybd_event_(#VK_SHIFT, 0, #KEYEVENTF_KEYUP, 0) ; Release SHIFT.
              Case "TAB" : vk = #VK_TAB
              Case "UP" : vk = #VK_UP
            EndSelect
            If Left(s$, 3) <> "ALT" And Left(s$, 7) <> "CONTROL" And Left(s$, 5) <> "SHIFT"
              keybd_event_(vk, 0, 0, 0) : keybd_event_(vk, 0, #KEYEVENTF_KEYUP, 0) ; Press the special key.
            EndIf
            r = r + s + 1 ; Continue getting the keystrokes that follow the special key.
          Else
            vk = VkKeyScanEx_(Asc(vk$), GetKeyboardLayout_(0)) ; Normal key found.
            If vk > 304 And shifted = 0 : keybd_event_(#VK_SHIFT, 0, 0, 0) : EndIf ; Due to shifted character.
            keybd_event_(vk, 0, 0, 0) : keybd_event_(vk, 0, #KEYEVENTF_KEYUP, 0)   ; Press the normal key.
            If vk > 304 And shifted = 0 : keybd_event_(#VK_SHIFT, 0, #KEYEVENTF_KEYUP, 0) : EndIf ; Due to shifted character.
          EndIf
        Next
        If thread1 <> thread2 : AttachThreadInput_(thread1, thread2, #False) : EndIf
        keybd_event_(#VK_MENU, 0, #KEYEVENTF_KEYUP, 0)
        keybd_event_(#VK_CONTROL, 0, #KEYEVENTF_KEYUP, 0)
        keybd_event_(#VK_SHIFT, 0, #KEYEVENTF_KEYUP, 0)
        ProcedureReturn 1
      EndIf
      
      ;     CompilerCase #PB_OS_Linux
      ;     CompilerCase #PB_OS_MacOS
      ;     CompilerDefault
      
  CompilerEndSelect
  
EndProcedure


;-
;- LANG
;- ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
; Set Language texts for "toolbar" and gadgets
Procedure Translate()
  
  ; "Toolbar" (gadgets)
  SetGadgetText(#text_Maskpanel, Language::Get("ToolBar", "Hide"))
  SetGadgetText(#text_previous, Language::Get("ToolBar", "Previous"))
  SetGadgetText(#text_Next, Language::Get("ToolBar", "Next"))
  SetGadgetText(#text_Home, Language::Get("ToolBar", "Home"))
  SetGadgetText(#text_Print, Language::Get("ToolBar", "Print"))
  SetGadgetText(#text_Searches, Language::Get("ToolBar", "Search"))
  SetGadgetText(#text_Options, Language::Get("ToolBar", "Options"))
  
  ; Left panel
  SetGadgetItemText(#panel, 0, Language::Get("Gadgets", "Summary"))
  
  SetGadgetItemText(#panel, 1, Language::Get("Gadgets", "Index"))
  SetGadgetText(#text_index, Language::Get("Gadgets", "SearchWord"))
  SetGadgetText(#button_index, Language::Get("Gadgets", "Display"))
  
  SetGadgetItemText(#panel, 2, Language::Get("Gadgets", "Search"))
  SetGadgetText(#text_search, Language::Get("Gadgets", "SearchWord"))
  SetGadgetText(#button_searchlist, Language::Get("Gadgets", "ListRubric"))
  SetGadgetText(#text_selectsection, Language::Get("Gadgets", "Selrubric"))
  SetGadgetText(#button_search, Language::Get("Gadgets", "Display"))
  
  SetGadgetItemText(#panel, 3, Language::Get("Gadgets", "Favorite"))
  SetGadgetText(#text_favorite, Language::Get("Gadgets", "Rubric"))
  SetGadgetText(#button_favoritedel, Language::Get("Gadgets", "Delete"))
  SetGadgetText(#button_favorite, Language::Get("Gadgets", "Display"))
  SetGadgetText(#text_sectioncurrent, Language::Get("Gadgets", "RubricIn"))
  SetGadgetText(#button_favoriteadd, Language::Get("Gadgets", "Add"))
  
  RefreshDialog2()
  
EndProcedure

; Set glogbal path (needed if u change the language on the fly)
Procedure SetPathLang()
  
  PathHTMLHD$ = PathHelp$ + UserLanguage$ + "/"
  PathHTML$   = PathHelp$ + UserLanguage$ + "/"
  
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      PathHTML$   = ReplaceString(PathHTML$, "\", "/")
      PathHTMLHD$ = PathHTML$
  CompilerEndSelect
  
EndProcedure

; Set the correct summary file according to the language
Procedure SetSummaryLang(changed = #False)
  Protected problem = 0
  
  DefaultSummary = PathHelpHD$ + UserLanguage$ + #PS$ + "contents.xml"
  ;TO DO MesaSummary = PathHelpHD$ + UserLanguage$ + #PS$ + "contents3D.xml";Path$ + "Summary_" + UserLanguage$ + "_3D.sum"
  MesaSummary = PathHelpHD$ + "Summary_" + UserLanguage$ + "_3D.sum"
  
  If Summary3D
    CurrentSummary = MesaSummary
  EndIf
  If CurrentSummary = ""
    CurrentSummary = DefaultSummary
  EndIf
  If FileSize(CurrentSummary)
  Else
    MessageRequester(Language::Get("Requesters", "Failed"), Language::Get("Requesters", "ContentsCorrupted"), #PB_MessageRequester_Warning)
  EndIf
  
  
EndProcedure

; Set language to GUI and summary
Procedure Setlang(changed = #False)
  
  FindUserLanguage(); Load Language file
  Translate()       ; Set language in gadgets
  SetPathLang()     ; Modify path directories
  SetSummaryLang(changed)  ; Set the right summary
  DefaultIndex = PathHelpHD$ + UserLanguage$ + #PS$ + "index.xml"
  ClearList(Searched_FilesSize())
  Select UserLanguage$
    Case "fr"
      CopyList(Searched_FilesSizefr(),Searched_FilesSize())
    Case "en"
      CopyList(Searched_FilesSizeen(),Searched_FilesSize())
    Case "de"
      CopyList(Searched_FilesSizede(),Searched_FilesSize())
  EndSelect
EndProcedure

;-
;- SPLITTER
;- ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
; Set the splitter pos according to the preferences
Procedure InitSplitter()
  
  SetGadgetState(#splitter, Val(Preferences("xsplitter")))
  
EndProcedure

;-
;- SUMMARY TREE
;- ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
;  WIN ONLY

;Set Icons in the summary tree: book open/book closed & file
Procedure TreeParentChild(Tree)
  Protected i, n = CountGadgetItems(Tree)
  Dim tab(n)
  
  For i = 0 To n - 1
    tab(i) = GetGadgetItemAttribute(Tree, i, #PB_Tree_SubLevel)
  Next i
  
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      Protected ImageSelect
      Protected iinf.ICONINFO, tvi.TV_ITEM
      Protected bookopen, bookclosed, bfiles, books
      
      ;       IconSize   = Val(Preferences("iconsize"));32
      iinf\fIcon = 1
      ; iinf\xHotspot = IconSize
      ; iinf\yHotspot = IconSize
      iinf\hbmMask  = ImageID(#im_tree_File)
      iinf\hbmColor = ImageID(#im_tree_File)
      bfiles        = CreateIconIndirect_(iinf)
      iinf\hbmMask  = ImageID(#im_tree_BookClosed)
      iinf\hbmColor = ImageID(#im_tree_BookClosed)
      bookclosed    = CreateIconIndirect_(iinf)
      iinf\hbmMask  = ImageID(#im_tree_BookOpen)
      iinf\hbmColor = ImageID(#im_tree_BookOpen)
      bookopen      = CreateIconIndirect_(iinf)
      iinf\hbmMask  = ImageID(#im_tree_Books)
      iinf\hbmColor = ImageID(#im_tree_Books)
      books         = CreateIconIndirect_(iinf)
      
      ImageList = ImageList_Create_(IconSize, IconSize, #ILC_COLOR32 | #ILC_MASK , 0, 10)
      ;0=The number of images that the image list initially contains.
      ;10=This parameter represents the number of new images that the resized image list can contain.
      ImageList_AddIcon_(ImageList, bfiles)
      ImageList_AddIcon_(ImageList, bookclosed)
      ImageList_AddIcon_(ImageList, bookopen)
      ImageList_AddIcon_(ImageList, books)
      
      SendMessage_(GadgetID(tree), #TVM_SETIMAGELIST, #TVSIL_NORMAL, ImageList)
      
      tvi\mask = #TVIF_HANDLE | #TVIF_IMAGE | #TVIF_SELECTEDIMAGE;
      
      For i = 0 To n - 2
        If tab(i + 1) > tab(i)
          ;                 SetGadgetItemImage(Tree,i,ImageID(#im_tree_BookClosed))
          tvi\hItem          = GadgetItemID(Tree, i)
          tvi\iImage         = 1
          tvi\iSelectedImage = 1
          SendMessage_(GadgetID(Tree), #TVM_SETITEM, 0, tvi)
          SetGadgetItemData(Tree, i, 1)
        Else
          ;           SetGadgetItemImage(Tree,i,ImageID(#im_tree_File))
          tvi\hItem          = GadgetItemID(Tree, i)
          tvi\iImage         = 0
          tvi\iSelectedImage = 0
          SendMessage_(GadgetID(Tree), #TVM_SETITEM, 0, tvi)
        EndIf
        
      Next i
      
      ;     CompilerCase #PB_OS_Linux
      ;     CompilerCase #PB_OS_MacOS
      
    CompilerDefault
      For i = 0 To n - 2
        If tab(i + 1) > tab(i)
          SetGadgetItemImage(Tree, i, ImageID(#im_tree_BookClosed))
          SetGadgetItemData(Tree, i, 1)
        Else
          SetGadgetItemImage(Tree, i, ImageID(#im_tree_File))
        EndIf
        
      Next i
      SetGadgetItemImage(Tree, n - 1, ImageID(#im_tree_File))
  CompilerEndSelect
  
EndProcedure

;Update icons in the summary tree. Needed with expand/collapse functions
Procedure TreeSetItemIcon(gadget, item, nicon)
  
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      Protected tvi.TV_ITEM
      tvi\mask           = #TVIF_HANDLE | #TVIF_IMAGE | #TVIF_SELECTEDIMAGE
      tvi\hItem          = GadgetItemID(gadget, item)
      tvi\iImage         = nicon
      tvi\iSelectedImage = nicon
      SendMessage_(GadgetID(gadget), #TVM_SETITEM, 0, tvi)
      
      ;     CompilerCase #PB_OS_Linux
      ;     CompilerCase #PB_OS_MacOS
      
    CompilerDefault
      Select nicon
        Case 0
          SetGadgetItemImage(gadget, item, ImageID(#im_tree_File))
        Case 1
          SetGadgetItemImage(gadget, item, ImageID(#im_tree_BookClosed))
        Case 2
          SetGadgetItemImage(gadget, item, ImageID(#im_tree_BookOpen))
        Case 3
          SetGadgetItemImage(gadget, item, ImageID(#im_tree_Books))
      EndSelect
      CompilerEndSelect
      
    EndProcedure
    
    ;Set items colors from the Preference file
    Procedure TreeItemColorInit()
      
      ; Keep original color (don't sure that works because of theme on windows, at least)
      SetGadgetState(#tree_summary, 0)
      If GetGadgetState(#tree_summary) >= 0
        ItemColorTxt = GetGadgetItemColor(#tree_summary, 0, #PB_Gadget_FrontColor)
        ItemColorBkg = GetGadgetItemColor(#tree_summary, 0, #PB_Gadget_BackColor)
      EndIf
      ;TODO Don't use ItemColor()\item but search the right url
      ForEach ItemColor()
        If ItemColor()\textcolor > -1
          SetGadgetItemColor(#tree_summary, ItemColor()\item, #PB_Gadget_FrontColor,ItemColor()\textcolor)
        EndIf
        If ItemColor()\bkgcolor
          SetGadgetItemColor(#tree_summary, ItemColor()\item, #PB_Gadget_BackColor, ItemColor()\bkgcolor)
        EndIf
      Next
      
    EndProcedure
    
    ;Update items colors to the Preference file
    Procedure TreeUpdateItemsColors()
      Protected i
      
      ;       If OpenPreferences(Preference$, #PB_Preference_GroupSeparator)
      RemovePreferenceGroup("COLOREDITEMS")
      FlushPreferenceBuffers()
      PreferenceGroup("COLOREDITEMS")
      SortStructuredList(ItemColor(), #PB_Sort_Ascending , OffsetOf(ColorItem\item), #PB_Integer)
      ForEach ItemColor()
        WritePreferenceString(Str(ItemColor()\item), Str(ItemColor()\textcolor)+","+Str(ItemColor()\bkgcolor))
      Next 
      FlushPreferenceBuffers()
      ;         ClosePreferences()
      ;       EndIf
      
    EndProcedure
    ;-
    ;- MENU
    ;- ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    
    ;- ToolBar Menu
    ;Stop web page: Menu #ToolBar_OptionPopUp_Stop
    Procedure Stop()
      
      CompilerSelect #PB_Compiler_OS
        CompilerCase #PB_OS_Windows
          SetGadgetState(#web, #PB_Web_Stop)
          
          ;   CompilerCase #PB_OS_Linux
          ;   CompilerCase #PB_OS_MacOS
          
        CompilerDefault
          Protected Controller.ICoreWebView2Controller = GetGadgetAttribute(#webview, #PB_WebView_ICoreController)
          Protected Core.ICoreWebView2
          Controller\get_CoreWebView2(@Core)
          Core\Stop()
      CompilerEndSelect
      
    EndProcedure
    
    ;Refresh web page:Menu #ToolBar_OptionPopUp_Refresh
    Procedure Refresh()
      
      CompilerSelect #PB_Compiler_OS
        CompilerCase #PB_OS_Windows
          SetGadgetState(#web, #PB_Web_Refresh)
          
          ;   CompilerCase #PB_OS_Linux
          ;   CompilerCase #PB_OS_MacOS
          
        CompilerDefault
          Protected Controller.ICoreWebView2Controller = GetGadgetAttribute(#webview, #PB_WebView_ICoreController)
          Protected Core.ICoreWebView2
          Controller\get_CoreWebView2(@Core)
          Core\Reload()
      CompilerEndSelect
      
    EndProcedure
    
    ;Change font for all gadgets:Menu #ToolBar_OptionPopUp_Font
    Procedure Fonts()
      Protected Res = FontRequester("", 11, 0)
      Protected nf
      
      If Res
        nf = LoadFont(#PB_Any, SelectedFontName(), SelectedFontSize(), SelectedFontStyle())
        If nf
          Preferences("font")          = SelectedFontName()
          Preferences("fontsize")      = Str(SelectedFontSize())
          Preferences("fontstyle")     = Str(SelectedFontStyle())
          Preferences("fontlist")      = SelectedFontName()
          Preferences("fontsizelist")  = Str(SelectedFontSize())
          Preferences("fontstylelist") = Str(SelectedFontStyle())
        EndIf
      EndIf
      
      If nf
        SetGadgetFont(#text_Maskpanel, FontID(nf))
        SetGadgetFont(#text_previous, FontID(nf))
        SetGadgetFont(#text_Next, FontID(nf))
        SetGadgetFont(#text_Home, FontID(nf))
        SetGadgetFont(#text_Print, FontID(nf))
        SetGadgetFont(#text_Searches, FontID(nf))
        SetGadgetFont(#text_Options, FontID(nf))
        SetGadgetFont(#text_Zoom, FontID(nf))
        SetGadgetFont(#panel, FontID(nf))
        SetGadgetFont(#tree_summary, FontID(nf))
        SetGadgetFont(#tree_summarynoicons, FontID(nf))
        SetGadgetFont(#text_index, FontID(nf))
        SetGadgetFont(#string_index, FontID(nf))
        SetGadgetFont(#listview_index, FontID(nf))
        SetGadgetFont(#button_index, FontID(nf))
        SetGadgetFont(#text_search, FontID(nf))
        SetGadgetFont(#string_Search, FontID(nf))
        SetGadgetFont(#button_searchlist, FontID(nf))
        SetGadgetFont(#text_selectsection, FontID(nf))
        SetGadgetFont(#listview_search, FontID(nf))
        SetGadgetFont(#button_search, FontID(nf))
        SetGadgetFont(#text_favorite, FontID(nf))
        SetGadgetFont(#listview_favorite, FontID(nf))
        SetGadgetFont(#button_favoritedel, FontID(nf))
        SetGadgetFont(#button_favorite, FontID(nf))
        SetGadgetFont(#text_sectioncurrent, FontID(nf))
        SetGadgetFont(#string_favoritesectioncurrent, FontID(nf))
        SetGadgetFont(#button_favoriteadd, FontID(nf))
        
        RefreshDialog2()
        
      EndIf
      
    EndProcedure
    
    ; Change the font size only, for all gadgets:Menu #ToolBar_OptionPopUp_FontSizeOnly
    Procedure FontSizeOnly()
      Protected size, nf
      
      size = Val(InputRequester(Language::Get("Requesters", "TitleFontSize"), Language::Get("Requesters", "MessageFontSize"), ""))
      
      If size > 0
        nf                      = LoadFont(#PB_Any, "", size, 0)
        Preferences("fontsize") = Str(size)
      EndIf
      
      If nf
        SetGadgetFont(#text_Maskpanel, FontID(nf))
        SetGadgetFont(#text_previous, FontID(nf))
        SetGadgetFont(#text_Next, FontID(nf))
        SetGadgetFont(#text_Home, FontID(nf))
        SetGadgetFont(#text_Print, FontID(nf))
        SetGadgetFont(#text_Searches, FontID(nf))
        SetGadgetFont(#text_Options, FontID(nf))
        SetGadgetFont(#text_Zoom, FontID(nf))
        SetGadgetFont(#panel, FontID(nf))
        SetGadgetFont(#tree_summary, FontID(nf))
        SetGadgetFont(#tree_summarynoicons, FontID(nf))
        SetGadgetFont(#text_index, FontID(nf))
        SetGadgetFont(#string_index, FontID(nf))
        SetGadgetFont(#listview_index, FontID(nf))
        SetGadgetFont(#button_index, FontID(nf))
        SetGadgetFont(#text_search, FontID(nf))
        SetGadgetFont(#string_Search, FontID(nf))
        SetGadgetFont(#button_searchlist, FontID(nf))
        SetGadgetFont(#text_selectsection, FontID(nf))
        SetGadgetFont(#listview_search, FontID(nf))
        SetGadgetFont(#button_search, FontID(nf))
        SetGadgetFont(#text_favorite, FontID(nf))
        SetGadgetFont(#listview_favorite, FontID(nf))
        SetGadgetFont(#button_favoritedel, FontID(nf))
        SetGadgetFont(#button_favorite, FontID(nf))
        SetGadgetFont(#text_sectioncurrent, FontID(nf))
        SetGadgetFont(#string_favoritesectioncurrent, FontID(nf))
        SetGadgetFont(#button_favoriteadd, FontID(nf))
        
        RefreshDialog2()
        
      EndIf
      
    EndProcedure
    
    ;Change font only for treegadget and listviews:Menu #ToolBar_OptionPopUp_FontList
    Procedure FontList()
      
      Protected Res = FontRequester("Arial", 11, 0)
      Protected nf
      
      If Res
        nf = LoadFont(#PB_Any, SelectedFontName(), SelectedFontSize(), SelectedFontStyle())
        
        If nf
          SetGadgetFont(#tree_summary, FontID(nf))
          SetGadgetFont(#tree_summarynoicons, FontID(nf))
          SetGadgetFont(#listview_index, FontID(nf))
          SetGadgetFont(#listview_search, FontID(nf))
          SetGadgetFont(#listview_favorite, FontID(nf))
          
          TreeParentChild(#tree_summary)
          RefreshDialog2()
          
          Preferences("fontlist")      = SelectedFontName()
          Preferences("fontsizelist")  = Str(SelectedFontSize())
          Preferences("fontstylelist") = Str(SelectedFontStyle())
        EndIf
      EndIf
      
    EndProcedure
    
    ;Reset font to default for all gadgets:Menu #ToolBar_OptionPopUp_FontDefault
    Procedure FontDefault()
      Protected Colour
      
      SetGadgetFont(#text_Maskpanel, #PB_Default)
      SetGadgetFont(#text_previous, #PB_Default)
      SetGadgetFont(#text_Next, #PB_Default)
      SetGadgetFont(#text_Home, #PB_Default)
      SetGadgetFont(#text_Print, #PB_Default)
      SetGadgetFont(#text_Searches, #PB_Default)
      SetGadgetFont(#text_Options, #PB_Default)
      SetGadgetFont(#text_Zoom, #PB_Default)
      SetGadgetFont(#panel, #PB_Default)
      SetGadgetFont(#tree_summary, #PB_Default)
      SetGadgetFont(#tree_summarynoicons, #PB_Default)
      SetGadgetFont(#text_index, #PB_Default)
      SetGadgetFont(#string_index, #PB_Default)
      SetGadgetFont(#listview_index, #PB_Default)
      SetGadgetFont(#button_index, #PB_Default)
      SetGadgetFont(#text_search, #PB_Default)
      SetGadgetFont(#string_Search, #PB_Default)
      SetGadgetFont(#button_searchlist, #PB_Default)
      SetGadgetFont(#text_selectsection, #PB_Default)
      SetGadgetFont(#listview_search, #PB_Default)
      SetGadgetFont(#button_search, #PB_Default)
      SetGadgetFont(#text_favorite, #PB_Default)
      SetGadgetFont(#listview_favorite, #PB_Default)
      SetGadgetFont(#button_favoritedel, #PB_Default)
      SetGadgetFont(#button_favorite, #PB_Default)
      SetGadgetFont(#text_sectioncurrent, #PB_Default)
      SetGadgetFont(#string_favoritesectioncurrent, #PB_Default)
      SetGadgetFont(#button_favoriteadd, #PB_Default)
      RefreshDialog2()
      
      Colour = 0
      SetGadgetColor(#tree_summary, #PB_Gadget_FrontColor, Colour)
      SetGadgetColor(#tree_summarynoicons, #PB_Gadget_FrontColor, Colour)
      SetGadgetColor(#listview_index, #PB_Gadget_FrontColor, Colour)
      SetGadgetColor(#listview_search, #PB_Gadget_FrontColor, Colour)
      SetGadgetColor(#listview_favorite, #PB_Gadget_FrontColor, Colour)
      RefreshDialog2()
      
      
      Preferences("font")           = ""
      Preferences("fontsize")       = ""
      Preferences("fontstyle")      = ""
      Preferences("fontcolour")     = ""
      Preferences("fontlist")       = ""
      Preferences("fontsizelist")   = ""
      Preferences("fontstylelist")  = ""
      Preferences("fontcolourlist") = ""
      
    EndProcedure
    
    ;Change color font for lists only:FontListSizeOnly
    Procedure FontColourList()
      Protected Colour = ColorRequester()
      
      If Colour > - 1
        SetGadgetColor(#tree_summary, #PB_Gadget_FrontColor, Colour)
        SetGadgetColor(#tree_summarynoicons, #PB_Gadget_FrontColor, Colour)
        SetGadgetColor(#listview_index, #PB_Gadget_FrontColor, Colour)
        SetGadgetColor(#listview_search, #PB_Gadget_FrontColor, Colour)
        SetGadgetColor(#listview_favorite, #PB_Gadget_FrontColor, Colour)
        RefreshDialog2()
        
        Preferences("fontcolourlist") = Str(Colour)
        
      EndIf
      
    EndProcedure
    
    ;Change font size for lists only:Menu #ToolBar_OptionPopUp_FontColour
    Procedure FontListSizeOnly()
      Protected size, nf
      
      size = Val(InputRequester(Language::Get("Requesters", "TitleFontSize"), Language::Get("Requesters", "MessageFontSize"), ""))
      If size > 0
        nf = LoadFont(#PB_Any, "", Size, 0)
        If nf
          SetGadgetFont(#tree_summary, FontID(nf))
          SetGadgetFont(#tree_summarynoicons, FontID(nf))
          SetGadgetFont(#listview_index, FontID(nf))
          SetGadgetFont(#listview_search, FontID(nf))
          SetGadgetFont(#listview_favorite, FontID(nf))
          
          TreeParentChild(#tree_summary)
          RefreshDialog2()
          
          Preferences("fontsizelist") = Str(Size)
          
        EndIf
      EndIf
      
    EndProcedure
    
    ; Display the summary treegadget with icons or not:Menu #ToolBar_OptionPopUp_Icons
    Procedure IconsInSummary()
      
      If GetMenuItemState(#MainForm_ToolBar_OptionPopUp, #ToolBar_OptionPopUp_Icons) = #False
        SetMenuItemState(#MainForm_ToolBar_OptionPopUp, #ToolBar_OptionPopUp_Icons, #True)
        HideGadget(#tree_summary, #False )
        HideGadget(#tree_summarynoicons, #True)
        SetGadgetData(#tree_summarynoicons, #True)
      Else
        SetMenuItemState(#MainForm_ToolBar_OptionPopUp, #ToolBar_OptionPopUp_Icons, #False)
        HideGadget(#tree_summary, #True)
        HideGadget(#tree_summarynoicons, #False)
        SetGadgetData(#tree_summarynoicons, #False)
      EndIf
      
    EndProcedure
    
    ;Change de Icons Size (32x32 by default)
    Procedure IconsSize()
      Protected Size
      Protected Size$
      
      Size$ = InputRequester(Language::Get("Requesters", "IconsSizeReq"), Language::Get("Requesters", "IconsSizeReq2"), "")
      
      If Size$
        Size = Val(Size$)
        If Size <= 7
          MessageRequester(Language::Get("Requesters", "ATTENTION"), Language::Get("Requesters", "NoValid"), #PB_MessageRequester_Error)
        Else
          IconSize = Size
          TreeParentChild(#tree_summary)
        EndIf
      EndIf
      
    EndProcedure
    
    ;Display the default summary:Menu #ToolBar_OptionPopUp_SummaryDefault
    Procedure SummaryDefault()
      Protected F$ = DefaultSummary, i
      
      If FileSize(F$) > 0
        FillSummary(#tree_summary, F$)
        FillSummary(#tree_summarynoicons, F$)
        TreeParentChild(#tree_summary)
        TreeItemColorInit()
        CurrentSummary = DefaultSummary
        Summary3D      = 0
        For i = #ToolBar_OptionPopUp_SummaryDefault To #ToolBar_OptionPopUp_SummaryMesa
          SetMenuItemState(#MainForm_ToolBar_OptionPopUp, i, #False)
        Next i
        SetMenuItemState(#MainForm_ToolBar_OptionPopUp, #ToolBar_OptionPopUp_SummaryDefault, #True)
        TreeAllItemResetColor():ClearList(ItemColor()) 
      Else
        MessageRequester(Language::Get("Requesters", "Information"), Language::Get("Requesters", "Failed"), #PB_MessageRequester_Warning)
      EndIf
      
    EndProcedure
    
    ;Display the 3D summary (3D pb procedures are in their own directory):Menu #ToolBar_OptionPopUp_SummaryMesa
    Procedure SummaryMesa()
      Protected F$ = MesaSummary, i
      
      If FileSize(F$) > 0
        FillSummary(#tree_summary, F$)
        FillSummary(#tree_summarynoicons, F$)
        TreeParentChild(#tree_summary)
        TreeItemColorInit()
        CurrentSummary = F$
        Summary3D      = 1
        For i = #ToolBar_OptionPopUp_SummaryDefault To #ToolBar_OptionPopUp_SummaryMesa
          SetMenuItemState(#MainForm_ToolBar_OptionPopUp, i, #False)
        Next i
        SetMenuItemState(#MainForm_ToolBar_OptionPopUp, #ToolBar_OptionPopUp_SummaryMesa, #True)
        TreeAllItemResetColor():ClearList(ItemColor()) 
      Else
        MessageRequester(Language::Get("Requesters", "Information"), Language::Get("Requesters", "Failed"), #PB_MessageRequester_Warning)
      EndIf
      
    EndProcedure
    
    ;Open a summary:Menu #ToolBar_OptionPopUp_SummaryOpen
    Procedure SummaryOpen()
      Protected F$, Filter$, i
      
      Filter$ = Language::Get("Requesters", "OpenSummary") + "|*.xml;*.hhc;*.sum"
      F$      = OpenFileRequester(Language::Get("Requesters", "OpenSummaryTitle"), Path$, Filter$, 0)
      ;         F$      = GetFilePart(F$)
      
      If F$
        Select LCase(GetExtensionPart(F$))
          Case "xml", "sum"
            FillSummary(#tree_summary, F$)
            FillSummary(#tree_summarynoicons, F$)
            TreeParentChild(#tree_summary)
            TreeItemColorInit()
            CurrentSummary = F$
           TreeAllItemResetColor():ClearList(ItemColor())  
          Case "hhc"
            Fill_hhc(#tree_summary, F$)
            Fill_hhc(#tree_summarynoicons, F$)
            TreeParentChild(#tree_summary)
            TreeItemColorInit()
            CurrentSummary = F$
            TreeAllItemResetColor():ClearList(ItemColor())  
        EndSelect
        
        For i = #ToolBar_OptionPopUp_SummaryDefault To #ToolBar_OptionPopUp_SummaryMesa
          SetMenuItemState(#MainForm_ToolBar_OptionPopUp, i, #False)
        Next i
        
      EndIf
      
    EndProcedure
    
    ; Create a summary file from an hhc file:Menu #ToolBar_OptionPopUp_SummaryCreate
    Procedure SummaryCreate()
      Protected F$, Filter$, G$
      
      Filter$ = Language::Get("Requesters", "OpenSummary") + "|*.hhc"
      F$      = OpenFileRequester(Language::Get("Requesters", "OpenSummaryTitle"), Path$, Filter$, 0)
      Filter$ = Language::Get("Requesters", "SaveSummary") + "|*.xml;*.sum"
      G$      = SaveFileRequester(Language::Get("Requesters", "SaveSummaryTitle"), Path$, Filter$, 0)
      If F$
        If G$
          If LCase(GetExtensionPart(G$)) = "xml"
            ;- TODO MakeXMLFromHHC(F$, G$)
          ElseIf LCase(GetExtensionPart(G$)) = "sum"
            MakeSummaryFromHHC(F$, G$)
          EndIf
        EndIf
      EndIf
      
    EndProcedure
    
    ; Display the default index:Menu #ToolBar_OptionPopUp_IndexDefault
    Procedure IndexDefault()
      
      FillIndex(#listview_index, DefaultIndex)
      SetMenuItemState(#MainForm_ToolBar_OptionPopUp, #ToolBar_OptionPopUp_IndexDefault, #True)
      
    EndProcedure
    
    ;Open an index file:Menu #ToolBar_OptionPopUp_IndexOpen
    Procedure IndexOpen()
      Protected F$, Filter$, i
      
      Filter$ = Language::Get("Requesters", "OpenIndex") + "|*.xml;*.ind;*.hhk"
      F$      = OpenFileRequester(Language::Get("Requesters", "OpenIndexTitle"), PathHelp$, Filter$, 0)
      ;         F$      = GetFilePart(F$)
      
      If F$
        Select  LCase(GetExtensionPart(F$))
          Case "xml", "ind"
            FillIndex(#listview_index, F$)
            CurrentIndex = F$
          Case "hhk"
            Fill_hhk(#listview_index, F$)
            CurrentIndex = F$
        EndSelect
        
        SetMenuItemState(#MainForm_ToolBar_OptionPopUp, #ToolBar_OptionPopUp_IndexDefault, #False)
        
      EndIf
      
    EndProcedure
    
    ;Create an index file from an hhk file:Menu #ToolBar_OptionPopUp_IndexCreate
    Procedure IndexCreate()
      Protected F$, Filter$, G$
      
      Filter$ = Language::Get("Requesters", "OpenIndex") + "|*.hhk"
      F$      = OpenFileRequester(Language::Get("Requesters", "OpenIndexTitle"), Path$, Filter$, 0)
      Filter$ = Language::Get("Requesters", "SaveIndex") + "|*.ind"
      G$      = SaveFileRequester(Language::Get("Requesters", "SaveIndexTitle"), Path$, Filter$, 0)
      If F$
        If G$
          MakeIndexFromHHK(F$, G$)
        EndIf
      EndIf
      
    EndProcedure
    
    ;Change GUI and summary language:Menu #ToolBar_OptionPopUp_Fr, #ToolBar_OptionPopUp_En, #ToolBar_OptionPopUp_De
    Procedure Lang()
      Protected i, Menu = EventMenu()
      
      If OpenPreferences(Preference$, #PB_Preference_GroupSeparator)
        PreferenceGroup("LANG")
        
        Select Menu
          Case #ToolBar_OptionPopUp_Fr
            WritePreferenceString("lang", "fr")
            UserLanguage$ = "fr"
          Case #ToolBar_OptionPopUp_En
            WritePreferenceString("lang", "en")
            UserLanguage$ = "en"
          Case #ToolBar_OptionPopUp_De
            WritePreferenceString("lang", "de")
            UserLanguage$ = "de"
        EndSelect
        
        FlushPreferenceBuffers()
        ClosePreferences()
        
        Setlang(#True)
        FreeMenu(#MainForm_ToolBar_OptionPopUp)
        FreeMenu(#MainForm_Treeview_PopUp)
        PopUpMenus()
        
        For i = #ToolBar_OptionPopUp_Fr To #ToolBar_OptionPopUp_De
          SetMenuItemState(#MainForm_ToolBar_OptionPopUp, i, #False)
        Next i
        SetMenuItemState(#MainForm_ToolBar_OptionPopUp, Menu, #True)
        
        PathHTML$   = PathHelp$ + UserLanguage$ + #PS$
        PathHTMLHD$ = PathHTML$
        CompilerSelect #PB_Compiler_OS
          CompilerCase #PB_OS_Windows
            PathHTML$   = ReplaceString(PathHTML$, "\", "/")
            PathHTMLHD$ = PathHTML$
        CompilerEndSelect

        Init()
        
      EndIf
      
    EndProcedure
    
    ;Update PureHelp files (summary, index,...) after a manual html and xml files update from a newer version of PureBasic
    Procedure Update()
      Protected Res
      Protected f, g, templen.q, size.q, dir, c, i, length.q, bytes.q, fbytes.q
      Protected ListOfHtml$ = Path$ + "Help" + #PS$ + "ListOfHtml.txt"; on hdd
      Protected ListOfHtmlvd$ = PathHelp$ + "ListOfHtml.txt"          ; on virtual drive
      Protected ListOfHtmlSize$ = Path$ + "Help" + #PS$ + "ListOfHtmlSize"; on hdd
      Protected ListOfHtmlSizevd$ = PathHelp$ + "ListOfHtmlSize.txt"      ; on virtual drive
      Protected fRamDisk$ = Path$ + "Help" + #PS$ + "RamDisk"             ; on hdd
      Protected fRamDiskvd$ = PathHelp$ + "RamDisk"                       ; on virtual drive
      Protected dirname$
      Protected Dim dirlang.s(0)
      Protected *MemoryID
      
      Res = MessageRequester(Language::Get("Requesters", "Update?"), Language::Get("Requesters", "UpdateText?"), #PB_MessageRequester_YesNoCancel|#PB_MessageRequester_Warning)
      If Res = #PB_MessageRequester_Yes
        Res = MessageRequester(Language::Get("Requesters", "Update?"), Language::Get("Requesters", "UpdateText2?"), #PB_MessageRequester_YesNo|#PB_MessageRequester_Warning)
        If Res = #PB_MessageRequester_Yes 
          
          ; Search Update
          ;Create "ListOfHtml.txt", a file with html files name only
          ClearList(Searched_Files())
          Search_BrowseDirectory(PathHelp$ + UserLanguage$, @Search_Files())
          f = CreateFile(#PB_Any, ListOfHtml$, #PB_UTF8)
          If f
            WriteStringN(f, Str(#version))
            ForEach Searched_Files()
              WriteStringN(f, RemoveString(Searched_Files(),PathHelp$ + UserLanguage$ + #PS$))
            Next
            CloseFile(f)
          EndIf
          
          ;Check or Create "ListOfHtmlSizexx" files with files size (html only) for each languages
          dir = ExamineDirectory(#PB_Any, PathHelpHD$, "*.*")
          If dir
            While NextDirectoryEntry(dir)
              If DirectoryEntryType(dir) = #PB_DirectoryEntry_Directory
                dirname$ = Trim(DirectoryEntryName(dir))
                If dirname$ = "." Or dirname$ = ".."
                Else
                  dirlang(c) = dirname$
                  c + 1
                  ReDim dirlang(c)
                  ;Check file size
                  
                  If ListSize(Searched_FilesSize()):ClearList(Searched_FilesSize()):EndIf
                  ;Fill file size list
                  AddElement(Searched_FilesSize())
                  Searched_FilesSize() = 0
                  ForEach Searched_Files()
                    size = FileSize(Searched_Files())
                    templen = templen + size 
                    AddElement(Searched_FilesSize())
                    Searched_FilesSize() = templen    
                  Next
                  ;Create the file size
                  f = CreateFile(#PB_Any, ListOfHtmlSize$+dirname$, #PB_UTF8)
                  If f
                    WriteStringN(f, Str(#version))
                    ForEach Searched_FilesSize()
                      WriteQuad(f, Searched_FilesSize())
                    Next
                    CloseFile(f)
                    ;Copy to the right list
                    Select dirname$
                      Case "fr"
                        ClearList(Searched_FilesSizefr())
                        CopyList(Searched_FilesSize(),Searched_FilesSizefr())
                      Case "en"
                        ClearList(Searched_FilesSizeen())
                        CopyList(Searched_FilesSize(),Searched_FilesSizeen())
                      Case "de"
                        ClearList(Searched_FilesSizede())
                        CopyList(Searched_FilesSize(),Searched_FilesSizede())
                    EndSelect
                    ClearList(Searched_FilesSize())
                    templen=0
                  EndIf 
                EndIf
              EndIf 
            Wend
            FinishDirectory(dir)
          EndIf 
          
          ;Make a big html file ("RamDiskxx") to use as a ramdisk
          For i = 0 To c-1
            dirname$ = dirlang(i)
            f=CreateFile(#PB_Any, fRamDisk$+dirname$, #PB_UTF8)
            If f
              ForEach Searched_Files()
                g=ReadFile(#PB_Any, Searched_Files(), #PB_UTF8)
                If g
                  length = Lof(g)
                  *MemoryID = AllocateMemory(length)
                  If *MemoryID
                    bytes = ReadData(g, *MemoryID, length)
                    fbytes + bytes
                  EndIf
                  CloseFile(g)
                EndIf
                WriteData(f, *MemoryID, length)
                FreeMemory(*MemoryID)
              Next
              CloseFile(f)
            EndIf 
            
          Next i    
          
          Init()
          
          MessageRequester(Language::Get("Requesters", "Update?"), Language::Get("Requesters", "Restaure"), #PB_MessageRequester_Ok|#PB_MessageRequester_Info)
        EndIf  
      EndIf
      
    EndProcedure
    
    ;Display license stuffes like icons:Menu #ToolBar_OptionPopUp_About
    Procedure About()
      Protected file$ = path$ + "ABOUT.md.html"
      
      ReplaceString(file$, "\", "/", #PB_String_InPlace)
      
      If FileSize(file$) > 0
        SetGadgetText(WebDisplay, file$)
      EndIf
      
    EndProcedure
    
    ;- Tree Menu
    ;Expand a three gadget
    ;keya https://www.purebasic.fr/english/viewtopic.php?f=12&t=63276&hilit=expand+treeview	
    Procedure TreeExpandAll()
      Protected TreeId.i, CurItemSelected.i, CurItem.i, CurState.i, ItemCnt.i, tmp.i
      
      If GetGadgetData(#tree_summarynoicons)
        TreeId = #tree_summary
      Else
        TreeId = #tree_summarynoicons
      EndIf
      
      ItemCnt = CountGadgetItems(TreeId)
      
      If ItemCnt <= 0: ProcedureReturn: EndIf
      CurItemSelected = GetGadgetState(TreeId)
      If CurItemSelected = -1
        CurItemSelected = 0
      EndIf
      For CurItem = 0 To ItemCnt - 1
        CurState = GetGadgetItemState(TreeId, CurItem)
        CurState = CurState ! #PB_Tree_Collapsed
        If CurState & #PB_Tree_Checked
          CurState = #PB_Tree_Checked | #PB_Tree_Expanded
        ElseIf CurState & #PB_Tree_Inbetween
          CurState = #PB_Tree_Inbetween | #PB_Tree_Expanded
        Else
          CurState = #PB_Tree_Expanded
        EndIf
        SetGadgetItemState(TreeId, CurItem, CurState)
        tmp = GetGadgetItemData(TreeId, CurItem)
        If Bool(tmp = 1 Or tmp = 2)
          ;SetGadgetItemImage(TreeId, CurItem, ImageID(#im_tree_BookOpen))
          TreeSetItemIcon(TreeId, CurItem, 2)
        EndIf
      Next
      
      SetGadgetState(TreeId, CurItemSelected)
      
    EndProcedure
    
    ;Collapse a treegadget
    Procedure TreeCollapseAll()
      Protected TreeId.i, CurItemSelected.i, CurItem.i, CurState.i, ItemCnt.i, tmp.i
      
      If GetGadgetData(#tree_summarynoicons)
        TreeId = #tree_summary
      Else
        TreeId = #tree_summarynoicons
      EndIf
      
      ItemCnt = CountGadgetItems(TreeId)
      
      If ItemCnt <= 0: ProcedureReturn: EndIf
      For CurItem = 0 To ItemCnt - 1
        CurState = GetGadgetItemState(TreeId, CurItem)
        CurState = CurState ! #PB_Tree_Expanded
        If CurState & #PB_Tree_Checked
          CurState = #PB_Tree_Checked | #PB_Tree_Collapsed
        ElseIf CurState & #PB_Tree_Inbetween
          CurState = #PB_Tree_Inbetween | #PB_Tree_Collapsed
        Else
          CurState = #PB_Tree_Collapsed
        EndIf
        SetGadgetItemState(TreeId, CurItem, CurState)
        SetGadgetItemState(TreeId, CurItem, CurState)
        tmp = GetGadgetItemData(TreeId, CurItem)
        If tmp = 1
          ;#im_tree_BookClosed
          TreeSetItemIcon(TreeId, CurItem, 1)
        ElseIf tmp = 2
          ;#im_tree_BookClosed
          TreeSetItemIcon(TreeId, CurItem, 1)
        EndIf
      Next
      
      SetGadgetState(TreeId, 0)
      
    EndProcedure
    
    ; Not used
    Procedure TreeDeselectAllItems(TreeId)
      Protected CurItem.i, CurState.i, ItemCnt.i = CountGadgetItems(TreeId)
      
      If ItemCnt <= 0: ProcedureReturn: EndIf
      For CurItem = 0 To ItemCnt - 1
        CurState = GetGadgetItemState(TreeId, CurItem)
        CurState = CurState ! #PB_Tree_Checked
        SetGadgetItemState(TreeId, CurItem, CurState)
      Next
      
    EndProcedure
    
    ; Not used
    Procedure TreeSelectAllItems(TreeId)
      Protected CurItem.i, CurState.i, ItemCnt.i = CountGadgetItems(TreeId)
      
      If ItemCnt <= 0: ProcedureReturn: EndIf
      For CurItem = 0 To ItemCnt - 1
        CurState = GetGadgetItemState(TreeId, CurItem)
        CurState = CurState | #PB_Tree_Checked
        SetGadgetItemState(TreeId, CurItem, CurState)
      Next
      
    EndProcedure
    
    Procedure TreeItemTextColor()
      Protected item = GetGadgetState(#tree_summary)
      Protected color, found = 0
      
      If item <> -1
        color=ColorRequester()
        If color <> -1
          SetGadgetItemColor(#tree_summary, item, #PB_Gadget_FrontColor, color)
          
          ;Preference
          ForEach ItemColor()
            If item = ItemColor()\item
              ItemColor()\textcolor = color
              found = 1
              Break
            EndIf
          Next
          
          If found = 0
            AddElement(ItemColor())
            ItemColor()\item = item
            ItemColor()\textcolor = color
            ItemColor()\bkgcolor = -1
          EndIf
        EndIf
      EndIf
      
    EndProcedure
    
    Procedure TreeItemBkgColor()
      Protected item = GetGadgetState(#tree_summary)
      Protected color, found = 0
      
      If item <> -1
        color=ColorRequester()
        If color <> -1
          SetGadgetItemColor(#tree_summary, item, #PB_Gadget_BackColor, color)
          
          ;Preference
          ForEach ItemColor()
            If item = ItemColor()\item
              ItemColor()\bkgcolor = color
              Break
            EndIf
          Next
          
          If found = 0
            AddElement(ItemColor())
            ItemColor()\item = item
            ItemColor()\textcolor = -1
            ItemColor()\bkgcolor = color
          EndIf
        EndIf
      EndIf
      
    EndProcedure
    
    Procedure TreeItemResetColor()
      Protected item = GetGadgetState(#tree_summary)
      
      SetGadgetItemColor(#tree_summary, item, #PB_Gadget_BackColor, ItemColorTxt)
      SetGadgetItemColor(#tree_summary, item, #PB_Gadget_FrontColor, ItemColorBkg)
      
      If ListSize(ItemColor())
        ForEach ItemColor()
          If item = ItemColor()\item
            DeleteElement(ItemColor(), 1)
            Break
          EndIf
        Next
      EndIf
      
    EndProcedure
    
    Procedure TreeAllItemResetColor()
            
       If ListSize(ItemColor())
      ForEach ItemColor()
        SetGadgetItemColor(#tree_summary, ItemColor()\item, #PB_Gadget_BackColor, ItemColorTxt)
        SetGadgetItemColor(#tree_summary, ItemColor()\item, #PB_Gadget_FrontColor, ItemColorBkg)
      Next
    EndIf
    
      ClearList(ItemColor()) 
      
    EndProcedure
    
    ;- Create pop-up menus
    Procedure PopUpMenus()
      Protected n, i, menu
      
      ;Options menu pop-up menu
      If CreatePopupMenu(#MainForm_ToolBar_OptionPopUp)
        ;MenuTitle("Options_SubMenus")
        MenuItem(#ToolBar_OptionPopUp_Stop, Language::Get("OptionsSubMenu", "Stop"))
        MenuItem(#ToolBar_OptionPopUp_Refresh, Language::Get("OptionsSubMenu", "Refresh"))
        MenuBar()
        OpenSubMenu(Language::Get("OptionsSubMenu", "Font"))
        MenuItem(#ToolBar_OptionPopUp_Font, Language::Get("OptionsSubMenu", "Font"))
        MenuItem(#ToolBar_OptionPopUp_FontSizeOnly, Language::Get("OptionsSubMenu", "FontSizeOnly"))
        MenuBar()
        MenuItem(#ToolBar_OptionPopUp_FontList, Language::Get("OptionsSubMenu", "FontList"))
        MenuItem(#ToolBar_OptionPopUp_FontListColour, Language::Get("OptionsSubMenu", "FontListColour"))
        MenuItem(#ToolBar_OptionPopUp_FontListSizeOnly, Language::Get("OptionsSubMenu", "FontListSizeOnly"))
        MenuBar()
        MenuItem(#ToolBar_OptionPopUp_FontDefault, Language::Get("OptionsSubMenu", "FontDefault"))
        CloseSubMenu()
        MenuBar()
        MenuItem(#ToolBar_OptionPopUp_Icons, Language::Get("OptionsSubMenu", "Icons"))
        MenuItem(#ToolBar_OptionPopUp_IconsSize, Language::Get("OptionsSubMenu", "IconsSize"))
        MenuBar()
        OpenSubMenu(Language::Get("OptionsSubMenu", "Summary"))
        MenuItem(#ToolBar_OptionPopUp_SummaryDefault, Language::Get("OptionsSubMenu", "SummaryDefault"))
        MenuItem(#ToolBar_OptionPopUp_SummaryMesa, Language::Get("OptionsSubMenu", "SummaryMesa"))
        MenuBar()
        MenuItem(#ToolBar_OptionPopUp_SummaryOpen, Language::Get("OptionsSubMenu", "SummaryOpen"))
        MenuItem(#ToolBar_OptionPopUp_SummaryCreate, Language::Get("OptionsSubMenu", "SummaryCreate"))
        CloseSubMenu()
        MenuBar()
        OpenSubMenu(Language::Get("OptionsSubMenu", "Index"))
        MenuItem(#ToolBar_OptionPopUp_IndexDefault, Language::Get("OptionsSubMenu", "IndexDefault"))
        MenuItem(#ToolBar_OptionPopUp_IndexOpen, Language::Get("OptionsSubMenu", "IndexOpen"))
        MenuBar()
        MenuItem(#ToolBar_OptionPopUp_IndexCreate, Language::Get("OptionsSubMenu", "IndexCreate"))
        CloseSubMenu()
        MenuBar()
        OpenSubMenu(Language::Get("OptionsSubMenu", "Lang"))
        MenuItem(#ToolBar_OptionPopUp_Fr, Language::Get("OptionsSubMenu", "French"))
        MenuItem(#ToolBar_OptionPopUp_En, Language::Get("OptionsSubMenu", "English"))
        MenuItem(#ToolBar_OptionPopUp_De, Language::Get("OptionsSubMenu", "German"))
        CloseSubMenu()
        MenuBar()
        MenuItem(#ToolBar_OptionPopUp_Update, Language::Get("OptionsSubMenu", "Update"))
        MenuBar()
        MenuItem(#ToolBar_OptionPopUp_About, Language::Get("OptionsSubMenu", "About"))
        
        SetMenuItemState(#MainForm_ToolBar_OptionPopUp, #ToolBar_OptionPopUp_Icons, #True)
        ;           SetMenuItemState(#MainForm_ToolBar_OptionPopUp, #ToolBar_OptionPopUp_SummaryMesa, #True)
        SetMenuItemState(#MainForm_ToolBar_OptionPopUp, #ToolBar_OptionPopUp_SummaryDefault, #True)
        SetMenuItemState(#MainForm_ToolBar_OptionPopUp, #ToolBar_OptionPopUp_Fr, #True)
        SetMenuItemState(#MainForm_ToolBar_OptionPopUp, #ToolBar_OptionPopUp_IndexDefault, #True)
        
        BindMenuEvent(#MainForm_ToolBar_OptionPopUp, #ToolBar_OptionPopUp_Stop, @Stop())
        BindMenuEvent(#MainForm_ToolBar_OptionPopUp, #ToolBar_OptionPopUp_Refresh, @Refresh())
        BindMenuEvent(#MainForm_ToolBar_OptionPopUp, #ToolBar_OptionPopUp_Font, @Fonts())
        BindMenuEvent(#MainForm_ToolBar_OptionPopUp, #ToolBar_OptionPopUp_FontSizeOnly, @FontSizeOnly())
        BindMenuEvent(#MainForm_ToolBar_OptionPopUp, #ToolBar_OptionPopUp_FontList, @FontList())
        BindMenuEvent(#MainForm_ToolBar_OptionPopUp, #ToolBar_OptionPopUp_FontDefault, @FontDefault())
        BindMenuEvent(#MainForm_ToolBar_OptionPopUp, #ToolBar_OptionPopUp_FontListColour, @FontColourList())
        BindMenuEvent(#MainForm_ToolBar_OptionPopUp, #ToolBar_OptionPopUp_FontListSizeOnly, @FontListSizeOnly())
        BindMenuEvent(#MainForm_ToolBar_OptionPopUp, #ToolBar_OptionPopUp_Icons, @IconsInSummary())
        BindMenuEvent(#MainForm_ToolBar_OptionPopUp, #ToolBar_OptionPopUp_IconsSize, @IconsSize())
        BindMenuEvent(#MainForm_ToolBar_OptionPopUp, #ToolBar_OptionPopUp_SummaryDefault, @SummaryDefault())
        BindMenuEvent(#MainForm_ToolBar_OptionPopUp, #ToolBar_OptionPopUp_SummaryMesa, @SummaryMesa())
        BindMenuEvent(#MainForm_ToolBar_OptionPopUp, #ToolBar_OptionPopUp_SummaryOpen, @SummaryOpen())
        BindMenuEvent(#MainForm_ToolBar_OptionPopUp, #ToolBar_OptionPopUp_SummaryCreate, @SummaryCreate())
        BindMenuEvent(#MainForm_ToolBar_OptionPopUp, #ToolBar_OptionPopUp_IndexDefault, @IndexDefault())
        BindMenuEvent(#MainForm_ToolBar_OptionPopUp, #ToolBar_OptionPopUp_IndexOpen, @IndexOpen())
        BindMenuEvent(#MainForm_ToolBar_OptionPopUp, #ToolBar_OptionPopUp_IndexCreate, @IndexCreate())
        BindMenuEvent(#MainForm_ToolBar_OptionPopUp, #ToolBar_OptionPopUp_Fr, @Lang())
        BindMenuEvent(#MainForm_ToolBar_OptionPopUp, #ToolBar_OptionPopUp_En, @Lang())
        BindMenuEvent(#MainForm_ToolBar_OptionPopUp, #ToolBar_OptionPopUp_De, @Lang())
        BindMenuEvent(#MainForm_ToolBar_OptionPopUp, #ToolBar_OptionPopUp_Update, @Update())
        BindMenuEvent(#MainForm_ToolBar_OptionPopUp, #ToolBar_OptionPopUp_About, @About())
      EndIf
      
      ;Tree pop-up menu
      If CreatePopupImageMenu(#MainForm_Treeview_PopUp)
        ;MenuTitle("Treeview_PopUp")
        MenuItem(#Treeview_Popup_ExpandAll, Language::Get("PopUpMenus", "ExpandAll"), ImageID(#im_tree_BookOpen))
        MenuItem(#Treeview_Popup_CollapseAll, Language::Get("PopUpMenus", "CollapseAll"), ImageID(#im_tree_BookClosed))
        MenuBar()
        MenuItem(#Treeview_Popup_ItemTextColor, Language::Get("PopUpMenus", "ItemTextColor"))
        MenuItem(#Treeview_Popup_ItemBkgColor, Language::Get("PopUpMenus", "ItemBkgColor"))
        MenuItem(#Treeview_Popup_ItemResetColor, Language::Get("PopUpMenus", "ItemResetColor"))
        MenuItem(#Treeview_Popup_AllItemResetColor, Language::Get("PopUpMenus", "AllItemResetColor")) 
        
        BindMenuEvent(#MainForm_Treeview_PopUp, #Treeview_Popup_ExpandAll, @TreeExpandAll())
        BindMenuEvent(#MainForm_Treeview_PopUp, #Treeview_Popup_CollapseAll, @TreeCollapseAll())
        BindMenuEvent(#MainForm_Treeview_PopUp, #Treeview_Popup_ItemTextColor, @TreeItemTextColor())
        BindMenuEvent(#MainForm_Treeview_PopUp, #Treeview_Popup_ItemBkgColor, @TreeItemBkgColor())
        BindMenuEvent(#MainForm_Treeview_PopUp, #Treeview_Popup_ItemResetColor, @TreeItemResetColor())
        BindMenuEvent(#MainForm_Treeview_PopUp, #Treeview_Popup_AllItemResetColor, @TreeAllItemResetColor())              
        
      EndIf
      
      For i = #ToolBar_OptionPopUp_Fr To #ToolBar_OptionPopUp_De
        SetMenuItemState(#MainForm_ToolBar_OptionPopUp, i, #False)
      Next i
      Select UserLanguage$
        Case "fr"
          Menu = #ToolBar_OptionPopUp_Fr
        Case "en"
          Menu = #ToolBar_OptionPopUp_En
        Case "de"
          Menu = #ToolBar_OptionPopUp_De
        Default
          Menu = #ToolBar_OptionPopUp_En
      EndSelect
      SetMenuItemState(#MainForm_ToolBar_OptionPopUp, Menu, #True)
      
    EndProcedure
    
    ;-
    ;- FAVORITES
    ;- ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    ;Fill the listview with favorites from the preference file
    Procedure FillFavorites()
      
      If OpenPreferences(Preference$, #PB_Preference_GroupSeparator)
        PreferenceGroup("FAVORITES")
        ExaminePreferenceKeys()
        While NextPreferenceKey()
          AddElement(Favorites())
          Favorites()\Node = PreferenceKeyName()
          Favorites()\Path = PreferenceKeyValue()
          Favorites()\Link = "file://" + PathHTMLHD$ + Favorites()\Path
          AddGadgetItem(#listview_favorite, - 1, PreferenceKeyName())
        Wend
        ClosePreferences()
      EndIf
      
    EndProcedure
    
    ;Update the favorite section of the preference file
    Procedure UpdateFavorites()
      Protected i
      
      ;       If OpenPreferences(Preference$, #PB_Preference_GroupSeparator)
      RemovePreferenceGroup("FAVORITES")
      FlushPreferenceBuffers()
      PreferenceGroup("FAVORITES")
      For i = 0 To CountGadgetItems(#listview_favorite) - 1
        WritePreferenceString(Favorites()\Node, Favorites()\Path)
      Next i
      FlushPreferenceBuffers()
      ;         ClosePreferences()
      ;       EndIf
      
    EndProcedure
    
    ;-
    ;- Accelerators
    ;- ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    ;TODO (accelerators are not implemented)
    ;Add keyboard shortcut
    Procedure Accelerators()
      
      ;If CreatePopupMenu(#DummyMenu)
      ;  MenuItem(#Acc_TB_Options, "")
      ;EndIf
      
      ;   ;ToolBar Accelerator
      ;   BindMenuEvent(#DummyMenu,#Acc_TB_Options,@OnRClick_tree_summary())
      ;   AddKeyboardShortcut(DialogWindow(1), #PB_Shortcut_Alt|#PB_Shortcut_O,#Acc_TB_Options)
      ;   ;Panel Accelerators
      ;   Select UserLanguage
      ;     Case #LANG_FRENCH
      ;French Accelerators
      ;       AddKeyboardShortcut(Main_Window, #PB_Shortcut_Alt|#PB_Shortcut_S,#Acc_Panel_TabSummary)
      ;       AddKeyboardShortcut(Main_Window, #PB_Shortcut_Alt|#PB_Shortcut_I,#Acc_Panel_TabIndex)
      ;       AddKeyboardShortcut(Main_Window, #PB_Shortcut_Alt|#PB_Shortcut_P,#Acc_Panel_Snippet)
      ;       AddKeyboardShortcut(Main_Window, #PB_Shortcut_Alt|#PB_Shortcut_R,#Acc_Panel_TabSearch)
      ;       AddKeyboardShortcut(Main_Window, #PB_Shortcut_Alt|#PB_Shortcut_V,#Acc_Panel_TabFavorites)
      ;       AddKeyboardShortcut(Main_Window, #PB_Shortcut_Alt|#PB_Shortcut_O,#Acc_Panel_StringSearch)
      ;       AddKeyboardShortcut(Main_Window, #PB_Shortcut_Alt|#PB_Shortcut_C,#Acc_Panel_ButtonDisplay)
      ;       AddKeyboardShortcut(Main_Window, #PB_Shortcut_Alt|#PB_Shortcut_L,#Acc_Panel_ButtonListRubric)
      ;       AddKeyboardShortcut(Main_Window, #PB_Shortcut_Alt|#PB_Shortcut_Q,#Acc_Panel_Rubric)
      ;       AddKeyboardShortcut(Main_Window, #PB_Shortcut_Alt|#PB_Shortcut_B,#Acc_Panel_StringRubric)
      ;       AddKeyboardShortcut(Main_Window, #PB_Shortcut_Alt|#PB_Shortcut_M,#Acc_Panel_ButtonDel)
      ;       AddKeyboardShortcut(Main_Window, #PB_Shortcut_Alt|#PB_Shortcut_Z,#Acc_Panel_ButtonRAZ)
      ;       AddKeyboardShortcut(Main_Window, #PB_Shortcut_Alt|#PB_Shortcut_U,#Acc_Panel_ButtonAdd)
      
      ;     Case #LANG_ENGLISH
      ;       ;TODO manage events acelarators for english and a beautiful home page
      ;       ;{ English Accelerators
      ;       ;       AddKeyboardShortcut(Main_Window, #PB_Shortcut_Alt|#PB_Shortcut_C,#Acc_Panel_TabSummary)
      ;       ;       AddKeyboardShortcut(Main_Window, #PB_Shortcut_Alt|#PB_Shortcut_I,#Acc_Panel_TabIndex)
      ;       ;       AddKeyboardShortcut(Main_Window, #PB_Shortcut_Alt|#PB_Shortcut_S,#Acc_Panel_TabSearch)
      ;       ;       AddKeyboardShortcut(Main_Window, #PB_Shortcut_Alt|#PB_Shortcut_V,#Acc_Panel_TabFavorites)
      ;       ;       AddKeyboardShortcut(Main_Window, #PB_Shortcut_Alt|#PB_Shortcut_T,#Acc_Panel_StringSearch)
      ;       ;       AddKeyboardShortcut(Main_Window, #PB_Shortcut_Alt|#PB_Shortcut_D,#Acc_Panel_ButtonDisplay)
      ;       ;       AddKeyboardShortcut(Main_Window, #PB_Shortcut_Alt|#PB_Shortcut_L,#Acc_Panel_ButtonListRubric)
      ;       ;       AddKeyboardShortcut(Main_Window, #PB_Shortcut_Alt|#PB_Shortcut_R,#Acc_Panel_Rubric)
      ;       ;       AddKeyboardShortcut(Main_Window, #PB_Shortcut_Alt|#PB_Shortcut_B,#Acc_Panel_StringRubric)
      ;       ;       AddKeyboardShortcut(Main_Window, #PB_Shortcut_Alt|#PB_Shortcut_T,#Acc_Panel_ButtonDel)
      ;       ;       AddKeyboardShortcut(Main_Window, #PB_Shortcut_Alt|#PB_Shortcut_S,ButtonRAZ)
      ;       ;       AddKeyboardShortcut(Main_Window, #PB_Shortcut_Alt|#PB_Shortcut_A,#Acc_Panel_ButtonAdd)
      
      ;     Case #LANG_GERMAN
      ;       ;TODO manage events acelarators for german, it's english for now and a A beautiful home page
      ;       ;{ German Accelerators
      ;       ;       AddKeyboardShortcut(Main_Window, #PB_Shortcut_Alt|#PB_Shortcut_C,#Acc_Panel_TabSummary)
      ;       ;       AddKeyboardShortcut(Main_Window, #PB_Shortcut_Alt|#PB_Shortcut_I,#Acc_Panel_TabIndex)
      ;       ;       AddKeyboardShortcut(Main_Window, #PB_Shortcut_Alt|#PB_Shortcut_S,#Acc_Panel_TabSearch)
      ;       ;       AddKeyboardShortcut(Main_Window, #PB_Shortcut_Alt|#PB_Shortcut_V,#Acc_Panel_TabFavorites)
      ;       ;       AddKeyboardShortcut(Main_Window, #PB_Shortcut_Alt|#PB_Shortcut_T,#Acc_Panel_StringSearch)
      ;       ;       AddKeyboardShortcut(Main_Window, #PB_Shortcut_Alt|#PB_Shortcut_D,#Acc_Panel_ButtonDisplay)
      ;       ;       AddKeyboardShortcut(Main_Window, #PB_Shortcut_Alt|#PB_Shortcut_L,#Acc_Panel_ButtonListRubric)
      ;       ;       AddKeyboardShortcut(Main_Window, #PB_Shortcut_Alt|#PB_Shortcut_R,#Acc_Panel_Rubric)
      ;       ;       AddKeyboardShortcut(Main_Window, #PB_Shortcut_Alt|#PB_Shortcut_B,#Acc_Panel_StringRubric)
      ;       ;       AddKeyboardShortcut(Main_Window, #PB_Shortcut_Alt|#PB_Shortcut_T,#Acc_Panel_ButtonDel)
      ;       ;       AddKeyboardShortcut(Main_Window, #PB_Shortcut_Alt|#PB_Shortcut_S,ButtonRAZ)
      ;       ;}       AddKeyboardShortcut(Main_Window, #PB_Shortcut_Alt|#PB_Shortcut_A,#Acc_Panel_ButtonAdd)
      ;   EndSelect
      
    EndProcedure
    
    
    ;-
    ;- SEARCHING
    ;- ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    
    ;Not used: Change html code to Highlight a text (not working very well)
    Procedure.s Search_Highlight(line$, searched$)
      
      Structure strbegend
        begin.i
        End.i
      EndStructure
      
      Protected NewList s.strbegend()
      Protected NewList ss()
      Protected NewList sss()
      Protected p, l, res, ll, q, regx1, regx2
      
      If line$ = "":ProcedureReturn "":EndIf
      If searched$ = "":ProcedureReturn "":EndIf
      
      regx1 = CreateRegularExpression(#PB_Any, "<[^>]*>")
      If regx1
        If ExamineRegularExpression(regx1, line$ )
          While NextRegularExpressionMatch(regx1)
            p = RegularExpressionMatchPosition(regx1)
            l = RegularExpressionMatchLength(regx1)
            If p
              AddElement(s())
              s()\begin = p
              s()\end   = p + l - 1
            EndIf
          Wend
        EndIf
      Else
        Debug RegularExpressionError()
        ProcedureReturn ""
      EndIf
      FreeRegularExpression(regx1)
      
      regx2 = CreateRegularExpression(#PB_Any, searched$, #PB_RegularExpression_NoCase)
      If regx2
        If ExamineRegularExpression(regx2, line$)
          While NextRegularExpressionMatch(regx2)
            p = RegularExpressionMatchPosition(regx2)
            If p
              AddElement(ss())
              ss() = p
            EndIf
          Wend
        EndIf
      Else
        Debug RegularExpressionError()
        ProcedureReturn ""
      EndIf
      FreeRegularExpression(regx2)
      
      ForEach ss()
        res = 0
        ForEach s()
          If ss() >= s()\begin And ss() <= s()\End
            res = 1
            Break
          EndIf
        Next
        If res = 0
        AddElement(sss()):sss() = ss():EndIf
      Next
      
      p = - 1
      l = Len(~"<span style=\"background-color:yellow;\">") + Len("</span>")
      l = 46
      ForEach sss()
        p + 1
        line$ = ReplaceString(line$, searched$, ~"<span style=\"background-color:yellow;\">" + searched$ + "</span>", #PB_String_NoCase, sss() + (p) * l, 1)
      Next
      
      ProcedureReturn line$
      
    EndProcedure
    
    ;Search an utf8 string (just $C2 and $C3 char) in memory
    Procedure.i Search_FindStringInMemory(*Memory, String$)
      
      Protected.i StringByteLength, Result
      Protected *MemoryEnd, *Ptr.Ascii, *FoundPtr, *Ptr2.Ascii, *String0.Ascii, *String.Ascii
      Protected MaxProgress.q, time.q
      
      StringByteLength = StringByteLength(String$, #PB_UTF8)
      *String0         = Ascii(String$)
      *String          = *String0
      ;PB    é=E9 00
      ;UTF8  é= C3 A9 (195 169)
      ;ASCII é=E9 (233)
      
      *MemoryEnd = *Memory + MemorySize(*Memory)
      
      *Ptr = *Memory
      
      MaxProgress = *MemoryEnd-*ptr
      SetGadgetAttribute(#progressbar, #PB_ProgressBar_Maximum, MaxProgress)
      time = ElapsedMilliseconds()
      
      ;Macro not used
      ;   Macro exotic()
      ;     If *Ptr\a>$C3 Or *String\a>$FF:Debug "chars over 255 are not implemented":ProcedureReturn :EndIf
      ;   EndMacro
      
      Repeat
        
        If *Ptr\a = $C2
          *Ptr + 1
        ElseIf *Ptr\a = $C3
          *Ptr + 1
          *Ptr\a + $40
        EndIf
        
        If *Ptr\a = *String\a
          *Ptr2 = *Ptr + 1
          *String + 1
          While *Ptr2\a = *String\a
            *Ptr2 + 1
            *String + 1
            If *Ptr2\a = $C2
              *Ptr2 + 1
            ElseIf *Ptr2\a = $C3;
              *Ptr2 + 1
              *Ptr2\a + $40
            EndIf
          Wend
          If *String\a = #Null
            *FoundPtr = *Ptr
            Break
          EndIf
          *String = *String0
        EndIf
        *Ptr + 1
        
        If (ElapsedMilliseconds() - time) %1000 = 0:SetGadgetState(#progressbar,*Ptr - *Memory):EndIf
        
      Until *Ptr >= *MemoryEnd
      
      SetGadgetState(#progressbar, MaxProgress)
      
      If *FoundPtr
        Result = *FoundPtr - *Memory
      EndIf
      
      ProcedureReturn Result
      
    EndProcedure
    
    ;Not used, stores in an array all offsets of the searched string
    Procedure.i Search_FindStringInMemoryAll(*Memory, String$);, Array OffSet.q(1)
      
      Protected.i StringByteLength, Result, n
      Protected *MemoryEnd, *Ptr.Ascii, *FoundPtr, *Ptr2.Ascii, *String0.Ascii, *String.Ascii
      Protected MaxProgress.q, time.q
              
      StringByteLength = StringByteLength(String$, #PB_UTF8)
      *String0         = Ascii(String$)
      *String          = *String0
      ;PB    é=E9 00
      ;UTF8  é= C3 A9 (195 169)
      ;ASCII é=E9 (233)
      
      *MemoryEnd = *Memory + MemorySize(*Memory)
      
      *Ptr = *Memory
      
      MaxProgress = *MemoryEnd-*ptr
      SetGadgetAttribute(#progressbar, #PB_ProgressBar_Maximum, MaxProgress)
      time = ElapsedMilliseconds()
      
      ;Macro not used
      ;   Macro exotic()
      ;     If *Ptr\a>$C3 Or *String\a>$FF:Debug "char case not implemented":ProcedureReturn :EndIf
      ;   EndMacro
      
      Repeat
        
        If *Ptr\a = $C2
          *Ptr + 1
        ElseIf *Ptr\a = $C3
          *Ptr + 1
          *Ptr\a + $40
        EndIf
        
        If *Ptr\a = *String\a
          *Ptr2 = *Ptr + 1
          *String + 1
          While *Ptr2\a = *String\a
            *Ptr2 + 1
            *String + 1
            If *Ptr2\a = $C2
              *Ptr2 + 1
            ElseIf *Ptr2\a = $C3
              *Ptr2 + 1
              *Ptr2\a + $40
            EndIf
          Wend
          If *String\a = #Null
            
            ReDim OffSet(n)
            OffSet(n) = *Ptr - *Memory
            n + 1
          EndIf
          *String = *String0
        EndIf
        
        *Ptr + 1
        
        If (ElapsedMilliseconds() - time) %1000 = 0:SetGadgetState(#progressbar,*Ptr - *Memory):EndIf
        
      Until *Ptr >= *MemoryEnd
      
      SetGadgetState(#progressbar, MaxProgress)
      
      Result = n
      
      ProcedureReturn Result
      
    EndProcedure
    
    ;Find the html file name
    Procedure Search_FindInRamDisk(FirstOcc=-1)
      
      Protected i, found, c=0
      Protected max=ArraySize(SearchArray())
      
      If FirstOcc =-1:ProcedureReturn -1:EndIf
      
      If FirstOcc >= 0
        i=0
        found=0
        
        Repeat
          c+1
          If SearchArray(i)<=FirstOcc
            i+1
            If i>max:Break:EndIf
          Else
            found=1
            i-1
            Break
          EndIf
        Until  i>max
        
        If found
          SelectElement(Searched_Files(),i)
        Else
          ;Debug "no found="+found
        EndIf
        
        ProcedureReturn found
        
      EndIf
      
    EndProcedure
    
    ;Find all html file name occ.
    Procedure Search_FindInRamDiskAll();Array OffSet.q(1)
      Protected i, j, found, c, offset.q, Count, f
      Protected max=ArraySize(SearchArray())
      Protected *Old_Element
      Protected line$
      
      For j=0 To ArraySize(OffSet())
        offset = OffSet(j)
        If offset<0:ProcedureReturn -1:EndIf
        
        i=0:found=0:c=0
        
        Repeat
          c+1
          If SearchArray(i)<=offset
            i+1
            If i>max:Break:EndIf
          Else
            found=1
            i-1
            Break
          EndIf
        Until  i>max
        
        If found
          *Old_Element = @Searched_Files()   
          SelectElement(Searched_Files(),i)
          If *Old_Element <> @Searched_Files()
          f = ReadFile(#PB_Any, Searched_Files())
           If f
             line$ = ReadString(f)
             line$ = Right(line$, Len(line$) - Len("<html><head><title>"))
             line$ = StringField(line$, 1 ,"<")
             AddGadgetItem(#listview_search, -1, line$)
             CloseFile(f)
           Else
            AddGadgetItem(#listview_search,-1,GetFilePart(Searched_Files(), #PB_FileSystem_NoExtension)) 
           EndIf
            SetGadgetItemData(#listview_search, Count, i)
            count = count + 1
            AddElement(Searched_Items())
            Searched_Items()\Path = Searched_Files()
          EndIf 
        Else    
        EndIf
      Next j
      
      ProcedureReturn found
      
    EndProcedure
    
    ;Browses directories
    Procedure Search_BrowseDirectory(sPath.s, *pClbFound = 0)
      Protected lDicID, qFiles.q, sDirName.s
      Static pCallBack.clbSearchFile
      
      If (Right(sPath, 1) <> #PS$):sPath + #PS$:EndIf;If (Right(sPath, 1) <> "/"): sPath + "/" : EndIf
      If (Not pCallBack): pCallBack = *pClbFound: EndIf
      CompilerIf #PB_Compiler_OS = #PB_OS_Windows
        ReplaceString(sPath, "/", "\", #PB_String_InPlace)
      CompilerEndIf
      lDicID = ExamineDirectory(#PB_Any, sPath, "*.*")
      If lDicID
        
        While NextDirectoryEntry(lDicID)
          qFiles + 1
          
          If DirectoryEntryType(lDicID) = #PB_DirectoryEntry_File
            If Not pCallBack(1, sPath + DirectoryEntryName(lDicID))
              Break
            EndIf 
          Else
            sDirName = DirectoryEntryName(lDicID)
            If (sDirName <> ".") And (sDirName <> "..")
              If pCallBack(2, sPath + sDirName)
                qFiles + Search_BrowseDirectory(sPath + sDirName)
              Else
                Break
              EndIf
            EndIf
          EndIf
        Wend
        
        FinishDirectory(lDicID)
        ProcedureReturn qFiles
      EndIf
      
    EndProcedure
    
    ;Lists all html files
    Procedure Search_Files(Type, Name$)
      If Type = 2
        ProcedureReturn #True
        
      Else
        If LCase(GetExtensionPart(Name$)) = "html"
          AddElement(Searched_Files())
          Searched_Files() = Name$
          
        EndIf
        ProcedureReturn #True
      EndIf
      
    EndProcedure
    
    ;Lists all html file containing a searched text
    Procedure Search_FindInFiles(GadgetSource.i, GadgetTarget.i, ProgressBarID = - 1)
      
      CompilerSelect #PB_Compiler_OS
          
        CompilerCase #PB_OS_Windows
          If OSVersion() <= #PB_OS_Windows_XP
            Protected a$, c$, e$, i$, o$, u$, y$, letter$, regEx$, filesource$
            Protected tmp$, tmp2$, tmpp$, result$
            Protected i, exp, exp2, format, count, f, n, z
            
            searched$ = GetGadgetText(GadgetSource)
            If Len(searched$) > 0
              exp = CreateRegularExpression(#PB_Any, "<[^>]*>")
              ;Manage accents
              a$ = "[aàâä]"
              c$ = "[cç]"
              e$ = "[eéèêë]"
              i$ = "[iîï]"
              o$ = "[oôö]"
              u$ = "[uùûü]"
              y$ = "[yÿ]"
              For i = 1 To Len(searched$)
                letter$ = Mid(searched$, i, 1)
                Select letter$
                  Case "a"
                    regEx$ + a$
                    
                  Case "c"
                    regEx$ + c$
                    
                  Case "e"
                    regEx$ + e$
                    
                  Case "i"
                    regEx$ + i$
                    
                  Case "o"
                    regEx$ + o$
                    
                  Case "u"
                    regEx$ + u$
                    
                  Case "y"
                    regEx$ + y$
                    
                  Case "i"
                    regEx$ + i$
                    
                  Default
                    regEx$ + letter$
                EndSelect
              Next i
              
              ;exp2 = CreateRegularExpression(#PB_Any, regEx$, #PB_RegularExpression_NoCase)
              
              ForEach Searched_Files()
                n + 1:SetGadgetState(#progressbar, n)
                filesource$ = Searched_Files()
                f           = ReadFile(#PB_Any, filesource$)
                ;format = ReadStringFormat(f);bug ?
                format = #PB_UTF8
                While Eof(f) = 0
                  tmp$ = ReadString(f, Format)
                  ;goto the tag body
                  If FindString(tmp$, "<body ", 0, #PB_String_NoCase) > 0
                    Break
                  EndIf
                Wend
                
                While Eof(f) = 0
                  tmp$  = ReadString(f, format)
                  tmpp$ = ReplaceString(tmp$, "&quot;", Chr(34))
                  tmpp$ = ReplaceString(tmpp$, "&amp;", "&")
                  ;result$ is the txt without html tags as good as possible
                  result$ = ReplaceRegularExpression(exp, tmpp$, "")
                  
                  If FindString(result$, "table.parameters")
                    
                  Else
                    If FindString(result$, searched$, 0, #PB_String_NoCase)
                      AddElement(Searched_Items())
                      Searched_Items()\Path = filesource$
                      tmp2$                 = GetFilePart(filesource$, #PB_FileSystem_NoExtension)
                      AddGadgetItem(GadgetTarget, - 1, tmp2$)
                      SetGadgetItemData(GadgetTarget, Count, Count)
                      count = count + 1
                      Break
                    EndIf
                  EndIf
                Wend
                CloseFile(f)
              Next
              ; FreeRegularExpression(exp2)
              FreeRegularExpression(exp)
              
              If count = 0
                MessageRequester("ATTENTION", Language::Get("Requesters", "SearchNoMatch"))
              EndIf
            Else
              ProcedureReturn 0
            EndIf
            
            ProcedureReturn count
            
          Else
            
            ;Windows > XP
            ;- ============
            Protected Found
            
            Searched$ = GetGadgetText(GadgetSource)
            If Len(Searched$) > 0              
              Count = Search_FindStringInMemoryAll(*RamDisk, Searched$);, OffSet()
              Found = Search_FindInRamDiskAll();OffSet()
              
              If Found = 0
                MessageRequester("ATTENTION", Language::Get("Requesters", "SearchNoMatch"))
                ProcedureReturn 0
              EndIf
              
              ProcedureReturn Count
            EndIf
          EndIf
          
          
          ;         CompilerCase #PB_OS_Linux
          ;         CompilerCase #PB_OS_MacOS
        CompilerDefault
          ;Linux + MacOS
          Protected Count, Found
          
          Searched$ = GetGadgetText(GadgetSource)
          If Len(Searched$) > 0
            Count = Search_FindStringInMemoryAll(*RamDisk, Searched$,  OffSet())
            Found = Search_FindInRamDiskAll(OffSet())
            
            If Found = 0
              MessageRequester("ATTENTION", Language::Get("Requesters", "SearchNoMatch"))
              ProcedureReturn 0
            EndIf
            
            ProcedureReturn Count
          EndIf
          
      CompilerEndSelect
      
    EndProcedure
    
    ;Not used: Use OS procedure to find a text in a virtual drive, Windows only
    Procedure Search_InVirtualDrive(vpath.s, find.s)
      
      CompilerIf #PB_Compiler_OS = #PB_OS_Windows
        Protected txt.s = "/c findstr /s /i /m " + find + " " + vpath + "*.html"
        Protected Virtual, Output$, item$, n
        
        Virtual = RunProgram("cmd", txt, vpath, #PB_Program_Open | #PB_Program_Read | #PB_Program_Hide)
        Output$ = ""
        If Virtual
          While ProgramRunning(Virtual)
            If AvailableProgramOutput(Virtual)
              Output$ = ReadProgramString(Virtual)
              If Output$
                item$ = Output$
                AddElement(Searched_Items())
                Searched_Items()\Path = item$
                AddGadgetItem(#listview_search, - 1, GetFilePart(item$, #PB_FileSystem_NoExtension))
                SetGadgetItemData(#listview_search, n, n)
                n + 1
              EndIf
            EndIf
          Wend
          CloseProgram(Virtual)
        EndIf
      CompilerEndIf
      
    EndProcedure
    
    ;Search and highlight a text in a webpage, in using jscript
    Procedure SearchInHtml()
      
      Protected ori$, Result$, p$
      Protected script$ = ~"<meta charset=\"utf-8\"><script> function highlightAll(keyWords) { document.getElementById('hid_search_text').value = keyWords; document.designMode = \"on\"; var sel = window.getSelection(); sel.collapse(document.body, 0); while (window.find(keyWords)) { document.execCommand(\"HiliteColor\", false, \"yellow\"); sel.collapseToEnd(); } document.designMode = \"off\"; goTop(keyWords,1); } function removeHighLight() { var keyWords = document.getElementById('hid_search_text').value; document.designMode = \"on\"; var sel = window.getSelection(); sel.collapse(document.body, 0); while (window.find(keyWords)) { document.execCommand(\"HiliteColor\", false, \"transparent\"); sel.collapseToEnd(); } document.designMode = \"off\"; goTop(keyWords,0); } function goTop(keyWords,findFirst) { if(window.document.location.href = '#') { if(findFirst) { window.find(keyWords, 0, 0, 1); } } } </script> <style> #search_para { color:grey; } .highlight { background-color: #FF6; } </style> <div id=\"wrapper\"> <input type=\"text\" id=\"search_text\" name=\"search_text\"> &nbsp; <input type=\"hidden\" id=\"hid_search_text\" name=\"hid_search_text\"> <input type=\"button\" value=\"Search\" id=\"search\" onclick=\"highlightAll(document.getElementById('search_text').value)\" > &nbsp; <input type=\"button\" value=\"Remove\" id=\"remove\" onclick=\"removeHighLight()\" ></div>"
      ;         Protected script$ = ~"<meta charset=\"utf-8\"><script> "
      ;         script$ + ~"function highlightAll(keyWords)"
      ;         script$ + ~"{ document.getElementById('hid_search_text').value = keyWords;"
      ;         script$ + ~"document.designMode = \"on\"; var sel = window.getSelection();"
      ;         script$ + ~"sel.collapse(document.body, 0);"
      ;         script$ + ~"While (window.find(keyWords))"
      ;         script$ + ~"{ document.execCommand(\"HiliteColor\", false, \"yellow\");"
      ;         script$ + ~"sel.collapseToEnd() "                                      ; }"
      ;         script$ + ~"document.designMode = \"off\"; goTop(keyWords,1); }"
      ;         script$ + ~"function removeHighLight() "
      ;         script$ + ~"{ var keyWords = document.getElementById('hid_search_text').value;"
      ;         script$ + ~"document.designMode = \"on\"; "
      ;         script$ + ~"var sel = window.getSelection(); "
      ;         script$ + ~"sel.collapse(document.body, 0); "
      ;         script$ + ~"While (window.find(keyWords)) "
      ;         script$ + ~"{ document.execCommand(\"HiliteColor\", false, \"transparent\"); "
      ;         script$ + ~"sel.collapseToEnd()                                            ; "
      ;         script$ + ~"} document.designMode = \"off\"; "
      ;         script$ + ~"goTop(keyWords,0)              ; } "
      ;         script$ + ~"function goTop(keyWords,findFirst) "
      ;         script$ + ~"{ If(window.document.location.href = '#') "
      ;         script$ + ~"{ If(findFirst) { window.find(keyWords, 0, 0, 1); } } } </script> "
      ;         script$ + ~"<style> #search_para { color:grey             ; } "
      ;         script$ + ~".highlight { background-color: #FF6           ; } "
      ;         script$ + ~"</style> "
      ;         script$ + ~"<div id=\"wrapper\"> "
      ;         script$ + ~"<input type=\"text\" id=\"search_text\" name=\"search_text\" value=\"est\"> &nbsp; "
      ;         script$ + ~"<input type=\"hidden\" id=\"hid_search_text\" name=\"hid_search_text\"> "
      ;         script$ + ~"<input type=\"button\" value=\"Search\" id=\"search\" "
      ;         script$ + ~"onclick=\"highlightAll(document.getElementById('search_text').value)\" > &nbsp; "
      ;         script$ + ~"<input type=\"button\" value=\"Remove\" id=\"remove\" onclick=\"removeHighLight()\" >"
      ;         script$ + ~"</div>"
      Protected f, gadget, selected, position
      
      script$ = ReplaceString(script$, ~"\"Search\"", Language::Get("Requesters", "Search"));~"\"Rechercher\""
      script$ = ReplaceString(script$, ~"\"Remove\"", Language::Get("Requesters", "Remove"));~"\"Annuler\""
      
      If GetGadgetData(#tree_summarynoicons)
        gadget = #tree_summary
      Else
        gadget = #tree_summarynoicons
      EndIf
      
      ;ori$ = GetGadgetItemText(WebDisplay, #PB_Web_HtmlCode)
      f = ReadFile(#PB_Any, CurrentPath, #PB_UTF8 )
      While Eof(f) = 0
        ori$ + ReadString(f, #PB_UTF8)
      Wend
      CloseFile(f)
      
      position = FindString(ori$, "<body ", #PB_String_NoCase)
      Result$  = InsertString(ori$, script$, Position)
      SetGadgetItemText(WebDisplay, #PB_Web_HtmlCode, Result$)
      
    EndProcedure
    
    ;Recreate several internal files after an update of html files (new version of PB)
    ;This update has to be made manually
    Procedure Search_Check(Update = #False)
      Protected f, g, templen.q, size.q, dir, c, i, length.q, bytes.q, fbytes.q
      Protected ListOfHtmlWin$ = Path$ + "Help" + #PS$ + "ListOfHtmlWin.txt"; on hdd
      Protected ListOfHtmlLinMac$ = Path$ + "Help" + #PS$ + "ListOfHtmlLinMac.txt"; on hdd
      Protected ListOfHtmlvd$ = PathHelp$ + "ListOfHtml.txt"                      ; on virtual drive
      Protected ListOfHtmlSize$ = Path$ + "Help" + #PS$ + "ListOfHtmlSize"        ; on hdd
      Protected ListOfHtmlSizevd$ = PathHelp$ + "ListOfHtmlSize.txt"              ; on virtual drive
      Protected fRamDisk$ = Path$ + "Help" + #PS$ + "RamDisk"                     ; on hdd
      Protected fRamDiskvd$ = PathHelp$ + "RamDisk"                               ; on virtual drive
      Protected dirname$, tmp$                                                   
      Protected Dim dirlang.s(0)
      Protected *MemoryID
      
      ;Check "ListOfHtmlxxx.txt", a file with html files name only
      If Update = #False
        If FileSize(ListOfHtmlWin$) <= 0
          ClearList(Searched_Files())
          Search_BrowseDirectory(PathHelp$ + UserLanguage$, @Search_Files())
          f = CreateFile(#PB_Any, ListOfHtmlWin$, #PB_UTF8)
          If f
            WriteStringN(f, Str(#version))
            ForEach Searched_Files()
              tmp$ = RemoveString(Searched_Files(),PathHelp$ + UserLanguage$ + #PS$)
              WriteStringN(f, ReplaceString(tmp$, "/", "\", #PB_String_InPlace))
            Next
            CloseFile(f)
          EndIf
        Else
          ;Debug ListOfHtmlWin$+" ok"
        EndIf
        
        If FileSize(ListOfHtmlLinMac$) <= 0;>0;
          ClearList(Searched_Files())
          If f=0
            Search_BrowseDirectory(PathHelp$ + UserLanguage$, @Search_Files())
          EndIf
          g = CreateFile(#PB_Any, ListOfHtmlLinMac$, #PB_UTF8)
          If g
            WriteStringN(g, Str(#version))
            ForEach Searched_Files()
              tmp$ = RemoveString(Searched_Files(),PathHelp$ + UserLanguage$ + #PS$)
              ReplaceString(tmp$, "\", "/", #PB_String_InPlace)
              WriteStringN(g, tmp$)
            Next
            CloseFile(g)
          EndIf
        Else
          ;Debug ListOfHtmlLinMac$+" ok"
        EndIf
        
      Else; Update = #True
          ;Create "ListOfHtmlxxx.txt", a file with html files name only
        ClearList(Searched_Files())
        Search_BrowseDirectory(PathHelp$ + UserLanguage$, @Search_Files())
        f = CreateFile(#PB_Any, ListOfHtmlWin$, #PB_UTF8)
        If f
          WriteStringN(f, Str(#version))
          ForEach Searched_Files()
            tmp$ = RemoveString(Searched_Files(),PathHelp$ + UserLanguage$ + #PS$)
            WriteStringN(f, ReplaceString(tmp$, "/", "\", #PB_String_InPlace))
          Next
          CloseFile(f)
        EndIf
        
        ClearList(Searched_Files())
        If f=0
          Search_BrowseDirectory(PathHelp$ + UserLanguage$, @Search_Files())
        EndIf
        g = CreateFile(#PB_Any, ListOfHtmlLinMac$, #PB_UTF8)
        If g
          WriteStringN(g, Str(#version))
          ForEach Searched_Files()
            tmp$ = RemoveString(Searched_Files(),PathHelp$ + UserLanguage$ + #PS$)
            ReplaceString(tmp$, "\", "/", #PB_String_InPlace)
            WriteStringN(g, tmp$)
          Next
          CloseFile(g)
        EndIf
      EndIf
      
      ;Check "ListOfHtmlSizexx" files with files size (html only) for each languages
      ;How many languages
      dir = ExamineDirectory(#PB_Any, PathHelpHD$, "*.*")
      If dir
        While NextDirectoryEntry(dir)
          If DirectoryEntryType(dir) = #PB_DirectoryEntry_Directory
            dirname$ = Trim(DirectoryEntryName(dir))
            If dirname$ = "." Or dirname$ = ".."
            Else
              dirlang(c) = dirname$
              c + 1
              ReDim dirlang(c)
            EndIf
          EndIf
        Wend
        FinishDirectory(dir)
      EndIf
      
      ;Check file size   
      If Update = #False
        For i = 0 To c-1
          If FileSize(ListOfHtmlSize$+dirlang(i)) <= 0;>0;
            ClearList(Searched_Files())
            Search_BrowseDirectory(PathHelp$ + dirlang(i), @Search_Files())
            ClearList(Searched_FilesSize())
            ;Fill file size list
            AddElement(Searched_FilesSize())
            Searched_FilesSize() = 0
            ForEach Searched_Files()
              size = FileSize(Searched_Files())
              templen = templen + size 
              AddElement(Searched_FilesSize())
              Searched_FilesSize() = templen    
            Next
            ;Create the file size
            f = CreateFile(#PB_Any, ListOfHtmlSize$+dirlang(i), #PB_UTF8)
            If f
              WriteStringN(f, Str(#version))
              ForEach Searched_FilesSize()
                WriteQuad(f, Searched_FilesSize())
              Next
              CloseFile(f)
            EndIf
          Else
            ;Debug ListOfHtmlSize$+dirlang(i) +" ok"          
          EndIf   
        Next i  
      Else; Update = #True
          ;Create files size
        For i = 0 To c-1
          ClearList(Searched_Files())
          Search_BrowseDirectory(PathHelp$ + dirlang(i), @Search_Files())
          ClearList(Searched_FilesSize())
          ;Fill file size list
          AddElement(Searched_FilesSize())
          Searched_FilesSize() = 0
          ForEach Searched_Files()
            size = FileSize(Searched_Files())
            templen = templen + size 
            AddElement(Searched_FilesSize())
            Searched_FilesSize() = templen    
          Next
          ;Create the file size
          f = CreateFile(#PB_Any, ListOfHtmlSize$+dirlang(i), #PB_UTF8)
          If f
            WriteStringN(f, Str(#version))
            ForEach Searched_FilesSize()
              WriteQuad(f, Searched_FilesSize())
            Next
            CloseFile(f)
          EndIf 
        Next i  
      EndIf
      
      ;Make a big html file ("RamDiskxx") to use as a ramdisk
      If Update = #False
        For i = 0 To c-1
          If FileSize(fRamDisk$+dirlang(i)) <= 0
            f=CreateFile(#PB_Any, fRamDisk$+dirlang(i), #PB_UTF8)
            If f
              ClearList(Searched_Files())
              Search_BrowseDirectory(PathHelp$ + dirlang(i), @Search_Files())
              ForEach Searched_Files()
                g=ReadFile(#PB_Any, Searched_Files(), #PB_UTF8)
                If g
                  length = Lof(g)
                  *MemoryID = AllocateMemory(length)
                  If *MemoryID
                    bytes = ReadData(g, *MemoryID, length)
                    fbytes + bytes
                  EndIf
                  CloseFile(g)
                EndIf
                WriteData(f, *MemoryID, length)
                FreeMemory(*MemoryID)
              Next
              CloseFile(f)
            EndIf 
          Else
            ;Debug fRamDisk$+dirlang(i)+" ok"  
          EndIf   
        Next i      
        
      Else; Update = #True
          ;Create Ramdiskxx
        For i = 0 To c-1
          f=CreateFile(#PB_Any, fRamDisk$+dirlang(i), #PB_UTF8)
          If f
            ClearList(Searched_Files())
            Search_BrowseDirectory(PathHelp$ + dirlang(i), @Search_Files())
            ForEach Searched_Files()
              g=ReadFile(#PB_Any, Searched_Files(), #PB_UTF8)
              If g
                length = Lof(g)
                *MemoryID = AllocateMemory(length)
                If *MemoryID
                  bytes = ReadData(g, *MemoryID, length)
                  fbytes + bytes
                EndIf
                CloseFile(g)
              EndIf
              WriteData(f, *MemoryID, length)
              FreeMemory(*MemoryID)
            Next
            CloseFile(f)
          EndIf   
        Next i     
      EndIf
      
    EndProcedure
    
    ;Prepares all things needed to make a search in the html files
    Procedure Search_Init()
      Protected f, length.q, bytes.q, size.q, templen.q, i
      Protected Path$
      Protected fHelp$ = PathHelp$ + "RamDisk" + UserLanguage$
      
      ;Check if needed files to make a search are present
      Search_Check()
      
      ;Fill Search_Files() (list of html files) 
      ClearList(Searched_Files())
      Search_BrowseDirectory(PathHelp$ + UserLanguage$ , @Search_Files())
      
      ;Fill Searched_FilesSize.q()  (list of size of html files) 
      ClearList(Searched_FilesSize())
      AddElement(Searched_FilesSize())
      Searched_FilesSize() = 0
      ForEach Searched_Files()
        size = FileSize(Searched_Files())
        templen = templen + size 
        AddElement(Searched_FilesSize())
        Searched_FilesSize() = templen    
      Next

      ; Fill Searched_Filessize() into an array which will be much faster
      ResetList(Searched_Filessize())
      ReDim  SearchArray(ListSize(Searched_Filessize()))
      For i = 0 To ListSize(Searched_Filessize()) - 1
        NextElement(Searched_Filessize())
        SearchArray(i) = Searched_Filessize()
      Next i
      
      ;Create the pseudo ramdisk
      f = ReadFile(#PB_Any, fHelp$)
      If f
        length = Lof(f)                            
        *RamDisk = AllocateMemory(length)         
        If *RamDisk
          bytes = ReadData(f, *RamDisk, length)  
        EndIf
        CloseFile(f)
      EndIf
      
    EndProcedure
    
    ;Main procedure to find a text in a webpage = first of all get all html files name
    Procedure SearchInFiles()
      Protected f
      Protected filename$
      
      If ListSize(Searched_Files()) > 0
        Search_FindInFiles(#string_search, #listview_search)
      EndIf
      
    EndProcedure
    
    ;-
    ;- WEB ZOOM
    ;- ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Windows
        
        ;Get the webpage zoom
        Procedure WebGadget_GetZoom(webgadget)
          CompilerIf #PB_Compiler_Version < 610
            #OLECMDID_OPTICAL_ZOOM        = 63
            #OLECMDEXECOPT_DONTPROMPTUSER = 2
            Protected WebObject.IWebBrowser2, zoom.VARIANT
            WebObject = GetWindowLongPtr_(GadgetID(webgadget), #GWL_USERDATA)
            If WebObject
              WebObject\ExecWB(#OLECMDID_OPTICAL_ZOOM, #OLECMDEXECOPT_DONTPROMPTUSER, 0, @zoom) ; get current zoom level in percent
              ProcedureReturn zoom\iVal
            EndIf
          CompilerElse
            
            Protected Result.d
            Protected Controller.ICoreWebView2Controller
            
            If GadgetType(WebDisplay) = #PB_GadgetType_WebView
              Controller = GetGadgetAttribute(WebDisplay, #PB_WebView_ICoreController)
              If Controller
                Controller\get_ZoomFactor(@Result)
              EndIf
            EndIf
            If GadgetType(WebDisplay) = #PB_GadgetType_Web
              Controller = GetGadgetAttribute(WebDisplay, #PB_Web_ICoreController)
              If Controller
                Controller\get_ZoomFactor(@Result)
              EndIf
            EndIf
            
            Result = Result * 100
            
            ProcedureReturn Result
            
          CompilerEndIf
        EndProcedure
        
        ;Set the webpage zoom
        Procedure WebGadget_SetZoom(webgadget, percent)
          CompilerIf #PB_Compiler_Version < 610
            Protected WebObject.IWebBrowser2, zoom.VARIANT
            WebObject = GetWindowLongPtr_(GadgetID(webgadget), #GWL_USERDATA)
            If WebObject
              If percent < 10 : percent = 10 : EndIf
              If percent > 1000 : percent = 1000 : EndIf
              zoom\vt   = 3
              zoom\iVal = percent
              WebObject\ExecWB(#OLECMDID_OPTICAL_ZOOM, #OLECMDEXECOPT_DONTPROMPTUSER, @zoom, 0) ; set new zoom level in percent (10 - 1000)
                                                                                                ;               Zoom=percent
            EndIf
          CompilerElse
            Protected Controller.ICoreWebView2Controller
            
            If GadgetType(WebDisplay) = #PB_GadgetType_WebView
              Controller = GetGadgetAttribute(WebDisplay, #PB_WebView_ICoreController)
              If Controller
                Controller\put_ZoomFactor(zoom / 100)
              EndIf
            EndIf
            If GadgetType(WebDisplay) = #PB_GadgetType_Web
              Controller = GetGadgetAttribute(WebDisplay, #PB_Web_ICoreController)
              If Controller
                Controller\put_ZoomFactor(zoom / 100)
              EndIf
            EndIf
            
          CompilerEndIf
          
        EndProcedure
        
        ; Not used, increase zoom
        Procedure WebGadget_IncreaseZoom(webgadget, percent = 20)
          CompilerIf #PB_Compiler_Version < 610
            Protected WebObject.IWebBrowser2, zoom.VARIANT
            WebObject = GetWindowLongPtr_(GadgetID(webgadget), #GWL_USERDATA)
            If WebObject
              WebObject\ExecWB(#OLECMDID_OPTICAL_ZOOM, #OLECMDEXECOPT_DONTPROMPTUSER, 0, @zoom) ; get current zoom level in percent
              zoom\iVal + percent
              If zoom\iVal > 1000 : zoom\iVal = 1000 : EndIf
              WebObject\ExecWB(#OLECMDID_OPTICAL_ZOOM, #OLECMDEXECOPT_DONTPROMPTUSER, @zoom, 0) ; set zoom level
            EndIf
          CompilerElse
            
          CompilerEndIf
          
        EndProcedure
        
        ; Not used, decrease zoom
        Procedure WebGadget_DecreaseZoom(webgadget, percent = 20)
          CompilerIf #PB_Compiler_Version < 610
            Protected WebObject.IWebBrowser2, zoom.VARIANT
            WebObject = GetWindowLongPtr_(GadgetID(webgadget), #GWL_USERDATA)
            If WebObject
              WebObject\ExecWB(#OLECMDID_OPTICAL_ZOOM, #OLECMDEXECOPT_DONTPROMPTUSER, 0, @zoom) ; get current zoom level in percent
              zoom\iVal - percent
              If zoom\iVal < 10 : zoom\iVal = 10 : EndIf
              WebObject\ExecWB(#OLECMDID_OPTICAL_ZOOM, #OLECMDEXECOPT_DONTPROMPTUSER, @zoom, 0) ; set zoom level
            EndIf
          CompilerElse
            
          CompilerEndIf
          
        EndProcedure
        
        ;Not used, Open the dev tools Window
        Procedure WebView_OpenDevToolsWindow(WebViewGadget)
          
          CompilerIf #PB_Compiler_Version < 610
          CompilerElse
            If IsGadget(WebViewGadget) = 0 : ProcedureReturn : EndIf
            If GadgetType(WebViewGadget) <> #PB_GadgetType_WebView : ProcedureReturn : EndIf
            
            Protected Controller.ICoreWebView2Controller
            Protected Core.ICoreWebView2
            Controller = GetGadgetAttribute(WebViewGadget, #PB_WebView_ICoreController)
            Controller\get_CoreWebView2(@Core)
            Core\OpenDevToolsWindow()
          CompilerEndIf
          
        EndProcedure
        
        ;   CompilerCase #PB_OS_Linux
        ;   CompilerCase #PB_OS_MacOS
        
      CompilerDefault
        
        ;Get the webpage zoom
        Procedure.d WebView_GetZoom(WebView)
          Protected Result.d
          Protected Controller.ICoreWebView2Controller
          
          If GadgetType(WebView) = #PB_GadgetType_WebView
            Controller = GetGadgetAttribute(WebView, #PB_WebView_ICoreController)
            If Controller
              Controller\get_ZoomFactor(@Result)
            EndIf
          EndIf
          Result = Result * 100
          ProcedureReturn Result
          
        EndProcedure
        
        ;Set the webpage zoom
        Procedure.i WebView_SetZoom(WebView, zzoom.d = 100)
          Protected Controller.ICoreWebView2Controller
          
          If GadgetType(WebView) = #PB_GadgetType_WebView
            Controller = GetGadgetAttribute(WebView, #PB_WebView_ICoreController)
            If Controller
              Controller\put_ZoomFactor(zzoom / 100)
            EndIf
          EndIf
          
        EndProcedure
        
        ;Not used, Open the dev tools Window
        Procedure WebView_OpenDevToolsWindow(WebViewGadget)
          CompilerIf #PB_Compiler_Version < 610
          CompilerElse
            If IsGadget(WebViewGadget) = 0 : ProcedureReturn : EndIf
            If GadgetType(WebViewGadget) <> #PB_GadgetType_WebView : ProcedureReturn : EndIf
            
            Protected Controller.ICoreWebView2Controller
            Protected Core.ICoreWebView2
            Controller = GetGadgetAttribute(WebViewGadget, #PB_WebView_ICoreController)
            Controller\get_CoreWebView2(@Core)
            Core\OpenDevToolsWindow()
          CompilerEndIf
          
        EndProcedure
        
    CompilerEndSelect
    
    
    ;-
    ;- VIRTUAL DRIVE
    ;- ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    ;Win only, set a virtual drive ("Z") to make searches faster
    Procedure SetVirtualDrive(drive.s, path.s)
      
      CompilerSelect #PB_Compiler_OS
        CompilerCase #PB_OS_Windows
          Protected txt.s, Output$
          Protected Virtual, n
          path = Left(path, Len(path) - 1)
          txt  = "/c subst " + drive + " " + path
          RunProgram("cmd", txt, "", #PB_Program_Wait | #PB_Program_Hide)
          ;/c subst
          Virtual = RunProgram("cmd", "/c dir " + VirtualDrive + ":", "", #PB_Program_Open | #PB_Program_Read | #PB_Program_Hide)
          Output$ = ""
          If Virtual
            While ProgramRunning(Virtual)
              If AvailableProgramOutput(Virtual)
                Output$ = ReadProgramString(Virtual)
                n + 1
                If n > 3
                  Break
                EndIf
              EndIf
            Wend
            CloseProgram(Virtual)
          EndIf
          
          If n > 1
            PathHelp$ = drive + "\"
            PathHTML$ = drive + "/"
          EndIf
        CompilerDefault
      CompilerEndSelect
      
    EndProcedure
    
    ;Close the virtual drive
    Procedure DelVirtualDrive(drive.s)
      
      CompilerSelect #PB_Compiler_OS
        CompilerCase #PB_OS_Windows
          Protected txt.s = "/c subst " + drive
          txt.s = "/c subst /D " + drive
          RunProgram("cmd ", txt, "", #PB_Program_Wait | #PB_Program_Hide)
        CompilerDefault
      CompilerEndSelect
      
    EndProcedure
    
    ;-
    ;- PREFERENCES
    ;- ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    ;Read the preference file
    Procedure PreferencesRead()
      Protected tmp$
      
      If OpenPreferences(Preference$, #PB_Preference_GroupSeparator)
        
        PreferenceGroup("LANG")
        UserLanguage$ = ReadPreferenceString("lang", "en")
        
        PreferenceGroup("MAINWINDOW")
        ;Fills global variable to open the main window, fullscreen or resize
        Preferences("fullscreen") = ReadPreferenceString("fullscreen", "1")
        Preferences("x")          = ReadPreferenceString("x", "0")
        Preferences("y")          = ReadPreferenceString("y", "0")
        Preferences("w")          = ReadPreferenceString("w", "1024")
        Preferences("h")          = ReadPreferenceString("h", "720")
        MainWindows_X             = Val(Preferences("x"))
        MainWindows_Y             = Val(Preferences("y"))
        MainWindows_W             = Val(Preferences("w"))
        MainWindows_H             = Val(Preferences("h"))
        
        ;Splitter pos
        Preferences("xsplitter") = ReadPreferenceString("xsplitter", "238")
        
        ;Icon size
        Preferences("iconsize") = ReadPreferenceString("iconsize", "32")
        IconSize                = Val(Preferences("iconsize"))
        
        ;Fonts
        Preferences("font")           = Trim(ReadPreferenceString("font", ""))
        Preferences("fontsize")       = ReadPreferenceString("fontsize", "0")
        Preferences("fontstyle")      = ReadPreferenceString("fontstyle", "0")
        Preferences("fontcolour")     = ReadPreferenceString("fontcolour", "0")
        Preferences("fontlist")       = Trim(ReadPreferenceString("fontlist", ""))
        Preferences("fontsizelist")   = ReadPreferenceString("fontsizelist", "0")
        Preferences("fontstylelist")  = ReadPreferenceString("fontstylelist", "0")
        Preferences("fontcolourlist") = ReadPreferenceString("fontcolourlist", "0")
        
        ;Zoom
        Zoom = ReadPreferenceFloat("zoom", 100.00)
        
        ;Summary with icons yes/no
        Preferences("iconsinsummary") = ReadPreferenceString("iconsinsummary", "1")
        
        ;Get summary file
        CurrentSummary = PathHelpHD$ + UserLanguage$ + #PS$ + Trim(ReadPreferenceString("summary", "contents.xml"))
        Summary3D      = ReadPreferenceInteger("summary3D", 0)
        
        ;Get index file
        CurrentIndex = PathHelpHD$ + UserLanguage$ + #PS$ + Trim(ReadPreferenceString("index", "index.xml"))
        
        ;Color some items in the summary tree
        PreferenceGroup("COLOREDITEMS")
        ExaminePreferenceKeys()
        While  NextPreferenceKey()
          AddElement(ItemColor())
          ItemColor()\item = Val(Trim(PreferenceKeyName()))
          tmp$ = PreferenceKeyValue()
          ItemColor()\textcolor = Val(StringField(tmp$, 1, ","))
          ItemColor()\bkgcolor = Val(StringField(tmp$, 2, ","))
        Wend
        
        ClosePreferences()
        
      EndIf
      
    EndProcedure
    
    ;Applies the preferences
    Procedure PreferencesInit()
      Protected nf
      Protected tmp$
      
      ;"MAINWINDOW"
      If Val(Preferences("fullscreen"))
        SetWindowState(DialogWindow(1), #PB_Window_Maximize)
      Else
        ResizeWindow(DialogWindow(1),
                     MainWindows_x,
                     MainWindows_y,
                     MainWindows_w,
                     MainWindows_h)
      EndIf
      
      ;Fonts
      If Val(Preferences("fontsize")) > 0
        nf = LoadFont(#PB_Any, Preferences("font"), Val(Preferences("fontsize")), Val(Preferences("fontstyle")))
        If nf
          SetGadgetFont(#text_Maskpanel, FontID(nf))
          SetGadgetFont(#text_previous, FontID(nf))
          SetGadgetFont(#text_Next, FontID(nf))
          SetGadgetFont(#text_Home, FontID(nf))
          SetGadgetFont(#text_Print, FontID(nf))
          SetGadgetFont(#text_Searches, FontID(nf))
          SetGadgetFont(#text_Options, FontID(nf))
          SetGadgetFont(#text_Zoom, FontID(nf))
          SetGadgetFont(#panel, FontID(nf))
          SetGadgetFont(#tree_summary, FontID(nf))
          SetGadgetFont(#text_index, FontID(nf))
          SetGadgetFont(#string_index, FontID(nf))
          SetGadgetFont(#listview_index, FontID(nf))
          SetGadgetFont(#button_index, FontID(nf))
          SetGadgetFont(#text_search, FontID(nf))
          SetGadgetFont(#string_Search, FontID(nf))
          SetGadgetFont(#button_searchlist, FontID(nf))
          SetGadgetFont(#text_selectsection, FontID(nf))
          SetGadgetFont(#listview_search, FontID(nf))
          SetGadgetFont(#button_search, FontID(nf))
          SetGadgetFont(#text_favorite, FontID(nf))
          SetGadgetFont(#listview_favorite, FontID(nf))
          SetGadgetFont(#button_favoritedel, FontID(nf))
          SetGadgetFont(#button_favorite, FontID(nf))
          SetGadgetFont(#text_sectioncurrent, FontID(nf))
          SetGadgetFont(#string_favoritesectioncurrent, FontID(nf))
          SetGadgetFont(#button_favoriteadd, FontID(nf))
        EndIf
      EndIf
      
      ;Font list
      If Val(Preferences("fontsizelist")) > 0
        nf = LoadFont(#PB_Any, Preferences("fontlist"), Val(Preferences("fontsizelist")), Val(Preferences("fontstylelist")))
        If nf
          SetGadgetFont(#tree_summary, FontID(nf))
          SetGadgetFont(#tree_summarynoicons, FontID(nf))
          SetGadgetFont(#listview_index, FontID(nf))
          SetGadgetFont(#listview_search, FontID(nf))
          SetGadgetFont(#listview_favorite, FontID(nf))
        EndIf
      EndIf
      
      ;Colour list
      nf = Val(Preferences("fontcolourlist"))
      If nf
        SetGadgetColor(#tree_summary, #PB_Gadget_FrontColor, nf)
        SetGadgetColor(#tree_summarynoicons, #PB_Gadget_FrontColor, nf)
        SetGadgetColor(#listview_index, #PB_Gadget_FrontColor, nf)
        SetGadgetColor(#listview_search, #PB_Gadget_FrontColor, nf)
        SetGadgetColor(#listview_favorite, #PB_Gadget_FrontColor, nf)
      EndIf
      
      ;Zoom
      CompilerSelect #PB_Compiler_OS
        CompilerCase #PB_OS_Windows
          WebGadget_SetZoom(#web, Zoom)
        CompilerDefault
          WebView_SetZoom(WebDisplay, zoom)
      CompilerEndSelect
      SetGadgetState(#Zoom, zoom)
      SetGadgetText(#text_Zoom, "Zoom = " + Str(zoom) + " %")
      
      ;Summary with icons ?
      If Val(Preferences("iconsinsummary")) = 1
      Else
        IconsInSummary()
      EndIf
      
      ;Splitter pos
      ;no efficiency, so it is in the H_Main.pb file => InitSplitter()
      
      RefreshDialog2()
      
    EndProcedure
    
    ;Uodates the preference file
    Procedure PreferencesUpdate()
      Protected font$, size, style
      
      If OpenPreferences(Preference$, #PB_Preference_GroupSeparator)
        PreferenceGroup("MAINWINDOW")
        
        ;Fullscreen or resize
        If GetWindowState(DialogWindow(1)) = #PB_Window_Maximize
          WritePreferenceInteger("fullscreen", 1)
        Else
          WritePreferenceInteger("x", WindowX(DialogWindow(1)))
          WritePreferenceInteger("y", WindowY(DialogWindow(1)))
          WritePreferenceInteger("w", WindowWidth(DialogWindow(1)))
          WritePreferenceInteger("h", WindowHeight(DialogWindow(1)))
        EndIf
        
        ;Splitter pos
        WritePreferenceInteger("xsplitter", GetGadgetState(#splitter))
        
        ;Icon size
        If IconSize
          WritePreferenceInteger("iconsize", IconSize)
        Else
          WritePreferenceInteger("iconsize", 32)
        EndIf
        
        ;Fonts
        WritePreferenceString("font", Preferences("font"))
        WritePreferenceString("fontsize", Preferences("fontsize"))
        WritePreferenceString("fontstyle", Preferences("fontstyle"))
        WritePreferenceString("fontcolour", Preferences("fontcolour"))
        WritePreferenceString("fontlist", Preferences("fontlist"))
        WritePreferenceString("fontsizelist", Preferences("fontsizelist"))
        WritePreferenceString("fontstylelist", Preferences("fontstylelist"))
        WritePreferenceString("fontcolourlist", Preferences("fontcolourlist"))
        
        ;Zoom = 100.00
        Zoom = GetGadgetState(#Zoom)
        WritePreferenceString("zoom", StrF(zoom, 2))
        
        ;Summary
        If GetMenuItemState(#MainForm_ToolBar_OptionPopUp, #ToolBar_OptionPopUp_Icons) = #False
          WritePreferenceInteger("iconsinsummary", 0)
        Else
          WritePreferenceInteger("iconsinsummary", 1)
        EndIf
        WritePreferenceInteger("summary3D", Summary3D)
        WritePreferenceString("summary", GetFilePart(CurrentSummary))
        
        ;Index (because there is only one file, no choices, so no update
        ;           WritePreferenceString("index", GetFilePart(CurrentIndex))
        
        ;Favorites
        UpdateFavorites()
        
        ;Color items in the summary tree
        TreeUpdateItemsColors()
        
        ClosePreferences()
        
      EndIf
      
    EndProcedure
    
    ;-
    ;- HISTORY
    ;- ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    ;A browse history
    Procedure SetHistory()
      
      AddElement(History())
      History() = 0
      
    EndProcedure
    
    ;-
    ;- Post init, just before showing the main window
    ;- ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    
    ; THIS PROCEDURE MAKES ALL INITIALIZATIONS. IT IS IN THE H_Main.pb FILE
    
    Procedure Init()
      
      PreferencesRead(); Open, read and close the PureHelp.prefs
      
      SwitchWebGadget(); On Windows, we use a webgadget but on linux & osx, we use a webview
      
      Images()         ; Load icons
      
      SetWindowsTheme(); Needed to put big icons in the treegadget (Windows only & protected with a compilerif)
      
      SetVirtualDrive(VirtualDrive + ":", PathHelp$); Virtual drive for faster research (Windows only & protected with a compilerif)
      
      PreferencesInit(); Apply preferences: GUI, splitter, zoom, etc
      
      Setlang(); Set language (find, load and apply language)
      
      ;Here, every procedure needs a language setted by Setlang()
      
      InitWebXP(); Special WebGadget init for Windows XP
      
      ;TODO (accelerators are not implemented)
      
      UnderscoreTextGadget();Fix wrong display with underscored text in TextGadget, (Windows only & protected with a compilerif)
      
      ; Hide the treegadget without icons (to fix a bug when you delete all icons in a tregadget)
      SetGadgetData(#tree_summarynoicons, 1); is hidden
      
      PopUpMenus(); Create the Treegadget popup menu
      
      FillSummary(#tree_summary, CurrentSummary); Fill the treegadgets with the tables of contents
      FillSummary(#tree_summarynoicons, CurrentSummary)
      SetGadgetState(#tree_summary, 0)
      SetGadgetState(#tree_summarynoicons, 0)
      TreeItemColorInit(); Colors some items
      
      FillIndex(#listview_index, CurrentIndex); Fill the index
      
      FillFavorites();Fill favorites from preference file
      
      OnClick_Home(); Display Home page
      
      TreeParentChild(#tree_summary);Set Icons in the summary tree: book open/book closed/file
      
      Search_Init();Init Ramdisk and everything to accelerate searches
      StringGReturnKeyInit();ReturnKey event on a StringGadget
      
      SetHistory()
      
      CountInit + 1
      
      ;RefreshDialog2()
      
    EndProcedure
    
; IDE Options = PureBasic 6.30 beta 3 (Windows - x64)
; CursorPosition = 1218
; FirstLine = 1208
; Folding = ------------------
; EnableAsm
; EnableXP
; CompileSourceDirectory