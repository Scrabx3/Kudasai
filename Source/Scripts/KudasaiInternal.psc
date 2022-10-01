Scriptname KudasaiInternal Hidden

Function UpdateSettings() native global
bool Function IsAlternateVersion() native global

KudasaiMCM Function GetMCM() global
  return Game.GetFormFromFile(0x7853F1, "YameteKudasai.esp") as KudasaiMCM
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

bool Function IsRadiant(Actor subject) global
  int formID = subject.GetFormID()
  return formID <= -16777216
EndFunction

Function RobActor(Actor victim, Actor robber, bool animation = true) global
  Debug.Trace("[Kudasai] Robbing Victim = " + victim + "; Robber = " + robber)
  If(animation)
    If(victim.GetDistance(robber) > 128)
      robber.MoveTo(victim, 60 * Math.cos(victim.Z), 60 * Math.sin(victim.Z), 0.0, false)
      robber.SetAngle(victim.GetAngleX(), victim.GetAngleY(), (victim.GetAngleZ() + victim.GetHeadingAngle(robber) - 180))
    EndIf
    Debug.SendAnimationEvent(robber, "KudasaiSearchBleedout")
    Utility.Wait(1.5)
  EndIf
  Kudasai.RemoveAllItems(victim, robber, !GetMCM().bStealArmor)
EndFunction

Armor[] Function GetWornArmor_Filtered(Actor subject) global
  Armor[] worn = Kudasai.GetWornArmor(subject)
  Keyword SexLabNoStrip = Keyword.GetKeyword("SexLabNoStrip")
  If(SexLabNoStrip)
    worn = Kudasai.RemoveArmorByKeyword(worn, SexLabNoStrip)
  EndIf
  Keyword ToysToy = Keyword.GetKeyword("ToysToy")
  If(ToysToy)
    worn = Kudasai.RemoveArmorByKeyword(worn, ToysToy)
  EndIf
  return worn
EndFunction

; Called by the .dll, never called for subject == Player
Function FinalizeDefeat(Actor subject) global
  Package p = Game.GetFormFromFile(0x88782C, "YameteKudasai.esp") as Package
  ActorUtil.AddPackageOverride(subject, p, 100)
  subject.EvaluatePackage()
EndFunction

Function FinalizeRescue(Actor subject) global
  Package p = Game.GetFormFromFile(0x88782C, "YameteKudasai.esp") as Package
  ActorUtil.RemovePackageOverride(subject, p)
  subject.EvaluatePackage()
EndFunction
