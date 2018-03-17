% Prepare integral data for CCF analysis

clear all
clc
close all

maxRTcutoff = 3 ; % * sd above the mean

cnt = 1;
cData = [];
subjectTitles = [3 4 1 2];

% Subject numbers
subjects = [01, 02, 03, 04]; % Actual subject numbers

% Column names
cols = {'sub', 'con', 'ses', 'tri', 'itm', 'sat', 'bri', 'rsp', 'cat', 'cor', 'rt'};

for si = 1:4; % Subject index (1-4)
    subject = subjects(si); % Get the subject specified in si
    dat = dlmread(fullfile(pwd, 'Data', sprintf('rawData_integral%02d.dat', subject)));
    
    % Recode stimuli based on saturation and brightness values
    stim = ones(size(dat, 1), 1);
    for i = 1:size(stim, 1)
        if dat(i, strcmp('sat', cols)) == 4 && dat(i, strcmp('bri', cols)) == 7; stim(i) = 1; end
        if dat(i, strcmp('sat', cols)) == 7 && dat(i, strcmp('bri', cols)) == 7; stim(i) = 2; end
        if dat(i, strcmp('sat', cols)) == 10 && dat(i, strcmp('bri', cols)) == 7; stim(i) = 3; end
        if dat(i, strcmp('sat', cols)) == 4 && dat(i, strcmp('bri', cols)) == 5.5; stim(i) = 4; end
        if dat(i, strcmp('sat', cols)) == 7 && dat(i, strcmp('bri', cols)) == 5.5; stim(i) = 5; end
        if dat(i, strcmp('sat', cols)) == 10 && dat(i, strcmp('bri', cols)) == 5.5; stim(i) = 6; end
        if dat(i, strcmp('sat', cols)) == 4 && dat(i, strcmp('bri', cols)) == 4; stim(i) = 7; end
        if dat(i, strcmp('sat', cols)) == 7 && dat(i, strcmp('bri', cols)) == 4; stim(i) = 8; end
        if dat(i, strcmp('sat', cols)) == 10 && dat(i, strcmp('bri', cols)) == 4; stim(i) = 9; end
    end
    
    % Insert stimulus codes into data file
    dat = [dat(:,1:5), stim, dat(:,6:11)];
    
    % Keep trials with RTs greater than .15
    dats = [dat(:,5:6), dat(:,11:12)];
    sess = dat(:,3);
    if ismember(si, [1 3])
        sess = sess(dats(:,4) > .15);
        dats = dats(dats(:,4) > .15, :);
    elseif ismember(si, [2 4])
        sess = sess(dats(:,4) > .15);
        dats = dats(dats(:,4) > .15, :);
    end
    nRemoved = size(dat, 1) - size(dats,1);
    
    % Remove RTs greater than 3 * std + mean for each item
    seqs = .15:.05:3;
    summ = zeros(9, 38);
    
    data = dats; cidx = []; nErrors = 0; cData = [];
    for stim = 1:9
        tmp = dats(dats(:,1) == stim & dats(:,3) == 1, 4);
        tmp1 = dats(dats(:,1) == stim & dats(:,3) == 0, 4);
        nErrors = nErrors + size(tmp1, 1);
        
        itemData = [dats(dats(:,1) == stim & dats(:,3) == 1, :), sess(dats(:,1) == stim & dats(:,3) == 1, :)];
        itemData1 = [dats(dats(:,1) == stim & dats(:,3) == 0, :), sess(dats(:,1) == stim & dats(:,3) == 0, :)];
        if ismember(si, [1 3])
            mn = mean(tmp); sd = std(tmp); tmp0 = tmp; tmp = tmp(tmp <= mn + maxRTcutoff * sd);
            mn1 = mean(tmp1);  sd1 = std(tmp1); tmp01 = tmp1; tmp1 = tmp1(tmp1 <= mn1 + maxRTcutoff *  sd1);
            
            itemData = itemData(tmp0 <= mn + maxRTcutoff *  sd, :);
            itemData1 = itemData1(tmp01 <= mn1 + maxRTcutoff *  sd1, :);
        elseif ismember(si, [2 4])
            mn = mean(tmp); sd1 = std(tmp); sd0 = sd1; tmp0 = tmp; tmp = tmp(tmp < mn + maxRTcutoff * sd1);
            mn1 = mean(tmp1); if length(sd1) > 1; sd1 = std(tmp1); else sd1 = 0;  tmp01 = tmp1; tmp1 = tmp1(tmp1 < mn1 + maxRTcutoff *  sd1); end
            
            itemData = itemData(tmp0 < mn + maxRTcutoff * sd0, :);
            if length(sd1) > 1; else itemData1 = itemData1(tmp01 < mn1 + maxRTcutoff *  sd1, :); end
        end
        nRemoved = nRemoved + size(tmp0, 1) - size(tmp, 1);
        cData = [cData; itemData];
    end
    
    % Recode items into indices
    if ismember(si, [1 3])
        b = [0 0 1 1 nan nan nan nan nan]; % H = 0; L = 1
        s = [0 1 0 1 nan nan nan nan nan]; % H = 0; L = 1
    elseif ismember(si, [2 4])
        b = [0 1 0 1 nan nan nan nan nan]; % H = 0; L = 1
        s = [0 0 1 1 nan nan nan nan nan]; % H = 0; L = 1
    end
    
    idx = [];
    for i = 1:size(cData, 1)
        idx(i, 1)  = b(cData(i, 1));
        idx(i, 2)  = s(cData(i, 1));
    end
    cData(:,6:7) = idx;
    
    cData(:,4) = cData(:,4) * 1000; % Convert to msec
    dlmwrite(sprintf('integral%02d.dat', si), cData)
end