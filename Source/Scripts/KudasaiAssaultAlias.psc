Scriptname KudasaiAssaultAlias extends ReferenceAlias  

Function Clear()
  GetActorReference().EvaluatePackage()
  If(Acheron.IsPacified(GetActorReference()))
    Acheron.ReleaseActor(GetActorReference())
  EndIf
  Parent.Clear()
EndFunction
