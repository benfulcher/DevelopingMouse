%---------------------------------------------------------------------
% initialize and load variables
%---------------------------------------------------------------------
timePoints={'E11pt5','E13pt5','E15pt5','E18pt5','P4','P14','P28'};
load('voxelGeneCoexpression_all') % contains 'voxGeneMat_all','distMat_all','dataIndSelect_all'

%---------------------------------------------------------------------
% Plot gene coexpression against distance
%---------------------------------------------------------------------
for i = 1:length(timePoints)
    % extract the correlation coefficients
    geneCorr=corrcoef((voxGeneMat{i}(dataIndSelect{i},:))','rows','pairwise');
    corrCoeff=geneCorr(find(triu(ones(size(geneCorr)),1)));
    % compute distances
    distances = computeDistances(distMat_all{i});
    % plot coexpression against distance
    f=figure('color','w');
    gcf;
    scatter(distance,corrCoeff,'.')
    xlabel('Separation Distance (um)','FontSize',16)
    ylabel('Gene Coexpression (Pearson correlation coefficient)','FontSize',13)
    str = sprintf('Developing Mouse %s',timePoints{i});
    title(str,'Fontsize',19);
    f=figureFullScreen(f,true); 
end

%---------------------------------------------------------------------
% fitting
%---------------------------------------------------------------------



