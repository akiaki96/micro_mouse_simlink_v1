
function prepareMazeSTL(inputImagePath)
% prepareMazeSTL  Create STL from maze image (reads stlFile from base workspace)
%  inputImagePath : string or char (path to input image)
%
%  Requires:
%   - PreLoadFcn または別処理で base workspace に stlFile を作成しておく:
%       stlFile = fullfile(pwd,'mazeActor.stl');
%       assignin('base','stlFile',stlFile);

    narginchk(1,1);

    if ~(ischar(inputImagePath) || isstring(inputImagePath))
        error('prepareMazeSTL:InvalidInput','inputImagePath must be a string or char vector.');
    end
    inputImagePath = char(inputImagePath);

    % 入力存在チェック
    if ~isfile(inputImagePath)
        error('prepareMazeSTL:NoInputFile','Input image not found: %s', inputImagePath);
    end

    % base workspace から stlFile を取得（存在チェック付き）
    if evalin('base', 'exist("stlFile","var")')
        stlFile = evalin('base', 'stlFile');
    else
        error('prepareMazeSTL:NoOutputFile','Base workspace variable ''stlFile'' not found. Set it in PreLoadFcn or before calling.');
    end
    if ~(ischar(stlFile) || isstring(stlFile))
        error('prepareMazeSTL:BadOutputFile','Base workspace variable ''stlFile'' must be a string path.');
    end
    stlFile = char(stlFile);

    % --- コア処理：既存の補助関数を利用 ---
    % parseMazeImage, generateMazeSTL がパス上にあることを前提
    maze = parseMazeImage(inputImagePath);   % 画像 -> 迷路データ
    generateMazeSTL(maze, stlFile);          % 迷路 -> STL ファイル出力

    fprintf('prepareMazeSTL: wrote STL -> %s\n', stlFile);
end