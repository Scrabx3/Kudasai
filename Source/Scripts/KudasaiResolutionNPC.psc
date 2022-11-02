Scriptname KudasaiResolutionNPC extends Quest

KudasaiMCM Property MCM Auto

KudasaiResolutionNPCAlias[] Property Victoires Auto
KudasaiResolutionNPCAlias[] Property Victims Auto

FormList[] Property VictoireRefs Auto
Actor[] VictimRefs

Keyword Property LinkKW Auto
Keyword Property Defeated Auto
Keyword Property ActorTypeNPC Auto

Actor[] Function GetActorReferences(KudasaiResolutionNPCAlias[] akAliases)
  Actor[] ret = PapyrusUtil.ActorArray(akAliases.Length)
  int i = 0
  While(i < akAliases.Length)
    ret[i] = akAliases[i].GetReference() as Actor
    i += 1
  EndWhile
  return PapyrusUtil.RemoveActor(ret, none)
EndFunction

bool Function CheckAssignement(Actor[] akVictims, Actor akAggressor)
  float currentdistane = 1500.0
  int ii = -1
  int i = 0
  While(i < akVictims.Length)
    float distance = akVictims[i].GetDistance(akAggressor)
    If(distance < currentdistane && (i == 0 || Utility.RandomInt(0, 99) < 30) && Kudasai.IsInterested(akVictims[0], akAggressor))  ; TODO: move into Papyrus stuff
      Kudasai.SetLinkedRef(akAggressor, akVictims[i], LinkKW)
      currentdistane = distance
      ii = i
    EndIf
    i += 1
  EndWhile
  VictoireRefs[ii].AddForm(akAggressor)
  return ii > -1
EndFunction

Function Init()
  Debug.Trace("[Kudasai] <NPC Resolution> START")
  VictimRefs = GetActorReferences(Victims)
  ; Assign a Victoire to every Victim
  int i = 0
  While(i < Victoires.Length)
    Actor victoire = Victoires[i].GetReference() as Actor
    If(victoire)
      If(CheckAssignement(VictimRefs, victoire))
        If(Kudasai.IsDefeated(victoire))
          Victoires[i].RegisterForSingleUpdate(Utility.RandomFloat(4, 17))
        Else  ; to ensure this victoire walks towards their target
          victoire.EvaluatePackage()
        EndIf
      Else
        Victoires[i].Clear()
      EndIf
    EndIf
    i += 1
  EndWhile
  SetStage(10)
  ; This only for logging >w<
  int n = 0
  While(n < VictimRefs.Length)
    Debug.Trace("[Kudasai] <NPC Resolution> Aggressor Group " + n + " = " + VictoireRefs[n].ToArray())
    n += 1
  EndWhile
  ; 7 second delay before starting adult scenes
  RegisterForSingleUpdate(7)
  RegisterForModEvent("ostim_end", "PostSceneOStim")
  RegisterForModEvent("HookAnimationEnd_Kudasai_rNPC", "PostSceneSL")
EndFunction
Event OnUpdate()
  If(GetStage() > 10)
    return
  EndIf
  int i = 0
  While(i < VictimRefs.Length)
    If(VictoireRefs[i].GetSize() == 0)
      Debug.Trace("[Kudasai] <NPC Resolution> Scene Nr. " + i + " for Victim = " + VictimRefs[i] + " has no victoires assigned")
    Else
      Debug.Trace("[Kudasai] <NPC Resolution> Creating Scene " + i + " for Victim = " + VictimRefs[i])
      Actor[] partners = CreateNewPartners(VictoireRefs[i])
      If (!partners.length) ; Only happens if all actors in this group are defeated
        Actor rescue = VictoireRefs[i].GetAt(0) as Actor
        Kudasai.RescueActor(rescue, true)
        partners = new Actor[1]
        partners[0] = rescue
        Debug.Trace("[Kudasai] <NPC Resolution> Not enough Actors found. Fallback Partners = " + partners)
      EndIf

      If(KudasaiAnimation.CreateAssault(VictimRefs[i], partners, "Kudasai_rNPC") == -1)
        Debug.Trace("[Kudasai] <NPC Resolution> Failed to start Scene " + i)
        ; HandlePostScene(i, true)
      EndIf
    EndIf
    i += 1
  EndWhile
EndEvent

Event PostSceneSL(int tid, bool hasPlayer)
  HandlePostScene(KudasaiAnimationSL.GetPositions(tid))
EndEvent
Event PostSceneOStim(string eventName, string strArg, float numArg, Form sender)
  HandlePostScene(KudasaiAnimationOStim.GetPositions(numArg as int))
EndEvent

int Function GetSceneID(Actor[] akPositions)
  int i = 0
  While(i < VictimRefs.Length)
    int where = akPositions.Find(VictimRefs[i])
    If(where > -1)
      return i
    endif
    i += 1
  EndWhile
  return -1
EndFunction

int Function CheckoutAggressors(Actor[] akOldPositions, int n)
  Debug.Trace("[Kudasai] <NPC Resolution> Checking out Aggressors at " + n)
  Form[] potentials = VictoireRefs[n].ToArray()
  int i = 0
  While(i < potentials.Length)
    Actor it = potentials[i] as Actor
    If(Utility.RandomInt(0, 99) < (25 + (akOldPositions.Find(it) > -1) as int * 25))
      VictoireRefs[n].RemoveAddedForm(it)
      ClearAlias(it)
    EndIf
    i += 1
  EndWhile
  Debug.Trace("[Kudasai] <NPC Resolution> Post Checkout = " + VictoireRefs[n].ToArray())
  return VictoireRefs[n].GetSize()
EndFunction

Function HandlePostScene(Actor[] akOldPositions, bool abLooping = false)
  int idx = GetSceneID(akOldPositions)
  Debug.Trace("[Kudasai] <NPC Resolution> Post Scene " + idx)
  If(GetStage() > 10 || CheckoutAggressors(akOldPositions, idx) == 0)
    Debug.Trace("[Kudasai] <NPC Resolution> Canceling Cycle " + idx)
    Debug.SendAnimationEvent(VictimRefs[idx], "bleedoutstart")
    ClearGroup(idx)
    return
  ElseIf(!abLooping)
    ; Debug.SendAnimationEvent(VictimRefs[idx], "KudasaiTraumeLie")
    Debug.SendAnimationEvent(VictimRefs[idx], "bleedoutstart")
  EndIf
  Utility.Wait(Utility.RandomFloat(3, 7))
  
  Actor[] partners = CreateNewPartners(VictoireRefs[idx])
  Debug.Trace("[Kudasai] <NPC Resolution> Starting new Scene with partners " + partners)
  If(!partners.Length || KudasaiAnimation.CreateAssault(VictimRefs[idx], partners, "Kudasai_rNPC") == -1)
    Debug.Trace("[Kudasai] <NPC Resolution> Failed to start Scene")
    HandlePostScene(akOldPositions, true)
  EndIf
EndFunction

; Build new Array for animation. Array does not include Victim
Actor[] Function CreateNewPartners(FormList akAggressorList)
  Form[] potentials = akAggressorList.ToArray()
  int max = KudasaiAnimation.GetAllowedParticipants(potentials.Length + 1) - 1
  Actor[] ret = PapyrusUtil.ActorArray(max)
  String racetype = ""
  int timeout = 50
  While(timeout)
    timeout -= 1
    int where = Utility.RandomInt(0, potentials.Length - 1)
    Actor it = potentials[where] as Actor
    If(it && !Kudasai.IsDefeated(it) && !KudasaiAnimation.IsAnimating(it, MCM))
      bool bValid
      If(racetype == "")
        If(it.HasKeyword(ActorTypeNPC))
          racetype = "human"
        Else
          racetype = KudasaiAnimation.GetRaceType(it)
        EndIf
        bValid = racetype != ""
      Else
        bValid = racetype == "human" && it.HasKeyword(ActorTypeNPC) || racetype == KudasaiAnimation.GetRaceType(it)
      EndIf
      If(bValid)
        int j = ret.RFind(none)
        ret[j] = it
        If(j == 0)
          return ret
        EndIf
      EndIf
    EndIf
    potentials[where] = none
  EndWhile
  return PapyrusUtil.RemoveActor(ret, none)
EndFunction

Function ClearAlias(ObjectReference akRef)
  int i = 0
  While(i < Victoires.Length)
    If(akRef == Victoires[i].GetReference())
      Victoires[i].Clear()
      return
    EndIf
    i += 1
  EndWhile
EndFunction

Function ClearGroup(int n, bool abCheckStop = true)
  Debug.Trace("[Kudasai] <NPC Resolution> Clearing assault group " + n + " | Victims Array = " + VictimRefs)
  If(VictimRefs[n] == none)
    return
  EndIf
  VictimRefs[n] = none
  Form[] forms = VictoireRefs[n].ToArray()
  int i = 0
  While(i < forms.Length)
    ClearAlias(forms[i] as ObjectReference)
    i += 1
  EndWhile
  VictoireRefs[n].Revert()
  If(abCheckStop && PapyrusUtil.CountActor(VictimRefs, none) == VictimRefs.Length)
    Debug.Trace("[Kudasai] <NPC Resolution> All groups cleared")
    Stop()
  EndIf
EndFunction

Function ForceStopScenes()
  Debug.Trace("[Kudasai] <NPC Resolution> Forcestopping Scenes")
  int i = 0
  While(i < VictimRefs.length)
    If(VictimRefs[i])
      KudasaiAnimation.StopAnimating(VictimRefs[i], MCM)
    EndIf
    i += 1
  EndWhile
EndFunction

; Called when Quest stops, make sure everything is cleared up properly
Function Cleanup()
  ForceStopScenes()
  int i = 0
  While(i < VictimRefs.Length)
    ClearGroup(i, false)
    i += 1
  EndWhile
  Debug.Trace("[Kudasai] <NPC Resolution> STOP")
EndFunction
