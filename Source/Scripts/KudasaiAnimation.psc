Scriptname KudasaiAnimation Hidden
{Main Script for Scene Starting}

; Return -1 on failure
int Function CreateAssault(Actor[] akPositions, Actor akVictim, String asHook, String asTags = "UseConfig") global
  Debug.Trace("[Kudasai] CreateAssault with Actors " + akPositions + " / Victim = " + akVictim + " / Hook = " + asHook)
  akPositions = PapyrusUtil.RemoveActor(akPositions, none)
  KudasaiMCM MCM = KudasaiInternal.GetMCM()
  If(MCM.iFrameSL <= 0 || (!MCM.FrameCreature && IncludesCreature(akPositions)))
    return -1
  EndIf
  return CreateAnimation(MCM, akPositions, akVictim, asTags, asHook)
EndFunction

; Expecting this to never be called with more than 5 Actors in array. Array may be unsorted
; Assume the victim to never be a creature
int Function CreateAnimation(KudasaiMCM MCM, Actor[] akPositions, Actor akVictim, String asTags, String asHook) global
  Debug.Trace("[Kudasai] SL Scene called with Actors = " + akPositions + " ;; Victim = " + akVictim + " >> hook = " + asHook)
  SexLabFramework SL = SexLabUtil.GetAPI()
  If(!SL.Enabled)
    return -1
  EndIf
  int lead = 0
  If(akVictim)
    lead = akPositions.Find(akVictim)
  EndIf
  int genderV = SL.GetGender(akPositions[lead])
  int[] genders = SL.GenderCount(akPositions)

  While(true)
    bool creatures = genders[2] || genders[3]
    sslBaseAnimation[] animations
    String[] tags
    If(asTags == "UseConfig")
      ; 0: F<-M | 1: M<-M | 2: M<-F | 3: F<-F | 4: F<-* | 5: M<-*
      int n
      If(akPositions.Length == 2 && !creatures)
        If(genderV == 1 && genders[0] == 1) ; F<-M
          n = 0
        Else ; F<-F // M<-F // M<-M
          n = 1 + genders[1]
        EndIf
      Else
        n = 5 - genderV
      EndIf
      tags = GetTags(MCM.SLTags[n])
    Else
      tags = GetTags(asTags)
    EndIf
    If(creatures)
      animations = SL.GetCreatureAnimationsByActorsTags(akPositions.Length, akPositions, tags[0], tags[1])
    Else
      animations = SL.GetAnimationsByTags(akPositions.length, tags[0], tags[1])
    EndIf
    If(!animations.Length)
      If(creatures)
        animations = SL.GetCreatureAnimationsByActors(akPositions.Length, akPositions)
      Else
        animations = SL.PickAnimationsByActors(akPositions, Aggressive = akVictim != none)
      EndIf
    EndIf
    If(!animations.Length)
      If(akPositions.Length <= 2)
        Debug.Trace("[Kudasai] Unable to find valid animations", 2)
        return -1
      EndIf
      Debug.Trace("[Kudasai] No Animations found, reducing Array size from size = " + akPositions.Length)
      Actor preserve = akPositions[lead]
      int i = 0
      While(i < akPositions.Length)
        If(akPositions[i] != preserve)
          akPositions = PapyrusUtil.RemoveActor(akPositions, akPositions[i])
          genders = SL.GenderCount(akPositions)
          lead = akPositions.Find(preserve)
        EndIf
        i += 1
      EndWhile
    Else
      return SL.StartSex(akPositions, animations, akVictim, hook = asHook)
    EndIf
  EndWhile
EndFunction

String[] Function GetTags(String str) global
  String[] all = PapyrusUtil.StringSplit(str, ",")
  String[] res = new String[2]
  int i = 0
  While(i < all.Length)
    If(StringUtil.GetNthChar(all[i], 0) == "-")
      res[1] = res[1] + (StringUtil.Substring(all[i], 1) + ",")
    Else
      res[0] = res[0] + all[i]
    EndIf
    i += 1
  EndWhile
  return res
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

bool Function AllowCreatures() global
  SexLabFramework sl = SexLabUtil.GetAPI()
  return sl.Enabled && sl.AllowCreatures
EndFunction

String Function GetRaceType(Actor akActor) global
  If(akActor.HasKeywordString("ActorTypeNPC"))
    return "Human"
  ElseIf(KudasaiInternal.GetMCM().iFrameSL > -1)
    String raceID = MiscUtil.GetActorRaceEditorID(akActor)
    return sslCreatureAnimationSlots.GetRaceKeyByID(raceID)
  EndIf
  return ""
EndFunction

String[] Function GetAllRaceKeys() global
  return sslCreatureAnimationSlots.GetAllRaceKeys()
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
  return KudasaiInternal.GetMCM().iFrameSL > -1 && SexLabUtil.GetAPI().FindActorController(akActor) > -1
EndFunction

bool Function StopAnimating(Actor akActor, int tid = -1) global
  If (KudasaiInternal.GetMCM().iFrameSL == -1)
    return false
  EndIf
  SexLabFramework SL = SexLabUtil.GetAPI()
  if (tid == -1)
    tid = SL.FindActorController(akActor)
    if (tid == -1)
      Debug.Trace("[Kudasai] Actor = " + akActor + " is not part of any SL Animation.")
      return false
    endif
  endif
  sslThreadController controller = SL.GetController(tid)
  if (!controller)
    Debug.Trace("[Kudasai] Actor = " + akActor + " is not part of any SL Animation.")
    return false
  endif
  controller.EndAnimation()
  return true
EndFunction

Actor[] Function GetPositions(int tid) global
  SexLabFramework SL = SexLabUtil.GetAPI()
  sslThreadController controller = SL.GetController(tid)
  return controller.Positions
EndFunction

Actor Function GetVictim(int tid) global
  SexLabFramework SL = SexLabUtil.GetAPI()
  sslThreadController Controller = SL.GetController(tid)
  return Controller.GetVictim()
EndFunction

