Scriptname KudasaiRPlayerAlias extends ReferenceAlias  

State Exhausted
  ; This State acts as a buffer to leave the Player non hostile towards Victoires. This State will last
  ; 15 seconds and is canceled early if the player does potentially "provoking"
	Event OnBeginState()
		Kudasai.RescueActor(Game.GetPlayer(), false)
    ; IDEA: Add an "exhausted" movement Idle here

		RegisterForActorAction(8) ; Drawing Weapon
		RegisterForMenu("ContainerMenu") ; "Looting near Victoires"
	EndEvent

	Event OnActorAction(int actionType, Actor akActor, Form source, int slot)
		GotoState("")
	EndEvent

	Event OnMenuOpen(string menuName)
		GotoState("")
	EndEvent

	Event OnEndState()
    GetOwningQuest().Stop()
	EndEvent
EndState

