function f = makeConstantPlot(params)
% Plot variation of fitted parameters over time
%-------------------------------------------------------------------------------

if nargin < 1
    params = GiveMeDefaultParams();
end

%-------------------------------------------------------------------------------
% Curve fitting
%-------------------------------------------------------------------------------
numTimePoints = length(params.timePoints);
goodTimePoint = false(numTimePoints,1);
stats = cell(numTimePoints,1);
fittedParams = cell(numTimePoints,1);
for i = 1:numTimePoints
    % Load the distance, CGE data:
    [dist,CGE] = ComputeDistanceCGE(params,params.timePoints{i},true);
    if isnan(dist)
        continue
    else
        goodTimePoint(i) = true;
    end

    % Bin the data:
    [xBinCenters,xThresholds,yMeans,yStds] = makeQuantiles(dist,CGE,params.numThresholds);

    % Fit the binned data (on means):
    [fitHandle,stats{i},fittedParams{i}] = GiveMeFit(xBinCenters,yMeans,params.whatFit,true);
end
goodTimeInd = find(goodTimePoint);
numTimePoints = length(goodTimeInd);
paramNames = coeffnames(fittedParams{goodTimeInd(1)});
fittedParams = fittedParams(goodTimePoint);

% Convert to confidence intervals:
CIs = cellfun(@(x)confint(x),fittedParams,'UniformOutput',false);
% ***Convert n -> inverses (hopefully valid to do nonlinear transformations of CIs)***
nIndex = strcmp(paramNames,'n');
for i = 1:length(CIs)
    CIs{i}(:,nIndex) = 1./CIs{i}(:,nIndex);
end

% Get max distances
maxDistances = makeMaxDistance(params);
maxDistances = maxDistances(goodTimePoint);

%-------------------------------------------------------------------------------
% Plotting
%-------------------------------------------------------------------------------
theParameter = {'n','n','n','A','B'};
customParamOrder = {'nLinear','nLog','nLogHuman','A','B'};
numParams = length(theParameter);

f = figure('color','w','Renderer','painters');
paramMeanValues = zeros(numParams,numTimePoints);
paramErrValues = zeros(numParams,numTimePoints);
for i = 1:numParams
    % Get mean parameter estimate:
    paramEstMean = cellfun(@(x)x.(theParameter{i}),fittedParams);
    if strcmp(theParameter{i},'n')
        paramEstMean = 1./paramEstMean;
    end

    paramInd = find(strcmp(paramNames,theParameter{i}));

    % Estimate error bounds:
    errs = cellfun(@(x) diff(x(:,paramInd))/2,CIs);

    % Store for output:
    paramMeanValues(i,:) = paramEstMean;
    paramErrValues(i,:) = errs;

    % Plot:
    % plotHere = find(strcmp(paramNames{i},plotOrder));
    % if isempty(plotHere)
    %     continue;
    % end
    subplot(1,numParams,i)
    if i==1
        title(sprintf('%s-%s',params.thisBrainDiv,params.thisCellType))
    end
    hold('on')
    axis('square')

    switch customParamOrder{i}
    case {'nLinear','A','B'}
        % Fit linear regression:
        xRange = linspace(0,maxDistances(end));
        if strcmp(theParameter{i},'n')
            ft = fittype('c*x');
            [c,Stats] = fit(maxDistances,paramEstMean,ft);
            f_handle = @(x) c.c*x;
            plot(xRange,f_handle(xRange),'-','color',ones(1,3)*0.5)
        else
            [c,Stats] = fit(maxDistances,paramEstMean,'poly1');
            Gradient = c.p1; Intercept = c.p2;
            f_handle = @(x) Gradient*x + Intercept;
            plot(xRange,f_handle(xRange),':k')
        end
        [r,pVal] = corr(maxDistances,paramEstMean);
        fprintf(1,'%s: r = %g, p = %g\n',theParameter{i},r,pVal);
        ylabel(theParameter{i})
        xlabel('Brain size, d_{max} (mm)')
        % Color by time point:
        for t = 1:numTimePoints
            errorbar(maxDistances(t),paramEstMean(t),errs(t),'-o','MarkerSize',8,...
                            'Color',params.colors(goodTimeInd(t),:),'LineWidth',2)
        end
    case 'nLog'
        decayConstant_voxel(params,maxDistances,paramEstMean,errs,goodTimeInd,false);
        axis('square')
    case 'nLogHuman'
        decayConstant_voxel(params,maxDistances,paramEstMean,errs,goodTimeInd,true);
        axis('square')
    end
end
f.Position(3:4) = [1291,420];

%-------------------------------------------------------------------------------
if ~params.doSubsample
    theFileName = 'parameterFits.mat';
else
    theFileName = 'parameterFits_subsampled.mat';
end
if ~(exist(theFileName,'file')==0)
    paramFitStruct = struct();
else
    load(theFileName,'paramFitStruct')
end

theField = sprintf('%s_%s',params.thisBrainDiv,params.thisCellType);
paramFitStruct.(theField).params = params;
paramFitStruct.(theField).paramMeanValues = paramMeanValues;
paramFitStruct.(theField).paramMeanValues = paramMeanValues;
fprintf(1,'Saving fitted info back to %s\n',theFileName);

if ~(exist(theFileName,'file')==0)
    save(theFileName,'paramFitStruct','-append');
else
    save(theFileName,'paramFitStruct');
end

end
