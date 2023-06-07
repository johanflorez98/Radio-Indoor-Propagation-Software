%% Making dataset for the aplication of a Deep Learning Algorithm 
% Heat map estimation and cells estimations

% IMPORTANT###
% When viewing the properties of the image, its dimensions are observed, for
% example 250x350 (width x height), where width = 250px and height = 350px or whatever
% equivalent to rows = 350 and columns = 250, which is how you
% reads from MATLAB. Also when monitoring the walls
% positions x should be exchanged for y, and vice versa, as well as i for
%j for counters.

%The model used for the calculo of the network is the model WIFI IEEE
% 802.11ax 

clear
clc
close all

% The previously generated AP positions are loaded:
% (The positions of the transmitters must be loaded according to the structure
% of the network that you want to analyze, that is, independently to
% 1, 2, 3, 4 and 5 transmitters. The route should be changed on a case-by-case basis.)
simu = "5AP"; % Structure specific (1 to 5 APs)

% ###Change paths for read or save general data###

load("E:\DataSet5GHz\Txs\" + simu + "\" + simu + "_pos_AP_esc.mat")

size_pos = size(pos_AP_esc);
images = size_pos(3); % Simulations by scennario
images = 1000; 

% Init counter:
counter_im = 366;
Sce_act = 59; % Scennario present
amont_sce = size_pos(4); % Number of scenarios on which the database is created

time_pot = zeros(amont_sce, images);

% The format to save the images is established:
formato = '.png';

% Load initial drawing:
% (The path must be changed according to the case.)
plain1 = imread("G:\Otros ordenadores\Backup Trabajo Maestria\Trabajo 2 CV Maestria\DataSet\datasetUNet\Escenarios_blanco_RGB\" + string(Sce_act) + '.JPG'); % Plano inicial

plain = double(plain1);
% plain(:, :, 1) = plain1;
% plain(:, :, 2) = plain1;
% plain(:, :, 3) = plain1;

% Select which scale in meters is used:
% (In this case, 20 m x 20 m scenarios are analyzed)
x_meters = 20;
y_meters = 20;

% Network Parameters:
c_ligth = 3e8; % [m/s^2] Speed ​​of light
K = 1.380649e-23; % Boltzmann's constant [J]
B = 80e6; % Bandwidth [Hz]
T = 290; % T ambient in [°K]
PT = 26; % Transmitting antenna power [dBm]
GT = 3; % Gain of transmitting antenna [dBi]
GR = 0; % Gain of transmitting antenna [dBi]
%F = 2.412e9; % Operating frequency [Hz]
F = 5.610e9;
dbp = 10; % Break point distance [m]
P_walls = 5; % losses due to wall penetration [dB]
amont_AP = size_pos(1);
amont_variables = amont_AP*2; % Number of variables to optimize
coor = 2;
 
while counter_im <= images && Sce_act <= amont_sce
% while counter_im <= images && Sce_act <= 11

    close all

    % Read shape image:
    shape_image = size(plain);
    x_image = shape_image(1);
    y_image = shape_image(2);

    % The walls on the sides of the stage are secured (again):
    % (It is important to mention that here, the walls are now represented with
    % black pixels and the rest of the stage with white pixels, since
    % in the coverage map to be generated later, the sites of lower power 
    % are represented with pixel values close to zero.)
    plain(1, :, :) = 0;
    plain(:, 1, :) = 0;
    plain(shape_image(1), :, :) = 0;
    plain(:, shape_image(2), :) = 0;

    % The walls are specified again
    for i = 1:shape_image(1)
        for j = 1:shape_image(2)
            if plain(i, j, 1) <= 100
                plain2(i, j) = 0;
            end
            if plain(i, j, 1) > 100
                plain2(i, j) = 255;
            end
        end
    end
    
    % AP location based on previous positions:
    apx = pos_AP_esc(:, 1, counter_im, Sce_act);
    apy = pos_AP_esc(:, 2, counter_im, Sce_act);
    
    % AP location in pixels:
    AP=[apy apx];

    % Calculation of the map of powers by AP:
    tic % Starts counting time spent overall power map
    for ap = 1:amont_AP
        for i = 1:x_image
            for j = 1:y_image
                AP_2 = AP(ap, :);
                % The function that performs the calculation of the map of
                % coverage:
                PR_graphic(i, j, ap) = power_calculation(AP_2, plain2, ...
                                    x_image, y_image, x_meters, y_meters, c_ligth, ...
                                    PT, GT, GR, F, dbp, P_walls, i, j, K, T, B);
            end
        end
    end

    % General power map and scenario cells by AP:
    for i = 1:x_image
        for j = 1:y_image
            [PR_general(i, j) cell(i, j)] = max(PR_graphic(i, j, :));
        end
    end

    % Save matrix at format csv
    % Placement of the walls on the stage with the cells
    for i = 1:shape_image(1)
        for j = 1:shape_image(2)
            if plain2(i, j) == 0
                PR_general(i, j) = 10*log10((K*T*B)/1e-3);
            end
        end
    end
    
    writematrix(PR_general, "E:\DataSet5GHz\Maps and cells\" + string(simu) + "\MapsCSV\" + string(Sce_act) + "_" + string(counter_im) + ".csv", 'Delimiter', ';');
    writematrix(cell, "E:\DataSet5GHz\Maps and cells\" + string(simu) + "\CellsCSV\" + string(Sce_act) + "_" + string(counter_im) + ".csv", 'Delimiter', ';');

    % Graph of the general power map:
    mapa = figure;
    mapa.Color = 'white';
    a = PR_general;
    imshow(plain);
    hold on 
    im = imagesc(a);
    colormap(gray(numel(a))); 
    axis image;
    set(gca, 'xtick', [], 'ytick', []); % Axis labels are removed

    % The image is saved in RGB:
    fileName = "E:\DataSet5GHz\Maps and cells\" + simu + "\Maps\" + string(Sce_act) + '_' + string(counter_im) + string(formato);
    
    Fig = getframe(gca);
    imwrite(Fig.cdata,  fileName);

    % Placement of the walls on the stage:
    % First the image is read and binarized:
    sim_gray_bef = imread("E:\DataSet5GHz\Maps and cells\" + simu + "\Maps\" + string(Sce_act) + '_' + string(counter_im) + string(formato));

    sim_gray = im2gray(sim_gray_bef); % takes the image to a depth of 8 bits
    
%     for i = 1:shape_image(1)
%         for j = 1:shape_image(2)
%             if plain2(i, j) == 0
%                 sim_gray(i, j) = 0;
%             end
%         end
%     end

    % Image is saved:
    fileName = "E:\DataSet5GHz\Maps and cells\" + simu + "\Maps\" + string(Sce_act) + '_' + string(counter_im) + string(formato);
    
    imwrite(sim_gray,  fileName);

    % Graph of the scenario cells:
    mapa = figure;
    mapa.Color = 'white';
    a = cell;
    imshow(plain);
    hold on 
    im = imagesc(a);
    colormap(gray(numel(a))); 
    axis image;
    set(gca, 'xtick', [], 'ytick', []); 

    % The image is saved in RGB:
    fileName = "E:\DataSet5GHz\Maps and cells\" + simu + "\Cells\" + string(Sce_act) + '_' + string(counter_im) + string(formato);
    Fig = getframe(gca);
    imwrite(Fig.cdata,  fileName);

    % First the image is read and binarized:
    cells_gray_rgb = imread("E:\DataSet5GHz\Maps and cells\" + simu + "\Cells\" + string(Sce_act) + '_' + string(counter_im) + string(formato));

    cells_gray = im2gray(cells_gray_rgb);

    % The image is saved with a depth of 8 bits:
    fileName = "E:\DataSet5GHz\Maps and cells\" + simu + "\Cells\" + string(Sce_act) + '_' + string(counter_im) + string(formato);
 
    imwrite(cells_gray,  fileName);

    %%
    time = toc;  
    % The time spent for each power map calculation is stored:
    time_pot(Sce_act, counter_im) = time;

    % Shows on the screen the simulations carried out
    formatOut1 = 'HH:MM';
    horaAct = datestr(now, formatOut1);
    disp(['Map ', num2str(counter_im), ' of ', num2str(images),  ...
        ',  scennario ',  ...
        num2str(Sce_act), ' of ',  num2str(amont_sce), ',  time used: '...
        , num2str(time/60), ' minutes,  hour: ', num2str(horaAct)])
    
    %%
    % Scenario counters per plane and scenarios are increased
    % simulated:
    counter_im = counter_im + 1;
    
    % The start of a new power map calculation is given and
    % when you have all the power maps per scenario, it is done
    % a plane change:
    if counter_im == images + 1
        counter_im = 1;
        Sce_act = Sce_act + 1;
        if Sce_act <= amont_sce            
            plain1 = imread("G:\Otros ordenadores\Backup Trabajo Maestria\Trabajo 2 CV Maestria\DataSet\datasetUNet\Escenarios_blanco_RGB\" + string(Sce_act) + '.JPG');
            plain = plain1;
%             plain(:, :, 1) = plain1;
%             plain(:, :, 2) = plain1;
%             plain(:, :, 3) = plain1;
        end
    end
    
end

% close all 

%save("G:\Otros ordenadores\Backup Trabajo Maestria\Trabajo 2 CV Maestria\DataSet\datasetUNet\Pos_Transmisores_f\" + simu + "\time_pot.mat",  'time_pot');
