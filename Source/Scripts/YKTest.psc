Scriptname YKTest extends ActiveMagicEffect  

Event OnEffectStart(Actor akTarget, Actor akCaster)
  If(!akTarget)
    Debug.Trace("Target is none")
    return
  EndIf
  ActorBase myTemplate = KudasaiInternal.GetTemplateBase(akTarget)
  If(myTemplate)
    Debug.Trace("myTemplate = " + myTemplate)
    akCaster.PlaceAtMe(myTemplate)
  EndIf
EndEvent