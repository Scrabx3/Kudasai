Scriptname KudasaiResolutionNPCAlias extends ReferenceAlias  

KudasaiResolutionNPC Property Res
  KudasaiResolutionNPC Function Get()
    return GetOwningQuest() as KudasaiResolutionNPC
  EndFunction
EndProperty

Event OnUpdate()
  Actor me = GetReference() as Actor
  If (Kudasai.IsDefeated(me))
    Kudasai.RescueActor(me, true)
  EndIf
EndEvent

Function Clear()
  Kudasai.SetLinkedRef(GetReference(), none, Res.LinkKW)
  Parent.Clear()
EndFunction

; =====================

Function StopQ()
  Quest q = GetOwningQuest()
  While(!q.GetStageDone(10))
    Utility.Wait(0.5)
  EndWhile
  Actor me = GetReference() as Actor
  If(!me) ; || Kudasai.IsDefeated(me))
    return
  ElseIf(me.IsDead() || me.IsInCombat())
    Debug.Trace("[Kudasai] <NPC Resolution> StopQ() on " + self + " | " + me)
    q.SetStage(100)
  EndIf
EndFunction

Event OnCombatStateChanged(Actor akTarget, int aeCombatState)
  If(aeCombatState == 1 && !Kudasai.IsDefeated(akTarget))
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