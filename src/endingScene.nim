# Copyright (C) 2026 tatjam
# SPDX-License-Identifier: GPL-3.0-or-later

import framework/[scene, canvas, mouse, audio, text], state, config, scenes
import std/strformat

let btnX = Wf / 2 - 200.0
let btnY = 500.0
let btnW = 400.0
let btnH = 100.0

type EndingScene* = ref object of Scene
  state*: GameState
  hover: bool = false

method update*(s: EndingScene, dt: float, ctx: Context) =
  let lastHover = s.hover
  s.hover =
    ctx.mous.pos.x > btnX and ctx.mous.pos.y > btnY and ctx.mous.pos.x < btnX + btnW and
    ctx.mous.pos.y < btnY + btnH

  if s.hover and not lastHover:
    beep(100, 1.0, 0.8, 1000, wSine)

  if s.hover and bLeft in ctx.mous.pressed:
    s.state.reset
    goToScene sidAction

method draw*(s: EndingScene, c: Canvas) =
  c.fillStyle("#edc372")
  c.fillRect(0, 0, Wf, Hf)

  if s.state.shine <= 0:
    c.drawText("The lamp was burned out by...", Wf / 2, 90, aCenter, "#6e582e", 44)

    var totalTally = 0.0
    for cause in Cause:
      totalTally += s.state.tally[cause]
    if totalTally < 0.001:
      totalTally = 0.001

    const causeName: array[Cause, string] =
      [cMoon: "The moon", cCrowd: "The crowd", cSelf: "Itself"]
    const causeColor: array[Cause, string] =
      [cMoon: "#58789e", cCrowd: "#b08355", cSelf: "#8a5f8a"]

    let barW = 560.0
    let barX = Wf / 2 - barW / 2
    let barH = 48.0
    let gap = 24.0
    let startY = 170.0

    for cause in Cause:
      let y = startY + float(ord(cause)) * (barH + gap)
      let frac = s.state.tally[cause] / totalTally

      c.drawText(causeName[cause], barX - 24, y + barH / 2, aRight, "#6e582e", 32)

      c.fillStyle("#c9a86a") # empty track
      c.fillRect(barX, y, barW, barH)

      c.fillStyle(cstring(causeColor[cause])) # filled portion
      c.fillRect(barX, y, barW * frac, barH)

      c.strokeStyle("#6e582e")
      c.strokeRect(barX, y, barW, barH)

      let pct = int(frac * 100.0 + 0.5)
      c.drawText($pct & "%", barX + barW + 24, y + barH / 2, aLeft, "#6e582e", 28)
  else:
    c.drawText(
      "You managed to keep the lamp shining!", Wf / 2, 90, aCenter, "#6e582e", 44
    )
    c.drawText(
      &"Final Score: {s.state.score * 100:.0f}", Wf / 2, 200, aCenter, "#000", 36, false
    )
  c.alpha(1.0)
  if s.hover:
    c.fillStyle("#a48c73")
  else:
    c.fillStyle("#6e582e")

  c.strokeStyle("#000")
  c.fillRect(btnX, btnY, btnW, btnH)
  c.strokeRect(btnX, btnY, btnW, btnH)
  c.drawText("Play again", btnX + btnW / 2, btnY + btnH / 2, aCenter, "#fff", 36)
