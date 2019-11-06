% clf_type: Single or Group 
% if the classification type (post-processing) is:
%    Single: A seizure is predict/detect if detects one preictal/ictal class
%    Group: A seizure is predict/detect if detects 5 consecutive 
%    preictal/ictal classes in 10 consecutive instances
function [prediction, detection]  = test_network(clf_type, trained_net, ...
    P_test, T_test)

    T_pred = sim(trained_net, P_test);

    
    for i = 1:length(T_pred)
        max = 1;
        for j = 2:4
            if(T_pred(j, i) >= T_pred(max, i))
                max = j;
            end
        end
        T_pred(:, i) = zeros(4, 1);
        T_pred(max, i) = 1; % The predicted target is the one that has the highest value
    end
    
    %%%% ---------- Post-Processing ----------
    if strcmp(clf_type,'Group')
        range = 10;
        consecutives_target = 5;
        % if preictal or ictal is found 5 times in 10 consecutive targets,
        % keeps it, otherwise classifies as class 1 (interictal)
        for i = 1 : (length(T_pred) - range)
            count_consecutives = 0;
            for k = 1 : range
                % Compare with the following 10 targets
                if(isequal(T_pred(:,i), T_pred(:,i + k)))
                    count_consecutives = count_consecutives + 1;
                end
            end
            if(count_consecutives < consecutives_target)
                T_pred(:,i) = [1;0;0;0];
            end
        end
    end
    
    prediction.TP = 0;
    prediction.TN = 0;
    prediction.FP = 0;
    prediction.FN = 0;
    prediction.sensitivity = 0;
    prediction.specificity = 0;
    prediction.accuracy = 0;
    
    detection.TP = 0;
    detection.TN = 0;
    detection.FP = 0;
    detection.FN = 0;
    detection.sensitivity = 0;
    detection.specificity = 0;
    detection.accuracy = 0;
    
    % Compare test targets with the predicted targets
    % Calculate TP, TN, FP and FN (values of confusion matrix)
    for i = 1:length(T_pred)
        % Prediction
        if(T_pred(2,i) == T_test(2,i))
            if(T_pred(2,i) == 1)
                prediction.TP = prediction.TP + 1;
            else
                prediction.TN = prediction.TN + 1;
            end
        else
            if(T_pred(2,i) == 1)
                prediction.FP = prediction.FP + 1;
            else
                prediction.FN = prediction.FN + 1;
            end
        end
        % Detection
        if(T_pred(3,i) == T_test(3,i))
            if(T_pred(3,i) == 1)
                detection.TP = detection.TP + 1;
            else
                detection.TN = detection.TN + 1;
            end
        else
            if(T_pred(3,i) == 1)
                detection.FP = detection.FP + 1;
            else
                detection.FN = detection.FN + 1;
            end
        end
    end
    
    prediction.sensitivity = prediction.TP / (prediction.TP + prediction.FN);
    prediction.specificity = prediction.TN / (prediction.TN + prediction.FP);
    prediction.accuracy = (prediction.TP + prediction.TN) / ...
        (prediction.TP + prediction.TN + prediction.FP + prediction.FN);
    
    detection.sensitivity = detection.TP / (detection.TP + detection.FN);
    detection.specificity = detection.TN / (detection.TN + detection.FP);
    detection.accuracy = (detection.TP + detection.TN) / ...
        (detection.TP + detection.TN + detection.FP + detection.FN);
    
    
    
end