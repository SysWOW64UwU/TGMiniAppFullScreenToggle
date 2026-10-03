#Requires AutoHotkey v2.0
#SingleInstance Force

SetTitleMatchMode(1)

#HotIf WinActive("Mini App:")

F11::
{
  mini := WinExist("A")
  static states := Map()

  ; ==========================================
  ; ENTER FULLSCREEN
  ; ==========================================

  if !states.Has(mini)
  {
    state := {
      x: 0,
      y: 0,
      w: 0,
      h: 0,
      controls: Map()
    }

    ; Save top-level Mini App geometry
    WinGetPos(&mx, &my, &mw, &mh, "ahk_id " mini)

    state.x := mx
    state.y := my
    state.w := mw
    state.h := mh

    ; ------------------------------------------
    ; Save every child
    ; ------------------------------------------

    controls := WinGetControlsHwnd("ahk_id " mini)

    for hwnd in controls
    {
      try
      {
        parent := DllCall(
          "GetParent",
          "Ptr", hwnd,
          "Ptr"
        )

        if !parent
          continue

        WinGetPos(
          &sx,
          &sy,
          &cw,
          &ch,
          "ahk_id " hwnd
        )

        ; Convert screen coordinates to coordinates
        ; relative to the child's actual parent.
        point := Buffer(8)

        NumPut("Int", sx, point, 0)
        NumPut("Int", sy, point, 4)

        DllCall(
          "ScreenToClient",
          "Ptr", parent,
          "Ptr", point
        )

        relX := NumGet(point, 0, "Int")
        relY := NumGet(point, 4, "Int")

        state.controls[hwnd] := {
          parent: parent,
          x: relX,
          y: relY,
          w: cw,
          h: ch
        }
      }
    }

    states[mini] := state

    ; ==========================================
    ; FULLSCREEN
    ; ==========================================

    monitor := GetMonitorFromWindow(mini)

    MonitorGet(
      monitor,
      &left,
      &top,
      &right,
      &bottom
    )

    W := right - left
    H := bottom - top

    ; Resize all children
    controls := WinGetControlsHwnd("ahk_id " mini)

    for hwnd in controls
    {
      try
        SetWindowPos(hwnd, 0, 0, W, H)
    }

    ; Resize top-level Mini App
    SetWindowPos(
      mini,
      left,
      top,
      W,
      H
    )

    ; Re-enumerate after Qt/Telegram reacts
    controls := WinGetControlsHwnd("ahk_id " mini)

    for hwnd in controls
    {
      try
        SetWindowPos(hwnd, 0, 0, W, H)
    }
  }

  ; ==========================================
  ; RESTORE
  ; ==========================================

  else
  {
    state := states[mini]

    ; Restore the top-level Mini App first.
    SetWindowPos(
      mini,
      state.x,
      state.y,
      state.w,
      state.h
    )

    Sleep(100)

    ; ------------------------------------------
    ; Restore children from parent -> child
    ; ------------------------------------------

    restored := Map()

    while restored.Count < state.controls.Count
    {
      madeProgress := false

      for hwnd, data in state.controls
      {
        if restored.Has(hwnd)
          continue

        ; Parent is ready if it is:
        ;   1. The Mini App itself, or
        ;   2. Another child that is already restored.
        parentReady := (data.parent = mini)

        if !parentReady
          parentReady := restored.Has(data.parent)

        if parentReady
        {
          SetWindowPos(
            hwnd,
            data.x,
            data.y,
            data.w,
            data.h
          )

          restored[hwnd] := true
          madeProgress := true
        }
      }

      ; Prevent an infinite loop if Telegram changes
      ; the hierarchy unexpectedly.
      if !madeProgress
        break
    }

    ; ------------------------------------------
    ; Force everything to redraw
    ; ------------------------------------------

    Sleep(100)

    DllCall(
      "RedrawWindow",
      "Ptr", mini,
      "Ptr", 0,
      "Ptr", 0,
      "UInt", 0x85
    )

    states.Delete(mini)
  }
}

#HotIf


SetWindowPos(hwnd, x, y, w, h)
{
  ; SWP_NOZORDER    0x0004
  ; SWP_NOACTIVATE  0x0010
  ; SWP_SHOWWINDOW  0x0040

  DllCall(
    "SetWindowPos",
    "Ptr", hwnd,
    "Ptr", 0,
    "Int", x,
    "Int", y,
    "Int", w,
    "Int", h,
    "UInt", 0x0054
  )
}


GetMonitorFromWindow(hwnd)
{
  WinGetPos(&x, &y, &w, &h, "ahk_id " hwnd)

  cx := x + w / 2
  cy := y + h / 2

  Loop MonitorGetCount()
  {
    MonitorGet(
      A_Index,
      &left,
      &top,
      &right,
      &bottom
    )

    if (
      cx >= left &&
      cx < right &&
      cy >= top &&
      cy < bottom
    )
      return A_Index
  }

  return MonitorGetPrimary()
}