Scriptname KudasaiRPlayerNAlias extends ReferenceAlias  

bool Property MarkForClear Auto Hidden

Event OnDeath(Actor akKiller)
  GetOwningQuest().Stop()
EndEvent

Event OnUnload()
  GetOwningQuest().Stop()
EndEvent
