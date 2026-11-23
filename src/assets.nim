# Copyright (C) 2026 tatjam
# SPDX-License-Identifier: GPL-3.0-or-later

import framework/sprites

type Assets* = ref object
  # player*: Sheet
  # background*: Sheet

proc loadAssets*(): Assets =
  result = Assets()
  # result.player = Sheet(img: loadImage("res/player.png"), fw: 32, fh: 32)
  # result.background = Sheet(img: loadImage("res/bg.png"), fw: 384, fh: 288)

let assets* = loadAssets()
