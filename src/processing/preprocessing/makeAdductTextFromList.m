function adductText = makeAdductTextFromList(adductList)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

for i = 1:length(adductList)
    asciiVals = double(adductList{i});
    isnum = [asciiVals<58] .* [asciiVals>47];
    d = find(isnum);
    if isempty(d)
        adductText{i} = adductList{i};
    end
    for j = 1:sum(isnum)
        if d(j)==1
            adductText{i}(1) = '_';
        elseif sum(isnum)==1
            adductText{i}(1:d-1) = adductList{i}(1:d-1);
            adductText{i}(end+1) = '_';
            adductText{i}(end+1) = adductList{i}(d);
        else
            if j == 1
                adductText{i}(1:d(j)-1) = adductList{i}(1:d(j)-1);
                adductText{i}(end+1) = '_';
                adductText{i}(end+1) = adductList{i}(d(j));
            elseif d(j-1) == d(j)-1
                adductText{i}(end+1) = '_';
                adductText{i}(end+1) = adductList{i}(d(j));
            else
                adductText{i}(end+1:(end+d(j) - d(j-1) -1)) = adductList{i}(d(j-1)+1:d(j)-1);
                adductText{i}(end+1) = '_';
                adductText{i}(end+1) = adductList{i}(d(j));
            end            
        end
        if j ==sum(isnum) && d(j) < length(adductList{i})
            adductText{i}(end+1:end+length(adductList{i}) - d(j)) = adductList{i}(d(j)+1:end);
        end
    end
end

end

