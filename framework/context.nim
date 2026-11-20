# Copyright (C) 2026 tatjam
# SPDX-License-Identifier: GPL-3.0-or-later

import keyboard, mouse
export Keyboard, Mouse

type Context* = object
  keys*: Keyboard
  mous*: Mouse
