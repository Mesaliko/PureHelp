;- TOP

;=============================================================================
;
;                              PURE HELP
;
; Preferences (creation)
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


; Use an ini file named 'PureHelp.prefs'

; If ini missing, so create it.
If FileSize(Preference$) = -1
  If CreatePreferences(Preference$, #PB_Preference_GroupSeparator)
    
    PreferenceGroup("LANG")
    WritePreferenceString("lang", "fr")
    
    PreferenceGroup("MAINWINDOW")
    WritePreferenceInteger("x", 0)
    WritePreferenceInteger("y", 0)
    WritePreferenceInteger("w", 1024)
    WritePreferenceInteger("h", 780)
    WritePreferenceInteger("fullscreen", 1)
    WritePreferenceInteger("xsplitter", 238)
    WritePreferenceInteger("iconsize", 32)
    WritePreferenceString("font", "")
    WritePreferenceString("fontsize", "")
    WritePreferenceString("fontstyle", "")
    WritePreferenceString("fontcolour", "")
    WritePreferenceString("fontlist", "")
    WritePreferenceString("fontsizelist", "")
    WritePreferenceString("fontstylelist", "")
    WritePreferenceString("fontcolourlist", "")
    WritePreferenceFloat("zoom", 111.00)
    WritePreferenceInteger("iconsinsummary", 1)
    WritePreferenceInteger("summary3D", 1)
    WritePreferenceString("summary", "contents.xml")
    WritePreferenceString("index", "index.xml")
    
    PreferenceGroup("FAVORITES")
    WritePreferenceString("Contacts", "MainGuide/contact.html")
    
    FlushPreferenceBuffers()
    
    ClosePreferences()
  EndIf
EndIf



; IDE Options = PureBasic 6.30 beta 1 (Windows - x64)
; CursorPosition = 21
; EnableAsm
; EnableXP
; CompileSourceDirectory