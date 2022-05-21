Scriptname KudasaiAnimationSL Hidden

; Expecting this to never be called with more than 5 Actors in array. Array may be unsorted
; Assume the victim to never be a creature
int Function CreateAnimation(KudasaiMCM MCM, Actor[] positions, Actor victim, String hook) global
  Debug.Trace("[Kudasai] SL Scene called with Actors = " + positions + " ;; Victim = " + victim + " >> hook = " + hook)
  If(positions.length < 2)
    Debug.Trace("[Kudasai] Not enough Actors", 1)
    return -1
  EndIf
  SexLabFramework SL = SexLabUtil.GetAPI()
  If(!SL.Enabled)
    return -1
  EndIf
  int v = ValidateArray(positions)
  If(v > -1)
    Debug.Trace("[Kudasai] Actor at " + v + "(" + positions[v] + ") is invalid, aborting", 2)
    return -1
  EndIf
  SortActors(positions)
  int vpos = positions.find(victim)
  int[] genders = Utility.CreateIntArray(positions.length)
  int i = 0
  While(i < genders.length)
    genders[i] = SL.GetGender(positions[i])
    i += 1
  EndWhile
  sslBaseAnimation[] anims
	bool breakLoop = false
	While(!breakLoop)
    bool creatures = genders.find(3) > -1 || genders.find(4) > -1
    int n
    If(positions.length == 2 && !creatures)
	    int males = SL.MaleCount(positions)
	    If(genders[0] == 1 && males == 1) ; F<-M
        n = 0
      Else ; F<-F // M<-F // M<-M
        n = 1 + males
      EndIf
	  Else
      If(genders[0] == 0 || victim && SL.GetGender(victim) == 0)
        n = 4
      Else
        n = 5
      EndIf
	  EndIf
    String[] tags = GetTags(MCM.SLTags[n])
    If (creatures)
      anims = SL.GetCreatureAnimationsByRaceTags(positions.Length, positions[positions.Length - 1].GetRace(), tags[0], tags[1])
    Else
      anims = SL.GetAnimationsByTags(positions.length, tags[0], tags[1])
    EndIf
		If(anims.Length)
      Debug.Trace("[Kudasai] Found Animations = " + anims.Length)
			breakLoop = true
		Else
      If(positions.length <= 2) ; Didnt find an animation with 2 or less actors
        Debug.Trace("[Kudasai] No Animations found", 2)
        return -1
      EndIf
      Debug.Trace("[Kudasai] No Animations found, reducing Array size from size = " + positions.length)
      int j = positions.Length
      While(j > 0)
        j -= 1
        If(positions[j] != victim)
          positions = PapyrusUtil.RemoveActor(positions, positions[j])
          genders = Utility.CreateIntArray(positions.length)
          int k = 0
          While(k < genders.length)
            genders[k] = SL.GetGender(positions[k])
            k += 1
          EndWhile
        EndIf
      EndWhile
    EndIf
	EndWhile
  return SL.StartSex(positions, anims, victim, hook = hook)
EndFunction

int Function ValidateArray(Actor[] array) global
  SexLabFramework SL = SexLabUtil.GetAPI()
  Keyword ActorTypeNPC = Keyword.GetKeyword("ActorTypeNPC")
  String racetag = ""
  int i = 0
  While(i < array.Length)
    If(SL.IsValidActor(array[i]) == false)
      return i
    ElseIf(array[i].HasKeyword(ActorTypeNPC) == false)
      String raceID = MiscUtil.GetActorRaceEditorID(array[i])
      If(racetag == "")
        racetag = sslCreatureAnimationSlots.GetRaceKeyByID(raceID)
      ElseIf(sslCreatureAnimationSlots.GetRaceKeyByID(raceID) != racetag)
        return i
      EndIf
    EndIf
    i += 1
  EndWhile
  return -1
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
  return Controller.VictimRef
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
  return SexLabUtil.GetAPI().AllowCreatures
EndFunction
