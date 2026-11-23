# Copyright (C) 2026 tatjam
# SPDX-License-Identifier: GPL-3.0-or-later
# ------------------------------------------
# Main game loop and entry point

import std/dom
import canvases, contexts, keyboards, mice, scenes, audio

proc startLoop*(
    canvasId: cstring,
    width, height: int,
    timestep: float,
    blockedKeys: seq[string],
    start: Scene,
) =
  var
    c = initCanvas(canvasId, width, height)
    ctx = Context()
    acc, last = 0.0

  let cElem = document.getElementById(canvasId)

  window.addEventListener(
    "keydown",
    proc(e: Event) =
      let k = $KeyboardEvent(e).key
      ctx.keys.press k
      if k in blockedKeys:
        e.preventDefault()
      unlockAudio(),
  )
  window.addEventListener(
    "keyup",
    proc(e: Event) =
      let k = $KeyboardEvent(e).key
      ctx.keys.release k
      if k in blockedKeys:
        e.preventDefault()
      unlockAudio(),
  )

  cElem.addEventListener(
    "mousemove",
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
    while acc >= timestep:
      updateScene(timestep, ctx)
      acc -= timestep

    ctx.keys.update
    ctx.mous.update

    drawScene(c)
    changeSceneIfNeeded()

    requestFrame(frame)

  nextScene start
  changeSceneIfNeeded()
  c.smoothing false
  requestFrame(frame)
