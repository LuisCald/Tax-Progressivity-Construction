%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file constructs the marginal individual income tax rates series 
% for 1946-2012 in Figure II
%
% Karel Mertens and Jose Montiel-Olea, ``Marginal Tax Rates and Income, 
%                                    New Time Series Evidence''
% August, 2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all; close all; 

addpath('auxiliary files');


% Step 1  Load Input Data
data_DAGI            = xlsread('data/SOI_AGI_Distributions.xlsx','ALLYEARS');
data_MR              = xlsread('data/SOI_Marginal_Rates_by_AGI_and_FS.xlsx','ALLYEARS');

TSERIES              = xlsread('data/TIME_SERIES_DATA.xlsx','SERIES');
YEARS                = (1946:2012)';

% Step 2 Fit Distributions of Adjusted Gross Income to Available Data from
% the IRS Statistics of Income
FitDistributions
load D
% Step 3 Construct AGI Floors for Income Percentiles
quan      = [0 0.99 0.95 0.90];
TAXUNITS  = TSERIES(:,2)*1000;
AGIFLOORS = fun_AGIFLOORS(quan,D,YEARS,TAXUNITS);

% Step 4 Construct MIITRS using method 1
MIITRs_method1

% Step 5 Construct MIITRS using method 2
MIITRs_method2

%% Step 6 Construct the MIITR Series for the entire sample. 
load MIITRS_m1;
load MIITRS_m2;

AMTR_BR    = [YEARS TSERIES(:,7)];                           % Barro Redlick
%dAMTR_BR   = [zeros(1,size(AMTR_BR,2))*NaN;diff(AMTR_BR)];
AMTR_S     = [YEARS TSERIES(:,8:11)];                        % Saez (2004)
%dAMTR_S    = [zeros(1,size(AMTR_S,2))*NaN;diff(AMTR_S)];
%dMTRS1     = [zeros(1,size(MTRS1,2))*NaN;diff(MTRS1)]; % Method 1
%dMTRS2     = [zeros(1,size(MTRS2,2))*NaN;diff(MTRS2)]; % Method 2
%SHARES      = SHARES(sel,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extend Saez (2004) Series By Regressions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sel = (YEARS<1971)&(isnan(MIITRS_m1(:,2))==0)&(isnan(AMTR_S(:,2))==0);
Y   = AMTR_S(sel,2:end);
XX  = MIITRS_m1(:,2:end);
X  = XX(sel,:); 
b    = [ones(sum(sel),1) X]\Y;
Y1hat = [ones(length(XX),1) XX]*b; 
AMTR_S((YEARS<1971)&(isnan(MIITRS_m1(:,2))==0)&(isnan(AMTR_S(:,2))==1),2:end)= Y1hat((YEARS<1971)&(isnan(MIITRS_m1(:,2))==0)&(isnan(AMTR_S(:,2))==1),:);


sel = (YEARS>1986)&(isnan(MIITRS_m1(:,2))==0)&(isnan(AMTR_S(:,2))==0);
Y   = AMTR_S(sel,2:end);
XX  = MIITRS_m1(:,2:end);
X  = XX(sel,:); 
b    = [ones(sum(sel),1) X]\Y;
Y2hat = [ones(length(XX),1) XX]*b; 
AMTR_S((YEARS>1986)&(isnan(MIITRS_m1(:,2))==0)&(isnan(AMTR_S(:,2))==1),2:end)= Y2hat((YEARS>1986)&(isnan(MIITRS_m1(:,2))==0)&(isnan(AMTR_S(:,2))==1),:);

sel = (YEARS<1971)&(isnan(MIITRS_m2(:,2))==0)&(isnan(AMTR_S(:,2))==0);
Y   = AMTR_S(sel,2:end);
XX  = MIITRS_m2(:,2:end);
X  = XX(sel,:); 
b    = [ones(sum(sel),1) X]\Y;
Y3hat = [ones(length(XX),1) XX]*b; 
AMTR_S((YEARS<1971)&(isnan(MIITRS_m2(:,2))==0)&(isnan(AMTR_S(:,2))==1),2:end)= Y3hat((YEARS<1971)&(isnan(MIITRS_m2(:,2))==0)&(isnan(AMTR_S(:,2))==1),:);

AMIITR1 = AMTR_S;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extend Barro Redlick (2011) Series By Regressions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 sel = (YEARS>1986)&(isnan(MIITRS_m1(:,2))==0)&(isnan(AMTR_BR(:,2))==0);
Y   = AMTR_BR(sel,2:end);
XX  = MIITRS_m1(:,2:end);
X  = XX(sel,:); 
b    = [ones(sum(sel),1) X]\Y;
Y4hat = [ones(length(XX),1) XX]*b; 
AMTR_BR((YEARS>1986)&(isnan(MIITRS_m1(:,2))==0)&(isnan(AMTR_BR(:,2))==1),2:end)= Y4hat((YEARS>1986)&(isnan(MIITRS_m1(:,2))==0)&(isnan(AMTR_BR(:,2))==1),:);

 
AMIITR2 = AMTR_BR;

s1  = TSERIES(:,4)./TSERIES(:,3);
s5  = TSERIES(:,5)./TSERIES(:,3);
s10 = TSERIES(:,6)./TSERIES(:,3);

AMIITR_5to1  = (AMIITR1(:,4)-s1./s5.*AMIITR1(:,3)).*s5./(s5-s1);
AMIITR_10to5 = (AMIITR1(:,5)-s5./s10.*AMIITR1(:,4)).*s10./(s10-s5);
AMIITR_b99   = (AMIITR1(:,2)-s1./1.*AMIITR1(:,3)).*1./(1-s1);
AMIITR_b90   = (AMIITR1(:,2)-s10./1.*AMIITR1(:,5)).*1./(1-s10);


AMIITR=[AMIITR2 AMIITR1(:,2:end) AMIITR_5to1 AMIITR_10to5 AMIITR_b99 AMIITR_b90];
xlswrite('AMIITRs',AMIITR);

