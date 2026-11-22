# Copyright (C) 2026 tatjam
# SPDX-License-Identifier: GPL-3.0-or-later

import framework/scene

type SceneId* = enum
  sidAction
  sidTurn
  sidEnding

var factories: array[SceneId, proc(): Scene]

proc register*(id: SceneId, make: proc(): Scene) =
  factories[id] = make

proc goToScene*(id: SceneId) =
  assert factories[id] != nil, "scene not registered"
  nextScene(factories[id]())
