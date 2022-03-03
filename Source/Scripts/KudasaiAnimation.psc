Scriptname KudasaiAnimation Hidden
{Main Script for Scene Starting}

; Assume this to be called with only npc or equal races as partners, partners.length <= 4
; On Success: return 0+ and send "KCreatureAssaultSuccess_" + Hook mod event from Victim
; On Failure: return -1 and send "KCreatureAssaultFailure_" + Hook mod event from Victim
int Function CreateAssault(Actor victim, Actor[] partners, String hook, bool checkarousal = false) global
  Debug.Trace("[Kudasai] Create Assault -> Victim = " + victim + " partners = " + partners + " Hook = " + hook)
  KudasaiMCM MCM = KudasaiInternal.GetMCM()
  Keyword ATNPC = Keyword.GetKeyword("ActorTypeNPC")
  int res = -1
  If(!victim.HasKeyword(ATNPC) || !partners[0].HasKeyword(ATNPC))
    If(MCM.fSLWeight > 0)
      If(checkarousal)
        KudasaiAnimationSL.FilterArousal(partners)
      EndIf
      Actor[] positions = PapyrusUtil.PushActor(partners, victim)
      res = KudasaiAnimationSL.CreateAnimation(MCM, positions, victim, hook)
    EndIf
  Else
    float frame = MCM.fSLWeight + MCM.fOStimWeight
    If(Utility.RandomFloat(0, frame) < MCM.fSLWeight)
      If(checkarousal)
        KudasaiAnimationSL.FilterArousal(partners)
      EndIf
      Actor[] positions = PapyrusUtil.PushActor(partners, victim)
      res = KudasaiAnimationSL.CreateAnimation(MCM, positions, victim, hook)
    Else
      If(checkarousal)
        KudasaiAnimationOStim.FilterArousal(partners)
      EndIf
      res = KudasaiAnimationOStim.CreateAnimation(MCM, victim, partners, partners[0])
    EndIf
  EndIf
  int handle
  If (res == -1)
    Debug.Trace("[Kudasai] <CreateAssault> Animation = -1", 1)
    handle = ModEvent.Create("KCreatureAssaultFailure_" + hook)
  Else
    Debug.Trace("[Kudasai] <CreateAssault> Animation = " + res, 0)
    handle = ModEvent.Create("KCreatureAssaultSuccess_" + hook)
  EndIf
  ModEvent.PushForm(handle, victim)
  int i = 0
  While(i < 4)
    If(partners.length < i)
      ModEvent.PushForm(handle, partners[i])
    Else
      ModEvent.PushForm(handle, none)
    EndIf
    i += 1
  EndWhile
  ModEvent.Send(handle)
  return res
EndFunction

int Function CreateAnimationCustom2p(KudasaiMCM MCM, Actor primus, Actor secundus, Actor victim, String tags, String hook) global
  Debug.Trace("[Kudasai] Custom 2p -> primus = " + primus + " partners = " + secundus + " Hook = " + hook)
  Keyword ATNPC = Keyword.GetKeyword("ActorTypeNPC")
  int res
  If(!primus.HasKeyword(ATNPC) || !secundus.HasKeyword(ATNPC))
    Actor[] positions = new Actor[2]
    positions[0] = primus
    positions[1] = secundus
    res = KudasaiAnimationSL.CreateAnimationCustom(positions, victim, tags, hook)
  Else
    float frame = MCM.fSLWeight + MCM.fOStimWeight
    If(Utility.RandomFloat(0, frame) < MCM.fSLWeight)
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
  int handle
  If (res == -1)
    Debug.Trace("[Kudasai] <CreateAssault> Animation = -1", 1)
    handle = ModEvent.Create("KCreatureAssaultFailure_" + hook)
  Else
    Debug.Trace("[Kudasai] <CreateAssault> Animation = " + res, 0)
    handle = ModEvent.Create("KCreatureAssaultSuccess_" + hook)
  EndIf
  ModEvent.PushForm(handle, primus)
  ModEvent.PushForm(handle, secundus)
  int i = 0
  While(i < 3)
    ModEvent.PushForm(handle, none)
    i += 1
  EndWhile
  ModEvent.Send(handle)
  return res
EndFunction

int Function GetAllowedParticipants(int limit) global
  Debug.Trace("[Kudasai] <GetAllowedParticipants> Limit = " + limit)
  If(limit <= 2)
    return limit
  EndIf
  int[] odds = new int[4]
  odds[0] = 50 ; 2p
  odds[1] = 85 ; 3p
  odds[2] = 35 ; 4p
  odds[3] = 20 ; 5p
  int res = KudasaiInternal.GetFromWeight(odds) + 1
  Debug.Trace("[Kudasai] <GetAllowedParticipants> res = " + res)
  If(res <= limit)
    return res
  EndIf
  return limit
EndFunction