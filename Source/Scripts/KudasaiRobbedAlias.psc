Scriptname KudasaiRobbedAlias extends ReferenceAlias  

Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
  If(akDestContainer == Game.GetPlayer())
    GetOwningQuest().SetStage(25)
  EndIf
EndEvent
