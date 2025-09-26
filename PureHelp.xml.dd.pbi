;
;- TOP

;=============================================================================
;
;                              PURE HELP
;
; Dialog GUI (made with Hex0r's Dialog Design0R)
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

;- Constante
#DD_WindowCount   = 1
#DD_UseExtraStuff = 0

CompilerIf #DD_UseExtraStuff
  XIncludeFile "../DD_AddStuff.pbi"
CompilerEndIf


Dim DD_WindowNames.s(#DD_WindowCount)

DD_WindowNames(1) = "window_purehelp"


Runtime Enumeration Gadgets
  #container_Maskpanel
  #Maskpanel
  #text_Maskpanel
  #container_Previous
  #Previous
  #text_previous
  #container_Next
  #Next
  #text_Next
  #container_Home
  #Home
  #text_Home
  #container_Print
  #Print
  #text_Print
  #container_Search
  #Search
  #text_Searches
  #container_Options
  #Options
  #text_Options
  #container_Zoom
  #Zoom
  #text_Zoom
  #splitter
  #container_left
  #panel
  #tab_summary
  #tree_summary
  #tree_summarynoicons
  #tab_index
  #text_index
  #string_index
  #listview_index
  #button_index
  #tab_search
  #text_search
  #string_Search
  #button_searchlist
  #text_selectsection
  #listview_search
  #progressbar
  #button_search
  #tab_favorite
  #text_favorite
  #listview_favorite
  #button_favoritedel
  #button_favorite
  #text_sectioncurrent
  #string_favoritesectioncurrent
  #button_favoriteadd
  #container_right
  #web
  #web_edge
  #webview
EndEnumeration

;- Declare
Declare OnClick_Maskpanel()
Declare OnClick_Previous()
Declare OnClick_Next()
Declare OnClick_Home()
Declare OnClick_Print()
Declare OnClick_Search()
Declare OnClick_Options()
Declare OnChange_Zoom()
Declare OnEvent_tree_summary()
Declare OnChange_tree_summary()
Declare OnRClick_tree_summary()
Declare OnClick_tree_summary()
Declare OnLDClick_tree_summary()
Declare OnChange_string_index()
Declare OnClick_listview_index()
Declare OnLDClick_listview_index()
Declare OnClick_button_index()
Declare OnChange_string_search()
Declare OnClick_button_searchlist()
Declare OnLDClick_listview_search()
Declare OnClick_button_search()
Declare OnLDClick_listview_favorite()
Declare OnClick_button_favoritedel()
Declare OnClick_button_favorite()
Declare OnChange_favoritesectioncurrent()
Declare OnClick_button_favoriteadd()



;- XML
Procedure.s GetXMLString()
  Protected XML$
  
  XML$ + "<?xml version='1.0' encoding='UTF-16'?>"
  XML$ + ""
  XML$ + "<dialogs><!--Created by Dialog Design0R V1.86 => get it from: https://hex0rs.coderbu.de/en/sdm_downloads/dialogdesign0r/-->"
  XML$ + "  <window flags='#PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget | #PB_Window_SizeGadget | #PB_Window_Invisible | #PB_Window_NoActivate' text='Pure Help' width='800' height='600' margin='0' name='window_purehelp' xpos='44' ypos='46'>"
  XML$ + "    <vbox expand='item:2' spacing='0'>"
  XML$ + "      <hbox expand='item:8' spacing='0'>"
  XML$ + "        <container flags='#PB_Container_Single' margin='0' id='#container_Maskpanel'>"
  XML$ + "          <vbox expand='item:1'>"
  XML$ + "            <buttonimage image='#im_imagepressedbuttonimage_Maskpanel' width='100' flags='#PB_Button_Toggle' gadget_image='#im_buttonimage_Hide' gadget_imagepressed='#im_imagepressedbuttonimage_Hide' id='#Maskpanel' imagepressed='#im_imagepressedbuttonimage_1' onevent='OnClick_Maskpanel()'/>"
  XML$ + "            <text text='Hide' flags='#PB_Text_Center' id='#text_Maskpanel'/>"
  XML$ + "          </vbox> "
  XML$ + "        </container>"
  XML$ + "        <container margin='0' flags='#PB_Container_Single' id='#container_Previous'>"
  XML$ + "          <vbox expand='item:1'>"
  XML$ + "            <buttonimage image='#im_buttonimage_Previous' width='100' gadget_image='#im_buttonimage_Hide' gadget_imagepressed='#im_imagepressedbuttonimage_Hide' id='#Previous' imagepressed='#im_imagepressedbuttonimage_1' onevent='OnClick_Previous()'/>"
  XML$ + "            <text text='Previous' flags='#PB_Text_Center' id='#text_previous'/>"
  XML$ + "          </vbox> "
  XML$ + "        </container>"
  XML$ + "        <container flags='#PB_Container_Single' margin='0' id='#container_Next'>"
  XML$ + "          <vbox expand='item:1'>"
  XML$ + "            <buttonimage image='#im_buttonimage_Next' width='100' gadget_image='#im_buttonimage_Hide' gadget_imagepressed='#im_imagepressedbuttonimage_Hide' id='#Next' imagepressed='#im_imagepressedbuttonimage_1' onevent='OnClick_Next()'/>"
  XML$ + "            <text text='Next' flags='#PB_Text_Center' id='#text_Next'/>"
  XML$ + "          </vbox> "
  XML$ + "        </container>"
  XML$ + "        <container flags='#PB_Container_Single' margin='0' id='#container_Home'>"
  XML$ + "          <vbox expand='item:1'>"
  XML$ + "            <buttonimage image='#im_buttonimage_Home' width='100' gadget_image='#im_buttonimage_Hide' gadget_imagepressed='#im_imagepressedbuttonimage_Hide' id='#Home' imagepressed='#im_imagepressedbuttonimage_1' onevent='OnClick_Home()'/>"
  XML$ + "            <text text='Home' flags='#PB_Text_Center' id='#text_Home'/>"
  XML$ + "          </vbox> "
  XML$ + "        </container>"
  XML$ + "        <container flags='#PB_Container_Single' margin='0' id='#container_Print'>"
  XML$ + "          <vbox expand='item:1'>"
  XML$ + "            <buttonimage image='#im_buttonimage_Print' width='100' gadget_image='#im_buttonimage_Hide' gadget_imagepressed='#im_imagepressedbuttonimage_Hide' id='#Print' imagepressed='#im_imagepressedbuttonimage_1' onevent='OnClick_Print()'/>"
  XML$ + "            <text text='Print' flags='#PB_Text_Center' id='#text_Print'/>"
  XML$ + "          </vbox> "
  XML$ + "        </container>"
  XML$ + "        <container margin='0' flags='#PB_Container_Single' id='#container_Search'>"
  XML$ + "          <vbox expand='item:1'>"
  XML$ + "            <buttonimage image='#im_buttonimage_Previous' width='100' gadget_image='#im_buttonimage_Hide' gadget_imagepressed='#im_imagepressedbuttonimage_Hide' id='#Search' imagepressed='#im_imagepressedbuttonimage_1' onevent='OnClick_Search()'/>"
  XML$ + "            <text text='Search' flags='#PB_Text_Center' id='#text_Searches'/>"
  XML$ + "          </vbox> "
  XML$ + "        </container>"
  XML$ + "        <container flags='#PB_Container_Single' margin='0' id='#container_Options'>"
  XML$ + "          <vbox expand='item:1'>"
  XML$ + "            <buttonimage image='#im_buttonimage_Options' width='100' gadget_image='#im_buttonimage_Hide' gadget_imagepressed='#im_imagepressedbuttonimage_Hide' id='#Options' imagepressed='#im_imagepressedbuttonimage_1' onevent='OnClick_Options()'/>"
  XML$ + "            <text text='Options' flags='#PB_Text_Center' id='#text_Options'/>"
  XML$ + "          </vbox> "
  XML$ + "        </container>"
  XML$ + "        <container flags='#PB_Container_Single' margin='0' id='#container_Zoom'>"
  XML$ + "          <vbox expand='item:1'>"
  XML$ + "            <trackbar width='100' min='10' max='500' value='100' id='#Zoom' onevent='OnChange_Zoom()'/>"
  XML$ + "            <text text='Zoom = 100 %' flags='#PB_Text_Center' id='#text_Zoom'/> "
  XML$ + "          </vbox> "
  XML$ + "        </container> "
  XML$ + "      </hbox>"
  XML$ + "      <splitter flags='#PB_Splitter_Vertical | #PB_Splitter_Separator' firstmin='0' secondmin='100' id='#splitter'>"
  XML$ + "        <container flags='#PB_Container_BorderLess' margin='0' id='#container_left'>"
  XML$ + "          <panel margin='0' id='#panel'>"
  XML$ + "            <tab image='#im_tab_summary' text='Summary' gadget_image='#im_tab_summary' id='#tab_summary'>"
  XML$ + "              <multibox>"
  XML$ + "                <tree id='#tree_summary' onrightclick='OnRClick_tree_summary()' onevent='OnEvent_tree_summary()' onleftclick='OnClick_tree_summary()' onchange='OnChange_tree_summary()' onleftdoubleclick='OnLDClick_tree_summary()'/>"
  XML$ + "                <tree invisible='yes' id='#tree_summarynoicons' onrightclick='OnRClick_tree_summary()' onevent='OnEvent_tree_summary()' onchange='OnChange_tree_summary()' onleftclick='OnClick_tree_summary()' onleftdoubleclick='OnLDClick_tree_summary()'/>"
  XML$ + "              </multibox> "
  XML$ + "            </tab>"
  XML$ + "            <tab image='#im_tab_1' text='Index' gadget_image='#im_tab_index' id='#tab_index'>"
  XML$ + "              <vbox expand='item:3'>"
  XML$ + "                <text text='Search the keyword:' id='#text_index'/>"
  XML$ + "                <string id='#string_index' onchange='OnChange_string_index()'/>"
  XML$ + "                <listview id='#listview_index' onleftclick='OnClick_listview_index()' onleftdoubleclick='OnLDClick_listview_index()'/>"
  XML$ + "                <hbox expand='item:1'>"
  XML$ + "                  <empty/>"
  XML$ + "                  <button text='Display' height='30' id='#button_index' onevent='OnClick_button_index()'/>"
  XML$ + "                </hbox> "
  XML$ + "              </vbox> "
  XML$ + "            </tab>"
  XML$ + "            <tab image='#im_tab_1' text='Search' gadget_image='#im_tab_search' id='#tab_search'>"
  XML$ + "              <vbox expand='item:5'>"
  XML$ + "                <text text='Search the keyword:' id='#text_search'/>"
  XML$ + "                <string id='#string_Search' onchange='OnChange_string_search()'  text=''/>"
  XML$ + "                <hbox expand='item:1'>"
  XML$ + "                  <empty/>"
  XML$ + "                  <button text='list of sections' height='30' id='#button_searchlist' onevent='OnClick_button_searchlist()'/>"
  XML$ + "                </hbox>"
  XML$ + "                <text text='Select the section:' id='#text_selectsection'/>"
  XML$ + "                <listview id='#listview_search' onleftclick='OnClick_listview_search()' onleftdoubleclick='OnLDClick_listview_search()'/>"
  XML$ + "                <hbox expand='item:1'>"
  XML$ + "                  <progressbar id='#progressbar'/>"
  XML$ + "                  <button text='Display' height='30' id='#button_search' onevent='OnClick_button_search()'/>"
  XML$ + "                </hbox> "
  XML$ + "              </vbox> "
  XML$ + "            </tab>"
  XML$ + "            <tab image='#im_tab_1' text='Favorite' gadget_image='#im_tab_favorite' id='#tab_favorite'>"
  XML$ + "              <vbox expand='item:2'>"
  XML$ + "                <text text='Sections:' id='#text_favorite'/>"
  XML$ + "                <listview id='#listview_favorite' onleftclick='OnClick_listview_favorite()' onleftdoubleclick='OnLDClick_listview_favorite()'/>"
  XML$ + "                <hbox expand='item:1'>"
  XML$ + "                  <empty/>"
  XML$ + "                  <button text='Delete' height='30' id='#button_favoritedel' onevent='OnClick_button_favoritedel()'/>"
  XML$ + "                  <button text='Display' height='30' id='#button_favorite' onevent='OnClick_button_favorite()'/> "
  XML$ + "                </hbox>"
  XML$ + "                <text text='Current section:' id='#text_sectioncurrent'/>"
  XML$ + "                <string id='#string_favoritesectioncurrent' onchange='OnChange_favoritesectioncurrent()'/>"
  XML$ + "                <hbox expand='item:1'>"
  XML$ + "                  <empty/>"
  XML$ + "                  <button text='Add' height='30' id='#button_favoriteadd' onevent='OnClick_button_favoriteadd()'/>"
  XML$ + "                </hbox> "
  XML$ + "              </vbox> "
  XML$ + "            </tab> "
  XML$ + "          </panel> "
  XML$ + "        </container>"
  XML$ + "        <container flags='#PB_Container_BorderLess' margin='0' id='#container_right'>"
  XML$ + "          <multibox>"
  CompilerIf #PB_Compiler_Version < 610
    XML$ + "            <web id='#web'/>"
  CompilerElse
    XML$ + "            <web id='#web' flags='#PB_Web_Edge'/>"
    XML$ + "            <webview invisible='yes' id='#webview'/> "
  CompilerEndIf
  XML$ + "          </multibox> "
  XML$ + "        </container> "
  XML$ + "      </splitter> "
  XML$ + "    </vbox> "
  XML$ + "  </window>"
  XML$ + "</dialogs><!--DDesign0R Definition: PureBasic|1|1|1|_______|Mesa3|1-->"
  
  ProcedureReturn XML$
EndProcedure

;-
;- Test it

CompilerIf #PB_Compiler_IsMainFile
  
  ;- Procedure runtime
  Runtime Procedure OnClick_Maskpanel()
    
  EndProcedure
  
  Runtime Procedure OnClick_Previous()
    
  EndProcedure
  
  Runtime Procedure OnClick_Next()
    
  EndProcedure
  
  Runtime Procedure OnClick_Home()
    
  EndProcedure
  
  Runtime Procedure OnClick_Print()
    
  EndProcedure
  
  Runtime Procedure OnClick_Search()
    
  EndProcedure
  
  Runtime Procedure OnClick_Options()
    
  EndProcedure
  
  Runtime Procedure OnChange_Zoom()
    
  EndProcedure
  
  Runtime Procedure OnEvent_tree_summary()
    
  EndProcedure
  
  Runtime Procedure OnChange_tree_summary()
    
  EndProcedure
  
  Runtime Procedure OnRClick_tree_summary()
    
  EndProcedure
  
  Runtime Procedure OnClick_tree_summary()
    
  EndProcedure
  
  Runtime Procedure OnLDClick_tree_summary()
    
  EndProcedure
  
  Runtime Procedure OnChange_string_index()
    
  EndProcedure
  
  Runtime Procedure OnClick_listview_index()
    
  EndProcedure
  
  Runtime Procedure OnLDClick_listview_index()
    
  EndProcedure
  
  Runtime Procedure OnClick_button_index()
    
  EndProcedure
  
  Runtime Procedure OnChange_string_search()
    
  EndProcedure
  
  Runtime Procedure OnClick_button_searchlist()
    
  EndProcedure
  
  Runtime Procedure OnClick_listview_search()
    
  EndProcedure
  
  Runtime Procedure OnLDClick_listview_search()
    
  EndProcedure
  
  Runtime Procedure OnClick_button_search()
    
  EndProcedure
  
  Runtime Procedure OnClick_listview_favorite()
    
  EndProcedure
  
  Runtime Procedure OnLDClick_listview_favorite()
    
  EndProcedure
  
  Runtime Procedure OnClick_button_favoritedel()
    
  EndProcedure
  
  Runtime Procedure OnClick_button_favorite()
    
  EndProcedure
  
  Runtime Procedure OnChange_favoritesectioncurrent()
    
  EndProcedure
  
  Runtime Procedure OnClick_button_favoriteadd()
    
  EndProcedure
  
  
  
  
  
  ;- Entry point
  a$ = GetXMLString()
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
        HideWindow(DialogWindow(i), 0)
        ok = #True
        ;Init()
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
  
CompilerEndIf

;- End



; IDE Options = PureBasic 6.30 beta 1 (Windows - x64)
; CursorPosition = 1
; Folding = ------
; EnableXP
; DPIAware
; CompileSourceDirectory