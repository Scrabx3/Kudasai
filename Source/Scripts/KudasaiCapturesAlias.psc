Scriptname KudasaiCapturesAlias extends ReferenceAlias  

KudasaiCaptures Property Captures
  KudasaiCaptures Function Get()
    return GetOwningQuest() as KudasaiCaptures
  EndFunction
EndProperty

Event OnDeath(Actor akKiller)
  Clear()
EndEvent


