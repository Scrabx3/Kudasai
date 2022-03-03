Scriptname KudasaiMain extends Quest  

Quest Property SurrenderQuest Auto
Message Property SurrenderQFailure Auto

Event OnInit()
  RegisterForModEvent("KCreatureAssaultSuccess_YKNativeAssault", "NativeAssaultSuccess")
  RegisterForModEvent("KCreatureAssaultFailure_YKNativeAssault", "NativeAssaultFailure")

  RegisterForModEvent("HookAnimationEnd_YKNativeAssault", "NativeAssaultEndSL")
  RegisterForModEvent("ostim_end", "NativeAssaultEndOStim")

  RegisterForKey(37)
EndEvent

Event OnKeyDown(int keyCode)
  If (!SurrenderQuest.Start())
    SurrenderQFailure.Show()
  EndIf
EndEvent

Actor[] nativescene
Event NativeAssaultSuccess(Actor a1, Actor a2, Actor a3, Actor a4, Actor a5)
  Debug.Trace("Native Scene call success")
  nativescene = new Actor[5]
  nativescene[1] = a1
  nativescene[2] = a2
  nativescene[3] = a3
  nativescene[4] = a4
  nativescene[5] = a5
EndEvent

Event NativeAssaultFailure(Actor a1, Actor a2, Actor a3, Actor a4, Actor a5)
  Debug.Trace("Native Scene call failed")
  Kudasai.RestoreActor(a1, false)
  If (a2)
  Kudasai.RestoreActor(a2, false)
  EndIf
  If (a3)
  Kudasai.RestoreActor(a3, false)
  EndIf
  If (a4)
  Kudasai.RestoreActor(a4, false)
  EndIf
  If (a5)
  Kudasai.RestoreActor(a5, false)
  EndIf
EndEvent
