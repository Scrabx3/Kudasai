Scriptname KudasaiMCM extends SKI_ConfigBase

; --------------------- Properties

String red = "<font color = '#c70700'>"
String green = "<font color = '#32d12a'>"

; ----------- General

bool Property bEnabled = true Auto Hidden

int Property iHunterPrideKey = -1 Auto Hidden ; Allowing Player to defeat through Combat
int Property iSurrenderKey = -1 Auto Hidden ; Surrender
int Property iAssaultKey = -1 Auto Hidden ; Player initiated Struggle Game

bool Property bNotifyDefeat = false Auto Hidden
bool Property bNotifyDestroy = false Auto Hidden
bool Property bNotifyColored = false Auto Hidden
int iNotifyColorChoice = 0xFF0000
String Property sNotifyColorChoice = "#0xFF0000" Auto Hidden

; ----------- Combat

bool Property bMidCombatAssault = true Auto Hidden
bool Property bPostCombatAssault = true Auto Hidden

; ----------- Defeat

float Property fLethalPlayer = 100.0 Auto Hidden
float Property fLethalNPC = 100.0 Auto Hidden

; ----------- NSFW
bool Property FrameAny Hidden
  bool Function Get()
    return fSLWeight > 0.0 || fOStimWeight > 0.0
  EndFunction
EndProperty

bool Property FrameCreature Hidden
  bool Function Get()
    return fSLWeight > 0.0
  EndFunction
EndProperty

float Property fSLWeight = 100.0 Auto Hidden
float Property fOStimWeight = 0.0 Auto Hidden

float Property fArousalNPC = 0.0 Auto Hidden
float Property fArousalFollower = 0.0 Auto Hidden

String[] Property SLTags Auto Hidden
{F<-M // M<-M // M<-F // F<-F // M<-* // F<-*}

float Property fOStimDurMin = 30.0 Auto Hidden
float Property fOStimDurMax = 60.0 Auto Hidden

; --------------------- Stripping

int Property iStrips Auto Hidden

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
EndEvent

Event OnPageReset(string page)
  SetCursorFillMode(TOP_TO_BOTTOM)
  If (page == "")
    page = "$YK_General"
  EndIf
  If (page == "$YK_General")
    AddToggleOptionST("enabled", "$YK_Enabled", bEnabled)
    AddHeaderOption("$YK_Hotkeys")
    AddKeyMapOptionST("hunterpridekey", "$YK_HunterPrideKey", iHunterPrideKey)
    AddKeyMapOptionST("surrenderkey", "$YK_SurrenderKey", iSurrenderKey)
    AddKeyMapOptionST("assaultkey", "$YK_AssaultKey", iAssaultKey)
    AddEmptyOption()
    AddHeaderOption("$YM_Assault")
    AddToggleOptionST("midcmbtassault", "$YK_MidCmbtAssault", bMidCombatAssault, getFlag(FrameAny))
    AddToggleOptionST("postcmbtassault", "$YK_PostCmbtAssault", bPostCombatAssault, getFlag(FrameAny))

    SetCursorPosition(1)
    AddHeaderOption("$YK_Notification")
    AddToggleOptionST("notifydefeat", "$YK_NotifyDefeat", bNotifyDefeat)
    AddToggleOptionST("notifydestroy", "$YK_NotifyDestry", bNotifyDestroy) ; as in item destruction
		AddToggleOptionST("notifycolored", "$YK_NotifyColored", bNotifyColored, getFlag(bNotifyDefeat || bNotifyDestroy))
    AddColorOptionST("notifycolorchoice", "$YK_NotifyColorChoice", iNotifyColorChoice, getFlag((bNotifyDefeat || bNotifyDestroy) && bNotifyColored))

  ElseIf (page == "$YK_Defeat")
    AddHeaderOption("$YK_Lethal")
    AddTextOptionST("lethaldesc", "$YK_ReadMe", "")
    AddSliderOptionST("lethalplayer", "$YK_LethalPlayer", fLethalPlayer, "{1}%")
    AddSliderOptionST("lethalnpc", "$YK_LethalNPC", fLethalNPC, "{1}%")


  ElseIf (page == "$YK_NSFW")
		bool SLThere = Game.GetModByName("SexLab.esm") != 255
		bool OStimThere = Game.GetModByName("OStim.esp") != 255
    AddHeaderOption("$YK_AdultFrames")
    AddSliderOptionST("sexlabweight", "$YK_SexLabWeight", fSLWeight, "{1}", getFlag(SLThere))
    AddSliderOptionST("ostimweight", "$YK_OStimWeight", fOStimWeight, "{1}", getFlag(OStimThere))
    AddEmptyOption()
    AddHeaderOption("$YK_Arousal")
    AddSliderOptionST("arousalnpc", "$YK_ArousalNPC", fArousalNPC, "{1}", getFlag(SLThere || OStimThere))
    AddSliderOptionST("arousalfollower", "$YK_ArousalFollower", fArousalFollower, "{1}", getFlag(SLThere || OStimThere))

    SetCursorPosition(1)
    AddHeaderOption("$YK_SexLab")
    int i = 0
    While(i < SLTags.Length)
      AddInputOptionST("sltags_" + i, "$YK_SLTags_" + i, SLTags[i], getFlag(SLThere))
      i += 1
    EndWhile
    AddEmptyOption()
    AddHeaderOption("$YK_OStim")
    AddSliderOptionST("ostimdurmin", "$YK_OStimDurMin", fOStimDurMin, "{0}s", getFlag(OStimThere))
    AddSliderOptionST("ostimdurmax", "$YK_OStimDurMax", fOStimDurMax, "{0}s", getFlag(OStimThere))

  ElseIf (page == "$YK_Stripping")
    SetCursorFillMode(LEFT_TO_RIGHT)
    int i = 0
    While(i < 32)
      int bit = Math.LeftShift(1, i)
      AddToggleOptionST("strips_" + i, "$YK_Strips_" + i, Math.LogicalAnd(iStrips, bit))
      i += 1
    EndWhile

  ElseIf (page == "$YK_Debug")
    AddHeaderOption("$YK_System")
    AddTextOption("$YK_CrosshairNPC", GetCrosshairRefName())
    AddTextOptionST("rescue", "$YK_Rescue", "")
    AddTextOptionST("excludeSpell", "$YK_ExcludeSpell", "")
    AddTextOptionST("exclude", "$YK_Exclude", "")
    AddTextOptionST("include", "$YK_Include", "")

  EndIf
EndEvent

; --------------------- State Options

Event OnSelectST()
  String[] s = StringUtil.Split(GetState(), "_")
  If(s[0] == "enabled")
    bEnabled = !bEnabled
    SetToggleOptionValueST(bEnabled)
  EndIf
EndEvent

Event OnHighlightST()
  String[] s = StringUtil.Split(GetState(), "_")
  If(s[0] == "enabled")
  SetInfoText("$YK_EnabledInfo")
  EndIf
EndEvent

; --------------------- Misc

String Function GetCrosshairRefName()
  Actor ref = Game.GetCurrentCrosshairRef() as Actor
  If (ref)
    return ref.GetLeveledActorBase().GetName()
  Else
    return "---"
  EndIf
EndFunction

int Function getFlag(bool option)
	If(option)
		return OPTION_FLAG_NONE
	else
		return OPTION_FLAG_DISABLED
	EndIf
endFunction
