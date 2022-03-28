Scriptname KudasaiRPlayerNAlias extends ReferenceAlias  

bool Property MarkForClear Auto Hidden

Event OnUpdate()
  Kudasai.RescueActor(GetActorReference(), true)
  If(MarkForClear)
    Clear()
  EndIf
EndEvent
