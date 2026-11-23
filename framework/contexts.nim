# Copyright (C) 2026 tatjam
# SPDX-License-Identifier: GPL-3.0-or-later
# ------------------------------------------
# A context carries everything the HTML5 game needs for interaction

import keyboards, mice
export Keyboard, Mouse

type Context* = object
  keys*: Keyboard
  mous*: Mouse
