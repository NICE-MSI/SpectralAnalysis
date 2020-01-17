function [ formula ] = f_stringToFormula( formulaString )
%stringToFormula converts chemical formula string into structure suitable
%for isotopicdist function
%   placing - or + at the beginning signifies loss or addition, no symbol
%   is assumed as addition

asciiString = double(formulaString);
element = [];
elementNumber = [];
lossIdentifier = 1;
for i = 1:length(asciiString)
    if asciiString(i) == 45
        if i > 1
            if ~isempty(elementNumber)
                formula.(element) = elementNumber * lossIdentifier;
                elementNumber = [];
            else
                formula.(element) = 1 * lossIdentifier;
                elementNumber = [];
            end
        end
        lossIdentifier = -1;
    elseif asciiString(i) == 43
        if i > 1
            if ~isempty(elementNumber)
                formula.(element) = elementNumber * lossIdentifier;
                elementNumber = [];
            else
                formula.(element) = 1 * lossIdentifier;
                elementNumber = [];
            end
        end
        lossIdentifier = 1;
    end
    if asciiString(i) > 48 && asciiString(i) < 58 %check if its number
        if isempty(elementNumber)
            elementNumber = asciiString(i) - 48;
        else % fixes if > 10 of an element
            elementNumber = elementNumber * 10 + asciiString(i) - 47;
        end
    elseif asciiString(i) > 64 && asciiString(i) < 91
        if i > 1 %prevents searching for 0 index
            if ~isempty(element)
                if strcmp(element(length(element)), formulaString(i-1))
                    formula.(formulaString(i-1)) = 1 * lossIdentifier;
                elseif ~isempty(elementNumber)
                    formula.(element) = elementNumber * lossIdentifier;
                    elementNumber = [];
                end
            end
        end
        element = formulaString(i);
    elseif asciiString(i) > 96 && asciiString(i) < 123
        element = strcat(element, formulaString(i));
    end
end

if isempty(elementNumber)
    formula.(element) = 1 * lossIdentifier;
else
    formula.(element) = elementNumber * lossIdentifier;
end


end

