classdef WaveletPeakDetection < SpectralPeakDetection
    properties (Constant)
        Name = 'Wavelet';
        Description = '';
        
        ParameterDefinitions = [];
    end
    
    methods
        function [spectralChannels, intensities, peakDetails] = detectPeaks(obj, spectralChannels, intensities)
            
            
            
            % Ensure that the intensities and spectralChannels are oriented the same
            if(size(intensities, 2) ~= size(spectralChannels, 2))
                intensities = intensities';
            end
            
            %perform wavelet peak picking
            [waveletPeaks, pFwhm] = mspeaks(spectralChannels, intensities);
            %gets the resolving power from each peak in the dataset
            peakWidths = (pFwhm(:,2) - pFwhm(:,1));
            peakResolvingPower = waveletPeaks(:,1) ./ peakWidths;
            %estimates the resolving power as median in this dataset
            estimatedResolvingPower = median(peakResolvingPower);
            % removes peaks that have either greater than double or
            % less than half the estimated resolving power
            peaksToFilter = (((peakResolvingPower < (estimatedResolvingPower*2)) .* ((peakResolvingPower > (estimatedResolvingPower/2)))))==1;
            waveletPeaks = waveletPeaks(peaksToFilter,:);
            pFwhm = pFwhm(peaksToFilter,:);
           
            %set up peak details file
            peakDetails = zeros(size(waveletPeaks,1), 7);
            
            %add peak maxima and full widths at half maxima
            peakDetails(:,2) = waveletPeaks(:,1)';
            peakDetails(:,1) = pFwhm(:,1);
            peakDetails(:,3) = pFwhm(:,2);
            
            %add peak intensity to peak details
            peakDetails(:,4) = waveletPeaks(:,2)';
            
            % find locations of peaks and fwhm and add to peak details
            tic
            for i = 1:size(waveletPeaks,1)
                peakDetails(i,5)  = find(spectralChannels >= waveletPeaks(i,1), 1, 'first');
                peakDetails(i,6) =  find(spectralChannels > pFwhm(i,1), 1, 'first');
                peakDetails(i,7) = find(spectralChannels < pFwhm(i,2), 1, 'last');
            end
            toc
            
            
            
            % Select the peaks
            spectralChannels = waveletPeaks(:,1)';
            intensities = waveletPeaks(:,2)';
            
            
            
        end
    end
end