Scriptname KudasaiRPlayerNAlias extends ReferenceAlias  

bool Property MarkForClear Auto Hidden

Event OnUpdate()
  Kudasai.RescueActor(GetActorReference(), true)
  If(MarkForClear)
    Clear()
  EndIf
EndEvent

Event OnDeath(Actor akKiller)
  GetOwningQuest().Stop()
EndEvent

Event OnUnload()
  GetOwningQuest().Stop()
EndEvent
