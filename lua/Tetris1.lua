-- Tetris (NES) bot script for BizHawk

-- [source: http://www.romdetectives.com/Wiki/index.php?title=Tetris_(NES)_-_RAM]
-- Memory Addresses
--
--   0000-0001 - General Temporary (Often Used as 16-bit Pointer for Indirect Addressing)
--
--   0017-0018 - Random Number (16-bit Linear Feedback Shift Register)
--
--   0019 - Previous Block (To Lessen Chance of Same Block in a Row)
--   001A - Total Block Count (Starts at 02)
--
--   0033 - VBlank Flag (Set to 01 on VBlank NMI; Cleared When Waiting for Next VBlank)
--
--   0040-005F - Copy of 0060-7F.
--   0060 - Shape X
--   0061 - Shape Y
--   0062 - Shape Type + Rotation
--   	00 - T Up
--   	01 - T Right
--   	02 - T Down
--   	03 - T Left
--   	04 - J Left
--   	05 - J Up
--   	06 - J Right
--   	07 - J Down
--   	08 - Z
--   	09 - Z Rotated
--   	0A - O
--   	0B - S
--   	0C - S Rotated
--   	0D - L Right
--   	0E - L Down
--   	0F - L Left
--   	10 - L Up
--   	11 - I
--   	12 - I Rotated
--
--   0064 - Level
--   0070 - Lines in A-Game/Remaining in B-Game
--   0073 - Score: xxxx99
--   0074 - Score: xx99xx
--   0075 - Score: 99xxxx
--
--   00A6 -
--   00A8 - Copyright Screen Timeout to Game Type Screen
--          Used as a Temporary in Other Places
--
--   00B1 - Frame Counter x1 (Incremented on VBlank NMI)
--   00B2 - Frame Counter x256
--
--   00BF - Next Block (Valid: 02, 07, 08, 0A, 0B, 0E, 12)
--
--   00C0 - Game State
--   	00 - Copyright
--   	01 - Title Screen
--   	02 - Game Type
--   	03 - Level Select
--   	04 - Playing / High Score / Victory Animation / Pause
--   	05 - Demo
--   00C1 - Game Type
--   00C2 - Music Type
--   00C3 - Copyright Screen Must Read Timeout
--
--   00D3 - Current Block In the Demo
--
--   00D8 - Singles
--   00D9 - Doubles
--   00DA - Triples
--   00DB - Quads
--
--   00F7 - Controller 1 Poll
--
--   00FC - Saved PPUSCROLL Y
--   00FD - Saved PPUSCROLL X
--   00FE - Saved PPUMASK
--   00FF - Saved PPUCTRL
--
--   0100-01FF - 6502 Runtime Stack (Grows Backwards from $1FF)
--   0200-02FF - Sprite Data (DMAed to OAM on every VBlank NMI)
--
--   03F0 - Stats: T
--   03F2 - Stats: J
--   03F4 - Stats: Z
--   03F6 - Stats: O
--   03F8 - Stats: S
--   03FA - Stats: L
--   03FC - Stats: I
--
--   0400-04FF - Pieces In the Well




local function fromBCD(bcd)
    local hexString = string.format("%x", bcd);
    local i = tonumber(hexString);
    return i;
end

local function sumScore(part1, part2, part3)
     local result = 0;
     result = result + fromBCD(part1);
     if (part2) then
        local n2 = (100 * fromBCD(part2));
        if (n2) then result = result + n2 end;
    end;
     if (part3) then
        result = result + (100 * 100 * fromBCD(part3));
     end;
     return result;
end;

local function getRandomInt(min, max, seed)
    --console.log({"getRandomInt", min, max, seed});
    local delta = seed % max;
    local result = min + delta;
    --console.log({delta=delta, "result", result=result});
    return result;
end;

-- X position in well between 0 and 9 (10 options)
local function decideXPosition(seed)
    --return 2;
    local minValue = 0;
    local maxValue = 9;
    local result = getRandomInt(minValue, maxValue, seed);
    --console.log({seed=seed, result=result});
    --console.log(string.format("Decided x position for %i is %i", seed, result));
    return result;
end;

-- Rotation of piece between 0 and 3 (4 options)
local function decideRotation(seed)
    local minValue = 0;
    local maxValue = 3;
    return getRandomInt(minValue, maxValue, seed);
end;


local function moveTowardsDecidedX()
    --
end;

-- Store variables
local gameState = "N/A";
local gamePhase = "N/A";
local lines = 0;
local score = 0;
local x = -1;
local y = -1;
local desiredX = nil; -- Each new piece starts at x=5
local desiredRot = 0;
local rotations = 0;

local deltaX = 0;
local shouldMoveLeft = false;
local shouldMoveRight = false;
local shouldRotate = false;

local pieceNumber = 0;


local START   = "P1 Start";
local A       = "P1 A";
local B       = "P1 B";
local ROTATE  = A;
local LEFT    = "P1 Left";
local RIGHT   = "P1 Right";
local DOWN    = "P1 Down";
local DROP    = DOWN;


-- Universal
local function updateGamePhase()
    local frameCount = emu.framecount();

	local newGameState = memory.readbyte(0x00C0);
	local newGamePhase = memory.readbyte(0x0047);


	if (newGameState and newGameState ~= gameState) then
	    console.log(string.format("[%i] gameState changed to %s", frameCount, newGameState));
	    gameState = newGameState;
    end;

	if (newGamePhase and newGamePhase ~= gamePhase) then
	    console.log(string.format("[%i] gamePhase changed to %s", frameCount, newGamePhase));
	    gamePhase = newGamePhase;
    end;
end;


-- index = frame, value = button
local startupScript = {};
startupScript[266] = START;
startupScript[272] = START;

startupScript[276] = START;

startupScript[280] = START;


local m1 = 281;

startupScript[m1+0] = RIGHT;
startupScript[m1+1] = DOWN;
startupScript[m1+2] = RIGHT;
startupScript[m1+4] = RIGHT;
startupScript[m1+6] = RIGHT;
startupScript[m1+7] = START; -- Should hold A here to add 10 to the level!
startupScript[m1+9] = START; -- Should hold A here to add 10 to the level!

-- index = piece number, value = [desiredX, rotation];
local pieceScript = {};
pieceScript[1] = {2, 2}; -- I
pieceScript[2] = {3, 1};
pieceScript[3] = {2, 0}; -- O
pieceScript[4] = {7, 0};
pieceScript[5] = {5, 0}; -- I
pieceScript[6] = {7, 3};
pieceScript[7] = {5, 1}; -- L
pieceScript[8] = {0, 3};
pieceScript[9] = {3, 2};
pieceScript[10] = {2, 2};
pieceScript[11] = {8, 1}; -- I => clear 2 (or optionally don't, just keep stacking)
pieceScript[12] = {7, 1}; -- J
pieceScript[13] = {9, 1}; -- I => tetris (if didnt clear 2 earlier)
pieceScript[14] = {0, 1}; -- Z





local function doInput(buttonToPress)
        local p1 = joypad.get(1);
        -- Clear all buttons
        p1["P1 Left"] = false;
        p1["P1 Right"] = false;
        p1["P1 Down"] = false;
        p1["P1 Right"] = false;
        p1["P1 A"] = false;
        p1["P1 B"] = false;
        p1["P1 Start"] = false;
        p1["P1 Select"] = false;

        -- Set the button we want to press
        p1[buttonToPress] = true;

        joypad.set(p1);
end;





local function doStartupScript()
    local frameCount = emu.framecount();

    updateGamePhase();

    local buttonThisFrame = startupScript[frameCount];

    if (buttonThisFrame) then
        console.log(string.format("[%i] Button to press %s", frameCount, buttonThisFrame));
        doInput(buttonThisFrame);
    end;
end;

local function doPieceScript(n)
    local frameCount = emu.framecount();
    --console.log(string.format("[%i] Getting a piece with index %i", frameCount, n));
    local pieceToDo = pieceScript[n];
    if (pieceToDo) then
        console.log(string.format("[%i] Piece with index %i: x=%i, rot=%i", frameCount, n, pieceToDo[1], pieceToDo[2]));
        return pieceToDo;
    end;
    return nil;
end;


local function doGameStuff()
    local frameCount = emu.framecount();

	--gui.addmessage("Hello");
	--console.log(string.format("%i", frame));

	local newX = memory.readbyte(0x0060);
	local newY = memory.readbyte(0x0061);

	local newPiece = memory.readbyte(0x0061);

	local newLines = memory.readbyte(0x0070);

	local scorePart1 = memory.readbyte(0x0053);
	local scorePart2 = memory.readbyte(0x0054);
	local scorePart3 = memory.readbyte(0x0055);

	local newScore = sumScore(scorePart1, scorePart2, scorePart3);

	--console.log(newScore);


    updateGamePhase();


	if (newLines and newLines > lines) then
	    console.log(string.format("[%i] Lines increased to %i", frameCount, newLines));
	    lines = newLines;
    end;

	if (newScore and newScore > score) then
	    console.log(string.format("[%i] Score increased to %i", frameCount, newScore));
	    score = newScore;
    end;


    if (newY ~= y) then
        --console.log(string.format("y changed to %i", newX));
        y = newY;

        if (newY == 0) then
            -- We are at the top, i.e. a new piece just appeared!
            -- That means we have control of it!
            --console.log(string.format("New piece at %i!", newX));
            --console.log("New piece!");
            pieceNumber = pieceNumber + 1; -- Start with 1 when we get the first piece

            if (gameState ~= 4) then
                console.log(string.format("[%i] WARN: gameState is not yet in gameplay (4) but %i", frameCount, gameState));
            end;

            -- Get a piece from the script, or if none, randomize.
            local maybeScriptedPiece = doPieceScript(pieceNumber);
            if (maybeScriptedPiece) then
                -- Do stuff
	            --console.log(string.format("Using a scripted piece: x=%i rot=%i", maybeScriptedPiece[1], maybeScriptedPiece[2]));
                desiredX = maybeScriptedPiece[1];
                desiredRot = maybeScriptedPiece[2];
                rotations = 0;
            else
	            console.log(string.format("[%i] Improvising for a piece", frameCount));
                desiredX = decideXPosition(frameCount);
                --if desiredX then console.log(string.format("Desired x is now %i", desiredX)) end;
                desiredRot = decideRotation(frameCount);
                rotations = 0;
                --if desiredX then console.log(string.format("Desired rotation is now %i", desiredRot)) end;
            end;
        else
            -- No new piece appeared, we're falling.
        end;
    else
        -- We did not change y-position
    end;

	if (newX ~= x) then
	    --console.log(string.format("x changed to %i", newX));
	    x = newX;
    else
        -- We did not change x-position, therefore we can likely press again?
        if desiredX then
            deltaX = (desiredX - newX);
	        --console.log(string.format("deltaX is %i", newX));
        end;

        if (deltaX > 0) then
            -- We are too left => let's move right.
            shouldMoveLeft = false;
            shouldMoveRight = true;
        elseif (deltaX < 0) then
            -- We are too right => let's move left.
            shouldMoveLeft = true;
            shouldMoveRight = false;
        else
            -- We are at the desired position.
            shouldMoveLeft = false;
            shouldMoveRight = false;
        end;
    end;

    if (desiredRot > rotations) then
        shouldRotate = true;
    else
        --console.log("At desired rotations.");
        shouldRotate = false;
    end;


    local isPressingLeft = joypad.get()[LEFT];
    local isPressingRight = joypad.get()[RIGHT];
    local isPressingA = joypad.get()[A];
    local isPressingB = joypad.get()[B];
    --if isPressingLeft then console.log("Is pressing Left") end;
    --if isPressingRight then console.log("Is pressing Right") end;

    local p1 = joypad.get(1);
    if (shouldMoveLeft and not isPressingLeft) then
        --console.log("Let's press Left");
        p1[LEFT] = true;
    else
        p1[LEFT] = false;
    end;

    if (shouldMoveRight and not isPressingRight) then
        --console.log("Let's press Right");
        p1[RIGHT] = true;
    else
        p1[RIGHT] = false;
    end;

    if (shouldRotate and not isPressingA and not isPressingB) then
        --console.log("Let's press A");
        p1[A] = true;
        rotations = rotations + 1;
    else
        p1[A] = false;
        p1[B] = false;
    end;

    -- Drop faster... but this affects the RNG!
   --if (not shouldMoveLeft and not shouldMoveRight) then
   --p1[DROP] = true;
   --end;

    joypad.set(p1);

end;



while true do
	-- Code here will run once when the script is loaded, then after each emulated frame.

    local frameCount = emu.framecount();
    if (frameCount >= 0 and frameCount < 289) then
        if (frameCount == 1) then
            console.log("Booted up");
        end;

        --console.log({"Let's do startup script on frame", frameCount});
        doStartupScript();
    elseif (frameCount == 289) then
        console.log("Startup script complete. Let's play!");
        --pieceNumber = 0;
    else
        --console.log({"Let's do stuff on frame", frameCount});
        doGameStuff();
    end;


	emu.frameadvance();
end
