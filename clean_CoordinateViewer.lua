-- =============================================================================
-- COORDINATE VIEWER
-- by RoboMat & Turbotutone
-- 
-- Created: 07.08.13 - 21:31
-- Updated: 07.29.14 to Build 27 by NCrawler
-- Updated: 04.06.15 to Build 31 by UnfoundedBros
--
-- =============================================================================

-- -- okay so any weirds errors, project zomboid uses kahlua ... lua for java..

local version = "0.8.0";
local author = "UnfoundedBros"
local originally="RoboMat & Turbotutone & NCrawler";
--local updatedby = "UnfoundedBros"
local modName = "Coordinate Viewer";

local FONT_SMALL = UIFont.Small;
local T_MANAGER = getTextManager();
-- do I need to assign ISChat to a similar object?

local SCREEN_X = 20;
local SCREEN_Y = 200;

local flag = true;
local floor = math.floor;
local print = print;

local mouseX = 0;
local mouseY = 0;

local waypointIndex=1; --customary to start lua tables with 1
local waypointMaxIndex=1;

local waypointTable={}; -- initialize an empty waypoint table...
waypointTable[1]="empty";

local loadWaypointTableOnce=false;
-- ------------------------------------------------
-- Functions
-- ------------------------------------------------
---
-- Prints out the mod info on startup and initializes a new
-- trait.
local function initInfo()
	print("Mod Loaded: " .. modName .. " by " .. author .. " (v" .. version .. ")");
	print("Previously authored by: " .. originally);
	print("Use 'P' to toggle the Mod on and off. 'Bar or backslash key' to create way points.");
	print("Backspace to delete way points, left and right curly brace to cycle through them");
end

-- so the only thing I have left to test is saving which for my case may not be a deal breaker

---
-- Checks if the P key is pressed to activate / deactivate the
-- debug menu.
-- @param _key - The key which was pressed by the player.
--
local function checkKey(_key)
	local key = _key;
	-- what is key==25? P
	-- well from http://pz-mods.net/guide/robomats-mod-tutorials/
	-- "As I said this will be a number from 0 to 223 (IIRC) with each number standing for a different key on the keyboard. Unfortunately I'm not to sure which numbering method is used but I think it might be the one from LWJGL. But with the print call in the function you will be able to easily find out which number is connected to which key anyway."
	-- also just see the below link for example...
	--http://minecraft.gamepedia.com/index.php?title=Key_Codes/Keyboard1&action=render
	
	if key == 25 then
		flag = not flag; -- reverse flag
	end
	-- to cycle through way-points...
	-- left curly bracket
	if key == 26 then
		if (waypointIndex-1)<1 then
			waypointIndex = #waypointTable; --#waypointTable = length of waypoint table...
		else
			waypointIndex=waypointIndex-1;
		end
	end
	-- right curly bracket
	if key == 27 then
		if (waypointIndex+1)> #waypointTable then
			waypointIndex=1;
		else
			waypointIndex=waypointIndex+1;
		end
	end
	
	-- end
	-- bar or back slash (43), double quotes or single quote (40)
	if flag and key == 43 then
		
		mouseX, mouseY = ISCoordConversion.ToWorld(getMouseX(), getMouseY(), 0);
		mouseX = round(mouseX);
		mouseY = round(mouseY);
		local cellX = mouseX / 300;
		local cellY = mouseY / 300;
		local locX = mouseX % 300;
		local locY = mouseY % 300;
		
		waypointMaxIndex=waypointMaxIndex+1;

		if waypointTable[1] == "empty" then
			waypointName = "Waypoint1"; 
		else
			waypointName = "Waypoint" .. (#waypointTable+1);
		end

		
		if waypointTable[1] == "empty" then
			waypointTable[1]={["wayPtName"]=waypointName,["absX"]=mouseX,["absY"]=mouseY,["wayPtCellX"]=cellX,["wayPtCellY"]=cellY,["wayPtX"]=locX,["wayPtY"]=locY};
		else
			table.insert(waypointTable,{["wayPtName"]=waypointName,["absX"]=mouseX,["absY"]=mouseY,["wayPtCellX"]=cellX,["wayPtCellY"]=cellY,["wayPtX"]=locX,["wayPtY"]=locY});
			waypointIndex=waypointIndex+1;
		end
		local tempPlayer = getSpecificPlayer(0);
		local playerModData = tempPlayer :getModData(); 

		playerModData.waypointTable=waypointTable; -- "save" the updated table...

		
	end
	-- backspace
	if flag and key == 14 then
		if #waypointTable == 1 then
			waypointTable[1]="empty";
		else
			table.remove(waypointTable, waypointIndex);
			waypointIndex=waypointIndex-1;
		end
		local tempPlayer = getSpecificPlayer(0);
		local playerModData = tempPlayer :getModData();
		playerModData.waypointTable=waypointTable;

		
	end

end


---
-- Round up if decimal is higher than 0.5 and down if it is smaller.
-- @param _num
--
local function round(_num)
	local number = _num;
	return number <= 0 and floor(number) or floor(number + 0.5);
end


---
-- Creates a small overlay UI that shows debug info if the
-- P key is pressed.
local function showDebugger()
	local player = getSpecificPlayer(0);

	if player and flag then
		if loadWaypointTableOnce==false then
			waypointTable = getSpecificPlayer(0):getModData().waypointTable or "";
			if waypointTable == "" then
				waypointTable={}; -- initialize an empty waypoint table...
				waypointTable[1]="empty";
			else 
				waypointTable=waypointTable
			end
			loadWaypointTableOnce=true;
		end
		
		-- Absolute Coordinates.
		local absX = player:getX();
		local absY = player:getY();

		-- Relative Coordinates.
		local cellX = absX / 300;
		local cellY = absY / 300;
		local locX = absX % 300;
		local locY = absY % 300;

		-- Detect room.
		local room = player:getCurrentSquare():getRoom();
		local roomTxt;
		if room then
			local roomName = player:getCurrentSquare():getRoom():getName();
			roomTxt = roomName;
		else
			roomTxt = "outside";
		end

		local strings = {
			"Absolute:",
			"X: " .. round(absX),
			"Y: " .. round(absY),
			"",
			"Relative: ",
			"CellX: " .. round(cellX),
			"CellY: " .. round(cellY),
			"X: " .. round(locX),
			"Y: " .. round(locY),
			"",
			"Current Room: " .. roomTxt,
			"",
			--"MouseX: " .. round(mouseX),
			--"MouseX: " .. round(mouseY),
		};
		
		
		
		local txt;
		for i = 1, #strings do
			txt = strings[i];
			T_MANAGER:DrawString(FONT_SMALL, SCREEN_X, SCREEN_Y + (i * 10), txt, 1, 1, 1, 1);
		end

		
		if waypointTable[1] ~= "empty" then

			local strings2={

				"",
				"Waypoint: " .. waypointTable[waypointIndex].wayPtName, 
				"Absolute: ", 
				"X: " .. round(waypointTable[waypointIndex].absX),
				"Y: " .. round(waypointTable[waypointIndex].absY),
				"",
				"CellX: " .. round(waypointTable[waypointIndex].wayPtCellX),
				"CellY: " .. round(waypointTable[waypointIndex].wayPtCellY),
				"X: " .. round(waypointTable[waypointIndex].wayPtX),
				"Y: " .. round(waypointTable[waypointIndex].wayPtY),
			};
			for i = 1, #strings2 do
				txt = strings2[i];
				T_MANAGER:DrawString(FONT_SMALL, SCREEN_X, SCREEN_Y + (i * 10) + (#strings * 10), txt, 1, 1, 1, 1);
			end
		end
	end
end


---
-- @param x
-- @param y
--
local function readTile(_x, _y)
	mouseX, mouseY = ISCoordConversion.ToWorld(getMouseX(), getMouseY(), 0);
	mouseX = round(mouseX);
	mouseY = round(mouseY);

	local cell = getWorld():getCell();
	local sq = cell:getGridSquare(mouseX, mouseY, 0);
	
	if sq then
		local sqModData = sq:getModData();

		print("=====================================================");
		print("MODDATA SQUARE: ", mouseX, mouseY, "Params: ", _x, _y);
		for k, v in pairs(sqModData) do
			print(k, v);
		end
		local objs = sq:getObjects();
		local objs_size = objs:size();
		print("OBJECTS FOUND: ", objs_size - 1, "real", objs_size)
		if objs_size > 0 then
			for i = 0, objs_size - 1, 1 do
				print(" " .. tostring(i) .. "-", objs:get(i));
				if objs:get(i):getName() then
					print("  - ", objs:get(i):getName());
				else
					print("  - ", "unknown");
				end
			end
		end
		print("=====================================================");
	end
end

local function readTileCreateWayPt(_x, _y)
	mouseX, mouseY = ISCoordConversion.ToWorld(getMouseX(), getMouseY(), 0);
	mouseX = round(mouseX);
	mouseY = round(mouseY);

	local cell = getWorld():getCell();
	local sq = cell:getGridSquare(mouseX, mouseY, 0);
	
	-- Absolute Coordinates.
	local absX = player:getX();
	local absY = player:getY();

	-- Relative Coordinates.
	local cellX = absX / 300;
	local cellY = absY / 300;
	local locX = absX % 300;
	local locY = absY % 300;
	
	if sq then
		local sqModData = sq:getModData();
		--print("MODDATA SQUARE: ", mouseX, mouseY, "Params: ", _x, _y);
		for k, v in pairs(sqModData) do
			print(k, v); -- assuming this going to debug window (F11 only)
			--return k,v -- hopefully only returns one sq x,y and not two squares
		end
		return cellX,cellY,locX,locY
	end
end


-- -- not implemented
-- -- borrowed kindly from admintools
-- -- to rework to handle /rewp -- rename waypoint
-- function ISChat:onCommandEntered()
	-- so I may be sure that this is eating text messages from the server.... woops! probably not going to work then...
    -- local command = ISChat.instance.textEntry:getText();
    -- ISChat.instance.textEntry:clear();
    -- ISChat.instance.textEntry:unfocus();
    -- ISChat.instance.textEntry:setText("");
    -- ISChat.instance.textEntry:setVisible(false);
    -- if not command or command == "" then
        -- return;
    -- end

	
	-- if flag and luautils.stringStarts(command, "/rewp") then
		-- local message = luautils.trim(string.gsub(command, "/rewp", ""));
		
		
		-- waypointTable[waypointIndex].waypointName=message;
		-- local tempPlayer = getSpecificPlayer(0);
		-- local playerModData = tempPlayer :getModData();
		-- playerData.waypointTable=waypointTable; -- "save" the updated table...
	-- end

-- end



-- ------------------------------------------------
-- Game hooks
-- ------------------------------------------------

---
-- Initialises the ingame events.
--
local function init()
	Events.OnMouseUp.Add(readTile);
	Events.OnKeyPressed.Add(checkKey);
	Events.OnPostUIDraw.Add(showDebugger);
end

Events.OnGameStart.Add(init)
Events.OnGameBoot.Add(initInfo);
