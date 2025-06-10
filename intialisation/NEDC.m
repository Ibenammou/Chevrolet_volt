% init_driving_cycle1.m
% Script d'initialisation d'un cycle de conduite (ex : NEDC)
% Ce script charge les données du cycle, prépare les données pour
% affichage et initialise les paramètres de simulation.

% ==============

% Vérification et définition des variables globales et paramètres
% ----------------------------------------------------------------

global h         % Pas de temps de simulation (s)
global N_sim     % Nombre de pas de calcul pour la simulation

% Variables paramétrables utilisées dans le script
if ~exist('autostop', 'var')
    autostop = 1;  % Arrêt automatique à la fin du cycle (1 = oui, 0 = non)
end

if ~exist('stepsize', 'var')
    stepsize = 1;  % Pas de temps par défaut (1 seconde)
end

if ~exist('test', 'var')
    test = 0;      % Mode test désactivé par défaut
end

if ~exist('v_end', 'var')
    v_end = 0;     % Vitesse finale pour test, 0 si pas utilisé
end

if ~exist('v_init', 'var')
    v_init = 0;    % Vitesse initiale pour test, 0 si pas utilisé
end

if ~exist('acc_constant', 'var')
    acc_constant = 1; % Accélération constante par défaut (m/s²)
end

% ====================
% Chargement des données du cycle de conduite
% ====================
% Charger fichier de données NEDC.mat (doit contenir les variables T_z, V_z, D_z, G_z)
% Attention : adapte le nom du fichier ou chemin si besoin

data = load('NEDC.mat');  % Charge le fichier NEDC.mat

T_z = data.T_z; % Temps [s]
V_z = data.V_z; % Vitesse [km/h]
D_z = data.D_z; % Distance [m]
G_z = data.G_z; % Pente [%]

clear data       % Nettoyer variable temporaire

% ====================
% Préparation des données pour affichage (optionnel)
% ====================
% Prolonge la courbe du cycle pour tracer une ligne plate après la fin

T_zplot = T_z;
V_zplot = V_z;

% Ajouter 25% de points supplémentaires avec vitesse nulle après fin cycle
for nnn = length(T_zplot) : round(length(T_zplot)*1.25)
    T_zplot(nnn+1) = T_zplot(nnn) + 1;
    V_zplot(nnn+1) = 0;
end

% ====================
% Calcul du temps d'arrêt de la simulation
% ====================

if test == 1
    % Calcul de la durée d'arrêt en mode test selon vitesse et accélération
    stoptime = ceil((v_end - v_init) / 3.6 / acc_constant);
else
    % Sinon durée du cycle complet
    stoptime = T_z(end);
end

% Appliquer arrêt automatique dans Simulink si demandé
if autostop == 1
    % 'gcb' = nom du bloc courant dans Simulink
    % 'bdroot(gcb)' = nom du modèle Simulink racine
    set_param(char(bdroot(gcb)), 'StopTime', num2str(stoptime));
end

% ====================
% Initialisation des paramètres globaux
% ====================

h = stepsize;   % Pas de temps global
N_sim = stoptime; % Nombre total d'itérations (secondes)

% ====================
% Stockage des paramètres dans le bloc Simulink (optionnel)
% ====================

cl_par = struct('stepsize', stepsize, 'stoptime', stoptime);
set_param(gcb, 'UserData', cl_par);

% ====================
% Fin d'initialisation
% ====================
disp(['Cycle chargé : durée totale = ', num2str(stoptime), ' s, pas de temps = ', num2str(stepsize), ' s']);
