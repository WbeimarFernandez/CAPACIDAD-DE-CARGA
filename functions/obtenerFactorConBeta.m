function valorFinal = obtenerFactorConBeta(nombreArchivo, betaBuscado, valorBusqueda, esEmpotrada, xBuscado, tipoFactor)
    % Parámetros extra:
    % tipoFactor: 'N' para Ncq (usa Ns), 'P' para Ngq (usa Phi)

    % 1. Cargar datos
    rutaArchivo = fullfile(pwd, '..', 'data', nombreArchivo);
    opts = detectImportOptions(rutaArchivo, 'VariableNamingRule', 'preserve');
    opts.SelectedVariableNames = opts.VariableNames(1:3); 
    opts = setvaropts(opts, opts.VariableNames{1}, 'Type', 'string');
    data = readtable(rutaArchivo, opts);
    data.Properties.VariableNames(1:3) = {'id', 'x', 'y'};

    % 2. Construir el sufijo de búsqueda (ej: "N0i" o "P40i")
    sufijo = [tipoFactor, num2str(valorBusqueda)];
    if esEmpotrada, sufijo = [sufijo, 'i']; end
    
    % Filtrar IDs que terminen exactamente en ese sufijo
    indicesCompatibles = endsWith(data.id, sufijo);
    tabFiltrada = data(indicesCompatibles, :);
    
    if isempty(tabFiltrada)
        error('No hay datos para %s en el archivo %s', sufijo, nombreArchivo);
    end

    % 3. Extraer ángulos Beta disponibles
    idsUnicos = unique(tabFiltrada.id);
    betasExistentes = zeros(length(idsUnicos), 1);
    for k = 1:length(idsUnicos)
        % Busca el número después de 'BT' y antes de 'N' o 'P'
        expr = ['(?<=BT)\d+(?=', tipoFactor, ')'];
        numStr = regexp(idsUnicos{k}, expr, 'match');
        betasExistentes(k) = str2double(numStr{1});
    end
    [betasExistentes, idxSort] = sort(betasExistentes);
    idsUnicos = idsUnicos(idxSort);

    % 4. Interpolación Doble (X y luego Beta)
    yPorBeta = zeros(length(betasExistentes), 1);
    for k = 1:length(betasExistentes)
        sub = tabFiltrada(strcmp(tabFiltrada.id, idsUnicos{k}), :);
        x_v = sub.x; y_v = sub.y;
        mask = ~isnan(x_v) & ~isnan(y_v);
        [x_v, idxX] = sort(x_v(mask));
        y_v = y_v(mask); y_v = y_v(idxX);
        yPorBeta(k) = interp1(x_v, y_v, xBuscado, 'linear', 'extrap');
    end

    % Interpolación final de Beta
    valorFinal = interp1(betasExistentes, yPorBeta, betaBuscado, 'linear', 'extrap');
end