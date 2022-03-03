Scriptname Kudasai Hidden



Function ForceBleedout(Actor subject, bool animation) global
  subject.SetNoBleedoutRecovery(true)
  If (animation)
    Debug.SendAnimationEvent(subject, "bleedoutstart")
  EndIf
  If(subject != Game.GetPlayer())
    Package p = Game.GetFormFromFile(0x7802E8, "YKudasai.esp") as Package
    ActorUtil.AddPackageOverride(subject, p, 100)
    subject.EvaluatePackage()
  EndIf
EndFunction

Function ClearBleedout(Actor subject) global
  If (subject != Game.GetPlayer())
    Package p = Game.GetFormFromFile(0x7802E8, "YKudasai.esp") as Package
    ActorUtil.RemovePackageOverride(subject, p)
    subject.EvaluatePackage()
  EndIf
  Debug.SendAnimationEvent(subject, "bleedoutstop")
EndFunction