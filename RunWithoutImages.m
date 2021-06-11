function cellMat = RunWithoutImages(blobSeq, varargin)

% add necessary paths
subdirs = textscan(genpath(fileparts(mfilename('fullpath'))), '%s','delimiter',pathsep);
addpath(subdirs{1}{:});

% construct the parameter struct
aImData.imageWidth = 680;
aImData.imageHeight = 512;
if nargin == 1 % include blobSeq
    aImData.TrackXSpeedStd = 1;
else
    aImData.TrackXSpeedStd = varargin{1};
end
aImData.TrackPAppear = 0;
aImData.TrackPDisappear = 0;
aImData.TrackMigInOut = true;
aImData.TrackMigLogLikeList = "MigLogLikeList_uniformClutter";
aImData.TrackNumNeighbours = 100;
aImData.TrackMotionModel = 'none';
aImData.pCnt0 = 0.1;
aImData.pCnt1 = 0.8;
aImData.pCnt2 = 0.1;
aImData.pCntExtrap = 0.25;
aImData.countClassifier = 'none';

if isempty(blobSeq)
    % construct image sequence (only centroid)
    blobSeq = {[10 10; 100 100];
               [101 101; 11 11; 500 510];
               [7 7; 102 102; 501 509];
               [4 5; 102 102; 501 508];
               [1 2; 103 102; 501 507];
               [103 102; 501 506]};
end
% fake scores
% countScores = [ ...
%     1.0000    1.0000   -2.9957   -0.0619   -4.8929   -6.2791   -7.6654   -9.0517  -10.4380  -11.8243  -13.2106  -14.5969; ...
%     1.0000    2.0000   -2.9957   -0.0619   -4.8929   -6.2791   -7.6654   -9.0517  -10.4380  -11.8243  -13.2106  -14.5969; ...
%     2.0000    1.0000   -2.9957   -0.0619   -4.8929   -6.2791   -7.6654   -9.0517  -10.4380  -11.8243  -13.2106  -14.5969; ...
%     2.0000    2.0000   -2.9957   -0.0619   -4.8929   -6.2791   -7.6654   -9.0517  -10.4380  -11.8243  -13.2106  -14.5969; ...
%     ];
% migrationScores = [ ...
%     1 1 1 -2.8793   -0.0578; ...
%     1 2 1 -0.0000  -19.2221; ...
%     1 1 2 -0.0000  -19.2221; ...
%     1 2 2 -2.8793   -0.0578; ...
%     ];
splitScores = rand(0, 6);
deathScores = rand(0, 4);
% appearanceScores = rand(0, 4);
% disappearanceScores = rand(0, 4);
appearanceScores = AppearanceScores(blobSeq, aImData);
disappearanceScores = DisappearanceScores(blobSeq, aImData);
migrationScores = MigrationScores_generic(blobSeq, aImData);
countScores = CountScores(blobSeq, aImData);
numDets = cellfun('size', blobSeq, 1);
[cellMat, divMat, deathMat] = ViterbiTrackLinking(...
    numDets,...
    countScores,...
    migrationScores,...
    splitScores,...
    deathScores,...
    appearanceScores,...
    disappearanceScores,...
    0,...
    0,...
    '',...
    '');
end