function [f,g] = NNClassifier(folder,numClasses,k,useMean)

training_location = strcat(folder,"/training");
[transformW, means, training, dataRaw, transformedMeansData, classifiedData] = whiten(training_location,numClasses);
#[means,training] = basicNormalization(folder,numClasses,0);
data = getTestData(folder);
#[means2,transformedData] = basicNormalization(folder,numClasses,data);
transformedData = data * transformW;

sizeData = rows(data);
NN = zeros(sizeData,1);
if( useMean == 1)
	for j = 1:1:sizeData
		NN(j) = nearestNeighbor(classifiedData,transformedData(j,:),numClasses,1);
	endfor
else
	for j = 1:1:sizeData
		NN(j) = nearestNeighbor(classifiedData,transformedData(j,:),numClasses,k);
	endfor
endif

true_class_location = strcat(folder,"/test/true_class_data.txt");
trueClass = load(true_class_location);
matched = (NN == trueClass);
percent_correct = sum(matched) / rows(matched);

f = NN;
g = percent_correct;

endfunction
