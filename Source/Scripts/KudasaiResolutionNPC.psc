Scriptname KudasaiResolutionNPC extends Quest

KudasaiMCM Property MCM Auto

KudasaiResolutionNPCAlias[] Property Victoires Auto
KudasaiResolutionNPCAlias[] Property Victims Auto

FormList[] Property VictoireRefs Auto
Actor[] VictimRefs

Keyword Property LinkKW Auto
Keyword Property ActorTypeNPC Auto

;/  SETUP  /;

Function Init()
  Debug.Trace("[Kudasai] <NPC Resolution> START")
  VictimRefs = GetActorReferences(Victims)
  ; Assign a Victoire to every Victim
  int i = 0
  While(i < Victoires.Length)
    Actor victoire = Victoires[i].GetReference() as Actor
    If(victoire)
      If(CheckAssignement(VictimRefs, victoire))
        If(Acheron.IsDefeated(victoire))
          Victoires[i].RegisterForSingleUpdate(Utility.RandomFloat(4, 17))
        Else  ; ensure this victoire walks towards their target
          victoire.EvaluatePackage()
        EndIf
      Else
        Victoires[i].Clear()
      EndIf
    EndIf
    i += 1
  EndWhile
  SetStage(10)
  int n = 0
  While(n < VictimRefs.Length)
    Debug.Trace("[Kudasai] <NPC Resolution> Aggressor Group " + n + " = " + VictoireRefs[n].ToArray())
    n += 1
  EndWhile
  RegisterForSingleUpdate(2)
  RegisterForModEvent("HookAnimationEnd_Kudasai_rNPC", "PostSceneSL")
EndFunction

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
    If(distance < currentdistane && (i == 0 || Utility.RandomInt(0, 99) < 30) && IsInterested(akVictims[0], akAggressor))
      Acheron.SetLinkedRef(akAggressor, akVictims[i], LinkKW)
      currentdistane = distance
      ii = i
    EndIf
    i += 1
  EndWhile
  If(ii > -1)
    VictoireRefs[ii].AddForm(akAggressor)
    return true
  EndIf
  return false
EndFunction

bool Function IsInterested(Actor akVictim, Actor akAggressor)
  String rt = KudasaiAnimation.GetRaceType(akAggressor)
  If(rt == "")
    return false
  ElseIf(rt == "Human")
    int sexV = akVictim.GetActorBase().GetSex()
    If(akAggressor.GetActorBase().GetSex() != sexV)
      If (sexV == 0)
        return MCM.bAllowFM
      Else
        return MCM.bAllowMF
      EndIf
    ElseIf(sexV == 0)
      return MCM.bAllowMM
    Else
      return MCM.bAllowFF
    EndIf
  ElseIf(!MCM.AllowedRaceType(rt))
    return false
  ElseIf(akVictim.GetActorBase().GetSex() == 0)
    return MCM.bAllowFC
  Else
    return MCM.bAllowMC
  EndIf
EndFunction

;/  CYCLE  /;

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
      Actor[] positions = CreatePositions(VictimRefs[i], VictoireRefs[i])
      If (positions.Find(none) == 1)
        ; Only happens if all actors in this group are defeated or animating
        Actor it = VictoireRefs[i].GetAt(0) as Actor
        If(KudasaiAnimation.IsAnimating(it))
          KudasaiAnimation.StopAnimating(it)
        EndIf
        If(Acheron.IsDefeated(it))
          Acheron.RescueActor(it, true)
        EndIf
        positions = new Actor[2]
        positions[0] = VictimRefs[i]
        positions[1] = it
        Debug.Trace("[Kudasai] <NPC Resolution> Not enough Actors found. Fallback Partners = " + positions)
      EndIf

      If(KudasaiAnimation.CreateAssault(positions, VictimRefs[i], "Kudasai_rNPC") == -1)
        Debug.Trace("[Kudasai] <NPC Resolution> Failed to start intro scene " + i)
        ClearGroup(i)
      EndIf
    EndIf
    i += 1
  EndWhile
EndEvent

Event PostSceneSL(int tid, bool hasPlayer)
  HandlePostScene(KudasaiAnimation.GetPositions(tid))
EndEvent

Function HandlePostScene(Actor[] akOldPositions, bool abLooping = false)
  int idx = GetSceneID(akOldPositions)
  If(idx < 0)
    return
  EndIf
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
  
  Actor[] positions = CreatePositions(VictimRefs[idx], VictoireRefs[idx])
  Debug.Trace("[Kudasai] <NPC Resolution> Starting new Scene with partners " + positions)
  If(!positions.Length || KudasaiAnimation.CreateAssault(positions, VictimRefs[idx], "Kudasai_rNPC") == -1)
    Debug.Trace("[Kudasai] <NPC Resolution> Failed to start Scene")
    HandlePostScene(akOldPositions, true)
  EndIf
EndFunction

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

Actor[] Function CreatePositions(Actor akVictim, FormList akAggressorList)
  Form[] potentials = akAggressorList.ToArray()
  Actor[] ret = new Actor[5]
  ret[0] = akVictim
  String racetype = ""
  int i = 0
  int ii = 1
  int max = KudasaiAnimation.GetAllowedParticipants(potentials.Length + 1)
  While(i < 50 && ii < max)
    int where = Utility.RandomInt(0, potentials.Length - 1)
    Actor it = potentials[where] as Actor
    If(it && !Acheron.IsDefeated(it) && !KudasaiAnimation.IsAnimating(it))
      If(racetype == "")
        ; Cant be empty or invalid, see 'CheckAssignement'
        racetype = KudasaiAnimation.GetRaceType(it)
        ret[ii] = it
        ii += 1
      ElseIf(KudasaiAnimation.GetRaceType(it) == racetype)
        ret[ii] = it
        ii += 1
      EndIf
    EndIf
    potentials[where] = none
    i += 1
  EndWhile
  return ret
EndFunction

;/  CLEANUP  /;

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

Function ClearGroup(int n)
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
  If(PapyrusUtil.CountActor(VictimRefs, none) == VictimRefs.Length)
    Debug.Trace("[Kudasai] <NPC Resolution> All groups cleared")
    Stop()
  EndIf
EndFunction

Function ForceStopScenes()
  Debug.Trace("[Kudasai] <NPC Resolution> Forcestopping Scenes")
  int i = 0
  While(i < VictimRefs.length)
    If(VictimRefs[i])
      KudasaiAnimation.StopAnimating(VictimRefs[i])
    EndIf
    i += 1
  EndWhile
EndFunction

; Called when Quest stops, make sure everything is cleared up properly
Function Cleanup()
  ForceStopScenes()
  int i = 0
  While(i < VictimRefs.Length)
    ClearGroup(i)
    i += 1
  EndWhile
  Debug.Trace("[Kudasai] <NPC Resolution> STOP")
EndFunction
