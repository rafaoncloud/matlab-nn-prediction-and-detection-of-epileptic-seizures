% Example: d1_Multilayer_Detection_High_70_ClassBalanced_20_29
function save_trained_net(P_test,T_test,trained_net, ...
    dataset_idx,type, goal, specialization, ...
    training_data_perc, balance, num_neurons, num_features)
        
    path = 'trained_nets/';

    dataset_idx = int2str(dataset_idx);

    if strcmp(type, 'Multilayer')
        type = 'Multilayer';
    elseif strcmp(type, 'Multilayer with delays')
        type = 'MultilayerDelays';
    elseif strcmp(type, 'CNN')
        type = 'CNN';
    elseif strcmp(type, 'LSMT')
        type = 'LSMT';
    end
    
    if training_data_perc == 0.7
        training_data = '70';
    elseif training_data_perc == 0.8
        training_data = '80';
    end
    
    if balance == 1
        balance = 'ClassBalanced';
    else
        balance = 'NoClassBalanced';
    end 
    
    num_neurons = int2str(num_neurons);
    
    num_features = int2str(num_features);
    
    file_name = strcat('d', dataset_idx,'_',type,'_',goal,'_', ...
        specialization,'_', training_data, '_', balance,'_', ...
        num_neurons, '_', num_features,'.mat');
    
    path_name = strcat(path,file_name);
    
    save(path_name, 'trained_net','P_test','T_test');
    
end
     

