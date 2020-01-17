function adductList = convertAdductStringToList(adductString)
%takes a comma separated string of adducts and converts it to a cell array
%of individual adducts

adductString = adductString(adductString~=' '); %remove spaces as they are unneccessary
allCommas = adductString==','; %find commas
commaIdx = 0; 
commaIdx(2:sum(allCommas)+1) = find(allCommas);
commaIdx(length(commaIdx)+1) = length(adductString)+1;
for i = 1:length(commaIdx)-1
    adductList{i} = adductString(commaIdx(i)+1:commaIdx(i+1)-1);
end
end