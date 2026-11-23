# Copyright (C) 2026 tatjam
# SPDX-License-Identifier: GPL-3.0-or-later
# Utils for linear algebra

import std/math

type V2* = object
  x*, y*: float

func v2*(x, y: float): V2 =
  V2(x: x, y: y)

func `+`*(a, b: V2): V2 =
  v2(a.x + b.x, a.y + b.y)

func `-`*(a, b: V2): V2 =
  v2(a.x - b.x, a.y - b.y)

func `*`*(a: V2, s: float): V2 =
  v2(a.x * s, a.y * s)

func `*`*(s: float, a: V2): V2 =
  a * s

func dot*(a, b: V2): float =
  a.x * b.x + a.y * b.y

func len*(a: V2): float =
  sqrt(dot(a, a))

func norm*(a: V2): V2 =
  let l = a.len
  if l > 0:
    a * (1.0 / l)
  else:
    v2(0, 0)

proc `+=`*(a: var V2, b: V2) =
  a = a + b
