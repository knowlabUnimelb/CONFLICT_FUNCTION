\Data\
- Contains data from Eidels, Townsend & Algom (2010) - Experiment 2 in xlsfiles

The items correspond to the design in the following manner:

    3_1 3_2   1_2 1_1
    3_3 3_4   1_4 1_3
             ---------
    4_3 4_4 | 2_4 2_3
    4_1 4_2 | 2_2 2_1

-----------------

ccf_Stroop.m 
- Compute SICs and CCFs and plot for all 5 subjects from ETA2009

computeSIC.m
- Function to compute SIC and bootstrapped confidence intervals

computeCCF.m
- Function to compute CCF and bootstrapped confidence intervals

mstrfind.m
- Function to find indexes for specified strings in a cell array of strings
