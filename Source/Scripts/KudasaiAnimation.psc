Scriptname KudasaiAnimation Hidden
{Main Script for Scene Starting}

; Assume this to be called with only npc or equal races as partners, partners.length <= 4
; Return -1 on failure
int Function CreateAssault(Actor[] akPositions, Actor akVictim, String asHook, String asTags = "UseConfig") global
  If(akPositions.Length != 5)
    akPositions = PapyrusUtil.ResizeActorArray(akPositions, 5)
  EndIf
  Debug.Trace("[Kudasai] CreateAssault with Actors " + akPositions + " / Victim = " + akVictim + " / Hook = " + asHook)
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
    If(!akPositions[i].HasKeyword(ActorTypeNPC))
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

;/
int Function CreateAnimationCustom2p(KudasaiMCM MCM, Actor primus, Actor secundus, Actor victim, String tags, String hook) global
  Debug.Trace("[Kudasai] CreateAnimationCustom 2p -> primus = " + primus + " partners = " + secundus + " Hook = " + hook)
  int res = -1
  If(MCM.FrameAny)
    Keyword ATNPC = Keyword.GetKeyword("ActorTypeNPC")
    If(!primus.HasKeyword(ATNPC) || !secundus.HasKeyword(ATNPC))
      If(MCM.FrameCreature)
        Actor[] positions = new Actor[2]
        positions[0] = primus
        positions[1] = secundus
        res = KudasaiAnimationSL.CreateAnimationCustom(positions, victim, tags, hook)
      EndIf
    Else
      int frame = MCM.iSLWeight + MCM.iOStimWeight
      If(Utility.RandomInt(0, frame) < MCM.iSLWeight)
        Actor[] positions = new Actor[2]
        positions[0] = primus
        positions[1] = secundus
        res = KudasaiAnimationSL.CreateAnimationCustom(positions, victim, tags, hook)
      Else
        Actor[] partners = new Actor[1]
        partners[0] = secundus
        Actor aggressor = none
        If (victim)
          aggressor = secundus
        EndIf
        res = KudasaiAnimationOStim.CreateAnimation(MCM, primus, partners, aggressor)
      EndIf
    EndIf
  EndIf
  Debug.Trace("[Kudasai] CreateAnimationCustom Result = " + res, (res == -1) as int)
  return res
EndFunction

; Return -1 if the Victim is not animating
; Return 0 if the Victim is animating but a Snatch is not permitted (= the Animation isnt called by Kudasai or the Animation is an OStim one)
; Return 1 if the Victim is animating and a Snatch was successful
int Function HookIfAnimating(Actor subject, KudasaiMCM MCM, String hook) global
  Debug.Trace("[Kudasai] Snatching Animation from " + subject + " with new Hook = " + hook)
  If (MCM.iSLWeight > 0)
    int status = KudasaiAnimationSL.HookIfAnimating(subject, hook)
    If(status > -1)
      return status
    EndIf
  EndIf
  If (MCM.iOStimWeight > 0 && KudasaiAnimationOStim.IsAnimating(subject))
    return 0
  EndIf
  return -1
EndFunction
/;
