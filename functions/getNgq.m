function y = getNgq(beta, phi, esEmpotrada, x)
    % Busca IDs tipo BT{beta}P{phi}
    y = obtenerFactorConBeta('data_ngq.csv', beta, phi, esEmpotrada, x, 'P');
end