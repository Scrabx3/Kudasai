Scriptname KudasaiPlayer extends ReferenceAlias

KudasaiMain Property Main
  KudasaiMain Function Get()
    return GetOwningQuest() as KudasaiMain
  EndFunction
EndProperty

Event OnPlayerLoadGame()
  Debug.Trace("[Kudasai] Player Load Game")
  Main.Maintenance()
EndEvent