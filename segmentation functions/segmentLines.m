function f = segmentLines(im,folder)
imbw = imcomplement(im);
#tic();
skew = document_skew(imbw);
imbw = imrotate(imbw,skew,"bilinear","loose",0);
if ~isbw(imbw)
	imbw = im2bw(imbw,graythresh(imbw));
endif
#toc();
CCLabel = bwlabel(imbw,4);
#imshow(label2rgb(CCLabel));
modeMatrix = [];
for k = 1:1:columns(CCLabel)
	modeMatrix = [modeMatrix;CCLabel(:,k)];
endfor
modeMatrix;
white = mode(modeMatrix);
maxLabel = max(max(CCLabel));
compData = zeros(maxLabel,3);
for k = 1:1:maxLabel
	[r, c] = find(CCLabel == k);
	compData(k,1) = k;
	compData(k,2) = min(r);
	compData(k,3) = max(r);
	compData(k,4) = min(c);	
	compData(k,5) = max(c);	
endfor
lineQueue = [];
threshold = 0.75;
finalLineComps = [];
lines{1} = [];
lineCount = 1;
#tic();
while(rows(compData) > 1)
	if(white != compData(1,1))
		lineQueue = compData(1,:);
		compData(1,:) = [];
	else
		lineQueue = compData(2,:);
		compData(2,:) = [];
	endif
	while(~isempty(lineQueue))
		iterations = rows(compData);
		count = 1;
		for k = 1:1:iterations
			A = compData(count,3) - compData(count,2);
			B = lineQueue(1,3) - lineQueue(1,2);
			maxAB = max([A;B]);
			minAB = min([A;B]);
			if(compData(count,1) != white) && (A != 0) && (B != 0) && (maxAB < ((1 / threshold) * minAB))
				if(compData(count,2) <= lineQueue(1,2)) && (compData(count,3) >= lineQueue(1,3))
					lineQueue = [lineQueue; compData(count,:)];
					compData(count,:) = [];
				elseif(compData(count,2) >= lineQueue(1,2)) && (compData(count,3) <= lineQueue(1,3))
					lineQueue = [lineQueue; compData(count,:)];
					compData(count,:) = [];
				elseif(compData(count,2) <= lineQueue(1,2)) && (compData(count,3) <= lineQueue(1,3)) && (compData(count,3) >= lineQueue(1,2))
					ratio = (compData(count,3) - lineQueue(1,2)) / (compData(count,3) - compData(count,2));
					ratio2 = (compData(count,3) - lineQueue(1,2)) / (lineQueue(1,3) - lineQueue(1,2));
					if((ratio >= threshold) || (ratio2 >= threshold))
						lineQueue = [lineQueue; compData(count,:)];
						compData(count,:) = [];
					else
						count = count + 1;
					endif
				elseif(compData(count,2) >= lineQueue(1,2)) && (compData(count,3) >= lineQueue(1,3)) && (compData(count,2) <= lineQueue(1,3))					
					ratio = (lineQueue(1,3) - compData(count,2)) / (compData(count,3) - compData(count,2));
					ratio2 = (lineQueue(1,3) - compData(count,2)) / (lineQueue(1,3) - lineQueue(1,2));
					if((ratio >= threshold) || (ratio2 >= threshold))
						lineQueue = [lineQueue; compData(count,:)];
						compData(count,:) = [];
					else
						count = count + 1;
					endif
				else
					count = count + 1;
				endif	
			else
				count = count + 1;
			endif
		endfor
		finalLineComps = [finalLineComps;lineQueue(1,:)];
		lineQueue(1,:) = [];
	endwhile
	lines{lineCount} = finalLineComps;
	finalLineComps = [];
	lineCount = lineCount + 1;
endwhile
#toc();
imageHeight = rows(imbw);
imageWidth = columns(imbw);
spanReq = 0.5;
densityReq = 0.6;
numImagesRequirement = 10;
minLines = false;
limitedData = false;
densityMatrix = [];
densityCount = 1;
while(minLines == false)
	#tic();
	imageCount = 1;
	for l = 1:1:columns(lines)
		newImage = zeros(imageHeight,imageWidth);
		lineData = lines{1,l};
		spanMax = max(lineData(:,5));
		spanMin = min(lineData(:,4));
		if (spanMax - spanMin) > (spanReq * imageWidth)
			for k = 1:1:rows(lineData)
				compNum = repmat(lineData(k,1),imageHeight,imageWidth);
				matched = (compNum == CCLabel);
				matched = matched .* imbw;
				newImage = newImage + matched;
			endfor
		trimMax = max(lineData(:,3));
		trimMin = min(lineData(:,2));
		newImage = newImage(trimMin:trimMax,:);
		numPix = (trimMax - trimMin) * imageWidth;
		numBlackPix = sum(sum(newImage));
		if(numPix > 0)
			density = numBlackPix / numPix;
			densityMatrix(densityCount) = density;
			densityCount = densityCount + 1;
		else
			density = 0;
		endif
		newImage = imrotate(newImage,-skew,"bilinear","loose",0);
		newImage = imcomplement(newImage);
			if(density >= densityReq)
				save_location = strcat(folder,"/",num2str(imageCount),".tif");
				imwrite(newImage,save_location);
				imageCount = imageCount + 1;
			endif
		endif
	endfor
	if(imageCount >= numImagesRequirement) || (limitedData == true)
		minLines = true;
	else
		densityMatrix = sort(densityMatrix,'descend');
		if columns(densityMatrix) >= numImagesRequirement
			densityReq = densityMatrix(numImagesRequirement);
		else
			densityReq = min(densityMatrix);
			limitedData = true;
		endif
	endif
	#toc();
endwhile
#zeroImage = zeros(imageHeight,imageWidth);
#newImage = (newImage > zeroImage);
#imshow(newImage)
f = lines;

endfunction
