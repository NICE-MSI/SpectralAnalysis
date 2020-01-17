function [ adductMasses ] = f_makeAdductMassList( adducts, databaseMasses, polarity)

adductMasses = zeros(size(databaseMasses,1), length(adducts));
for i = 1:length(adducts)
    [isotopes] = f_stringToFormula(adducts{i});
    adductIsotopes = isotopicdist(isotopes);
    [~, l] = max(adductIsotopes(:,2));
    adductMass = adductIsotopes(1,l);
    adductMasses(:,i) = databaseMasses + adductMass;
end

if strcmp(polarity, 'positive') % add or lose mass of electron
    adductMasses = adductMasses - 0.00054858;
elseif strcmp(polarity, 'negative')
    adductMasses = adductMasses + 0.00054858;
end

end

