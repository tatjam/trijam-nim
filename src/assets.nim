# Copyright (C) 2026 tatjam
# SPDX-License-Identifier: GPL-3.0-or-later

import framework/sprites

const manNames* = ["hat-man", "bearded", "woman"]

type Assets* = ref object
  background*: Sheet
  middleground*: Sheet
  lamp*: Sheet
  crowdIdle*: array[manNames.len, Sheet]
  crowdWalk*: array[manNames.len, Sheet]
  moon*: Sheet

  litHouse*: Sheet
  litChurch*: Sheet

proc loadAssets*(): Assets =
  result = Assets(
    background: Sheet(img: loadImage("res/background.png"), fw: 384, fh: 288),
    middleground: Sheet(img: loadImage("res/middleground.png"), fw: 650, fh: 350),
    lamp: Sheet(img: loadImage("res/street-lamp.png"), fw: 35, fh: 108),
    moon: Sheet(img: loadImage("res/moon.png"), fw: 55, fh: 55),
    litHouse: Sheet(img: loadImage("res/window_lit.png"), fw: 104, fh: 80),
    litChurch: Sheet(img: loadImage("res/church_lit.png"), fw: 91, fh: 80),
  )

  for i, name in manNames:
    if name == "woman":
      result.crowdWalk[i] = Sheet(
        img: loadImage(cstring("res/" & name & "-walk.png")), fw: 37, fh: 52, frames: 6
      )
      result.crowdIdle[i] = Sheet(
        img: loadImage(cstring("res/" & name & "-idle.png")), fw: 37, fh: 52, frames: 7
      )
    elif name == "hat-man":
      result.crowdWalk[i] = Sheet(
        img: loadImage(cstring("res/" & name & "-walk.png")), fw: 39, fh: 52, frames: 6
      )
      result.crowdIdle[i] = Sheet(
        img: loadImage(cstring("res/" & name & "-idle.png")), fw: 39, fh: 52, frames: 4
      )
    else:
      result.crowdWalk[i] = Sheet(
        img: loadImage(cstring("res/" & name & "-walk.png")), fw: 40, fh: 52, frames: 6
      )
      result.crowdIdle[i] = Sheet(
        img: loadImage(cstring("res/" & name & "-idle.png")), fw: 40, fh: 52, frames: 5
      )

let res* = loadAssets()
