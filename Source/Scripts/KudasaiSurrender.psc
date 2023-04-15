Scriptname KudasaiSurrender extends Quest Conditional

KudasaiMCM Property MCM Auto

ReferenceAlias[] Property Followers Auto
ReferenceAlias[] Property Enemies Auto
ReferenceAlias Property ControlParty Auto
ReferenceAlias Property Observer Auto
ReferenceAlias Property DialogueAlias Auto

Keyword Property ActorTypeNPC Auto
Faction Property GuardDialogueFaction Auto
Race Property ElderRace Auto
ImageSpaceModifier Property FadeToBlackImod Auto
ImageSpaceModifier Property FadeToBlackHoldImod Auto
ImageSpaceModifier Property FadeToBlackBackImod Auto
FormList Property CrimeFactions Auto
MiscObject Property Gold001 Auto

Message Property ERRThirdParty Auto
Message Property ERRPlayerDefeated Auto
Message Property ERRNoActors Auto
Message Property CrtAccept Auto
Message Property CrtIgnore Auto

Spell Property TimeoutSpell Auto
{So the player cant surrender to the same Actor again within 3 Minutes}
FormList Property KnowsPlayer Auto
Scene Property SurrenderScene Auto

Actor[] Hostiles ; Hostile Adult NPC (for animations)
Actor[] Creatures ; Hostile Creatures (for animations)
Actor[] Allies ; Allied NPC

bool Property PermitNSFWCrt Auto Hidden Conditional
bool Property Outlaw Auto Hidden Conditional
bool Property Nude Auto Hidden Conditional
bool Property IsAlone Auto Hidden Conditional
bool Property HasHumanCompanions Auto Hidden Conditional

int Property Offered Auto Hidden Conditional ; When the Victoire demands the Player to hand over all their items, this is the result

bool tied_up

;/ Start Up /;

Event OnInit()
  If (!IsRunning())
    return
  EndIf
  Debug.Trace("[Kudasai] <Surrender> Player attempting to Surrender")
  Actor PlayerRef = Game.GetPlayer()
  If (ControlParty.GetReference())
    ERRThirdParty.Show()
    Debug.Trace("[Kudasai] More than 1 fighting faction = " + ControlParty.GetReference())
    Stop()
    return
  ElseIf (Acheron.IsDefeated(PlayerRef) || PlayerRef.IsBleedingOut())
    ERRPlayerDefeated.Show()
    Debug.Trace("[Yamete] Player already defeated")
    Stop()
    return
  EndIf

  tied_up = false
  Hostiles = PapyrusUtil.ActorArray(Enemies.Length)
  Creatures = PapyrusUtil.ActorArray(Enemies.Length)

  Actor primus    ; the primary npc whos leading the conversation. If none, only Creatures are involved
  int primusType  ; None = 0, Child = 1, Elder = 2, Adult = 3
  int i = 0
  int hi = 0
  int ci = 0
  While(i < Enemies.Length)
    Actor enemy = Enemies[i].GetReference() as Actor
    Debug.Trace("[Kudasai] <Surrender> Checking Actor at " + i + " = " + enemy)
    If (enemy)
      If (enemy.HasKeyword(ActorTypeNPC))
        If (ValidGuard(enemy))
          primus = enemy
          i = Enemies.Length
        Else
          ; Adults over elder over childs
          If (!primus)
            Debug.Trace("[Kudasai] First primus at " + i + " = " + enemy)
            primus = enemy
            If (enemy.IsChild())
              primusType = 1
            ElseIf (primus.GetRace() == ElderRace)
              primusType = 2
            Else
              primusType = 3
              Hostiles[hi] = enemy
              hi += 1
            EndIf
          Else
            If (!enemy.IsChild())
              If (enemy.GetRace() == ElderRace)
                If (primusType == 1) ; Previous primus is child, replace them
                  Debug.Trace("[Kudasai] Replacing Child with Elder at " + i + " = " + enemy)
                  primus = enemy
                  primusType = 2
                ElseIf (primusType == 2 && primus.GetActorValue("Confidence") < enemy.GetActorValue("Confidence"))
                  primus = enemy
                EndIf
              Else ; Adult
                If (primusType < 3 || primus.GetActorValue("Confidence") < enemy.GetActorValue("Confidence"))
                  Debug.Trace("[Kudasai] Replacing previous Primus with Adult at " + i + " = " + enemy)
                  primus = enemy
                  primusType = 3
                EndIf
                Hostiles[hi] = enemy
                hi += 1
              EndIf
            EndIf
          EndIf
        EndIf
      Else ; Creature
        If (Creatures[0] == none)
          Debug.Trace("[Kudasai] First Creature")
          If (MCM.AllowedRaceType(KudasaiAnimation.GetRaceType(enemy)))
            Debug.Trace("[Kudasai] Race is valid, adding")
            Creatures[ci] = enemy
            ci += 1
          Else
            Debug.Trace("[Kudasai] Race is invalid, skipping")
          EndIf
        ElseIf (Creatures[0].GetRace() == enemy.GetRace())
          Creatures[ci] = enemy
          ci += 1
        EndIf
      EndIf
    EndIf
    i += 1
  EndWhile
  Debug.Trace("[Kudasai] Hostiles = " + Hostiles + " Creatures = " + Creatures)
  If (Hostiles[0] == none && Creatures[0] == none)
    ERRNoActors.Show()
    Debug.Trace("[Kudasai] No Actors to surrender to")
    Stop()
    return
  EndIf
  Acheron.PacifyActor(PlayerRef)
  Debug.SendAnimationEvent(PlayerRef, "KudasaiSurrender")
  int n = 0
  While(n < Hostiles.Length)
    If (Hostiles[n])
      Acheron.PacifyActor(Hostiles[n])
    EndIf
    If (Creatures[n])
      Acheron.PacifyActor(Creatures[n])
    EndIf
    n += 1
  EndWhile
  Hostiles = PapyrusUtil.RemoveActor(Hostiles, none)
  Creatures = PapyrusUtil.RemoveActor(Creatures, none)
  Utility.Wait(0.7)
  If (!primus) ; Only Creatures
    If(MCM.FrameCreature) ; ---------------- Assault
      Debug.Trace("[Kudasai] <Surrender> Creature -> Assault")
      SetStage(90)
      If(!MakeScene(PlayerRef, Creatures[0], Creatures, ""))
        CrtAccept.Show()
        SetStage(100)
      EndIf
    Else
      If(Utility.RandomInt(0, 99) < 15) ; -- Accept & Move On
        Debug.Trace("[Kudasai] Creature -> Surrender accepted")
        CrtAccept.Show()
        SetStage(100)
      Else ; ------------------------------- Ignore
        Debug.Trace("[Kudasai] Creature -> Ignored")
        CrtIgnore.Show()
        SurrenderEnd()
        Stop()
        return
      EndIf
    EndIf
  Else
    DialogueAlias.ForceRefTo(primus)
    PermitNSFWCrt = MCM.FrameCreature && Creatures.Length
    Outlaw = primus.GetCrimeFaction() == none
    Nude = PlayerRef.GetWornForm(4) == none
    IsAlone = Hostiles.Length + Creatures.Length == 1
    HasHumanCompanions = Hostiles.Length > 1
  EndIf
  Debug.Trace("[Kudasai] Surrender Setup = completed")
  RegisterForSingleUpdate(0.5) ; cant start Scenes in OnInit..
  RegisterForModEvent("HookAnimationEnd_KSurrender", "SLSceneEnd")
  RegisterForModEvent("HookAnimationEnd_KSurrenderFollower", "SLSceneFollower")
  RegisterForModEvent("ostim_end", "OStimCreatureEnd")
EndEvent
Event OnUpdate()
  SurrenderScene.Start()
EndEvent

Function SurrenderEnd()
  Debug.Trace("[Kudasai] SurrenderQ End Hostiles = " + Hostiles)
  Debug.Trace("[Kudasai] SurrenderQ End Creatures = " + Creatures)
  Acheron.ReleaseActor(Game.GetPlayer())
  int i = 0
  While(i < Hostiles.Length)
    If (Hostiles[i])
      Acheron.ReleaseActor(Hostiles[i])
      TimeoutSpell.Cast(Hostiles[i])
      If (Hostiles[i].GetLeveledActorBase().IsUnique())
        KnowsPlayer.AddForm(Hostiles[i])
      EndIf
      Hostiles[i].EvaluatePackage()
    EndIf
    i += 1
  EndWhile
  int n = 0
  While(n < Creatures.Length)
    If (Creatures[n])
      Acheron.ReleaseActor(Creatures[n])
      TimeoutSpell.Cast(Creatures[n])
      Creatures[n].EvaluatePackage()
    EndIf
    n += 1
  EndWhile
EndFunction

bool Function ValidGuard(Actor subject)
  If (subject.IsGuard() && subject.IsInFaction(GuardDialogueFaction))
    Faction crimefaction = subject.GetCrimeFaction()
    If (crimefaction)
      Debug.Trace("[Kudasai] Surrendered to a guard = " + subject)
      If (crimefaction.GetCrimeGold() < 100)
        crimefaction.ModCrimeGold(100, true)
      EndIf
      return true
    EndIf
  EndIf
  return false
EndFunction

;/ Strip & Theft /;

Function Strip(Actor akTarget, Actor akContainer = none)
  Armor[] items = Acheron.StripActor(akTarget)
  If(items.Length)
    akTarget
  EndIf
  If(akContainer)
    Debug.Trace("[Kudasai] <Surrender> Stripping items from " + akTarget + " to " + akContainer + ": " + items)
    int i = 0
    While (i < items.length)
      akContainer.RemoveItem(items[i], 1, true, akTarget)
      i += 1
    EndWhile
  Else
    Debug.Trace("[Kudasai] <Surrender> Stripping items from " + akTarget + ": " + items)
  EndIf
EndFunction

; Strip player and all stripplable followers
Function StripAll(Actor akContainer = none)
  Strip(Game.GetPlayer(), akContainer)
  Actor[] list = Acheron.GetFollowers()
  int i = 0
  While(i < list.Length)
    If(list[i].HasKeyword(ActorTypeNPC) && !Acheron.IsDefeated(list[i]))
      Strip(list[i], akContainer)
    EndIf
    i += 1
  EndWhile
EndFunction

Function OfferItems(Actor aggressor)
  Actor PlayerRef = Game.GetPlayer()
  int iItm = PlayerRef.GetNumItems()
  Debug.Trace("[Kudasai] <Surrender> Items before trade = " + iItm)
  If(iItm <= 3)
    Offered = 4
    return
  EndIf
  float numGold = PlayerRef.GetItemCount(Gold001) as float
  aggressor.ShowGiftMenu(true, none, true)
  int nItm = PlayerRef.GetNumItems()
  Debug.Trace("[Kudasai] <Surrender> items after trade = " + nItm)
  If(nItm == iItm)  ; No items given
    Offered = 0
  ElseIf(nItm < 7)  ; Gave up (almost) everything
    int i = 0
    While(i < nItm)
      Form f = PlayerRef.GetNthForm(i)
      Armor ar = f as Armor
      If(ar && Math.LogicalAND(ar.GetSlotMask(), 4) != 0 || f as Weapon || f == Gold001 && PlayerRef.GetItemCount(f) > (numGold * 0.3))
        Debug.Trace("[Kudasai] <Surrender> Player owns Armor, Weapon or some Gold")
        Offered = 2
        return
      EndIf
      i += 1
    EndWhile
    Offered = 3
  Else
    int req = ((0.05 + (0.1 * Outlaw as float)) * (iItm as float)) as int
    Debug.Trace("[Kudasai] <Surrender> Total Items = " + iItm + ", After Trade = " + nItm + " Required To Give = " + req)
    If(PlayerRef.GetItemCount(Gold001) < (numGold * 0.3) as int)
      Debug.Trace("[Kudasai] <Surrender> Player gave 70%+ Gold") 
      nItm -= 1
    EndIf
    If(iItm - nItm >= req)
      Offered = 1
    Else
      Offered = 0
    EndIf
  EndIf
EndFunction

Function GiveGold(float percent, ObjectReference to)
  Actor PlayerRef = Game.GetPlayer()
  int give = Math.Ceiling(PlayerRef.GetItemCount(Gold001) * percent)
  PlayerRef.RemoveItem(Gold001, give, false, to)
EndFunction

Function StealItems(ObjectReference akTransferTo)
  Actor player = Game.GetPlayer()
  int numItm = player.GetNumItems()
  int numStl = Math.Ceiling(0.1 * numItm as float)
  int i = 0
  While(i < numStl)
    int w = Utility.RandomInt(0, numItm - i)
    Form itm = player.GetNthForm(w)
    If(itm == Gold001)
      GiveGold(0.6, akTransferTo)
    Else
      player.RemoveItem(itm, 1, false, akTransferTo)
    EndIf
    i += 1
  EndWhile
EndFunction

;/ Misc Consequences /;

Function SellOut()
  SetStage(100)
  FadeToBlackImod.Apply()
  Utility.Wait(1.8)
  If(Game.GetModByName("SimpleSlavery.esp") != 255)
    SendModEvent("SSLV Entry")
  Else
    Faction cf = CrimeFactions.GetAt(Utility.RandomInt(0, CrimeFactions.GetSize() - 1)) as Faction
    cf.ModCrimeGold(600, true)
    cf.SendPlayerToJail()
  EndIf
  FadeToBlackImod.PopTo(FadeToBlackBackImod)
EndFunction

Function Imprison(Faction crimefaction)
  SetStage(100)
  If(!crimefaction || !CrimeFactions.HasForm(crimefaction))
    crimefaction = CrimeFactions.GetAt(Utility.RandomInt(0, CrimeFactions.GetSize() - 1)) as Faction
  EndIf
  If(crimefaction.GetCrimeGold() < 200)
    crimefaction.ModCrimeGold(200, true)
  EndIf
  FadeToBlackImod.Apply()
  Utility.Wait(1.8)
  crimefaction.SendPlayerToJail()
  FadeToBlackImod.PopTo(FadeToBlackBackImod)
EndFunction

Function TieUp(Actor akTarget)
  ; COMEBACK: Reduce the number of tie ups here to 1 or 2 and move everything else into the Black Market(?)
  String[] poses = new String[10]
  poses[0] = "KudasaiAPC006"
  poses[1] = "KudasaiAPC008"
  poses[2] = "KudasaiAPC011"
  poses[3] = "KudasaiAPC012"
  poses[4] = "KudasaiAPC014"
  poses[5] = "KudasaiAPC013"
  poses[6] = "KudasaiAPC015"
  poses[7] = "KudasaiAPC056"
  poses[8] = "KudasaiAPC057"
  poses[9] = "KudasaiAPC016"
  poses[10] = "KudasaiAPC018"
  poses[11] = "KudasaiAPC019"
  poses[12] = "KudasaiAPC058"

  Debug.SendAnimationEvent(akTarget, poses[Utility.RandomInt(0, poses.Length - 1)])
  If(akTarget == Game.GetPlayer())
    Game.SetPlayerAIDriven(true)
    tied_up = true
  Else
    akTarget.SetRestrained(true)
  EndIf
EndFunction

Function UndoTieUp(Actor akTarget)
  Debug.SendAnimationEvent(akTarget, "staggerStart")
  If(akTarget == Game.GetPlayer())
    Game.SetPlayerAIDriven(false)
  Else
    akTarget.SetRestrained(false)
  EndIf
EndFunction

;/ ADULT SCENES /;
Actor scene_target

bool Function StartScene(Actor akAggressor = none, Actor akVictim = none, String asTags = "UseConfig")
  If(akVictim == none)
    akVictim = Game.GetPlayer()
  EndIf
  If(akAggressor == none)
    akAggressor = GetAggressor(Hostiles)
  EndIf
  SetStage(90)
  If(!MakeScene(akVictim, akAggressor, Hostiles, asTags))
    Debug.Trace("[Kudasai] <Surrender> Failed to start NPC Scene")
    Debug.Notification("[Kudasai] Error starting Scene")
    SetStage(100)
    return false
  EndIf
  scene_target = akVictim
  return true
EndFunction

Function StartSceneFollower(Actor akAggressor = none, bool abUseHook = false, bool abAll = false, String asTags = "UseConfig")
  If(akAggressor == none)
    akAggressor = GetAggressor(Hostiles)
  EndIf
  Actor[] fols = Acheron.GetFollowers()
  int i = 0
  While(i < fols.Length)
    Actor it = fols[i]
    If(it.HasKeyword(ActorTypeNPC) && !Acheron.IsDefeated(it))
      If(abUseHook && StartScene(akAggressor, it, asTags) || \
        !abUseHook && MakeScene(it, akAggressor, Hostiles, asTags, "KSurrenderFollower"))
        If(!abAll)
          return
        Else
          akAggressor = GetAggressor(Hostiles)
          abUseHook = false
        EndIf
      EndIf
    EndIf
    i += 1
  EndWhile
EndFunction

Actor Function GetAggressor(Actor[] akHostiles)
  int i = 0
  While(i < akHostiles.Length)
    Actor it = akHostiles[i]
    If(!KudasaiAnimation.IsAnimating(it) && !Acheron.IsDefeated(it))
      return it
    EndIf
    i += 1
  EndWhile
  return none
EndFunction

bool Function MakeScene(Actor akVictim, Actor akAggressor, Actor[] akPartners, String asTags = "UseConfig", String asHook = "KSurrender")
  Debug.Trace("[Kudasai] <Surrender> MakeScene with first actor = " + akVictim + " / Aggressor = " + akAggressor + " / Partners = " + akPartners + " / Tags = " + asTags)
  String racekey = KudasaiAnimation.GetRaceType(akAggressor)
  If(MCM.AllowedRaceType(racekey))
    return false
  EndIf
  ; assert(akPartners.Find(akAggressor) > -1)
  int max = KudasaiAnimation.GetAllowedParticipants(akPartners.Length + 1)
  Actor[] positions = new Actor[5]
  positions[0] = akVictim
  positions[1] = akAggressor
  int i = 0
  int ii = 2
  While(i < 50 && ii < max)
    Actor it = akPartners[Utility.RandomInt(0, akPartners.Length - 1)]
    If(!KudasaiAnimation.IsAnimating(it) && it.Is3DLoaded() && KudasaiAnimation.GetRaceType(it) == racekey)
      positions[ii] = it
      ii += 1
    EndIf
    i += 1
  EndWhile
  Debug.Trace("[Kudasai] <Surrender> Creating scene with positions = " + positions)
  return KudasaiAnimation.CreateAssault(positions, akVictim, asHook, asTags) > -1
EndFunction

Event SLSceneEnd(int tid, bool hasPlayer)  
  ToBleedout(KudasaiAnimationSL.GetPositions(tid))
  If(!tied_up)
    SetStage(100)
  Else
    SetStage(95)
  EndIf
EndEvent
Event SLSceneFollower(int tid, bool hasPlayer)
  ToBleedout(KudasaiAnimationSL.GetPositions(tid))
EndEvent
Event OStimEnd(string eventName, string strArg, float numArg, Form sender)
  If(numArg <= -2)
    return
  EndIf
  Actor[] p = KudasaiAnimationOStim.GetPositions(numArg as int)
  ToBleedout(p)
  If(p.Find(scene_target))
    If(!tied_up)
      SetStage(100)
    Else
      SetStage(95)
    EndIf
  EndIf
EndEvent

Function ToBleedout(Actor[] akPositions)
  int i = 0
  While(i < akPositions.Length)
    If(Acheron.IsDefeated(akPositions[i]))
      Debug.SendAnimationEvent(akPositions[i], "bleedoutStart")
    EndIf
    i += 1
  EndWhile
EndFunction
