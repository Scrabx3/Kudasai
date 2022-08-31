Scriptname KudasaiRPlayer extends Quest Conditional

KudasaiMCM Property MCM Auto
KudasaiRPlayerAlias Property Player Auto
ReferenceAlias Property EnemyNPC Auto
ReferenceAlias[] Property Enemies Auto
ReferenceAlias[] Property Followers Auto
ReferenceAlias[] Property SecRefs Auto
ReferenceAlias[] Property TerRefs Auto
Scene[] Property Scenes Auto
{1: Primary Scene with Dialogue, 2+3: Simple Loop}
Topic Property CycleTopic Auto

FavorJarlsMakeFriendsScript Property ThaneVars Auto
Race Property WerebearRace Auto
Quest Property PlayerWerewolfQuest Auto
Quest Property ToMapEdge Auto
Keyword Property ActorTypeNPC Auto
GlobalVariable Property GameDaysPassed Auto
FormList Property HoldsList Auto

Actor[] PrimGroup
Actor[] SecGroup
Actor[] TerGroup
int[] scenecounter
int totalscenes = 0

int Property IsWerewolf Auto Hidden Conditional
{0 = No Werewolf, 1 = Werewolf, 2 = Werebear}
bool Property Thane Auto Hidden Conditional
bool Property DoAdult Auto Hidden Conditional
bool Property Remembers Auto Hidden Conditional
int Property CyclesPlayer Auto Hidden Conditional

; ============= STARTUP
;/
  Resolution needs to divide between Creatures & NPC
  If no adult content is allowed & the Hostile is a Creature, the Quest will cancel out
  If no adult content is allowed & the Hosile is a NPC, create a basic robbing instance
  If adult content is allowed, this will create a chain assault. NPC will gain some exclusive Dialogue
/;
Event OnUpdate()
  Debug.Trace("[Kudasai] <Assault> START")
  SetDialogueFlags()
  If(CreateAssaultGroups())
    Debug.Trace("[Kudasai] <Assault> STAGE 5")
    Kudasai.RegisterForActorDefeated(self)
    SetStage(5)
    int i = 0
    While(i < Enemies.Length)
      Actor it = Enemies[i].GetActorReference()
      If(it)
        it.EvaluatePackage()
      EndIf
      i += 1
    EndWhile
    return
  EndIf
  ; Fallback
  Debug.Trace("[Kudasai] <Assault> FAILED TO CREATE GROUPS")
  Debug.Notification("Failed to create Assault Groups..")
  Kudasai.RescueActor(Game.GetPlayer(), false)
  totalscenes = 1
  Player.GoToState("Exhausted")
EndEvent

bool Function IsInterested(Actor akSubject, Actor akTarget)
  return akSubject.GetDistance(akTarget) < 2048.0 && Kudasai.IsInterested(akSubject, akTarget)
EndFunction

; Split the <= 20 collected Aliases into up to 3 groups, 1 Player + 2 Follower
bool Function CreateAssaultGroups()
  Actor PlayerRef = Game.GetPlayer()
  Actor[] Hosts = GetActors(Enemies)
  Actor[] Fols = GetActors(Followers)
  Debug.Trace("[Kudasai] <Assault> Found Hostiles = " + Hosts)
  Debug.Trace("[Kudasai] <Assault> Found Additional Victims = " + Fols)
  int nHostiles = Hosts.Length - PapyrusUtil.CountActor(Hosts, none)
  int nFollowers = Fols.Length - PapyrusUtil.CountActor(Fols, none)
  If(!Hosts.Length)
    return false
  EndIf
  ; Create Arrays, max <= 6
  int max = nHostiles / (1 + nFollowers)
  PrimGroup = PapyrusUtil.ActorArray(max + (nHostiles % (1 + nFollowers)))
  SecGroup = PapyrusUtil.ActorArray(max)
  TerGroup = PapyrusUtil.ActorArray(max)
  ; Populate Refs
  int i = 0
  While(i < Hosts.Length)
    Actor it = Hosts[i]
    If(it)
      If(Kudasai.IsDefeated(it))
        Kudasai.RescueActor(it, true)
      EndIf
      If(IsInterested(it, PlayerRef) && PrimGroup.Find(none) > -1)
        int where = PrimGroup.Find(none)
        PrimGroup[where] = it
      ElseIf(Fols[0] && IsInterested(it, Fols[0]) && SecGroup.Find(none) > -1)
        int where = SecGroup.Find(none)
        SecRefs[where].ForceRefTo(it)
        SecGroup[where] = it
        Enemies[i].Clear()
      ElseIf(Fols[1] && IsInterested(it, Fols[1]) && TerGroup.Find(none) > -1)
        int where = TerGroup.Find(none)
        TerRefs[where].ForceRefTo(it)
        TerGroup[where] = it
        Enemies[i].Clear()
      Else
        Enemies[i].Clear()
      EndIf
    EndIf
    i += 1
  EndWhile
  PrimGroup = PapyrusUtil.RemoveActor(PrimGroup, none)
  SecGroup = PapyrusUtil.RemoveActor(SecGroup, none)
  TerGroup = PapyrusUtil.RemoveActor(TerGroup, none)
  Debug.Trace("[Kudasai] <Assault> Prim = " + PrimGroup)
  Debug.Trace("[Kudasai] <Assault> Sec = " + SecGroup)
  Debug.Trace("[Kudasai] <Assault> Ter = " + TerGroup)
  ; From here, all Aliases are sorted into the 3 Groups. Leftovers will simply "spectate" the Player
  If(!PrimGroup.Length)
    Debug.Trace("[Kudasai] <Assault> Primary Group is empty")
    return false
  EndIf
  Actor lead = GetLeadingActor()
  If(!lead)
    Debug.Trace("[Kudasai] <Assault> No Primary Actor found")
    return false
  EndIf
  Debug.Trace("[Kudasai] <Assault> Found Primary Actor = " + lead)
  EnemyNPC.ForceRefTo(lead)
  If(lead.HasKeyword(ActorTypeNPC))
    Remembers = false
    float dayspassed = GameDaysPassed.Value
    int j = 0
    While(j < PrimGroup.Length)
      If(PrimGroup[i].GetLeveledActorBase().IsUnique())
        If(StorageUtil.GetFloatValue(PrimGroup[j], "Kudasai_LastDefeat", dayspassed) + 14.0 < dayspassed)
          Remembers = true
        EndIf
        StorageUtil.SetFloatValue(PrimGroup[j], "Kudasai_LastDefeat", dayspassed)
      EndIf
      j += 1
    EndWhile
  EndIf
  Scenes[0].Start()
  If(!Scenes[0].IsPlaying())
    Debug.Trace("[Kudasai] <Assault> Primary Scene Failed to play")
    return false
  EndIf
  totalscenes = 1
  If(MCM.FrameAny && SecGroup.Length)
    Scenes[1].Start()
    totalscenes += Scenes[1].IsPlaying() as int
    If(TerGroup.Length)
      Scenes[2].Start()
      totalscenes += Scenes[2].IsPlaying() as int
    EndIf
  EndIf
  Debug.Trace("[Kudasai] <Assault> Total Scenes started = " + totalscenes)
  scenecounter = new int[3]
  return true
EndFunction

Actor[] Function GetActors(ReferenceAlias[] reflist)
  Actor[] ret = PapyrusUtil.ActorArray(reflist.Length)
  int i = 0
  While(i < reflist.Length)
    Actor subject = reflist[i].GetReference() as Actor
    If(subject)
      If(subject.HasKeyword(ActorTypeNPC) || MCM.FrameCreature && Kudasai.ValidRace(subject))
        ret[i] = subject
      Else
        reflist[i].Clear()
      EndIf
      i += 1
    Else
      i = reflist.Length
    EndIf
  EndWhile
  return ret
EndFunction

Actor Function GetLeadingActor()
  Kudasai.SortByDistance(PrimGroup, Game.GetPlayer())
  int i = 0
  While(i < PrimGroup.Length)
    If(PrimGroup[i].HasKeyword(ActorTypeNPC))
      return PrimGroup[i]
    EndIf
    i += 1
  EndWhile
  If(MCM.FrameCreature)
    return PrimGroup[0]
  EndIf
  return none
EndFunction

Actor[] Function GetFollowers()
  Actor[] fols = Kudasai.GetFollowers()
  int i = 0
  While(i < fols.Length)
    If(!fols[i].Is3DLoaded())
      fols[i] = none
    EndIf
    i += 1
  EndWhile
  fols = PapyrusUtil.RemoveActor(fols, none)
  return PapyrusUtil.MergeActorArray(fols, GetActors(Followers), true)
EndFunction

Function SetDialogueFlags()
  If(PlayerWerewolfQuest.IsRunning())
    IsWerewolf = 1 + ((Game.GetPlayer().GetRace() == WerebearRace) as int)
    PlayerWerewolfQuest.SetStage(100)
  Else
    IsWerewolf = 0
  EndIf
  Thane = IsThane()
  DoAdult = MCM.FrameAny
EndFunction

Event OnActorDefeated(Actor akVictim)
  int where = PrimGroup.Find(akVictim)
  If(where > -1)
    PrimGroup = PapyrusUtil.RemoveActor(PrimGroup, akVictim)
    return
  EndIf
  where = SecGroup.Find(akVictim)
  If(where > -1)
    PrimGroup = PapyrusUtil.RemoveActor(SecGroup, akVictim)
    return
  EndIf
  where = TerGroup.Find(akVictim)
  If(where > -1)
    PrimGroup = PapyrusUtil.RemoveActor(TerGroup, akVictim)
    return
  EndIf
EndEvent

; ============= STRUGGLE CYCLE
; For Followers, all Assaults link into this first
; For player, this is called for pure Creature encounters
Function CreateStruggle(int ID)
  Actor[] positions = new Actor[2]
  int difficulty
  If(ID == 0)
    ; For the Player, this is only called for pure creature encounters
    positions[0] = Game.GetPlayer()
    positions[1] = PrimGroup[0]
    difficulty = (100 - (positions[0].GetActorValuePercentage("Health") * 100) - PrimGroup.Length * 10 + 10) as int
  Else
    Actor[] tmp
    If(ID == 1)
      tmp = SecGroup
      positions[0] = Followers[0].GetReference() as Actor
    Else
      tmp = TerGroup
      positions[0] = Followers[1].GetReference() as Actor
    EndIf
    ; Check if there are NPC in this Group, if not use Creatures
    int i = 0
    While(i < tmp.Length)
      If(tmp[i].HasKeyword(ActorTypeNPC))
        positions[1] = tmp[i]
        i = tmp.Length
      Else
        i += 1
      EndIf
    EndWhile
    If(!positions[1])
      positions[1] = tmp[0]
    EndIf
    ; Make Followers always lose the struggle zz
    difficulty = 0
  EndIf
  Debug.Trace("[Kudasai] <Assault> Beginning Struggle for ID = " + ID + " ( " + positions + " ) Difficulty = " + difficulty)
  If(!KudasaiStruggle.CreateStruggle(positions, difficulty, self))
    Debug.Trace("[Kudasai] <Assault> Failed to begin Struggle, skipping to Assault")
    CreateCycle(ID)
  EndIf
EndFunction

Event OnFuture_c(Actor[] positions, int victory, String argStr)
  Debug.Trace("[Kudasai] <Assault> Struggle End (Callback)")
  int ID
  Actor PlayerRef = Game.GetPlayer()
  If(positions.find(PlayerRef) > -1)
    If(victory)
      KudasaiStruggle.EndStruggle(positions, victory)
      Kudasai.RescueActor(PlayerRef, false, true)
      GoToState("Breakfree")
      Utility.Wait(5)
      Stop()
      return
    EndIf
    ID = 0
  Else  ; Followers cant win the Struggle
    If(positions.find(Followers[0].GetActorReference()) > -1)
      ID = 1
    Else
      ID = 2
    EndIf
  EndIf
  String[] anims = new String[2]
  anims[0] = "BleedoutStart"
  anims[1] = "IdleForceDefaultState"
  KudasaiStruggle.EndStruggleCustom(positions, anims)
  Debug.SendAnimationEvent(positions[1], "ReturnToDefault")
  If(GetState() == "")
    CreateCycle(ID)
  EndIf
EndEvent

State Breakfree
EndState

; ============= ASSAULT CYCLE
; Called by Setup (ID == 2/3) OR Intro Scene (ID == 0)
Function CreateCycle(int ID)
  Actor victim
  Actor[] positions
  If(ID == 0)
    CreateNewCycle(ID, Game.GetPlayer(), firstcycle = true)
  ElseIf(ID == 1)
    CreateNewCycle(ID, Followers[0].GetActorReference(), firstcycle = true)
  Else
    CreateNewCycle(ID, Followers[1].GetActorReference(), firstcycle = true)
  EndIf
  RegisterForModEvent("HookAnimationEnd_YKrPlayer_" + ID, "PostAssaultSL_" + ID)
  RegisterForModEvent("ostim_end", "PostAssaultOStim")
EndFunction

Event PostAssaultSL_0(int tid, bool hasPlayer)
  Actor[] positions = KudasaiAnimationSL.GetPositions(tid)
  Actor victim = KudasaiAnimationSL.GetVictim(tid)
  CreateNewCycle(0, victim, positions)
EndEvent
Event PostAssaultSL_1(int tid, bool hasPlayer)
  Actor[] positions = KudasaiAnimationSL.GetPositions(tid)
  Actor victim = KudasaiAnimationSL.GetVictim(tid)
  CreateNewCycle(1, victim, positions)
EndEvent
Event PostAssaultSL_2(int tid, bool hasPlayer)
  Actor[] positions = KudasaiAnimationSL.GetPositions(tid)
  Actor victim = KudasaiAnimationSL.GetVictim(tid)
  CreateNewCycle(2, victim, positions)
EndEvent
Event PostAssaultOStim(string asEventName, string asStringArg, float afNumArg, form akSender)
  Actor[] positions = KudasaiAnimationOStim.GetPositions(afNumArg as int)
  Actor victim
  int ID
  If (positions.find(Game.GetPlayer()) > -1)
    victim = Game.GetPlayer()
    ID = 0
  ElseIf(positions.find(Followers[0].GetActorReference()) > -1)
    victim = Followers[0].GetReference() as Actor
    ID = 1
  ElseIf(positions.find(Followers[1].GetActorReference()) > -1)
    victim = Followers[1].GetReference() as Actor
    ID = 2
  EndIf
  If(!victim)
    return
  EndIf
  CreateNewCycle(ID, victim, positions)
EndEvent

Function CreateNewCycle(int ID, Actor victim, Actor[] oldpositions = none, bool firstcycle = false)
  If(GetStage() > 300 || (ID != 0 && victim.GetDistance(Game.GetPlayer()) > 2048.0))
    QuitCycle(ID)
    return
  EndIf
  Debug.Trace("[Kudasai] <Assault> " + ID + ": Creating new Cycle | Victim = " + Victim)
  Actor[] potentials
  ReferenceAlias[] list
  If(ID == 0)
    list = Enemies
    potentials = PrimGroup
  ElseIf(ID == 1)
    list = SecRefs
    potentials = SecGroup
  Else
    list = TerRefs
    potentials = TerGroup
  EndIf
  If(!firstcycle) 
    ; Not first Cycle, add Scene Counter
    scenecounter[ID] = scenecounter[ID] + 1
    Debug.Trace("[Kudasai] <Assault> " + ID + ": Completed Cycles = " + scenecounter[ID] + "/" + MCM.iMaxAssaults)
    If(MCM.iMaxAssaults <= scenecounter[ID])
      QuitCycle(ID)
      return
    ElseIf(ID == 0)
      CyclesPlayer = scenecounter[ID]
    EndIf
    ; .. remove actors part of the previous Scene
    int i = 0
    While(i < oldpositions.Length)
      If(oldpositions[i] != victim && Utility.RandomFloat(0, 99.5) < MCM.fRapistQuits)
        int where = potentials.find(oldpositions[i])
        potentials[where] = none
      EndIf
      i += 1
    EndWhile
    potentials = PapyrusUtil.RemoveActor(potentials, none)
    If(!potentials.Length)
      Debug.Trace("[Kudasai] <Assault> " + ID + ": No Actors left to animate")
      QuitCycle(ID)
      return
    EndIf
    Debug.SendAnimationEvent(victim, "BleedoutStart")
    If(ID == 0)
      Game.SetPlayerAIDriven(true)
      PrimGroup = potentials
    Else
      Victim.SetDontMove(true)
      If(ID == 1)
        SecGroup = potentials
      Else
        TerGroup = potentials
      EndIf
    EndIf
  EndIf
  int max = KudasaiAnimation.GetAllowedParticipants(potentials.Length + 1) - 1
  Actor[] newpositions = PapyrusUtil.ActorArray(max)
  bool humanz = potentials[Utility.RandomInt(0, potentials.Length - 1)].HasKeyword(ActorTypeNPC)
  Race match
  int i = 0
  While(i < 25 && newpositions.Find(none) > -1)
    int n = Utility.RandomInt(0, potentials.Length - 1)
    If(newpositions.find(potentials[n]) == -1)
      Actor it = potentials[n]
      If(it.Is3DLoaded() && !it.IsInCombat() && !it.IsDead() && it.GetDistance(victim) <= 1024.0 && !Kudasai.IsDefeated(it))
        int where = newpositions.Find(none)
        If(humanz)
          If(potentials[n].HasKeyword(ActorTypeNPC))
            newpositions[where] = potentials[n]
          EndIf
        Else
          Race r = potentials[n].GetRace()
          If(!match)
            match = r
          ElseIf(match == r)
            newpositions[where] = potentials[n]
          EndIf
        EndIf
      EndIf
    EndIf
    i += 1
  EndWhile
  Debug.Trace("[Kudasai] <Assault> " + ID + ": New Positions = " + newpositions)
  newpositions = PapyrusUtil.RemoveActor(newpositions, none)
  If(!newpositions.Length)
    Debug.Trace("[Kudasai] <Assault> " + ID + ": Failed to find new Positions for Scene")
    QuitCycle(ID)
    return
  EndIf
  If(ID == 0 && humanz && !firstcycle)
    int where = Utility.RandomInt(0, newpositions.Length - 1)
    newpositions[where].Say(CycleTopic)
    Utility.Wait(3)
  EndIf
  If (KudasaiAnimation.CreateAssault(victim, newpositions, "YKrPlayer_" + ID) == -1)
    Debug.Trace("[Kudasai] <Assault> " + ID + ": Failed to create Scene")
    QuitCycle(ID)
    If(ID == 0)
      Debug.Notification("Failed to create Scene")
    EndIf
  EndIf
EndFunction

; =============== CLEANUP

; Called when the Scene Loop no longer continues for w/e reason or the associated Scene ends
Function QuitCycle(int ID)
  int stage = 100 + 100 * ID
  If(GetStageDone(stage))
    return
  ElseIf(GetStage() > 300)
    Debug.Trace("[Kudasai] <Assault> QuitCycle for ID = " + ID + " -> Stage > 300")
    return
  EndIf
  SetStage(stage)
  Debug.Trace("[Kudasai] <Assault> QuitCycle for ID = " + ID + " Remaining Scenes = " + totalscenes)
  If(ID == 0)
    ; exhaust state will complete player scene
    ClearGroup(Enemies)
    Utility.Wait(3)
    Player.GoToState("Exhausted")
  Else
    totalscenes -= 1
    If(totalscenes <= 0)
      Stop()
      return
    EndIf
    Actor victim = Followers[ID - 1].GetReference() as Actor
    Debug.SendAnimationEvent(victim, "bleedoutStart")
    If(ID == 1)
      ClearGroup(SecRefs)
    Else
      ClearGroup(TerRefs)
    EndIf
  EndIf
EndFunction

Function CompletePlayerCycle()
  ResetPlayerStatus()
  totalscenes -= 1
  If(totalscenes <= 0)
    Stop()
  EndIf
EndFunction

Function ClearGroup(ReferenceAlias[] group)
  int i = 0
  While(i < group.Length)
    group[i].TryToClear()
    i += 1
  EndWhile
EndFunction

Function ForceStopScenes()
  Actor follower0 = Followers[0].GetActorReference()
  Actor follower1 = Followers[1].GetActorReference()
  KudasaiAnimation.StopAnimating(Game.GetPlayer(), MCM)
  If(follower0)
    KudasaiAnimation.StopAnimating(follower0, MCM)
    Debug.SendAnimationEvent(follower0, "bleedoutStart")
  EndIf
  If(follower1)
    KudasaiAnimation.StopAnimating(follower1, MCM)
    Debug.SendAnimationEvent(follower1, "bleedoutStart")
  EndIf
EndFunction

; Called when the Quest stops for good
Function AssaultEnd()
  Debug.Trace("[Kudasai] <Assault> STOP QUEST")
  GoToState("")
  ForceStopScenes()
  ResetPlayerStatus()
EndFunction

Function ResetPlayerStatus()
  Actor PlayerRef = Game.GetPlayer()
  If(Kudasai.IsDefeated(PlayerRef))
    Kudasai.RescueActor(PlayerRef, true)
  ElseIf(Kudasai.IsPacified(PlayerRef))
    Kudasai.UndoPacify(PlayerRef)
  EndIf
EndFunction

; ------------ Util

bool Function IsThane()
  Actor PlayerRef = Game.GetPlayer()
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

