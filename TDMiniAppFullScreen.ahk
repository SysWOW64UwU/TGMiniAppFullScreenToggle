#Requires AutoHotkey v2.0
#SingleInstance Force
SetTitleMatchMode(1)
FullscreenStates := Map()
#HotIf WinActive("Mini App:") || WinActive("ahk_class Qt51519QWindow")
F11::{
  Critical("On")
  SetWinDelay(-1)
  SetControlDelay(-1)  
  global FullscreenStates
  CleanupClosedWindows()
  miniHWND := WinExist("A")
  if !miniHWND
    return
  if !FullscreenStates.Has(miniHWND)
    FullscreenStates[miniHWND] := false
  if (FullscreenStates[miniHWND] == false){
    jsCommand := "window.Telegram.WebApp.expand(); window.Telegram.WebApp.requestFullscreen();"
    newState := true
  } else{
    jsCommand := "window.Telegram.WebApp.exitFullscreen();"
    newState := false
  }
  WinActivate("ahk_id " miniHWND)
  if !WinWaitActive("ahk_id " miniHWND, , 0.5)
    return
  Send("^+j")
  devtoolsHWND := WinWait("DevTools - ", , 3)
  if !devtoolsHWND{
    MsgBox("Error: WebView inspection must be enabled under TD Settings > Advanced > Experimental Settings!", "TDesktopMiniAppFullScreen", 16)
    return
  }
  WinSetTransparent(0, "ahk_id " devtoolsHWND)
  ControlSend("{Text}" jsCommand, , "ahk_id " devtoolsHWND)
  Sleep(50)
  ControlSend("{Enter}", , "ahk_id " devtoolsHWND)
  Sleep(100)
  WinHide("ahk_id " devtoolsHWND)
  if WinExist("ahk_id " miniHWND)
    WinActivate("ahk_id " miniHWND)
  FullscreenStates[miniHWND] := newState
}
#HotIf

CleanupClosedWindows(){
  global FullscreenStates
  deadWindows := []
  for hwnd, state in FullscreenStates{
    if !WinExist("ahk_id " hwnd)
      deadWindows.Push(hwnd)
  }
  for hwnd in deadWindows
    FullscreenStates.Delete(hwnd)
}