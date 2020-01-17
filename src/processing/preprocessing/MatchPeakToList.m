classdef MatchPeakToList < PeakFilter
    properties (Constant)
        Name = 'Match to list';
        Description = '';
        
        ParameterDefinitions = [ParameterDescription('List path', ParameterType.String, ''), ...
            ParameterDescription('Ppm threshold', ParameterType.Double, 50),...
            ParameterDescription('Adducts', ParameterType.String, ''),...
            ParameterDescription('Positive polarity', ParameterType.Boolean, 1)];
    end
    
    properties
        curatedList;
        threshold;
        adducts;
        polarity;
    end
    
    methods
        function this = MatchPeakToList(curatedList, threshold, adducts, polarity)
            if(nargin == 4)
                this.Parameters = Parameter(MatchPeakToList.ParameterDefinitions(1), curatedList);
                this.Parameters(2) = Parameter(MatchPeakToList.ParameterDefinitions(2), threshold);
                this.Parameters(3) = Parameter(MatchPeakToList.ParameterDefinitions(3), adducts);
                this.Parameters(4) = Parameter(MatchPeakToList.ParameterDefinitions(4), polarity);
                
            end
        end
        
        function [spectralChannels, intensities, peakDetails] = applyFilter(this, spectralChannels, intensities, peakDetails)
            listPath = this.Parameters(1).value;
            ppmTolerance = this.Parameters(2).value;
            adductString = this.Parameters(3).value;
            listPath = listPath(listPath~='"');
            filterList = false(length(spectralChannels),1);
            if this.Parameters(4).value
                polarity = 'positive';
            else
                polarity = 'negative';
            end
            adductList = convertAdductStringToList(adductString);
            adductText = makeAdductTextFromList(adductList);
            %try and load excel file
            try
                [monoisotopicMassList, labels] = xlsread(listPath);
            catch %if not excel then try a csv instead
                [monoisotopicMassList] = csvread(listPath);
            end
            [ adductMasses ] = f_makeAdductMassList( adductList, monoisotopicMassList, polarity);
            cc = 1;
            for i = 1:length(spectralChannels)
                ppmError = abs(((adductMasses - spectralChannels(i))./ spectralChannels(i)) * 1000000); % checks each peak against possible adduct list
                [matchedR, matchedC] = find(ppmError < ppmTolerance); % finds those within ppm error
                if length(matchedR) > 1
                    matchError = inf(length(matchedR),1);
                    for j = 1:length(matchedR)
                        matchError(j) = ppmError(matchedR(j), matchedC(j));
                    end
                    [~, minErrIdx] = min(matchError);
                    matchedR = matchedR(minErrIdx);
                    matchedC = matchedC(minErrIdx);
                end
                if ~isempty(matchedR)
                    filterList(i) = true;
                    if adductList{matchedC}(1) == '-'
                        if this.Parameters(4).value
                            matchedList(cc) = strcat(labels(matchedR), ' [M', adductText(matchedC), ']^+');
                        else
                            matchedList(cc) = strcat(labels(matchedR), ' [M', adductText(matchedC), ']^-');
                        end
                    else
                        if this.Parameters(4).value
                            matchedList(cc) = strcat(labels(matchedR), ' [M+', adductText(matchedC), ']^+');
                        else
                            matchedList(cc) = strcat(labels(matchedR), ' [M+', adductText(matchedC), ']^-');
                        end
                    end
                    cc = cc+1;
                end
            end
            %             spectralChannels = spectralChannels(filterList);
            spectralChannels = matchedList;
            intensities = intensities(filterList);
            peakDetails = peakDetails(filterList,:);
        end
        
    end
end