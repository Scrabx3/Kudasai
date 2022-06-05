Scriptname KudasaiRPlayer extends Quest Conditional

KudasaiMCM Property MCM Auto
KudasaiRPlayerAlias Property Player Auto
ReferenceAlias Property EnemyNPC Auto
ReferenceAlias[] Property Enemies Auto
ReferenceAlias[] Property Followers Auto
ReferenceAlias[] Property SecRefs Auto
ReferenceAlias[] Property TerRefs Auto
Scene[] Property Scenes Auto
{ 1: Primary Scene with Dialogue, 2+3: Simple Loop}
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
; ============= UTILITY

Function ForceRef(ReferenceAlias[] list, ObjectReference object)
  int i = 0
  While(i < list.Length)
    If(list[i].ForceRefIfEmpty(object))
      return
    EndIf
    i += 1
  EndWhile
EndFunction

; Sort _new into an empty Alias, or the one _old is occupying
Function SwapRef(ReferenceAlias[] list, ObjectReference _new, ObjectReference _old)
  int n = 0
  While(n < list.Length)
    ObjectReference ref = list[n].GetReference()
    If(!ref || ref == _old)
      list[n].ForceRefTo(_new)
      return
    EndIf
    n += 1
  EndWhile
EndFunction

Function ClearAliasByRef(ReferenceAlias[] list, ObjectReference ref)
  int i = 0
  While(i < list.Length)
    If(list[i].GetReference() == ref)
      list[i].Clear()
    EndIf
    i += 1
  EndWhile
EndFunction

; ============= STARTUP
;/
  Resolution needs to divide between Creatures & NPC
  If no adult content is allowed & the Hostile is a Creature, the Quest will cancel out
  If no adult content is allowed & the Hosile is a NPC, create a basic robbing instance
  If adult content is allowed, this will create a chain assault. NPC will gain some exclusive Dialogue
/;
Event OnUpdate()
  Debug.Trace("[Kudasai] <Assault> START")
  Actor PlayerRef = Game.GetPlayer()
  GoToState("")
  If(PlayerWerewolfQuest.IsRunning())
    IsWerewolf = 1 + ((PlayerRef.GetRace() == WerebearRace) as int)
    PlayerWerewolfQuest.SetStage(100)
  Else
    IsWerewolf = 0
  EndIf
  Thane = IsThane()
  DoAdult = MCM.FrameAny
  If(CreateAssaultGroups())
    Debug.Trace("[Kudasai] <Assault> STAGE 5")
    SetStage(5)
    return
  EndIf
  ; Fallback
  Debug.Trace("[Kudasai] <Assault> FAILED TO CREATE GROUPS")
  Kudasai.RescueActor(PlayerRef, false, true)
  Debug.SendAnimationEvent(PlayerRef, "BleedoutStop")
  Player.GoToState("Exhausted")
  Player.RegisterForSingleUpdate(11)
EndEvent

; Split the <= 20 collected Aliases into up to 3 groups, 1 Player + 2 Follower
bool Function CreateAssaultGroups()
  Actor PlayerRef = Game.GetPlayer()
  Actor[] fols = GetActors(Followers)
  Actor[] hostiles = GetActors(Enemies)
  Debug.Trace("[Kudasai] <Assault> Found Hostiles = " + hostiles)
  Debug.Trace("[Kudasai] <Assault> Found Additional Victims = " + fols)
  int numfols = fols.Length - PapyrusUtil.CountActor(fols, none)
  int numhostile = hostiles.Length - PapyrusUtil.CountActor(hostiles, none)
  If(numhostile == 0)
    return false
  EndIf
  ; Create Arrays
  int folsize = Math.floor((numhostile as float) / 3)
  int playersize = hostiles.Length - folsize * numfols
  PrimGroup = PapyrusUtil.ActorArray(playersize)
  SecGroup = PapyrusUtil.ActorArray(folsize)
  TerGroup = PapyrusUtil.ActorArray(folsize)
  ; Populate Refs
  int i = 0
  While(i < hostiles.Length)
    If(hostiles[i])
      If(Kudasai.IsDefeated(hostiles[i]))
        Kudasai.RescueActor(hostiles[i], true)
      EndIf
      int rand = Utility.RandomInt(0, 99)
      If(fols[1] && rand < 25 && TerGroup.find(none) > -1 && Kudasai.IsInterested(fols[1], hostiles[i]))
        ForceRef(TerRefs, hostiles[i])
        TerGroup[TerGroup.find(none)] = hostiles[i]
        Enemies[i].Clear()
      ElseIf(fols[0] && rand < 45 && SecGroup.find(none) > -1 && Kudasai.IsInterested(fols[0], hostiles[i]))
        ForceRef(SecRefs, hostiles[i])
        SecGroup[SecGroup.find(none)] = hostiles[i]
        Enemies[i].Clear()
      ElseIf(PrimGroup.Find(none) > -1 && Kudasai.IsInterested(PlayerRef, hostiles[i]))
        PrimGroup[PrimGroup.find(none)] = hostiles[i]
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
    return false
  EndIf
  ; Look for the closest Actor in the PrimGroup
  bool creature = MCM.FrameCreature
  Actor prim
  float d = 9999999.9
  int n = 0
  While(n < PrimGroup.Length)
    If(PrimGroup[n].HasKeyword(ActorTypeNPC))
      float d2 = PrimGroup[n].GetDistance(PlayerRef)
      If(d2 < d)
        prim = PrimGroup[n]
        d = d2
      EndIf
      creature = false
    ElseIf(creature)
      float d2 = PrimGroup[n].GetDistance(PlayerRef)
      If(d2 < d)
        prim = PrimGroup[n]
        d = d2
      EndIf
    EndIf
    n += 1
  EndWhile
  If(prim != none)
    Debug.Trace("[Kudasai] <Assault> Found Primary Actor = " + prim)
    EnemyNPC.ForceRefTo(prim)
    ; Dont waste time if thats no NPC
    If(!creature)
      Remembers = false
      float dayspassed = GameDaysPassed.Value
      int j = 0
      While(j < PrimGroup.Length)
        If(StorageUtil.GetFloatValue(PrimGroup[j], "Kudasai_LastDefeat", dayspassed) + 14.0 < dayspassed)
          Remembers = true
        EndIf
        StorageUtil.SetFloatValue(PrimGroup[j], "Kudasai_LastDefeat", dayspassed)
        j += 1
      EndWhile
    EndIf
  Else
    Debug.Trace("[Kudasai] <Assault> No Primary Actor found")
    return false
  EndIf
  ; Scene 0 will divide between 3 cases:
  ; 1. NPC + No Adult will play a quick Robbing Scene & report back into QuitCycle
  ; 2. NPC + Adult will call CreateCycle, starting a Rape Loop
  ; 3. Creature + Adult will create a Struggle Scene
  Scenes[0].Start()
  If(!Scenes[0].IsPlaying())
    Debug.Trace("[Kudasai] <Assault> Primary Scene Failed to play")
    return false
  EndIf
  totalscenes = 1
  ; Dont rob followers, I guess? So this only applies to chain rapes?
  If(DoAdult)
    If(SecGroup.Length)
      Scenes[1].Start()
      totalscenes += Scenes[1].IsPlaying() as int
      If(TerGroup.Length)
        Scenes[2].Start()
        totalscenes += Scenes[2].IsPlaying() as int
      EndIf
    EndIf
  EndIf
  Debug.Trace("[Kudasai] <Assault> Total Scenes started = " + totalscenes)
  scenecounter = Utility.CreateIntArray(3, 0)
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
    Else
      return ret
    EndIf
    i += 1
  EndWhile
  return ret
EndFunction

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
  ElseIf(positions.find(Followers[0].GetReference() as Actor) > -1)
    ; Followers cant win the Struggle
    ID = 1
  Else
    ID = 2
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
    CreateNewCycle(ID, Game.GetPlayer(), PrimGroup, true)
  ElseIf(ID == 1)
    CreateNewCycle(ID, Followers[0].GetActorReference(), SecGroup, true)
  Else
    CreateNewCycle(ID, Followers[1].GetActorReference(), TerGroup, true)
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

Function CreateNewCycle(int ID, Actor victim, Actor[] oldpositions, bool firstcycle = false)
  Debug.Trace("[Kudasai] <Assault> " + ID + " (" + Victim + "): Creating new Cycle")
  If(GetStage() > 300 || (ID != 0 && victim.GetDistance(Game.GetPlayer()) > 8192.0))
    QuitCycle(ID)
    return
  EndIf
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
  Utility.Wait(1) ; Wait for the Scene to fully shut down zzz
  If(!firstcycle) ; Stack up Scene Counter & Checkout previously animated Actors
    scenecounter[ID] = scenecounter[ID] + 1
    Debug.Trace("[Kudasai] <Assault> " + ID + ": Completed Cycles = " + scenecounter[ID] + "/" + MCM.iMaxAssaults)
    If(scenecounter[ID] == MCM.iMaxAssaults)
      QuitCycle(ID)
      return
    ElseIf(ID == 0)
      CyclesPlayer = scenecounter[ID]
    EndIf
    ; Checkout Aggressors
    int i = 0
    While(i < oldpositions.Length)
      If(oldpositions[i] != victim && (Utility.RandomFloat(0, 99.5) < MCM.fRapistQuits))
        potentials[potentials.find(oldpositions[i])] = none
      EndIf
      i += 1
    EndWhile
    potentials = PapyrusUtil.RemoveActor(potentials, none)
    If(!potentials.Length)
      Debug.Trace("[Kudasai] <Assault> " + ID + ": No Actors left to animate")
      QuitCycle(ID)
      return
    Else
      Debug.SendAnimationEvent(victim, "KudasaiTraumeLie")
      If(ID == 0)
        Game.SetPlayerAIDriven(true)
      Else
        Victim.SetDontMove(true)
      EndIf
    EndIf
  EndIf
  int max = KudasaiAnimation.GetAllowedParticipants(potentials.Length + 1) - 1
  Actor[] newpositions = PapyrusUtil.ActorArray(max)
  Debug.Trace("[Kudasai] <Assault> " + ID + ": Num Partners (max) = " + max)
  bool humanz = potentials[Utility.RandomInt(0, potentials.Length - 1)].HasKeyword(ActorTypeNPC)
  Race match
  int i = 0
  While(i < 25 && newpositions.Find(none) > -1)
    int n = Utility.RandomInt(0, potentials.Length - 1)
    If(newpositions.find(potentials[n]) == -1)
      int where = newpositions.Find(none)
      If(humanz && potentials[n].HasKeyword(ActorTypeNPC))
        newpositions[where] = potentials[n]
      Else
        Race r = potentials[n].GetRace()
        If(!match)
          match = r
        ElseIf(match == r)
          newpositions[where] = potentials[n]
        EndIf
      EndIf
    EndIf
    i += 1
  EndWhile
  Debug.Trace("[Kudasai] <Assault> " + ID + ": New Positions = " + newpositions)
  newpositions = PapyrusUtil.RemoveActor(newpositions, none)
  If(newpositions.Length)
    If(ID == 0 && humanz && !firstcycle)
      int where = Utility.RandomInt(0, newpositions.Length - 1)
      newpositions[where].Say(CycleTopic)
      Utility.Wait(3)
    EndIf
    If (KudasaiAnimation.CreateAssault(victim, newpositions, "YKrPlayer_" + ID) > -1)
      return
    EndIf
  EndIf
  Debug.Trace("[Kudasai] <Assault> " + ID + ": Failed to create Scene")
  QuitCycle(ID)
  If(ID == 0)
    Debug.Notification("Failed to create Scene")
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
  totalscenes -= 1
  Debug.Trace("[Kudasai] <Assault> QuitCycle for ID = " + ID + " Remaining Scenes = " + totalscenes)
  ; If all Stages completed, stop the Quest
  If(ID == 0)
    ; Quest ended early due to combat
    ClearGroup(Enemies)
    Utility.Wait(3)
    Player.GoToState("Exhausted")
    If(totalscenes == 0)
      Player.RegisterForSingleUpdate(13)
    EndIf
  Else
    If(totalscenes == 0)
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

