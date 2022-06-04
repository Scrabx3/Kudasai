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

bool Property PermitNSFW Auto Hidden Conditional
bool Property PermitNSFWCrt Auto Hidden Conditional
bool Property HasSchlong Auto Hidden Conditional
bool Property Outlaw Auto Hidden Conditional
bool Property Nude Auto Hidden Conditional
bool Property IsAlone Auto Hidden Conditional

int Property Offered Auto Hidden Conditional ; When the Victoire demands the Player to hand over all their items, this is the result

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
  ElseIf (Kudasai.IsDefeated(PlayerRef) || PlayerRef.IsBleedingOut())
    ERRPlayerDefeated.Show()
    Debug.Trace("[Yamete] Player already defeated")
    Stop()
    return
  EndIf

  Hostiles = PapyrusUtil.ActorArray(Enemies.Length)
  Creatures = PapyrusUtil.ActorArray(Enemies.Length)

  Actor primus ; the primary npc whos leading the conversation. If none, only Creatures are involved
  int primusType ; None = 0, Child = 1, Elder = 2, Adult = 3
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
          If (Kudasai.ValidRace(enemy))
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
  Hostiles = PapyrusUtil.RemoveActor(Hostiles, none)
  Creatures = PapyrusUtil.RemoveActor(Creatures, none)
  Debug.Trace("[Kudasai] Hostiles = " + Hostiles + " Creatures = " + Creatures)
  If (Hostiles[0] == none && Creatures[0] == none)
    ERRNoActors.Show()
    Debug.Trace("[Kudasai] No Actors to surrender to")
    Stop()
    return
  EndIf
  Kudasai.PacifyActor(PlayerRef)
  Debug.SendAnimationEvent(PlayerRef, "KudasaiSurrender")
  int n = 0
  While(n < Hostiles.Length)
    If (Hostiles[n])
      Kudasai.PacifyActor(Hostiles[n])
    EndIf
    If (Creatures[n])
      Kudasai.PacifyActor(Creatures[n])
    EndIf
    n += 1
  EndWhile
  Utility.Wait(0.7)
  If (!primus) ; Only Creatures
    If(MCM.FrameCreature) ; -------------- Assault
      Debug.Trace("[Kudasai] Creature -> Assault")
      StartSceneCreature()
    Else
      int accept = 20
      int j = 0
      While(j < Followers.Length)
        If (Followers[j].GetReference())
          accept += 15
        EndIf
        j += 1
      EndWhile
      If(Utility.RandomInt(0, 99) < accept) ; -- Accept & Move On
        Debug.Trace("[Kudasai] Creature -> Surrender accepted")
        CrtAccept.Show()
        SetStage(100)
      Else ; ----------------------------------- Ignore
        Debug.Trace("[Kudasai] Creature -> Ignored")
        CrtIgnore.Show()
        SurrenderEnd()
        Stop()
        return
      EndIf
    EndIf
  Else
    DialogueAlias.ForceRefTo(primus)
    PermitNSFW = MCM.FrameAny && Hostiles.Length && KudasaiInternal.IsAlternateVersion()
    PermitNSFWCrt = MCM.FrameCreature && Creatures.Length && KudasaiInternal.IsAlternateVersion()
    HasSchlong = primus.GetLeveledActorBase().GetSex() == 0 || KudasaiInternal.HasSchlong(primus)
    Outlaw = primus.GetCrimeFaction() == none
    Nude = PlayerRef.GetWornForm(4) == none
    IsAlone = Hostiles.Length + Creatures.Length == 1
  EndIf
  Debug.Trace("[Kudasai] Surrender Setup = completed")
  RegisterForSingleUpdate(0.5) ; cant start Scenes in OnInit..
  RegisterForModEvent("HookAnimationEnd_KSurrender", "SLSceneEnd")
  RegisterForModEvent("ostim_end", "OStimCreatureEnd")
EndEvent
Event OnUpdate()
  SurrenderScene.Start()
EndEvent

Function SurrenderEnd()
  Debug.Trace("[Kudasai] SurrenderQ End Hostiles = " + Hostiles)
  Debug.Trace("[Kudasai] SurrenderQ End Creatures = " + Creatures)
  Kudasai.UndoPacify(Game.GetPlayer())
  int i = 0
  While(i < Hostiles.Length)
    If (Hostiles[i])
      Kudasai.UndoPacify(Hostiles[i])
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
      Kudasai.UndoPacify(Creatures[n])
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

Function SellOut()
  SetStage(100)
  FadeToBlackImod.Apply()
  Utility.Wait(1.8)
  If(KudasaiInternal.IsAlternateVersion() && Game.GetModByName("SimpleSlavery.esp") != 255)
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
  If (!crimefaction)
    crimefaction = CrimeFactions.GetAt(Utility.RandomInt(0, CrimeFactions.GetSize() - 1)) as Faction
  EndIf
  If (crimefaction.GetCrimeGold() < 200)
    crimefaction.ModCrimeGold(200, true)
  EndIf
  FadeToBlackImod.Apply()
  Utility.Wait(1.8)
  crimefaction.SendPlayerToJail()
  FadeToBlackImod.PopTo(FadeToBlackBackImod)
EndFunction

Function Strip(Actor stripper)
  Armor[] wornz = KudasaiInternal.GetWornArmor_Filtered(stripper)
  Debug.Trace("[Kudasai] <Strip> Subject = " + stripper + " Worn Armor = " + wornz)
  int i = 0
  While (i < wornz.length)
    stripper.UnequipItem(wornz[i], abSilent = true)
    i += 1
  EndWhile
EndFunction
Function StripAndHandOver(Actor tostrip, Actor handover)
  Armor[] wornz = KudasaiInternal.GetWornArmor_Filtered(tostrip)
  Debug.Trace("[Kudasai] <StripAndHandOver> Subject = " + tostrip + " Worn Armor = " + wornz)
  int i = 0
  While (i < wornz.length)
    tostrip.UnequipItem(wornz[i], abSilent = true)
    tostrip.RemoveItem(wornz[i], 1, true, handover)
    i += 1
  EndWhile
EndFunction
Function StripAndHandOverAll(Actor handover)
  Actor target = Game.GetPlayer()
  int n = Followers.Length
  While(true)
    If (target)
      Armor[] wornz = KudasaiInternal.GetWornArmor_Filtered(target)
      Debug.Trace("[Kudasai] <StripAndHandOver> Subject = " + target + " Worn Armor = " + wornz)
      int i = 0
      While (i < wornz.length)
        target.UnequipItem(wornz[i], abSilent = true)
        target.RemoveItem(wornz[i], 1, true, handover)
        i += 1
      EndWhile
    EndIf
    If (n == 0)
      return
    Endif
    n -= 1
    target = Followers[n].GetReference() as Actor
  EndWhile
EndFunction

Function OfferItems(Actor aggressor)
  Actor PlayerRef = Game.GetPlayer()
  int iItm = PlayerRef.GetNumItems()
  Debug.Trace("[Kudasai] <Surrender> Items b4 trade = " + iItm)
  If(iItm <= 3)
    ; Player got nothing to offer
    Offered = 4
    return
  EndIf
  float numGold = PlayerRef.GetItemCount(Gold001) as float
  ; Open Gifting Menu, then analyze difference
  aggressor.ShowGiftMenu(true, none, true)
  int nItm = PlayerRef.GetNumItems()
  Debug.Trace("[Kudasai] <Surrender> items after trade = " + nItm)
  If(nItm == iItm)
    ; Didnt give any Items but has Items
    Offered = 0
  ElseIf(nItm < 7)
    ; divide between given up everything & being essentially harmless and being simply poor
    int i = 0
    While(i < nItm)
      Form f = PlayerRef.GetNthForm(i)
      Armor ar = f as Armor
      If(ar && Math.LogicalAND(ar.GetSlotMask(), 4) != 0 || f as Weapon || f == Gold001 && PlayerRef.GetItemCount(f) > (numGold * 0.3))
        ; If we got a weapn or armor on Slot 32, set to 2 (barely anything)
        Debug.Trace("[Kudasai] Surrender: Player owns Armor, Weapon or some Gold")
        Offered = 2
        return
      EndIf
      i += 1
    EndWhile
    ; If the remaining items are only junk, little money and no weapon & body armor, lil adventuerer is officially considered failed.. or so
    Offered = 3
  Else
    ; got some stuff left. The victoire will be satisfied if 20% (40% if outlaw) of the inventory is offered. Money needs to be offered 70% to be considered
    int req = ((0.2 + (0.2 * Outlaw as int)) * (iItm as float)) as int
    Debug.Trace("[Kudasai] <Surrender> Total Items = " + iItm + ", After Trade = " + nItm + " Required To Give = " + req)
    If(PlayerRef.GetItemCount(Gold001) < (numGold * 0.3) as int)
      ; If 70%+ money has been given, remove the gold from calculation
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

Function StartScene(Actor req, Actor victim, bool multiple)
  SetStage(90)
  Debug.Trace("[Kudasai] Starting Scene with NPC = " + Hostiles)
  int num = KudasaiAnimation.GetAllowedParticipants(Hostiles.Length + 1) - 1
  If (Hostiles.Length > num)
    If (num == 1)
      num = 2
    EndIf
    Hostiles = PapyrusUtil.SliceActorArray(Hostiles, 0, num)
    If (Hostiles.find(req) == -1)
      Hostiles[0] = req
    EndIf
  EndIf
  If (KudasaiAnimation.CreateAssault(victim, Hostiles, "KSurrender") == -1)
    Debug.Trace("[Kudasai] <Surrender> Failed to start NPC Scene")
    Debug.Notification("[Kudasai] Error starting Scene")
    SetStage(100)
  EndIf
EndFunction
Function StartSceneCreature()
  SetStage(90)
  Debug.Trace("[Kudasai] Starting Creature Scene with Creaeturs = " + Creatures)
  int num = KudasaiAnimation.GetAllowedParticipants(Creatures.Length + 1) - 1
  If (Creatures.Length > num)
    Creatures = PapyrusUtil.SliceActorArray(Creatures, 0, num)
  EndIf
  If (KudasaiAnimation.CreateAssault(Game.GetPlayer(), Creatures, "KSurrender") == -1)
    Debug.Trace("[Kudasai] <Surrender> Failed to start Creature Scene")
    CrtAccept.Show()
    SetStage(100)
    return
  EndIf
EndFunction
Function StartSceneCustom(Actor victim, Actor secundus, String tags)
  IF (KudasaiAnimation.CreateAnimationCustom2p(MCM, victim, secundus, victim, tags, "KSurrender") == -1)
    Debug.Trace("[Kudasai] <Surrender> Failed to start custom Scene")
    Debug.Notification("[Kudasai] Error starting Scene")
    SetStage(100)
  EndIf
EndFunction

Event SLSceneEnd(int tid, bool hasPlayer)
  SetStage(100)
EndEvent
Event OStimEnd(string eventName, string strArg, float numArg, Form sender)
  If(numArg > -2)
    If(KudasaiAnimationOStim.FindActor(Game.GetPlayer(), numArg as int) == false)
      return
    EndIf
  EndIf
  SetStage(100)
EndEvent

