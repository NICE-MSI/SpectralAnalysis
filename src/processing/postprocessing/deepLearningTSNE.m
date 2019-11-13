function [ net, performaces, subsetNeural, reducedNeuralFull, tsneReduced, rgbImage, autoencoder, top50Scores, top50Coeffs, mu, rgbData, rgbDataSubset] = deepLearningTSNE( data, subsetSize, mask, distance )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


subset = data(1:subsetSize:size(data,1),:);
[Coeffs, Scores] = pca(subset);
top50Scores = Scores(:,1:50);
[~, mu, ~] = zscore(subset);
top50Coeffs = Coeffs(:,1:50);
tsneReduced = tsne(subset, 'Algorithm', 'exact', 'Distance', distance, 'NumDimensions',3);
pcaReduced50Full = (data - repmat(mu,size(data,1),1)) * top50Coeffs;
autoencoder{1} = trainAutoencoder(top50Scores',25, ...
'MaxEpochs',1000, ...
'EncoderTransferFunction', 'logsig',...
'DecoderTransferFunction','logsig', ...
'L2WeightRegularization', 0.0001, ...
'SparsityRegularization', 8, ...
'UseGPU',true, ...
'SparsityProportion',0.1);
featureSpaceSubset{1} = encode(autoencoder{1},top50Scores');
featureSpaceFull{1} = encode(autoencoder{1}, pcaReduced50Full');
autoencoder{2} = trainAutoencoder(featureSpaceSubset{1},10, ...
'MaxEpochs',1000, ...
'EncoderTransferFunction', 'logsig',...
'DecoderTransferFunction','logsig', ...
'L2WeightRegularization', 0.01, ...
'SparsityRegularization', 4, ...
'UseGPU',true, ...
'SparsityProportion',0.1);
featureSpaceSubset{2} = encode(autoencoder{2},featureSpaceSubset{1});
featureSpaceFull{2} = encode(autoencoder{2},featureSpaceFull{1});
trainingMethod = 'trainbr';
neuralNetwork = fitnet(25, trainingMethod);
neuralNetwork.divideParam.trainRatio = 70/100;
neuralNetwork.divideParam.valRatio = 15/100;
neuralNetwork.divideParam.testRatio = 15/100;
[net, performaces] = train(neuralNetwork,featureSpaceSubset{2},tsneReduced');
subsetNeural = sim(net,featureSpaceSubset{2});
reducedNeuralFull = sim(net,featureSpaceFull{2});
[n, m] = size(mask);
rgbImage = zeros(m,n,3);
for k = 1:3
temp = tsneReduced(:,k);
a = min(temp);
b = max(temp - min(temp));
rgbDataSubset(:,k) = (temp - a) ./ b;
temp = reducedNeuralFull(k,:);
temp2 = (temp - a) ./ b;
image = double(mask);
image(image==1) = temp2;
rgbData(:,k) = temp2;
rgbImage(:,:,k) = image';
end

end

