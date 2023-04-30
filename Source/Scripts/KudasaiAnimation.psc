Scriptname KudasaiAnimation Hidden
{Main Script for Scene Starting}

; Return -1 on failure
int Function CreateAssault(Actor[] akPositions, Actor akVictim, String asHook, String asTags = "UseConfig") global
  Debug.Trace("[Kudasai] CreateAssault with Actors " + akPositions + " / Victim = " + akVictim + " / Hook = " + asHook)
  akPositions = PapyrusUtil.RemoveActor(akPositions, none)
  KudasaiMCM MCM = KudasaiInternal.GetMCM()
  If(IncludesCreature(akPositions))
    If(!MCM.FrameCreature)
      return -1
    EndIf
    return KudasaiAnimationSL.CreateAnimation(MCM, akPositions, akVictim, asTags, asHook)
  EndIf
  If(MCM.iFrameSL > 0)
    return KudasaiAnimationSL.CreateAnimation(MCM, akPositions, akVictim, asTags, asHook)
  ElseIf(OStimThere())
    return KudasaiAnimationOStim.CreateAnimation(akPositions, akVictim)
  EndIf
  return -1
EndFunction

bool Function IncludesCreature(Actor[] akPositions) global
  Keyword ActorTypeNPC = Keyword.GetKeyword("ActorTypeNPC")
  int i = 0
  While(i < akPositions.Length)
    If(akPositions[i] && !akPositions[i].HasKeyword(ActorTypeNPC))
      return true
    EndIf
    i += 1
  EndWhile
  return false
EndFunction

bool Function OStimThere() global
  return Game.GetModByName("OStim.esp") != 255
EndFunction

String Function GetRaceType(Actor akActor) global
  If(akActor.HasKeywordString("ActorTypeNPC"))
    return "Human"
  ElseIf(KudasaiInternal.GetMCM().iFrameSL > -1)
    return KudasaiAnimationSL.GetRaceType(akActor)
  EndIf
  return ""
EndFunction

int Function GetAllowedParticipants(int limit) global
  Debug.Trace("[Kudasai] <GetAllowedParticipants> Limit = " + limit)
  If(limit <= 2)
    return limit
  EndIf
  int[] odds = KudasaiInternal.GetMCM().iSceneTypeWeight
  int res = KudasaiInternal.GetFromWeight(odds) + 1
  Debug.Trace("[Kudasai] <GetAllowedParticipants> res = " + res)
  If(res <= limit)
    return res
  EndIf
  return limit
EndFunction

bool Function IsAnimating(Actor akActor) global
  return KudasaiInternal.GetMCM().iFrameSL > -1 && KudasaiAnimationSL.IsAnimating(akActor) || \
    OStimThere() && KudasaiAnimationOStim.IsAnimating(akActor)
EndFunction

bool Function StopAnimating(Actor akActor) global
  return KudasaiInternal.GetMCM().iFrameSL > -1 && KudasaiAnimationSL.StopAnimating(akActor) || \
    OStimThere() && KudasaiAnimationOStim.StopAnimating(akActor)
EndFunction
