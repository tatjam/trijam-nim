# Copyright (C) 2026 tatjam
# SPDX-License-Identifier: GPL-3.0-or-later

import framework/[scene, canvas, audio]

type Play* = ref object of Scene
  score: int

method update*(s: Play, dt: float, ctx: Context) =
  discard

method draw*(s: Play, c: Canvas) =
  discard
