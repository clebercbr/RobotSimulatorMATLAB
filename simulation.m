function [] = simulation()
 
    bot = createRobot(35,35);
    assignin('base','bot',bot);
 
    room = createWorkspace(800,600);
    assignin('base','room',room);
 
    roomWithoutBot = room;
 
    configSimulation();
 
    dir = 1;
    while 1
        botNewX = bot.x;%+dir;
        botNewY = bot.y;
        retMove = moveRobot(room,roomWithoutBot,bot,botNewX,botNewY); 
        if retMove == 0
            imagesc(room.area)
            pbaspect([room.width room.height 1]);
            drawnow;
            pause(0.02);
        else
            dir = -dir;
            imagesc(room.area)
            pbaspect([room.width room.height 1]);
            drawnow;
            pause(0.02);
        end
    end
end
 
function room = createWorkspace(width, height)
    %Measures in cm
    room.width = width;
    room.height = height;
    room.area = zeros(room.height,room.width);
    %Create desktops
    doorW = 100;
    doorH = 100;
    i = 1;
    while i <= 10
        desktop(i).object = zeros(60,120)+1;
        [h,w] = size(desktop(i).object);
        candidateX = randi(room.width-w);
        candidateY = randi(room.height-h);
        if candidateX > doorW || candidateY > doorH
            desktop(i).x = candidateX;
            desktop(i).y = candidateY;
            room.area(desktop(i).y:desktop(i).y+h-1,desktop(i).x:desktop(i).x+w-1) = desktop(i).object;
            i = i + 1;
        end
    end
    assignin('base','desktop',desktop);
    %Create chairs
    i = 1;
    while i <= 20
        chair(i).object = zeros(45,45)+1;
        [chair(i).height, chair(i).width] = size(chair(i).object);
        candidateX = randi(room.width-chair(i).width);
        candidateY = randi(room.height-chair(i).height);
        if candidateX > doorW || candidateY > doorH
            room.area(candidateY:candidateY+chair(i).height-1,candidateX:candidateX+chair(i).width-1) = chair(i).object;
            i = i + 1;
        end
    end
    assignin('base','chair',chair);
end
 
function robot = createRobot(width, height)
    robot.object = zeros(width,height)+1;
    robot.width = width;
    robot.height = height;
    %By defalut it initiates in position (1,1) of workspace
    robot.x = 1; 
    robot.y = 1;
end
 
function ret = moveRobot(room,roomWithoutBot,bot,newX,newY)
    sumRoom = sum(sum(room.area));    
    assignin('base','sumRoom',sumRoom);
    backupRoom = room; %Current room has a robot inside
    
    room = roomWithoutBot; %Clean the room to draw the robot in a new position
    
    bot.x = newX;
    bot.y = newY;
    assignin('base','bot',bot);
    room.area(bot.y:bot.y+bot.height-1,bot.x:bot.x+bot.width-1) = bot.object;
    %room.area(1:35,1:35) = bot.object;
    
    newSumRoom = sum(sum(room.area));
    assignin('base','newSumRoom',newSumRoom);
    
    if  sumRoom == newSumRoom
        ret = 0 %Success
    else
        room = backupRoom; %Undo movement
        ret = 1 %Error
    end
end
 
function [] = configSimulation()
    figure(1)
    colormap(flipud(gray))
    grid on
end
