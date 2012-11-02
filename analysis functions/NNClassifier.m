function [f,g] = NNClassifier(folder,numClasses)

[transformW, means] = whiten(folder,numClasses);
data = getTestData(folder);
transformedData = data * transformW;

sizeData = rows(data);
NN = zeros(sizeData,1);

for j = 1:1:sizeData
	NN(j) = nearestNeighbor(means,transformedData(j,:));
endfor

true_class_location = strcat(folder,"/test/true_class_data.txt");
trueClass = load(true_class_location);
matched = (NN == trueClass)
percent_correct = sum(matched) / rows(matched);

f = NN;
g = percent_correct;

endfunction
