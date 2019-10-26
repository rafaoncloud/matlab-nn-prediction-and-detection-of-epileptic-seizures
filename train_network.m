%% Inputs description
% P_train, P_test: input matrix
% T_train, T_test: target matrix (4 columns) 
%   Class 1: Interictal
%   Class 2: Preictal
%   Class 3: Ictal
%   Class 4: Posictal
% type: type of neural network
%   Multilayer -> feedforwardnet
%   Multilayer with delays -> layrecnet
%   CNN
%   LSTM
% num_neurons: number of neurons
% goal: prediction (preictal) or detection (ictal) of a seizure
%   Prediction
%   Detection
% specialization: use of different weights (penalizations) of the error of
% the NN in the different instants; Specialization in Prediction or
% Detection
%   None
%   Medium
%   High
% 
function trained_net = train_network(P_train, T_train, P_test,T_test, ...
    type,num_neurons, goal, specialization)
   
%% Specialization (Ajust weight penalizations of the errors)
    weights_penalization = ones(1, length(P_train));
    
    interictal_idxs = find(T_train(1,:) == 1);
    interictal_total = length(interictal_idxs);
    preictal_idxs = find(T_train(2,:) == 1);
    preictal_total = length(preictal_idxs);
    ictal_idxs = find(T_train(3,:) == 1);
    ictal_total = length(ictal_idxs);

    % Network for prediction
    if strcmp(goal, 'Prediction') % Preictal (Class 2)
        if strcmp(specialization,'None')
            error = 1;
        elseif strcmp(specialization,'Medium')
            error = (interictal_total/preictal_total);
        elseif strcmp(specialization,'High')
            error = (interictal_total/preictal_total) * 1.5;
        end
        weights_penalization(preictal_idxs) = error;
    % Network for detection    
    elseif strcmp(goal, 'Detection') % Ictal (Class 3) 
        if strcmp(specialization,'None')
            error = 1;
        elseif strcmp(specialization,'Medium')
            error = (interictal_total/ictal_total);
        elseif strcmp(specialization,'High')
            error = (interictal_total/ictal_total) * 1.5;
        end
        weights_penalization(ictal_idxs) = error;
    end
    
%% Create and Train Network 
if strcmp(type, 'Multilayer') % feedforwardnet
    
    net = feedforwardnet(num_neurons);
    
    net.divideFcn = 'divideind';
    [net.divideParam.trainInd,~,~] = divideind(length(P_train),1:length(P_train),[],[]);
    
    net.trainFcn = 'trainscg';
    net.trainParam.epochs = 1000;
    trained_net = train(net, P_train, T_train, [],[],weights_penalization, ...
        'useParallel','yes', ...
        'useGPU', 'yes', ...
        'showResources','yes');
    
elseif strcmp(type, 'Multilayer with delays') % layrecnet

elseif strcmp(type, 'CNN')
    
elseif strcmp(type, 'LSTM')

end

    
    