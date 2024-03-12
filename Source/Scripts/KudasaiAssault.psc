Scriptname KudasaiAssault extends Quest Conditional

String Property HookID = "YKrPlayer_" AutoReadOnly

KudasaiMCM Property MCM Auto

Actor Property PlayerRef Auto
KudasaiAssaultAliasPlayer Property PlayerAlias Auto
ReferenceAlias Property RefAlly1 Auto
ReferenceAlias Property RefAlly2 Auto

ReferenceAlias Property RecentSpeaker Auto
ReferenceAlias Property FirstNPC Auto
ReferenceAlias[] Property RefsA Auto
ReferenceAlias[] Property RefsB Auto
ReferenceAlias[] Property RefsC Auto
Scene Property PlayerScene Auto
Topic Property CycleTopic Auto

FavorJarlsMakeFriendsScript Property ThaneVars Auto
FormList Property HoldsList Auto
Quest Property PlayerWerewolfQuest Auto
Race Property WerebearRace Auto
Keyword Property ActorTypeNPC Auto

Actor[] GroupA
Actor[] GroupB
Actor[] GroupC

bool[] cycle_cancel
int[] cycle_count

int Property IsWerewolf Auto Hidden Conditional     ; 0 = No Werewolf, 1 = Werewolf, 2 = Werebear
bool Property Thane Auto Hidden Conditional         ; Player is thane in current hold?
bool Property Remembers Auto Hidden Conditional     ; Player has been defeated by these NPC before?
bool Property CanEnterNSFW Auto Hidden Conditional  ; If the player group can enter adult content or not
int Property CyclesPlayer Auto Hidden Conditional   ; Number of assaults thus far

bool Property CanEnterNSFW_Ally1 Auto Hidden Conditional
bool Property CanEnterNSFW_Ally2 Auto Hidden Conditional

;/  START UP  /;

Function Setup()
  Debug.Trace("[Kudasai] Started Assault Player -> Setup()")
  RegisterForSingleUpdate(0.7)
  cycle_count = new int[3]
  cycle_cancel = new bool[3]
  Acheron.RegisterForActorRescued(self)
EndFunction

Event OnUpdate()
  Debug.Trace("[Kudasai] Started Assault Player -> OnUpdate()")
  GroupA = AsActorArray(RefsA)
  GroupB = AsActorArray(RefsB)
  GroupC = AsActorArray(RefsC)
  Actor ref1 = RefAlly1.GetActorRef()
  Actor ref2 = RefAlly2.GetActorRef()
  CanEnterNSFW_Ally1 = ref1 && HasInterestedActor(ref1, GroupB)
  CanEnterNSFW_Ally2 = ref2 && HasInterestedActor(ref2, GroupC)
  RescueAll(GroupA)
  RescueAll(GroupB)
  RescueAll(GroupC)
  bool interested = false
  int i = 0
  While(i < GroupA.Length && !interested)
    If(GroupA[i].HasKeyword(ActorTypeNPC))
      If (!interested && IsValidPrime(GroupA[i], PlayerRef))
        interested = true
      EndIf
      FirstNPC.ForceRefTo(GroupA[i])
    EndIf
    i += 1
  EndWhile
  Debug.Trace("[Kudasai] Groups -> A: " + GroupA + " (First NPC: " + FirstNPC.GetReference() + ") | B: " + GroupB + " | C: " + GroupC)
  IsWerewolf = IsWerewolf()
  Thane = IsThane()
  Remembers = IsRemembered()
  CanEnterNSFW = HasInterestedActor(PlayerRef, GroupA)
  Debug.Trace("[Kudasai] Dialogue Vars -> IsWerewolf: " + IsWerewolf + " | Thane: " + Thane + " | Remembers: " + Remembers + " | CanEnterNSFW: " + CanEnterNSFW)
  Debug.Trace("[Kudasai] Ally Vars     -> CanEnterNSFW (Ally1): " + CanEnterNSFW_Ally1 + " | CanEnterNSFW (Ally2): " + CanEnterNSFW_Ally2)
  ; Gotta set data ( ^ ) before playing player scene. Other scenes are started on quest start
  If (!CanEnterNSFW && !FirstNPC.GetReference())  ; Invalid creature
    Debug.Trace("[Kudasai] Creature Assault but creature is invalid. Skip player scene...")
    EndCycle(0, PlayerRef)
    EvaluatePackageGroup(0)
    Utility.Wait(5)
    PlayerAlias.GoToState("Exhausted")
    Debug.Notification(" " + GroupA[0].GetLeveledActorBase().GetName() + " doesn't seem interested in you...")
  Else
    PlayerScene.Start()
  EndIf
  SetStage(5)
EndEvent

Function RescueAll(Actor[] akRefs, bool pacify = true)
  int i = 0
  While(i < akRefs.Length)
    If(Acheron.IsDefeated(akRefs[i]))
      Acheron.RescueActor(akRefs[i], pacify)
    Else
      If(!Acheron.IsPacified(akRefs[i]))
        Acheron.PacifyActor(akRefs[i])
      EndIf
    EndIf
    i += 1
  EndWhile
EndFunction

Function PacifyAllRefs(ReferenceAlias[] akRefs)
  int i = 0
  While(i < akRefs.Length)
    Actor _actor = akRefs[i].GetReference() as Actor
    If(!Acheron.IsPacified(_actor))
      Acheron.PacifyActor(_actor)
    EndIf
    i += 1
  EndWhile
EndFunction

Function ReleaseAllRefs(ReferenceAlias[] akRefs)
  int i = 0
  While(i < akRefs.Length)
    Actor _actor = akRefs[i].GetReference() as Actor
    If(Acheron.IsPacified(_actor))
      Acheron.ReleaseActor(_actor)
    EndIf
    i += 1
  EndWhile
EndFunction

;/  CYCLE ENTRANCE  /;

float Property how_close = 420.0 AutoReadOnly Hidden

; Only called if NSFW == true
Function MakePlayerCycle()
  Actor ref = FirstNPC.GetReference() as Actor
  If(!ref || ref.IsInDialogueWithPlayer() || PlayerRef.GetDistance(ref) > how_close)
    int n = 0
    While(n < 5)
      Utility.Wait(1.0)
      int i = 0
      While(i < GroupA.Length)
        Actor it = GroupA[i]
        If((!ref || it != ref || !ref.IsInDialogueWithPlayer()) && PlayerRef.GetDistance(it) <= how_close)
          ref = it
          i = GroupA.Length
          n = 5
        EndIf
        i += 1
      EndWhile
      n += 1
    EndWhile
    ; Only called after at least 1 actor is less than 300 units away from the player, 
    ; hence this is at least the original ref, make sure for them to finish dialogue
    While(ref.IsInDialogueWithPlayer())
      Debug.Trace("[Kudasai] Primary aggressor reference is in dialogue..")
      Utility.Wait(0.5)
    EndWhile
  EndIf
  MakeStruggleOr(PlayerRef, ref)
EndFunction

Function MakeAllyCycle(int aiAllyID)
  Actor victim
  Actor aggressor
  Actor[] grp
  If(aiAllyID == 1)
    victim = RefAlly1.GetReference() as Actor
    grp = GroupB
  Else
    victim = RefAlly2.GetReference() as Actor
    grp = GroupC
  EndIf
  int i = 0
  While(i < grp.Length)
    Actor it = grp[i]
    If(!aggressor && victim.GetDistance(it) < how_close)
      aggressor = it
    EndIf
    i += 1
  EndWhile
  ; assert(aggressor != none)
  MakeStruggleOr(victim, aggressor)
EndFunction

; Make a struggle or start cycle
Function MakeStruggleOr(Actor akVictim, Actor akAggressor)
  bool npc = akAggressor.HasKeyword(ActorTypeNPC)
  If(npc && MCM.bUseStruggle || !npc && MCM.bUseStruggleCrt)
    String callbackevent = "Kudasai_StruggleResult"
    float difficulty = 0.0
    If(akVictim == PlayerRef)
      float lvDiff = akAggressor.GetLevel() - akVictim.GetLevel()
      float hpDmg = (1 - akAggressor.GetAVPercentage("Health")) * 75
      difficulty = 80.0 + hpDmg - lvDIff - 2.5 * GroupA.Length
      Debug.Trace("[Kudasai] Player Assault; Setting difficulty to { " + difficulty + " } // lvDiff = " + lvDiff + "; hpDmg = " + hpDmg + "; GroupA.Length = " + GroupA.Length)
    EndIf
    If(KudasaiStruggle.MakeStruggle(akAggressor, akVictim, callbackevent, difficulty))
      RegisterForModEvent(callbackevent, "OnStruggleEnd")
      Debug.Trace("[Kudasai] Created Struggle")
      return
    EndIf
    Debug.Trace("[Kudasai] Failed to create Struggle, falling back to scene")
  EndIf
  EnterCycle(akVictim)
EndFunction

Event OnStruggleEnd(Form akVictim, Form akAggressor, bool abVictimEscaped)
  Debug.Trace("[Kudasai] Struggle End -> Victim: " + akVictim + " // abVictimEscaped: " + abVictimEscaped)
  If(abVictimEscaped) ; Only the player can escape here
    Acheron.RescueActor(PlayerRef, false)
    Utility.Wait(3)
    Debug.Trace("[Kudasai] Player escaped, stopping quest...")
    Stop()
    return
  EndIf
  EnterCycle(akVictim as Actor)
EndEvent

Function EnterCycle(Actor akVictim)
  int id = GetVictimID(akVictim)
  Debug.Trace("[Kudasai] Creating cycle for victim " + akVictim + "(" + id + ")")
  RegisterForModEvent("HookAnimationEnd_" + HookID + id, "PostAssaultSL_" + id)
  RegisterForModEvent("ostim_end", "PostAssaultOStim")
  NewCycle(akVictim, id, PapyrusUtil.ActorArray(0))
EndFunction

;/  CYCLE  /;

Event PostAssaultSL_0(int tid, bool hasPlayer)
  PostSceneSL(tid, 0)
EndEvent
Event PostAssaultSL_1(int tid, bool hasPlayer)
  PostSceneSL(tid, 1)
EndEvent
Event PostAssaultSL_2(int tid, bool hasPlayer)
  PostSceneSL(tid, 2)
EndEvent
Function PostSceneSL(int tid, int aiVicID)
  Actor[] positions = KudasaiAnimationSL.GetPositions(tid)
  Actor victim = KudasaiAnimationSL.GetVictim(tid)
  Utility.Wait(0.5)
  NewCycle(victim, aiVicID, positions)
EndFunction
Event PostAssaultOStim(string asEventName, string asStringArg, float afNumArg, form akSender)
  Actor[] positions = KudasaiAnimationOStim.GetPositions(afNumArg as int)
  Actor victim
  int id
  If(positions.find(Game.GetPlayer()) > -1)
    victim = Game.GetPlayer()
  ElseIf(positions.find(RefAlly1.GetActorReference()) > -1)
    victim = RefAlly1.GetReference() as Actor
  ElseIf(positions.find(RefAlly2.GetActorReference()) > -1)
    victim = RefAlly2.GetReference() as Actor
  EndIf
  If(!victim)
    return
  EndIf
  NewCycle(victim, id, positions)
EndEvent

Function NewCycle(Actor akVictim, int aiVicID, Actor[] akOldPosition)
  Debug.Trace("[Kudasai] Attempting new cycle for victim " + akVictim + "(" + aiVicID + ")")
  If (cycle_cancel[aiVicID] || IsStopped() || IsStopping())
    Debug.Trace("[Kudasai] Assault Quest ending, abandon")
    return
  EndIf
  cycle_count[aiVicID] = cycle_count[aiVicID] + 1
  If(MCM.iMaxAssaults != 0 && cycle_count[aiVicID] > MCM.iMaxAssaults)
    Debug.Trace("[Kudasai] Ending Cycle after " + cycle_count[aiVicID] + "/" + MCM.iMaxAssaults + " animations")
    EndCycle(aiVicID, akVictim)
    return
  ElseIf(aiVicID == 0)
    CyclesPlayer = cycle_count[0]
  EndIf

  Actor[] group = GetVictimGroup(aiVicID)
  If(akOldPosition.Length)
    ; Linking from a previous animation
    int i = 0
    While(i < akOldPosition.Length)
      If(akOldPosition[i] != akVictim && Utility.RandomFloat(0, 99.5) < MCM.fRapistQuits)
        int where = group.find(akOldPosition[i])
        group[where] = none
      EndIf
      i += 1
    EndWhile
    group = PapyrusUtil.RemoveActor(group, none)
    If(!group.Length)
      Debug.Trace("[Kudasai] No aggressors left to animate group for victim " + akVictim + "(" + aiVicID + ")")
      EndCycle(aiVicID, akVictim)
      return
    EndIf
    AssignVictimGroup(aiVicID, group)
    Debug.SendAnimationEvent(akVictim, "BleedoutStart")
  EndIf
  Actor[] positions = BuildSceneArray(akVictim, group)
  If(positions[1] == none)
    Debug.Trace("[Kudasai] Unable to build scene array for victim " + akVictim + "(" + aiVicID + ")")
    EndCycle(aiVicID, akVictim)
    return
  ElseIf(aiVicID == 0 && positions[1].HasKeyword(ActorTypeNPC))
    RecentSpeaker.ForceRefTo(positions[1])
    positions[1].Say(CycleTopic)
    Utility.Wait(3)
  EndIf
  If(KudasaiAnimation.CreateAssault(positions, akVictim, HookID + aiVicID) == -1)
    Debug.Trace("[Kudasai] Failed to create scene for victim " + akVictim + "(" + aiVicID + ")")
    EndCycle(aiVicID, akVictim)
    If(aiVicID == 0)
      Debug.Notification("Failed to create Scene")
    EndIf
  EndIf
EndFunction

Actor[] Function BuildSceneArray(Actor akVictim, Actor[] akPotentials)
  Debug.Trace("[Kudasai] Building Scene array for victim: " + akVictim + " with potentials: " + akPotentials)
  Actor[] ret = new Actor[5]
  ret[0] = akVictim
  int sexV = akVictim.GetActorBase().GetSex()
  String pType = ""
  int i = 0
  int ii = 1
  int max = KudasaiAnimation.GetAllowedParticipants(akPotentials.Length + 1)
  While(i < 50 && ii < max)
    Actor it = akPotentials[Utility.RandomInt(0, akPotentials.Length - 1)]
    If(it.Is3DLoaded() && !Acheron.IsDefeated(it))
      If(pType == "")
        String rt = IsValidPrime(it, akVictim)
        If(rt != "")
          pType = rt
          ret[ii] = it
          ii += 1
        EndIf
      ElseIf(ret.Find(it) == -1 && KudasaiAnimation.GetRaceType(it) == pType && IsMatchGender(sexV, pType != "Human", it))
        ret[ii] = it
        ii += 1
      EndIf
    EndIf
    i += 1
  EndWHile
  return ret
EndFunction

bool Function IsMatchGender(int aiVictimSex, bool abCrt, Actor akActor)
  If(abCrt)
    If(aiVictimSex == 0)
      return MCM.bAllowMC
    Else
      return MCM.bAllowFC
    EndIf
  EndIf
  int aggrSex = akActor.GetLeveledActorBase().GetSex()
  If(aggrSex != aiVictimSex)
    If (aiVictimSex == 0)
      return MCM.bAllowFM
    Else
      return MCM.bAllowMF
    EndIf
  ElseIf(aggrSex == 0)
    return MCM.bAllowMM
  Else
    return MCM.bAllowFF
  EndIf
EndFunction

;/  QUEST END  /;

Event OnActorRescued(Actor akVictim)
  Debug.Trace("[Kudasai] Actor has been rescued: " + akVictim)
  If (akVictim == PlayerRef)
    If (GetStageDone(105))
      ; Player exhaustion state
      return
    EndIf
    cycle_cancel[0] = true
    If(KudasaiAnimation.IsAnimating(akVictim))
      KudasaiAnimation.StopAnimating(akVictim)
    EndIf
    Utility.Wait(3)
    Stop()
  ElseIf (akVictim == RefAlly1.GetReference())
    cycle_cancel[1] = true
    ForceStop(RefAlly1)
    Utility.Wait(0.5)
    EndCycle(1, akVictim)
  ElseIf (akVictim == RefAlly2.GetReference())
    cycle_cancel[2] = true
    ForceStop(RefAlly2)
    Utility.Wait(0.5)
    EndCycle(2, akVictim)
  EndIf
EndEvent

Function EndCycle(int aiVicID, Actor akVictim)
  If (GetStage() == 500 || IsStopped() || IsStopping())
    Debug.Trace("[Kudasai] Ending cycle for victim " + akVictim + "(" + aiVicID + ") but quest is at Stage 500 (Stopping)")
    return
  EndIf
  int stage = aiVicID * 100 + 100
  If(GetStageDone(stage))
    Debug.Trace("[Kudasai] Ending cycle for victim " + akVictim + "(" + aiVicID + ") but stage is already set")
    return
  EndIf
  cycle_cancel[aiVicID] = true
  Debug.Trace("[Kudasai] Ending cycle for victim " + akVictim + "(" + aiVicID + ")")
  ; Progress scene
  SetStage(stage)
  If(aiVicID != 0)
    Debug.SendAnimationEvent(akVictim, "bleedoutStart")
  EndIf
EndFunction

Function CheckStopConditions(int aiVictimID)
  If (!GetStageDone(120) || RefAlly1.GetRef() && !GetStageDone(210) || RefAlly2.GetRef() && !GetStageDone(310))
    Debug.Trace("[Kudasai] Fully shut down cycle " + aiVictimID)
    return
  EndIf
  Debug.Trace("[Kudasai] All scenes ended, stopping quest..")
  Stop()
EndFunction

Function QuestEnd()
  Debug.Trace("[Kudasai] Assault End")
  Acheron.UnregisterForActorRescued(self)
  If(KudasaiAnimation.IsAnimating(PlayerRef))
    KudasaiAnimation.StopAnimating(PlayerRef)
  EndIf
  If(Acheron.IsDefeated(PlayerRef))
    Acheron.RescueActor(PlayerRef, true)
  ElseIf(Acheron.IsPacified(PlayerRef))
    Acheron.ReleaseActor(PlayerRef)
  EndIf
  ForceStop(RefAlly1)
  ForceStop(RefAlly2)
EndFunction

Function ForceStop(ReferenceAlias akRef)
  Actor ref = akRef.GetActorReference()
  If (!ref)
    return
  EndIf
  If(KudasaiAnimation.IsAnimating(ref))
    KudasaiAnimation.StopAnimating(ref)
  EndIf
  If(Acheron.IsDefeated(ref))
    Acheron.DefeatActor(ref)
  EndIf
EndFunction

;/ Dialogue Flags /;

int Function IsWerewolf()
  If(PlayerWerewolfQuest.IsRunning())
    int ret = 1 + (Game.GetPlayer().GetRace() == WerebearRace) as int
    PlayerWerewolfQuest.SetStage(100)
    return ret
  EndIf
  return 0
EndFunction

bool Function HasInterestedActor(Actor akVictim, Actor[] akGroup)
  int i = 0
  While(i < akGroup.Length)
    If(IsValidPrime(akGroup[i], akVictim))
      return true
    EndIf
    i += 1
  EndWhile
  return false
EndFunction

bool Function IsRemembered()
  float dayspassed = Utility.GetCurrentGameTime()
  bool ret = false
  int i = 0
  While(i < GroupA.Length)
    Actor it = GroupA[i]
    If(StorageUtil.GetFloatValue(it, "Kudasai_LastDefeat", dayspassed) + 14.0 < dayspassed)
      ret = true
    EndIf
    StorageUtil.SetFloatValue(it, "Kudasai_LastDefeat", dayspassed)
    i += 1
  EndWhile
  return ret
EndFunction

bool Function IsThane()
  Form[] Holds = HoldsList.ToArray()
  If(PlayerRef.IsInLocation(Holds[0] as Location))
    return ThaneVars.EastmarchImpGetOutofJail > 0 || ThaneVars.EastmarchSonsGetOutofJail > 0
  ElseIf(PlayerRef.IsInLocation(Holds[1] as Location))
    return ThaneVars.FalkreathImpGetOutofJail > 0 || ThaneVars.FalkreathSonsGetOutofJail > 0
  ElseIf(PlayerRef.IsInLocation(Holds[2] as Location))
    return ThaneVars.HaafingarImpGetOutofJail > 0 || ThaneVars.HaafingarSonsGetOutofJail > 0
  ElseIf(PlayerRef.IsInLocation(Holds[3] as Location))
    return ThaneVars.HjaalmarchImpGetOutofJail > 0 || ThaneVars.HjaalmarchSonsGetOutofJail > 0
  ElseIf(PlayerRef.IsInLocation(Holds[4] as Location))
    return ThaneVars.PaleImpGetOutofJail > 0 || ThaneVars.PaleSonsGetOutofJail > 0
  ElseIf(PlayerRef.IsInLocation(Holds[5] as Location))
    return ThaneVars.ReachImpGetOutofJail > 0 || ThaneVars.ReachSonsGetOutofJail > 0
  ElseIf(PlayerRef.IsInLocation(Holds[6] as Location))
    return ThaneVars.RiftImpGetoutofJail > 0 || ThaneVars.RiftSonsGetOutofJail > 0
  ElseIf(PlayerRef.IsInLocation(Holds[7] as Location))
    return ThaneVars.WhiterunImpGetOutofJail > 0 || ThaneVars.WhiterunSonsGetOutofJail > 0
  ElseIf(PlayerRef.IsInLocation(Holds[8] as Location))
    return ThaneVars.WinterholdImpGetOutofJail > 0 || ThaneVars.WinterholdSonsGetOutofJail > 0
  EndIf
  return false
EndFunction

;/  UTILITY  /;

String Function IsValidPrime(Actor akActor, Actor akVictim)
  String ret = KudasaiAnimation.GetRaceType(akActor)
  If(ret != "" && MCM.AllowedRaceType(ret) && IsMatchGender(akVictim.GetActorBase().GetSex(), ret != "Human", akActor))
    return ret
  EndIf
  return ""
EndFunction

int Function GetVictimID(Actor akVictim)
  If(akVictim == PlayerRef)
    return 0
  ElseIf(akVictim == RefAlly1.GetReference())
    return 1
  Else
    return 2
  EndIf
EndFunction

Actor[] Function GetVictimGroup(int aiVictimID)
  If(aiVictimID == 0)
    return GroupA
  ElseIf(aiVictimID == 1)
    return GroupB
  Else
    return GroupC
  EndIf
EndFunction

Function AssignVictimGroup(int aiVictimID, Actor[] akNewGroup)
  If(aiVictimID == 0)
    GroupA = akNewGroup
  ElseIf(aiVictimID == 1)
    GroupB = akNewGroup
  Else
    GroupC = akNewGroup
  EndIf
EndFunction

Actor[] Function AsActorArray(ReferenceAlias[] akRefs)
  Actor[] ret = PapyrusUtil.ActorArray(akRefs.Length)
  int i = 0
  While(i < akRefs.Length)
    ret[i] = akRefs[i].GetReference() as Actor
    i += 1
  EndWhile
  return PapyrusUtil.RemoveActor(ret, none)
EndFunction

Function EvaluatePackageGroup(int aiVictimID)
  ReferenceAlias[] grp = GetVictimRefs(aiVictimID)
  int i = 0
  While(i < grp.Length)
    grp[i].TryToEvaluatePackage()
    i += 1
  EndWhile
EndFunction

ReferenceAlias[] Function GetVictimRefs(int aiVictimID)
  If(aiVictimID == 0)
    return RefsA
  ElseIf(aiVictimID == 1)
    return RefsB
  Else
    return RefsC
  EndIf
EndFunction

Function ClearAliasGroup(ReferenceAlias[] akRefs)
  int i = 0
  While(i < akRefs.Length)
    akRefs[i].TryToClear()
    i += 1
  EndWhile
EndFunction
