

$dark = {:queen => '♔', :king => '♕', :rook => '♖', :bishop => '♗', :knight => '♘', :pawn => '♙'}
$light = {:queen => '♚', :king => '♛', :rook => '♜', :bishop => '♝', :knight => '♞', :pawn => '♟'}
$emptyTile = '☐'
$crossTile = '☒'
$abc = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']

class ChessTable
    attr_accessor :chessTable, :dark, :light
    def initialize
        self.createChessTable
    end

    def createChessTable
        @chessTable = Array.new(10){Array.new(10)}
        for i in 1..8
            @chessTable[0][i] = @chessTable[9][i] = $abc[i-1]
            @chessTable[2][i] = $dark[:pawn]
            @chessTable[7][i] = $light[:pawn]
            @chessTable[i][0] = @chessTable[i][9] = 9 - i
        end

        for i in 3..6
            for j in 1..8
                @chessTable[i][j] = '☐'
            end
        end

        @chessTable[1][1] = @chessTable [1][8] = $dark[:rook]
        @chessTable[1][2] = @chessTable [1][7] = $dark[:knight]
        @chessTable[1][3] = @chessTable [1][6] = $dark[:bishop]
        @chessTable[1][4] = $dark[:king]
        @chessTable[1][5] = $dark[:queen]

        @chessTable[8][1] = @chessTable [8][8] = $light[:rook]
        @chessTable[8][2] = @chessTable [8][7] = $light[:knight]
        @chessTable[8][3] = @chessTable [8][6] = $light[:bishop]
        @chessTable[8][4] = $light[:king]
        @chessTable[8][5] = $light[:queen]

    end

    def displayChessTable
        puts
        @chessTable.each do |row|
            row.each do |el|
                print "\t#{el}"
            end
            2.times{puts}
        end
    end

end

class Piece

    attr_accessor :canMove, :movementsTable

    def initialize(row,column,table)
        @row = row
        @column = column
        self.cloneTable(table) # We don't want to modify the original array
        @chessTable = table
        @symbol = @movementsTable[@row][@column] # Piece type
    end

    def cloneTable(table)
        @movementsTable = Array.new(10){Array.new(10)}
        for i in 0..9
            for j in 0..9
                @movementsTable[i][j] = table[i][j]
            end
        end
    end

    def showPiece
        print "[#{@row}, #{@column}] = #{@symbol} \n"
    end

    def generatePossibleMovements # Where can we move that Piece?
        case @symbol
            when '♟'
                self.generatePawnMovement($light) # Can move only down
            when '♙'
                 self.generatePawnMovement($dark) # Can move only up
            when '♜'
                 self.generateRookMovement($light) # @light or @dark arguments are used to determine if there is an obstacle (same colour piece) or enemy (dif color) on the way
            when '♖'
                 self.generateRookMovement($dark)
            when '♝'
                 self.generateBishopMovement($light)
            when '♗'
                 self.generateBishopMovement($dark)
            when '♞'
                 self.generateKnightMovement($light)
            when '♘'
                 self.generateKnightMovement($dark)
            when '♚'
                 self.generateQueenMovement($light)
            when '♔'
                 self.generateQueenMovement($dark)
            when '♛'
                 self.generateKingMovement($light)
            when '♕'
                 self.generateKingMovement($dark)
        end
    end

    def invertColor color
        if color == $light
            return $dark
        else
            return $light
        end
    end

    def isEnemy?(symbol,color)
        enemyColor = self.invertColor color
        enemyColor.has_value?symbol
    end

    def inChessTable?(row,column)
        row.between?(1,8) && column.between?(1,8)
    end

    def generatePawnMovement(color)

        if color == $light
            direction = -1
        else
            direction = 1
        end

        if @movementsTable[@row + direction][@column] == '☐'
            @movementsTable[@row + direction][@column] = '☒'
        end

        [-1,1].each do |columnDirection|
            if self.isEnemy? @movementsTable[@row + direction][@column + columnDirection], color
                @movementsTable[@row + direction][@column + columnDirection] = '☒'
            end
        end

        if @row == 2 || @row == 7
            if @movementsTable[@row + 2 * direction][@column] == '☐'
                @movementsTable[@row + 2 * direction][@column] = '☒'
            end
        end

        @movementsTable

    end

    def generateRookMovement(color)

        # Check north, if obstacle (enemy, team) encounter on the way or if we arrive at edge then break

        (@row-1).downto(1) do |row|
            if @movementsTable[row][@column] != '☐'
                if !color.has_value?@movementsTable[row][@column]
                    @movementsTable[row][@column] = '☒'
                end
                break
            end
            @movementsTable[row][@column] = '☒'
        end

        # Check south

        (@row + 1).upto(8) do |row|
            if @movementsTable[row][@column] != '☐'
                if !color.has_value?@movementsTable[row][@column]
                    @movementsTable[row][@column] = '☒'
                end
                break
            end
            @movementsTable[row][@column] = '☒'
        end

        # Check West

        (@column - 1).downto(1) do |column|
            if @movementsTable[@row][column] != '☐'
                if !color.has_value?@movementsTable[@row][column]
                    @movementsTable[@row][column] = '☒'
                end
                break
            end
            @movementsTable[@row][column] = '☒'
        end

        # Check East

        (@column + 1).upto(8) do |column|
            if @movementsTable[@row][column] != '☐'
                if !color.has_value?@movementsTable[@row][column]
                    @movementsTable[@row][column] = '☒'
                end
                break
            end
            @movementsTable[@row][column] = '☒'
        end

        @movementsTable

    end

    def generateKnightMovement(color)
        directions = [[-1,-2],[-2,-1],[-2,1],[-1,2],[1,2],[2,1],[2,-1],[1,-2]]
        directions.each do |direction|
            if inChessTable? @row + direction[0], @column + direction[1]
                if @movementsTable[@row + direction[0]][@column + direction[1]] == '☐' || (!color.has_value?@movementsTable[@row+direction[0]][@column+direction[1]])
                    @movementsTable[@row + direction[0]][@column + direction[1]] = '☒'
                end
            end
        end
        @movementsTable
    end

    def generateBishopMovement(color)

        # Check North West

        row = @row - 1
        column = @column - 1
        loop do
            if row == 0 || column == 0
                break
            end
            if @movementsTable[row][column] != '☐'
                if !color.has_value?@movementsTable[row][column]
                    @movementsTable[row][column] = '☒'
                end
                break
            end
            @movementsTable[row][column] = '☒'
            row -= 1
            column -= 1
        end

        # Check North East

        row = @row - 1
        column = @column + 1
        loop do
            if row == 0 || column == 9
                break
            end
            if @movementsTable[row][column] != '☐'
                if !color.has_value?@movementsTable[row][column]
                    @movementsTable[row][column] = '☒'
                end
                break
            end
            @movementsTable[row][column] = '☒'
            row -= 1
            column += 1
        end

        # Check South East

        row = @row + 1
        column = @column + 1
        loop do
            if row == 9 || column == 9
                break
            end
            if @movementsTable[row][column] != '☐'
                if !color.has_value?@movementsTable[row][column]
                    @movementsTable[row][column] = '☒'
                end
                break
            end
            @movementsTable[row][column] = '☒'
            row += 1
            column += 1
        end

        # Check South West

        row = @row + 1
        column = @column - 1
        loop do
            if row == 9 || column == 0
                break
            end
            if @movementsTable[row][column] != '☐'
                if !color.has_value?@movementsTable[row][column]
                    @movementsTable[row][column] = '☒'
                end
                break
            end
            @movementsTable[row][column] = '☒'
            row += 1
            column -= 1
        end

        @movementsTable
    end

    def generateQueenMovement(color)
        generateBishopMovement(color)
        generateRookMovement(color)
        @movementsTable
    end

    def generateKingMovement(color)
        [[-1,-1],[-1,0],[-1,1],[0,1],[1,1],[1,0],[1,-1],[0,-1]].each do |direction|
            if inChessTable? @row + direction[0], @column + direction[1]
                if @movementsTable[@row + direction[0]][@column + direction[1]] == '☐' || (!color.has_value?@movementsTable[@row+direction[0]][@column+direction[1]])
                    @movementsTable[@row + direction[0]][@column + direction[1]] = '☒'
                end
            end
        end
        @movementsTable
    end

    def showPossibleMovements # Generate an array with all the possible moves of that piece
        generatePossibleMovements.each do |row|
            row.each do |el|
                print "\t#{el}"
            end
            puts
            puts
        end
    end

    def canMove?
        @movementsTable.each do |row|
            row.each do |item|
                if item == '☒'
                    return true
                end
            end
        end
        false
    end

    def movePiece
        loop do
            print "Where to move? (eg. a1, b5..) : "
            position = gets.chomp
            row = 9 - position[1].to_i
            column = position[0].ord - 96
            if @movementsTable[row][column] == '☒'
                @chessTable[row][column] = @symbol
                @chessTable[@row][@column] = '☐'
                return @chessTable
            end
            print "Invalid position - "
        end
    end
end

class Player

    @@numberOfPlayers = 1

    attr_accessor :name, :color, :capturedPieces, :focusPiece

    def initialize

        # The name of the player

        print "Player #{@@numberOfPlayers} name: "
        @name = gets.chomp

        # The color of this player picies
        @color = @@numberOfPlayers.odd? ? $light : $dark

        # The pieces captured by this player
        @capturedPieces = []

        @@numberOfPlayers += 1

    end


    def playOn chessTable, feedback

        case feedback
            when 0
                self.move
            when 1
                self.move(true)
        end

        @feedback

    end

    def move(isCheck = false)

        if isCheck
            # The king is automatically selected for the player
            @focusPiece = self.getKing
        else
            # Player must select one of his valid pieces
            @focusPiece = self.selectPiece
        end

        # Player must select a valid destination for the piece
        @destination = self.selectDestination

        # The piece will move to that destination
        @focusPiece.moveTo(@destination)

    end

    def selectPiece

        # Interactive piece selection repeated until a valid piece is select
        # or r is entered, for reasing

    end


end

class Game

    attr_accessor :chessTable, :movementTable, :player1, :player2, :currentPlayer, :gameOver, :isCheck, :isCheckMate, :feedback

    def initialize

        # Player 1
        @player1 = Player.new

        # Player 2
        @player2 = Player.new

        # Chess Table
        @chessTable = ChessTable.new

        # Movements Table
        @movementTable = ChessTable.new

        # Game will have at least one Round
        @gameOver = false

    end

    def start

        # Player 1 vs Player 2
        print "\n\t#{@player1.name} vs #{@player2.name}\n"

        # Display initial Chess Table
        @chessTable.displayChessTable

        # Continue game until Game is Over
        loop do
            self.continueGame
            if self.isGameOver? # Game Over
                self.gameOver
                break
            end
        end
    end

    def continueGame

        # Use the feedback before the next move
        self.useFeedback

        @currentPlayer.playOn @chessTable, @feedback

        # Change from player 1 to player 2 and viceversa
        self.togglePlayer


        # Display actual Chess Table
        @chessTable.displayChessTable

    end

    def useFeedback # Whe use the feedback to determine the current state of the game

        # Feedback is the state of the game
        #   0 - normal round
        #   1 - check
        #   2 - check mate
        #   3 - resignition
        #   4 - time out
        #   5 - draw

        case @feedback
        when 1
            @isCheck = true
        when 2
            @isCheckMate = true
        end

    end

    def tooglePlayer

        # Change from player 1 to player 2 and viceversa

        if @currentPlayer == @player1
            @currentPlayer = @player2
        else
            @currentPlayer = @player1
        end

    end

    def isGameOver? # If it is check mate then the game is over, more to come

        @gameOver = @isCheckMate
        @gameOver

    end

end


def main

    game = Game.new

    game.start

end

main