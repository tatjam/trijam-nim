import state, scenes, state, actionScene, turnScene
import framework/scene

let gameState = GameState()

register(
  sidAction,
  proc(): Scene =
    ActionScene(state: gameState),
)
register(
  sidTurn,
  proc(): Scene =
    TurnScene(state: gameState),
)

# var startScene* = ActionScene(state: gameState)
var startScene* = TurnScene(state: gameState)
