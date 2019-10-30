function encode_datasets()

    dataset_idx = 1;
    num_features = 29;
    trainRatio = 0.9999;
    balance = 0;

    [P_train,T_train, P_test, T_test] = build_dataset(dataset_idx, ...
                    num_features, trainRatio, balance);

    P = P_train;
    
    hiddenSize = 2;
    autoenc = trainAutoencoder(P,hiddenSize,...
        'EncoderTransferFunction','satlin',...
        'DecoderTransferFunction','purelin',...
        'L2WeightRegularization',0.01,...
        'SparsityRegularization',4,...
        'SparsityProportion',0.10);
    
    path_name = 'encoded_data/d1_encoded2.mat'; 
    save(path_name, 'autoenc');
    
    features = encode(autoenc,P);
    
    path_name = 'encoded_data/d1_features2.mat'; 
    save(path_name, 'features');

end 