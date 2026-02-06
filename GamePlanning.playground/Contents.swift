import UIKit

var all = [1, 2, 3, 4, 5, 6, 7, 8, 9] // list of all possible moves

var winningMoves = [
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9],
    [1, 4, 7],
    [2, 5, 8],
    [3, 6, 9],
    [1, 5, 9],
    [3, 5, 7]
]

@MainActor
func checkWinner(submittedMoves: [Int]) -> Bool {
    for moves in winningMoves {
        if moves.allSatisfy(submittedMoves.contains) {
            return true
        }
    }
    return false
}

print(checkWinner(submittedMoves: [1, 2, 4, 6]))
