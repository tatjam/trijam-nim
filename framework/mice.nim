# Copyright (C) 2026 tatjam
# SPDX-License-Identifier: GPL-3.0-or-later
# ------------------------------------------
# Utils for handling the mouse

import vecs

type Button* = enum
  bLeft
  bMiddle
  bRight

type Mouse* = object
  held*: set[Button]
  pressed*: set[Button]
  released*: set[Button]
  pos*: V2

proc intToButton(button: int): Button =
  case button
  of 0:
    return bLeft
  of 1:
    return bMiddle
  of 2:
    return bRight
  else:
    return bLeft

proc press*(k: var Mouse, button: int) =
  let b = intToButton(button)
  if b notin k.held:
    k.pressed.incl b
  k.held.incl b

proc release*(k: var Mouse, button: int) =
  let b = intToButton(button)
  k.held.excl b
  k.released.incl b

proc move*(k: var Mouse, x: int, y: int) =
  k.pos = V2(x: x.toFloat, y: y.toFloat)

proc update*(k: var Mouse) =
  k.pressed = {}
  k.released = {}
