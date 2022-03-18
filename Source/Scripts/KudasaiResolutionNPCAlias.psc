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

; =====================

Event OnCombatStateChanged(Actor akTarget, int aeCombatState)
  if (aeCombatState != 0)
    GetOwningQuest().SetStage(50)
  endif
EndEvent

Event OnDying(Actor akKiller)
  if (akKiller != none)
    GetOwningQuest().SetStage(50)
  endif
EndEvent

; =====================

Event OnUnload()
  GetOwningQuest().SetStage(100)
EndEvent