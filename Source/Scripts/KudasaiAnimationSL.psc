Scriptname KudasaiAnimationSL Hidden

; Expecting this to never be called with more than 5 Actors in array. Array may be unsorted
; Assume the victim to never be a creature
int Function CreateAnimation(KudasaiMCM MCM, Actor[] array, Actor victim, String hook) global
  Debug.Trace("[Kudasai] SL Scene called with Actors = " + array + " ;; Victim = " + victim + " >> hook = " + hook)
  If(array.length < 2)
    Debug.Trace("[Kudasai] Not enough Actors", 1)
    return -1
  EndIf
  int v = ValidateArray(array)
  If(v > -1)
    Debug.Trace("[Kudasai] Actor at " + v + "(" + array[v] + ") is invalid, aborting", 2)
    return -1
  EndIf
  SexLabFramework SL = SexLabUtil.GetAPI()
  Actor[] positions = SL.SortActorsByAnimation(array)
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
    int n
    If(positions.length == 2 && genders.find(3) == -1 && genders.find(4) == -1)
	    int males = genders.find(0)
	    If(genders[0] == 1 && males == 1) ; Female first & Male Partner
        n = 0
	    ElseIf(males == 2)
        n = 1
      ElseIf(victim && SL.GetGender(victim) == 0)
        n = 2
      Else
        n = 3
	    EndIf
	  Else
      If(genders[0] == 0 || victim && SL.GetGender(victim) == 0)
        n = 4
      Else
        n = 5
      EndIf
	  EndIf
    String[] tags = GetTags(MCM.SLTags[n])
    anims = SL.GetAnimationsByTags(positions.length, tags[0], tags[1])
		If(anims.Length)
			breakLoop = true
		Else
      If(positions.length < 3)
        Debug.Trace("[Kudasai] No Animations found", 2)
        return -1
      EndIf
      Debug.Trace("[Kudasai] No Animations found, reducing Array size from size = " + positions.length)
      int j = positions.Length
      While(j > 0)
        j -= 1
        If(positions[j] != victim)
          positions = PapyrusUtil.RemoveActor(positions, positions[j])
          ; might wanna create my own removeat() function here..
          genders = Utility.CreateIntArray(positions.length)
          int k = 0
          While(k < genders.length)
            genders[i] = SL.GetGender(positions[i])
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

float Function GetArousal(Actor subject) global
  return (Quest.GetQuest("sla_Framework") as slaFrameworkScr).GetActorArousal(subject)
EndFunction

; if filter = true, remove the actors from the array
Function FilterArousal(Actor[] subjects) global
  Debug.Trace("[Kudasai] <SL FilterArousal> Filtering Actors = " + subjects)
  KudasaiMCM MCM = KudasaiInternal.GetMCM()
  int i = 0
  While(i < subjects.Length)
    float arousal = GetArousal(subjects[i])
    Debug.Trace("[Kudasai] <SL FilterArousal> Arousal = " + arousal)
    If (arousal < 0)
      arousal = 0
    EndIf
    If(subjects[i].IsPlayerTeammate())
      If (arousal < MCM.fArousalFollower)
        Debug.Trace("[Kudasai] <SL FilterArousal> Removing Actor = " + subjects[i])
        subjects = PapyrusUtil.RemoveActor(subjects, subjects[i])
      EndIf
    ElseIf(arousal < MCM.fArousalNPC)
      Debug.Trace("[Kudasai] <SL FilterArousal> Removing Actor = " + subjects[i])
      subjects = PapyrusUtil.RemoveActor(subjects, subjects[i])
    EndIf
    i += 1
  EndWhile
EndFunction
