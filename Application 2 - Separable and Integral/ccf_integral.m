% Analyse SIC and CCF for Application 2 - Separable Dimension
% Categorization
clear all
clc
close all


% List of data file names
datafiles = {'integral01.dat',...
    'integral02.dat',...
    'integral03.dat',...
    'integral04.dat'};

% Data columnn names
% cols = {'sub', 'subid', 'ses', 'blk', 'tri', 'itm', 'top', 'shade', 'design', 'base', 'resp' 'cat', 'cor', 'rt'};
%    cols = {'sub', 'con', 'ses', 'tri', 'itm', 'sat', 'bri', 'rsp', 'cat', 'cor', 'rt'};
cols = {'itm', 'dummy', 'cor', 'rt', 'idx1', 'idx2'};

% Open window
figure('WindowStyle', 'docked')
for si = 1:numel(datafiles); % which subject to analyse?

    %% Get data
    data = dlmread(fullfile(pwd, 'Data', datafiles{si}));
    
    % SIC items
    % HH = data(data(:, strcmp('itm', cols)) == 1, strcmp('rt', cols));
    % HL = data(data(:, strcmp('itm', cols)) == 2, strcmp('rt', cols));
    % LH = data(data(:, strcmp('itm', cols)) == 3, strcmp('rt', cols));
    % LL = data(data(:, strcmp('itm', cols)) == 4, strcmp('rt', cols));
    
    %% Estimate CDF for all items
    % Note: data is in msec
    mint = min([min(data(:,strcmp('rt', cols))), 5]);
    maxt = max([max(data(:,strcmp('rt', cols)))]) + 300;
    t = mint:10:maxt; % #### set t, time vector in msec (MIN : bin size : MAX)
    
    items = unique(data(:,strcmp('itm', cols)));
    for i = 1:numel(items)
        d{i}      = data(data(:,strcmp('itm', cols)) == i, strcmp(cols, 'rt')); % Store data for that item
    end
    
    
    %% Target SICs
    % Target SIC item codes: LL = 4, LH = 2, HL = 3, HH = 1;
    HH = d{1}; HL = d{2}; LH = d{3}; LL = d{4};
    [sic, std_boot, tcdf, tsf] = computeSIC(LL, LH, HL, HH, mint, maxt);
    
    %% Compute CCF
    [ccf, ccfboot, ccf_cdfs, ccf_Ss] = computeCCF(d{5}, d{6}, d{7}, d{8}, mint, maxt);
    
    
    %% Plot CDFS
    sm = 2; % 2 * std boot
     
    subplot(4,3,(si - 1) * 3 + 1) % Create a subplot within figure
    hc = plot(t, tcdf); % plot the cdfs
    
    % % Change colors of lines and linestyles
    set(hc(1), 'Color', 'r', 'LineStyle', '-' , 'LineWidth', 2)
    set(hc(2), 'Color', 'r', 'LineStyle', '--', 'LineWidth', 2)
    set(hc(3), 'Color', 'b', 'LineStyle', '-' , 'LineWidth', 2)
    set(hc(4), 'Color', 'b', 'LineStyle', '--', 'LineWidth', 2)
    %
    legend(hc, 'LL', 'LH', 'HL', 'HH') % Legend
    xlabel('t', 'FontSize', 14)   % Label axes
    ylabel('CDF(t)', 'FontSize', 14)
    axis([250 1200 0 1]) % Sets axis size
    set(gca,'FontSize', 12) % Set overall font size
    
    %% Plot SICS
    subplot(4,3,(si - 1) * 3 + 2)
    hsic = plot(t, sic); hold on
    set(hsic, 'Color', 'r', 'LineStyle', '-' , 'LineWidth', 2)
    hsicCI = plot(t, sic + sm*std_boot', '--b', t, sic - sm*std_boot', '--b');
    set(hsicCI, 'LineWidth', 1)
    
    xlabel('t', 'FontSize', 14)
    ylabel('SIC(t)', 'FontSize', 14)
    axis tight
    l = line([mint maxt], [0 0]); set(l, 'Color', 'k')
    set(gca,'FontSize', 12, 'XLim', [250 1200], 'YLim', [-.15 .25])
    %         title('SIC', 'FontSize', 14)
    
    %% Plot CCF
    subplot(4,3,(si - 1) * 3 + 3)
    plot(t, zeros(1, length(t)), '-k');
    hold on
    hc = plot(t, ccf);
    set(hc(1), 'Color', 'r', 'LineStyle', '-' , 'LineWidth', 2)
    xlabel('t', 'FontSize', 14)
    ylabel('CCF(t)', 'FontSize', 14)
    plot(t, ccf+ccfboot*sm, 'b', t,  ccf-ccfboot*sm, 'b');    % plot Bootstrap Confidence Interval (1 std)
    set(gca,'FontSize', 12, 'XLim', [mint 1200], 'YLim', [-1 4])
end