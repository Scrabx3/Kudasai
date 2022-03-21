Scriptname KudasaiPlayer extends ReferenceAlias

KudasaiMain Property Main
  KudasaiMain Function Get()
    return GetOwningQuest() as KudasaiMain
  EndFunction
EndProperty

Event OnInit()
  OnPlayerLoadGame()
EndEvent

Event OnPlayerLoadGame()
  Main.Maintenance()
EndEvent