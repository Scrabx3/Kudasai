Scriptname KudasaiAnimationSL Hidden

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

int Function CreateAnimationCustom(Actor[] positions, Actor victim, String tags, String hook) global
  SexLabFramework SL = SexLabUtil.GetAPI()
  sslBaseAnimation[] anims = SL.GetAnimationsByTags(positions.Length, tags)
  return SL.StartSex(positions, anims, victim, hook = hook)
EndFunction

int Function GetActorType(Actor subject) global
  SexLabFramework SL = SexLabUtil.GetAPI()
  int sex = SL.GetGender(subject)
  If (sex > 2)
    sex += 1
  ElseIf (sex == 2)
    If(Game.GetModByName("Schlongs of Skyrim.esp") != 255)
      Faction schlongified = Game.GetFormFromFile(0x00AFF8, "Schlongs of Skyrim.esp") as Faction
      sex += subject.IsInFaction(schlongified) as int
    EndIf
  EndIf
  return sex
EndFunction

Function SortActors(Actor[] subjects) global
  SexLabFramework SL = SexLabUtil.GetAPI()
  int i = 1
  While(i < subjects.Length)
    Actor sortthis = subjects[i]
    int gender = SL.GetGender(sortthis)
    int n = i - 1
    While(n != -1 && IsLesserGender(gender, SL.GetGender(subjects[n])))
      subjects[n + 1] = subjects[n]
      n -= 1
    EndWhile
    subjects[n + 1] = sortthis
    i += 1
  EndWhile
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

; returns true if prim < sec
; Male = 0, Female = 1, Crt = 2, FCrt = 3
; Female > Male > Creature > FCrt
bool Function IsLesserGender(int prim, int sec) global
  If (prim == 1)
    return true
  Else
    return prim < sec
  EndIf
EndFunction

bool Function IsAnimating(Actor subject) global
  SexLabFramework SL = SexLabUtil.GetAPI()
  return SL.FindActorController(subject) > -1
EndFunction

bool Function StopAnimating(Actor subject, int tid = -1) global
  SexLabFramework SL = SexLabUtil.GetAPI()
  if (tid == -1)
    tid = SL.FindActorController(subject)
    if (tid == -1)
      Debug.Trace("[Kudasai] Actor = " + subject + " is not part of any SL Animation.")
      return false
    endif
  endif
  sslThreadController controller = SL.GetController(tid)
  if (!controller)
    Debug.Trace("[Kudasai] Actor = " + subject + " is not part of any SL Animation.")
    return false
  endif
  controller.EndAnimation()
  return true
EndFunction

int Function HookIfAnimating(Actor subject, String hook) global
  SexLabFramework SL = SexLabUtil.GetAPI()
  int tid = SL.FindActorController(subject)
  If(tid == -1)
    Debug.Trace("[Kudasai] Actor = " + subject + " is not part of any SL Animation.")
    return -1
  EndIf
  sslThreadController controller = SL.GetController(tid)
  String[] hooks = controller.GetHooks()
  Debug.Trace("[Kudasai] Actor is animating; hooks = " + hooks)
  int i = 0
  While(i < hooks.Length)
    If(StringUtil.Find(hooks[i], "Kudasai_") > -1)
      controller.SetHook(hook)
      return 1
    EndIf
    i += 1
  EndWhile
  return 0
EndFunction

bool Function AllowCreatures() global
  SexLabFramework sl = SexLabUtil.GetAPI()
  return sl.Enabled && sl.AllowCreatures
EndFunction

String Function GetRaceType(Actor akActor) global
  String raceID = MiscUtil.GetActorRaceEditorID(akActor)               
  return sslCreatureAnimationSlots.GetRaceKeyByID(raceID)
EndFunction

String[] Function GetAllRaceKeys() global
  return sslCreatureAnimationSlots.GetAllRaceKeys()
EndFunction
