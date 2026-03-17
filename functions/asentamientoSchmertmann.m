function [de, C1, C2] = asentamientoSchmertmann(L, B, gamma, Df, sq, t, Es)
    % 1. Parámetros básicos y carga neta
    q = gamma * Df;
    p_neta = sq - q; % (sq - q)
    
    if p_neta <= 0
        error('La sobrecarga (sq) debe ser mayor que la presión de desplante (q).');
    end

    % 2. Factores de corrección C1 y C2
    C1 = max(0.5, 1 - 0.5 * (q / p_neta));
    C2 = 1 + 0.2 * log10(t / 0.1);

    % 3. Determinación de la geometría de Iz
    relacionLB = L / B;
    dz = 0.01; % Paso de integración (1 cm)
    
    % Definimos los puntos clave según la relación L/B
    if relacionLB <= 1
        z_pico = 0.5 * B;
        z_final = 2.0 * B;
        Iz_ini = 0.1;
    elseif relacionLB >= 10
        z_pico = 1.0 * B;
        z_final = 4.0 * B;
        Iz_ini = 0.2;
    else
        % INTERPOLACIÓN LINEAL entre L/B=1 y L/B=10
        % Fracción de interpolación
        f = (relacionLB - 1) / (10 - 1);
        
        z_pico = (0.5 * B) + f * (1.0 * B - 0.5 * B);
        z_final = (2.0 * B) + f * (4.0 * B - 2.0 * B);
        Iz_ini = 0.1 + f * (0.2 - 0.1);
    end

    % 4. Cálculo de Iz_pico (Varía con la presión neta)
    % Iz_p = 0.5 + 0.1 * sqrt(p_neta / sigma_vp) 
    % Para simplificar según tu solicitud original, mantenemos Iz_pico 
    % como el punto de quiebre de las rectas:
    Iz_pico = 0.5 + 0.1 * sqrt(p_neta / (gamma * (Df + z_pico)));

    % 5. Integración Numérica (Sumatoria Iz * Dz / Es)
    z_vector = 0:dz:z_final;
    suma_Iz_Dz_Es = 0;

    for z = z_vector
        if z <= z_pico
            % Recta ascendente: desde Iz_ini hasta Iz_pico
            Iz = Iz_ini + (Iz_pico - Iz_ini) * (z / z_pico);
        else
            % Recta descendente: desde Iz_pico hasta 0 en z_final
            Iz = Iz_pico * (z_final - z) / (z_final - z_pico);
        end
        
        % Solo sumamos si Iz es positivo
        if Iz > 0
            suma_Iz_Dz_Es = suma_Iz_Dz_Es + (Iz * dz / Es);
        end
    end

    % 6. Cálculo final del asentamiento
    de = C1 * C2 * p_neta * suma_Iz_Dz_Es;
end