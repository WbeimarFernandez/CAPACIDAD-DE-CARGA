function qu = calcularQuSobreTalud(beta, phi, c, gamma, B, H, b, Df)
    % 1. Determinar Ns (Considerando la relación B y H)
    % Si B < H, se fuerza Ns = 0 por criterio de diseño.
    if B < H
        Ns = 0;
    else
        % Si B >= H, se usa el Ns calculado (evitando división por cero)
        if c > 0
            Ns = (gamma * H) / c;
        else
            Ns = 4; % Valor máximo usual en tablas si no hay cohesión
        end
    end
    
    % Redondeo de Ns a los valores disponibles en tus IDs (0, 2, 4)
    posiblesNs = [0, 2, 4];
    [~, idxNs] = min(abs(posiblesNs - Ns));
    NsTabla = posiblesNs(idxNs);

    % 2. Condición de empotramiento (Df/B = 1)
    esEmpotrada = (abs(Df/B - 1) < 0.1); 
    
    % 3. Definir variable X (Distancia normalizada)
    % Para Ncq: si Ns es 0 se usa b/B, de lo contrario b/H
    if NsTabla == 0
        x_Ncq = b / B;
    else
        x_Ncq = b / H;
    end
    
    % Para Ngq: siempre se usa b/B
    x_Ngq = b / B;

    % 4. Obtener factores llamando a la lógica de interpolación doble (Beta y X)
    try
        Ncq = getNcq(beta, NsTabla, esEmpotrada, x_Ncq);
        Ngq = getNgq(beta, phi, esEmpotrada, x_Ngq);
    catch ME
        error('Error al obtener factores: %s', ME.message);
    end

    % 5. Ecuación final de capacidad de carga última
    qu = (c * Ncq) + (0.5 * gamma * B * Ngq);
    
    % --- Reporte de variables en consola ---
    fprintf('\n--- Resultados de Capacidad de Carga ---\n');
    fprintf('Criterio B < H: %s (B=%.2f, H=%.2f)\n', string(B < H), B, H);
    fprintf('Ns utilizado: %d\n', NsTabla);
    fprintf('Ncq: %.3f (usando x=%.2f)\n', Ncq, x_Ncq);
    fprintf('Ngq: %.3f (usando x=%.2f)\n', Ngq, x_Ngq);
    fprintf('qu:  %.2f kPa\n', qu);
end