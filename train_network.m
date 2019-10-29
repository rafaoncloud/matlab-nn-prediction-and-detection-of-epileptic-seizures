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
function trained_net = train_network(P_train, T_train, type, ...
    num_neurons, goal, specialization)
   
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
        'useGPU', 'no', ...
        'showResources','yes');
    
elseif strcmp(type, 'Multilayer with Delays') % layrecnet
    
    net = layrecnet(1:2,num_neurons);
    
    net.divideFcn = 'divideind';
    [net.divideParam.trainInd,~,~] = divideind(length(P_train),1:length(P_train),[],[]);
    
    net.trainParam.epochs = 100;
    trained_net = train(net, P_train, T_train, [],[],weights_penalization, ...
        'useParallel','yes', ...
        'useGPU', 'no', ...
        'showResources','yes');

elseif strcmp(type, 'CNN')
    
    layers = [
        imageInputLayer([29 29 1])
        convolution2dLayer(5,20)
        reluLayer()
        maxPooling2dLayer(2,'Stride',2)
        fullyConnectedLayer(10)
        softmaxLayer
        classificationLayer
    ];

    options = trainingOptions('sgdm', ...
        'InitialLearnRate',0.01, ...
        'MaxEpochs',4, ...
        'Shuffle','every-epoch', ...
        'ValidationData',imdsValidation, ...
        'ValidationFrequency',30, ...
        'Verbose',false, ...
        'Plots','training-progress');

    trained_net = trainNetwork(P_train,layers, options);
    
    
elseif strcmp(type, 'LSTM')
    
    numFeatures = 29;
    numHiddenUnits = 100;
    numClasses = 4;
    layers = [
        sequenceInputLayer(numFeatures)
        lstmLayer(numHiddenUnits,'OutputMode','last')
        fullyConnectedLayer(numClasses)
        softmaxLayer
        classificationLayer
    ];

    options = trainingOptions('sgdm', ...
        'ExecutionEnvironment','auto', ...
        'GradientThreshold',1, ...
        'MaxEpochs',50, ...
        'MiniBatchSize',29, ...
        'SequenceLength','longest', ...
        'Shuffle','never', ...
        'Verbose',0, ...
        'Plots','training-progress');

    P_train = num2cell(P_train,1);
    
    class1_idx = find(T_train(1,:) == 1);
    class2_idx = find(T_train(2,:) == 1);
    class3_idx = find(T_train(3,:) == 1);
    class4_idx = find(T_train(4,:) == 1);
    T_train_vector = zeros(1, length(T_train)); 
    T_train_vector(class1_idx) = 1;
    T_train_vector(class2_idx) = 2;
    T_train_vector(class3_idx) = 3;
    T_train_vector(class4_idx) = 4;
    T_train_vector = categorical(T_train_vector)';
 
    trained_net = trainNetwork(P_train, T_train_vector, layers, options);
end

    
    