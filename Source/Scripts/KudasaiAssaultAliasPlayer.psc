Scriptname KudasaiAssaultAliasPlayer extends ReferenceAlias  

State Exhausted
	Event OnBeginState()
		If(GetOwningQuest().GetStage() > 300)
			return
		EndIf
		Debug.Trace("[Kudasai] <Assault> PLAYER SCRIPT -> Enter State = Exhausted")
		Acheron.RescueActor(Game.GetPlayer(), false)
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
		GotoState("")
	EndEvent

	Event OnMenuOpen(string menuName)
		Debug.Trace("[Kudasai] <Assault> PLAYER SCRIPT -> OnMenuOpen")
		GotoState("")
	EndEvent

	Event OnUpdate()
		Debug.Trace("[Kudasai] <Assault> PLAYER SCRIPT -> OnUpdate")
		GoToState("")
	EndEvent

	Event OnEndState()
		UnregisterForUpdate()
		UnregisterForAllMenus()
		UnregisterForActorAction(0)
		UnregisterForActorAction(1)
		UnregisterForActorAction(3)
		UnregisterForActorAction(5)
		; UnregisterForActorAction(8)
    Acheron.ReleaseActor(Game.GetPlayer())
    GetOwningQuest().SetStage(120)
	EndEvent
EndState

