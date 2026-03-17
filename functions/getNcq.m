function y = getNcq(beta, Ns, esEmpotrada, x)
    % Busca IDs tipo BT{beta}N{Ns}
    y = obtenerFactorConBeta('data_ncq.csv', beta, Ns, esEmpotrada, x, 'N');
end