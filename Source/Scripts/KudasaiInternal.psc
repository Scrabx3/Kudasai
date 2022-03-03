Scriptname KudasaiInternal Hidden

KudasaiMCM Function GetMCM() global
  return Game.GetFormFromFile(0x7853F1, "YKudasai.esp") as KudasaiMCM
EndFunction

bool Function HasSchlong(Actor subject) global
  If (Game.GetModByName("Schlongs of Skyrim.esp") != 255)
    Faction SchlongFac = Game.GetFormFromFile(0x00AFF8, "Schlongs of Skyrim.esp") as Faction
		return subject.IsInFaction(SchlongFac)
  EndIf
  return false 
EndFunction

int Function GetFromWeight(int[] weights) global
  int all = 0
  int i = 0
  While(i < weights.length)
    all += weights[i]
    i += 1
  EndWhile
  int this = Utility.RandomInt(1, all)
  int limit = 0
  int res = 0
  While(limit < this)
    limit += weights[i]
    res += 1
  EndWhile
  return res
EndFunction

Function ForceBleedout(Actor subject) global
  If (!subject.IsBleedingOut())
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