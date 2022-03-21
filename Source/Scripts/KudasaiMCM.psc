Scriptname KudasaiMCM extends SKI_ConfigBase

; --------------------- Properties

String red = "<font color = '#c70700'>"
String green = "<font color = '#32d12a'>"

; ----------- General

bool Property bEnabled = true Auto Hidden

int Property iSurrenderKey = -1 Auto Hidden ; Surrender
int Property iHunterPrideKey = -1 Auto Hidden ; Allowing Player to defeat through Combat
int Property iAssaultKey = -1 Auto Hidden ; Player initiated Struggle Game

bool Property bNotifyDefeat = false Auto Hidden
bool Property bNotifyDestroy = false Auto Hidden ; TODO: implement this when doing the destruction stuff
bool Property bNotifyColored = false Auto Hidden
int iNotifyColorChoice = 0xFF0000
String Property sNotifyColorChoice = "#FF0000" Auto Hidden

; ----------- Combat

bool Property bMidCombatAssault = true Auto Hidden
bool Property bPostCombatAssault = true Auto Hidden

; ----------- Defeat
bool Property bLethalEssential = true Auto Hidden
float Property fLethalPlayer = 100.0 Auto Hidden
float Property fLethalNPC = 100.0 Auto Hidden

; ----------- NSFW

bool Property FrameAny Hidden
  bool Function Get()
    return iSLWeight > 0 || iOStimWeight > 0
  EndFunction
EndProperty

bool Property FrameCreature Hidden
  bool Function Get()
    return iSLWeight > 0
  EndFunction
EndProperty

int Property iSLWeight = 100 Auto Hidden
int Property iOStimWeight = 0 Auto Hidden

float Property fArousalNPC = 0.0 Auto Hidden
float Property fArousalFollower = 0.0 Auto Hidden

String[] Property SLTags Auto Hidden
{F<-M // M<-M // M<-F // F<-F // M<-* // F<-*}

float Property fOStimDurMin = 30.0 Auto Hidden
float Property fOStimDurMax = 60.0 Auto Hidden

; ----------- Stripping

int Property iStrips = 1066390941 Auto Hidden

; --------------------- Menu

int Function GetVersion()
	return 1
endFunction

Event OnConfigInit()
  Pages = new String[5]
  Pages[0] = "$YK_General"
  Pages[1] = "$YK_Defeat"
  Pages[2] = "$YK_NSFW"
  Pages[3] = "$YK_Stripping"
  Pages[4] = "$YK_Debug"

  SLTags = new String[6]
  SLTags[2] = "femdom"
EndEvent

Event OnPageReset(string page)
  SetCursorFillMode(TOP_TO_BOTTOM)
  If (page == "")
    page = "$YK_General"
  EndIf
  If (page == "$YK_General")
    AddToggleOptionST("enabled", "$YK_Enabled", bEnabled)
    AddHeaderOption("$YK_Hotkeys")
    AddKeyMapOptionST("surrenderkey", "$YK_SurrenderKey", iSurrenderKey)
    AddKeyMapOptionST("hunterpridekey", "$YK_HunterPrideKey", iHunterPrideKey)
    AddKeyMapOptionST("assaultkey", "$YK_AssaultKey", iAssaultKey)

    SetCursorPosition(1)
    AddHeaderOption("$YK_Notification")
    AddToggleOptionST("notifydefeat", "$YK_NotifyDefeat", bNotifyDefeat)
    AddToggleOptionST("notifydestroy", "$YK_NotifyDestry", bNotifyDestroy) ; as in item destruction
		AddToggleOptionST("notifycolored", "$YK_NotifyColored", bNotifyColored, getFlag(bNotifyDefeat || bNotifyDestroy))
    AddColorOptionST("notifycolorchoice", "$YK_NotifyColorChoice", iNotifyColorChoice, getFlag((bNotifyDefeat || bNotifyDestroy) && bNotifyColored))

  ElseIf (page == "$YK_Defeat")
    AddHeaderOption("$YM_Assault")
    AddToggleOptionST("midcmbtassault", "$YK_MidCmbtAssault", bMidCombatAssault, getFlag(FrameAny))
    AddToggleOptionST("postcmbtassault", "$YK_PostCmbtAssault", bPostCombatAssault, getFlag(FrameAny))

    SetCursorPosition(1)
    AddHeaderOption("$YK_Lethal")
    AddToggleoptionST("lethalessential", "$YK_LethalEssential", bLethalEssential)
    AddSliderOptionST("lethalplayer", "$YK_LethalPlayer", fLethalPlayer, "{1}%")
    AddSliderOptionST("lethalnpc", "$YK_LethalNPC", fLethalNPC, "{1}%")

  ElseIf (page == "$YK_NSFW")
		bool SLThere = Game.GetModByName("SexLab.esm") != 255
		bool OStimThere = Game.GetModByName("OStim.esp") != 255
    AddHeaderOption("$YK_AdultFrames")
    AddSliderOptionST("sexlabweight", "$YK_SexLabWeight", iSLWeight, "{0}", getFlag(SLThere))
    AddSliderOptionST("ostimweight", "$YK_OStimWeight", iOStimWeight, "{0}", getFlag(OStimThere))
    AddEmptyOption()
    AddHeaderOption("$YK_Arousal")
    AddSliderOptionST("arousalnpc", "$YK_ArousalNPC", fArousalNPC, "{1}", getFlag(SLThere || OStimThere))
    AddSliderOptionST("arousalfollower", "$YK_ArousalFollower", fArousalFollower, "{1}", getFlag(SLThere || OStimThere))

    SetCursorPosition(1)
    AddHeaderOption("$YK_SexLab")
    AddTextOptionST("sltagsreadme", "", "$YK_AboutTags", getFlag(SLThere))
    int i = 0
    While(i < SLTags.Length)
      AddInputOptionST("sltags_" + i, "$YK_SLTags_" + i, SLTags[i], getFlag(SLThere))
      i += 1
    EndWhile
    AddEmptyOption()
    AddHeaderOption("$YK_OStim")
    AddSliderOptionST("ostimdurmin", "$YK_OStimDurMin", fOStimDurMin, "{1}s", getFlag(OStimThere))
    AddSliderOptionST("ostimdurmax", "$YK_OStimDurMax", fOStimDurMax, "{1}s", getFlag(OStimThere))

  ElseIf (page == "$YK_Stripping")
    SetCursorFillMode(LEFT_TO_RIGHT)
    AddTextOptionST("stripsreadme", "$YK_ReadMe", "")
    AddTextOptionST("stripsdefaults", "$YK_RestoreDefaults", "")
    AddHeaderOption("$YK_Stripping")
    AddHeaderOption("")
    int i = 0
    While(i < 32)
      int flag = OPTION_FLAG_NONE
      If(i == 9 || i == 20 || i == 21 || i == 31)
        flag = OPTION_FLAG_DISABLED
      EndIf
      int bit = Math.LeftShift(1, i)
      AddToggleOptionST("strips_" + i, "$YK_Strips_" + i, Math.LogicalAnd(iStrips, bit), flag)
      i += 1
    EndWhile

  ElseIf (page == "$YK_Debug")
    AddHeaderOption("$YK_Defeat")
    bool pldefeated = Kudasai.IsDefeated(Game.GetPlayer())
    AddTextOptionST("rescuedebug_0", "$YK_Rescue_0", "", getFlag(pldefeated))
    AddTextOptionST("undopacify_0", "$YK_UndoPacify_0", "", getFlag(Kudasai.IsPacified(Game.GetPlayer()) && !pldefeated))
    AddTextOptionST("rescuedebug_1", "$YK_Rescue_1", "", getFlag(IsCrosshairRefDefeated()))
    AddTextOptionST("undopacify_1", "$YK_UndoPacify_1", "", getFlag(IsCrosshairRefPacified()))
  EndIf
EndEvent

; --------------------- State Options

Event OnSelectST()
  String[] s = StringUtil.Split(GetState(), "_")
  ; --------------- General
  If(s[0] == "notifydefeat")
    bNotifyDefeat = !bNotifyDefeat
    SetToggleOptionValueST(bNotifyDefeat, true)
    SetOptionFlagsST(getFlag(bNotifyDefeat || bNotifyDestroy), true, "notifycolored")
    SetOptionFlagsST(getFlag((bNotifyDefeat || bNotifyDestroy) && bNotifyColored), false, "notifycolorchoice")
  ElseIf(s[0] == "notifydestroy")
    bNotifyDestroy = !bNotifyDestroy
    SetToggleOptionValueST(bNotifyDestroy, true)
    SetOptionFlagsST(getFlag(bNotifyDefeat || bNotifyDestroy), true, "notifycolored")
    SetOptionFlagsST(getFlag((bNotifyDefeat || bNotifyDestroy) && bNotifyColored), false, "notifycolorchoice")
  ElseIf(s[0] == "notifycolored")
    bNotifyColored = !bNotifyColored
    SetToggleOptionValueST(bNotifyColored, true)
    SetOptionFlagsST(getFlag((bNotifyDefeat || bNotifyDestroy) && bNotifyColored), false, "notifycolorchoice")

  ; --------------- Defeat
  ElseIf(s[0] == "midcmbtassault")
    bMidCombatAssault = !bMidCombatAssault
    SetToggleOptionValueST(bMidCombatAssault)
  ElseIf(s[0] == "postcmbtassault")
    bPostCombatAssault = !bPostCombatAssault
    SetToggleOptionValueST(bPostCombatAssault)
  ElseIf(s[0] == "lethalessential")
    bLethalEssential = !bLethalEssential
    SetToggleOptionValueST(bLethalEssential)

  ; --------------- NSFW
  ElseIf(s[0] == "sltagsreadme")
    ShowMessage("$YK_AboutTagsMsg", false, "$YK_Ok")

  ; --------------- Stripping
  ElseIf(s[0] == "stripsreadme")
    ShowMessage("$YK_StripReadMe", false, "$YK_Ok")
  ElseIf(s[0] == "stripsdefaults")
    If(ShowMessage("$YK_StripsDefaultsMsg"))
      iStrips = 1066390941
      ForcePageReset()
    EndIf
  ElseIf(s[0] == "strips")
    int i = s[1] as int
    int bit = Math.LeftShift(1, i)
    iStrips = Math.LogicalXor(iStrips, bit)
    SetToggleOptionValueST(Math.LogicalAnd(iStrips, bit))

  ; --------------- Stripping
  ElseIf(s[0] == "rescuedebug")
    int i = s[1] as int
    Actor rescue
    If(i == 0)
      If(!ShowMessage("$YK_RescueBleedoutMsg"))
        return
      EndIf
      rescue = Game.GetPlayer()
    ElseIf(i == 1)
      Actor ref = Game.GetCurrentCrosshairRef() as Actor
      String name = ref.GetLeveledActorBase().GetName()
      If(!ShowMessage("$YK_RescueBleedoutMsg{" + name + "}"))
        return
      EndIf
      rescue = ref
    EndIf
    Kudasai.RescueActor(rescue, true)
  ElseIf(s[0] == "undopacify")
    int i = s[1] as int
    Actor rescue
    If(i == 0)
      If(!ShowMessage("$YK_UndoPacifyMsg"))
        return
      EndIf
      rescue = Game.GetPlayer()
    ElseIf(i == 1)
      Actor ref = Game.GetCurrentCrosshairRef() as Actor
      String name = ref.GetLeveledActorBase().GetName()
      If(!ShowMessage("$YK_UndoPacifyMsg{" + name + "}"))
        return
      EndIf
      rescue = ref
    EndIf
    Kudasai.UndoPacify(rescue)
  EndIf
EndEvent

Event OnSliderOpenST()
	String[] s = StringUtil.Split(GetState(), "_")
  ; --------------- Defeat
	If(s[0] == "lethalplayer")
		SetSliderDialogStartValue(fLethalPlayer)
		SetSliderDialogDefaultValue(100)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(0.5)
	ElseIf(s[0] == "lethalnpc")
		SetSliderDialogStartValue(fLethalNPC)
		SetSliderDialogDefaultValue(30)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(0.5)

  ; --------------- NSFW
	ElseIf(s[0] == "sexlabweight")
		SetSliderDialogStartValue(iSLWeight)
		SetSliderDialogDefaultValue(100)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	ElseIf(s[0] == "ostimweight")
		SetSliderDialogStartValue(iOStimWeight)
		SetSliderDialogDefaultValue(100)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	ElseIf(s[0] == "arousalnpc")
		SetSliderDialogStartValue(fArousalNPC)
		SetSliderDialogDefaultValue(30)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(0.5)
	ElseIf(s[0] == "arousalfollower")
		SetSliderDialogStartValue(fArousalFollower)
		SetSliderDialogDefaultValue(60)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(0.5)
	ElseIf(s[0] == "ostimdurmin")
		SetSliderDialogStartValue(fOStimDurMin)
		SetSliderDialogDefaultValue(20)
		SetSliderDialogRange(10, fOStimDurMax)
		SetSliderDialogInterval(0.5)
	ElseIf(s[0] == "ostimdurmax")
		SetSliderDialogStartValue(fOStimDurMax)
		SetSliderDialogDefaultValue(60)
		SetSliderDialogRange(fOStimDurMin, 600)
		SetSliderDialogInterval(0.5)
  EndIf
EndEvent

Event OnSliderAcceptST(float value)
	string[] s = StringUtil.Split(GetState(), "_")
  ; --------------- Defeat
	If(s[0] == "lethalplayer")
		fLethalPlayer = value
		SetSliderOptionValueST(fLethalPlayer, "{1}%")
	ElseIf(s[0] == "lethalnpc")
		fLethalNPC = value
		SetSliderOptionValueST(fLethalNPC, "{1}%")

  ; --------------- NSFW
	ElseIf(s[0] == "sexlabweight")
		iSLWeight = value as int
		SetSliderOptionValueST(iSLWeight, "{0}")
	ElseIf(s[0] == "ostimweight")
		iOStimWeight = value as int
		SetSliderOptionValueST(iOStimWeight, "{0}")
	ElseIf(s[0] == "arousalnpc")
		fArousalNPC = value
		SetSliderOptionValueST(fArousalNPC, "{1}")
	ElseIf(s[0] == "arousalfollower")
		fArousalFollower = value
		SetSliderOptionValueST(fArousalFollower, "{1}")
	ElseIf(s[0] == "ostimdurmin")
		fOStimDurMin = value
		SetSliderOptionValueST(fOStimDurMin, "{1}s")
	ElseIf(s[0] == "ostimdurmax")
		fOStimDurMax = value
		SetSliderOptionValueST(fOStimDurMax, "{1}s")
  EndIf
EndEvent

Event OnKeyMapChangeST(int newKeyCode, string conflictControl, string conflictName)
  String[] s = StringUtil.Split(GetState(), "_")
  If(newKeyCode == 1)
    newKeyCode = -1
  Else
    If(conflictControl != "")
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
  EndIf
  If(s[0] == "surrenderkey")
      iSurrenderKey = newKeyCode
      SetKeyMapOptionValueST(iSurrenderKey)
    ElseIf(s[0] == "hunterpridekey")
      iHunterPrideKey = newKeyCode
      SetKeyMapOptionValueST(iHunterPrideKey)
    ElseIf(s[0] == "assaultkey")
      iAssaultKey = newKeyCode
      SetKeyMapOptionValueST(iAssaultKey)
    EndIf
    ; TODO: main.updatekeys()
    return
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
  If(s[0] == "surrenderkey")
    SetInfoText("$YK_SurrenderKeyHighlight")
  ElseIf(s[0] == "hunterpridekey")
    SetInfoText("$YK_HunterPrideKeyHighlight")
  ElseIf(s[0] == "assaultkey")
    SetInfoText("$YK_AssaultKeyHighlight")
  ElseIf(s[0] == "notifydefeat")
    SetInfoText("$YK_NotifyDefeatHighlight")
  ElseIf(s[0] == "notifydestroy")
    SetInfoText("$YK_NotifyDestryHighlight")
  ElseIf(s[0] == "notifycolored")
    SetInfoText("$YK_NotifyColoredHighlight")
  ElseIf(s[0] == "notifycolorchoice")
    SetInfoText("$YK_NotifyColorChoiceHighlight")

  ; --------------- Defeat
  ElseIf(s[0] == "lethalessential")
    SetInfoText("$YK_LethalEssentialHighlight")
  ElseIf(s[0] == "lethalplayer")
    SetInfoText("$YK_LethalPlayerHighlight")
  ElseIf(s[0] == "lethalnpc")
    SetInfoText("$YK_LethalNPCHighlight")

  ; --------------- NSFW
  ElseIf(s[0] == "sexlabweight")
    SetInfoText("$YK_SexLabWeighthighlightHighlight")
  ElseIf(s[0] == "ostimweight")
    SetInfoText("$YK_OStimWeighhighlightHighlight")
  ElseIf(s[0] == "arousalnpc")
    SetInfoText("$YK_ArousalNPCHighlight")
  ElseIf(s[0] == "arousalfollower")
    SetInfoText("$YK_ArousalFollowerHighlight")
  ElseIf(s[0] == "ostimdurmin")
    SetInfoText("$YK_OStimDurMinHighlight")
  ElseIf(s[0] == "ostimdurmax")
    SetInfoText("$YK_OStimDurMaxHighlight")

  ; --------------- Stripping
  ElseIf(s[0] == "strips")
    int i = s[1] as int
    int bit = Math.LeftShift(1, i)
    Form worn = Game.GetPlayer().GetWornForm(bit)
    String name
    If(!worn)
      name = "---"
    Else
       name = worn.GetName()
      If(name == "" || name == " ")
        name = "---"
      EndIf
    EndIf
    SetInfoText("$YK_StripsHighlight{" + name + "}")
  EndIf
EndEvent

; --------------------- Default State
State notifycolorchoice
	Event OnColorOpenST()
		SetColorDialogStartColor(iNotifyColorChoice)
		SetColorDialogDefaultColor(0xFF0000)
	EndEvent
	Event OnColorAcceptST(int color)
		iNotifyColorChoice = color
		SetColorOptionValueST(iNotifyColorChoice)
    ; Convert the color code into a hex string for display in notifications
    String hex = ""
    While(color != 0)
      int c = color % 16
      If(c < 10)
        hex = c + hex
      Else
        hex = StringUtil.AsChar(55 + c) + hex
      EndIf
      color /= 16
    EndWhile
    While(StringUtil.GetLength(hex) < 6)
      hex = "0" + hex
    EndWhile
    sNotifyColorChoice = "#" + hex
	EndEvent
EndState

; --------------------- Misc

bool Function IsCrosshairRefDefeated()
  Actor ref = Game.GetCurrentCrosshairRef() as Actor
  If(!ref)
    return false
  Else
    return Kudasai.IsDefeated(ref)
  EndIf
EndFunction

bool Function IsCrosshairRefPacified()
  Actor ref = Game.GetCurrentCrosshairRef() as Actor
  If(!ref)
    return false
  Else
    return Kudasai.IsPacified(ref) && !Kudasai.IsDefeated(ref)
  EndIf
EndFunction

int Function getFlag(bool option)
	If(option)
		return OPTION_FLAG_NONE
	else
		return OPTION_FLAG_DISABLED
	EndIf
endFunction
