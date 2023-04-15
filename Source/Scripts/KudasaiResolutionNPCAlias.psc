Scriptname KudasaiResolutionNPCAlias extends ReferenceAlias  

KudasaiResolutionNPC Property Res
  KudasaiResolutionNPC Function Get()
    return GetOwningQuest() as KudasaiResolutionNPC
  EndFunction
EndProperty

Event OnUpdate()
  Actor me = GetReference() as Actor
  If (Acheron.IsDefeated(me))
    Acheron.RescueActor(me, true)
  EndIf
EndEvent

Function Clear()
  Acheron.SetLinkedRef(GetReference(), none, Res.LinkKW)
  Parent.Clear()
EndFunction

; =====================

Function StopQ()
  Quest q = GetOwningQuest()
  While(!q.GetStageDone(10))
    Utility.Wait(0.5)
  EndWhile
  Actor me = GetReference() as Actor
  If(!me) ; || Acheron.IsDefeated(me))
    return
  ElseIf(me.IsDead() || me.IsInCombat())
    Debug.Trace("[Kudasai] <NPC Resolution> StopQ() on " + self + " | " + me)
    q.SetStage(100)
  EndIf
EndFunction

Event OnCombatStateChanged(Actor akTarget, int aeCombatState)
  If(aeCombatState == 1 && !Acheron.IsDefeated(akTarget))
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
  Debug.Trace("[Kudasai] <NPC Resolution> OnUnload() on " + self + " | " + GetReference())
  GetOwningQuest().SetStage(100)
EndEvent