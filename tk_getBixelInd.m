function bixelInd = tk_getBixelInd(shapeInfo,beamNum,leafNum,xPos,isLeftBool)

% function to find the bixel index from the information of the leaf
% position of a certain beam
% shapeInfo: struct containing info from sequencing
% beamNum: beam number
% leafNum: number of the leaf of this beam, here the enumeration is from 1
% to numberOfLeaves for this beam. Attention leafNum=1 corresponds to
% lowest leafPair when regarding the physical position

%% 1. store data for chosen beam
try
    info = shapeInfo.beam(beamNum);
catch
    error('invalid beam number or shape structure. Please check the variables!')
end
%% 2. check if the info is valid

if leafNum < 1 || leafNum > info.numOfActiveLeafPairs
    error('specified leaf is not active... please check the value')
end

if xPos < info.lim_l(leafNum) || xPos > info.lim_r(leafNum)
    error('Out of bounds. The specified position is not covered by a ray!')
end

%% 3. find position within the map of the MLC

zPos = info.leafPairPos(leafNum);

zPosInd = (zPos-info.posOfCornerBixel(3))/shapeInfo.bixelWidth+1;

if xPos == info.lim_l(zPosInd) % if leaf at min_let
    % use first possible bixel
    xPosInd = find(~isnan(info.bixelIndMap(zPosInd,:)),1,'first');
elseif xPos == info.lim_r(zPosInd) %if leaf at max_right
    % use last possible bixel
    xPosInd = find(~isnan(info.bixelIndMap(zPosInd,:)),1,'last');
else % leaf is not at min/max
    % for the left leaf: if positioned on edge between bixel n and n+1, the
    % corresponding bixel is n. (use floor)
    % for the right leaf: if positioned on edge between bixel n and n+1, the
    % corresponding bixel is n+1. (use round)
    if isLeftBool  % current leaf is left leaf
        % check if leaf is on a bixel edge
        decimalPos = (xPos-info.posOfCornerBixel(1))/shapeInfo.bixelWidth -...
        floor((xPos-info.posOfCornerBixel(1))/shapeInfo.bixelWidth);
        if decimalPos == 0.5 % leaf on edge        
            xPosInd = floor((xPos-info.posOfCornerBixel(1))/shapeInfo.bixelWidth)+1;
        else
            xPosInd = round((xPos-info.posOfCornerBixel(1))/shapeInfo.bixelWidth)+1;
        end
    else % current leaf is right leaf
        xPosInd = round((xPos-info.posOfCornerBixel(1))/shapeInfo.bixelWidth)+1;
    end
end

% correct if the leaf is completely on the left
% if xPosInd == 0 
%     xPosInd = 1;
% end
% % correct if the leaf is completely on the right
% if xPosInd > size(info.bixelIndMap,2) 
%     xPosInd = size(info.bixelIndMap,2);
% end

%% 4. get bixel index

bixelInd = info.bixelIndMap(zPosInd,xPosInd);

end