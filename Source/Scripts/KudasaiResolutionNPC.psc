Scriptname KudasaiResolutionNPC extends Quest  

KudasaiMCM Property MCM Auto
Keyword Property Defeated Auto

Keyword[] Property rNPC Auto
FormList[] Property Aggressors Auto
Actor[] Victims

; Populate the Victims array & Aggressor formlists. The quest is started through cpp which will only add linked refs
Function Init()
  Alias[] aliases = GetAliases()
  Victims = new Actor[15]
  int i = 0
  While(i < aliases.Length)
    KudasaiResolutionNPCAlias victoire = aliases[i] as KudasaiResolutionNPCAlias
    Actor subject = victoire.GetReference() as Actor
    If (subject)
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
        victoire.RegisterForSingleUpdate(Utility.RandomFloat(4, 17))
      EndIf
    EndIf
    i += 1
  EndWhile
  Victims = PapyrusUtil.RemoveActor(Victims, none)
  Debug.Trace("NPC Resolution Started, Victims = " + Victims)
  ; Start the first Scene 7 Seconds after Combat ended. All Victoires are near their Victim, so this should
  ; also be enough time for them to go near the victim to have it seem somewhat "real"
  RegisterForSingleUpdate(7)
  RegisterForModEvent("ostim_end", "PostSceneOStim")
  RegisterForModEvent("HookAnimationEnd_Kudasai_rNPC", "PostSceneSL")
EndFunction

; Start a Scene. There should be 1 Scene for every Victim
Event OnUpdate()
  int i = 0
  While(i < Victims.Length)
    Form[] list = Aggressors[i].ToArray()
    int total = KudasaiAnimation.GetAllowedParticipants(list.Length + 1)
    Actor[] positions = PapyrusUtil.ActorArray(total)
    positions[0] = Victims[n]
    total -= 1
    int n = 0
    While(n < list.Length && total > 1)
      If(!list[n].HasKeyword(Defeated))
        positions[total] = list[n] as Actor
        total -= 1
      EndIf
      n += 1
    EndWhile
    positions = PapyrusUtil.RemoveActor(positions, none)    
    ; If there are no non-defeated Victoires for this Scene, force one of them to stand up
    If (!positions.length)
      positions = new Actor[1]
      positions[0] = list[0] as Actor
      Kudasai.RescueActor(positions[0], true)
    EndIf
    ; Start a Scene for this Group
    KudasaiAnimation.CreateAssault(Victims[i], positions, "Kudasai_rNPC")
    i += 1
  EndWhile
EndEvent

Event PostSceneSL(int tid, bool hasPlayer)
  Actor[] positions = KudasaiAnimationSL.GetPositions(tid)
  HandlePostScene(positions)
EndEvent
Event PostSceneOStim(string eventName, string strArg, float numArg, Form sender)
  Actor[] positions = KudasaiAnimationOStim.GetPositions(numArg as int)
  HandlePostScene(positions)
EndEvent
; After a Scene ends, Victoires will "decide" if they want to stick around of leave their Victim be
; If they do stick around, another Scene starts. This process will repeat itself until no Victoires are left
Function HandlePostScene(Actor[] positions)
  int id = GetLoopID(positions)
  ; IDEA: alternate algorithm to remove victoires, considering only the actors in positions[] rather than everyone in the group
  If(GetStage() < 10 || CheckoutAggressors(id) == 0)
    ; I never take Victims out of their Defeat Status, only thing to do here is to set their animation again
    Debug.SendAnimationEvent(Victims[id], "bleedoutstart")
    return
  Else
    Debug.SendAnimationEvent(Victims[id], "KudasaiTraumeLie")
  EndIf
  Actor[] alist = TranslateToActorArray(Aggressors[id].ToArray())
  ; Its unlikely that an Actor is still defeated, but just in case.. dont animate if they are still defeated
  ; OnUpdate on their Script should have already taken them out by now though >:(
  int i = 0
  While(i < alist.Length)
    If(Kudasai.IsDefeated(alist[i]))
      alist = PapyrusUtil.RemoveActor(alist, alist[i])
    EndIf
    i += 1
  EndWhile
  ; A quick set down time to not rush scenes too much
  Utility.Wait(Utility.RandomFloat(3, 7))
  Actor[] newpositions = CreateNewPositions(alist)
  KudasaiAnimation.CreateAssault(Victims[id], newpositions, "Kudasai_rNPC")
EndFunction

; Scenes only allow 5 (3) Actors in total and to avoid the same actors being used in every scene, this will select a few to animate
Actor[] Function CreateNewPositions(Actor[] potentials)
  int total = KudasaiAnimation.GetAllowedParticipants(potentials.Length + 1) - 1
  If(total == potentials.Length)
    return potentials
  EndIf
  Actor[] ret = PapyrusUtil.ActorArray(total)
  int i = 0
  int ii = 0
  While(ret.find(none) > -1 && i < 50)
    int where = Utility.RandomInt(0, potentials.Length - 1)
    Actor next = potentials[where]
    If(ret.find(next) == -1)
      ret[ii] = next
      ii += 1
    EndIf
    i += 1
  EndWhile
  return PapyrusUtil.RemoveActor(ret, none)
EndFunction

; Cause the Quest handles up to 15 Groups in total, need a function to get which animevent was from
; this returns the group id - an identifier to link Victim to Victoires, so I dont process the wrong groups D:
int Function GetLoopID(Actor[] positions)
  Actor victim
  int i = 0
  While(i < Victims.Length)
    int where = positions.find(Victims[i])
    if (where > -1)
      return i
    endif
    i += 1
  EndWhile
  return -1
EndFunction

; This decides if victoires still want to "keeep going". Its actually just a RNG check. Yay.
; Returns the amount of remaining victoires for this group
int Function CheckoutAggressors(int id)
  int i = 0
  int l = Aggressors[id].GetSize()
  While(i < l)
    If(Utility.RandomInt(0, 99) < 45)
      Actor that = Aggressors[id].GetAt(i) as Actor
      ClearAlias(that)
      Aggressors[id].RemoveAddedForm(that)
      Kudasai.SetLinkedRef(that, none, rNPC[id])
    EndIf
    i += 1
  EndWhile
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

; Cleanup Function to remove the link of all remaining victoires stored in the quest
Function UnsetLinks()
  int i = 0
  While(i < Aggressors.length)
    Actor[] tmp = TranslateToActorArray(Aggressors[i].ToArray())
    int n = 0
    While(n < tmp.Length)
      Kudasai.SetLinkedRef(tmp[n], none, rNPC[i])
      n += 1
    EndWhile
    i += 1
  EndWhile
EndFunction

; Forcefully stop all currently running Scene
; The only Actors that are never skipped for Scenes are Victims
Function ForceStopScenes()
  int i = 0
  While(i < Victims.length)
    KudasaiAnimation.StopAnimating(Victims[i], MCM)
    i += 1
  EndWhile
EndFunction
