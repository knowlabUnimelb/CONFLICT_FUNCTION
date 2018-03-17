function [ccf, ccf_boot, cdf, S] = computeCCF(AH, AL, BH, BL, varargin)
% Compute Conflict Contrast Function

% Optional arguments
optargs = {5, 2000, 1000};
newVals = cellfun(@(x) ~isempty(x), varargin); % skip any new inputs if they are empty
optargs(newVals) = varargin(newVals); % now put these defaults into the valuesToUse cell array, and overwrite the ones specified in varargin.
[mint, maxt, nbootstrap] = optargs{:}; % Place optional args in memorable variable names

%% Compute cdf
t = mint:10:maxt; % #### set t, time vector in msec (MIN : bin size : MAX)

data = {AH, AL, BH, BL};
for i = 1:numel(data)
    cdf(:,i) = cumsum(hist(data{i}, t))/nnz(data{i})';
    S(:,i) = 1 - cdf(:,i);
end

ccf = (log(S(:,1)) - log(S(:,2))) + (log(S(:,3)) - log(S(:,4)));

if nbootstrap > 0
    [ccf_boot] = f_bootstrap_ccf(AH, AL, BH, BL, t, nbootstrap)';  % call the bootstrap function
else
    ccf_boot = 0;
end

function [std_boot] = f_bootstrap_ccf(AH, AL, BH, BL, t, nbootstrap)

% n iterations of resmapling (with replacement)
% ~~~~~~~~~~~~~~~~~~~~~~~~~~
for n = 1:nbootstrap;
    AH_boot = randsample(AH, length(AH), true);
    AL_boot = randsample(AL, length(AL), true);
    BH_boot = randsample(BH, length(BH), true);
    BL_boot = randsample(BL, length(BL), true); 
 
    SaH_boot = 1 - cumsum(hist (AH_boot, t) / nnz(AH_boot));
    SaL_boot = 1 - cumsum(hist (AL_boot, t) / nnz(AL_boot));
    SbH_boot = 1 - cumsum(hist (BH_boot, t) / nnz(BH_boot));
    SbL_boot = 1 - cumsum(hist (BL_boot, t) / nnz(BL_boot));
    
    ccf_boot(:, n) = (log(SaH_boot) - log(SaL_boot)) + (log(SbH_boot) - log(SbL_boot));
end

std_boot = (std(ccf_boot, 0, 2))';