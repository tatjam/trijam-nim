# Copyright (C) 2026 tatjam
# SPDX-License-Identifier: GPL-3.0-or-later

import framework/[sprite]

type Assets* = ref object
  background*: Sheet
  moon*: Sheet

proc loadAssets*(): Assets =
  return Assets(
    background: Sheet(img: loadImage("res/background.png"), fw: 384, fh: 288),
    moon: Sheet(img: loadImage("res/moon.png"), fw: 55, fh: 55),
  )
