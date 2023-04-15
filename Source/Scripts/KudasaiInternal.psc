Scriptname KudasaiInternal Hidden

KudasaiMCM Function GetMCM() global
  return Game.GetFormFromFile(0x7853F1, "YameteKudasai.esp") as KudasaiMCM
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

bool Function IsRadiant(Form akForm) global
  return akForm.GetFormID() <= -16777216  ; 0xFF000000 as signed integer in decimal
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
  Acheron.RemoveAllItems(victim, robber, !GetMCM().bStealArmor)
EndFunction

ObjectReference[] Function GetReferences(ReferenceAlias[] akAliases) global
  ObjectReference[] ret = PapyrusUtil.ObjRefArray(akAliases.Length)
  int i = 0
  While(i < akAliases.Length)
    ret[i] = akAliases[i].GetReference()
    i += 1
  EndWhile
  return PapyrusUtil.RemoveObjRef(ret, none)
EndFunction

Actor[] Function GetActorReferences(ReferenceAlias[] akAliases) global
  Actor[] ret = PapyrusUtil.ActorArray(akAliases.Length)
  int i = 0
  While(i < akAliases.Length)
    ret[i] = akAliases[i].GetReference() as Actor
    i += 1
  EndWhile
  return PapyrusUtil.RemoveActor(ret, none)
EndFunction
