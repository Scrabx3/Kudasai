Scriptname KudasaiRPlayerNAlias extends ReferenceAlias  

bool Property MarkForClear Auto Hidden

Event OnDeath(Actor akKiller)
  If(GetOwningQuest().GetStage() > 300)
    return
  EndIf
  Debug.Trace("[Kudasai] <Assault> OnDeath -> " + GetName())
  GetOwningQuest().Stop()
EndEvent

Event OnUnload()
  If(GetOwningQuest().GetStage() > 300)
    return
  EndIf
  Debug.Trace("[Kudasai] <Assault> OnUnload -> " + GetName())
  GetOwningQuest().Stop()
EndEvent

Event OnCombatStateChanged(Actor akTarget, int aeCombatState)
  Quest q = GetOwningQuest()
  int stage = q.GetStage()
  If(stage < 5 || stage > 300)
    return
  EndIf
  Debug.Trace("[Kudasai] <Assault> OnCombatState Change -> " + GetName() + "; State = " + aeCombatState + "; Target = " + akTarget)
  If(aeCombatState == 1 && akTarget && !Kudasai.IsDefeated(akTarget))
    q.SetStage(450)
  EndIf
EndEvent
