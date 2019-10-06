function [maxDistance] = getMaxDistance(thisBrainDiv,timePointNow)
  load('annotationGrids.mat');
  timePoints = GiveMeParameter('timePoints');
  timePointIndex = strcmp(timePointNow,timePoints);
  resolutionGrid = GiveMeParameter('resolutionGrid');
  % get the max extent along the x-axis
  coOrds = getCoOrds(thisBrainDiv,timePointNow);
  maxX = max(coOrds(:,1)) - min(coOrds(:,1));
  maxDistance = maxX*resolutionGrid.(timePointNow);
end
