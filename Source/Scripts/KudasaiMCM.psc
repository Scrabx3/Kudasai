Scriptname KudasaiMCM extends SKI_ConfigBase

; ----------- General

int Property iSurrenderKey = -1 Auto Hidden ; Surrender
int Property iSurrenderKeyM = -1 Auto Hidden
int Property iAssaultKey = -1 Auto Hidden ; Player initiated Struggle Game
int Property iAssaultKeyM = -1 Auto Hidden

; ----------- Defeat

bool Property bStealArmor = true Auto Hidden

int Property iMaxAssaults = 4 Auto Hidden
float Property fRapistQuits = 35.0 Auto Hidden

; ----------- NSFW

bool Property FrameCreature Hidden
  bool Function Get()
    return iFrameSL > 0 && KudasaiAnimationSL.AllowCreatures()
  EndFunction
EndProperty

bool Property bAllowCreatures = false Auto Hidden
bool Property bAllowFF = true Auto Hidden
bool Property bAllowMM = true Auto Hidden
bool Property bAllowMC = false Auto Hidden
bool Property bAllowFC = false Auto Hidden

int Property iFrameSL = 100 Auto Hidden

int[] Property iSceneTypeWeight Auto Hidden

String[] Property SLTags Auto Hidden
{F<-M // M<-M // M<-F // F<-F // M<-* // F<-*}

; ----------- Race

String[] sRaceKeys
bool Function AllowedRaceType(String asRaceKey)
  If(asRaceKey == "Human")
    return true
  ElseIf(iFrameSL <= 0 || !bAllowCreatures)
    return false
  EndIf
  return sRaceKeys.Find(asRaceKey) > -1
EndFunction

; --------------------- Menu

int Function GetVersion()
	return 1
endFunction

Event OnConfigInit()
  Pages = new String[6]
  Pages[0] = "$YK_General"
  Pages[1] = "$YK_Defeat"
  Pages[2] = "$YK_NSFW"
  Pages[2] = "$YK_Race"

  SLTags = new String[6]
  SLTags[2] = "femdom"

  iSceneTypeWeight = new int[4]
  iSceneTypeWeight[0] = 75 
  iSceneTypeWeight[1] = 60
  iSceneTypeWeight[2] = 35
  iSceneTypeWeight[3] = 20
EndEvent

Event OnConfigClose()
EndEvent

Event OnPageReset(string page)
  SetCursorFillMode(TOP_TO_BOTTOM)
  If (page == "")
    page = "$YK_General"
  EndIf
  If (page == "$YK_General")
    SetCursorPosition(1)
    AddHeaderOption("$YK_SurrenderKey")
    AddKeyMapOptionST("surrenderkey", "$YK_Hotkey", iSurrenderKey)
    AddKeyMapOptionST("surrendermodkey", "$YK_ModifierKey", iSurrenderKeyM)
    AddHeaderOption("$YK_AssaultKey")
    AddKeyMapOptionST("assaultkey", "$YK_Hotkey", iAssaultKey)
    AddKeyMapOptionST("assaultmodkey", "$YK_ModifierKey", iAssaultKeyM)

  ElseIf (page == "$YK_Defeat")
    AddToggleOptionST("postcmbtkeeparmor", "$YK_StealArmor", bStealArmor)
    AddSliderOptionST("postcmbtmaxassaults", "$YK_MaxAssaults", iMaxAssaults, "{0}")
    AddSliderOptionST("postcmbtrapiststays", "$YK_RapistQuits", fRapistQuits, "{1}%")

  ElseIf (page == "$YK_NSFW")
    AddHeaderOption("$YK_AdultFrames")
    AddSliderOptionST("sexlabweight", "$YK_SexLabWeight", iFrameSL, "{0}", getFlag(iFrameSL == -1))
    AddEmptyOption()
    AddHeaderOption("$YK_SceneTypes")
    int n = 0
    While(n < iSceneTypeWeight.Length)
      AddSliderOptionST("scenetype_" + n, "$YK_SceneType_" + n, iSceneTypeWeight[n], "{0}")
      n += 1
    EndWhile

    SetCursorPosition(1)
    AddHeaderOption("$YK_SexLab")
    AddTextOptionST("sltagsreadme", "", "$YK_AboutTags", getFlag(iFrameSL == -1))
    int i = 0
    While(i < SLTags.Length)
      AddInputOptionST("sltags_" + i, "$YK_SLTags_" + i, SLTags[i], getFlag(iFrameSL == -1))
      i += 1
    EndWhile

  ElseIf(page == "$YK_Race")
    If(iFrameSL <= 0 || !bAllowCreatures)
      AddTextOption("$YK_RaceDisallowed", "", OPTION_FLAG_DISABLED)
      return
    EndIf
    SetCursorFillMode(LEFT_TO_RIGHT)
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

  ; --------------- NSFW
  ElseIf(s[0] == "sltagsreadme")
    ShowMessage("$YK_AboutTagsMsg", false, "$YK_Ok")

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
	ElseIf(s[0] == "sexlabweight")
		SetSliderDialogStartValue(iFrameSL)
		SetSliderDialogDefaultValue(100)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
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
  ; --------------- Defeat
	If(s[0] == "postcmbtmaxassaults")
		iMaxAssaults = value as int
		SetSliderOptionValueST(iMaxAssaults, "{0}")
	ElseIf(s[0] == "postcmbtrapiststays")
		fRapistQuits = value
		SetSliderOptionValueST(fRapistQuits, "{1}%")

  ; --------------- NSFW
	ElseIf(s[0] == "sexlabweight")
		iFrameSL = value as int
		SetSliderOptionValueST(iFrameSL, "{0}")
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
  ((Self as Quest) as KudasaiMain).RegisterKeys()
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
  ; --------------- General
  If(s[0] == "surrendermodkey"  || s[0] == "assaultmodkey")
    SetInfoText("$YK_ModifierKeyHighlight")
  ElseIf(s[0] == "surrenderkey")
    SetInfoText("$YK_SurrenderKeyHighlight")
  ElseIf(s[0] == "assaultkey")
    SetInfoText("$YK_AssaultKeyHighlight")

  ; --------------- Defeat
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
