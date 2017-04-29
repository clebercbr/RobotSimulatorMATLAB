function [] = simulation()

    Tsimu = 0.001; %Simulation Period

    room = ws_createWorkspace(600,600);
    assignin('base','room',room);
	disp('Workspace created succesfully!');

    ws_configSimulation(room);
	disp('Simulation prepared!');

    bot = ws_createRobot(32,32);
    assignin('base','bot',bot);
	disp('Robot created successfully!');
 
    roomWithoutBot = room;
	heatmap = roomWithoutBot.area .- roomWithoutBot.area;
	disp('Heatmap report initiated succesfully!');
 
    [dirX, dirY] = pol2cart(bot.theta,bot.rho);
    assignin('base','dir',dir);
    botNewX = bot.x;
    botNewY = bot.y;
	counter = 0;
	disp('Robot placed in first position!');

    while 1
        botNewX = botNewX+dirX;
        botNewY = botNewY+dirY;
        [room,bot,hadCollision] = ws_changeBotPosition(room,roomWithoutBot,bot,botNewX,botNewY); 
		[dirX,dirY,bot,counter] = bot_nextPosition(bot,hadCollision,counter);
		heatmap = ws_updateHeatmap(heatmap,bot);
	    assignin('base','heatmap',heatmap);
	    pbaspect([room.width room.height 1]);
		imagesc(room.area)
		pause(Tsimu);
	end

	disp('Simulation terminated!');
end
 
function room = ws_createWorkspace(width, height)
    %Measures in cm
    room.width = width;
    room.height = height;
    room.area = zeros(room.height,room.width);
    %Stabilish a door - furnitures must be created out of this area 
    doorW = 100;
    doorH = 100;
	%Room without desktops
	roomWithDesktops.area = room.area;
    %Create chairs
    i = 1;
    while i <= 20
		roomTemp.area = room.area;
        chair(i).object = zeros(44,44)+1;
        [chair(i).height, chair(i).width] = size(chair(i).object);
        candidateX = randi(room.width-chair(i).width);
        candidateY = randi(room.height-chair(i).height);
		roomTemp.area(candidateY:candidateY+chair(i).height-1,candidateX:candidateX+chair(i).width-1) = chair(i).object;
		%Make sure the object is not going to be put on the door or over another chair
        if (candidateX > doorW || candidateY > doorH) && (sum(sum(roomTemp.area))==sum(sum(room.area))+sum(sum(chair(i).object)))
	        chair(i).object(1:end,1:end) = 0;
			chair(i).object(1:5,1:5) = 1;	
			chair(i).object(end-4:end,1:5) = 1;
			chair(i).object(1:5,end-4:end) = 1;
			chair(i).object(end-4:end,end-4:end) = 1;

            room.area(candidateY:candidateY+chair(i).height-1,candidateX:candidateX+chair(i).width-1) = chair(i).object;
            i = i + 1;
        end
    end
    %Create desktops
    i = 1;
    while i <= 10
		 %In this case a desktop over a chair is ok
		roomTemp.area = roomWithDesktops.area;
        desktop(i).object = zeros(60,120)+1;
        [desktop(i).height,desktop(i).width] = size(desktop(i).object);
        candidateX = randi(room.width-desktop(i).width);
        candidateY = randi(room.height-desktop(i).height);
		roomTemp.area(candidateY:candidateY+desktop(i).height-1,candidateX:candidateX+desktop(i).width-1) = desktop(i).object;
		%Make sure the object is not going to be put on the door or over another desktop
        if (candidateX > doorW || candidateY > doorH) && (sum(sum(roomTemp.area))==sum(sum(roomWithDesktops.area))+sum(sum(desktop(i).object)))
			roomWithDesktops.area(candidateY:candidateY+desktop(i).height-1,candidateX:candidateX+desktop(i).width-1) = desktop(i).object;
            room.area(candidateY:candidateY+desktop(i).height-1,candidateX:candidateX+desktop(i).width-1) = desktop(i).object;
            i = i + 1;
        end
    end
end
 
function robot = ws_createRobot(width, height)
    robot.object = zeros(width,height);
    for i = -width/2:width/2
        for j = -height/2:height/2
	    	[theta,rho] = cart2pol(i/((width/2)-1),j/((height/2)-1));
            if (rho <= 1) 
				robot.object(i+width/2,j+height/2) = 1;
	    	end
        end
    end

    robot.width = width;
    robot.height = height;
    %By defalut it initiates in position (1,1) of workspace with 0 rad in angle
    robot.x = 1; 
    robot.y = 1;
	robot.theta = 0;
	robot.rho = 1;
	robot.vacuum = robot.object(1+width/4:end-width/4,height/2);
end
 
function [room,bot,collision] = ws_changeBotPosition(room,roomWithoutBot,bot,newX,newY)
    sumRoomWithoutBot = sum(sum(roomWithoutBot.area));
    sumRoom = sum(sum(room.area));
    if sumRoomWithoutBot == sumRoom
        %Place robot in its first position
        room.area(bot.y:bot.y+bot.height-1,bot.x:bot.x+bot.width-1) = bot.object;
    end
    
    if (newX >= 1) && (newY >= 1) && (newX <= room.width-bot.width) && (newY <= room.height-bot.height)
        backupRoom = room; %Current room has a robot inside
        room = roomWithoutBot; %Clean the room to draw the robot in a new position
        room.area(newY:newY+bot.height-1,newX:newX+bot.width-1) = bot.object;
    
        newSumRoom = sum(sum(room.area));
        if sumRoom == newSumRoom
			%Commit bot position
	        bot.x = newX;
	        bot.y = newY;
            collision = 0; %Success
        else
            room = backupRoom; %Undo movement
            collision = 1; %Collision
        end
    else
        collision = 2; %Out of bounds
    end
end
 
function [retX,retY,bot,counter] = bot_nextPosition(bot,hadCollision,counter)
%How to do it????
%	if ~exist('counter')
%		counter = 0
%	end	
	if (hadCollision == 0) && (counter < 50)
    	[retX, retY] = pol2cart(bot.theta,bot.rho);
		retX = int16(retX);
		retY = int16(retY);
		counter = counter + 1;
	else
		bot.theta = bot.theta + pi/randi(2:6);
    	[retX, retY] = pol2cart(bot.theta,bot.rho);
		retX = int16(retX);
		retY = int16(retY);
		counter = 0;
	end
end

function [] = ws_configSimulation(room)
    figure(1)
    colormap(flipud(gray))
    grid on
end

function [heatmap] = ws_updateHeatmap(heatmap,bot)
	%heatmap = heatmap .+ newRoom.area .- roomWithoutBot.area;
	heatmap(bot.x:bot.x+size(bot.vacuum)-1) = heatmap(bot.x:bot.x+size(bot.vacuum)-1) + 1;
end
