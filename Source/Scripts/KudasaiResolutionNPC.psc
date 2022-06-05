Scriptname KudasaiResolutionNPC extends Quest  

KudasaiMCM Property MCM Auto
Keyword Property Defeated Auto

Keyword[] Property rNPC Auto
FormList[] Property Aggressors Auto
Actor[] Victims

Faction Property TmpFriends Auto

; Populate the Victims array & Aggressor formlists. The quest is started through cpp which will only add linked refs
Function Init()
  Debug.Trace("[Kudasai] NPC Resolution -> START")
  Alias[] refs = GetAliases()
  Victims = new Actor[15]
  int i = 0
  While(i < refs.Length)
    ObjectReference subject = (refs[i] as ReferenceAlias).GetReference()
    If (subject)
      ; Find this subjects Victim
      int n = 0
      While(n < rNPC.Length)
        Actor link = subject.GetLinkedRef(rNPC[n]) as Actor
        If (link)
          Aggressors[n].AddForm(subject)
          Victims[n] = link
          n = rNPC.Length
        Else
          n += 1
        EndIf
      EndWhile
      ; Defeated Victoires will stand up again after a short delay
      If (subject.Haskeyword(Defeated))
        refs[i].RegisterForSingleUpdate(Utility.RandomFloat(4, 17))
      EndIf
      i += 1
    Else
      Debug.Trace("[Kudasai] Empty Ref -> Total Victoire Refs = " + i)
      If(i == 0)
        ; impossible branch as the .dll wouldnt start the quest if it cant flag anything?
        Stop()
        return
      EndIf
      i = refs.Length
    EndIf
  EndWhile
  Victims = PapyrusUtil.RemoveActor(Victims, none)
  SetStage(10)
  int n = 0
  While(n < Aggressors.Length)
    Debug.Trace("[Kudasai] Aggressor Group " + n + " = " + Aggressors[n].ToArray())
    n += 1
  EndWhile
  ; Start the first Scene 7 Seconds after Combat ended. All Victoires are near their Victim, so this should
  ; also be enough time for them to go near the victim to have it seem somewhat "real"
  RegisterForSingleUpdate(7)
  RegisterForModEvent("ostim_end", "PostSceneOStim")
  RegisterForModEvent("HookAnimationEnd_Kudasai_rNPC", "PostSceneSL")
EndFunction

; Start a Scene. There should be 1 Scene for every Victim
Event OnUpdate()
  If(GetStage() > 10)
    return
  EndIf
  int i = 0
  While(i < Victims.Length)
    Debug.Trace("[Kudasai] Creating Scene Nr. " + i + " for Victim = " + Victims[i])
    ; Check if Victim is animating & take over the Callback (itd most cerainly a mid combat animation thatd be taken over here)
    If(KudasaiAnimation.HookIfAnimating(Victims[i], MCM, "Kudasai_rNPC") == -1)
      Actor[] partners = CreateNewPartners(i)
      ; If there are no non-defeated Victoires for this Scene, force one of them to stand up
      If (!partners.length) ; 1 Victim
        Actor rescue = Aggressors[i].GetAt(0) as Actor
        Kudasai.RescueActor(rescue, true)
        partners = new Actor[1]
        partners[0] = rescue
        Debug.Trace("[Kudasai] Not enough Actors found. Fallback Partners = " + partners)
      EndIf
      ; Start a Scene for this Group
      If(KudasaiAnimation.CreateAssault(Victims[i], partners, "Kudasai_rNPC") == -1)
        Debug.Trace("[Kudasai] Failed to start Scene")
        HandlePostScene(i, true)
      EndIf
    EndIf
    i += 1
  EndWhile
EndEvent

; Scene end. Kick out Actors that got 'bored' of waiting/assaulting
Event PostSceneSL(int tid, bool hasPlayer)
  Actor victim = KudasaiAnimationSL.GetVictim(tid)
  int id = Victims.find(victim)
  If(id == -1)
    Debug.Trace("[Kudasai] Could not find Victim in SL Scene? Victim = " + victim, 2)
    ; Likely a hooked scene where the Scenes Victim lost the fight
    ; Its likely that Combat will trgger now anyway so meh
    Actor[] positions = KudasaiAnimationSL.GetPositions(tid)
    int i = 0
    While(i < positions.Length)
      If(Victims.find(positions[i]) > -1)
        ClearGroup(i)
      EndIf
      i += 1
    EndWhile
    return
  EndIf
  HandlePostScene(id)
EndEvent
Event PostSceneOStim(string eventName, string strArg, float numArg, Form sender)
  Actor[] positions = KudasaiAnimationOStim.GetPositions(numArg as int)
  int i = 0
  While(i < Victims.Length)
    int where = positions.find(Victims[i])
    If(where > -1)
      HandlePostScene(i)
      return
    endif
    i += 1
  EndWhile
  Debug.Trace("[Kudasai] Could not find Victim in OStim Scene? Positions = " + positions, 2)
EndEvent

Function HandlePostScene(int id, bool looping = false)
  Debug.Trace("[Kudasai] Post Scene for ID = " + id)
  If(GetStage() > 10 || CheckoutAggressors(id) == 0)
    Debug.Trace("[Kudasai] Group is empty.")
    ; Victims are defeated at all times. Only have to reset their animation
    Debug.SendAnimationEvent(Victims[id], "bleedoutstart")
    ClearGroup(id)
    If(PapyrusUtil.CountActor(Victims, none) == Victims.Length)
      Debug.Trace("[Kudasai] .. stopping Quest")
      Stop()
    EndIf
    return
  ElseIf(!looping)
    Debug.SendAnimationEvent(Victims[id], "KudasaiTraumeLie")
  EndIf
  Actor[] partners = CreateNewPartners(id)
  Utility.Wait(Utility.RandomFloat(3, 7))
  If(!partners.Length || KudasaiAnimation.CreateAssault(Victims[id], partners, "Kudasai_rNPC") == -1)
    Debug.Trace("[Kudasai] Failed to start Scene")
    HandlePostScene(id, true)
  EndIf
EndFunction

; Scenes only allow 5 (3) Actors in total
; From potentials, choosing so many by random, to avoid the same actors being animated in every Scene
; .. remember that the Starting Function doesnt require the Victim to be part of the partners array zzz
Actor[] Function CreateNewPartners(int id)
  Keyword ActorTypeNPC = Keyword.GetKeyword("ActorTypeNPC")
  Actor[] potentials = TranslateToActorArray(Aggressors[id].ToArray())
  Debug.Trace("[Kudasai] Creating new Positions for Victim = " + Victims[id] + " with Potentials = " + potentials)

  int numpartners = KudasaiAnimation.GetAllowedParticipants(potentials.Length + 1) - 1
  Actor[] ret = PapyrusUtil.ActorArray(numpartners)
  Race racelock
  int i = 0
  int ii = 0
  While(i < 50 && ii < numpartners)
    int where = Utility.RandomInt(0, potentials.Length - 1)
    If(potentials[where] && !Kudasai.IsDefeated(potentials[where]) && !KudasaiAnimation.IsAnimating(potentials[where], MCM))
      bool valid = false
      If(racelock == none)
        racelock = potentials[where].GetRace()
        valid = true
      Else
        ; TODO: Can add to combination?
        valid = racelock.HasKeyword(ActorTypeNPC) && potentials[where].HasKeyword(ActorTypeNPC) || racelock == potentials[where].GetRace()
      EndIf
      If(valid)
        ret[ii] = potentials[where]
        ii += 1
      EndIf
    EndIf
    potentials[where] = none
    i += 1
  EndWhile

  Debug.Trace("[Kudasai] Found NewPositions = " + ret)
  return PapyrusUtil.RemoveActor(ret, none)
EndFunction

; This decides if victoires still want to "keeep going". Its actually just a RNG check. Yay.
; Returns the amount of remaining victoires for this group
int Function CheckoutAggressors(int id)
  Form[] potentials = Aggressors[id].ToArray()
  Debug.Trace("[Kudasai] Checking out Aggressors at ID = " + id + " ;; Pre Checkout = " + potentials)
  int i = 0
  While(i < potentials.Length)
    If(Utility.RandomInt(0, 99) < 45)
      Debug.Trace("[Kudasai] Checking out " + potentials[i])
      Actor that = potentials[i] as Actor
      Aggressors[id].RemoveAddedForm(that)
      Kudasai.SetLinkedRef(that, none, rNPC[id])
      ClearAlias(that)
    EndIf
    i += 1
  EndWhile
  Debug.Trace("[Kudasai] Post Checkout = " + Aggressors[id].ToArray())
  return Aggressors[id].GetSize()
EndFunction

; FormLists are list of forms, yees :<
; Need to manually cast them to Actors one by one. There should never be a non actor in this list
Actor[] Function TranslateToActorArray(Form[] list)
  Actor[] ret = PapyrusUtil.ActorArray(list.Length)
  int i = 0
  While(i < list.Length)
    ret[i] = list[i] as Actor
    i += 1
  EndWhile
  return ret
EndFunction

; 50 Aliases total and Im workin on Actors, utility to remove a specific Alias from the Quest
Function ClearAlias(ObjectReference what)
  Alias[] aliases = GetAliases()
  int i = 0
  While(i < aliases.Length)
    ReferenceAlias refalias = aliases[i] as ReferenceAlias
    ObjectReference that = refalias.GetReference()
    If (that == what)
      refalias.Clear()
    EndIf
    i += 1
  EndWhile
EndFunction

Function ClearGroup(int id)
  Debug.Trace("Cleargroup in ID = " + id + " Victims.Length = " + Victims.Length)
  If(Victims.Length <= id || Victims[id] == none)
    return
  EndIf
  Debug.Trace("Clearing Group " + id + " with Victim = " + Victims[id])
  Kudasai.SetLinkedRef(victims[id], none, rNPC[id])
  Victims[id].RemoveFromFaction(TmpFriends)
  Victims[id] = none
  Actor[] partners = TranslateToActorArray(Aggressors[id].ToArray())
  int i = 0
  While(i < partners.Length)
    Debug.Trace("[Kudasai] Clearing out " + partners[i])
    Kudasai.SetLinkedRef(partners[i], none, rNPC[id])
    ClearAlias(partners[i])
    i += 1
  EndWhile
  Aggressors[id].Revert()
EndFunction

; Cleanup Function to remove the link of all remaining victoires stored in the quest
; Called by Stage 100, on Quest Stop
Function UnsetLinks()
  Debug.Trace("[Kudasai] <NPC Res> Unsetting Links")
  int i = 0
  While(i < Aggressors.length)
    ClearGroup(i)
    i += 1
  EndWhile
EndFunction

; Forcefully stop all currently running Scene
; The only Actors that are never skipped for Scenes are Victims
Function ForceStopScenes()
  Debug.Trace("[Kudasai] <NPC Res> Forcestopping Scenes")
  int i = 0
  While(i < Victims.length)
    If(Victims[i])
      KudasaiAnimation.StopAnimating(Victims[i], MCM)
    EndIf
    i += 1
  EndWhile
EndFunction
