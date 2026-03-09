function generateMazeSTL(maze, filename)

N = maze.size;
vwall = maze.vwall;
hwall = maze.hwall;

cell = 0.18;
wall_h = 0.05;
wall_t = 0.012;
floor_t = 0.01;

pillar_size = wall_t;

vertices = [];
faces = [];

%% Box生成
function addBox(cx,cy,cz,sx,sy,sz)

v = [
-sx/2 -sy/2 -sz/2
 sx/2 -sy/2 -sz/2
 sx/2  sy/2 -sz/2
-sx/2  sy/2 -sz/2
-sx/2 -sy/2  sz/2
 sx/2 -sy/2  sz/2
 sx/2  sy/2  sz/2
-sx/2  sy/2  sz/2];

v = v + [cx cy cz];

f = [
1 2 3;1 3 4
5 6 7;5 7 8
1 2 6;1 6 5
2 3 7;2 7 6
3 4 8;3 8 7
4 1 5;4 5 8];

offset = size(vertices,1);

vertices = [vertices; v];
faces = [faces; f + offset];

end

%% =================
%% 縦壁
%% =================

for j = 1:N+1

    i = 1;

    while i <= N

        if vwall(i,j)

            start_i = i;

            while i<=N && vwall(i,j)
                i = i+1;
            end

            len = i-start_i;

            x = (j-1)*cell;
            y = (start_i-1)*cell + (len*cell)/2;

            addBox(x,y,wall_h/2,...
                wall_t,...
                len*cell,...
                wall_h);

        else
            i = i+1;
        end

    end

end

%% =================
%% 横壁
%% =================

for i = 1:N+1

    j = 1;

    while j <= N

        if hwall(i,j)

            start_j = j;

            while j<=N && hwall(i,j)
                j = j+1;
            end

            len = j-start_j;

            x = (start_j-1)*cell + (len*cell)/2;
            y = (i-1)*cell;

            addBox(x,y,wall_h/2,...
                len*cell,...
                wall_t,...
                wall_h);

        else
            j = j+1;
        end

    end

end

%% =================
%% 柱（正しい接続判定）
%% =================

c1 = N/2;
c2 = N/2 + 1;

for i = 1:N+1
for j = 1:N+1

    %% 中央4柱削除
    if (i==c1 || i==c2) && (j==c1 || j==c2)
        continue
    end

    connected = false;

    %% 左の壁
    if j>1 && i<=N
        if vwall(i,j)
            connected = true;
        end
    end

    %% 右の壁
    if j<=N && i<=N
        if vwall(i,j+1)
            connected = true;
        end
    end

    %% 下の壁
    if i>1 && j<=N
        if hwall(i,j)
            connected = true;
        end
    end

    %% 上の壁
    if i<=N && j<=N
        if hwall(i+1,j)
            connected = true;
        end
    end

    if connected

        x = (j-1)*cell;
        y = (i-1)*cell;

        addBox(x,y,wall_h/2,...
            pillar_size,...
            pillar_size,...
            wall_h);

    end

end
end

%% =================
%% 床
%% =================

maze_w = N*cell;
maze_h = N*cell;

addBox(maze_w/2,...
       maze_h/2,...
       -floor_t/2,...
       maze_w,...
       maze_h,...
       floor_t);

%% =================
%% 頂点統合
%% =================

[vertices,~,ix] = unique(round(vertices,6),'rows');
faces = ix(faces);

%% STL出力

if isa(filename,'string')
    filename = char(filename);
end
filename = strtrim(filename);
[p,n,e] = fileparts(filename);
if isempty(e) || ~strcmpi(e,'.stl')
    filename = fullfile(p,[n '.stl']);
end

TR = triangulation(faces,vertices);
stlwrite(TR,filename);

end