Scriptname KudasaiResolutionNPCAlias extends ReferenceAlias  

KudasaiResolutionNPC Property Res
  KudasaiResolutionNPC Function Get()
    return GetOwningQuest() as KudasaiResolutionNPC
  EndFunction
EndProperty

Event OnInit()
  Actor me = GetActorReference()
  If(me)
    me.EvaluatePackage()
  EndIf
EndEvent

Event OnUpdate()
  Actor me = GetReference() as Actor
  If (Kudasai.IsDefeated(me))
    Kudasai.RescueActor(me, true)
  EndIf
EndEvent

; =====================

Function StopQ()
  Quest q = GetOwningQuest()
  Utility.Wait(1)
  While(!q.GetStageDone(10))
    Utility.Wait(0.5)
  EndWhile
  Actor me = GetReference() as Actor
  If(me && (me.IsDead() || me.IsInCombat()))
    q.SetStage(50)
  EndIf
EndFunction

Event OnCombatStateChanged(Actor akTarget, int aeCombatState)
  If(aeCombatState == 1)
    StopQ()
  EndIf
EndEvent

Event OnDeath(Actor akKiller)
  If(akKiller != none)
    StopQ()
  EndIf
EndEvent

; =====================

Event OnUnload()
  GetOwningQuest().SetStage(100)
EndEvent