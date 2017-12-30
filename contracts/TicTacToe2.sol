pragma solidity 0.4.18;

contract TicTacToe2 {

    event NewGame(uint game_id, address player1, address player2);

    struct Game {
        address player1; // 1
        address player2; // 2
        address winner; 
        uint8 turn; // if odd, first player, if even, second player, if greater than 4 check for winner
        uint8[3][3] board; // 3 x 3 board: 0=no move ; 1=X ; 2=O
    }
    
    Game[] public games;
    
    function newGame(address player1, address player2) public returns (uint) {
        uint8[3][3] memory board;
        uint game_id = games.push(Game(player1, player2, 0, 0, board));
        NewGame(game_id - 1, player1, player2);
        return game_id - 1;
    }
    
    function getBoard(uint game_id) public view returns (uint8[3][3]) {
        return games[game_id].board;
    }
    
    function makeMove(uint game_id, uint x, uint y) public returns (address) {
        address cur_player = msg.sender;
        Game memory g = games[game_id];
        uint8 sign = 1; // if player1 sign = 1 ; if player2 sign = 2

        require(( cur_player == g.player1 || cur_player == g.player2) && g.winner == 0);
        if (g.turn == 9) return 0; // game is finished with no winner
        
        // if player2 moves first, switch Game.player1 and Game.player2 addresses
        if (g.turn == 0 && cur_player != games[game_id].player1) {
            switchPlayerPosition(game_id, cur_player);
        } else {
            if (cur_player == g.player2) sign = 2;
        }

        require(checkValidMove(g, x, y, sign));
        
        // play the move and increment turn
        games[game_id].board[x][y] = sign;
        games[game_id].turn = games[game_id].turn + 1;
        
        if (g.turn >= 4 && checkWin(g, game_id, cur_player)) return cur_player;
        
        return 0;
    }
    
    
    // Helper Functions //
    
    function checkValidMove (Game g, uint x, uint y, uint sign) private pure returns (bool) {
        require(sign % 2 == (g.turn + 1) % 2);
        require(g.board[x][y] == 0);
        return true;
    }
    
    function switchPlayerPosition(uint game_id, address newPlayer1) private {
        games[game_id].player2 = games[game_id].player1;
        games[game_id].player1 = newPlayer1;
    }
    
    function checkWin(Game g, uint game_id, address cur_player) private returns (bool) {
        uint8[3][3] memory board = g.board;
        
        for (uint i = 0; i < board.length; i++) {
            uint8 cur_sign = board[i][0]; 
            if (cur_sign == 0) break;
            
            //  check horizontal;
            for (uint j = 0; j < board[i].length; j++) {
                if (cur_sign != board[i][j]) break;
                if (j == 2) return isWinner(game_id, cur_player);
            }
            
            // check vertical
            for (uint k = 0; k < board.length; k++) {
                if (cur_sign != board[k][i]) break;
                if (k == 2) return isWinner(game_id, cur_player);
            }
        }
        
        // check diagonals;
        if (board[0][0] == board[1][1] && board[1][1] == board[2][2]) return isWinner(game_id, cur_player);
        if (board[0][2] == board[1][1] && board[1][1] == board[2][0]) return isWinner(game_id, cur_player);
        
        //no winner
        return false;
    }
    
    function isWinner(uint game_id, address winner) private returns (bool) {
        games[game_id].winner = winner;
        return true;
    }
}