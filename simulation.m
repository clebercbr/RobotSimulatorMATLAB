
n [] = simulation()
 
    bot = createRobot(35,35);
    assignin('base','bot',bot);
 
    room = createWorkspace(800,600);
    assignin('base','room',room);
 
    roomWithoutBot = room;
 
    configSimulation();
 
 
    dir = 1;
    while 1
        room_backup = room;
        botNewX = bot.x+dir;
        botNewY = bot.y;
        retMove = moveRobot(room,bot,botNewX,botNewY); 
        if retMove == 0
            imagesc(room.area)
            pbaspect([room.width room.height 1]);
            drawnow;
            pause(0.02);
        else
            room = room_backup;
            dir = -dir;
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
        [y,x] = size(desktop(i).object);
        candidateX = randi(room.width-x);
        candidateY = randi(room.height-y);
        if candidateX > doorW || candidateY > doorH
            desktop(i).x = candidateX;
            desktop(i).y = candidateY;
            room.area(desktop(i).y:desktop(i).y+y-1,desktop(i).x:desktop(i).x+x-1) = desktop(i).object;
            i = i + 1;
        end
    end
    assignin('base','desktop',desktop);
    %Create chairs
    i = 1;
    while i <= 20
        chair(i).object = zeros(45,45)+1;
        [y,x] = size(chair(i).object);
        candidateX = randi(room.width-x);
        candidateY = randi(room.height-y);
        if candidateX > doorW || candidateY > doorH
            chair(i).x = candidateX;
            chair(i).y = candidateY;
            room.area(chair(i).y:chair(i).y+y-1,chair(i).x:chair(i).x+x-1) = chair(i).object;
            i = i + 1;
        end
    end
    assignin('base','chair',chair);
end
 
function robot = createRobot(width, height)
    robot.object = zeros(width,height)+1;
    robot.width = 35;
    robot.height = 35;
    %By defalut it initiates in position (1,1) of workspace
    robot.x = 1; 
    robot.y = 1;
end
 
function ret = moveRobot(room,bot,newX,newY)
    sumRoom = sum(sum(room.area));    
 
    bot.x = newX;
    bot.y = newY;
    [y,x] = size(bot.object);
    room.area(bot.y:bot.y+y-1,bot.x:bot.x+x-1) = bot.object;
    newSumRoom = sum(sum(room.area));
 
    if  sumRoom == newSumRoom
        ret = 0; %Success
    else
        room = room_backup;
        ret = 1; %Error
    end
end
 
function [] = configSimulation()
    figure(1)
    colormap(flipud(gray))
    grid on
end
