# Copyright (C) 2026 tatjam
# SPDX-License-Identifier: GPL-3.0-or-later
# ------------------------------------------
# Utils for the HTML5 canvas

import std/math
import canvases

template saved*(c: Canvas, body: untyped) =
  ## Runs body between save() and restore().
  c.save()
  body
  c.restore()

proc clear*(c: Canvas, color: cstring) =
  c.fillStyle(color)
  c.fillRect(0, 0, c.width.float, c.height.float)

proc line*(c: Canvas, x0, y0, x1, y1: float) =
  c.beginPath()
  c.moveTo(x0, y0)
  c.lineTo(x1, y1)
  c.stroke()

proc fillCircle*(c: Canvas, x, y, r: float) =
  c.beginPath()
  c.arc(x, y, r, 0, TAU)
  c.fill()

proc strokeCircle*(c: Canvas, x, y, r: float) =
  c.beginPath()
  c.arc(x, y, r, 0, TAU)
  c.stroke()

proc polygon*(c: Canvas, pts: openArray[(float, float)], close = true) =
  if pts.len == 0:
    return
  c.beginPath()
  c.moveTo(pts[0][0], pts[0][1])
  for i in 1 ..< pts.len:
    c.lineTo(pts[i][0], pts[i][1])
  if close:
    c.closePath()

proc glow*(c: Canvas, x, y, r: float, color: cstring) =
  let g = c.radialGradient(x, y, 0, x, y, r)
  g.addStop(0, color)
  g.addStop(1, "rgba(0,0,0,0)")
  c.fillStyle(g)
  c.fillRect(x - r, y - r, r * 2, r * 2)

proc lightBlob*(c: Canvas, x, y, r: float) =
  c.glow(x, y, r, "rgba(255,255,255,1)")

proc tintLayer*(c: Canvas, color: cstring, a = 1.0) =
  c.saved:
    c.blend(bmSourceAtop)
    c.alpha(a)
    c.fillStyle(color)
    c.fillRect(0, 0, c.width.float, c.height.float)

proc fadeOverlay*(c: Canvas, t: float, color = "#000") =
  c.fillStyle(cstring(color))
  c.alpha(t)
  c.fillRect(0, 0, c.width.float, c.height.float)
  c.alpha(1.0)
