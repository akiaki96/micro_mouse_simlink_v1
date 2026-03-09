function maze = parseMazeImage(filename)
% parseMazeImage 迷路画像から壁配列を生成
%
% maze = parseMazeImage(filename)
%
% 出力
% maze.size   : 迷路サイズ (N)
% maze.vwall  : 縦壁 (Nx(N+1)) logical
% maze.hwall  : 横壁 ((N+1)xN) logical
% maze.cell   : 各セルの壁bit (E,N,W,S)

%% 画像読み込み

if exist(filename,'file')~=2
    error('File not found: %s', filename);
end
info = imfinfo(filename);
disp(info.Format); % 'png' などが表示されるはず

original = imread(filename);

%% 二値化（壁=1）
bw = imbinarize(rgb2gray(original));
bw = imcomplement(bw);

%% 迷路の輪郭を抽出
colsum = sum(bw);
rowsum = sum(bw,2);

[~,we] = max(colsum(1:end/2));
[~,ee] = max(colsum(end/2:end));

[~,ne] = max(rowsum(1:end/2));
[~,se] = max(rowsum(end/2:end));

trim = bw(ne:(se+size(rowsum,1)/2), we:(ee+size(colsum,2)/2));

%% サイズ正規化
trim = imresize(trim,[1600 1600]);

%% ノイズ除去
trim = imopen(trim,ones(10));
trim = imdilate(trim,ones(5));

%% 迷路サイズ検出
trimsum = sum(trim);
trimsum = trimsum < sum(trimsum)/length(trimsum);
maze_size = sum(([trimsum 0]-[0 trimsum])>0);

%% セルサイズ
segsize = size(trim)/maze_size;

%% 壁抽出
vwall = trim( ...
    round(segsize(1)/2:segsize(1):end), ...
    round(1:segsize(2):end-segsize(2)/3) );

hwall = trim( ...
    round(1:segsize(1):end-segsize(1)/3), ...
    round(segsize(2)/2:segsize(2):end) );

%% 外周壁追加
vwall = [vwall, true(maze_size,1)];
hwall = [hwall; true(1,maze_size)];

%% logical化
vwall = logical(vwall);
hwall = logical(hwall);

%% セル壁bit生成
cellwall = uint8( ...
      1 * vwall(:,2:end) ...   % East
    + 2 * hwall(1:end-1,:) ... % North
    + 4 * vwall(:,1:end-1) ... % West
    + 8 * hwall(2:end,:) );    % South

%% 出力
maze.size = maze_size;
maze.vwall = vwall;
maze.hwall = hwall;
maze.cell = cellwall;

end