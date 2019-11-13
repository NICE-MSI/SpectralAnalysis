classdef NN_tSNE < Clustering
    properties (Constant)
        Name = 'Neural network t-SNE';
        Description = '';
        
        ParameterDefinitions = [ParameterDescription('Subset size', ParameterType.Integer, 5), ...
            ParameterDescription('Distance Metric', ParameterType.Selection, {'Euclidean', 'Manhattan', 'Cosine', 'Correlation', 'Hamming'})];
    end
    
    methods
        function obj = NN_tSNE(subsetSize, distanceMetric)
            obj.Parameters{1} = Parameter(NN_tSNE.ParameterDefinitions(1), subsetSize);
            obj.Parameters{2} = distanceMetric;
        end
        
        function [dataRepresentationList regionOfInterestLists] = process(this, dataRepresentation)
            rois = this.regionOfInterestList.getObjects();
            
            if(this.preprocessEverySpectrum || ~isa(dataRepresentation, 'DataInMemory') || ~isempty(rois))
                % If not already in memory or requires processing then we need to
                % perform data cube reduction
                datacubeReduction = DatacubeReduction('New Window');
                
                datacubeReduction.applyPreprocessingToEverySpectrum(this.preprocessEverySpectrum);
                datacubeReduction.postProcessEntireDataset(this.processEntireDataset);
                datacubeReduction.setPreprocessingWorkflow(this.preprocessingWorkflow);
                datacubeReduction.setRegionOfInterestList(this.regionOfInterestList);
                
                dataRepresentationList = datacubeReduction.process(dataRepresentation);
            else
                dataRepresentationList = DataRepresentationList();
                dataRepresentationList.add(dataRepresentation);
            end
            
            subsetSize = this.Parameters{1}.value;
            if strcmp(this.Parameters{2}, 'Euclidean')
                distanceMetric = 'euclidean';
            elseif strcmp(this.Parameters{2}, 'Cosine')
                distanceMetric = 'cosine';
            elseif strcmp(this.Parameters{2}, 'Correlation')
                distanceMetric = 'correlation';
            elseif strcmp(this.Parameters{2}, 'Manhattan')
                distanceMetric = 'cityblock';
            elseif strcmp(this.Parameters{2}, 'Hamming')
                distanceMetric = 'hamming';
            end
            
            
            dataRepresentations = dataRepresentationList.getObjects();
            regionOfInterestLists = {};
            
            for i = 1:numel(dataRepresentations)
                mask = dataRepresentations{i}.regionOfInterest.pixelSelection';
               [ ~, ~, ~, reducedNeuralFull, tsneReduced, rgbImage, ~, ~, ~, ~, rgbData, ~] = deepLearningTSNE( dataRepresentations{i}.data, subsetSize, mask, distanceMetric );
                [res,C,SUMD,K]=kmeans_elbow(reducedNeuralFull',30);
                k = max(res);
                
                h = figure;
                imagesc(rgbImage)
                axis image
                axis off
                
                h = figure;
                scatter3(tsneReduced(:,1), tsneReduced(:,2), tsneReduced(:,3), 100, (tsneReduced - min(tsneReduced))./max(tsneReduced - min(tsneReduced)), 'x')
                
                %                curPixels = dataRepresentations{i}.regionOfInterest.pixelSelection;
                kmeansImage = zeros(dataRepresentation.height, dataRepresentation.width); %size(curPixels));
                
                pixels = dataRepresentations{i}.regionOfInterest.getPixelList();
                
                if(dataRepresentations{i}.isRowMajor)
                    % Sort by y column, then by x column
                    pixels = sortrows(pixels, [2 1]);
                else
                    % Sort by x column, then by y column
                    pixels = sortrows(pixels, [1 2]);
                end
                
                for j = 1:length(pixels)
                    kmeansImage(pixels(j, 2), pixels(j, 1)) = res(j);
                end
                
                %                 figure, imagesc(kmeansImage);
                
                %                 kmeansImage = zeros(size(curPixels));
                %                 kmeansImage(curPixels == 1) = res;
                
                regionOfInterestLists{i} = RegionOfInterestList();
                
                for j = 1:k
                    roi = RegionOfInterest(size(kmeansImage, 2), size(kmeansImage, 1));
                    roi.addPixels(kmeansImage == j);
                    roi.setName(['k = ' num2str(j)]);
                    clusterColour = mean(rgbData(res==j,:));
                    clusterColour(clusterColour>1) = 1;
                    clusterColour(clusterColour<0) = 0;
                    clusterColour = round(clusterColour*255);
                    roi.setColour(Colour(clusterColour(1), clusterColour(2), clusterColour(3)));
                    
                    %                     roi.cropTo(curPixels);
                    
                    regionOfInterestLists{i}.add(roi);
                    %                     curPixels(curPixels == 1) = res
                end
            end
            
            %             % Create projection data representation
            %             kmeansDataRepresentation = DataInMemory();
            %             kmeansDataRepresentation.setData(res, dataRepresentation.pixelSelection, dataRepresentation.isRowMajor, 0);
            %             dataRepresentation = kmeansDataRepresentation;
        end
    end
end