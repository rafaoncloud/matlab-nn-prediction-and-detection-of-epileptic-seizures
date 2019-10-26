function [P_train,T_train, P_test, T_test] = build_dataset( ...
    dataset_idx, ...
    num_features, ...
    training_data_perc, ...
    balance) 

    if dataset_idx < 1 || dataset_idx > 2
        error('Dataset index out of range [1;2]!');
    elseif balance ~= 1 && balance ~= 10
        error('Balance is not 1 or 10!')
    elseif training_data_perc < 0 || training_data_perc > 1
        error('The training data percentage must range between 0 and 1!')
    end 
    
    % Load raw dataset
    if dataset_idx == 1
        load('datasets/dataset_1/112502.mat');
    elseif dataset_idx == 2
        load('datasets/dataset_2/44202.mat');
    end
    
    % 0 (non-ictal) and 1 (ictal) dataset to 4 classes (interictal, preictal 
    % ictal and posictal)
    T = targets_by_class(Trg);
    
    % Reduce the number of features (by correlation value)
    P = reduce_dataset(FeatVectSel, Trg, num_features);
    
    % Vector that indicated the begining and end of each seizure (1 and -1)
    seizures = diff(Trg);
    % Indexes with the first pre-ictal (2) of each seizure
    start_preictal = find(seizures == 1) - 600;
    % Indexes with the last pos-ictal (4) of each seizure
    end_posictal = find(seizures == -1) + 301;
    
    total_seizures = length(start_preictal);
    
    % Number of seizures present in the training data
    num_seizures_training_data = round(total_seizures * training_data_perc);
    
    % Vector with preictal (2), ictal (3) and postictal (4) for the
    % training set
    seizures_idxs = [];
    for i = 1 : num_seizures_training_data
        seizures_idxs = [seizures_idxs start_preictal(i):1:end_posictal(i)];
    end
    
    % Balance dataset
    % Balance = 1: The number of inter_ictal (1) class instances is equal
    % to the sum of all other classes;
    % Balance = 10: The number of inter_ictal (1) class instances is equal
    % to ten times the sum of all other classes;
    total_interictal = length(seizures_idxs) * balance;
    
    % If the number of total interictal is larger than the existing
    % interictal instances, use only the available ones
    if(total_interictal > (length(P) - length(seizures_idxs)))
        total_interictal = length(P) - length(seizures_idxs);
    end
    
    % Choose inter_ictal indexes in a equal number to the total ones
    interictal_idxs = find(T == 1)';
    interictal_idxs = interictal_idxs(1:total_interictal);
    
    % Join interinctal (1) class and the remaining classes (2,3,4 -
    % seizure)
    training_idxs = horzcat(interictal_idxs,seizures_idxs);
    training_idxs = sort(training_idxs);
    
    % Define the training set
    P_train = P(training_idxs,:)';
    T_train = T(training_idxs,:)';
    
    
    
    % Remaining seizures to the test set
    %P_all_idxs = 1:length(P);
    %test_idxs = setdiff(P_all_idxs, training_idxs);
    
    seizures_idxs = [];
    for i = num_seizures_training_data + 1 : total_seizures
        seizures_idxs = [seizures_idxs start_preictal(i):1:end_posictal(i)];
    end
    
    total_interictal = length(seizures_idxs) * balance;
    
    % If the number of total interictal is larger than the existing
    % interictal instances, use only the available ones
    if(total_interictal > (length(P) - length(seizures_idxs)))
        total_interictal = length(P) - length(seizures_idxs);
    end
    
    % Join interinctal (1) class and the remaining classes (2,3,4 -
    % seizure)
    test_idxs = horzcat(interictal_idxs,seizures_idxs);
    test_idxs = sort(test_idxs);

    
    % Define the test set
    P_test = P(test_idxs,:)';
    T_test = T(test_idxs,:)';
    
end