whatTimePointNow='E11pt5';

fileTimePoints={'E11.5','E13.5','E15.5','E18.5','P4','P14','P28'};
timePoints={'E11pt5','E13pt5','E15pt5','E18pt5','P4','P14','P28'};
timePointIndex=find(cellfun(@(c)strcmp(whatTimePointNow,c),timePoints)); %match index to the chosen timepoint
sizeGrids=struct('E11pt5',[70,75,40],'E13pt5',[89,109,69],'E15pt5',[94,132,65],'E18pt5',[67,43,40],'P4',[77,43,50],...
    'P14',[68,40,50],'P28',[73,41,53]);

% resolutionGrid=struct('E11pt5',80,'E13pt5',100,'E15pt5',120,'E18pt5',140,'P4',160,...
%     'P14',200,'P28',200);
%%
% Location of saved API gene expression data expressed in a cell
expression_loc=fullfile('Data','API','GridData',fileTimePoints{timePointIndex});
%%
% Folder to save the created matlab variables
folder_save=fullfile('Data','Matlab_variables');

A=dir(expression_loc);
% remove hidden files
A=A(arrayfun(@(A) A.name(1), A) ~= '.');
% initialize
energyGrids=cell(length(A),1);
timePointInfo=cell(length(A),1);
geneIDInfo=zeros(length(A),1);

% store original directory and move to new directory (necessitated by
% filepath problems)
currentFolder = pwd;
cd(expression_loc);

h = waitbar(0,'Compiling energy grid...');
steps=length(A);
%%
for j=1:length(A)
    
    fileStr=fullfile(A(j).name,'energy.raw');
    % ENERGY = 3-D matrix of expression energy grid volume
    % load files
    fid = fopen(fileStr, 'r', 'l' );
    energyGrids{j} = fread( fid, prod(sizeGrids.(timePoints{timePointIndex})), 'float' );
    fclose( fid );
    energyGrids{j} = reshape(energyGrids{j},sizeGrids.(timePoints{timePointIndex}));
    infoStr=strsplit(A(j).name,'_');
    timePointInfo{j}=infoStr{1};
    geneIDInfo(j)=str2double(infoStr{2});
    waitbar(j/steps)
end
close(h)
%% cd back to original directory
cd(currentFolder);

%%
str=strcat(folder_save,'\','energyGrids_',timePoints{timePointIndex},'.mat');
save(str,'energyGrids','-v7.3')
str=strcat(folder_save,'\','timePointInfo_',timePoints{timePointIndex},'.mat');
save(str,'timePointInfo')
str=strcat(folder_save,'\','geneIDInfo_',timePoints{timePointIndex},'.mat');
save(str,'geneIDInfo')