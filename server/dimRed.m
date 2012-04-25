% Spring 2012, 18-551 Project
% Dimensionality Reduction using PCA

function [dataSet nVecs cummulVar] = dimRed(data, dataGray, n, numSamplesPerChar, numClasses, reducFact, numNoisy, noisyData, rowDiv, colDiv)
% Assume that data coming in is e.g. imgDataTrain

% Calculating feature vector size
char = data{1};
dim = numel(char{1}) * reducFact * reducFact;
dim = dim + 16; % For vertical and horizontal projections
dim = 32*4 + 16 + 128*128*3 + 128*128 + 128*128;
dim = 64*4 + 64 + 16*16*5;
% elliptical, zoning, gaussian, log, gabors

% Creating the filter bank
% Variables
nFilters = 5;

% For Gaussian
sigma = 0.5; % sigma for gaussian

% For Gabor
theta1 = degtorad(0);
theta2 = degtorad(60);
theta3 = degtorad(120);
gamma = 2;
lambda = 0.6;
psi = 0;

% Setting up filter bank
filterBank = cell(nFilters, 1);
filterBank{1} = fspecial('gaussian', 16*16, sigma);
filterBank{2} = fspecial('log', 16*16, sigma);
filterBank{3} = gaborFilter(sigma, theta1, lambda, psi, gamma);
filterBank{4} = gaborFilter(sigma, theta2, lambda, psi, gamma);
filterBank{5} = gaborFilter(sigma, theta3, lambda, psi, gamma);


% Formatting dataInput
dataInput = zeros(numSamplesPerChar * numClasses, dim);
dataIndex = 0;
for i = 1:numClasses
    
    % Noisy Images
    %char = noisyData{i};
    for j = 1:numNoisy
        dataIndex = dataIndex + 1;
%         thumbnail = imresize(char{end - j}, reducFact);
%         vec = getCompositeFeature(char{end - j});
%         dataInput(dataIndex, :) = [reshape(thumbnail, 1, dim-256) vec];
%         dataInput(dataIndex, :) = getCompositeFeature(char{end - j});
%         dataInput(dataIndex, :) = getSkeletonZoneFeature(char{end - j}, rowDiv, colDiv);

        % Data should have grayscale and binary
        % Assume image is grayscale (ie imgData...not raw)
        charBW = im2bw(char{end - j});
        charGray = histeq(char{end - j});
        
        % Creating feature vector
        % Elliptical
        outline = getOutline(charBW);
        rFSDs = fEfourier(outline, 32, 1, 1);
        curveVec = reshape(rFSDs, 1, 32*4);
        
        % Zoning
        zonVec = getSkeletonZoneFeature(charBW, rowDiv, colDiv);
        
%         % Filters
%         filtVec1 = imfilter(charGray, filterBank{1});
%         filtVec1 = reshape(filtVec1, numel(filtVec1), 1);
%         
%         filtVec2 = imfilter(charGray, filterBank{2});
%         filtVec2 = reshape(filtVec2, numel(filtVec2), 1);
%         
%         filtVec3 = imfilter(charGray, filterBank{3});
%         filtVec3 = reshape(filtVec3, numel(filtVec3), 1);
%         
%         filtVec4 = imfilter(charGray, filterBank{4});
%         filtVec4 = reshape(filtVec4, numel(filtVec4), 1);
%         
%         filtVec5 = imfilter(charGray, filterBank{5});
%         filtVec5 = reshape(filtVec5, numel(filtVec5), 1);
%         
%         filtVec = [filtVec1 filtVec2 filtVec3 filtVec4 filtVec5];
% 
%         dataInput(dataIndex, :) = [curveVec zonVec filtVec];
        dataInput(dataIndex, :) = [curveVec zonVec];
    end
    
    % Clean Images
    char = data{i};
    charG = dataGray{i};
    for j = 1:numSamplesPerChar-numNoisy
        dataIndex = dataIndex + 1;
%         thumbnail = imresize(char{j}, reducFact);
%         vec = getCompositeFeature(char{j});
%         dataInput(dataIndex, :) = [reshape(thumbnail, 1, dim-256) vec];
%         dataInput(dataIndex, :) = getCompositeFeature(char{j});
%         dataInput(dataIndex, :) = getSkeletonZoneFeature(char{j}, rowDiv, colDiv);

        % Data should have grayscale and binary
        % Assume image is grayscale (ie imgData...not raw)
        %charBW = im2bw(char{j}); %IF NOT RAW THEN UNCOMMENT'
        charBW = char{j}; % IF RAW UNCOMMENT
        %charGray = histeq(char{j}); %IF NOT RAW THEN UNCOMMENT
        charGray = charG{j}; % IF RAW UNCOMMENT
        charGray = imresize(charGray, [128/8 128/8]);
        
        % Creating feature vector
        % Elliptical
        outline = getOutline(charBW);
        rFSDs = fEfourier(outline, 64, 1, 1);
        curveVec = reshape(rFSDs, 1, 64*4);
        if (any(isnan(curveVec)))
            curveVec
            imshow(charBW)
            displayOutline(outline)
            charBW
        end
        
        % Zoning
        zonVec = getSkeletonZoneFeature(charBW, rowDiv, colDiv);
        
        % Filters
        filtVec1 = imfilter(charGray, filterBank{1});
        filtVec1 = reshape(filtVec1, 1, numel(filtVec1));
        
        filtVec2 = imfilter(charGray, filterBank{2});
        filtVec2 = reshape(filtVec2, 1, numel(filtVec2));
        
        filtVec3 = imfilter(charGray, filterBank{3});
        filtVec3 = reshape(filtVec3, 1, numel(filtVec3));
        
        filtVec4 = imfilter(charGray, filterBank{4});
        filtVec4 = reshape(filtVec4, 1, numel(filtVec4));
        
        filtVec5 = imfilter(charGray, filterBank{5});
        filtVec5 = reshape(filtVec5, 1, numel(filtVec5));
        
        filtVec = [filtVec1 filtVec2 filtVec3 filtVec4 filtVec5];
        dataInput(dataIndex, :) = [curveVec zonVec filtVec];
    end
end

% PCA
%[v d] = eig(cov(dataInput));
%d = rot90(d,2);
%v = fliplr(v);
%cummulVar = cumsum(diag(d))/sum(diag(d));
[COEFF, SCORE, LATENT] = princomp(dataInput);
cummulVar = cumsum(diag(LATENT))/sum(diag(LATENT));

%fprintf('%d\% Variance Captured using %d basis\n', cummulVar(n), n);

% Getting the first n eigenvectors
nVecs = COEFF(:,1:n);
dataSet = dataInput * nVecs; % USE PRINCOMP
end