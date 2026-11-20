# Copyright (C) 2026 tatjam
# SPDX-License-Identifier: GPL-3.0-or-later

import std/dom
import canvas, context, keyboard, mouse, scene, audio, src/[config]

var
  c = initCanvas("c", W, H)
  ctx = Context()

  # For constant timestepping
  acc, last = 0.0

let cElem = document.getElementById("c")

window.addEventListener(
  "keydown",
  proc(e: Event) =
    let k = $KeyboardEvent(e).key
    ctx.keys.press k
    if k in gameKeys:
      e.preventDefault()
    unlockAudio(),
)
window.addEventListener(
  "keyup",
  proc(e: Event) =
    let k = $KeyboardEvent(e).key
    ctx.keys.release k
    if k in gameKeys:
      e.preventDefault()
    unlockAudio(),
)

cElem.addEventListener(
  "mouseMove",
  proc(e: Event) =
    let mev = MouseEvent(e)
    ctx.mous.move(mev.offsetX, mev.offsetY)
    e.preventDefault(),
)

cElem.addEventListener(
  "mousedown",
  proc(e: Event) =
    ctx.mous.press MouseEvent(e).button
    e.preventDefault()
    unlockAudio(),
)

cElem.addEventListener(
  "contextmenu",
  proc(e: Event) =
    e.preventDefault(),
)

cElem.addEventListener(
  "mouseup",
  proc(e: Event) =
    ctx.mous.release MouseEvent(e).button
  ,
)

proc frame(ms: float) =
  let t = ms / 1000.0
  acc += min(t - last, 0.25)
  last = t
  while acc >= dt:
    updateScene(dt, ctx)
    acc -= dt

  ctx.keys.update
  ctx.mous.update

  drawScene(c)
  changeSceneIfNeeded()

  requestFrame(frame)

nextScene config.startScene
changeSceneIfNeeded()
c.smoothing false
requestFrame(frame)
