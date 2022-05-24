Scriptname KudasaiRPlayerNAlias extends ReferenceAlias  

bool Property MarkForClear Auto Hidden

Event OnDeath(Actor akKiller)
  Debug.Trace("[Kudasai] OnDeath -> " + GetName())
  GetOwningQuest().Stop()
EndEvent

Event OnUnload()
  Debug.Trace("[Kudasai] OnUnload -> " + GetName())
  GetOwningQuest().Stop()
EndEvent

Event OnCombatStateChanged(Actor akTarget, int aeCombatState)
  Quest q = GetOwningQuest()
  If(q.GetStage() < 5)
    return
  EndIf
  Debug.Trace("[Kudasai] OnCombatState Change -> " + GetName() + "; State = " + aeCombatState + "; Target = " + akTarget)
  If(aeCombatState == 1 && !Kudasai.IsDefeated(akTarget))
    q.Stop()
  EndIf
EndEvent
