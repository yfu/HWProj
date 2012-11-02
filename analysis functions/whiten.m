function [f,g] = whiten(folder,numClasses)

count = 1;
currentClass = 0;

slant_location = strcat(folder,"/training/slant_data.txt");
skew_location = strcat(folder,"/training/skew_data.txt");
asc_vs_desc_location = strcat(folder,"/training/asc_vs_desc_data.txt");
curvature_location = strcat(folder,"/training/curvature_data.txt");

load(slant_location);
load(skew_location);
load(asc_vs_desc_location);
load(curvature_location);

data = [data_slant, data_skew, data_asc, data_curv];

numFeatures = columns(data);

numExamplesPerClass = rows(data) / numClasses;

means = zeros(numClasses,numFeatures);

lowerBound = 1;

upperBound = numExamplesPerClass;

covMatrix = zeros(numFeatures, numFeatures);

for j = 1:1:numClasses
	covMatrix = covMatrix + cov(data(lowerBound:upperBound,:));
	means(j,:) = mean(data(lowerBound:upperBound,:));
	lowerBound = lowerBound + numExamplesPerClass;
	upperBound = upperBound + numExamplesPerClass;
endfor

covMatrix = covMatrix ./ numClasses;

[eigenVector, eigenValues] = eig(covMatrix);

transformW = eigenVector * diag(diag(eigenValues .^ (-.5)));

data_class = zeros(numClasses,1);

for j = 1:1:numClasses
	data_class(j,1) = j;
endfor

f = transformW;
g = [means * transformW,data_class];

endfunction