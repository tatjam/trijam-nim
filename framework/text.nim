# Copyright (C) 2026 tatjam
# SPDX-License-Identifier: GPL-3.0-or-later

import std/strformat
import canvas

type Align* = enum
  aLeft = "left"
  aCenter = "center"
  aRight = "right"

proc font*(c: Ctx, f: cstring) {.importjs: "#.font = #".}
proc textAlign*(c: Ctx, a: cstring) {.importjs: "#.textAlign = #".}
proc textBaseline*(c: Ctx, b: cstring) {.importjs: "#.textBaseline = #".}

proc drawText*(
    ctx: Ctx,
    s: string,
    x, y: float,
    align = aCenter,
    color = "#fff",
    size = 16,
    shadow = true,
) =
  ctx.font(cstring(&"{size}px monospace"))
  ctx.textAlign(cstring($align))
  ctx.textBaseline("middle")
  if shadow:
    ctx.fillStyle("#000")
    ctx.fillText(cstring(s), x + 1, y + 1)
  ctx.fillStyle(cstring(color))
  ctx.fillText(cstring(s), x, y)
