function yInterp = getNcq(idBuscado, xBuscado)
    % 1. Validar el rango de x
    if xBuscado < 0 || xBuscado > 5
        error('El valor de x debe estar entre 0 y 5.');
    end

    % 2. Ruta al archivo CSV
    rutaArchivo = fullfile(pwd, '..', 'data', 'data.csv');
    
    % 3. Configurar opciones de importación para CSV
    % 'VariableNamingRule','preserve' evita que MATLAB cambie nombres de columnas
    opts = detectImportOptions(rutaArchivo, 'VariableNamingRule', 'preserve');
    
    % Forzamos a que lea las primeras 3 columnas
    opts.SelectedVariableNames = opts.VariableNames(1:3); 
    
    % IMPORTANTE: En CSV es vital asegurar que el ID se lea como String
    % y no como categoría o número si el ID parece numérico.
    opts = setvaropts(opts, opts.VariableNames{1}, 'Type', 'string');
    opts = setvaropts(opts, opts.VariableNames{2}, 'Type', 'double');
    opts = setvaropts(opts, opts.VariableNames{3}, 'Type', 'double');

    % 4. Leer la tabla
    data = readtable(rutaArchivo, opts);
    data.Properties.VariableNames(1:3) = {'id', 'x', 'y'};

    % 5. Limpieza de asteriscos y espacios
    idLimpio = strrep(idBuscado, '*', ''); 
    
    % Filtrar (Usamos contains para mayor flexibilidad con el ID)
    filasId = data(contains(strtrim(data.id), idLimpio), :);

    if isempty(filasId)
        error('No se encontró el ID: %s', idBuscado);
    end

    % 6. Preparar datos (Eliminar NaNs y ordenar)
    x_val = filasId.x;
    y_val = filasId.y;
    
    mask = ~isnan(x_val) & ~isnan(y_val);
    x_val = x_val(mask);
    y_val = y_val(mask);

    if length(x_val) < 2
        error('Puntos insuficientes para %s', idBuscado);
    end

    [x_val, idx] = sort(x_val);
    y_val = y_val(idx);

    % 7. Interpolar
    yInterp = interp1(x_val, y_val, xBuscado, 'linear');
end