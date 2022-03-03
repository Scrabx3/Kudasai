Scriptname KudasaiMain extends Quest  

Quest Property SurrenderQuest Auto
Message Property SurrenderQFailure Auto

Function Maintenance()
  ; Native Assault Calls
  RegisterForModEvent("HookAnimationStart_YKNativeAssault", "NativeAssaultSLStart")
  RegisterForModEvent("HookAnimationEnd_YKNativeAssault", "NativeAssaultSLEnd")
  ; RegisterForModEvent("ostim_end", "NativeAssaultEndOStim")

  RegisterForKey(37)
EndFunction

Event OnKeyDown(int keyCode)
  If (!SurrenderQuest.Start())
    SurrenderQFailure.Show()
  EndIf
EndEvent


Event NativeAssaultSLStart(int tid, bool hasPlayer)
  Debug.Trace("[Kudasai] SL -> Native Assault Start")
  ; Native assault calls create dammage immunity to avoid the Actors beign killed pre Scene Start
  Actor[] positions = KudasaiAnimationSL.GetActorsInScene(tid)
  int i = 0
  While(i < positions.Length)
    KudasaiInternal.SetDamageImmune(positions[i], false)
    i += 1
  EndWhile
EndEvent

Event NativeAssaultSLEnd(int tid, bool hasPlayer)
  Debug.Trace("[Kudasai] SL -> Native Assault End")
  ; For now, the end of an assault simply resets this Actor
  Actor[] positions = KudasaiAnimationSL.GetActorsInScene(tid)
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
