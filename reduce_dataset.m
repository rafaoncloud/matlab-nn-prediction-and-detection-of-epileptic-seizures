function P = reduce_dataset(P, T, num_features)

    % Get total number of features
    [~ , total_num_features] = size(P);

    if num_features > total_num_features || num_features < 1
        error('Number of features out of range!');
    end
        
    % Join inputs (P) and outputs (T) in a single matrix
    data = horzcat(P, T);
    data_num_col = size(data);
    data_num_col = data_num_col(2);
    
    % Compute correlation matrix
    corr_matrix = corrcoef(data);
    
    % Extract values from the last column (target
    corr_vector = corr_matrix(data_num_col, 1:total_num_features);
    
    % Absolute value of negativa and positive correlations
    corr_vector = abs(corr_vector);
    
    % From higher to lower correlation value
    [~, vector_idx] = sort(corr_vector, 'descend');
    
    % Return a new dataset with the indicated number of feature
    % based on the original dataset
    P = data(:, vector_idx(1:num_features));

end