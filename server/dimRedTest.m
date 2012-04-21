% Spring 2012, 18-551 Project
% Dimensionality Reduction using PCA
% Used for testing

function [dataSet] = dimRedTest(data, numSamplesPerChar, numClasses, nVecs, numNoisy, noisyData)
% Assume that data coming in is e.g. imgDataTest

reducFact = 0.25; % Reduction factor
char = data{1};
dim = numel(char{1}) * reducFact * reducFact;
dim = dim + 256; % For projections

% Formatting dataInput
dataInput = zeros(numSamplesPerChar * numClasses, dim);
dataIndex = 0;
for i = 1:numClasses
    
    % Noisy Images
    char = noisyData{i};
    for j = 1:numNoisy
        dataIndex = dataIndex + 1;
        thumbnail = imresize(char{end - j}, reducFact);
        vec = getCompositeFeature(char{end - j});
        dataInput(dataIndex, :) = [reshape(thumbnail, 1, dim-256) vec];
    end
    
    % Clean Images
    char = data{i};
    for j = 1:numSamplesPerChar-numNoisy
        dataIndex = dataIndex + 1;
        thumbnail = imresize(char{j}, reducFact);
        vec = getCompositeFeature(char{j});
        dataInput(dataIndex, :) = [reshape(thumbnail, 1, dim-256) vec];
    end
end

% Getting the first n eigenvectors
dataSet = dataInput * nVecs;
end