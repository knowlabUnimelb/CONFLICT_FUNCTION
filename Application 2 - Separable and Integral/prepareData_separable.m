% Set up separable data for CCF paper
clear all
clc
close all

datafiles = {'rawData_separable01.dat',...
             'rawData_separable02.dat',...
             'rawData_separable03.dat',...
             'rawData_separable04.dat'};
sessions = {2:5, 2:5, 2:5, 2:5};        % There were 5 sessions, discard the first

% column names
cols = {'sub', 'con', 'ses', 'blk', 'tri', 'itm', 'top', 'shade', 'design', 'base', 'resp' 'cat', 'cor', 'rt'};

for si = 1:4; % which subject to analyse?
    session = sessions{si}; % Extract session numbers
    
    %% Remove outliers
    % Throw out anything greater than this prctile (if 100 then don't throw out anything)
    % This is useful for getting rid of extremely long RTs 
    cutoffPercentiles = repmat([99.9], 1, numel(datafiles)); 
    
    % Read data
    datalocation = fullfile(pwd, 'Data');
    alldata = dlmread(fullfile(datalocation, datafiles{si}));
    data = alldata(ismember(alldata(:,strcmp(cols, 'ses')), session), :);
    
    % Remove practice trial (first 27 trials) and session 1
    data(data(:,strcmp(cols, 'ses')) == 2 & data(:,strcmp(cols, 'blk')) == 1 &...
        data(:,strcmp(cols, 'tri')) <= 27, :) = [];
    data(:,strcmp(cols, 'rt')) = data(:,strcmp(cols, 'rt')) * 1000;
        
    %% Remove overall long RTs
    data(data(:,end) > prctile(data(:,strcmp(cols, 'rt')), cutoffPercentiles(si)), :) = [];
    
    %% Remove timeouts
    idx9 = find(data(:,strcmp('rsp', cols)) == 9); % Remove timeouts
    data(idx9,:) = [];
    data(isnan(data(:,strcmp('rt', cols))), :) = [];
    
    %% Remove outliers from each item 
    rawdata = data;          % Sort the data by session and by trial
    
    % Get means and standard deviations for each item
    means = aggregate(data, strcmp('itm', cols), strcmp('rt', cols));        % Compute the means for each item
    stds  = aggregate(data, strcmp('itm', cols), strcmp('rt', cols), @std);  % Compute the stds for each item
        
    trialnumber =  (1:size(data,1))'; fintrialnumber =[];
    trialdata = [];
    
    minrt = 150; % Minimum RT 150ms
    for item = 1:9
        itemdata = data(data(:,strcmp('itm', cols)) == item,:);
        
        % Remove errors
        errors{item} = find(itemdata(:,strcmp('cor', cols)) == 0);
        itemdata(errors{item},:) = [];
        
        % Remove outlying RTs < minrt (for errors and correct) or > 3 stds + mean (for correct only)
        outliers{item} = find(any([itemdata(:,strcmp('rt', cols)) < minrt, itemdata(:,strcmp('cor', cols)) == 0 & itemdata(:,strcmp('rt', cols)) > means(item,2) + stds(item,2) * 3], 2));
        itemdata(outliers{item}, :) = [];

        trialdata = [trialdata; itemdata];
    end
    cleandata = sortrows(trialdata, [find(strcmp('ses', cols)), find(strcmp('blk', cols)), find(strcmp('tri', cols))]);
    
    %% Get data
    dlmwrite(sprintf('separable%02d.dat', si), cleandata)
end