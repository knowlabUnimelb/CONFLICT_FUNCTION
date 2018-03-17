% Analyse Exp 2 from Eidels, Townsend & Algom (2009)
clear all
clc
close all

subjects = {'ADI', 'ANA', 'DIT', 'EIN', 'SHIR'};

cols = {'Trial Name', 'Trial #', 'Event #', 'Response', 'Error Code', 'Reaction Time', 'dummy'}; % Column names

itemCons = {'green_in_red', 'greeningreen', 'red__in__red', 'red_in_green'}; % Unique item conditions
redundantCondition = 3; % red__in__red is the redundant target condition for Exp2

sftCons = {'HH', 'HH', 'HH', 'HH', 'HL', 'HL', 'HL', 'HL', 'LH', 'LH', 'LH', 'LH', 'LL', 'LL', 'LL', 'LL'}; % sft conditions

cidx = 1;
for sidx = 1:numel(subjects);
    filename = fullfile(pwd, 'Data', sprintf('Exp3_%s_data.xls', subjects{sidx}));
    [~,~,data] = xlsread(filename, 'data', 'A6:G5799'); % Read in data
    data(1,:) = []; % Delete column labels
    data(~cellfun(@isstr, data(:,1)), :) = [];
    
    % Read the excel data into a more usable format
    for i = 1:size(data,1)
        itemCon(i,1) = {data{i,strcmp(cols, 'Trial Name')}(regexp(data{i,strcmp(cols, 'Trial Name')}, '\D'))};
        itemCode(i,1) = mstrfind(itemCons, itemCon(i,1));
        
        sftCon(i,1)  = str2num(data{i,strcmp(cols, 'Trial Name')}(regexp(data{i,strcmp(cols, 'Trial Name')}, '\d')));
        sftCode(i,1) = {sftCons{sftCon(i,1)}};
        
        resp(i,1) = strcmp(data{i,strcmp(cols, 'Response')}, 'A');
        corr(i,1) = strcmp(data{i,strcmp(cols, 'Error Code')}, 'C');
        rt(i,1) = data{i,strcmp(cols, 'Reaction Time')};
    end
    
    % Assign SFT number codes
    sftNumCode = nan(size(itemCode, 1), 1);
    sftNumCode(mstrfind(sftCode, {'HH'})) = 1;
    sftNumCode(mstrfind(sftCode, {'HL'})) = 2;
    sftNumCode(mstrfind(sftCode, {'LH'})) = 3;
    sftNumCode(mstrfind(sftCode, {'LL'})) = 4;
    
    % Organize data
    output = [itemCode, sftCon, sftNumCode, resp, corr, rt];
    
    %% Find target present (SIC) condition - Exp2: GREEN in Green
    sicCon = unique(output(output(:,4) == 0, 1));
    sicData = output(output(:,1) == sicCon, :);
    
    HH = sicData(sicData(:,3) == 1, 6);
    HL = sicData(sicData(:,3) == 2, 6);
    LH = sicData(sicData(:,3) == 3, 6);
    LL = sicData(sicData(:,3) == 4, 6);
    
    mint = 10;
    maxt = 1600;
    dt = 10;
    t = mint:dt:maxt;
    [sic, std_boot, tcdf, tsf] = computeSIC(LL, LH, HL, HH, mint, maxt, [], dt);
    
    %% Find target absent (SIC) condition
    rsicCon = unique(output(output(:,4) == 1, 1));
    rsicData = output(output(:,1) == redundantCondition, :);
    
    rHH = rsicData(rsicData(:,3) == 1, 6);
    rHL = rsicData(rsicData(:,3) == 2, 6);
    rLH = rsicData(rsicData(:,3) == 3, 6);
    rLL = rsicData(rsicData(:,3) == 4, 6);
    
    [rsic, rstd_boot, rtcdf, rtsf] = computeSIC(rLL, rLH, rHL, rHH, mint, maxt, [], dt);
    
    %% Find conflict items
    % 3_1 3_2   1_2 1_1
    % 3_3 3_4   1_4 1_3
    %          ---------
    % 4_3 4_4 | 2_4 2_3
    % 4_1 4_2 | 2_2 2_1
    
    
    % R  = output(output(:,1) == 3 & output(:,3) == 4, 6);
    lowAH = output(output(:,1) == 4 & output(:,3) == 2, 6);
    lowAL = output(output(:,1) == 4 & output(:,3) == 4, 6);
    lowBH = output(output(:,1) == 1 & output(:,3) == 3, 6);
    lowBL = output(output(:,1) == 1 & output(:,3) == 4, 6);
    
    highAH = output(output(:,1) == 4 & output(:,3) == 1, 6);
    highAL = output(output(:,1) == 4 & output(:,3) == 3, 6);
    highBH = output(output(:,1) == 1 & output(:,3) == 1, 6);
    highBL = output(output(:,1) == 1 & output(:,3) == 2, 6);
    
    [ccf, ccf_boot, ccf_cdfs, ccf_Ss] = computeCCF(lowAH, lowAL, lowBH, lowBL, mint, maxt, [], dt);
    [high_ccf, high_ccf_boot, high_ccf_cdfs, high_ccf_Ss] = computeCCF(highAH, highAL, highBH, highBL, mint, maxt, [], dt);
    
%     %% Plot SICS
%     subplot(5,3,cidx); cidx = cidx + 1;
%     hsic = plot(t, sic); hold on
%     set(hsic, 'Color', 'r', 'LineStyle', '-' , 'LineWidth', 2)
%     hsicCI = plot(t, sic + std_boot', '--b', t, sic - std_boot', '--b');
%     set(hsicCI, 'LineWidth', 1)
%     
%     xlabel('t', 'FontSize', 14)
%     ylabel('SIC(t)', 'FontSize', 14)
%     axis tight
%     l = line([mint maxt], [0 0]); set(l, 'Color', 'k')
%     set(gca,'FontSize', 14)
%     title('Target Absent (AND)', 'FontSize', 14)
    
    %% Plot SIC for redundant target condition
    subplot(5,3,cidx); cidx = cidx + 1;
    hsic = plot(t, rsic); hold on
    set(hsic, 'Color', 'r', 'LineStyle', '-' , 'LineWidth', 2)
    hsicCI = plot(t, rsic + rstd_boot', '--b', t, rsic - rstd_boot', '--b');
    set(hsicCI, 'LineWidth', 1)
    
    xlabel('t', 'FontSize', 14)
    ylabel('SIC(t)', 'FontSize', 14)
    axis tight
    l = line([mint maxt], [0 0]); set(l, 'Color', 'k')
    set(gca,'FontSize', 14)
    title('Target Present (OR)', 'FontSize', 14)
    
    %% Plot CCF for low salience targets
    sm = 2; % 2 * std boot
    
    subplot(5,3,cidx); cidx = cidx + 1;
    plot(t, zeros(1, length(t)), '-k');
    hold on
    hc = plot(t, ccf);
    set(hc(1), 'Color', 'r', 'LineStyle', '-' , 'LineWidth', 2)
    xlabel('t', 'FontSize', 14)
    ylabel('CCF_{L}(t)', 'FontSize', 14)
    set(gca,'FontSize', 14, 'XLim', [mint maxt])
    plot(t, ccf+ccf_boot*sm, 'b', t,  ccf-ccf_boot*sm, 'b');    % plot Bootstrap Confidence Interval (1 std)
    set(gca, 'XLim', [300 1200], 'YLim', [-5 1])
    
    %% Plot CCF for high salience targets
    subplot(5,3,cidx); cidx = cidx + 1;
    plot(t, zeros(1, length(t)), '-k');
    hold on
    hc = plot(t, high_ccf);
    set(hc(1), 'Color', 'r', 'LineStyle', '-' , 'LineWidth', 2)
    xlabel('t', 'FontSize', 14)
    ylabel('CCF_{H}(t)', 'FontSize', 14)
    set(gca,'FontSize', 14, 'XLim', [mint maxt])
    plot(t, high_ccf+high_ccf_boot*sm, 'b', t,  high_ccf-high_ccf_boot*sm, 'b');    % plot Bootstrap Confidence Interval (1 std)
    set(gca, 'XLim', [300 1200], 'YLim', [-5 1])
end