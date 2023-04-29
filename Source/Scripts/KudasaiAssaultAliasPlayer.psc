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
		UnregisterForActorAction(8)
    Acheron.ReleaseActor(Game.GetPlayer())
    KudasaiAssault scr = GetOwningQuest() as KudasaiAssault
    scr.SetStage(120)
		scr.CheckStopConditions()
	EndEvent
EndState

