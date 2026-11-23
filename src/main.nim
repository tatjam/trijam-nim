# Copyright (C) 2026 tatjam
# SPDX-License-Identifier: GPL-3.0-or-later

import framework/loop, framework/scenes
import config, flow, action_scene, turn_scene, ending_scene

register(
  sidAction,
  proc(data: SceneData): Scene = ActionScene(state: gameState),
)
register(
  sidTurn,
  proc(data: SceneData): Scene = TurnScene(state: gameState),
)
register(
  sidEnding,
  proc(data: SceneData): Scene = EndingScene(state: gameState),
)

startLoop("c", W, H, dt, @gameKeys, ActionScene(state: gameState))
