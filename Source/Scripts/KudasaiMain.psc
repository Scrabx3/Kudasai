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
    ; MCM.bMidCombatAssault = false
    MCM.bPostCombatAssault = false
  EndIf

  RegisterForModEvent("HookAnimationStart_Kudasai_NativeAssault", "NativeAssaultSLStart")
  RegisterForModEvent("HookAnimationEnd_Kudasai_NativeAssault", "NativeAssaultSLEnd")
  RegisterForModEvent("ostim_end", "NativeAssaultEndOStim")
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


; ===================================== 

Event NativeAssaultSLStart(int tid, bool hasPlayer)
  Debug.Trace("[Kudasai] SL -> Native Assault Start")
  ; Native assault calls create dammage immunity to avoid the Actors beign killed pre Scene Start
  ; This primarily to avoid a "bug" with SL taking too long to start a Scene, causing dead actors to be animated
  Actor[] positions = KudasaiAnimationSL.GetPositions(tid)
  int i = 0
  While(i < positions.Length)
    KudasaiInternal.SetDamageImmune(positions[i], false)
    i += 1
  EndWhile
EndEvent

Event NativeAssaultSLEnd(int tid, bool hasPlayer)
  Debug.Trace("[Kudasai] SL -> Native Assault End")
  Actor[] positions = KudasaiAnimationSL.GetPositions(tid)
  Actor victim = KudasaiAnimationSL.GetVictim(tid)
  Kudasai.DefeatActor(victim)
  int i = 0
  While(i < positions.Length)
    If(positions[i] != victim)
      Kudasai.UndoPacify(positions[i])
    EndIf
    i += 1
  EndWhile
EndEvent

Event NativeAssaultEndOStim(string asEventName, string asStringArg, float afNumArg, form akSender)
  Actor[] positions = KudasaiAnimationOStim.GetPositions(afNumArg as int)
  int where = -1
  int n = 0
  While(n < positions.Length && where == -1)
    where = StorageUtil.FormListFind(MCM, "ostimNATIVE", positions[n])
  EndWhile
  Actor victim = StorageUtil.FormListPluck(MCM, "ostimNATIVE", where, none) as Actor
  If (victim == none)
    return
  EndIf
  Debug.Trace("[Kudasai] OStim -> Native Assault End")
  int i = 0
  While(i < positions.Length)
    If(positions[i] == victim)
      Kudasai.DefeatActor(positions[i])
    Else
      Kudasai.UndoPacify(positions[i])
    EndIf
    i += 1
  EndWhile
EndEvent
