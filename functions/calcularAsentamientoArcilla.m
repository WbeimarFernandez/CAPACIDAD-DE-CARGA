
function [Se_mm, mu0, mu1] = calcularAsentamientoArcilla(tipoSuelo)
% CALCULARASENTAMIENTOARCILLA Calcula el asentamiento elástico en arcillas saturadas.
% Entrada: tipoSuelo (string)
% Salida: Se_mm (Asentamiento en mm), mu0 y mu1 (Factores de influencia)

    % 1. Validación del tipo de suelo
    if ~strcmpi(tipoSuelo, 'arcilla saturada')
        error('Error: Esta función solo es válida para "arcilla saturada".');
    end

    % 2. Solicitud de datos al usuario
    fprintf('\n--- Introduzca los parámetros para Arcilla Saturada ---\n');
    Df = input('Profundidad de desplante (Df) [m]: ');
    B  = input('Ancho de la cimentación (B) [m]: ');
    L  = input('Largo de la cimentación (L) [m]: ');
    H  = input('Espesor del estrato compresible (H) [m]: ');
    Es = input('Módulo de elasticidad del suelo (Es) [kN/m2]: ');
    q  = input('Carga neta aplicada (q) [kN/m2]: ');

    % 3. Cálculo de relaciones geométricas
    relacion_DfB = Df / B;
    relacion_HB  = H / B;
    relacion_LB  = L / B;

    % 4. Interpolación de Factor mu0 (Efecto profundidad)
    % Aproximación de Christian y Carrier (1978)
    mu0 = 1 - 0.19 * log10(1 + 1.1 * relacion_DfB);

    % 5. Interpolación de Factor mu1 (Efecto forma y espesor)
    % Curva para Cuadrada (L/B = 1) y Corrida (L/B > 10)
    f_cuadrada = 0.35 * log10(relacion_HB) + 0.15;
    f_corrida  = 0.45 * log10(relacion_HB) + 0.35;

    if relacion_LB <= 1
        mu1 = f_cuadrada;
    elseif relacion_LB >= 10
        mu1 = f_corrida;
    else
        % Interpolación lineal entre cuadrada y corrida según L/B
        mu1 = f_cuadrada + (f_corrida - f_cuadrada) * ((relacion_LB - 1) / 9);
    end

    % Ajuste de límites físicos de mu1 (típicamente entre 0.1 y 1.0)
    mu1 = max(min(mu1, 1.0), 0.1);

    % 6. Cálculo Final (Se = mu0 * mu1 * q * B / Es)
    Se_m = (mu0 * mu1 * q * B) / Es;
    Se_mm = Se_m * 1000;

    % 7. Reporte de resultados en consola
    fprintf('\n====================================');
    fprintf('\nRESULTADOS DEL ASENTAMIENTO');
    fprintf('\n====================================');
    fprintf('\nFactor mu0 (Profundidad): %.3f', mu0);
    fprintf('\nFactor mu1 (Forma/H):     %.3f', mu1);
    fprintf('\nAsentamiento Total:       %.2f mm', Se_mm);
    fprintf('\n====================================\n');

end