% Cálculo de Lacunaridad
clc;
clear all;
close all;

ruta_vasos = '35_vasos.png';

% Cargar imagen
vasos = imread(ruta_vasos);
if ndims(vasos) == 3
    vasos = rgb2gray(vasos);
end
if ~islogical(vasos)
    vasos = imbinarize(vasos);
else
    vasos = logical(vasos);
end

fprintf('Imagen cargada: %s\n', ruta_vasos);
fprintf('Resolución: %d x %d px\n', size(vasos,2), size(vasos,1));

[filas, columnas] = size(vasos);

% Escalas
num_cajas   = [2 4 8 16 32 64 128 256 512];
num_escalas = length(num_cajas);

lacunaridad = zeros(1, num_escalas);
N           = zeros(1, num_escalas);

for i = 1:num_escalas

    k        = num_cajas(i);
    tam_caja = ceil(max(filas,columnas) / k);

    filas_pad    = k * tam_caja;
    columnas_pad = k * tam_caja;
    pad_filas    = filas_pad - filas;
    pad_columnas = columnas_pad - columnas;

    pad_sup = floor(pad_filas/2);
    pad_inf = ceil(pad_filas/2);
    pad_izq = floor(pad_columnas/2);
    pad_der = ceil(pad_columnas/2);

    imagen_pad = padarray(vasos, [pad_sup pad_izq], 0, 'pre');
    imagen_pad = padarray(imagen_pad, [pad_inf pad_der], 0, 'post');

    masas    = zeros(1, k*k);
    idx_masa = 0;

    for r = 1:k
        for c = 1:k
            r_ini  = (r-1)*tam_caja + 1;
            r_fin  = r*tam_caja;
            c_ini  = (c-1)*tam_caja + 1;
            c_fin  = c*tam_caja;
            bloque = imagen_pad(r_ini:r_fin, c_ini:c_fin);

            masa     = sum(bloque(:));
            idx_masa = idx_masa + 1;
            masas(idx_masa) = masa;

            if masa > 0
                N(i) = N(i) + 1;
            end
        end
    end

    % Lacunaridad: Λ(r) = σ²(r) / μ²(r) + 1
    mu     = mean(masas);
    sigma2 = var(masas);

    if mu == 0
        lacunaridad(i) = 0;
    else
        lacunaridad(i) = (sigma2 / mu^2) + 1;
    end
end

% Tabla de resultados
fprintf('\nTabla de Lacunaridad\n');
fprintf('%8s %10s %12s\n', 'k (cajas)', 'N(l)', 'Λ(r)');
fprintf('-------------------------------------\n');
for i = 1:num_escalas
    fprintf('%8d %10d %12.4f\n', num_cajas(i), N(i), lacunaridad(i));
end
fprintf('-------------------------------------\n');
fprintf('Lacunaridad media = %.4f\n\n', mean(lacunaridad));

% Gráfica
figure;
plot(log(num_cajas), lacunaridad, 'ko-','LineWidth', 2, 'MarkerFaceColor', 'k', 'MarkerSize', 7);
grid on;
xlabel('log(1/l)', 'FontSize', 12);
ylabel('Lacunaridad  (Λ)',        'FontSize', 12);
title('Lacunaridad', 'FontSize', 13);
legend('Curva de Lacunaridad', 'Location', 'best');

text(min(log(num_cajas))+0.1, max(lacunaridad)*0.95,['\Lambda_{media} = ' num2str(mean(lacunaridad),'%.4f')], ...
'FontSize', 11, 'Color', 'k', 'FontWeight', 'bold');