Scriptname KudasaiAssaultAliasPlayer extends ReferenceAlias  

State Exhausted
	Event OnBeginState()
		Quest q = GetOwningQuest()
		If(q.GetStageDone(105))
			Debug.Trace("[Kudasai] <Assault> Already in exhausted State")
			return
		ElseIf(q.GetStage() == 500 || q.IsStopped() || q.IsStopping())
			Debug.Trace("[Kudasai] <Assault> Enter Exhausted State but Quest is stopping")
			return
		EndIf
		GetOwningQuest().SetStage(105)
		Debug.Trace("[Kudasai] <Assault> PLAYER SCRIPT -> Enter State = Exhausted")
		Acheron.RescueActor(GetActorReference(), false)
    ; IDEA: Add an "exhausted" movement Idle here
		
		RegisterForSingleUpdate(11)	      ; Time to escape
		RegisterForActorAction(0)         ; Weapon Swing
		RegisterForActorAction(1)         ; Spell Cast
		RegisterForActorAction(3)         ; Voice Cast
		RegisterForActorAction(5)         ; Bow Draw
		; RegisterForActorAction(8)         ; Drawing Weapon
		RegisterForMenu("ContainerMenu")  ; "Looting near Victoires"
	EndEvent

	Event OnActorAction(int actionType, Actor akActor, Form source, int slot)
		Debug.Trace("[Kudasai] <Assault> PLAYER SCRIPT -> OnActorAction")
		CompleteExhaustion()
	EndEvent

	Event OnMenuOpen(string menuName)
		Debug.Trace("[Kudasai] <Assault> PLAYER SCRIPT -> OnMenuOpen")
		CompleteExhaustion()
	EndEvent

	Event OnUpdate()
		Debug.Trace("[Kudasai] <Assault> PLAYER SCRIPT -> OnUpdate")
		CompleteExhaustion()
	EndEvent

	Event OnEndState()
		Debug.Trace("[Kudasai] <Assault> Player leaving Exhausted State")
	EndEvent
EndState

Function CompleteExhaustion()
	UnregisterForUpdate()
	UnregisterForAllMenus()
	UnregisterForActorAction(0)
	UnregisterForActorAction(1)
	UnregisterForActorAction(3)
	UnregisterForActorAction(5)
	; UnregisterForActorAction(8)
  Acheron.ReleaseActor(GetActorReference())
  GetOwningQuest().SetStage(120)
	GoToState("")
EndFunction
