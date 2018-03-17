\Data\
- Contains raw data and prepared data from Little, Nosofsky & Denton (2011; 
    Experiment 1; LND2011) and Little, Nosofsky, Donkin & Denton (2013; 
    Experiment 1; LNDD2013)

rawData_ is the raw data from the above papers

- Data have been preprocessed in the following way:
-- RT longer than the 99.9 percentile were discarded upfront
-- Session 1 and the practice trials from session 2 were discarded
-- RTs < 150 ms or > 3 * std + mean were removed separately for each item

The items correspond to the design in the following manner:

     7  | 3    1
        |
     8  | 4    2
        |--------
     9    6    5

The preprocessing steps are slightly different for LNDD2013 because we 
rotated the boundaries for each subject

The main analyses will be conducted on the prepared data in:

    separable01.dat-separable04.dat - data from LND2011
    integral01.dat-integral04.dat - data from LNDD2013

-----------------

ccf_separable.m 
- Compute SICs and CCFs and plot for all 4 subjects from LND2011


ccf_integral.m 
- Compute SICs and CCFs and plot for all 4 subjects from LNDD2013

computeSIC.m
- Function to compute SIC and bootstrapped confidence intervals

computeCCF.m
- Function to compute CCF and bootstrapped confidence intervals

aggregate.m
- Function to compute means with specific cells of a matrix given the values 
  other indicator cells. (Compare to SPSS function or [R] function aggregate)
