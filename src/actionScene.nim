# Copyright (C) 2026 tatjam
# SPDX-License-Identifier: GPL-3.0-or-later

import framework/[scene, canvas, mouse, audio, text], state, config, scenes
import std/[options, strformat]

type Button = object
  x, y, w, h: float
  text: string

iterator actionButtons(): tuple[act: Action, button: Button] =
  var x = Wf / 4
  var y = Hf / 2
  var w = (Wf / 3) / 2
  var h = w

  for act in Action:
    yield (act, Button(x: x - w / 2, y: y - h / 2, w: w, h: h))
    x += Wf / 4

proc overButton(mous: Mouse, btn: Button): bool =
  return
    mous.pos.x > btn.x and mous.pos.y > btn.y and mous.pos.x < btn.x + btn.w and
    mous.pos.y < btn.y + btn.h

type ActionScene* = ref object of Scene
  state*: GameState
  hover: Option[Action] = none(Action)
  fade: Option[float] = none(float)

method update*(s: ActionScene, dt: float, ctx: Context) =
  if isSome s.fade:
    s.fade = some(s.fade.get + dt)

    if s.fade.get > 1.0:
      s.state.playTurn(get s.hover)
      goToScene sidTurn
  else:
    # Chooser GUI
    var anyHover = false
    for act, btn in actionButtons():
      if ctx.mous.overButton btn:
        if s.hover != some(act):
          beep(100, 1.0, 0.8, 1000, wSine)
        s.hover = some(act)
        anyHover = true
    if not anyHover:
      s.hover = none(Action)

    if bLeft in ctx.mous.pressed and isSome s.hover:
      s.fade = some(0.0)

method draw*(s: ActionScene, c: Canvas) =
  c.fillStyle("#edc372")
  c.fillRect(0, 0, Wf, Hf)

  for act, btn in actionButtons():
    if s.hover == some(act):
      c.fillStyle("#a48c73")
    else:
      c.fillStyle("#6e582e")
    c.strokeStyle("#000")
    c.fillRect(btn.x, btn.y, btn.w, btn.h)
    c.strokeRect(btn.x, btn.y, btn.w, btn.h)
    c.drawText(
      actionName[act], btn.x + btn.w / 2, btn.y + btn.h / 2, aCenter, "#fff", 36
    )

  c.drawText(
    "Night " & $s.state.night & "/" & $s.state.lastNight,
    Wf / 2,
    100,
    aCenter,
    "#000",
    36,
    false,
  )

  if isSome s.fade:
    c.fillStyle("#000")
    c.alpha(s.fade.get)
    c.fillRect(0, 0, Wf, Hf)
    c.alpha(1.0)
  else:
    c.drawText(
      &"Score: {s.state.score * 100:.0f}", Wf / 2, 200, aCenter, "#000", 36, false
    )
    c.drawText(
      &"Shine: {s.state.shine * 100:.0f}", Wf / 2, 150, aCenter, "#000", 36, false
    )
