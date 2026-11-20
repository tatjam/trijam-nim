# Copyright (C) 2026 tatjam
# SPDX-License-Identifier: GPL-3.0-or-later

import canvas, std/math

type
  Image* {.importc.} = ref object
    complete*: bool
    naturalWidth*: int

  Sheet* = object
    img*: Image
    fw*, fh*: int

proc newImage(): Image {.importjs: "new Image()".}
proc `src=`(i: Image, s: cstring) {.importjs: "#.src = #".}
proc drawImage*(
  c: Canvas, i: Image, sx, sy, sw, sh, dx, dy, dw, dh: float
) {.importjs: "#.drawImage(@)".}

var pending: seq[Image]

func ready(i: Image): bool =
  i.complete and i.naturalWidth > 0

proc loadImage*(path: cstring): Image =
  result = newImage()
  result.src = path
  pending.add result

proc loadImageProgress*(): float =
  let total = pending.len
  var loaded = 0
  for i in pending:
    if i.ready:
      loaded += 1

  return loaded / total

proc drawFrame*(c: Canvas, s: Sheet, frame: int, x, y: float, scale = 1.0) =
  if not s.img.ready:
    return
  let cols = s.img.naturalWidth div s.fw
  c.drawImage(
    s.img,
    ((frame mod cols) * s.fw).float,
    ((frame div cols) * s.fh).float,
    s.fw.float,
    s.fh.float,
    x.round,
    y.round,
    s.fw.float * scale,
    s.fh.float * scale,
  )
