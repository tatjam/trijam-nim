import state, scenes, state, actionScene, turnScene, endingScene, endingScene, assets
import framework/scene

let gameState = GameState()
let res = loadAssets()

register(
  sidAction,
  proc(): Scene =
    ActionScene(state: gameState),
)
register(
  sidTurn,
  proc(): Scene =
    TurnScene(state: gameState, assets: res),
)
register(
  sidEnding,
  proc(): Scene =
    EndingScene(state: gameState),
)

var startScene* = ActionScene(state: gameState)
# var startScene* = EndingScene(state: gameState)
# var startScene* = TurnScene(state: gameState, assets: res)
