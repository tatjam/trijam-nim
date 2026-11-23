# Copyright (C) 2026 tatjam
# SPDX-License-Identifier: GPL-3.0-or-later

import framework/scenes

type
  SceneId* = enum
    sidLoad, sidHello

  SceneData* = object
    kind*: SceneId

var factories: array[SceneId, proc(data: SceneData): Scene]

proc register*(id: SceneId, make: proc(data: SceneData): Scene) =
  factories[id] = make

proc goToScene*(id: SceneId) =
  nextScene(factories[id](SceneData(kind: id)))
