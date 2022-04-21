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

Function RobVictim(Actor victim, Actor aggressor)
  Debug.Trace("[Kudasai] Robbing Victim = " + victim + " ;; Aggressor = " + aggressor)
  If(victim.GetDistance(aggressor) > 128)
    aggressor.MoveTo(victim, 60 * Math.cos(victim.Z), 60 * Math.sin(victim.Z), 0.0, false)
    aggressor.SetAngle(victim.GetAngleX(), victim.GetAngleY(), (victim.GetAngleZ() + victim.GetHeadingAngle(aggressor) - 180))
  EndIf
  Debug.SendAnimationEvent(aggressor, "KudasaiSearchBleedout")
  Utility.Wait(1.5)

  Kudasai.RemoveAllItems(victim, aggressor, !MCM.bStealArmor)
  If(!MCM.bStealArmor)
    Armor[] wornz = Kudasai.GetWornArmor(victim, false)
    int i = 0
    While(i < wornz.length)
      victim.UnequipItem(wornz, abSilent = true)
      i += 1
    EndWhile
  EndIf
EndFunction

Function ForceRef(ReferenceAlias[] list, ObjectReference object)
  int i = 0
  While(i < list.Length)
    If(list[i].ForceRefIfEmpty(object))
      return
    EndIf
    i += 1
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
  Actor pl = Game.GetPlayer()
  If(PlayerWerewolfQuest.IsRunning())
    IsWerewolf = 1 + ((pl.GetRace() == WerebearRace) as int)
    PlayerWerewolfQuest.SetStage(100)
  Else
    IsWerewolf = 0
  EndIf
  Thane = IsThane()
  DoAdult = MCM.FrameAny
  If(CreateAssaultGroups())
    return
  EndIf
  ; Fallback
  ToMapEdge.Start()
  Stop()
EndEvent

; Split the <= 20 collected Aliases into up to 3 groups, 1 Player + 2 Follower
bool Function CreateAssaultGroups()
  float numfollower = GetNumFollowers()
  float hostiles = GetNumHostiles()
  If(hostiles == 0.0)
    return false
  EndIf
  ; At this point, the Quest contains only Aliases which are of valid Race (ie allowed to animate)
  int f = Math.Floor(hostiles * 0.3) ; with <= 20 Aliases -> { f <= 6 }
  int fp = Math.Floor(hostiles - f * numfollower)
  int[] ff = Utility.CreateIntArray(2, f)
  PrimGroup = PapyrusUtil.ActorArray(fp)
  SecGroup = PapyrusUtil.ActorArray(f)
  TerGroup = PapyrusUtil.ActorArray(f)
  ; Populate Refs
  Actor PlayerRef = Game.GetPlayer()
  Actor fol0 = Followers[0].GetReference() as Actor
  Actor fol1 = Followers[1].GetReference() as Actor
  int i = 0
  ; First Ref would be EnemyNPC. If possible, try to keep them in the Players List
  Actor a1 = Enemies[0].GetReference() as Actor
  If(a1 && Kudasai.IsInterested(PlayerRef, a1))
    i = 1
    fp -= 1
    PrimGroup[fp] = a1
    If(Kudasai.IsDefeated(a1))
      Enemies[i].RegisterForSingleUpdate(Utility.RandomInt(2, 6))
    EndIf
  EndIf
  While(i < Enemies.Length)
    Actor e = Enemies[i].GetReference() as Actor
    If(e)
      int r = Utility.RandomInt(0, 99)
      If(fol0 && ff[0] > -1 && r < 20 && Kudasai.IsInterested(fol0, e))
        ff[0] = ff[0] - 1
        ForceRef(TerRefs, e)
        TerGroup[ff[0]] = e
        If(Kudasai.IsDefeated(e))
          Kudasai.RescueActor(e, true)
        EndIf
        Enemies[i].Clear()
      ElseIf(fol1 && ff[1] > -1 && r < 40 && Kudasai.IsInterested(fol1, e))
        ff[1] = ff[1] - 1
        ForceRef(SecRefs, e)
        SecGroup[ff[1]] = e
        If(Kudasai.IsDefeated(e))
          Kudasai.RescueActor(e, true)
        EndIf
        Enemies[i].Clear()
      ElseIF(fp > -1 && Kudasai.IsInterested(PlayerRef, e))
        fp -= 1
        PrimGroup[fp] = e
        If(Kudasai.IsDefeated(e))
          Enemies[i].RegisterForSingleUpdate(Utility.RandomInt(2, 6))
        EndIf
      Else
        Enemies[i].Clear()
      EndIf
    EndIf
    i += 1
  EndWhile
  PrimGroup = PapyrusUtil.RemoveActor(PrimGroup, none)
  SecGroup = PapyrusUtil.RemoveActor(SecGroup, none)
  TerGroup = PapyrusUtil.RemoveActor(TerGroup, none)
  Debug.Trace("[Kudasai] Prim = " + PrimGroup)
  Debug.Trace("[Kudasai] Sec = " + SecGroup)
  Debug.Trace("[Kudasai] Ter = " + TerGroup)
  ; All Aliases should be either cleared or divided into up to 3 Groups of interst
  ; Start the individual Scenes now & create the shut down Condition
  If(!PrimGroup.Length)
    return false
  ElseIf(ValidateEnemyNPC() != none)
    ; No point to set this if there is no NPC in this Group
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
  ElseIf(!DoAdult)
    ; If there are no NPC and Adult Content isnt permitted, cancel the Quest & throw the Player to entrance
    ; I got no SFW Content for Creatures here
    return false
  EndIf
  ; Scene 0 will properly divide between the 3 remaining cases:
  ; NPC + No Adult will play a quick Robbing Scene & report back into QuitCycle
  ; NPC + Adult will call CreateCycle, starting a Rape Loop
  ; Creature + Adult will create a Struggle Scene
  Scenes[0].Start()
  If(!Scenes[0].IsPlaying())
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

  return true
EndFunction

float Function GetNumFollowers()
  int i = 0
  While(i < Followers.Length)
    If(Followers[i].GetReference() == none)
      return i
    EndIf
    i += 1
  EndWhile
  return i
EndFunction

; Count the Number of Hostile Actors that are allowed to animate and clear all Aliases that arent allowed to animate
float Function GetNumHostiles()
  float ret = ((Enemies[0].GetReference() as Actor) != none) as int
  int i = 1
  While(i < Enemies.Length)
    Actor that = Enemies[i].GetReference() as Actor
    If(!that)
      return ret
    EndIf
    If(that.HasKeyword(ActorTypeNPC) || (MCM.FrameCreature && Kudasai.ValidRace(that)))
      ret += 1.0
    Else
      Enemies[i].Clear()
    EndIf
    i += 1
  EndWhile
  return ret
EndFunction

Actor Function ValidateEnemyNPC()
  Actor a0 = Enemies[0].GetReference() as Actor
  If(!a0)
    Actor PlayerRef = Game.GetPlayer()
    float d = 9999999.9
    If(PrimGroup[0].Haskeyword(ActorTypeNPC))
      d = PrimGroup[0].GetDistance(PlayerRef)
    EndIf
    int n = 1
    int nn = -1
    While(n < PrimGroup.Length)
      If(PrimGroup[n].HasKeyword(ActorTypeNPC))
        float d2 = PrimGroup[n].GetDistance(PlayerRef)
        If(d2 < d)
          nn = n
          d = d2
        EndIf
      EndIf
      n += 1
    EndWhile
    If(nn > -1)
      Enemies[0].ForceRefTo(PrimGroup[nn])
      return PrimGroup[nn]
    Else
      return none
    EndIf
  Else
    return a0
  EndIf
EndFunction

; ============= STRUGGLE CYCLE
; For Followers, all Assaults link into this first
; For player, this is called for pure Creature encounters
Function CreateStruggle(int ID)
  Actor aggressor = none
  Actor victim
  int difficulty
  If(ID == 0)
    ; For the Player, this is only called for pure creature encounters
    aggressor = PrimGroup[0]
    victim = Game.GetPlayer()
    difficulty = 1 + ((PrimGroup.Length > 3) as int) + ((victim.GetActorValuePercentage("Health") < 0.5) as int)
  Else
    Actor[] positions
    If(ID == 1)
      positions = SecGroup
      victim = Followers[0].GetReference() as Actor
    Else
      positions = TerGroup
      victim = Followers[1].GetReference() as Actor
    EndIf
    ; Check if there are NPC in this Group, if not use Creatures
    int i = 0
    While(i < positions.Length)
      If(positions[i].HasKeyword(ActorTypeNPC))
        aggressor = positions[i]
        i = positions.Length
      Else
        i += 1
      EndIf
    EndWhile
    If(!aggressor)
      aggressor = positions[0]
    EndIf
    ; Make Followers always lose the struggle zz
    difficulty = 0
  EndIf

  Kudasai.CreateStruggle(victim, aggressor, difficulty, self)
EndFunction

Event OnStruggleEnd_c(Actor[] positions, bool VictimWon)
  Debug.Trace("[Kudasai] rPlayer -> Struggle End (Callback)")
  int ID
  Actor PlayerRef = Game.GetPlayer()
  If(positions.find(PlayerRef) > -1)
    If(VictimWon)
      Kudasai.PlayBreakfree(positions)
      Kudasai.RescueActor(PlayerRef, false)
      GoToState("Breakfree")
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
  Kudasai.PlayBreakfreeCustom(positions, anims)
  ; Derived from SLF
  Debug.SendAnimationEvent(positions[1], "ReturnDefaultState") ; for chicken, hare and slaughterfish before the "ReturnToDefault"
  Debug.SendAnimationEvent(positions[1], "ReturnToDefault") ; the rest creature-animal
  Debug.SendAnimationEvent(positions[1], "FNISDefault") ; for dwarvenspider and chaurus
  Debug.SendAnimationEvent(positions[1], "IdleReturnToDefault") ; for Werewolves and VampirwLords
  Debug.SendAnimationEvent(positions[1], "ForceFurnExit") ; for Trolls afther the "ReturnToDefault" and draugr, daedras and all dwarven exept spiders
  Debug.SendAnimationEvent(positions[1], "Reset") ; for Hagravens afther the "ReturnToDefault" and Dragons
  If(GetState() != "Breakfree")
    CreateCycle(ID)
  EndIf
EndEvent
State Breakfree
  Event OnBeginState()
    RegisterForSingleUpdate(5)
  EndEvent
  Event OnUpdate()
    Actor fol0 = Followers[0].GetReference() as Actor
    If(fol0 && Kudasai.IsStruggling(fol0))
      Kudasai.StopStruggle(fol0)
    EndIf
    Actor fol1 = Followers[1].GetReference() as Actor
    If(fol1 && Kudasai.IsStruggling(fol1))
      Kudasai.StopStruggle(fol1)
    EndIf
    Stop()
  EndEvent
EndState

; ============= ASSAULT CYCLE
; Called by Setup (ID == 2/3) OR Intro Scene (ID == 0)
Function CreateCycle(int ID)
  Actor victim
  Actor[] positions
  If(ID == 0)
    victim = Game.GetPlayer()
    positions = PrimGroup
  ElseIf(ID == 1)
    victim = Followers[0].GetReference() as Actor
    positions = SecGroup
  Else
    victim = Followers[1].GetReference() as Actor
    positions = TerGroup
  EndIf

  scenecounter = new int[3]
  CreateNewCycle(ID, victim, positions, true)

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
  If(victim == none)
    return
  EndIf

  CreateNewCycle(ID, victim, positions)
EndEvent

Function CreateNewCycle(int ID, Actor victim, Actor[] oldpositions, bool firstcycle = false)
  Debug.Trace("[Kudasai] Creating new Cycle for ID = " + ID + " With Victim = " + Victim + " old positions = " + oldpositions)
  ; If player is too far away or a Shutdown Stage is set, dont start a new Scene
  If(GetStage() > 300 || (ID != 0 && victim.GetDistance(Game.GetPlayer()) > 8192.0))
    QuitCycle(ID)
    return
  EndIf
  ; How much I wish thered be multidimensional arrays rn :<
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
  ; Not the first cycle? Count up, check if a new should start & checkout aggressors
  If(!firstcycle)
    scenecounter[ID] = scenecounter[ID] + 1
    Debug.Trace("[Kudasai] Cycle Nr = " + scenecounter[ID])
    If(ID == 0)
      CyclesPlayer = scenecounter[ID]
    EndIf
    If(MCM.iMaxAssaults > 0 && scenecounter[ID] == MCM.iMaxAssaults - 1)
      Debug.Trace("[Kudasai] Cycle hit max Iterations at Cycle Nr = " + scenecounter[ID])
      QuitCycle(ID)
      return
    EndIf
    Debug.Trace("[Kudasai] Removing Actors; Pre Removal = " + potentials)
    ; Checkout Aggressors
    int i = 1 ; i = 0 is Victim, dont wanna checkout that
    While(i < oldpositions.Length)
      If(Utility.RandomFloat(0, 99.5) < MCM.fRapistQuits)
        int where = potentials.find(oldpositions[i])
        potentials[where] = none
      EndIf
      i += 1
    EndWhile
    Debug.Trace("[Kudasai] Post Removal = " + potentials)
    potentials = PapyrusUtil.RemoveActor(potentials, none)

    If(!potentials.Length)
      Debug.Trace("[Kudasai] No Actors left to animate")
      QuitCycle(ID)
      return
    Else
      Debug.SendAnimationEvent(victim, "KudasaiTraumeLie")
      Game.SetPlayerAIDriven(true)
    EndIf
  EndIf

  int max = KudasaiAnimation.GetAllowedParticipants(potentials.Length + 1) - 1
  Actor[] newpositions = PapyrusUtil.ActorArray(max)
  Debug.Trace("[Kudasai] Creating Scene for ID = " + ID + " with Num Partners (max) = " + max)

  bool humanz = potentials[Utility.RandomInt(0, potentials.Length - 1)].HasKeyword(ActorTypeNPC)
  Race match
  int i = 0
  While(i < 50 && newpositions.Find(none) > -1)
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
  Debug.Trace("[Kudasai] Found Actors = " + newpositions)
  newpositions = PapyrusUtil.RemoveActor(newpositions, none)

  If(!newpositions.Length)
    QuitCycle(ID)
    If(ID == 0)
      Debug.Notification("Failed to create Scene")
    EndIf
  Else
    If(ID == 0 && humanz && !firstcycle)
      int where = Utility.RandomInt(0, newpositions.Length - 1)
      newpositions[where].Say(CycleTopic)
    EndIf
    Utility.Wait(Utility.RandomFloat(2, 5))
    If (KudasaiAnimation.CreateAssault(victim, newpositions, "YKrPlayer_" + ID) == -1)
      Debug.Trace("[Kudasai] Failed to create Scene")
      QuitCycle(ID)
      If(ID == 0)
        Debug.Notification("Failed to create Scene")
      EndIf
    EndIf
  EndIf
EndFunction

; =============== CLEANUP

Function QuitCycle(int ID)
  ; No longer Setting Stage for Player, so the NPC stay around clapping until the Quest ends & the player is ported
  If(ID == 0)
    Debug.SendAnimationEvent(Game.GetPlayer(), "bleedoutStart")
    ; Player.GoToState("Exhausted") ; Porting anyway, no need for a "getaway" timer
    ToMapEdge.Start()
    Stop()
  Else
    SetStage(100 + 100 * ID)
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

