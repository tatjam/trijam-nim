# Copyright (C) 2026 tatjam
# SPDX-License-Identifier: GPL-3.0-or-later
# ------------------------------------------
# Interpolation and easing curves

import std/math
import vecs

func lerp*(a, b: V2, t: float): V2 =
  v2(a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t)

func lerp*(a, b, t: float): float =
  a + (b - a) * t

func clamp01*(t: float): float =
  max(0.0, min(1.0, t))

func smoothstep*(t: float): float =
  let x = clamp01(t)
  x * x * (3.0 - 2.0 * x)

func smootherstep*(t: float): float =
  let x = clamp01(t)
  x * x * x * (x * (x * 6.0 - 15.0) + 10.0)

func easeInQuad*(t: float): float =
  let x = clamp01(t)
  x * x

func easeOutQuad*(t: float): float =
  let x = clamp01(t)
  1.0 - (1.0 - x) * (1.0 - x)

func easeInOutQuad*(t: float): float =
  let x = clamp01(t)
  if x < 0.5:
    2.0 * x * x
  else:
    1.0 - pow(-2.0 * x + 2.0, 2.0) / 2.0

func easeOutCubic*(t: float): float =
  let x = clamp01(t)
  1.0 - pow(1.0 - x, 3.0)

func easeInOutCubic*(t: float): float =
  let x = clamp01(t)
  if x < 0.5:
    4.0 * x * x * x
  else:
    1.0 - pow(-2.0 * x + 2.0, 3.0) / 2.0

func easeOutBack*(t: float): float =
  let x = clamp01(t)
  let c1 = 1.70158
  let c3 = c1 + 1.0
  1.0 + c3 * pow(x - 1.0, 3.0) + c1 * pow(x - 1.0, 2.0)
