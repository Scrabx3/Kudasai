Scriptname KudasaiMain extends Quest  

KudasaiMCM Property MCM Auto

Quest Property SurrenderQuest Auto
Message Property SurrenderQFailure Auto

Function Maintenance()
  RegisterKeys()
  ; Native Assault Calls
  RegisterForModEvent("HookAnimationStart_YKNativeAssault", "NativeAssaultSLStart")
  RegisterForModEvent("HookAnimationEnd_YKNativeAssault", "NativeAssaultSLEnd")
  RegisterForModEvent("ostim_end", "NativeAssaultEndOStim")
EndFunction

Function RegisterKeys()
  UnregisterForAllKeys()
  RegisterForKey(MCM.iSurrenderKey)
  RegisterForKey(MCM.iHunterPrideKey)
  RegisterForKey(MCM.iAssaultKey)
EndFunction

Event OnKeyDown(int keyCode)
  If (!SurrenderQuest.Start())
    SurrenderQFailure.Show()
  EndIf
EndEvent


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
  ; For now, the end of an assault simply resets this Actor
  Actor[] positions = KudasaiAnimationSL.GetPositions(tid)
  Actor victim = KudasaiAnimationSL.GetVictimInScene(tid)
  Kudasai.DefeatActor(victim)
  int i = 0
  While(i < positions.Length)
    If (positions[i] != victim)
      Kudasai.UndoPacify(positions[i])
    EndIf
    i += 1
  EndWhile
EndEvent

Event NativeAssaultEndOStim(string asEventName, string asStringArg, float afNumArg, form akSender)
  Actor[] positions = KudasaiAnimationOStim.GetPositions(afNumArg as int)
  Actor victim = StorageUtil.GetFormValue(MCM, "ostimNATIVE") as Actor
  If (!victim || positions.find(victim) == -1)
    return
  EndIf
  Debug.Trace("[Kudasai] OStim -> Native Assault End")
  StorageUtil.SetFormValue(MCM, "ostimNATIVE", none)
  Kudasai.DefeatActor(victim)
  int i = 0
  While(i < positions.Length)
    If (positions[i] != victim)
      Kudasai.UndoPacify(positions[i])
    EndIf
    i += 1
  EndWhile
EndEvent
