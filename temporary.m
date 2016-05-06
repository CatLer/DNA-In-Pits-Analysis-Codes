%% Loop Data Sets
clear Data
saveDir='C:\Users\Francois\Documents\Nanopit data\August_23_2013\Analysis\Dataset';
dirInfo = dir(saveDir);
folderNames={dirInfo.name};
folderNames(1) = []; folderNames(1) = [];


for currSet = 1:length(folderNames)
    name = folderNames{currSet};
    Data{currSet} = DataSet([],[],[],[],name);
    specifyVars = dataPropertiesList('RadiusCurveSet');
%     specifyVars = [{'name'}; {'gapHeight'};{'dnaFitStructure'};{'roiPoints'};{'roiImageStruct'};{'xoDyeFit'};{'yoDyeFit'};{'dyeScan'}];
    Data{currSet}.loadVariables(specifyVars,saveDir); %,optionalSaveTag);
end

