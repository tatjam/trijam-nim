# Copyright (C) 2026 tatjam
# SPDX-License-Identifier: GPL-3.0-or-later
# ------------------------------------------
# Convenient spritesheets

import canvases, canvas_utils, std/math

type
  Image* {.importc.} = ref object
    complete*: bool
    naturalWidth*: int

  Sheet* = object
    img*: Image
    fw*, fh*: int
    frames*: int

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
  if total == 0:
    return 1.0
  var loaded = 0
  for i in pending:
    if i.ready:
      loaded += 1

  return loaded / total

proc drawFrame*(
    c: Canvas,
    s: Sheet,
    frame: int,
    x, y: float,
    scale = 1.0,
    flipX = false,
    flipY = false,
) =
  if s.img.isNil or s.fw <= 0 or not s.img.ready:
    return
  let cols = max(1, s.img.naturalWidth div s.fw)
  let sx = ((frame mod cols) * s.fw).float
  let sy = ((frame div cols) * s.fh).float
  let dw = s.fw.float * scale
  let dh = s.fh.float * scale

  c.saved:
    # move the origin to the sprite's top-left; when flipped, to the edge that becomes the left
    c.translate(x.round + (if flipX: dw else: 0.0), y.round + (if flipY: dh else: 0.0))
    c.scale(if flipX: -1.0 else: 1.0, if flipY: -1.0 else: 1.0)
    c.drawImage(s.img, sx, sy, s.fw.float, s.fh.float, 0.0, 0.0, dw, dh)

proc drawAnim*(
    c: Canvas,
    s: Sheet,
    time: float,
    x, y: float,
    fps = 8.0,
    scale = 1.0,
    flipX = false,
    flipY = false,
) =
  let frame = int(floorMod(time * fps, s.frames.float))
  c.drawFrame(s, frame, x, y, scale, flipX, flipY)
