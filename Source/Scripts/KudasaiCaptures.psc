Scriptname KudasaiCaptures extends Quest

GlobalVariable Property Capacity Auto
{Total amount of Victims that the Ring may store}
ImageSpaceModifier Property FadeToBlackAndBackFast Auto
{Fast Fading in and out. Wind up is 0.55 seconds, fade out lasts 0.15 seconds, fade back takes 0.2 seconds}
ImageSpaceModifier Property FadeToBlackHoldImod Auto
ImageSpaceModifier Property FadeToBlackHoldBackFastImod Auto
{Same as Default, but speed up to only take 0.4 seconds}

Cell Property HoldingCell Auto
ObjectReference Property HoldingCellMarker Auto
Message Property _NoFreeSlot Auto

int Property size = 0 Auto Hidden
{Number of Victims currently stored}

GlobalVariable Property GameDay Auto
GlobalVariable Property GameMonth Auto
GlobalVariable Property GameYear Auto
GlobalVariable Property GameHour Auto

; Load & open the Captures Menu to display all captures
; The caller should register for the Callback Events "YKSelect_Accept" and "YKSelect_Cancel"
; The Accept Event sends the chosen captures name + storage ID (which is used in this Script to find and retrieve the captures)
Function OpenCapturesMenu()
  ; SetData(optionid: Number, n: String, lv: String, sx: String, loc: String, t: String, r: String, w: Boolean): Void
  int[] handles = Utility.CreateIntArray(Capacity.GetValueInt())
  UI.OpenCustomMenu("YameteKudasaiHunterSelection")
  int i = 0
  While(i < handles.Length)
    Form keyform = (GetNthAlias(i) as ReferenceAlias).GetReference()
    If(keyform)
      int iHandle = UICallback.Create("CustomMenu", "_root.main.SetData")
      If(!iHandle)
        Debug.MessageBox("Error opening Menu..")
        UI.CloseCustomMenu()
        return
      EndIf
      UICallback.PushInt(iHandle, i)
      UICallback.PushString(iHandle, StorageUtil.GetStringValue(keyform, "YK_CapturesName", "???"))
      UICallback.PushString(iHandle, StorageUtil.GetStringValue(keyform, "YK_CapturesLevel", " Lv. 0"))
      UICallback.PushString(iHandle, StorageUtil.GetStringValue(keyform, "YK_CapturesSex", "???"))
      UICallback.PushString(iHandle, StorageUtil.GetStringValue(keyform, "YK_CapturesLoc", ""))
      UICallback.PushString(iHandle, StorageUtil.GetStringValue(keyform, "YK_CapturesTime", ""))
      UICallback.PushString(iHandle, StorageUtil.GetStringValue(keyform, "YK_CapturesRarity", ""))
      UICallback.PushBool(iHandle, StorageUtil.GetIntValue(keyform, "YK_CapturesWanted", 0) as bool)
      UICallback.Send(iHandle)
    EndIf
    i += 1
  EndWhile
  UI.Invoke("CustomMenu", "_root.main.OpenMenu")
EndFunction

; Sort an Actor into the List of Defeated Victims
bool Function Store(Actor subject)
  If(size == Capacity.Value)
    Debug.Trace("[Kudasai] Cannot store subject = " + subject + " No available capacity")
    _NoFreeSlot.Show()
    return false
  EndIf
  int emptyID = GetFreeAlias()
  If(emptyID == -1)
    Debug.Trace("[Kudasai] Cannot store subject = " + subject + " EmptyID is -1?")
    _NoFreeSlot.Show()
    return false
  EndIf
  ReferenceAlias empty = GetNthAlias(emptyID) as ReferenceAlias
  ; Returns none if Actor isnt leveled (i.e. unique)
  ActorBase vicbase = Kudasai.GetTemplateBase(subject)
  Actor victim
  FadeToBlackAndBackFast.Apply()
  Utility.Wait(0.5)
  If(!vicbase)
    victim = subject
    Kudasai.RescueActor(subject, true)
  Else
    victim = subject.PlaceAtMe(vicbase) as Actor
    subject.MoveTo(HoldingCellMarker)
  EndIf
  Location subloc = victim.GetCurrentLocation()
  victim.MoveTo(HoldingCellMarker)
  empty.ForceRefTo(victim)
  Kudasai.RemoveAllItems(victim, none)
  size += 1
  ; Create Flash Entry
  ActorBase sbase = subject.GetLeveledActorBase()
  ; Cant do this in the original split cause time
  
  StorageUtil.SetStringValue(victim, "YK_CapturesName", sbase.GetName())
  StorageUtil.SetStringValue(victim, "YK_CapturesLevel", " Lv. " + subject.GetLevel())
  If(sbase.GetSex() == 1)
    StorageUtil.SetStringValue(victim, "YK_CapturesSex", "Female")
  Else
    StorageUtil.SetStringValue(victim, "YK_CapturesSex", "Male")
  EndIf
  If(subloc)
    StorageUtil.SetStringValue(victim, "YK_CapturesLoc", subloc.GetName())
  Else
    StorageUtil.SetStringValue(victim, "YK_CapturesLoc", "Wilderness")
  EndIf
  StorageUtil.SetStringValue(victim, "YK_CapturesTime", CreateGameTimeString())
  StorageUtil.SetStringValue(victim, "YK_CapturesRarity", "")
  StorageUtil.SetIntValue(victim, "YK_CapturesWanted", 0) ; TODO: Write a func to see if this Actor is used in a bounty quest?
EndFunction

bool Function RescueByReference(Actor subject, ObjectReference whereto = none)
  Alias[] aliases = GetAliases()
  int i = 0
  While(i < aliases.Length)
    KudasaiCapturesAlias captured = aliases[i] as KudasaiCapturesAlias
    If(captured.GetReference() as Actor == subject)
      return RescueActorByID(i, whereto)
    EndIf
    i += 1
  EndWhile
  return false
EndFunction

; Retrieve this Actor from the Actor Storage and place it at the desired Location
; If whereto == none, the Actor will be kill & forget
bool Function RescueActorByID(int index, ObjectReference whereto)
  ReferenceAlias akAlias = GetNthAlias(index) as ReferenceAlias
  Actor ref = akAlias.GetReference() as Actor
  float Z = whereto.GetAngleZ()
  float moveX = 50.0 * Math.Sin(Z)
  float moveY = 50.0 * Math.Cos(Z)
  If(whereto)
    Kudasai.DefeatActor(ref, true)
    FadeToBlackAndBackFast.Apply() ;TODO: Add FadeToBlackHoldImod.Apply() Spawning the NPC takes ~1 second, too long for the fast one
    Utility.Wait(0.50)
    FadeToBlackAndBackFast.PopTo(FadeToBlackHoldImod)
    ref.MoveTo(whereto, moveX, moveY)
    Debug.SendAnimationEvent(ref, "BleedoutStart")
    Utility.Wait(0.4)
    FadeToBlackHoldImod.PopTo(FadeToBlackHoldBackFastImod)
  Else
    ActorBase refbase = ref.GetLeveledActorBase()
    If(refbase.IsEssential())
      refbase.SetEssential(false)
    EndIf
    ref.Kill(Game.GetPlayer())
  EndIf
  akAlias.Clear()
  size -= 1
  StorageUtil.UnsetStringValue(ref, "YK_CapturesName")
  StorageUtil.UnsetStringValue(ref, "YK_CapturesLevel")
  StorageUtil.UnsetStringValue(ref, "YK_CapturesSex")
  StorageUtil.UnsetStringValue(ref, "YK_CapturesLoc")
  StorageUtil.UnsetStringValue(ref, "YK_CapturesTime")
  StorageUtil.UnsetStringValue(ref, "YK_CapturesRarity")
  StorageUtil.UnsetIntValue(ref, "YK_CapturesWanted")
  return true
EndFunction

Actor[] Function GetAllCaptured()
  Actor[] captures = PapyrusUtil.ActorArray(size)
  Alias[] aliases = GetAliases()
  int i = 0
  int ii = 0
  While(i < aliases.Length)
    Actor captured = (aliases[i] as ReferenceAlias).GetReference() as Actor
    If(captured != none)
      captures[ii] = captured
      ii += 1
    EndIf
    i += 1
  EndWhile
  return captures
EndFunction

int Function GetFreeAlias()
  Alias[] aliases = GetAliases()
  int i = 0
  While(i < Capacity.Value)
    ReferenceAlias that = aliases[i] as ReferenceAlias
    If(that.GetReference() == none)
      return i
    EndIf
    i += 1
  EndWhile
  return -1
EndFunction

String Function CreateGameTimeString()
  String ret
  int day = GameDay.GetValueInt()
  If(day == 1)
    ret = "1st of "
  ElseIf(day == 2)
    ret = "2nd of "
  ElseIf(day == 3)
    ret = "3rd of "
  Else
    ret = day + "th of "
  EndIf
  int month = GameMonth.GetValueInt() + 1
  If(month == 1)
    ret += "of Morning Star "
  ElseIf(month == 2)
    ret += "of Sun's Dawn "
  ElseIf(month == 3)
    ret += "of First Seed "
  ElseIf(month == 4)
    ret += "of Rain's Hand "
  ElseIf(month == 5)
    ret += "of Second Seed "
  ElseIf(month == 6)
    ret += "of Mid Year "
  ElseIf(month == 7)
    ret += "of Sun's Height "
  ElseIf(month == 8)
    ret += "of Last Seed "
  ElseIf(month == 9)
    ret += "of Hearthfire "
  ElseIf(month == 10)
    ret += "of Frost Fall "
  ElseIf(month == 11)
    ret += "of Sun's Dusk "
  ElseIf(month == 12)
    ret += "of Evening Star "
  EndIf
  ret += "4E " + GameYear.GetValueInt() + " / "
  float hour = GameHour.Value
  ret += (hour as int) + ":"
  int minute = ((GameHour.Value - hour) * 60) as int
  ret += minute
  Debug.Trace("[Kudasai] Returning Date = " + ret)
  return ret
EndFunction
