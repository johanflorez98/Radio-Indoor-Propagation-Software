clear
% Generation of AP locations ********************************

close all
clc

% Current scenario:
scen = 11;
amo_scen = 60; % Number of scenarios availables************************

% AP Positions per scenario:
pos = 1000; % Number of simulations to be carried out per scenario
pos1 = 1; % Counter of AP positions per scenario

amo_AP = 5; % Amount of AP************************************************
simulation = "5AP";
load("G:\Otros ordenadores\Backup Trabajo Maestria\Trabajo 2 CV Maestria\DataSet\datasetUNet\Pos_Transmisores_f\" + string(simulation) + "\pos_AP_esc.mat");
% (it is modified according to the structure of the network that is wanted, in this case,
% established 1,2 and 3 access points)
%%
% Generation cycle of scenarios and transmitters:
while pos1 <= pos && scen <= amo_scen

    % current plane reading:
    if pos1 == 1
        % Images that are read as scenarios
        % are represented in black pixels and the
        % rest of it with blank pixels.
        % (The path should be changed depending on the folder where the images are stored
        % of scenarios)
        plain = imread("G:\Otros ordenadores\Backup Trabajo Maestria\Trabajo 2 CV Maestria\DataSet\datasetUNet\Escenarios_blanco_RGB\" + string(scen) + '.JPG'); % plain inicial
        amo = size(plain); % Size of the scenarios
        
        % Adequacy of the plan ********************************************
        % The image is binarized:
        % Walls are now rendered with white pixels and the rest
        % of stage with black pixels. Likewise the images
        % are generated at a depth of 8 bits.
        for i = 1:amo(1)
            for j = 1:amo(2)
                if plain(i,j,1) <= 100
                    plain1(i,j) = 255;
                end
                if plain(i,j,1) > 100
                    plain1(i,j) = 0;
                end
            end
        end
        
        % Side walls are secured:
        plain1(1,:) = 255;
        plain1(amo(1),:) = 255;
        
        plain1(:,1) = 255;
        plain1(:,amo(2)) = 255;
        
        % The processed plan is displayed and saved:
        figure(1)
        imshow(plain1)
        imwrite(plain1,"E:\DataSet5GHz\Scennarios init\Scennarios B\" + string(scen) + '.png')
    end

    % Random AP location, leaving 10px margin from
    % to the edges of each image:
    apx = randi([0+10 amo(1)-10],1,amo_AP);
    apy = randi([0+10 amo(2)-10],1,amo_AP);
    
    AP = [apx' apy'];

    % APs are relocated if they are on walls *****************
    % move 5 pixels diagonally to the right:
    for k = 1:amo_AP
        for i = 1:amo(1)
            for j = 1:amo(2)
                if plain1(i,j) == 255 && AP(k,1) == i && AP(k,2) == j
                    AP(k,1) = AP(k,1) + 5;
                    AP(k,2) = AP(k,2) + 5;
                end
            end
        end
    end
    
    % AP positions are updated
    antennas = zeros(amo(1),amo(2));
    
    for i=1:length(apx)
        antennas(AP(i,1),AP(i,2)) = 255;
    end
    
    % Transmitter positions are displayed and saved:
    figure(2)
    imshow(antennas)
%     imwrite(antennas,"E:\DataSet5GHz\Txs\" + string(simulation) + "\" + string(esc) + '_'+string(pos1) + '.png')

    % Locations (x,y) of APs per scenario are stored ************
    pos_AP_esc(:,:,pos1,scen) = AP; % (x,y,position_AP,scenario)
    pos1 = pos1 + 1;
    if pos1 == pos + 1
        pos1 = 1;
        scen = scen + 1;
    end

    % The positions of the APs are saved for any subsequent use that may be
    % require:
    save("E:\DataSet5GHz\Txs\" + string(simulation) + "\" + string(simulation) + "_pos_AP_esc.mat", 'pos_AP_esc');

    disp([num2str(pos1), '/', num2str(pos), ' - ', num2str(scen), '/', num2str(amo_scen)])
end
%% Division of APs positions in individual images:
% clear
close all
clc

load("E:\DataSet5GHz\Txs\" + string(simulation) + "\" + string(simulation) + "_pos_AP_esc.mat");
scennarios = amo_scen;
positions = pos;
APs = amo_AP;

for i = scen : scennarios
    for j = 1 : positions
        AP_po = pos_AP_esc(:,:,j,i);

        antennas = zeros(256,256,APs);
    
        for k=1:APs
            antennas(AP_po(k,1),AP_po(k,2),k) = 255;
            imwrite(antennas(:,:,k), "E:\DataSet5GHz\Txs\" + string(simulation) + "\" + string(i) + '_'+ string(j)+ '_' + string(k) + '.png');
%             imwrite(antennas(:,:,k), "E:\DataSet5GHz\Txs\" + string(simulation) + "\" + string(i) + '_'+ string(j) + '.png');
        end
    end
end