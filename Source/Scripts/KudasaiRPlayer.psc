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

Keyword Property ActorTypeNPC Auto
Quest Property ToMapEdge Auto

Actor[] PrimGroup
Actor[] SecGroup
Actor[] TerGroup
int[] scenecounter
int totalscenes = 0
int Property TotalPotentials Auto Hidden Conditional

; ============= UTILITY

Function RobVictim(Actor victim, Actor aggressor)
  Debug.Trace("[Kudasai] Robbing Victim = " + victim + " ;; Aggressor = " + aggressor)
  If(victim.GetDistance(aggressor) > 128)
    aggressor.MoveTo(victim, 80 * Math.cos(victim.Z), 80 * Math.sin(victim.Z), 0.0, false)
    aggressor.SetAngle(victim.GetAngleX(), victim.GetAngleY(), (victim.GetAngleZ() + victim.GetHeadingAngle(aggressor) - 180))
  EndIf
  Debug.SendAnimationEvent(aggressor, "KudasaiSearchBleedout")
  Utility.Wait(1.5)

  Kudasai.RemoveAllItems(victim, aggressor, MCM.bStealArmor, 100)
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
  If(CreateAssaultGroups())
    return
  EndIf
  ; Fallback
  ToMapEdge.Start()
  Stop()
EndEvent

; Split the <= 20 collected Aliases into up to 3 groups, 1 Player + 2 Follower
bool Function CreateAssaultGroups()
  If(MCM.bPostCombatAssault)
    float numfollower = GetNumFollowers()
    float hostiles = GetNumHostiles()
    If(hostiles == 0.0)
      return false
    EndIf
    ; At this point, the Quest contains only Aliases whichs references are allowed to animate
    int f = Math.Floor(hostiles * 0.3) ; with <= 20 Aliases => f <= 6
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
    Actor a1 = Enemies[0].GetReference() as Actor
    If(a1); FIXME: + TODO: && Kudasai.IsInterrested(PlayerRef, e) !IMPORTANT^
      i = 1
      fp -= 1
      PrimGroup[fp] = a1
      If(Kudasai.IsDefeated(a1))
        Kudasai.RescueActor(a1, true)
      EndIf
    EndIf
    While(i < Enemies.Length)
      Actor e = Enemies[i].GetReference() as Actor
      If(e)
        int r = Utility.RandomInt(0, 99)
        If(fol0 && ff[0] > -1 && r < 20) ; FIXME: + TODO: && Kudasai.IsInterrested(fol0, e) !IMPORTANT
          ff[0] = ff[0] - 1
          ForceRef(TerRefs, e)
          TerGroup[ff[0]] = e
          If(Kudasai.IsDefeated(e))
            Kudasai.RescueActor(e, true)
          EndIf
          Enemies[i].Clear()
        ElseIf(fol1 && ff[1] > -1 && r < 40) ; FIXME: + TODO: && Kudasai.IsInterrested(fol1.GetActorReference(), e) !IMPORTANT
          ff[1] = ff[1] - 1
          ForceRef(SecRefs, e)
          SecGroup[ff[1]] = e
          If(Kudasai.IsDefeated(e))
            Kudasai.RescueActor(e, true)
          EndIf
          Enemies[i].Clear()
        ElseIF(fp > -1) ; FIXME: + TODO: && Kudasai.IsInterrested(PlayerRef, e) !IMPORTANT
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
    EndIf
    ValidateEnemyNPC()
    Scenes[0].Start()
    If(!Scenes[0].IsPlaying())
      return false
    EndIf
    totalscenes = 1
    If(SecGroup.Length)
      Scenes[1].Start()
      If(Scenes[1].IsPlaying())
        totalscenes += 1
        CreateCycle(2)
      EndIf
      If(TerGroup.Length)
        Scenes[2].Start()
        If(Scenes[2].IsPlaying())
          totalscenes += 1
          CreateCycle(3)
        EndIf
      EndIf
    EndIf
  Else
    Scenes[0].Start()
    If(!Scenes[0].IsPlaying())
      return false
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
  int i = 0
  float ret = 0
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

Function ValidateEnemyNPC()
  If(!Enemies[0].GetReference() as Actor)
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
        return
      EndIf
      n += 1
    EndWhile
    If(nn > -1)
      Enemies[0].ForceRefTo(PrimGroup[nn])
    EndIf
  EndIf
EndFunction

; ============= ASSAULT CYCLE
; Called by Setup (ID == 2/3) OR Intro Scene (ID == 0)
Function CreateCycle(int ID)
  Actor victim
  Actor[] positions
  If(ID == 0)
    victim = Game.GetPlayer()
    positions = PrimGroup
    Actor a = EnemyNPC.GetActorReference()
    If(a)
      RobVictim(victim, a)
    EndIf
  ElseIf(ID == 1)
    victim = Followers[0].GetReference() as Actor
    positions = SecGroup
    RobVictim(victim, SecGroup[0])
  Else
    victim = Followers[1].GetReference() as Actor
    positions = TerGroup
    RobVictim(victim, TerGroup[0])
  EndIf

  scenecounter = new int[3]
  CreateNewCycle(ID, victim, positions, true)

  RegisterForModEvent("HookAnimationEnd_YKrPlayer_" + ID, "PostAssaultSL_" + ID)
  RegisterForModEvent("ostim_end", "PostAssaultOStim")
EndFunction

Event PostAssaultSL_0(int tid, bool hasPlayer)
  Debug.Trace("[Kudasai] SL End -> rPlayer ;; ID = 0")
  Actor[] positions = KudasaiAnimationSL.GetPositions(tid)
  Actor victim = KudasaiAnimationSL.GetVictim(tid)
  CreateNewCycle(0, victim, positions)
EndEvent
Event PostAssaultSL_1(int tid, bool hasPlayer)
  Debug.Trace("[Kudasai] SL End -> rPlayer ;; ID = 1")
  Actor[] positions = KudasaiAnimationSL.GetPositions(tid)
  Actor victim = KudasaiAnimationSL.GetVictim(tid)
  CreateNewCycle(1, victim, positions)
EndEvent
Event PostAssaultSL_2(int tid, bool hasPlayer)
  Debug.Trace("[Kudasai] SL End -> rPlayer ;; ID = 2")
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
  Debug.Trace("[Kudasai] OStimEnd -> rPlayer ;; Victim = " + victim)

  CreateNewCycle(ID, victim, positions)
EndEvent

; Take the 
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
    If(MCM.iMaxAssaults > 0 && scenecounter[ID] > MCM.iMaxAssaults)
      Debug.Trace("[Kudasai] Cycle hit max Iterations at Cycle Nr = " + scenecounter[ID])
      QuitCycle(ID)
      return
    EndIf
    Debug.Trace("[Kudasai] Cycle Nr = " + scenecounter[ID] + " Removing Actors; Pre Removal = " + potentials)
    ; Checkout Aggressors
    int i = 0
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
      If(ID == 0)
        Game.SetPlayerAIDriven(true)
      EndIf
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
    If(!firstcycle && ID == 0)
      Debug.Notification("Failed to create Scene")
      Debug.SendAnimationEvent(Game.GetPlayer(), "staggerStart")
      Game.SetPlayerAIDriven(false)
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
      If(!firstcycle && ID == 0)
        Debug.Notification("Failed to create Scene")
        Debug.SendAnimationEvent(Game.GetPlayer(), "staggerStart")
        Game.SetPlayerAIDriven(false)
      EndIf
    EndIf
  EndIf
EndFunction

; =============== CLEANUP

Function QuitCycle(int ID)
  SetStage(100 + 100 * ID)
  If(ID == 0)
    Player.RegisterForSingleUpdate(1)
    ClearGroup(Enemies)
  Else
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

Function CompleteCycle()
  totalscenes -= 1
  Debug.Trace("[Kudasai] Completing Cycle, remaining Cycles = " + totalscenes)
  If(totalscenes == 0)
    Stop()
  EndIf
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
