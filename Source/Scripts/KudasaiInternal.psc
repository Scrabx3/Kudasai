Scriptname KudasaiInternal Hidden

; Update the Weights in MCM Script
Function UpdateWeights() native global

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
  int n = 0
  While(limit < this)
    limit += weights[n]
    n += 1
  EndWhile
  return n
EndFunction

; Called by the .dll, never called for subject == Player
Function FinalizeDefeat(Actor subject) global
  Package p = Game.GetFormFromFile(0x7802E8, "YKudasai.esp") as Package
  ActorUtil.AddPackageOverride(subject, p, 100)
  subject.EvaluatePackage()
EndFunction

Function FinalizeRescue(Actor subject) global
  Package p = Game.GetFormFromFile(0x7802E8, "YKudasai.esp") as Package
  ActorUtil.RemovePackageOverride(subject, p)
  subject.EvaluatePackage()
EndFunction

; Called by the .dll
Function FinalizeAnimationStart(Actor subject) global
  ; Cleanup Actor State
  If(subject.IsSneaking())
    subject.StartSneaking()
  EndIf
  ; Apply Package
  If(subject != Game.GetPlayer())
    Package p = Game.GetFormFromFile(0x88782C, "YKudasai.esp") as Package
    ActorUtil.AddPackageOverride(subject, p)
    subject.EvaluatePackage()
  EndIf
EndFunction

Function FinalizeAnimationEnd(Actor subject) global
  If(subject != Game.GetPlayer())
    Package p = Game.GetFormFromFile(0x88782C, "YKudasai.esp") as Package
    ActorUtil.RemovePackageOverride(subject, p)
    subject.EvaluatePackage()
  EndIf
EndFunction