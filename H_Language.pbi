;- TOP

;=============================================================================
;
;                              PURE HELP
;
; User languages: French, English, German (Add your own language here)
; ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
; Author: Freak, GPI, Pbsians from the forum, Mesa (module) : No AI !
;
; Version: 1.0
;
; Windows : All
; Linux and MacOS should work, but not tested
; 
;
; 2025
;=============================================================================


DeclareModule Language
  EnableExplicit
  Structure Group
    Map Word.s()
    MaxLen.i
    HalfMaxLen.i
  EndStructure
  
  Global NewMap Group.Group()
  
  Macro Get(sGroup, sWord)
    Language::Group(UCase(sGroup))\Word(UCase(sWord))
  EndMacro
  
  Declare LoadLanguage(*DefaultLanguage, Filenname.s = "")
  Declare SaveLanguage(Filename.s)
  Declare.s GetNormalized(sGroup.s, sWord.s)
EndDeclareModule


Module Language
  Procedure LoadLanguage(*Default, File.s = "")
    Define Group.s = "COMMON"
    Define Option.s
    Define Value.s
    Define Len.i
    
    ClearMap(Group())
    
    Repeat
      ;Because read without restore will not work
      Len      = MemoryStringLength(*Default) + 1
      Option.s = PeekS(*Default)
      *Default + Len * SizeOf(Character)
      
      len     = MemoryStringLength(*Default) + 1
      Value.s = PeekS(*Default)
      *Default + Len * SizeOf(Character)
      
      Option = UCase(Option)
      Select option
        Case "", "_END_"
          Break
        Case "_GROUP_"
          Group = UCase(Value)
        Default
          Group(Group)\Word(Option) = Value
          If Len(Value) > Group()\MaxLen
            Group()\MaxLen     = Len(Value)
            Group()\HalfMaxLen = Group()\MaxLen / 2 + 1
          EndIf
      EndSelect
    ForEver
    
    If File
      If OpenPreferences(File)
        ForEach Group()
          PreferenceGroup(MapKey(Group()))
          ForEach Group()\Word()
            Group()\Word() = ReadPreferenceString(MapKey(Group()\Word()), Group()\Word())
            If Len(Group()\Word()) > Group()\MaxLen
              Group()\MaxLen     = Len(Group()\Word())
              Group()\HalfMaxLen = Group()\MaxLen / 2 + 1
            EndIf
          Next
        Next
        ClosePreferences()
      Else
        ProcedureReturn #False
      EndIf
    EndIf
    ProcedureReturn #True
  EndProcedure
  
  Procedure SaveLanguage(File.s)
    If CreatePreferences(File, #PB_Preference_GroupSeparator)
      PreferenceComment("Language File")
      PreferenceGroup("info");just in case we need this information sometimes
      WritePreferenceString("Version", "1.00")
      WritePreferenceString("Programm", GetFilePart(ProgramFilename()))
      ForEach Group()
        PreferenceGroup(MapKey(Group()))
        ForEach Group()\Word()
          WritePreferenceString(MapKey(Group()\Word()), Group()\Word())
        Next
      Next
      ClosePreferences()
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure
  
  Procedure.s GetNormalized(sGroup.s, sWord.s)
    ; every texts have the same size (len), usefull for menus and toolbars
    Protected tmp$
    
    tmp$ = Group(UCase(sGroup))\Word(UCase(sWord))
    tmp$ = LSet(tmp$, Len(tmp$) / 2 + Group(UCase(sGroup))\HalfMaxLen, " ")
    tmp$ = RSet(tmp$, Group(UCase(sGroup))\MaxLen, " ")
    
    ProcedureReturn tmp$
    
  EndProcedure
  
EndModule


Procedure.s FindUserLanguage()
  Protected lg$
  
  ; Try to get it in the preference file
  If FileSize(Preference$) >= 0
    If OpenPreferences(Preference$, #PB_Preference_GroupSeparator)
      PreferenceGroup("LANG")
      lg$ = ReadPreferenceString("lang", "en")
      Select lg$
        Case "en"
          UserLanguage  = #LANG_ENGLISH
          UserLanguage$ = "en"
          Language::LoadLanguage(?English)
          
        Case"fr"
          UserLanguage = #LANG_FRENCH
          Language::LoadLanguage(?French)
          UserLanguage$ = "fr"
          
        Case "de"
          UserLanguage  = #LANG_GERMAN
          UserLanguage$ = "de"
          Language::LoadLanguage(?German)
      EndSelect
      ClosePreferences()
      
    EndIf
  EndIf
  
  ;Add languages and translations under, only for Windows XP
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      If OSVersion() <= #PB_OS_Windows_XP
        Select GetUserDefaultLangID_() & $0003FF
          Case #LANG_ENGLISH
            Searchbox$ = "Search"
          Case #LANG_FRENCH
            Searchbox$ = "Rechercher"
          Case #LANG_GERMAN
           Searchbox$ = "Zur Forschung"
        EndSelect
      EndIf
  CompilerEndSelect
  
  ProcedureReturn lg$
EndProcedure


;Language::SaveLanguage(GetCurrentDirectory() + "PureHelp.pref") ; if a preference file is needed to be created


DataSection
  
  ; Here the default language is specified. It is a list of Group, Name pairs,
  ; with some special keywords for the Group:
  ;
  ; "_GROUP_" will indicate a new group in the datasection, the second value is the group name
  ; "_END_" will indicate the end of the language list (as there is no fixed number)
  ;
  ; Note: The identifier strings are case insensitive to make live easier :)
  
  ;- English
  
  English:
  
  ; ===================================================
  Data.s "_GROUP_",            "ToolBar"
  ; ===================================================
  
  Data.s "Hide",                "Hide"
  Data.s "Display",             "Display"
  Data.s "Previous",            "Previous"
  Data.s "Next",                "Next"
  Data.s "Home",                "Home"
  Data.s "Print",               "Print"
  Data.s "Options",             "Options"
  Data.s "Search",              "Search"
  Data.s "Compile",             "Compile"
  
  ; ===================================================
  Data.s "_GROUP_",            "OptionsSubMenu"
  ; ===================================================
  
  Data.s "Stop",                "Stop"
  Data.s "Refresh",             "Refresh"
  Data.s "Font",                "Fonts"
  Data.s "FontSizeOnly",        "Font size only"
  Data.s "FontList",            "Font (Lists only)"
  Data.s "FontListColour",      "Font colour (Lists only)"
  Data.s "FontListSizeOnly",    "Font Size (Lists only)"
  Data.s "FontDefault",         "Default Font"
  Data.s "Icons",               "Show icons in the summary list"
  Data.s "IconsSize",           "Icons size (Lists only)"
  Data.s "Summary",             "Summary"
  Data.s "SummaryDefault",      "Default summary"
  Data.s "SummaryOriginal",     "Original summary"
  Data.s "SummaryMesa",         "Summary 3D/Network"
  Data.s "SummaryOpen",         "Open a summary..."
  Data.s "SummaryCreate",       "Create Summary from an hhc file"
  Data.s "Index",               "Index"
  Data.s "IndexDefault",        "Default Index"
  Data.s "IndexOpen",           "Open an Index file"
  Data.s "IndexCreate",         "Create an Index from an hhk file"
  Data.s "Lang",                "Language"
  Data.s "English",             "English"
  Data.s "French",              "French"
  Data.s "German",              "German"
  Data.s "Update",              "Update"
  Data.s "About",               "About"
  Data.s "DisableHighlighting", "Disable Highlighting"
  Data.s "EnableHighlighting",  "Enable Highlighting"
  Data.s "GraphicalCharter",    "Graphical Charter"
  
  ; ===================================================
  Data.s "_GROUP_",            "Gadgets"
  ; ===================================================
  
  Data.s "Summary",              "&Contents"
  Data.s "Index",                "&Index"
  Data.s "Display",              "&Display"
  Data.s "SearchWord",           "En&ter the word to search:"
  Data.s "Snippets",             "Sni&ppets"
  Data.s "WebSnippets",          "Web Snippets"
  Data.s "LocalSnippets",        "Local Snippets"
  Data.s "Search",               "&Search"
  Data.s "Selrubric",            "Select the ru&brique to display:"
  Data.s "ListRubric",           "&List of rubrics"
  Data.s "Favorite",             "Fa&vorites"
  Data.s "Add",                  "&Add"
  Data.s "RubricIn",             "Current ru&bric:"
  Data.s "Delete",               "Dele&te"
  Data.s "Rubric",               "Rub&rics:"
  Data.s "Reset",                "&Reset"
  
  ; ===================================================
  Data.s "_GROUP_",            "PopUpMenus"
  ; ===================================================
  
;   ; Scintilla Pop Up Menu
;   Data.s "CopySelected",         "Copy Selected"
;   Data.s "CopyAll",              "Copy All"
  ;Treeview
  Data.s "CollapseAll",          "Collapse All"
  Data.s "ExpandAll",            "Expand All"
  Data.s "ItemTextColor",        "Item text color"
  Data.s "ItemBkgColor",         "Item background color"
  Data.s "ItemResetColor",       "Item reset color"
  Data.s "AllItemResetColor",    "All items reset color"
  Data.s "AddItem",              "Add Item"
  Data.s "DeleteItem",           "Delete Item"
  Data.s "OpenFolder",           "Open the folder..."
  Data.s "LargeIcon",            "Large Icons"
  Data.s "SmallIcon",            "Small Icons"
  Data.s "List",                 "List"
  Data.s "Report",               "Report"
  
  ; ===================================================
  Data.s "_GROUP_",            "Requesters"
  ; ===================================================
  
  Data.s "ATTENTION",            "ATTENTION"
  Data.s "NoValid",              "No valid value."
  Data.s "SearchTitle",          "Search the current page ..." 
  Data.s "SearchMessage",        "Enter a text:"
  Data.s "SearchMessageRegEx",   "Enter a text or a regex:"
  Data.s "Information",          "Information"
  Data.s "Failed",               "Failed"
  Data.s "NoMatch",              "Not found !"
  Data.s "ContentsCorrupted",    "The content file: Table of Contents.hhc is corrupted or is missing"
  Data.s "HKKCorrupted",         "The index file: Index.hhk is corrupted or is missing"
  Data.s "HKKAddIndexName",      "Add an index"
  Data.s "HKKAddIndexLink",      "Choose an HML file inside the 'HELP' folder only !"
  Data.s "HKKCloseIndexFile",    "Please close the 'Index.hhk' file."
  Data.s "HKKAddIndex",          "Add an index ?"
  Data.s "HKKDeleteIndex",       "Delete an index ?"
  Data.s "HKKNoIndex",           "Nothing to delete !"
  Data.s "HKKDeleteSure",        "Are you sure to delete this index ?"
  Data.s "HKKREset",             "Reset?"
  Data.s "SnippetAddURL",        "Enter a valid URL entry:"
  Data.s "SnippetWebPrefFailed", "The file 'PureHelp.prefs' is corrupted or is missing."
  Data.s "FavoritesEntryNoAllowed","The favorite stil exists."
  Data.s "SearchNoMatch",        "No topic found."
  Data.s "HelpDirMissing",       "The 'Help' folder is missing."
  Data.s "ScintillaDLLMissing",  "Scintilla.dll is missing inside the DLL folder."
  Data.s "Pleasewait",           "Please wait..."
  Data.s "ALotOfMatches",        "The search may take several minutes."+#LF$+"Continue?"
  Data.s "TitleFontSize",        "Font size"
  Data.s "MessageFontSize",      "Enter the font size:"
  Data.s "OpenSummaryTitle",     "Open the summary file"
  Data.s "OpenSummary",          "Summary file"
  Data.s "SaveSummaryTitle",     "Save the summary file"
  Data.s "SaveSummary",          "Summary file"
  Data.s "Search",               "Search"
  Data.s "Remove",               "Remove"
  Data.s "OpenIndexTitle",       "Open an index file"
  Data.s "OpenIndex",            "Index file"
  Data.s "SaveIndexTitle",       "Save the index file"
  Data.s "SaveIndex",            "Index file"
  Data.s "Savefile",             "Save file"
  Data.s "Overwrite",            "Overwrite the file ?"
  Data.s "Searchbox",            "Search"; it's the window name of the searchbox in a webgadget
  Data.s "IconsSizeReq",         "Icon size?"
  Data.s "IconsSizeReq2",        "Which size? (ex : 64)"
  Data.s "Update?",              "Update PureHelp?"
  Data.s "UpdateText?",          "Did you update html and xml files from a newer version of PureBasic?"
  Data.s "UpdateText2?",         "Do you want to update now?"
  Data.s "Restaure",             "Update is done. Backup files have been saved in the Backup directory."+#LF$+"Restart PureHelp."
  ; ===================================================
  Data.s "_END_",              ""
  ; ===================================================
  
  
  ;- French
  
  French:
  ;For memory: Unused accelerators:adefghjknotwxyz
  ; ===================================================
  Data.s "_GROUP_",            "ToolBar"
  ; ===================================================
  
  Data.s "Hide",                "Masquer"
  Data.s "Display",             "Afficher"
  Data.s "Previous",            "Page précédente"
  Data.s "Next",                "Page suivante"
  Data.s "Home",                "Démarrage"
  Data.s "Print",               "Imprimer"
  Data.s "Options",             "Options"
  Data.s "Search",              "Rechercher"
  Data.s "Compile",             "Compiler"
  
  ; ===================================================
  Data.s "_GROUP_",            "OptionsSubMenu"
  ; ===================================================
  
  Data.s "Stop",                "Arrêter"
  Data.s "Refresh",             "Actualiser"
  Data.s "Font",                "Polices"
  Data.s "FontSizeOnly",        "Police taille"
  Data.s "FontList",            "Police         (Affichage des Listes)"
  Data.s "FontListColour",      "Police couleur (Affichage des Listes)"
  Data.s "FontListSizeOnly",    "Police taille  (Affichage des Listes)"
  Data.s "FontDefault",         "Police système par défaut"
  Data.s "Icons",               "Afficher les icônes dans le Sommaire"
  Data.s "IconsSize",           "Tailles des icônes (Affichage des Listes)"
  Data.s "Summary",             "Sommaire"
  Data.s "SummaryDefault",      "Sommaire par défaut"
  Data.s "SummaryOriginal",     "Sommaire d'origine"
  Data.s "SummaryMesa",         "Sommaire Mesa (3D/Réseaux)"
  Data.s "SummaryOpen",         "Ouvrir un sommaire..."
  Data.s "SummaryCreate",       "Créer un Sommaire à partir d'un fichier hhc"
  Data.s "Index",               "Index"
  Data.s "IndexDefault",        "Index par défaut"
  Data.s "IndexOpen",           "Ouvrir un fichier Index"
  Data.s "IndexCreate",         "Créer un Index à partir d'un fichier hhk"
  Data.s "Lang",                "Langue"
  Data.s "English",             "Anglais"
  Data.s "French",              "Français"
  Data.s "German",              "Allemand"
  Data.s "Update",              "Mise à jour..."
  Data.s "About",               "À propos..."
  Data.s "DisableHighlighting", "Désactiver la mise en surbrillance"
  Data.s "EnableHighlighting",  "Activer la mise en surbrillance"
  Data.s "GraphicalCharter",    "Charte graphique"
  
  ; ===================================================
  Data.s "_GROUP_",            "Gadgets"
  ; ===================================================
  
  Data.s "Summary",              "&Sommaire"
  Data.s "Index",                "&Index"
  Data.s "Display",              "Affi&cher"
  Data.s "SearchWord",           "Entrer le m&ot clé à rechercher:"
  Data.s "Snippets",             "Codes et A&PI"
  Data.s "WebSnippets",          "Exemples de code (Web)"
  Data.s "LocalSnippets",        "Exemples de code (Local)"
  Data.s "Search",               "&Rechercher"
  Data.s "Selrubric",            "Sélectionnez la ru&brique à afficher:"
  Data.s "ListRubric",           "&Liste des rubriques"
  Data.s "Favorite",             "Fa&voris"
  Data.s "Add",                  "Ajo&uter"
  Data.s "RubricIn",             "Ru&brique en cours:"
  Data.s "Delete",               "Suppri&mer"
  Data.s "Rubric",               "Rubri&ques:"
  Data.s "Reset",                "RA&Z"
  
  ; ===================================================
  Data.s "_GROUP_",            "PopUpMenus"
  ; ===================================================
  
;   ; Scintilla Pop Up Menu
;   Data.s "CopySelected",         "Copier la sélection"
;   Data.s "CopyAll",              "Copier tout"
  ;Treeview
  Data.s "CollapseAll",          "Fermer tout"
  Data.s "ExpandAll",            "Ouvrir tout"
  Data.s "ItemTextColor",        "Changer la couleur du texte de l'item"
  Data.s "ItemBkgColor",         "Changer la couleur de fond de l'item"
  Data.s "ItemResetColor",       "Remise à zéro"
  Data.s "AllItemResetColor",    "Tout remettre à zéro"
  Data.s "AddItem",              "Ajouter une entrée"
  Data.s "DeleteItem",           "Supprimer l'entrée"
  Data.s "OpenFolder",           "Ouvrir le dossier..."
  Data.s "LargeIcon",            "Grandes icônes"
  Data.s "SmallIcon",            "Petites icônes"
  Data.s "List",                 "Liste"
  Data.s "Report",               "Détails"
  
  ; ===================================================
  Data.s "_GROUP_",            "Requesters"
  ; ===================================================
  
  Data.s "ATTENTION",            "ATTENTION"
  Data.s "NoValid",              "Valeur non valide."
  Data.s "SearchTitle",          "Rechercher dans la page en cours..." 
  Data.s "SearchMessage",        "Entrer un texte:"
  Data.s "SearchMessageRegEx",   "Entrer un texte ou un regex:"
  Data.s "Information",          "Information"
  Data.s "Failed",               "Echec"
  Data.s "NoMatch",              "Pas trouvé !"
  Data.s "ContentsCorrupted",    "Le fichier Sommaire: Table of Contents.hhc est corrompu ou absent"
  Data.s "HKKCorrupted",         "Le fichier Index: Index.hhk est corrompu ou absent"
  Data.s "HKKAddIndexName",      "Ajouter une entrée d'index"
  Data.s "HKKAddIndexLink",      "Choisissez le fichier HML, dans le dossier 'HELP' uniquement !"
  Data.s "HKKCloseIndexFile",    "Veuillez fermer le fichier 'Index.hhk'."
  Data.s "HKKAddIndex",          "Ajouter un index ?"
  Data.s "HKKDeleteIndex",       "Supprimer un index ?"
  Data.s "HKKNoIndex",           "Rien à supprimer !"
  Data.s "HKKDeleteSure",        "Voulez-vous vraiment supprimer cet index ?"
  Data.s "HKKREset",             "Voulez-vous remettre à zéro ?"
  Data.s "SnippetAddURL",        "Veuillez entrer une URL valide:"
  Data.s "SnippetWebPrefFailed", "Le fichier 'PureHelp.prefs' est absent ou corrompu."
  Data.s "FavoritesEntryNoAllowed","Le favori existe déjà."
  Data.s "SearchNoMatch",        "Aucune rubrique trouvée"
  Data.s "HelpDirMissing",       "Le dossier 'Help' est absent."
  Data.s "ScintillaDLLMissing",  "Scintilla.dll introuvable dans le dossier DLL"
  Data.s "Pleasewait",           "Veuillez patienter, svp..."
  Data.s "ALotOfMatches",        "La recherche peut prendre plusieurs minutes."+#LF$+"Continuer ?"
  Data.s "TitleFontSize",        "Taille de la police de caractère."
  Data.s "MessageFontSize",      "Entrer la taille:"
  Data.s "OpenSummaryTitle",     "Ouvrir un fichier sommaire"
  Data.s "OpenSummary",          "Fichier Sommaire"
  Data.s "SaveSummaryTitle",     "Enregistrer le fichier Sommaire"
  Data.s "SaveSummary",          "Fichier Sommaire"
  Data.s "Search",               "Rechercher"
  Data.s "Remove",               "Effacer"
  Data.s "OpenIndexTitle",       "Ouvrir un fichier index"
  Data.s "OpenIndex",            "Fichier Index"
  Data.s "SaveIndexTitle",       "Enregistrer le fichier index"
  Data.s "SaveIndex",            "Fichier Index"
  Data.s "Save file",            "Enregistrer le fichier"
  Data.s "Overwrite",            "Remplacer le fichier ?"
  Data.s "Searchbox",            "Rechercher"; c'est le nom de la boîte de dialogue Rechercher (ctrl+f) du webgadget
  Data.s "IconsSizeReq",         "Tailles des icônes ?"
  Data.s "IconsSizeReq2",        "Quelle taille ? (ex : 64)"
  Data.s "Update?",              "Mise à jour de PureHelp ?"
  Data.s "UpdateText?",          "Avez-vous mis à jour les fichiers html et xml manuellement depuis une version nouvelle de PureBasic ?"
  Data.s "UpdateText2?",         "Voulez_vous effectuer la mise à jour ?"
  Data.s "Restaure",             "Mise à jour effectuée. Les anciens fichiers ont été sauvegardés dans le dossier nommé Backup."+#LF$+"Redémarrez PureHelp."
   
  ; ===================================================
  Data.s "_END_",              ""
  ; ===================================================
  
  
  ;- German
  
  German:
  ;TODO translation
  ; ===================================================
  Data.s "_GROUP_",            "ToolBar"
  ; ===================================================
  
  Data.s "Hide",                "Hide"
  Data.s "Display",             "Display"
  Data.s "Previous",            "Previous"
  Data.s "Next",                "Next"
  Data.s "Home",                "Home"
  Data.s "Print",               "Print"
  Data.s "Options",             "Options"
  Data.s "Search",              "Search"
  Data.s "Compile",             "Compile"
  
  ; ===================================================
  Data.s "_GROUP_",            "OptionsSubMenu"
  ; ===================================================
  
  Data.s "Stop",                "Stop"
  Data.s "Refresh",             "Refresh"
  Data.s "Font",                "Fonts"
  Data.s "FontSizeOnly",        "Font size only"
  Data.s "FontList",            "Font (Lists only)"
  Data.s "FontListColour",      "Font colour (Lists only)"
  Data.s "FontListSizeOnly",    "Font Size (Lists only)"
  Data.s "FontDefault",         "Default Font"
  Data.s "Icons",               "Show icons in the summary list"
  Data.s "IconsSize",           "Icons size (Lists only)"
  Data.s "Summary",             "Summary"
  Data.s "SummaryDefault",      "Default summary"
  Data.s "SummaryOriginal",     "Original summary"
  Data.s "SummaryMesa",         "Summary 3D/Network"
  Data.s "SummaryOpen",         "Open a summary..."
  Data.s "SummaryCreate",       "Create Summary from an hhc file"
  Data.s "Index",               "Index"
  Data.s "IndexDefault",        "Default Index"
  Data.s "IndexOpen",           "Open an Index file"
  Data.s "IndexCreate",         "Create an Index from an hhk file"
  Data.s "Lang",                "Language"
  Data.s "English",             "English"
  Data.s "French",              "French"
  Data.s "German",              "German"
  Data.s "Update",              "Update"
  Data.s "About",               "About"
  Data.s "DisableHighlighting", "Disable Highlighting"
  Data.s "EnableHighlighting",  "Enable Highlighting"
  Data.s "GraphicalCharter",    "Graphical Charter"
  
  ; ===================================================
  Data.s "_GROUP_",            "Gadgets"
  ; ===================================================
  
  Data.s "Summary",              "&Contents"
  Data.s "Index",                "&Index"
  Data.s "Display",              "&Display"
  Data.s "SearchWord",           "En&ter the word to search:"
  Data.s "Snippets",             "Sni&ppets"
  Data.s "WebSnippets",          "Web Snippets"
  Data.s "LocalSnippets",        "Local Snippets"
  Data.s "Search",               "&Search"
  Data.s "Selrubric",            "Select the ru&brique to display:"
  Data.s "ListRubric",           "&List of rubrics"
  Data.s "Favorite",             "Fa&vorites"
  Data.s "Add",                  "&Add"
  Data.s "RubricIn",             "Current ru&bric:"
  Data.s "Delete",               "Dele&te"
  Data.s "Rubric",               "Rub&rics:"
  Data.s "Reset",                "&Reset"
  
  ; ===================================================
  Data.s "_GROUP_",            "PopUpMenus"
  ; ===================================================
  
;   ; Scintilla Pop Up Menu
;   Data.s "CopySelected",         "Copy Selected"
;   Data.s "CopyAll",              "Copy All"
  ;Treeview
  Data.s "CollapseAll",          "Collapse All"
  Data.s "ExpandAll",            "Expand All"
  Data.s "ItemTextColor",        "Item text color"
  Data.s "ItemBkgColor",         "Item background color"
  Data.s "ItemResetColor",       "Item reset color"
  Data.s "AllItemResetColor",    "All items reset color"
  Data.s "AddItem",              "Add Item"
  Data.s "DeleteItem",           "Delete Item"
  Data.s "OpenFolder",           "Open the folder..."
  Data.s "LargeIcon",            "Large Icons"
  Data.s "SmallIcon",            "Small Icons"
  Data.s "List",                 "List"
  Data.s "Report",               "Report"
  
  ; ===================================================
  Data.s "_GROUP_",            "Requesters"
  ; ===================================================
  
  Data.s "ATTENTION",            "ATTENTION"
  Data.s "NoValid",              "No valid value."
  Data.s "SearchTitle",          "Search the current page ..." 
  Data.s "SearchMessage",        "Enter a text:"
  Data.s "SearchMessageRegEx",   "Enter a text or a regex:"
  Data.s "Information",          "Information"
  Data.s "Failed",               "Failed"
  Data.s "NoMatch",              "Not found !"
  Data.s "ContentsCorrupted",    "The content file: Table of Contents.hhc is corrupted or is missing"
  Data.s "HKKCorrupted",         "The index file: Index.hhk is corrupted or is missing"
  Data.s "HKKAddIndexName",      "Add an index"
  Data.s "HKKAddIndexLink",      "Choose an HML file inside the 'HELP' folder only !"
  Data.s "HKKCloseIndexFile",    "Please close the 'Index.hhk' file."
  Data.s "HKKAddIndex",          "Add an index ?"
  Data.s "HKKDeleteIndex",       "Delete an index ?"
  Data.s "HKKNoIndex",           "Nothing to delete !"
  Data.s "HKKDeleteSure",        "Are you sure to delete this index ?"
  Data.s "HKKREset",             "Reset?"
  Data.s "SnippetAddURL",        "Enter a valid URL entry:"
  Data.s "SnippetWebPrefFailed", "The file 'PureHelp.prefs' is corrupted or is missing."
  Data.s "FavoritesEntryNoAllowed","The favorite stil exists."
  Data.s "SearchNoMatch",        "No topic found."
  Data.s "HelpDirMissing",       "The 'Help' folder is missing."
  Data.s "ScintillaDLLMissing",  "Scintilla.dll is missing inside the DLL folder."
  Data.s "Pleasewait",           "Please wait..."
  Data.s "ALotOfMatches",        "The search may take several minutes."+#LF$+"Continue?"
  Data.s "TitleFontSize",        "Font size"
  Data.s "MessageFontSize",      "Enter the font size:"
  Data.s "OpenSummaryTitle",     "Open summary file"
  Data.s "OpenSummary",          "Summary file"
  Data.s "SaveSummaryTitle",     "Save the summary file"
  Data.s "SaveSummary",          "Summary file"
  Data.s "Search",               "Search"
  Data.s "Remove",               "Remove"
  Data.s "OpenIndexTitle",       "Open an index file"
  Data.s "OpenIndex",            "Index file"
  Data.s "SaveIndexTitle",       "Save the index file"
  Data.s "SaveIndex",            "Index file"
  Data.s "Savefile",             "Save file"
  Data.s "Overwrite",            "Overwrite the file ?"
  Data.s "Searchbox",            "Search"; it's the window name of the searchbox in a webgadget
  Data.s "IconsSizeReq",         "Icon size?"
  Data.s "IconsSizeReq2",        "Which size? (ex : 64)"
  Data.s "Update?",              "Update PureHelp?"
  Data.s "UpdateText?",          "Did you update html and xml files from a newer version of PureBasic?"
  Data.s "UpdateText2?",         "Do you want to update now?"
  Data.s "Restaure",             "Update is done. Backup files have been saved in the Backup directory."+#LF$+"Restart PureHelp."
    
  ; ===================================================
  Data.s "_END_",              ""
  ; ===================================================
  
  ;- End 
EndDataSection








; IDE Options = PureBasic 6.03 LTS (Windows - x86)
; CursorPosition = 158
; FirstLine = 144
; Folding = --
; EnableAsm
; EnableXP
; CompileSourceDirectory