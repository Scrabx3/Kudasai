Scriptname KudasaiMain extends Quest  

KudasaiMCM Property MCM Auto

Perk Property InteractionPerk Auto

Quest Property SurrenderQuest Auto
Message Property SurrenderQFailure Auto

Function Maintenance()
  Game.GetPlayer().AddPerk(InteractionPerk)
  RegisterKeys()

  If(Game.GetModByName("SexLab.esm") == 255)
    MCM.iSLWeight = 0
  EndIf
  If(Game.GetModByName("OStim.esp") == 255)
    MCM.iOStimWeight = 0
  EndIf
  If(!MCM.FrameAny)
    MCM.bPostCombatAssault = false
  EndIf
EndFunction

Function RegisterKeys()
  UnregisterForAllKeys()
  RegisterForKey(MCM.iSurrenderKey)
  RegisterForKey(MCM.iHunterPrideKey)
  RegisterForKey(MCM.iAssaultKey)
EndFunction

Event OnKeyDown(int keyCode)
  If(Utility.IsInMenuMode() || !Game.IsLookingControlsEnabled() || !Game.IsMovementControlsEnabled() || UI.IsMenuOpen("Dialogue Menu"))
		return
	EndIf
  If(keyCode == MCM.iSurrenderKey)
    If (!SurrenderQuest.Start())
      SurrenderQFailure.Show()
    EndIf
  ElseIf(keyCode == MCM.iHunterPrideKey)
    Debug.Notification("-- TODO: --")
  ElseIf(keyCode == MCM.iAssaultKey)
    Debug.Notification("-- TODO: --")
  EndIf
EndEvent
