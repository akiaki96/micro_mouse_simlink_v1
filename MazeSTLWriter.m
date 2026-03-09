
classdef MazeSTLWriter < matlab.System
    % MazeSTLWriter  - generates STL once at simulation start

    properties (Nontunable)
        ImgFile (1,:) char = ''   % 入力画像のフルパス
        StlFile (1,:) char = ''   % 出力STLのフルパス
    end

    methods
        function obj = MazeSTLWriter(varargin)
            % コンストラクタ：名前-値でプロパティ設定可能
            setProperties(obj,nargin,varargin{:});
        end
    end

    methods (Access = protected)
        function setupImpl(obj)
            % シミュレーション開始時に一度だけ実行
            maze = parseMazeImage(obj.ImgFile);
            generateMazeSTL(maze, obj.StlFile);
        end

        function y = stepImpl(~, ~)
            % 実行中は何もしない（ダミー出力）
            y = 0;
        end

        function resetImpl(~)
            % 必要ならリセット処理を実装
        end
    end

    methods (Static, Access = protected)
        function sz = getOutputSizeImpl(~)
            sz = [1 1];
        end
        function dt = getOutputDataTypeImpl(~)
            dt = 'double';
        end
        function cp = isOutputComplexImpl(~)
            cp = false;
        end
        function fs = isOutputFixedSizeImpl(~)
            fs = true;
        end
    end
end