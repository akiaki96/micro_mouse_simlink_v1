function generateMazeSTL_temp(maze, filename)
% generateMazeSTL
% Simulink 3D用迷路STL生成
%
% maze : parseMazeImage 出力
% filename : 出力STL

% function generateMazeSTL_full(maze, filename)


cellSize = 0.18;
wallThickness = 0.012;
wallHeight = 0.05;
pillarSize = wallThickness;

Ny = size(walls.h,1);
Nx = size(walls.v,2);

vertices = [];
faces = [];

%% ================================
%% 1 壁 (横方向 merge)
%% ================================

for y = 1:Ny+1

    x = 1;

    while x <= Nx

        if walls.h(y,x)

            startx = x;

            while x<=Nx && walls.h(y,x)
                x = x + 1;
            end

            endx = x-1;

            length = (endx-startx+1)*cellSize;

            cx = ((startx+endx)/2)*cellSize;
            cy = (y-1)*cellSize;

            [v,f] = createBox(cx,cy,length,wallThickness,wallHeight);

            f = f + size(vertices,1);

            vertices = [vertices; v];
            faces = [faces; f];

        end

        x = x + 1;

    end

end

%% ================================
%% 2 壁 (縦方向 merge)
%% ================================

for x = 1:Nx+1

    y = 1;

    while y <= Ny

        if walls.v(y,x)

            starty = y;

            while y<=Ny && walls.v(y,x)
                y = y + 1;
            end

            endy = y-1;

            length = (endy-starty+1)*cellSize;

            cx = (x-1)*cellSize;
            cy = ((starty+endy)/2)*cellSize;

            [v,f] = createBox(cx,cy,wallThickness,length,wallHeight);

            f = f + size(vertices,1);

            vertices = [vertices; v];
            faces = [faces; f];

        end

        y = y + 1;

    end

end


%% ================================
%% 3 柱生成
%% ================================

centerX = Nx/2;
centerY = Ny/2;

for ix = 1:Nx+1
for iy = 1:Ny+1

    x = (ix-1)*cellSize;
    y = (iy-1)*cellSize;

    %% 周囲壁チェック

    N=false;S=false;E=false;W=false;

    if iy<=Ny && ix<=Nx
        N = walls.h(iy,ix);
    end

    if iy>1 && ix<=Nx
        S = walls.h(iy-1,ix);
    end

    if ix<=Nx && iy<=Ny
        E = walls.v(iy,ix);
    end

    if ix>1 && iy<=Ny
        W = walls.v(iy,ix-1);
    end

    wallCount = N+S+E+W;

    %% 柱判定

    place=false;

    if wallCount>=1
        place=true;
    end

    %% 直角壁補強
    if (N&&E)||(E&&S)||(S&&W)||(W&&N)
        place=true;
    end

    %% 中央4マスの柱削除

    if abs(ix-centerX)<=1 && abs(iy-centerY)<=1
        place=false;
    end

    %% 生成

    if place

        [v,f] = createBox(x,y,pillarSize,pillarSize,wallHeight);

        f = f + size(vertices,1);

        vertices = [vertices; v];
        faces = [faces; f];

    end

end
end


%% ================================
%% 4 頂点統合（重要）
%% ================================

[vertices,~,ix] = unique(round(vertices,6),'rows');
faces = ix(faces);

%% STL出力

TR = triangulation(faces,vertices);
stlwrite(TR,filename);

disp("maze STL generated")

end



function [v,f] = createBox(cx,cy,sx,sy,sz)

x = sx/2;
y = sy/2;

v = [
cx-x cy-y 0
cx+x cy-y 0
cx+x cy+y 0
cx-x cy+y 0
cx-x cy-y sz
cx+x cy-y sz
cx+x cy+y sz
cx-x cy+y sz
];

f = [
1 2 3
1 3 4
5 6 7
5 7 8
1 2 6
1 6 5
2 3 7
2 7 6
3 4 8
3 8 7
4 1 5
4 5 8
];

end
% 
% % N = maze.size;
% % vwall = maze.vwall;
% % hwall = maze.hwall;
% % 
% % cell = 0.18;
% % wall_h = 0.05;
% % wall_t = 0.012;
% % floor_t = 0.01;
% % 
% % pillar_size = wall_t;
% % 
% % vertices = [];
% % faces = [];
% % 
% % %% Box生成
% % function addBox(cx,cy,cz,sx,sy,sz)
% % 
% % v = [
% % -sx/2 -sy/2 -sz/2
% %  sx/2 -sy/2 -sz/2
% %  sx/2  sy/2 -sz/2
% % -sx/2  sy/2 -sz/2
% % -sx/2 -sy/2  sz/2
% %  sx/2 -sy/2  sz/2
% %  sx/2  sy/2  sz/2
% % -sx/2  sy/2  sz/2];
% % 
% % v = v + [cx cy cz];
% % 
% % f = [
% % 1 2 3;1 3 4
% % 5 6 7;5 7 8
% % 1 2 6;1 6 5
% % 2 3 7;2 7 6
% % 3 4 8;3 8 7
% % 4 1 5;4 5 8];
% % 
% % offset = size(vertices,1);
% % 
% % vertices = [vertices; v];
% % faces = [faces; f + offset];
% % 
% % end
% % 
% % %% =================
% % %% 縦壁
% % %% =================
% % 
% % for j = 1:N+1
% % 
% %     i = 1;
% % 
% %     while i <= N
% % 
% %         if vwall(i,j)
% % 
% %             start_i = i;
% % 
% %             while i<=N && vwall(i,j)
% %                 i = i+1;
% %             end
% % 
% %             len = i-start_i;
% % 
% %             x = (j-1)*cell;
% %             y = (start_i-1)*cell + (len*cell)/2;
% % 
% %             addBox(x,y,wall_h/2,...
% %                 wall_t,...
% %                 len*cell,...
% %                 wall_h);
% % 
% %         else
% %             i = i+1;
% %         end
% % 
% %     end
% % 
% % end
% % 
% % %% =================
% % %% 横壁
% % %% =================
% % 
% % for i = 1:N+1
% % 
% %     j = 1;
% % 
% %     while j <= N
% % 
% %         if hwall(i,j)
% % 
% %             start_j = j;
% % 
% %             while j<=N && hwall(i,j)
% %                 j = j+1;
% %             end
% % 
% %             len = j-start_j;
% % 
% %             x = (start_j-1)*cell + (len*cell)/2;
% %             y = (i-1)*cell;
% % 
% %             addBox(x,y,wall_h/2,...
% %                 len*cell,...
% %                 wall_t,...
% %                 wall_h);
% % 
% %         else
% %             j = j+1;
% %         end
% % 
% %     end
% % 
% % end
% % 
% % %% =================
% % %% 柱（最適化）
% % %% =================
% % 
% % c1 = N/2;
% % c2 = N/2 + 1;
% % 
% % for i = 1:N+1
% % for j = 1:N+1
% % 
% %     %% 中央柱削除
% %     if (i==c1 || i==c2) && (j==c1 || j==c2)
% %         continue
% %     end
% % 
% %     connected = false;
% % 
% %     if i<=N && j<=N
% %         if vwall(i,j) || hwall(i,j)
% %             connected = true;
% %         end
% %     end
% % 
% %     if i<=N && j>1
% %         if vwall(i,j)
% %             connected = true;
% %         end
% %     end
% % 
% %     if i>1 && j<=N
% %         if hwall(i,j)
% %             connected = true;
% %         end
% %     end
% % 
% %     if connected
% % 
% %         x = (j-1)*cell;
% %         y = (i-1)*cell;
% % 
% %         addBox(x,y,wall_h/2,...
% %             pillar_size,...
% %             pillar_size,...
% %             wall_h);
% % 
% %     end
% % 
% % end
% % end
% % 
% % %% =================
% % %% 床
% % %% =================
% % 
% % maze_w = N*cell;
% % maze_h = N*cell;
% % 
% % addBox(maze_w/2,...
% %        maze_h/2,...
% %        -floor_t/2,...
% %        maze_w,...
% %        maze_h,...
% %        floor_t);
% % 
% % %% =================
% % %% 頂点統合
% % %% =================
% % 
% % [vertices,~,ix] = unique(round(vertices,6),'rows');
% % faces = ix(faces);
% % 
% % %% STL出力
% % 
% % TR = triangulation(faces,vertices);
% % stlwrite(TR,filename);
% % 
% % end

% 
% function generateMazeSTL_ultraFast(filename, maze)
% 
% cellSize = 0.18;
% wallThickness = 0.012;
% wallHeight = 0.05;
% pillarSize = wallThickness;
% 
% N = maze.size;
% 
% vwall = maze.vwall;
% hwall = maze.hwall;
% 
% vertices = [];
% faces = [];
% 
% %% =========================
% %% 壁 merge (horizontal)
% %% =========================
% 
% for y = 1:N+1
% 
% x = 1;
% 
% while x <= N
% 
% if hwall(y,x)
% 
% start = x;
% 
% while x<=N && hwall(y,x)
% x = x+1;
% end
% 
% len = x-start;
% 
% cx = (start-1)*cellSize;
% cy = (y-1)*cellSize;
% 
% addBox(cx,cy, len*cellSize, wallThickness);
% 
% else
% x = x+1;
% end
% 
% end
% end
% 
% %% =========================
% %% 壁 merge (vertical)
% %% =========================
% 
% for x = 1:N+1
% 
% y = 1;
% 
% while y <= N
% 
% if vwall(y,x)
% 
% start = y;
% 
% while y<=N && vwall(y,x)
% y = y+1;
% end
% 
% len = y-start;
% 
% cx = (x-1)*cellSize;
% cy = (start-1)*cellSize;
% 
% addBox(cx,cy, wallThickness, len*cellSize);
% 
% else
% y = y+1;
% end
% 
% end
% end
% 
% %% =========================
% %% 柱生成
% %% =========================
% 
% for ix = 1:N+1
% for iy = 1:N+1
% 
% cx = (ix-1)*cellSize;
% cy = (iy-1)*cellSize;
% 
% % 中央柱削除
% if ix>=N/2 && ix<=N/2+1 && iy>=N/2 && iy<=N/2+1
% continue
% end
% 
% Nw=false;Sw=false;Ew=false;Ww=false;
% 
% if iy<=N && ix<=N
% Nw = hwall(iy,ix);
% end
% 
% if iy>1 && ix<=N
% Sw = hwall(iy-1,ix);
% end
% 
% if ix<=N && iy<=N
% Ew = vwall(iy,ix);
% end
% 
% if ix>1 && iy<=N
% Ww = vwall(iy,ix-1);
% end
% 
% if Nw||Sw||Ew||Ww
% 
% addBox(cx-pillarSize/2, cy-pillarSize/2, pillarSize, pillarSize);
% 
% end
% 
% end
% end
% 
% %% =========================
% %% 頂点統合
% %% =========================
% 
% [vertices,~,ix] = unique(round(vertices,6),'rows');
% faces = ix(faces);
% 
% TR = triangulation(faces,vertices);
% 
% stlwrite(TR,filename);
% 
% disp("UltraFast maze STL generated");
% 
% %% =========================
% %% Box生成関数
% %% =========================
% 
% function addBox(x,y,dx,dy)
% 
% v = [
% x y 0
% x+dx y 0
% x+dx y+dy 0
% x y+dy 0
% x y wallHeight
% x+dx y wallHeight
% x+dx y+dy wallHeight
% x y+dy wallHeight
% ];
% 
% f = [
% 1 2 6
% 1 6 5
% 2 3 7
% 2 7 6
% 3 4 8
% 3 8 7
% 4 1 5
% 4 5 8
% 5 6 7
% 5 7 8
% ];
% 
% offset = size(vertices,1);
% 
% vertices = [vertices; v];
% faces = [faces; f + offset];
% 
% end
% 
% end


% function generateMazeSTL_onemesh(filename, maze)
% 
% cellSize = 0.18;
% wallThickness = 0.012;
% wallHeight = 0.05;
% 
% N = maze.size;
% 
% vwall = maze.vwall;
% hwall = maze.hwall;
% 
% res = wallThickness/3;
% 
% sx = N*cellSize;
% sy = N*cellSize;
% sz = wallHeight;
% 
% nx = ceil(sx/res)+3;
% ny = ceil(sy/res)+3;
% nz = ceil(sz/res)+3;
% 
% vox = false(nx,ny,nz);
% 
% toIdx = @(x) round(x/res)+2;
% 
% %% horizontal wall
% 
% for y=1:N+1
% for x=1:N
% 
% if hwall(y,x)
% 
% x0=(x-1)*cellSize;
% x1=x*cellSize;
% 
% y0=(y-1)*cellSize-wallThickness/2;
% y1=(y-1)*cellSize+wallThickness/2;
% 
% fill();
% 
% end
% end
% end
% 
% %% vertical wall
% 
% for y=1:N
% for x=1:N+1
% 
% if vwall(y,x)
% 
% x0=(x-1)*cellSize-wallThickness/2;
% x1=(x-1)*cellSize+wallThickness/2;
% 
% y0=(y-1)*cellSize;
% y1=y*cellSize;
% 
% fill();
% 
% end
% end
% end
% 
% %% pillars
% 
% pillar = wallThickness;
% 
% for ix=1:N+1
% for iy=1:N+1
% 
% x=(ix-1)*cellSize;
% y=(iy-1)*cellSize;
% 
% if ix>=N/2 && ix<=N/2+1 && iy>=N/2 && iy<=N/2+1
% continue
% end
% 
% x0=x-pillar/2;
% x1=x+pillar/2;
% y0=y-pillar/2;
% y1=y+pillar/2;
% 
% fill();
% 
% end
% end
% 
% %% mesh
% 
% [X,Y,Z] = meshgrid( ...
% (0:ny-1)*res, ...
% (0:nx-1)*res, ...
% (0:nz-1)*res );
% 
% fv = isosurface(X,Y,Z,permute(vox,[2 1 3]),0.5);
% 
% TR = triangulation(fv.faces,fv.vertices);
% 
% stlwrite(TR,filename);
% 
% disp("Maze STL generated");
% 
% function fill()
% 
% ix0=toIdx(x0); ix1=toIdx(x1);
% iy0=toIdx(y0); iy1=toIdx(y1);
% iz0=1; iz1=toIdx(wallHeight);
% 
% ix0=max(ix0,1);
% iy0=max(iy0,1);
% 
% ix1=min(ix1,nx);
% iy1=min(iy1,ny);
% iz1=min(iz1,nz);
% 
% vox(ix0:ix1,iy0:iy1,iz0:iz1)=true;
% 
% end
% 
% end


% function generateMazeSTL_manifold(filename, maze)
% 
% cellSize = 0.18;
% wallThickness = 0.012;
% wallHeight = 0.05;
% 
% N = maze.size;
% 
% vwall = maze.vwall;
% hwall = maze.hwall;
% 
% %% =============================
% %% occupancy grid resolution
% %% =============================
% 
% res = wallThickness/3;
% 
% sx = N * cellSize;
% sy = N * cellSize;
% 
% nx = ceil(sx/res)+10;
% ny = ceil(sy/res)+10;
% 
% grid = false(nx,ny);
% 
% toIdx = @(x) round(x/res)+5;
% 
% %% =============================
% %% horizontal walls
% %% =============================
% 
% for y = 1:N+1
% for x = 1:N
% 
% if hwall(y,x)
% 
% x0 = (x-1)*cellSize;
% x1 = x*cellSize;
% 
% y0 = (y-1)*cellSize - wallThickness/2;
% y1 = (y-1)*cellSize + wallThickness/2;
% 
% grid( toIdx(x0):toIdx(x1) , toIdx(y0):toIdx(y1) ) = true;
% 
% end
% end
% end
% 
% %% =============================
% %% vertical walls
% %% =============================
% 
% for y = 1:N
% for x = 1:N+1
% 
% if vwall(y,x)
% 
% x0 = (x-1)*cellSize - wallThickness/2;
% x1 = (x-1)*cellSize + wallThickness/2;
% 
% y0 = (y-1)*cellSize;
% y1 = y*cellSize;
% 
% grid( toIdx(x0):toIdx(x1) , toIdx(y0):toIdx(y1) ) = true;
% 
% end
% end
% end
% 
% %% =============================
% %% pillars
% %% =============================
% 
% pillar = wallThickness;
% 
% for ix=1:N+1
% for iy=1:N+1
% 
% if ix>=N/2 && ix<=N/2+1 && iy>=N/2 && iy<=N/2+1
% continue
% end
% 
% x=(ix-1)*cellSize;
% y=(iy-1)*cellSize;
% 
% x0=x-pillar/2;
% x1=x+pillar/2;
% 
% y0=y-pillar/2;
% y1=y+pillar/2;
% 
% grid( toIdx(x0):toIdx(x1) , toIdx(y0):toIdx(y1) ) = true;
% 
% end
% end
% 
% %% =============================
% %% Marching Squares
% %% =============================
% 
% C = contourc(double(grid),[1 1]);
% 
% polys = {};
% 
% k=1;
% 
% while k < size(C,2)
% 
% len = C(2,k);
% pts = C(:,k+1:k+len);
% 
% polys{end+1} = pts';
% 
% k = k + len + 1;
% 
% end
% 
% %% =============================
% %% polygon -> mesh extrusion
% %% =============================
% 
% vertices = [];
% faces = [];
% 
% for p = 1:length(polys)
% 
% poly = polys{p};
% 
% poly(:,1) = (poly(:,1)-5)*res;
% poly(:,2) = (poly(:,2)-5)*res;
% 
% pg = polyshape(poly(:,1),poly(:,2));
% 
% T = triangulation(pg);
% 
% tri = T.ConnectivityList;
% v2 = T.Points;
% 
% nv = size(v2,1);
% 
% bottom = [v2 zeros(nv,1)];
% top    = [v2 wallHeight*ones(nv,1)];
% 
% offset = size(vertices,1);
% 
% vertices = [vertices; bottom; top];
% 
% %% bottom
% 
% faces = [faces
% offset + tri(:,[1 2 3])];
% 
% %% top
% 
% faces = [faces
% offset + tri(:,[3 2 1]) + nv];
% 
% %% sides
% 
% polyLoop = boundary(pg);
% 
% for i=1:length(polyLoop)
% 
% i2 = mod(i,length(polyLoop))+1;
% 
% b1 = offset + polyLoop(i);
% b2 = offset + polyLoop(i2);
% 
% t1 = b1 + nv;
% t2 = b2 + nv;
% 
% faces = [faces
% b1 b2 t2
% b1 t2 t1];
% 
% end
% 
% end
% 
% % %% =============================
% % %% triangulate top/bottom
% % %% =============================
% % 
% % DT = delaunayTriangulation(vertices(:,1),vertices(:,2));
% % 
% % tri = DT.ConnectivityList;
% % 
% % zTop = vertices(:,3)==wallHeight;
% % zBot = vertices(:,3)==0;
% % 
% % topVerts = find(zTop);
% % botVerts = find(zBot);
% % 
% % faces = [faces
% % tri
% % tri(:,[1 3 2])];
% 
% %% =============================
% %% unify vertices
% %% =============================
% 
% faces = int32(faces);
% 
% if any(faces(:)<=0)
%     error("faces contains invalid index")
% end
% 
% [vertices,~,ix] = unique(round(vertices,6),'rows');
% 
% faces = ix(faces);
% 
% TR = triangulation(faces,vertices);
% 
% stlwrite(TR,filename);
% 
% disp("Manifold maze STL generated")
% 
% end