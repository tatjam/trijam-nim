# Copyright (C) 2026 tatjam
# SPDX-License-Identifier: GPL-3.0-or-later

import framework/[scenes, canvases, texts, canvas_utils, gui, audio]
import std/strformat
import config, state, flow, style

const
  btnX = Wf / 2 - 200.0
  btnY = 500.0
  btnW = 400.0
  btnH = 100.0

  causeName: array[Cause, string] =
    [cMoon: "The moon", cCrowd: "The crowd", cSelf: "Itself"]
  causeColor: array[Cause, string] =
    [cMoon: "#58789e", cCrowd: "#b08355", cSelf: "#8a5f8a"]

type EndingScene* = ref object of Scene
  state*: GameState
  hover: bool = false

proc playAgainButton(): GuiButton =
  GuiButton(x: btnX, y: btnY, w: btnW, h: btnH, text: "Play again")

method update*(s: EndingScene, dt: float, ctx: Context) =
  let btn = playAgainButton()
  let lastHover = s.hover
  s.hover = btn.hovered(ctx.mous)

  if s.hover and not lastHover:
    beep(100, 1.0, 0.8, 1000, wSine)

  if btn.clicked(ctx.mous):
    s.state.reset()
    goToScene sidAction

method draw*(s: EndingScene, c: Canvas) =
  c.clear("#edc372")

  if s.state.shine <= 0:
    c.drawText("The lamp was burned out by...", Wf / 2, 90, aCenter, "#6e582e", 44)

    var totalTally = 0.0
    for cause in Cause:
      totalTally += s.state.tally[cause]
    if totalTally < 0.001:
      totalTally = 0.001

    let barW = 560.0
    let barX = Wf / 2 - barW / 2
    let barH = 48.0
    let gap = 24.0
    let startY = 170.0

    for cause in Cause:
      let y = startY + float(ord(cause)) * (barH + gap)
      let frac = s.state.tally[cause] / totalTally
      GuiBar(
        x: barX, y: y, w: barW, h: barH,
        fraction: frac, label: causeName[cause], color: causeColor[cause]
      ).draw(c, barStyle)
  else:
    c.drawText(
      "You managed to keep the lamp shining!", Wf / 2, 90, aCenter, "#6e582e", 44
    )
    c.drawText(
      &"Final Score: {s.state.score * 100:.0f}", Wf / 2, 200, aCenter, "#000", 36, false
    )

  playAgainButton().draw(c, buttonStyle, s.hover)
