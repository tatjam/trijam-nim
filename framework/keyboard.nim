# Copyright (C) 2026 tatjam
# SPDX-License-Identifier: GPL-3.0-or-later

import std/[sets]

export sets

type Keyboard* = object
  held*: HashSet[string]
  pressed*: HashSet[string]
  released*: HashSet[string]

proc press*(k: var Keyboard, key: string) =
  if key notin k.held:
    k.pressed.incl key
  k.held.incl key

proc release*(k: var Keyboard, key: string) =
  k.held.excl key
  k.released.incl key

proc update*(k: var Keyboard) =
  k.pressed.clear()
  k.released.clear()
