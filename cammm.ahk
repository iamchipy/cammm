/*
==============================================================================================================
  ____  _      _                       _              
 / __ \| |    (_)                     | |             
| /  \/| |__   _  _ __   _   _      __| |  ___ __   __
| |    | '_ \ | || '_ \ | | | |    / _` | / _ \\ \ / /
| \__/\| | | || || |_) || |_| | _ | (_| ||  __/ \ V / 
 \____/|_| |_||_|| .__/  \__, |(_) \__,_| \___|  \_/  
                 | |      __/ |                       
                 |_|     |___/  
==============================================================================================================
*/
;run preliminary script setup (placed above so GLOBALS can overwrite)
;https://github.com/iamchipy/chipys-ahk-library
#Include C:\Dropbox\_SCRIPTS\chipys-ahk-library\chipys-ahk-library.ahk  	;this is STATIC to allow for direct us of latest CUL
#SingleInstance Force

;===================================================
app_version := "2.8.16", unused := "custom var"
;@Ahk2Exe-Let U_version = %A_PriorLine~U)^(.+"){1}(.+)".*$~$2%

;@Ahk2Exe-SetCopyright    Freeware written by Chipy
;@Ahk2Exe-SetCompanyName  Chipy.dev
;@Ahk2Exe-SetFileVersion  %U_version%
;@Ahk2Exe-SetName         Chipy's ARK Map Marker Manager
;@Ahk2Exe-SetDescription  Chipy's ARK Map Marker Manager
;@Ahk2Exe-SetOrigFilename cammm.ahk
;===================================================

;constructed for AHKv2 
;should be able to find it in (autohotkey.com/download/2.0/)
coded_on := "2.0.10"
if A_AhkVersion != coded_on and !A_IsCompiled
	msgbox "You are running AHK v" A_AhkVersion "`n`rThis code was writting on v" coded_on "`n`nPlease download that exact version from autohotkey.com/download/2.0/"

if !DirExist(A_AppData "/ChipysArkMapMarkerManager")
    DirCreate(A_AppData "/ChipysArkMapMarkerManager")
if A_IsCompiled
    A_WorkingDir := A_AppData "/ChipysArkMapMarkerManager"
global LOG_LEVEL := 2
global SCRIPT_NAME := "cammm"
global CFG_PATH := SCRIPT_NAME ".cfg"
global LOG_PATH := SCRIPT_NAME ".log"
LOCALIZATION_FILENAME := "localization.ini"

; Statics
iniSectionName := "/Script/ShooterGame.ShooterGameUserSettings"
baseURL := "https://chipy.dev/download/"
loopBreaker := true

database := Map()
iniPath := getINIPath()
cfg := ConfigManagerTool()
updateObj := UpdateHandler("https://chipy.dev/download/cammm.exe",app_version,SCRIPT_NAME, "Chipy's ARK MapMarkerManager")

; ### MapMarker
; (id, name, color, xyz, map:="TheIsland_WP", overlay:="False")
class MapMarker {
    __New(id, name, rgbArray, xyz, map:="TheIsland_WP", overlay:="True", assignment:="other",tags:="") {

        if (rgbArray[1]> 1 or
            rgbArray[2]> 1 or
            rgbArray[3]> 1  ){
            rgbArray := this._rescaleRGB(rgbArray)
        }

        this.id := id
        this.name := Trim(name)
        this.r := rgbArray[1]
        this.g := rgbArray[2]
        this.b := rgbArray[3]
        this.x := xyz[1]
        this.y := xyz[2]
        this.z := xyz[3]
        this.map := map
        this.overlay := overlay
        this.assignment := assignment
        this.tags := StrSplit(tags,"|")
    }

    _rescaleRGB(rgbArray){
        return [rgbArray[1]/255,rgbArray[2]/255,rgbArray[3]/255]
    }

    stringify(){
        ; top 2 are returned versions
        ; SavedMinimapMarks=(Name="Artifact_Cunning",CustomTag="Artifact_Cunning-chipy",Location=(X=267420.000000,Y=-28505.000000,Z=-43224.000000),Color=(R=0.929412,G=0.647059,B=0.082353,A=1.000000),ID=232,MarkIcon=/Script/Engine.Texture2D'"/Game/PrimalEarth/UI/Textures/T_UI_HUDPointOfInterest_Collectible.T_UI_HUDPointOfInterest_Collectible"',MapName="TheIsland_WP",bIsShowing=True,IconColor=(R=0.929412,G=0.647059,B=0.082353,A=1.000000),bIsShowingText=True,CharacterID=-1,CharacterIsPlayer=False)
        ; SavedMinimapMarks=(Name="Artifact_Cunning",CustomTag="",Location=(X=267420.000000,Y=-28505.000000,Z=-43224.000000),Color=(R=0.929412,G=0.647059,B=0.082353,A=1.000000),ID=0,MarkIcon=/Script/Engine.Texture2D'"/Game/PrimalEarth/UI/Textures/T_UI_HUDPointOfInterest_Collectible.T_UI_HUDPointOfInterest_Collectible"',MapName="TheIsland_WP",bIsShowing=False,IconColor=(R=0.929412,G=0.647059,B=0.082353,A=1.000000),bIsShowingText=True,CharacterID=-1,CharacterIsPlayer=False)
        ; SavedMinimapMarks=(Name="Artifact_Cunning",             Location=(X=267420,Y=-28505,Z=-43224),                     Color=(R=0.92941176470588238,G=0.6470588235294118,B=0.082352941176470587,A=1.000000),ID=chipy-223,MarkIcon=/Script/Engine.Texture2D'"/Game/PrimalEarth/UI/Textures/T_UI_HUDPointOfInterest_Collectible.T_UI_HUDPointOfInterest_Collectible"',MapName="TheIsland_WP",bIsShowing=False,IconColor=(R=0.92941176470588238,G=0.6470588235294118,B=0.082352941176470587,A=1.000000),bIsShowingText=True,CharacterID=-1,CharacterIsPlayer=False)
        
        outputString := 'SavedMinimapMarks=(Name="'
        outputString .= this.name
        outputString .= '",CustomTag="'
        outputString .= this.name "-chipy"
        outputString .= '",Location=(X='
        outputString .= this.x
        outputString .= ',Y='
        outputString .= this.y
        outputString .= ',Z='
        outputString .= this.z
        outputString .= '),Color=(R='
        outputString .= this.r
        outputString .= ',G='
        outputString .= this.g
        outputString .= ',B='
        outputString .= this.b
        outputString .= ',A=1.000000),ID='
        outputString .= this.id
        outputString .= ",MarkIcon=/Script/Engine.Texture2D'`"/Game/PrimalEarth/UI/Textures/T_UI_HUDPointOfInterest_Collectible.T_UI_HUDPointOfInterest_Collectible`"',MapName=`""
        outputString .= this.map
        outputString .= '",bIsShowing='
        outputString .= this.overlay        
        outputString .= ',IconColor=(R='
        outputString .= this.r
        outputString .= ',G='
        outputString .= this.g
        outputString .= ',B='
        outputString .= this.b
        outputString .= ',A=1.000000),bIsShowingText=True,CharacterID=-1,CharacterIsPlayer=False)'
        return outputString
    }
}

; ### MarkerCollections
; __New(name, color, map:="TheIsland_WP", overlay:="True", description:="")
class MarkerCollection {
    __New(name, color, map:="TheIsland_WP", overlay:="True", description:="", ListSliceArray:="") {
        this.name:= name
        this.color:=color
        this.rgbArray:=this._colorToRGBArray(color)
        this.map:= map
        this.markers := []
        this.overlay := overlay
        this.guiCheckbox:= ""
        this.description:=description
        this.ListSliceArray:=ListSliceArray
        this.addedMarkerCount:=0
    }

    ; ## _addMarker(markerObject)
    ; Simply added a markerObject into the markers
    _addMarker(markerObject){
        this.markers.push(markerObject)
    }

    ; ## readInMarkers(fileName)
    ; File name is fully qualified file path
    ; File must be CSV format
    ; #### Columns
    ; - 1 chipy-ID#
    ; - 2 name
    ; - 3 x
    ; - 4 y
    ; - 5 z
    ; - 6 map
    ; - 7 assignment
    ; - 8 tags
    readInMarkers(donwloadedString, name){  
        this.addedMarkerCount := 0
        ; if (Type(this.ListSliceArray) == "Array"){
        ;     MsgBox donwloadedString
        ; }        
        ; split string into lines
        for line in StrSplit(donwloadedString,"`n") {
            ; split lines into words
            word := StrSplit(line,",")
            ; if the resulting list is too short to be valid end the loop
            if(word.Length < 6){
                return 
            }
            
            ; if there is a selection subslice to only show selected number then check
            if (Type(this.ListSliceArray) == "Array"){
                ; loops for each item in the list of selected IDs
                for id in this.ListSliceArray{
                    ; if the id doesn't match
                    if (word[1] != id)
                        continue
                    this._addMarker(MapMarker(word[1],word[2],this.rgbArray,[word[3],word[4],word[5]],word[6],this.overlay))
                    this.addedMarkerCount +=1
                    break                    
                }
            }else if(word[7] != name){
                ; if the current entry does not match the assignment name in column 7 skip
                continue
            }else{
                this._addMarker(MapMarker(word[1],word[2],this.rgbArray,[word[3],word[4],word[5]],word[6],this.overlay))
                this.addedMarkerCount +=1
            }
        }
        return this.addedMarkerCount
    }

    ; ## _colorToRGB(color)
    ; Take a Hex based color value and converts to RGBArray
    _colorToRGBArray(color:="0x00BBFF"){
        ; rHex:=Format(":X",rStr) GOES TO hex (wrong direction for this just a note for later)
        color := String(color)

        if(SubStr(color,1,1) = "c") {
            color:=SubStr(color,2)
        }        

        if (SubStr(color,1,2) = "0x")
            color:=SubStr(color,3)

        rHex := this._hexToDec(SubStr(color,1,2))
        gHex := this._hexToDec(SubStr(color,3,2))
        bHex := this._hexToDec(SubStr(color,5,2))
        ; MsgBox(color "`n" rHex " " gHex " " bHex)
        return [rHex,gHex,bHex]
    }
    
    ; ## _hexToDec(hex) 
    ; Take a hex value and converts it to decimal
    ; This in an implicit change over for AHK we just gotta prefix "0x" then do "math" with it to trigger    
    ; FF >> 255
    _hexToDec(hex) {
        withPrefix := "0x" . hex
        return withPrefix + 0
    }
}

buildConfig(&cfg)
refreshLocalization(true)
buildGUI(iniPath, iniSectionName, database,   baseURL, &loopBreaker, cfg)
buildTray()

return

buildTray(){
    A_TrayMenu.add("OPEN GUI",(*)=>buildGUI(iniPath, iniSectionName, database,   baseURL, &loopBreaker, cfg))
}

buildConfig(&cfg){
    
    cfg.ini("localizationlanguage",,"english",,"Language selection",["English","Turkish"])
    cfg.load_all()
    cfg.save_all()
    
    ; MsgBox "loading " cfg.c["localizationlanguage"].value 
    ; ExitApp
}


constructDatabase(database, baseURL, OptionsGUI, &loopBreaker){
    cachedList := ""
    fileName := "cammm_raw.csv"
    donwloadURL := StrReplace(baseURL fileName, "\", "/")

    ; build REQUEST obj
    whr := ComObject("WinHttp.WinHttpRequest.5.1")
    whr.Open("GET",  donwloadURL, true)
    whr.Send()
    ; Using 'true' above and the call below allows the script to remain responsive.
    whr.WaitForResponse()

    ; handle weird line starts
    try{
        cachedList := StrSplit(whr.ResponseText, "ï»¿")[2]
        MsgBox "(" StrSplit(cachedList, "`n").Length -1 ") " localize("promptDownloadSuccess", cfg.c["localizationlanguage"].value) 
    }catch{
        MsgBox("Error downloading Nodes!")
        FileAppend(A_Now "|" A_LastError,"cmmm.log")
    }

    ; ; Build the list of areas dynamically (by checking for unique entries)
    ; extractUniqueCatagories(cachedList){
    ;     uniqueEntries := []
    ;     ; split string into lines
    ;     for line in StrSplit(cachedList,"`n") {
    ;         ; split lines into words
    ;         word := StrSplit(line,",")
    ;         ; if the resulting list is too short to be valid end the loop
    ;         if(word.Length < 6){
    ;             return 
    ;         }
    ;         ; If this catagory not ready in the list add it
    ;         if (!InStr(uniqueEntries, word[7])){
    ;             uniqueEntries.Push(word[7])
    ;         }
    ;     }

    ;     return uniqueEntries
    ; }
    ; ; new method is to just loop and create one for each type/zone/catagory
    ; for entry in extractUniqueCatagories(cachedList){
    ;     constructCollection(entry,"ced9315","TheIsland_WP","True", entry "Description",         cachedList, database)
    ; }

    constructCollection(name, color, map, overlay, descLocName, cachedList, database, ListSliceArray:=0){
        descStr := localize(descLocName, cfg.c["localizationlanguage"].value)
        try{
            database[name] := MarkerCollection(name, color, map, overlay, descStr, ListSliceArray)
            database[name].readInMarkers(cachedList, name)
        }catch{
            MsgBox(name " error with: " whr.ResponseText)
            FileAppend(A_Now "|constructCollection>" name "|" A_LastError,"cmmm.log")
        }
    }

    ListSliceArray := [6,19,46,48,51,52,53,55,56,57,60,62,89,90,95,99,110,112,113,131,140,148,149,160,169,191,200]
    constructCollection("NoBeds",           "cfffb00","TheIsland_WP","True", "nonBedCaveDescription",  cachedList, database, ListSliceArray)

    constructCollection("Artifact",         "ced9315","TheIsland_WP","True", "artifactCollectionDescription",         cachedList, database)
    constructCollection("BlackPearlA",      "ced1597","TheIsland_WP","True", "blackPearlADescription",     cachedList, database)
    constructCollection("DeepSea",          "c15eded","TheIsland_WP","True", "underWaterDropsDescription",  cachedList, database)
    constructCollection("MetalRunA",        "cfffb00","TheIsland_WP","True", "MetalRunADescription",  cachedList, database)
    constructCollection("metalFarsPeak",    "caeac76","TheIsland_WP","True", "metalFarsPeak",  cachedList, database)
    constructCollection("metalVolcano",    "caeac76","TheIsland_WP","True", "metalVolcano",  cachedList, database)
    constructCollection("metalRedWood",    "caeac76","TheIsland_WP","True", "metalRedWood",  cachedList, database)
    constructCollection("metalSouthEastA",    "caeac76","TheIsland_WP","True", "metalSouthEastA",  cachedList, database)
    constructCollection("metalSouthEastB",    "caeac76","TheIsland_WP","True", "metalSouthEastB",  cachedList, database)
    constructCollection("metalBlueOby",    "caeac76","TheIsland_WP","True", "metalBlueOby",  cachedList, database)

    constructCollection("noteBoss",         "cd6d6d6","TheIsland_WP","True", "noteBossDescription",      cachedList, database)
    constructCollection("noteCave",         "c1b1b1b","TheIsland_WP","True", "noteCaveDescription",  cachedList, database)
    constructCollection("noteEasy",         "c15ed4f","TheIsland_WP","True", "noteEasyDescription",  cachedList, database)
    constructCollection("noteMountain",     "cf14553","TheIsland_WP","True", "noteMountainDescription",                     cachedList, database)
    constructCollection("noteOther",        "c6b4219","TheIsland_WP","True", "noteOtherDescription",  cachedList, database)
    
    constructCollection("dropCentralCaveCLEVER","c8af508","TheIsland_WP","True", "dropCentralCaveCLEVERDescription",  cachedList, database)
    constructCollection("dropNWCaveSKYLORD","c8af508","TheIsland_WP","True", "dropNWCaveSKYLORDDescription",  cachedList, database)
    constructCollection("dropLowerSCaveHUNTER","c8af508","TheIsland_WP","True", "dropLowerSCaveHUNTERDescription",  cachedList, database)
    constructCollection("dropUpperSCavePACK","c8af508","TheIsland_WP","True", "dropUpperSCavePACKDescription",  cachedList, database)
    constructCollection("dropNECaveDEVOURER","c8af508","TheIsland_WP","True", "dropNECaveDEVOURERDescription",  cachedList, database)
    constructCollection("dropLavaCaveMASSIVE","c8af508","TheIsland_WP","True", "dropLavaCaveMASSIVEDescription",  cachedList, database)
    constructCollection("dropSwampCaveIMMUNE","c8af508","TheIsland_WP","True", "dropSwampCaveIMMUNEDescription",  cachedList, database)
    constructCollection("dropSnowCaveSTRONG","c8af508","TheIsland_WP","True", "dropSnowCaveSTRONGDescription",  cachedList, database)
    constructCollection("dropLostFaithBRUTE","c8af508","TheIsland_WP","True", "dropLostFaithBRUTEDescription",  cachedList, database)
    constructCollection("dropLostHopeCUNNING","c8af508","TheIsland_WP","True", "dropLostHopeCUNNINGDescription",  cachedList, database)
    
    
temp:="
(
CREDIT:
@adjaro - dropSwampCaveIMMUNE, dropSnowCaveSTRONG (TONS)
@cheaterramos - Brute4/ Pack1

    Name	            Artifact	            Lat	    Lon
Central Cave	        Clever (Broodmother)	41.5	46.9
North West Cave	        Skylord (Dragon)	    19.3	19.0
Lower South Cave	    Hunter (Broodmother)	80.3	53.5
North East Cave	        Devourer (Megapithecus)	14.7	85.4
Upper South Cave	    Pack (Megapithecus)	    68.2	56.2
Lava Cave	            Massive (Broodmother)	70.6	86.1
Swamp Cave	            Immune (Dragon)	        62.7	37.3
Snow Cave	            Strong (Dragon)	        29.1	31.8
Caverns of Lost Faith	Brute (Megapithecus)	53.7	10.4
Caverns of Lost Hope	Cunning (Dragon)	    45.9	88.9
dropCentralCaveCLEVER
dropNWCaveSKYLORD
dropLowerSCaveHUNTER
dropUpperSCavePACK
dropNECaveDEVOURER
dropLavaCaveMASSIVE
dropSwampCaveIMMUNE
dropSnowCaveSTRONG
dropLostFaithBRUTE
dropLostHopeCUNNING
)"
    

    OptionsGUI.Destroy()
    buildGUI(iniPath, iniSectionName, database,   baseURL, &loopBreaker, cfg)
}

; excecute
addMarkersToINI(iniPath,iniSectionName, database){
    countRemoved :=0
    countAdded :=0

    ; WARN the user
    MsgBox localize("promptINIWarning", cfg.c["localizationlanguage"].value)

    ; Get current INI state
    currentINI := IniRead(iniPath, iniSectionName)

    ; Purge our old lines from the INI
    cleanedINI := ""
    loop parse currentINI, "`n" {
        if !lineContainsChipy(A_LoopField){
            ; we can keep the line
            cleanedINI .= A_LoopField "`n"
        }else{
            countRemoved +=1
        }
    }


    ; compile our markers
    modifiedINI:=""
    ; Loop for each collection
    for name, collection in database{
        
        ; if the collection is selected in GUI
        if (collection.guiCheckbox.value) {
            ; MsgBox name
            ; loop for each marker in the collection
            for marker in collection.markers{
                ; MsgBox marker.stringify()
                modifiedINI .= marker.stringify() "`n"
                countAdded +=1
            }
        }
    }

    ; append the prevevious lines back in
    modifiedINI := cleanedINI . modifiedINI "`n"
    
    ; Save
    IniWrite(modifiedINI,iniPath,iniSectionName)

    reportStr :=localize("promptINIReport1", cfg.c["localizationlanguage"].value)
    reportStr .=A_LastError
    reportStr .=localize("promptINIReport2", cfg.c["localizationlanguage"].value)
    reportStr .=countRemoved
    reportStr .=localize("promptINIReport3", cfg.c["localizationlanguage"].value)
    reportStr .=countAdded
    reportStr .=localize("promptINIReport4", cfg.c["localizationlanguage"].value)
    MsgBox reportStr

}

; excecute
removeMarkersFromINI(iniPath,iniSectionName){
    countRemoved :=0
    ; WARN the user
    MsgBox localize("promptINIWarning", cfg.c["localizationlanguage"].value)

    ; Get current INI state
    currentINI := IniRead(iniPath, iniSectionName)

    ; Purge our old lines from the INI
    cleanedINI := ""
    loop parse currentINI, "`n" {
        if !lineContainsChipy(A_LoopField){
            ; we can keep the line
            cleanedINI .= A_LoopField "`n"
        }else{
            countRemoved+=1
        }
    }

    ; Save
    IniWrite(cleanedINI,iniPath,iniSectionName)

    reportStr :=localize("promptINIReport1", cfg.c["localizationlanguage"].value)
    reportStr .=A_LastError
    reportStr .=localize("promptINIReport2", cfg.c["localizationlanguage"].value)
    reportStr .=countRemoved
    reportStr .=localize("promptINIReport4", cfg.c["localizationlanguage"].value)
    MsgBox reportStr

}

lineContainsChipy(InputString){
    if InStr(InputString,"chipy")
        return true
    return false
}

buildGUI(iniPath,iniSectionName, database,   baseURL, &loopBreaker, cfg){
    ; build GUI
    GUI_FONT_SIZE:=17
    OptionsGUI := gui(" -MinimizeBox -DPIScale","Chipys ASA Map Marker Manager (" app_version " " cfg.c["localizationlanguage"].value ")")
    OptionsGUI.setfont("c00cccc s" round(GUI_FONT_SIZE) " q3", "Terminal")				
    ; OptionsGUI.setfont("c00cccc s" round(GUI_FONT_SIZE) " q5 w700", "Noto Sans")							
    OptionsGUI.setfont("c00cccc s" round(GUI_FONT_SIZE) " q5 w700", "roboto")							
    OptionsGUI.BackColor := "444444"								

    OptionsGUI.Add("text",  ,localize("guiTitleNotes", cfg.c["localizationlanguage"].value))
    for key, value in database {
        if InStr(key, "note"){
            database[key].guiCheckbox := OptionsGUI.Add("Checkbox", "+right xm yp" round(GUI_FONT_SIZE*1.5) " background" SubStr(value.color,2) ,"   ")
            OptionsGUI.Add("text", " yp" , "[" value.addedMarkerCount "] " value.description)
        }
    }
    OptionsGUI.Add("text", "xm "  ,localize("guiTitlePOIs", cfg.c["localizationlanguage"].value))
    for key, value in database {
        if !InStr(key, "note"){
            database[key].guiCheckbox := OptionsGUI.Add("Checkbox", "+right xm yp" round(GUI_FONT_SIZE*1.5) " background" SubStr(value.color,2) ,"   ")
            OptionsGUI.Add("text", " yp" , "(" value.addedMarkerCount ") " value.description)
        }
    }

    
    ; OptionsGUI.Add("Label", "CustomStyle CSS file:xm " , localize("buttonDownload", cfg.c["localizationlanguage"].value)).OnEvent("click",(*)=> constructDatabase(database,   baseURL, OptionsGUI, &loopBreaker))
    temp := OptionsGUI.Add("button", "xm h40" , localize("buttonDownload", cfg.c["localizationlanguage"].value))
    temp.OnEvent("click",(*)=> constructDatabase(database,   baseURL, OptionsGUI, &loopBreaker))
    temp.Opt("Background666666 default")
    temp := OptionsGUI.Add("button", "xm h40" , localize("buttonApply", cfg.c["localizationlanguage"].value))
    temp.OnEvent("click",(*)=> addMarkersToINI(iniPath,iniSectionName, database))
    temp.Opt("Background666666 default")
    temp := OptionsGUI.Add("button", "yp h40" , localize("buttonINI", cfg.c["localizationlanguage"].value))
    temp.OnEvent("click",(*)=> Run(iniPath))
    temp.Opt("Background666666 default")
    temp := OptionsGUI.Add("button", "xm h40" , localize("buttonCleanup", cfg.c["localizationlanguage"].value))
    temp.OnEvent("click",(*)=> removeMarkersFromINI(iniPath,iniSectionName))
    temp.Opt("Background666666 default")
    temp := OptionsGUI.Add("button", "yp h40" , localize("buttonCCC", cfg.c["localizationlanguage"].value))
    temp.OnEvent("click",(*)=> toggleCaptureClipboardChanges(&loopBreaker))
    temp.Opt("Background666666 default")

    ; OptionsGUI.Add("button", "yp" , "Capture CCC").OnEvent("click",(*)=> toggleCaptureClipboardChanges(&loopBreaker))    
    OptionsGUI.setfont("c00cccc s" round(GUI_FONT_SIZE*0.6), )		
    OptionsGUI.AddLink( "xm" ,localize("supportMe", cfg.c["localizationlanguage"].value))
    OptionsGUI.show()
}

localize(string_name, target_language:="english"){
    ; try
    ;     refreshLocalization()
    try
        return StrReplace(IniRead("localization.ini", target_language, string_name),"``n","`n")
    catch
        try
            return StrReplace(IniRead("localization.ini", "english", string_name),"``n","`n")
        return "LocErr: " string_name
}

refreshLocalization(forceRedownload:=0){
    if (!FileExist(LOCALIZATION_FILENAME) or forceRedownload){
        Download("https://chipy.dev/download/cammm_localization.ini", LOCALIZATION_FILENAME)
        log("INFO: Downloading Localization " LOCALIZATION_FILENAME)
    }
    if (!FileExist("NotoSans-Regular.ttf")){
        Download("https://chipy.dev/res/NotoSans-Regular.ttf", "NotoSans-Regular.ttf")
        
        ; run(A_WinDir "\fonts\NotoSans-Regular.ttf")
        ; ; Run('reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /v "NotoSans Regular (TrueType)" /t REG_SZ /d NotoSans-Regular.ttf /f')
        ; RegWrite("NotoSans-Regular.ttf", "REG_SZ", "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts","NotoSans Regular (TrueType)")
        ; MsgBox "you are missing NotoSans-Regular.ttf"
        
    }
}

getINIPath(){
    ; get ASA's install path from Reg>Steam>lib>InstallPath
    steamPath := RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Valve\Steam","InstallPath", "NULL")
    ArkSurvivalAscendedID:= "2399830"
    streanVDF := steamPath "\steamapps\libraryfolders.vdf" 
    libFolder := ""
    loop read streanVDF 
        {
            ; MsgBox A_LoopReadLine
            if InStr(A_LoopReadLine,"Path") {
                libFolder := A_LoopReadLine
            }
            if InStr(A_LoopReadLine, ArkSurvivalAscendedID){
                break
            }
        }
    loop parse libFolder , '"'{
        ; MsgBox A_LoopField A_Index
        if A_Index > 3{
            ASAPath := A_LoopField
            break
        }
    }
    return strreplace(ASAPath,"\\","\") "\steamapps\common\ARK Survival Ascended\ShooterGame\Saved\Config\Windows\GameUserSettings.ini"
}

toggleCaptureClipboardChanges(&loopBreaker){
    ticker:="x"
    cliboardPrevious:=""
    clipboardStack:=""
    if (loopBreaker){
        A_Clipboard := ""  ; must clear clipboard or else we get all previous clipboard data toooo
        loopBreaker := false
        captureClipboardChanges(ticker, cliboardPrevious, clipboardStack, &loopBreaker)
        MsgBox "Captuing started! Now just open console and hit the 'ccc' command to save your mark.`n`nThen when you are done click the Capture Button again to copy it all to clipboard."
    }else{
        loopBreaker := true
    }
}

captureClipboardChanges(ticker, cliboardPrevious, clipboardStack ,&loopBreaker, waitTime:=-750 ){
    ticker := ticker="x"? ticker:="+":ticker:="x"
    ToolTip(ticker, 50,50,9)
    if (A_Clipboard != cliboardPrevious){
        ToolTip(ticker " - " A_Clipboard, 50,50,9)
        cliboardPrevious:=A_Clipboard
        clipboardStack .= A_Now "|" A_Clipboard "`n"
    }


    ; end loop
    if (!loopBreaker){
        SetTimer(()=>captureClipboardChanges(ticker, cliboardPrevious, clipboardStack ,&loopBreaker,waitTime), waitTime)
    }else{
        A_Clipboard := clipboardStack
        FileAppend(clipboardStack, "cammm_clipboard.log")
        ToolTip("Saved", 50,50,9)
        sleep(1000)
        ToolTip("",,,9)
    }
}


;open 5.62.117.5    ---"UNET ERROR"
; http://arkdedicated.com/news.ini
; http://arkdedicated.com/dynamicconfig.ini
; http://arkdedicated.com/pcnotification.html

; Wishlist
; Minimap selection