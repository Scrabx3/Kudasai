Scriptname KudasaiRPlayerAlias extends ReferenceAlias  

State Exhausted
  ; This State acts as a buffer to leave the Player non hostile towards Victoires. This State will last
  ; 15 seconds and is canceled early if the player does potentially "provoking"
	Event OnBeginState()
		Debug.Trace("[Kudasai] <Assault> PLAYER SCRIPT -> Enter State = Exhausted")
		Kudasai.RescueActor(Game.GetPlayer(), false)
    ; IDEA: Add an "exhausted" movement Idle here

		RegisterForActorAction(8) ; Drawing Weapon
		RegisterForMenu("ContainerMenu") ; "Looting near Victoires"
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
    GetOwningQuest().Stop()
	EndEvent
EndState

