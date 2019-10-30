function plot_cluster(k, num_features)
    
    if num_features < 2 || num_features > 3
        error('Number of features should be 2 or 3');
    end
    
    if num_features == 2
        load('encoded_data/d1_features2.mat','features');
    elseif num_features == 3 
        load('encoded_data/d1_features3.mat','features');
    end
    
    dataset_idx = 1;
    num_features_raw = 29;
    trainRatio = 0.9999;
    balance = 0;
    [~,T_train, ~, ~] = build_dataset(dataset_idx, ...
                    num_features_raw, trainRatio, balance);

    T = T_train;
    T_class1_idx = find(T(1,:) == 1);
    T_class2_idx = find(T(2,:) == 1);
    T_class3_idx = find(T(3,:) == 1);
    T_class4_idx = find(T(4,:) == 1);
  
    [idx, C] = kmeans(features',k);
    
    len = length(idx);
    idx = idx';
    
    if num_features == 3
        scatter3(features(1,T_class1_idx), features(2,T_class1_idx), features(3,T_class1_idx),'c');
        hold on;
        scatter3(features(1,T_class2_idx), features(2,T_class2_idx), features(3,T_class2_idx),'b');
        scatter3(features(1,T_class3_idx), features(2,T_class3_idx), features(3,T_class3_idx),'g');
        scatter3(features(1,T_class4_idx), features(2,T_class4_idx), features(3,T_class4_idx),'k');
        plot3(C(:,1),C(:,2),C(:,3),'kx', 'MarkerSize',15,'LineWidth',3)
        legend('Interictal','Preictal','Ictal','Posictal','Centroids','Location','SouthEast'); 
    elseif num_features == 2
        scatter(features(1,T_class1_idx), features(2,T_class1_idx),'c');
        hold on;
        scatter(features(1,T_class2_idx), features(2,T_class2_idx),'b');
        scatter(features(1,T_class3_idx), features(2,T_class3_idx),'g');
        scatter(features(1,T_class4_idx), features(2,T_class4_idx),'k');
        plot(C(:,1),C(:,2),'kx', 'MarkerSize',15,'LineWidth',3)
        legend('Interictal','Preictal','Ictal','Posictal','Centroids','Location','SouthEast'); 
    end
        
end

