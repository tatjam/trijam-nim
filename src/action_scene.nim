# Copyright (C) 2026 tatjam
# SPDX-License-Identifier: GPL-3.0-or-later

import framework/[scenes, canvases, texts, canvas_utils, gui, audio, mice]
import std/[options, strformat]
import config, state, flow, style

type ActionScene* = ref object of Scene
  state*: GameState
  hover: Option[Action] = none(Action)
  fade: Option[float] = none(float)

iterator actionButtons(): tuple[act: Action, button: GuiButton] =
  let w = (Wf / 3) / 2
  let h = w
  var x = Wf / 4
  let y = Hf / 2

  for act in Action:
    yield (
      act,
      GuiButton(x: x - w / 2, y: y - h / 2, w: w, h: h, text: actionName[act]),
    )
    x += Wf / 4

method update*(s: ActionScene, dt: float, ctx: Context) =
  if s.fade.isSome:
    s.fade = some(s.fade.get + dt)
    if s.fade.get > 1.0:
      s.state.playTurn(get s.hover)
      goToScene sidTurn
  else:
    var anyHover = false
    for act, btn in actionButtons():
      if btn.hovered(ctx.mous):
        if s.hover != some(act):
          beep(100, 1.0, 0.8, 1000, wSine)
        s.hover = some(act)
        anyHover = true
    if not anyHover:
      s.hover = none(Action)
    if bLeft in ctx.mous.pressed and s.hover.isSome:
      s.fade = some(0.0)

method draw*(s: ActionScene, c: Canvas) =
  c.clear("#edc372")

  for act, btn in actionButtons():
    btn.draw(c, buttonStyle, s.hover == some(act))

  c.drawText(
    "Night " & $s.state.night & "/" & $s.state.lastNight,
    Wf / 2, 100, aCenter, "#000", 36, false
  )

  if s.fade.isSome:
    c.fadeOverlay(s.fade.get)
  else:
    c.drawText(&"Score: {s.state.score * 100:.0f}", Wf / 2, 200, aCenter, "#000", 36, false)
    c.drawText(&"Shine: {s.state.shine * 100:.0f}", Wf / 2, 150, aCenter, "#000", 36, false)
