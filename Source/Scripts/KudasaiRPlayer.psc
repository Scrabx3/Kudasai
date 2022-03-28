Scriptname KudasaiRPlayer extends Quest Conditional

KudasaiMCM Property MCM Auto
KudasaiRPlayerAlias Property Player Auto
ReferenceAlias Property EnemyNPC Auto
ReferenceAlias[] Property Enemies Auto
ReferenceAlias[] Property Followers Auto

ReferenceAlias[] Property SecRefs Auto
ReferenceAlias[] Property TerRefs Auto
Scene Property Scene01 Auto ; NPC Scene, walking up to Player & talking to them
Scene Property Scene02 Auto ; Simple Assault Scene for the 1st Follower
Scene Property Scene03 Auto ; Simple Assault Scene for the 2nd Follower
Topic Property CycleTopic Auto

Keyword Property ActorTypeNPC Auto
Quest Property ToMapEdge Auto

Actor[] PrimGroup
Actor[] SecGroup
Actor[] TerGroup
int[] scenecounter
int totalscenes = 0
int Property TotalPotentials Auto Hidden Conditional

Function RobVictim(Actor victim, Actor aggressor)
  If(victim.GetDistance(aggressor) > 200)
    aggressor.MoveTo(victim, 120 * Math.cos(victim.Z), 120 * Math.sin(victim.Z), 0.0, false)
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


; ============= ASSAULT CYCLE
Function CreateCycle(int ID)
  Actor victim
  Actor[] positions
  If(ID == 0)
    victim = Game.GetPlayer()
    positions = PrimGroup
    RobVictim(victim, EnemyNPC.GetActorReference())
  ElseIf(ID == 1)
    victim = Followers[0].GetReference() as Actor
    positions = SecGroup
    RobVictim(victim, SecGroup[0])
  Else
    victim = Followers[0].GetReference() as Actor
    positions = TerGroup
    RobVictim(victim, TerGroup[0])
  EndIf

  scenecounter = new int[3]
  CreateNewCycle(victim, positions, true)

  RegisterForModEvent("HookAnimationEnd_YKrPlayer_" + ID, "PostAssaultSL_" + ID)
  RegisterForModEvent("ostim_end", "PostAssaultOStim")
EndFunction

Function CreateNewCycle(Actor victim, Actor[] positions, bool firstcycle = false)
  int ID
  If(victim == Game.GetPlayer())
    ID = 0
  ElseIf(victim == Followers[0].GetReference())
    ID = 1
  Else
    ID = 2
  EndIf
  If(GetStage() > 300 || (ID != 0 && victim.GetDistance(Game.GetPlayer()) > 8192.0))
    QuitCycle(ID, positions)
    return
  EndIf
  If(!firstcycle)
    scenecounter[ID] = scenecounter[ID] + 1
    If(MCM.iMaxAssaults > 0 && scenecounter[ID] > MCM.iMaxAssaults)
      QuitCycle(ID, positions)
      return
    EndIf
    ; Remove Actors that got 'bored'
    Actor[] potentials
    ReferenceAlias[] list
    If(ID == 0)
      list = Enemies
    ElseIf(ID == 1)
      list = SecRefs
    Else
      list = TerRefs
    EndIf
    If(MCM.bOnlyRapistsQuit)
      potentials = positions
    Else
      If(ID == 0)
        potentials = PrimGroup
      ElseIf(ID == 1)
        potentials = SecGroup
      Else
        potentials = TerGroup
      EndIf
    EndIf
    int i = 0
    While(i < potentials.Length)
      If(Utility.RandomFloat(0, 99.5) < MCM.fRapistQuits)
        ClearAliasByRef(list, potentials[i])
        potentials = PapyrusUtil.RemoveActor(potentials, potentials[i])
      EndIf
      i += 1
    EndWhile
  EndIf

  Actor[] potentials
  If(ID == 0)
    potentials = PrimGroup
  ElseIf(ID == 1)
    potentials = SecGroup
  Else
    potentials = TerGroup
  EndIf
  If(!potentials.Length)
    QuitCycle(ID, positions)
    return
  Else
    Debug.SendAnimationEvent(victim, "KudasaiTraumeLie")
  EndIf

  int max = KudasaiAnimation.GetAllowedParticipants(potentials.Length + 1) - 1
  Actor[] newpositions = PapyrusUtil.ActorArray(max)
  int creatures = -1
  Race match
  int i = 0
  While(i < 50 && newpositions.Find(none) > -1)
    int n = Utility.RandomInt(0, potentials.Length - 1)
    If(creatures == -1)
      creatures = (!potentials[n].HasKeyword(ActorTypeNPC)) as int
    EndIf
    If(newpositions.find(potentials[n]) == -1)
      int where = newpositions.Find(none)
      If(creatures == 1)
        Race r = potentials[n].GetRace()
        If(!match)
          match = r
        EndIf
        If(match == r)
          newpositions[where] = potentials[n]
        EndIf
      Else
        newpositions[where] = potentials[n]
      EndIf
    EndIf
    i += 1
  EndWhile

  newpositions = PapyrusUtil.RemoveActor(newpositions, none)
  If(ID == 0)
    TotalPotentials = newpositions.Length
    int where = Utility.RandomInt(0, TotalPotentials - 1)
    If(newpositions[where].HasKeyword(ActorTypeNPC))
      newpositions[where].Say(CycleTopic)
    EndIf
  EndIf

  Utility.Wait(Utility.RandomFloat(2, 5))
  If (KudasaiAnimation.CreateAssault(victim, newpositions, "YKrPlayer_" + ID) == -1)
    QuitCycle(ID, positions)
  EndIf
EndFunction

Function QuitCycle(int ID, Actor[] lastaggressors)
  SetStage(100 + 100 * ID)
  If(ID == 0)
    Player.RegisterForSingleUpdate(1)
  Else
    Actor victim = Followers[ID - 1].GetReference() as Actor
    Debug.SendAnimationEvent(victim, "bleedoutStart")
  EndIf
EndFunction

Function CompleteCycle()
  totalscenes -= 1
  If(totalscenes == 0)
    GoToState("Ending")
  EndIf
EndFunction

State Ending
  Event OnBeginState()
    RegisterForSingleUpdate(60)
  EndEvent

  Event OnUpdate()
    Stop()
  EndEvent
EndState


Event PostAssaultSL_0(int tid, bool hasPlayer)
  Debug.Trace("[Kudasai] SL End -> rPlayer ;; ID = 0")
  Actor[] positions = KudasaiAnimationSL.GetPositions(tid)
  Actor victim = KudasaiAnimationSL.GetVictim(tid)
  CreateNewCycle(victim, positions)
EndEvent
Event PostAssaultSL_1(int tid, bool hasPlayer)
  Debug.Trace("[Kudasai] SL End -> rPlayer ;; ID = 1")
  Actor[] positions = KudasaiAnimationSL.GetPositions(tid)
  Actor victim = KudasaiAnimationSL.GetVictim(tid)
  CreateNewCycle(victim, positions)
EndEvent
Event PostAssaultSL_2(int tid, bool hasPlayer)
  Debug.Trace("[Kudasai] SL End -> rPlayer ;; ID = 2")
  Actor[] positions = KudasaiAnimationSL.GetPositions(tid)
  Actor victim = KudasaiAnimationSL.GetVictim(tid)
  CreateNewCycle(victim, positions)
EndEvent
Event NativeAssaultEndOStim(string asEventName, string asStringArg, float afNumArg, form akSender)
  Actor[] positions = KudasaiAnimationOStim.GetPositions(afNumArg as int)
  Actor victim
  If (positions.find(Game.GetPlayer()) > -1)
    victim = Game.GetPlayer()
  ElseIf(positions.find(Followers[0].GetActorReference()) > -1)
    victim = Followers[0].GetReference() as Actor
  ElseIf(positions.find(Followers[1].GetActorReference()) > -1)
    victim = Followers[1].GetReference() as Actor
  EndIf
  If(victim == none)
    return
  EndIf
  Debug.Trace("[Kudasai] OStimEnd -> rPlayer ;; Victim = " + victim)

  CreateNewCycle(victim, positions)
EndEvent

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
  Actor enpc = EnemyNPC.GetReference() as Actor
  If(enpc)
    Debug.Trace("DoResNPC -> enpc = " + enpc)
    If(Kudasai.IsDefeated(enpc))
      Kudasai.RescueActor(enpc, true)
    EndIf
    If(CreateAssaultGroups())
      return
    EndIf
  ElseIf(MCM.FrameCreature)
    If(CreateAssaultGroups())
      return
    EndIf
  EndIf

  ; Fallback
  ToMapEdge.Start()
  Stop()
EndEvent

bool Function CreateAssaultGroups()
  If(MCM.bPostCombatAssault)
    float numfollower = GetNumFollowers()
    float hostiles = GetNumHostiles()
    If(hostiles == 0.0)
      return false
    EndIf
    ; At this point, the Quest contains only Aliases whichs references are allowed to animate
    ; With a max of 20 references, and a min of 1
    int forfollower = Math.Floor(hostiles * 0.3) ; With only 20 enemies total, this cant be greater than 6
    int forplayer = Math.Floor(hostiles - forfollower * numfollower)

    ; Create up to 3 groups dividing hostiles, so that each of the max 3 victims has for_ members assigned to them
    If(numfollower > 0)
      SecGroup = PapyrusUtil.ActorArray(forfollower)
      PopulateRefs(SecRefs, SecGroup, forfollower)
      If(numfollower > 1)
        TerGroup = PapyrusUtil.ActorArray(forfollower)
        PopulateRefs(TerRefs, TerGroup, forfollower)
      EndIf
    EndIf
    PrimGroup = PapyrusUtil.ActorArray(forplayer)
    int i = 0
    int ii = 0
    While(i < Enemies.Length)
      Actor that = Enemies[i].GetReference() as Actor
      If(that) ; FIXME: && Kudasai.IsInterested(that))
        PrimGroup[ii] = that
        ii += 1
      EndIf
      i += 1
    EndWhile
    Debug.Trace("Prim = " + PrimGroup)
    Debug.Trace("Sec = " + SecGroup)
    Debug.Trace("Ter = " + TerGroup)
    ; At this point, all fetched Alises are divided into up to 3 Groups. Player assigned Aliases are using
    ; the default aliases, whereas Follower ones have their own "SecRef" and "TerRef" aliases
    ; Now the Scenes should start which will start the individual Scene loops
    totalscenes = 1
    If(SecRefs[0].GetReference())
      Scene02.Start()
      If(Scene02.IsPlaying())
        totalscenes += 1
        CreateCycle(2)
      EndIf
      If(TerRefs[0].GetReference())
        Scene03.Start()
        If(Scene03.IsPlaying())
          totalscenes += 1
          CreateCycle(3)
        EndIf
      EndIf
    EndIf
  EndIf
  Scene01.Start()

  return Scene01.IsPlaying()
EndFunction

Function PopulateRefs(ReferenceAlias[] list, Actor[] array, int max)
  int i = 1 ; 0 is EnemyNPC which is reserved for the Player
  int ii = 0
  While(i < Enemies.Length && ii < max)
    Actor that = Enemies[i].GetReference() as Actor
    If(that) ; FIXME: && Kudasai.IsInterrested(that))
      If(Kudasai.IsDefeated(that))
        (Enemies[i] as KudasaiRPlayerNAlias).MarkForClear = true
      Else
        Enemies[i].Clear()
      EndIf
      ForceRef(list, that)
      array[ii] = that
      ii += 1
    EndIf
    i += 1
  EndWhile
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

; Count the number of Hostile Actors fetched by the Quest
; Return the Number of Hostiles that are allowed to enter Scenes
; Clear any Aliases that arent allowed to animate
; Rescue defeated Victoires
float Function GetNumHostiles()
  bool ignorecreatures = EnemyNPC.GetReference() != none
  int i = 0
  int ii = 0
  While(i < Enemies.Length)
    Actor that = Enemies[i].GetReference() as Actor
    If(!that)
      return ii
    EndIf
    bool defeated = Kudasai.IsDefeated(that)
    If(!ignorecreatures && Kudasai.ValidRace(that) || that.HasKeyword(ActorTypeNPC))
      ii += 1
    Else
      If(!defeated)
        Enemies[i].Clear()
      Else
        (Enemies[i] as KudasaiRPlayerNAlias).MarkForClear = true
      EndIf
    EndIf
    If(defeated)
      Enemies[i].RegisterForSingleUpdate(Utility.RandomInt(2, 6))
    EndIf
    i += 1
  EndWhile
  return ii
EndFunction

; =============== CLEANUP

Function ForceStopScenes()
  Actor follower0 = Followers[0].GetActorReference()
  Actor follower1 = Followers[1].GetActorReference()
  KudasaiAnimation.StopAnimating(Game.GetPlayer(), MCM)
  If(follower0)
    KudasaiAnimation.StopAnimating(follower0, MCM)
  EndIf
  If(follower1)
    KudasaiAnimation.StopAnimating(follower1, MCM)
  EndIf
EndFunction
