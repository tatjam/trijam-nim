# Copyright (C) 2026 tatjam
# SPDX-License-Identifier: GPL-3.0-or-later

import contexts, canvases
export Context, Canvas

type Scene* = ref object of RootObj

method enter*(s: Scene) {.base.} =
  discard

method exit*(s: Scene) {.base.} =
  discard

method update*(s: Scene, dt: float, ctx: Context) {.base.} =
  discard

method draw*(s: Scene, c: Canvas) {.base.} =
  discard

var
  current: Scene
  pending: Scene

proc nextScene*(s: Scene) =
  pending = s

proc changeSceneIfNeeded*() =
  if isNil pending:
    return

  if not isNil current:
    exit current

  current = pending
  pending = nil
  enter current

proc updateScene*(dt: float, ctx: Context) =
  if isNil current:
    return

  current.update(dt, ctx)

proc drawScene*(c: Canvas) =
  if isNil current:
    return

  current.draw(c)
