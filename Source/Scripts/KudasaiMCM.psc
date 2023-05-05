Scriptname KudasaiMCM extends SKI_ConfigBase

KudasaiMain Property Main
  KudasaiMain Function Get()
    return (Self as Quest) as KudasaiMain
  EndFunction
EndProperty

; ----------- General

bool Property bStealArmor = true Auto Hidden
int Property iMaxAssaults = 4 Auto Hidden
float Property fRapistQuits = 35.0 Auto Hidden

bool Property bHunterAssault = true Auto Hidden
bool Property bHunterStrip = true Auto Hidden

int Property iSurrenderKey = -1 Auto Hidden ; Surrender
int Property iSurrenderKeyM = -1 Auto Hidden
int Property iAssaultKey = -1 Auto Hidden ; Player initiated Struggle Game
int Property iAssaultKeyM = -1 Auto Hidden

; ----------- NSFW

bool Property FrameCreature Hidden
  bool Function Get()
    return iFrameSL > 0 && KudasaiAnimationSL.AllowCreatures()
  EndFunction
EndProperty

bool Property bAllowFF = true Auto Hidden
bool Property bAllowMM = true Auto Hidden
bool Property bAllowMC = false Auto Hidden
bool Property bAllowFC = false Auto Hidden

int[] Property iSceneTypeWeight Auto Hidden

int Property iFrameSL = 100 Auto Hidden

String[] Property SLTags Auto Hidden
{F<-M // M<-M // M<-F // F<-F // M<-* // F<-*}

; ----------- Race

String[] sRaceKeys
bool Function AllowedRaceType(String asRaceKey)
  If(asRaceKey == "Human")
    return true
  ElseIf(!FrameCreature)
    return false
  EndIf
  return sRaceKeys.Find(asRaceKey) > -1
EndFunction

; --------------------- Menu

int Function GetVersion()
	return 1
endFunction

Event OnConfigInit()
  Pages = new String[3]
  Pages[0] = "$YK_General"
  Pages[1] = "$YK_NSFW"
  Pages[2] = "$YK_Race"

  SLTagsDefault()
  iSceneTypeWeightDefault()
  Load()
EndEvent

Function SLTagsDefault()
  SLTags = new String[6]
  SLTags[2] = "femdom"
EndFunction
Function iSceneTypeWeightDefault()
  iSceneTypeWeight = new int[4]
  iSceneTypeWeight[0] = 75 
  iSceneTypeWeight[1] = 60
  iSceneTypeWeight[2] = 35
  iSceneTypeWeight[3] = 20
EndFunction

Event OnConfigClose()
  Save()
EndEvent

Event OnGameReload()
  parent.OnGameReload()
  Load()
EndEvent

Event OnPageReset(string page)
  SetCursorFillMode(TOP_TO_BOTTOM)
  If (page == "")
    page = "$YK_General"
  EndIf
  If (page == "$YK_General")
    AddHeaderOption("$YK_Events")
    AddToggleOptionST("postcmbtkeeparmor", "$YK_StealArmor", bStealArmor)
    AddSliderOptionST("postcmbtmaxassaults", "$YK_MaxAssaults", iMaxAssaults, "{0}")
    AddSliderOptionST("postcmbtrapiststays", "$YK_RapistQuits", fRapistQuits, "{1}%")
    AddHeaderOption("$Achr_HunterPride")
    AddToggleOptionST("hunterassault", "$YK_HunterAssaultToggle", bHunterAssault && Acheron.HasOption(KudasaiMain.HunterAssaultID()))
    AddToggleOptionST("hunterstrip", "$YK_HunterStripToggle", bHunterStrip && Acheron.HasOption(KudasaiMain.HunterStripID()))
    SetCursorPosition(1)
    AddHeaderOption("$YK_SurrenderKey")
    AddKeyMapOptionST("surrenderkey", "$YK_Hotkey", iSurrenderKey)
    AddKeyMapOptionST("surrendermodkey", "$YK_ModifierKey", iSurrenderKeyM)
    AddEmptyOption()
    AddHeaderOption("$YK_AssaultKey")
    AddKeyMapOptionST("assaultkey", "$YK_Hotkey", iAssaultKey)
    AddKeyMapOptionST("assaultmodkey", "$YK_ModifierKey", iAssaultKeyM)

  ElseIf (page == "$YK_NSFW")
    AddHeaderOption("$YK_Sex")
    AddToggleOptionST("sexFF", "$YK_AllowFF", bAllowFF)
    AddToggleOptionST("sexMM", "$YK_AllowMM", bAllowMM)
    AddToggleOptionST("sexMC", "$YK_AllowMC", bAllowMC)
    AddToggleOptionST("sexFC", "$YK_AllowFC", bAllowFC)
    AddHeaderOption("$YK_SceneTypes")
    int n = 0
    While(n < iSceneTypeWeight.Length)
      AddSliderOptionST("scenetype_" + n, "$YK_SceneType_" + n, iSceneTypeWeight[n], "{0}")
      n += 1
    EndWhile
    SetCursorPosition(1)
    AddHeaderOption("$YK_AdultFrames")
    AddToggleOptionST("sexlabweight", "$YK_SexLabWeight", iFrameSL > 0, OPTION_FLAG_DISABLED)
    ; IDEA: Toys?
    AddEmptyOption()
    AddHeaderOption("$YK_Tagging")
    int i = 0
    While(i < SLTags.Length)
      AddInputOptionST("sltags_" + i, "$YK_SLTags_" + i, SLTags[i], getFlag(iFrameSL != -1))
      i += 1
    EndWhile
    AddTextOptionST("sltagsreadme", "", "$YK_AboutTags", getFlag(iFrameSL != -1))

  ElseIf(page == "$YK_Race")
    If(iFrameSL == -1 || !KudasaiAnimationSL.AllowCreatures())
      AddTextOption("$YK_RaceDisallowed", "", OPTION_FLAG_DISABLED)
      return
    EndIf
    SetCursorFillMode(LEFT_TO_RIGHT)
    AddHeaderOption("")
    AddTextOptionST("enablecreaturesall", "$YK_EnableAll", "")
    String[] keys = KudasaiAnimationSL.GetAllRaceKeys()
    int i = 0
    While(i < keys.Length)
      AddToggleOptionST("racekey_" + keys[i], keys[i], sRaceKeys.Find(keys[i]) > -1)
      i += 1
    EndWhile
  EndIf
EndEvent

; --------------------- State Options

Event OnSelectST()
  String[] s = StringUtil.Split(GetState(), "_")
  If(s[0] == "postcmbtkeeparmor")
    bStealArmor = !bStealArmor
    SetToggleOptionValueST(bStealArmor)
  ElseIf(s[0] == "hunterassault")
    String id = KudasaiMain.HunterAssaultID()
    bool hasOption = Acheron.HasOption(id)
    If(hasOption && bHunterAssault)
      Acheron.RemoveOption(id)
      bHunterAssault = false
    ElseIf(!hasOption && !bHunterAssault)
      Main.AddHunterAssaultOption()
      bHunterAssault = true
    Else
      bHunterAssault = hasOption
    EndIf
    SetToggleOptionValueST(bHunterAssault)
  ElseIf(s[0] == "hunterstrip")
    String id = KudasaiMain.HunterStripID()
    bool hasOption = Acheron.HasOption(id)
    If(hasOption && bHunterStrip)
      Acheron.RemoveOption(id)
      bHunterStrip = false
    ElseIf(!hasOption && !bHunterStrip)
      Main.AddHunterStripOption()
      bHunterStrip = true
    Else
      bHunterStrip = hasOption
    EndIf
    SetToggleOptionValueST(bHunterStrip)

  ; --------------- NSFW
  ElseIf(s[0] == "sexlabweight")
    iFrameSL = 1 - iFrameSL
    SetToggleOptionValueST(iFrameSL > 0)
  ElseIf(s[0] == "sexFF")
    bAllowFF = !bAllowFF
    SetToggleOptionValueST(bAllowFF)
  ElseIf(s[0] == "sexMM")
    bAllowMM = !bAllowMM
    SetToggleOptionValueST(bAllowMM)
  ElseIf(s[0] == "sexMC")
    bAllowMC = !bAllowMC
    SetToggleOptionValueST(bAllowMC)
  ElseIf(s[0] == "sexFC")
    bAllowFC = !bAllowFC
    SetToggleOptionValueST(bAllowFC)
  ElseIf(s[0] == "sltagsreadme")
    ShowMessage("$YK_AboutTagsMsg", false, "$YK_Ok")

  ; --------------- Race
  ElseIf(s[0] == "enablecreaturesall")
    sRaceKeys = PapyrusUtil.RemoveString(KudasaiAnimationSL.GetAllRaceKeys(), "")
    ForcePageReset()
  ElseIf(s[0] == "racekey")
    bool includes = sRaceKeys.Find(s[1]) > -1
    If(includes)
      sRaceKeys = PapyrusUtil.RemoveString(sRaceKeys, s[1])
    Else
      sRaceKeys = PapyrusUtil.PushString(sRaceKeys, s[1])
    EndIf
    SetToggleOptionValueST(!includes)
  EndIf
EndEvent

Event OnSliderOpenST()
	String[] s = StringUtil.Split(GetState(), "_")
  ; --------------- Defeat
  If(s[0] == "postcmbtmaxassaults")
		SetSliderDialogStartValue(iMaxAssaults)
		SetSliderDialogDefaultValue(4)
		SetSliderDialogRange(0, 25)
		SetSliderDialogInterval(1)
	ElseIf(s[0] == "postcmbtrapiststays")
		SetSliderDialogStartValue(fRapistQuits)
		SetSliderDialogDefaultValue(35)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(0.5)

  ; --------------- NSFW
	ElseIf(s[0] == "scenetype")
    int i = s[1] as int
		SetSliderDialogStartValue(iSceneTypeWeight[i])
		SetSliderDialogDefaultValue(50)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
  EndIf
EndEvent

Event OnSliderAcceptST(float value)
	string[] s = StringUtil.Split(GetState(), "_")
  ; --------------- Events
	If(s[0] == "postcmbtmaxassaults")
		iMaxAssaults = value as int
		SetSliderOptionValueST(iMaxAssaults, "{0}")
	ElseIf(s[0] == "postcmbtrapiststays")
		fRapistQuits = value
		SetSliderOptionValueST(fRapistQuits, "{1}%")

  ; --------------- NSFW
	ElseIf(s[0] == "scenetype")
    int i = s[1] as int
		iSceneTypeWeight[i] = value as int
		SetSliderOptionValueST(iSceneTypeWeight[i], "{1}")
  EndIf
EndEvent

Event OnKeyMapChangeST(int newKeyCode, string conflictControl, string conflictName)
  String[] s = StringUtil.Split(GetState(), "_")
  If(newKeyCode == 1)
    newKeyCode = -1
  EndIf
  If(s[0] == "surrendermodkey")
    iSurrenderKeyM = newKeyCode
    SetKeyMapOptionValueST(iSurrenderKeyM)
  ElseIf(s[0] == "assaultmodkey")
    iAssaultKeyM = newKeyCode
    SetKeyMapOptionValueST(iAssaultKeyM)
  ElseIf(newKeyCode != -1 && conflictControl != "")
		string msg
		If(conflictName != "")
			msg = "$YK_ConflictControl{" + conflictControl + "}{" + conflictName + "}"
    Else
			msg = "$YK_ConflictControl{" + conflictControl + "}"
		EndIf
		If(!ShowMessage(msg, true, "$Yes", "$No"))
      return
    EndIf
	EndIf
  If(s[0] == "surrenderkey")
    iSurrenderKey = newKeyCode
    SetKeyMapOptionValueST(iSurrenderKey)
  ElseIf(s[0] == "assaultkey")
    iAssaultKey = newKeyCode
    SetKeyMapOptionValueST(iAssaultKey)
  EndIf
  Main.RegisterKeys()
EndEvent

Event OnInputOpenST()
	String[] s = StringUtil.Split(GetState(), "_")
	If(s[0] == "sltags")
		int i = s[1] as int
		SetInputDialogStartText(SLTags[i])
	EndIf
EndEvent

Event OnInputAcceptST(string a_input)
	String[] s = StringUtil.Split(GetState(), "_")
	If(s[0] == "sltags")
		int i = s[1] as int
		SLTags[i] = a_input
		SetInputOptionValueST(SLTags[i])
	EndIf
EndEvent

Event OnHighlightST()
  String[] s = StringUtil.Split(GetState(), "_")
  ; --------------- Hotkeys
  If(s[0] == "surrendermodkey"  || s[0] == "assaultmodkey")
    SetInfoText("$YK_ModifierKeyHighlight")
  ElseIf(s[0] == "surrenderkey")
    SetInfoText("$YK_SurrenderKeyHighlight")
  ElseIf(s[0] == "assaultkey")
    SetInfoText("$YK_AssaultKeyHighlight")
  ; --------------- Hunter Pride
  ElseIf(s[0] == "hunterassault")
    SetInfoText("$YK_HunterAssaultToggleHighlight")
  ElseIf(s[0] == "hunterstrip")
    SetInfoText("$YK_HunterStripToggleHighlight")
  ; --------------- Events
  ElseIf(s[0] == "postcmbtkeeparmor")
    SetInfoText("$YK_StealArmorHighlight")
  ElseIf(s[0] == "postcmbtmaxassaults")
    SetInfoText("$YK_MaxAssaultsHighlight")
  ElseIf(s[0] == "postcmbtrapiststays")
    SetInfoText("$YK_RapistQuitsHighlight")

  ; --------------- NSFW
  ElseIf(s[0] == "sexlabweight")
    SetInfoText("$YK_SexLabWeightHighlight")
  ElseIf(s[0] == "scenetype")
    SetInfoText("$YK_SceneTypeHighlight")
  EndIf
EndEvent

; --------------------- Save/Load

String Property FilePath = "YKudasai_Settings.json" AutoReadOnly Hidden

Function Save()
  JsonUtil.SetIntValue(FilePath, "bStealArmor", bStealArmor as int)
  JsonUtil.SetIntValue(FilePath, "iMaxAssaults", iMaxAssaults)
  JsonUtil.SetFloatValue(FilePath, "fRapistQuits", fRapistQuits)
  JsonUtil.SetIntValue(FilePath, "bHunterAssault", bHunterAssault as int)
  JsonUtil.SetIntValue(FilePath, "bHunterStrip", bHunterStrip as int)
  JsonUtil.SetIntValue(FilePath, "iSurrenderKey", iSurrenderKey)
  JsonUtil.SetIntValue(FilePath, "iSurrenderKeyM", iSurrenderKeyM)
  JsonUtil.SetIntValue(FilePath, "iAssaultKey", iAssaultKey)
  JsonUtil.SetIntValue(FilePath, "iAssaultKeyM", iAssaultKeyM)
  JsonUtil.SetIntValue(FilePath, "bAllowFF", bAllowFF as int)
  JsonUtil.SetIntValue(FilePath, "bAllowMM", bAllowMM as int)
  JsonUtil.SetIntValue(FilePath, "bAllowMC", bAllowMC as int)
  JsonUtil.SetIntValue(FilePath, "bAllowFC", bAllowFC as int)
  JsonUtil.IntListCopy(FilePath, "iSceneTypeWeight", iSceneTypeWeight)
  If(iFrameSL > -1)
    JsonUtil.SetIntValue(FilePath, "iFrameSL", iFrameSL)
  EndIf
  If(SLTags.Length != 6)
    SLTagsDefault()
  EndIf
  JsonUtil.StringListCopy(FilePath, "SLTags", SLTags)
  If(sRaceKeys.Length)
    JsonUtil.StringListCopy(FilePath, "sRaceKeys", sRaceKeys)
  EndIf
EndFunction

bool Function Load()
  If(!JsonUtil.JsonExists(FilePath))
    return false
  ElseIf(!JsonUtil.Load(FIlePath) || !JsonUtil.IsGood(FilePath))
    Debug.Trace("Failed to load Json file: " + JsonUtil.GetErrors(FilePath))
    return false
  EndIf
  bStealArmor = JsonUtil.GetIntValue(FilePath, "bStealArmor", bStealArmor as int)
  iMaxAssaults = JsonUtil.GetIntValue(FilePath, "iMaxAssaults", iMaxAssaults)
  fRapistQuits = JsonUtil.GetFloatValue(FilePath, "fRapistQuits", fRapistQuits)
  bHunterAssault = JsonUtil.GetIntValue(FilePath, "bHunterAssault", bHunterAssault as int)
  If(bHunterAssault != Acheron.HasOption(KudasaiMain.HunterAssaultID()))
    If(bHunterAssault)
      Main.AddHunterAssaultOption()
    Else
      Acheron.RemoveOption(KudasaiMain.HunterAssaultID())
    EndIf
  EndIf
  bHunterStrip = JsonUtil.GetIntValue(FilePath, "bHunterStrip", bHunterStrip as int)
  If(bHunterStrip != Acheron.HasOption(KudasaiMain.HunterStripID()))
    If(bHunterStrip)
      Main.AddHunterStripOption()
    Else
      Acheron.RemoveOption(KudasaiMain.HunterStripID())
    EndIf
  EndIf
  iSurrenderKey = JsonUtil.GetIntValue(FilePath, "iSurrenderKey", iSurrenderKey)
  iSurrenderKeyM = JsonUtil.GetIntValue(FilePath, "iSurrenderKeyM", iSurrenderKeyM)
  iAssaultKey = JsonUtil.GetIntValue(FilePath, "iAssaultKey", iAssaultKey)
  iAssaultKeyM = JsonUtil.GetIntValue(FilePath, "iAssaultKeyM", iAssaultKeyM)
  bAllowFF = JsonUtil.GetIntValue(FilePath, "bAllowFF", bAllowFF as int)
  bAllowMM = JsonUtil.GetIntValue(FilePath, "bAllowMM", bAllowMM as int)
  bAllowMC = JsonUtil.GetIntValue(FilePath, "bAllowMC", bAllowMC as int)
  bAllowFC = JsonUtil.GetIntValue(FilePath, "bAllowFC", bAllowFC as int)
  If(JsonUtil.StringListCount(FilePath, "iSceneTypeWeight") == 4)
    iSceneTypeWeight = JsonUtil.IntListToArray(FilePath, "iSceneTypeWeight")
  ElseIf(!iSceneTypeWeight.Length != 4)
    iSceneTypeWeightDefault()
  EndIf
  If(JsonUtil.HasIntValue(FilePath, "iFrameSL"))
    iFrameSL = JsonUtil.GetIntValue(FilePath, "iFrameSL", iFrameSL)
  EndIf
  If(JsonUtil.StringListCount(FilePath, "SLTags") == 6)
    SLTags = JsonUtil.StringListToArray(FilePath, "SLTags")
  ElseIf(SLTags.Length != 6)
    SLTagsDefault()
  EndIf
  If(JsonUtil.StringListCount(FilePath, "sRaceKeys"))
    sRaceKeys = JsonUtil.StringListToArray(FilePath, "sRaceKeys")
  EndIf
  return true
EndFunction

; --------------------- Misc

String Function GetCustomControl(int keyCode)
	If(keyCode == iSurrenderKey)
		return "Surrender"
  ElseIf(keyCode == iAssaultKey)
    return "Assault"
  Else
		return ""
	EndIf
EndFunction

int Function getFlag(bool option)
	If(option)
		return OPTION_FLAG_NONE
	else
		return OPTION_FLAG_DISABLED
	EndIf
endFunction
