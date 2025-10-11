;- TOP

; Procedure runtime used with Dialog, all are gadgets triggers


;-
;- ToolBar
;- ¯¯¯¯¯¯¯
Runtime Procedure OnClick_Maskpanel()
  
  If GetGadgetData(#container_left) = 0
    SetGadgetText(#text_Maskpanel, Language::GetNormalized("toolbar", "display"))
    SetGadgetData(#Splitter, GetGadgetState(#Splitter))
    SetGadgetState(#Splitter, 0)
    DisableGadget(#Splitter, #True)
  Else
    SetGadgetText(#text_Maskpanel, Language::GetNormalized("toolbar", "hide"))
    DisableGadget(#Splitter, #False)
    SetGadgetState(#Splitter, GetGadgetData(#Splitter))
  EndIf
  SetGadgetData(#Container_Left, ~(GetGadgetData(#Container_Left)))
  
EndProcedure

Runtime Procedure OnClick_Previous()
  Protected pos, r
  
  ShowSearch = 0
  
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      SetGadgetState(WebDisplay, #PB_Web_Back)
      ;   CompilerCase #PB_OS_Linux
      ;   CompilerCase #PB_OS_MacOS
    CompilerDefault
       WebViewExecuteScript(#webview, ~"history.back();")
  CompilerEndSelect
  
  r   = PreviousElement(History())
  pos = History()
  SelectElement(Contents(), pos)
  SetGadgetText(#string_favoritesectioncurrent, Contents()\node)
  
EndProcedure

Runtime Procedure OnClick_Next()
  Protected r, pos
  
  ShowSearch = 0
  
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      SetGadgetState(WebDisplay, #PB_Web_Forward)
      
      ;   CompilerCase #PB_OS_Linux
      ;   CompilerCase #PB_OS_MacOS
    CompilerDefault
      WebViewExecuteScript(#webview, ~"history.forward();")
  CompilerEndSelect
  
  r   = NextElement(History())
  pos = History()
  SelectElement(Contents(), pos)
  SetGadgetText(#string_favoritesectioncurrent, Contents()\node)
  
EndProcedure

Runtime Procedure OnClick_Home()
  Protected file$ = PathHTML$ + "MainGuide" + "/" + "Intro.html"
  
  ShowSearch = 0
  
  CurrentPath = file$
  CurrentLink = "file://" + file$
  
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    ReplaceString(file$, "\", "/", #PB_String_InPlace)
  CompilerEndIf
  
  If FileSize(file$) > 0
    SetGadgetText(WebDisplay, file$)
  EndIf
  
  If ListIndex(Contents()) >= 0
  SelectElement(Contents(), 0)
  SetGadgetText(#string_favoritesectioncurrent, Contents()\node)
EndIf

EndProcedure

Runtime Procedure OnClick_Print()
  
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      CompilerIf #PB_Compiler_Version < 610
        Protected IWebBrowser2.IWebBrowser2
        IWebBrowser2.IWebBrowser2 = GetWindowLongPtr_(GadgetID(WebDisplay), #GWL_USERDATA)
        IWebBrowser2\ExecWB(7, 2, 0, 0)
      CompilerElse
        Protected Controller.ICoreWebView2Controller = GetGadgetAttribute(WebDisplay, #PB_WebView_ICoreController)
        Protected Core.ICoreWebView2
        Controller\get_CoreWebView2(@Core)
        core\ExecuteScript("window.print()", #Null)
      CompilerEndIf
    CompilerDefault
      WebViewExecuteScript(#webview, ~"window.print();")
  CompilerEndSelect
  
EndProcedure

Runtime Procedure OnClick_Search()
  
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      CompilerIf #PB_Compiler_Version < 610
        #OLECMDID_FIND           = 32
        #OLECMDEXECOPT_DODEFAULT = 0
        Protected WebObject.IWebBrowser2 = GetWindowLong_(GadgetID(#web), #GWL_USERDATA)
        WebObject\ExecWB(#OLECMDID_FIND, #OLECMDEXECOPT_DODEFAULT, #Null, #Null)
      CompilerElse
        SearchInHtml()
      CompilerEndIf
      
    CompilerDefault
      SearchInHtml()
  CompilerEndSelect
  
EndProcedure

Runtime Procedure OnClick_Options()
  DisplayPopupMenu(#MainForm_ToolBar_OptionPopUp, WindowID(DialogWindow(1)),
                   GadgetX(#Options, #PB_Gadget_ScreenCoordinate), GadgetY(WebDisplay, #PB_Gadget_ScreenCoordinate))
  
EndProcedure

Runtime Procedure OnChange_Zoom()
  
  Zoom = GetGadgetState(#Zoom)
  SetGadgetText(#text_Zoom, "Zoom = " + Str(zoom) + " %")
  
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      WebGadget_SetZoom(#web, zoom)
    CompilerDefault
      WebView_SetZoom(#webview, zoom)
  CompilerEndSelect
  
EndProcedure

;-
;- Gadgets in the PanelGadget
;- ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
;- Summary
Runtime Procedure OnEvent_tree_summary()
  Protected i
  Protected gadget
  
  If GetGadgetData(#tree_summarynoicons)
    gadget = #tree_summary
  Else
    gadget = #tree_summarynoicons
  EndIf
  
  For i = 0 To CountGadgetItems(gadget) - 1
    If GetGadgetItemData(gadget, i) = 1
      If GetGadgetItemState(gadget, i) & #PB_Tree_Expanded
        TreeSetItemIcon(gadget, i, 2)
      ElseIf GetGadgetItemState(gadget, i) & #PB_Tree_Collapsed
        TreeSetItemIcon(gadget, i, 1)
      EndIf
    EndIf
  Next i
  
  If Tree_Double_Click = 1
    i = GetGadgetState(gadget)
    If GetGadgetItemData(gadget, i) = 1
      If GetGadgetItemState(gadget, i) & #PB_Tree_Collapsed
        TreeSetItemIcon(gadget, i, 2)
      ElseIf GetGadgetItemState(gadget, i) & #PB_Tree_Expanded
        TreeSetItemIcon(gadget, i, 1)
      EndIf
    EndIf
    Tree_Double_Click = 0
  EndIf
  
EndProcedure

Runtime Procedure OnChange_tree_summary()
  
  ShowSearch = 0
  
EndProcedure

Runtime Procedure OnRClick_tree_summary()
  
  DisplayPopupMenu(#MainForm_Treeview_PopUp, WindowID(DialogWindow(1)))
  
EndProcedure

Runtime Procedure OnClick_tree_summary()
  Protected gadget
  Protected item$
  
  If GetGadgetData(#tree_summarynoicons)
    gadget = #tree_summary
  Else
    gadget = #tree_summarynoicons
  EndIf
  item$ = GetGadgetItemText(gadget, GetGadgetState(gadget))
  
  ForEach contents()
    If item$ = contents()\Node
      SetGadgetText(WebDisplay, contents()\Link)
      CurrentLink = contents()\Link
      CurrentPath = Contents()\Path
      
      ;favorite tab
      SetGadgetText(#string_favoritesectioncurrent, Contents()\node)
      
      ; History
      NextElement(History())
      InsertElement(History())
      History() = GetGadgetState(gadget)
      SetGadgetText(#string_favoritesectioncurrent, contents()\Node)
      SetGadgetData(#string_favoritesectioncurrent, 0)
      Break
    EndIf
  Next
  
EndProcedure

Runtime Procedure OnLDClick_tree_summary()
  
  Tree_Double_Click = 1
  
EndProcedure

;- Index
Runtime Procedure OnChange_string_index()
  Protected SelectItemText$ = GetGadgetText(#string_index), tmp
  
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      tmp = SendMessage_(GadgetID(#listview_index), #LB_FINDSTRING, 0, @SelectItemText$)
      SetGadgetItemState(#listview_index, tmp, 0)
      SendMessage_(GadgetID(#listview_index), #LB_SETTOPINDEX, tmp, 0)
      
    CompilerCase #PB_OS_MacOS
      ClearGadgetItems(#listview_index)
      ForEach index()
        If LCase(Left(index()\Node, Len(SelectItemText$))) = LCase(SelectItemText$)
          AddGadgetItem(#listview_index, - 1, index()\Node)
        EndIf
      Next
      
    CompilerCase #PB_OS_Linux
      ClearGadgetItems(#listview_index)
      ForEach index()
        If LCase(Left(index()\Node, Len(SelectItemText$))) = LCase(SelectItemText$)
          AddGadgetItem(#listview_index, - 1, index()\Node)
        EndIf
      Next
      
  CompilerEndSelect
  
EndProcedure

Runtime Procedure OnClick_listview_index()
  Protected item$ = GetGadgetItemText(#listview_index, GetGadgetState(#listview_index))
  
  ShowSearch = 0
  
  ForEach index()
    If item$ = index()\Node
      SetGadgetText(WebDisplay, index()\Link)
      CurrentLink = index()\Link
      CurrentPath = index()\Path
      
      SetGadgetText(#string_favoritesectioncurrent, index()\node)
      
      ; History
      NextElement(History())
      InsertElement(History())
      History() = GetGadgetState(#listview_index)
      SetGadgetText(#string_favoritesectioncurrent, index()\Node)
      SetGadgetData(#string_favoritesectioncurrent, 1)
      Break
    EndIf
  Next
  
EndProcedure

Runtime Procedure OnLDClick_listview_index()
  
  OnClick_listview_index()
  
EndProcedure

Runtime Procedure OnClick_button_index()
  
  OnClick_listview_index()
  
EndProcedure

;- Search
Runtime Procedure OnChange_string_search()
  
EndProcedure

Runtime Procedure OnClick_button_searchlist()
  Protected Tofind$ = GetGadgetText(#string_search)

  If Tofind$ <> ""
    ClearGadgetItems(#listview_search)
    ;Bug: the listviewgadget not updating its window, so let's force it
    CompilerIf #PB_Compiler_OS = #PB_OS_Windows:UpdateWindow_(GadgetID(#listview_search)):CompilerEndIf
    ClearList(Searched_Items())
    SearchInFiles()
  EndIf
  
EndProcedure

Runtime Procedure OnClick_listview_search()
  Protected tmp = GetGadgetState(#listview_search)
  Protected tmp2, filesource$
  
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      If OSVersion() <= #PB_OS_Windows_XP
        If tmp > - 1
          ShowSearch = 1
          tmp2       = GetGadgetItemData(#listview_search, tmp)
          SelectElement(Searched_Items(), tmp2)
          filesource$ = Searched_Items()\Path
          SetGadgetText(WebDisplay, filesource$)
          Searched$ = GetGadgetText(#string_Search)
        EndIf
      Else
        Protected ori$, Result$
;         Protected script$ = ~"<meta charset=\"utf-8\"><script> function highlightAll(keyWords) { document.getElementById('hid_search_text').value = keyWords; document.designMode = \"on\"; var sel = window.getSelection(); sel.collapse(document.body, 0); while (window.find(keyWords)) { document.execCommand(\"HiliteColor\", false, \"yellow\"); sel.collapseToEnd(); } document.designMode = \"off\"; goTop(keyWords,1); } function removeHighLight() { var keyWords = document.getElementById('hid_search_text').value; document.designMode = \"on\"; var sel = window.getSelection(); sel.collapse(document.body, 0); while (window.find(keyWords)) { document.execCommand(\"HiliteColor\", false, \"transparent\"); sel.collapseToEnd(); } document.designMode = \"off\"; goTop(keyWords,0); } function goTop(keyWords,findFirst) { if(window.document.location.href = '#') { if(findFirst) { window.find(keyWords, 0, 0, 1); } } } </script> <style> #search_para { color:grey; } .highlight { background-color: #FF6; } </style> <div id=\"wrapper\"> <input type=\"text\" id=\"search_text\" name=\"search_text\"> &nbsp; <input type=\"hidden\" id=\"hid_search_text\" name=\"hid_search_text\"> <input type=\"button\" value=\"Search\" id=\"search\" onclick=\"highlightAll(document.getElementById('search_text').value)\" > &nbsp; <input type=\"button\" value=\"Remove\" id=\"remove\" onclick=\"removeHighLight()\" ></div>"
        Protected script$ = ~"<meta charset=\"utf-8\"><script> "
        script$ + ~"function highlightAll(keyWords) "
        script$ + ~"{ document.getElementById('hid_search_text').value = keyWords; "
        script$ + ~"document.designMode = \"on\"; var sel = window.getSelection(); "
        script$ + ~"sel.collapse(document.body, 0); "
        script$ + ~"while (window.find(keyWords)) "
        script$ + ~"{ document.execCommand(\"HiliteColor\", false, \"yellow\"); "
        script$ + ~"sel.collapseToEnd(); } "
        script$ + ~"document.designMode = \"off\"; goTop(keyWords,1); } "
        script$ + ~"function removeHighLight() "
        script$ + ~"{ var keyWords = document.getElementById('hid_search_text').value; "
        script$ + ~"document.designMode = \"on\"; "
        script$ + ~"var sel = window.getSelection(); "
        script$ + ~"sel.collapse(document.body, 0); "
        script$ + ~"while (window.find(keyWords)) "
        script$ + ~"{ document.execCommand(\"HiliteColor\", false, \"transparent\"); "
        script$ + ~"sel.collapseToEnd(); "
        script$ + ~"} document.designMode = \"off\"; "
        script$ + ~"goTop(keyWords,0); } "
        script$ + ~"function goTop(keyWords,findFirst) "
        script$ + ~"{ if(window.document.location.href = '#') "
        script$ + ~"{ if(findFirst) { window.find(keyWords, 0, 0, 1); } } } </script> "
        script$ + ~"<style> #search_para { color:grey; } "
        script$ + ~".highlight { background-color: #FF6; } "
        script$ + ~"</style> "
        script$ + ~"<div id=\"wrapper\"> "
        script$ + ~"<input type=\"text\" id=\"search_text\" name=\"search_text\" value=\"\"> &nbsp; "
        script$ + ~"<input type=\"hidden\" id=\"hid_search_text\" name=\"hid_search_text\"> "
        script$ + ~"<input type=\"button\" value=\"Search\" id=\"search\" "
        script$ + ~"onclick=\"highlightAll(document.getElementById('search_text').value)\" > &nbsp; "
        script$ + ~"<input type=\"button\" value=\"Remove\" id=\"remove\" onclick=\"removeHighLight()\" >"
        script$ + ~"</div>"
        Protected f, gadget, selected, position
        
        script$ = ReplaceString(script$, ~"\"Search\"", Language::Get("Requesters", "Search"))
        script$ = ReplaceString(script$, ~"\"Remove\"", Language::Get("Requesters", "Remove"))
        
        If tmp > - 1
          SelectElement(Searched_Items(), tmp)
          filesource$ = Searched_Items()\Path
          SetGadgetText(WebDisplay,filesource$)
          Searched$ = GetGadgetText(#string_Search)
          script$=ReplaceString(script$,~"name=\"search_text\" value=\"\">",~"name=\"search_text\" value=\""+Searched$+~"\">")
          f= ReadFile(#PB_Any,filesource$,#PB_UTF8 )
          While Eof(f) = 0
            ori$+ ReadString(f, #PB_UTF8) 
          Wend
          CloseFile(f) 
          ori$=ReplaceString(ori$,"<body",~"<body onload=\"highlightAll(document.getElementById('search_text').value)\"",#PB_String_NoCase,0,1)
          position = FindString(ori$, "<body ", #PB_String_NoCase)
          Result$  = InsertString(ori$, script$, Position)
          SetGadgetItemText(WebDisplay, #PB_Web_HtmlCode, Result$)
        EndIf
      EndIf
    CompilerDefault
      
  CompilerEndSelect
  
EndProcedure

Runtime Procedure OnLDClick_listview_search()
  
  OnClick_listview_search()
  
EndProcedure

Runtime Procedure OnClick_button_search()
  
  OnLDClick_listview_search()
  
EndProcedure

;- Favorites
Runtime Procedure OnClick_listview_favorite()
  Protected item$
  
  item$ = GetGadgetItemText(#listview_favorite, GetGadgetState(#listview_favorite))
  ForEach Favorites()
    If item$ = Favorites()\Node
      SetGadgetText(WebDisplay, "file://" + PathHTML$ + Favorites()\Path)
      SetGadgetText(#string_favoritesectioncurrent, Favorites()\node)
      Break
    EndIf
  Next
  
EndProcedure

Runtime Procedure OnLDClick_listview_favorite()
  
  OnClick_listview_favorite()
  
EndProcedure

Runtime Procedure OnClick_button_favoritedel()
  Protected item = GetGadgetState(#listview_favorite)
  
  If item >= 0
    RemoveGadgetItem(#listview_favorite, item)
  EndIf
  
EndProcedure

Runtime Procedure OnClick_button_favorite()
  
  OnLDClick_listview_favorite()
  
EndProcedure

Runtime Procedure OnChange_favoritesectioncurrent()
  
EndProcedure

Runtime Procedure OnClick_button_favoriteadd()
  
  If GetGadgetData(#string_favoritesectioncurrent)
    SelectElement(index(), History())
    AddElement(Favorites())
    Favorites() = index()
  Else
    SelectElement(contents(), History())
    AddElement(Favorites())
    Favorites() = contents()
  EndIf
  
  AddGadgetItem(#listview_favorite, - 1, Favorites()\Node)
  
EndProcedure



; IDE Options = PureBasic 6.30 beta 3 (Windows - x64)
; CursorPosition = 469
; FirstLine = 437
; Folding = ------
; EnableXP
; DPIAware
; CompileSourceDirectory