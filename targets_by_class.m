% The datasets consider 0 has non-ictal and 1 as ictal

% Convert ones to:
    % 3 - ictal
% Convert zeros to:
    % 1 - inter-ictal
    % 2 - pre-ictal
    % 4 - pos-ictal
function T_matrix = targets_by_class(T)

    ictal_idx = find(T == 1); % Get indices of non-zero values
   
    T(ictal_idx(1) - 600 : ictal_idx(1) - 1) = 2; 
    ictal_idx_length = length(ictal_idx);
    
    for i = 2 : ictal_idx_length
        before_idx = ictal_idx(i-1);
        cur_idx = ictal_idx(i);
        % different seizure in time (cur_idx is the beginning of the next
        % seizure and the before_idx the end of the previous seizure
        if cur_idx - before_idx > 1 
            T(cur_idx - 600 : cur_idx - 1) = 2; % pre-ictal
            T(before_idx + 1 : before_idx + 301) = 4; % pos-ictal
        end 
    end
    
    T(cur_idx + 1 : cur_idx + 301) = 4; % last seizure pos-ictal
    
    T(T == 1) = 3; % ictal from 1 to 3
    T(T == 0) = 1; % interictal from 0 to 1
    
    % Transform into a matrix of four columns (one represents each class)
    T_matrix = zeros(length(T), 4);
    for i = 1 : length(T)
        T_matrix(i, T(i)) = 1;
    end
    
    %save datasets/dataset_1/T_dataset1 T; % dataset #1
    %save datasets/dataset_2/T_dataset2 T; % dataset #1
end


    
