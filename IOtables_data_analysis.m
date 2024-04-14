clc
clear all

year='2019';

data=readtable(['Data','\',year,'_SML.csv']);

IOtable_ii_WW=data(1:3465,2:3466); %IO table industries by industries

%% Declaration countries set, Sector set and usefull constant

countries ={'ARG','AUS','AUT','BEL','BGD','BGR','BLR','BRA','BRN','CAN','CHE','CHL','CHN','CIV','CMR','COL','CRI','CYP','CZE','DEU','DNK','EGY','ESP','EST','FIN','FRA','GBR','GRC','HKG','HRV','HUN','IDN','IND','IRL','ISL','ISR','ITA','JOR','JPN','KAZ','KHM','KOR','LAO','LTU','LUX','LVA','MAR','MEX','MLT','MMR','MYS','NGA','NLD','NOR','NZL','PAK','PER','PHL','POL','PRT','ROU','RUS','SAU','SEN','SGP','SVK','SVN','SWE','THA','TUN','TUR','TWN','UKR','USA','VNM','ZAF','ROW'};
countries=sort(countries);
n_countries=length(countries);


EA_countries={'AUT','BEL','HRV','CYP','EST','FIN','FRA','DEU','GRC','IRL','ITA','LVA','LTU','LUX','MLT','NLD','PRT','SVK','SVN','ESP'};
EA_countries=sort(EA_countries);
n_EA_countries=length(EA_countries);

USA_countries={'USA'};
n_USA_countries=length(USA_countries);

RoW_countries=setdiff(setdiff(countries,EA_countries),USA_countries);
RoW_countries=sort(RoW_countries);
n_RoW_countries=length(RoW_countries);

Countries_clusters={'EA','US','RoW'};

Wi_names=IOtable_ii_WW.Properties.VariableNames;
n_industries=45; %number of different industries

Energy_aggr={'_B05_06','_C19','_D'};
Tradable_aggr={'_A','_B07_08','_B09','_C10', '_C10T12', '_C11', '_C12', '_C13', '_C13T15', '_C14', '_C15', '_C16', '_C16T18', '_C17', '_C18', '_C20', '_C21', '_C22', '_C22_23', '_C23', '_C24', '_C24_25', '_C25', '_C26', '_C27', '_C28', '_C29', '_C29__C30', '_C30', '_C31', '_C31_32', '_C31T33', '_C32', '_C33','_G'};
NonTradable_aggr={'_E','_F','_H','_I','_J','_K','_L','_M','_N','_O','_P','_Q','_R','_S','_T','_U'};

sector_aggregation={Energy_aggr,Tradable_aggr,NonTradable_aggr};
sector_name={'Energy','Tradable', 'NonTradable'};

n_sector=length(sector_aggregation);

%% Initilization desired Output
task_names={
'Total energy in private consumption'
'Brown energy in private consumption'
'Green energy in private consumption' 
'Total energy in private investment'
'Brown energy in private investment'
'Green energy in private investment'
'Share of energy in total production'
'Share of brown energy in total production'
'Share of green energy in total production'
};

Data_out=table(zeros(length(task_names),1),zeros(length(task_names),1),zeros(length(task_names),1),'RowNames',task_names,'VariableNames',Countries_clusters); %3 is the number of cluster of countries countries

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% EA related columns
IOtable_ii_WEA=zeros(n_industries*n_countries,n_industries*n_EA_countries);
EAi_names=cell(1,n_industries*n_EA_countries);

for i=1:n_EA_countries
    idx=contains(Wi_names,EA_countries{i});
    IOtable_ii_WEA(:,(i-1)*n_industries+1:i*n_industries)=table2array(IOtable_ii_WW(:,logical(idx)));
    EAi_names((i-1)*n_industries+1:i*n_industries)=Wi_names(idx);
end


%IOtable of the input (on the row) of each industries of each countries of
%the world in all the industries of every EA contries
IOtable_ii_WEA=array2table(IOtable_ii_WEA,'VariableNames',EAi_names);



%% Aggregation in sector of the EA
IOtable_is_WEA=zeros(n_industries*n_countries,n_sector);
idx=zeros(1, n_industries*n_EA_countries);

for j=1:n_sector
    for k=1:length(sector_aggregation{j})
        idx=idx+contains(EAi_names,sector_aggregation{j}{k}); 
    end
    IOtable_is_WEA(:,j)=table2array(sum(IOtable_ii_WEA(:, logical(idx)), 2));
    idx=zeros(1, n_industries*n_EA_countries);
end
EAs_names={'EA_Energy','EA_Tradable','EA_NonTradable'};

%IOtable of the input (on the columns) of each industries of each countries of
%the world in all the EU sector
IOtable_si_EAW=array2table(IOtable_is_WEA','VariableNames',Wi_names);
%IOtable of the input (on the row) of each industries of each countries of
%the world in all the EU sector
IOtable_is_WEA=array2table(IOtable_is_WEA,'VariableNames',EAs_names);


%% Aggregation in sector of the W
IOtable_ss_EAW=zeros(n_sector);
idx=zeros(1,n_countries*n_industries);
for j=1:n_sector
    for k=1:length(sector_aggregation{j})
        idx=idx+contains(Wi_names,sector_aggregation{j}{k}); 
    end
    IOtable_ss_EAW(:,j)=table2array(sum(IOtable_si_EAW(:,logical(idx)), 2));
    idx=zeros(1,n_countries*n_industries);
end

IOtable_ss_WEA=array2table(IOtable_ss_EAW','VariableNames',EAs_names);

IOtable_ss_WEA_norm=IOtable_ss_WEA./sum(IOtable_ss_WEA);

%% Energy into EA total production
Brown=0.717;
Green=1-Brown;

W_Energy_into_EA_Total_Prod=table2array(sum(IOtable_ss_WEA(1,:),2));
EA_Total_Prod=table2array(sum(IOtable_ss_WEA,'all'));

share_W_Energy_into_EA_Total_Prod=W_Energy_into_EA_Total_Prod/EA_Total_Prod;
share_B_W_Energy_into_EA_Total_prod=share_W_Energy_into_EA_Total_Prod*Brown;
share_G_W_Energy_into_EA_Total_prod=share_W_Energy_into_EA_Total_Prod*Green;

Data_out.(1)(7)=share_W_Energy_into_EA_Total_Prod;
Data_out.(1)(8)=share_B_W_Energy_into_EA_Total_prod;
Data_out.(1)(9)=share_G_W_Energy_into_EA_Total_prod;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% USA related columns
IOtable_ii_WUSA=zeros(n_industries*n_countries,n_industries*n_USA_countries);
USAi_names=cell(1,n_industries*n_USA_countries);

for i=1:n_USA_countries
    idx=contains(Wi_names,USA_countries{i});
    IOtable_ii_WUSA(:,(i-1)*n_industries+1:i*n_industries)=table2array(IOtable_ii_WW(:,logical(idx)));
    USAi_names((i-1)*n_industries+1:i*n_industries)=Wi_names(idx);
end


%IOtable of the input (on the row) of each industries of each countries of
%the world in all the industries of every USA contries
IOtable_ii_WUSA=array2table(IOtable_ii_WUSA,'VariableNames',USAi_names);



%% Aggregation in sector of the USA
IOtable_is_WUSA=zeros(n_industries*n_countries,n_sector);
idx=zeros(1, n_industries*n_USA_countries);

for j=1:n_sector
    for k=1:length(sector_aggregation{j})
        idx=idx+contains(USAi_names,sector_aggregation{j}{k}); 
    end
    IOtable_is_WUSA(:,j)=table2array(sum(IOtable_ii_WUSA(:, logical(idx)), 2));
    idx=zeros(1, n_industries*n_USA_countries);
end
USAs_names={'USA_Energy','USA_Tradable','USA_NonTradable'};

%IOtable of the input (on the columns) of each industries of each countries of
%the world in all the USA sector
IOtable_si_USAW=array2table(IOtable_is_WUSA','VariableNames',Wi_names);
%IOtable of the input (on the row) of each industries of each countries of
%the world in all the EU sector
IOtable_is_WUSA=array2table(IOtable_is_WUSA,'VariableNames',USAs_names);


%% Aggregation in sector of the W
IOtable_ss_USAW=zeros(n_sector);
idx=zeros(1,n_countries*n_industries);
for j=1:n_sector
    for k=1:length(sector_aggregation{j})
        idx=idx+contains(Wi_names,sector_aggregation{j}{k}); 
    end
    IOtable_ss_USAW(:,j)=table2array(sum(IOtable_si_USAW(:,logical(idx)), 2));
    idx=zeros(1,n_countries*n_industries);
end

IOtable_ss_WUSA=array2table(IOtable_ss_USAW','VariableNames',USAs_names);

IOtable_ss_WUSA_norm=IOtable_ss_WUSA./sum(IOtable_ss_WUSA);

%% Energy into USA total production
Brown=0.717;
Green=1-Brown;

W_Energy_into_USA_Total_Prod=table2array(sum(IOtable_ss_WUSA(1,:),2));
USA_Total_Prod=table2array(sum(IOtable_ss_WUSA,'all'));

share_W_Energy_into_USA_Total_Prod=W_Energy_into_USA_Total_Prod/USA_Total_Prod;
share_B_W_Energy_into_USA_Total_prod=share_W_Energy_into_USA_Total_Prod*Brown;
share_G_W_Energy_into_USA_Total_prod=share_W_Energy_into_USA_Total_Prod*Green;

Data_out.(2)(7)=share_W_Energy_into_USA_Total_Prod;
Data_out.(2)(8)=share_B_W_Energy_into_USA_Total_prod;
Data_out.(2)(9)=share_G_W_Energy_into_USA_Total_prod;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% RoW related columns
IOtable_ii_WRoW=zeros(n_industries*n_countries,n_industries*n_RoW_countries);
RoWi_names=cell(1,n_industries*n_RoW_countries);

for i=1:n_RoW_countries
    idx=contains(Wi_names,RoW_countries{i});
    IOtable_ii_WRoW(:,(i-1)*n_industries+1:i*n_industries)=table2array(IOtable_ii_WW(:,logical(idx)));
    RoWi_names((i-1)*n_industries+1:i*n_industries)=Wi_names(idx);
end


%IOtable of the input (on the row) of each industries of each countries of
%the world in all the industries of every RoW contries
IOtable_ii_WRoW=array2table(IOtable_ii_WRoW,'VariableNames',RoWi_names);


%% Aggregation in sector of the RoW
IOtable_is_WRoW=zeros(n_industries*n_countries,n_sector);
idx=zeros(1, n_industries*n_RoW_countries);

for j=1:n_sector
    for k=1:length(sector_aggregation{j})
        idx=idx+contains(RoWi_names,sector_aggregation{j}{k}); 
    end
    IOtable_is_WRoW(:,j)=table2array(sum(IOtable_ii_WRoW(:, logical(idx)), 2));
    idx=zeros(1, n_industries*n_RoW_countries);
end
RoWs_names={'RoW_Energy','RoW_Tradable','RoW_NonTradable'};

%IOtable of the input (on the columns) of each industries of each countries of
%the world in all the RoW sector
IOtable_si_RoWW=array2table(IOtable_is_WRoW','VariableNames',Wi_names);
%IOtable of the input (on the row) of each industries of each countries of
%the world in all the EU sector
IOtable_is_WRoW=array2table(IOtable_is_WRoW,'VariableNames',RoWs_names);

%% Aggregation in sector of the W
IOtable_ss_RoWW=zeros(n_sector);
idx=zeros(1,n_countries*n_industries);
for j=1:n_sector
    for k=1:length(sector_aggregation{j})
        idx=idx+contains(Wi_names,sector_aggregation{j}{k}); 
    end
    IOtable_ss_RoWW(:,j)=table2array(sum(IOtable_si_RoWW(:,logical(idx)), 2));
    idx=zeros(1,n_countries*n_industries);
end

IOtable_ss_WRoW=array2table(IOtable_ss_RoWW','VariableNames',RoWs_names);

IOtable_ss_WRoW_norm=IOtable_ss_WRoW./sum(IOtable_ss_WRoW);

%% Energy into RoW total production
Brown=0.717;
Green=1-Brown;

W_Energy_into_RoW_Total_Prod=table2array(sum(IOtable_ss_WRoW(1,:),2));
RoW_Total_Prod=table2array(sum(IOtable_ss_WRoW,'all'));

share_W_Energy_into_RoW_Total_Prod=W_Energy_into_RoW_Total_Prod/RoW_Total_Prod;
share_B_W_Energy_into_RoW_Total_prod=share_W_Energy_into_RoW_Total_Prod*Brown;
share_G_W_Energy_into_RoW_Total_prod=share_W_Energy_into_RoW_Total_Prod*Green;

Data_out.(3)(7)=share_W_Energy_into_RoW_Total_Prod;
Data_out.(3)(8)=share_B_W_Energy_into_RoW_Total_prod;
Data_out.(3)(9)=share_G_W_Energy_into_RoW_Total_prod;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Consumption and Investment
CI=data(1:end-3,3467:end-1);
n_CI=6;
WCI_names=CI.Properties.VariableNames;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% EA CI
CI_EA=zeros(n_industries*n_countries,2);
idx_C=zeros(1,n_CI*n_countries);
idx_I=zeros(1,n_CI*n_countries);

for i=1:n_EA_countries
    idx_C=idx_C+(contains(WCI_names,[EA_countries{i},'_HFCE'])+contains(WCI_names,[EA_countries{i},'_NPISH']));
    idx_I=idx_I+(contains(WCI_names,[EA_countries{i},'_GFCF'])+contains(WCI_names,[EA_countries{i},'_INVNT']));
end

CI_EA(:,1)=table2array(sum(CI(:,logical(idx_C)),2));
CI_EA(:,2)=table2array(sum(CI(:,logical(idx_I)),2));

CI_EA_T=array2table(CI_EA','VariableNames',Wi_names);

idx_full_energy=zeros(1,n_industries*n_countries);

for i=1:n_countries
    for j=1:length(sector_aggregation{1})
        idx_full_energy=idx_full_energy+contains(Wi_names,[countries{i},sector_aggregation{1}{j}]);
    end
end

TOTAL_C_EA=sum(CI_EA(:,1));
TOTAL_I_EA=sum(CI_EA(:,2));

CI_EA_aggr=table2array(sum(CI_EA_T(:,logical(idx_full_energy)),2));

Data_out.(1)(1)=CI_EA_aggr(1)/TOTAL_C_EA;
Data_out.(1)(2)=CI_EA_aggr(1)/TOTAL_C_EA*Brown;
Data_out.(1)(3)=CI_EA_aggr(1)/TOTAL_C_EA*Green;
Data_out.(1)(4)=CI_EA_aggr(2)/TOTAL_I_EA;
Data_out.(1)(5)=CI_EA_aggr(2)/TOTAL_I_EA*Brown;
Data_out.(1)(6)=CI_EA_aggr(2)/TOTAL_I_EA*Green;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% USA CI
CI_USA=zeros(n_industries*n_countries,2);
idx_C=zeros(1,n_CI*n_countries);
idx_I=zeros(1,n_CI*n_countries);

for i=1:n_USA_countries
    idx_C=idx_C+(contains(WCI_names,[USA_countries{i},'_HFCE'])+contains(WCI_names,[USA_countries{i},'_NPISH']));
    idx_I=idx_I+(contains(WCI_names,[USA_countries{i},'_GFCF'])+contains(WCI_names,[USA_countries{i},'_INVNT']));
end

CI_USA(:,1)=table2array(sum(CI(:,logical(idx_C)),2));
CI_USA(:,2)=table2array(sum(CI(:,logical(idx_I)),2));

CI_USA_T=array2table(CI_USA','VariableNames',Wi_names);

idx_full_energy=zeros(1,n_industries*n_countries);

for i=1:n_countries
    for j=1:length(sector_aggregation{1})
        idx_full_energy=idx_full_energy+contains(Wi_names,[countries{i},sector_aggregation{1}{j}]);
    end
end

TOTAL_C_USA=sum(CI_USA(:,1));
TOTAL_I_USA=sum(CI_USA(:,2));

CI_USA_aggr=table2array(sum(CI_USA_T(:,logical(idx_full_energy)),2));

Data_out.(2)(1)=CI_USA_aggr(1)/TOTAL_C_USA;
Data_out.(2)(2)=CI_USA_aggr(1)/TOTAL_C_USA*Brown;
Data_out.(2)(3)=CI_USA_aggr(1)/TOTAL_C_USA*Green;
Data_out.(2)(4)=CI_USA_aggr(2)/TOTAL_I_USA;
Data_out.(2)(5)=CI_USA_aggr(2)/TOTAL_I_USA*Brown;
Data_out.(2)(6)=CI_USA_aggr(2)/TOTAL_I_USA*Green;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% RoW CI
CI_RoW=zeros(n_industries*n_countries,2);
idx_C=zeros(1,n_CI*n_countries);
idx_I=zeros(1,n_CI*n_countries);

for i=1:n_RoW_countries
    idx_C=idx_C+(contains(WCI_names,[RoW_countries{i},'_HFCE'])+contains(WCI_names,[RoW_countries{i},'_NPISH']));
    idx_I=idx_I+(contains(WCI_names,[RoW_countries{i},'_GFCF'])+contains(WCI_names,[RoW_countries{i},'_INVNT']));
end

CI_RoW(:,1)=table2array(sum(CI(:,logical(idx_C)),2));
CI_RoW(:,2)=table2array(sum(CI(:,logical(idx_I)),2));

CI_RoW_T=array2table(CI_RoW','VariableNames',Wi_names);

idx_full_energy=zeros(1,n_industries*n_countries);

for i=1:n_countries
    for j=1:length(sector_aggregation{1})
        idx_full_energy=idx_full_energy+contains(Wi_names,[countries{i},sector_aggregation{1}{j}]);
    end
end

TOTAL_C_RoW=sum(CI_RoW(:,1));
TOTAL_I_RoW=sum(CI_RoW(:,2));

CI_RoW_aggr=table2array(sum(CI_RoW_T(:,logical(idx_full_energy)),2));

Data_out.(3)(1)=CI_RoW_aggr(1)/TOTAL_C_RoW;
Data_out.(3)(2)=CI_RoW_aggr(1)/TOTAL_C_RoW*Brown;
Data_out.(3)(3)=CI_RoW_aggr(1)/TOTAL_C_RoW*Green;
Data_out.(3)(4)=CI_RoW_aggr(2)/TOTAL_I_RoW;
Data_out.(3)(5)=CI_RoW_aggr(2)/TOTAL_I_RoW*Brown;
Data_out.(3)(6)=CI_RoW_aggr(2)/TOTAL_I_RoW*Green;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Energy distribution on other sector + Normalization EA

IOtable_ss_WEA=table2array(IOtable_ss_WEA);
sigma_E=IOtable_ss_WEA(2,1)/(IOtable_ss_WEA(2,1)+IOtable_ss_WEA(3,1));
sigma_T=IOtable_ss_WEA(1,2)/(IOtable_ss_WEA(1,2)+IOtable_ss_WEA(1,3));

M=[ 1         ,       sigma_T       ,         1-sigma_T       ;
    sigma_E   , sigma_T*sigma_E     , (1-sigma_T)*sigma_E     ;
    1-sigma_E , sigma_T*(1-sigma_E) , (1-sigma_T)*(1-sigma_E) ];

A=IOtable_ss_WEA(1,1)*[-1, 1, 1;
                        1,-1,-1;
                        1,-1,-1];

IOtable_ss_WEA_Energy_Distributed=IOtable_ss_WEA+(A.*M);

IOtable_ss_WEA_Energy_Distributed_norm=IOtable_ss_WEA_Energy_Distributed./sum(IOtable_ss_WEA_Energy_Distributed);

%% Energy distribution on other secotr + Normalization USA

IOtable_ss_WUSA=table2array(IOtable_ss_WUSA);
sigma_E=IOtable_ss_WUSA(2,1)/(IOtable_ss_WUSA(2,1)+IOtable_ss_WUSA(3,1));
sigma_T=IOtable_ss_WUSA(1,2)/(IOtable_ss_WUSA(1,2)+IOtable_ss_WUSA(1,3));

M=[ 1         ,       sigma_T       ,         1-sigma_T       ;
    sigma_E   , sigma_T*sigma_E     , (1-sigma_T)*sigma_E     ;
    1-sigma_E , sigma_T*(1-sigma_E) , (1-sigma_T)*(1-sigma_E) ];

A=IOtable_ss_WUSA(1,1)*[-1, 1, 1;
                        1,-1,-1;
                        1,-1,-1];

IOtable_ss_WUSA_Energy_Distributed=IOtable_ss_WUSA+(A.*M);

IOtable_ss_WUSA_Energy_Distributed_norm=IOtable_ss_WUSA_Energy_Distributed./sum(IOtable_ss_WUSA_Energy_Distributed);

%% Energy distribution on other secotr + Normalization RoW

IOtable_ss_WRoW=table2array(IOtable_ss_WRoW);
sigma_E=IOtable_ss_WRoW(2,1)/(IOtable_ss_WRoW(2,1)+IOtable_ss_WRoW(3,1));
sigma_T=IOtable_ss_WRoW(1,2)/(IOtable_ss_WRoW(1,2)+IOtable_ss_WRoW(1,3));

M=[ 1         ,       sigma_T       ,         1-sigma_T       ;
    sigma_E   , sigma_T*sigma_E     , (1-sigma_T)*sigma_E     ;
    1-sigma_E , sigma_T*(1-sigma_E) , (1-sigma_T)*(1-sigma_E) ];

A=IOtable_ss_WRoW(1,1)*[-1, 1, 1;
                        1,-1,-1;
                        1,-1,-1];

IOtable_ss_WRoW_Energy_Distributed=IOtable_ss_WRoW+(A.*M);

IOtable_ss_WRoW_Energy_Distributed_norm=IOtable_ss_WRoW_Energy_Distributed./sum(IOtable_ss_WRoW_Energy_Distributed);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Plot settings
addpath('P:\ECB business areas\DGR\Project\papadon_QMFA\wTemp\Energy_project\OECD_database\functions');
path='P:\ECB business areas\DGR\Project\papadon_QMFA\wTemp\Energy_project\OECD_database\Figures';
ce=[43,76,125]./255; %energy blue
cm=[243,169,22]./255; %manifacturing orange
cs=[195,43,43]./255; %services red

%% EA Plot
fig=figure('visible','off'); 
bh=bar(1:size(IOtable_ss_WEA_Energy_Distributed_norm, 1), IOtable_ss_WEA_Energy_Distributed_norm', 'stacked','FaceColor','flat');
bh(1).CData=ce;
bh(2).CData=cm;
bh(3).CData=cs;
tt=title('Sectorial input into sectorial output (%) EA ');
lgd=legend(sector_name);
xticklabels(sector_name);
ecb_format_axis(gca);
ecb_format_legend(lgd);
ecb_format_title_small(tt);
ylim([0,1]);
grid on
saveas(fig,[path,'\IOtable_EA'],'fig') ;
saveas(fig,[path,'\IOtable_EA'],'eps') ;

%% USA Plot
fig=figure('visible','off'); 
bh=bar(1:size(IOtable_ss_WUSA_Energy_Distributed_norm, 1), IOtable_ss_WUSA_Energy_Distributed_norm', 'stacked','FaceColor','flat');
bh(1).CData=ce;
bh(2).CData=cm;
bh(3).CData=cs;
tt=title('Sectorial input into sectorial output (%) USA ');
lgd=legend(sector_name);
xticklabels(sector_name);
ecb_format_axis(gca);
ecb_format_legend(lgd);
ecb_format_title_small(tt);
ylim([0,1]);
grid on
saveas(fig,[path,'\IOtable_USA'],'fig') ;
saveas(fig,[path,'\IOtable_USA'],'eps') ;

%% RoW Plot
fig=figure('visible','off'); 
bh=bar(1:size(IOtable_ss_WRoW_Energy_Distributed_norm, 1), IOtable_ss_WRoW_Energy_Distributed_norm', 'stacked','FaceColor','flat');
bh(1).CData=ce;
bh(2).CData=cm;
bh(3).CData=cs;
tt=title('Sectorial input into sectorial output (%) RoW ');
lgd=legend(sector_name);
xticklabels(sector_name);
ecb_format_axis(gca);
ecb_format_legend(lgd);
ecb_format_title_small(tt);
ylim([0,1]);
grid on
saveas(fig,[path,'\IOtable_RoW'],'fig') ;
saveas(fig,[path,'\IOtable_RoW'],'eps') ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% EA CIG Energy
CI_EA_E=zeros(n_industries*n_countries,3);
idx_C_E=zeros(1,n_CI*n_countries);
idx_I_E=zeros(1,n_CI*n_countries);
idx_G_E=zeros(1,n_CI*n_countries);

for i=1:n_EA_countries
    idx_C_E=idx_C_E+(contains(WCI_names,[EA_countries{i},'_HFCE'])+contains(WCI_names,[EA_countries{i},'_NPISH']));
    idx_I_E=idx_I_E+(contains(WCI_names,[EA_countries{i},'_GFCF'])+contains(WCI_names,[EA_countries{i},'_INVNT']));
    idx_G_E=idx_G_E+contains(WCI_names,[EA_countries{i},'_GGFC']);
end

CI_EA_E(:,1)=table2array(sum(CI(:,logical(idx_C_E)),2));
CI_EA_E(:,2)=table2array(sum(CI(:,logical(idx_I_E)),2));
CI_EA_E(:,3)=table2array(sum(CI(:,logical(idx_G_E)),2));

CI_EA_T_E=array2table(CI_EA_E','VariableNames',Wi_names);

idx_full_energy=zeros(1,n_industries*n_countries);

for i=1:n_countries
    for j=1:length(sector_aggregation{1})
        idx_full_energy=idx_full_energy+contains(Wi_names,[countries{i},sector_aggregation{1}{j}]);
    end
end

TOTAL_C_EA_E=sum(CI_EA_E(:,1));
TOTAL_I_EA_E=sum(CI_EA_E(:,2));
TOTAL_G_EA_E=sum(CI_EA_E(:,3));

CI_EA_aggr_E=table2array(sum(CI_EA_T_E(:,logical(idx_full_energy)),2));

Tradable_into_CIG_EA_E=[CI_EA_aggr_E(1)/TOTAL_C_EA_E;
CI_EA_aggr_E(2)/TOTAL_I_EA_E;
CI_EA_aggr_E(3)/TOTAL_G_EA_E;];

%% USA CIG Energy
CI_USA_E=zeros(n_industries*n_countries,3);
idx_C_E=zeros(1,n_CI*n_countries);
idx_I_E=zeros(1,n_CI*n_countries);
idx_G_E=zeros(1,n_CI*n_countries);

for i=1:n_USA_countries
    idx_C_E=idx_C_E+(contains(WCI_names,[USA_countries{i},'_HFCE'])+contains(WCI_names,[USA_countries{i},'_NPISH']));
    idx_I_E=idx_I_E+(contains(WCI_names,[USA_countries{i},'_GFCF'])+contains(WCI_names,[USA_countries{i},'_INVNT']));
    idx_G_E=idx_G_E+contains(WCI_names,[USA_countries{i},'_GGFC']);
end

CI_USA_E(:,1)=table2array(sum(CI(:,logical(idx_C_E)),2));
CI_USA_E(:,2)=table2array(sum(CI(:,logical(idx_I_E)),2));
CI_USA_E(:,3)=table2array(sum(CI(:,logical(idx_G_E)),2));

CI_USA_T_E=array2table(CI_USA_E','VariableNames',Wi_names);

idx_full_energy=zeros(1,n_industries*n_countries);

for i=1:n_countries
    for j=1:length(sector_aggregation{1})
        idx_full_energy=idx_full_energy+contains(Wi_names,[countries{i},sector_aggregation{1}{j}]);
    end
end

TOTAL_C_USA_E=sum(CI_USA_E(:,1));
TOTAL_I_USA_E=sum(CI_USA_E(:,2));
TOTAL_G_USA_E=sum(CI_USA_E(:,3));

CI_USA_aggr_E=table2array(sum(CI_USA_T_E(:,logical(idx_full_energy)),2));

Tradable_into_CIG_USA_E=[CI_USA_aggr_E(1)/TOTAL_C_USA_E;
CI_USA_aggr_E(2)/TOTAL_I_USA_E;
CI_USA_aggr_E(3)/TOTAL_G_USA_E;];

%% RoW CIG Energy
CI_RoW_E=zeros(n_industries*n_countries,3);
idx_C_E=zeros(1,n_CI*n_countries);
idx_I_E=zeros(1,n_CI*n_countries);
idx_G_E=zeros(1,n_CI*n_countries);

for i=1:n_RoW_countries
    idx_C_E=idx_C_E+(contains(WCI_names,[RoW_countries{i},'_HFCE'])+contains(WCI_names,[RoW_countries{i},'_NPISH']));
    idx_I_E=idx_I_E+(contains(WCI_names,[RoW_countries{i},'_GFCF'])+contains(WCI_names,[RoW_countries{i},'_INVNT']));
    idx_G_E=idx_G_E+contains(WCI_names,[RoW_countries{i},'_GGFC']);
end

CI_RoW_E(:,1)=table2array(sum(CI(:,logical(idx_C_E)),2));
CI_RoW_E(:,2)=table2array(sum(CI(:,logical(idx_I_E)),2));
CI_RoW_E(:,3)=table2array(sum(CI(:,logical(idx_G_E)),2));

CI_RoW_T_E=array2table(CI_RoW_E','VariableNames',Wi_names);

idx_full_energy=zeros(1,n_industries*n_countries);

for i=1:n_countries
    for j=1:length(sector_aggregation{1})
        idx_full_energy=idx_full_energy+contains(Wi_names,[countries{i},sector_aggregation{1}{j}]);
    end
end

TOTAL_C_RoW_E=sum(CI_RoW_E(:,1));
TOTAL_I_RoW_E=sum(CI_RoW_E(:,2));
TOTAL_G_RoW_E=sum(CI_RoW_E(:,3));

CI_RoW_aggr_E=table2array(sum(CI_RoW_T_E(:,logical(idx_full_energy)),2));

Tradable_into_CIG_RoW_E=[CI_RoW_aggr_E(1)/TOTAL_C_RoW_E;
CI_RoW_aggr_E(2)/TOTAL_I_RoW_E;
CI_RoW_aggr_E(3)/TOTAL_G_RoW_E;];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% EA CIG Tradable
CI_EA_T=zeros(n_industries*n_countries,3);
idx_C_T=zeros(1,n_CI*n_countries);
idx_I_T=zeros(1,n_CI*n_countries);
idx_G_T=zeros(1,n_CI*n_countries);

for i=1:n_EA_countries
    idx_C_T=idx_C_T+(contains(WCI_names,[EA_countries{i},'_HFCE'])+contains(WCI_names,[EA_countries{i},'_NPISH']));
    idx_I_T=idx_I_T+(contains(WCI_names,[EA_countries{i},'_GFCF'])+contains(WCI_names,[EA_countries{i},'_INVNT']));
    idx_G_T=idx_G_T+contains(WCI_names,[EA_countries{i},'_GGFC']);
end

CI_EA_T(:,1)=table2array(sum(CI(:,logical(idx_C_T)),2));
CI_EA_T(:,2)=table2array(sum(CI(:,logical(idx_I_T)),2));
CI_EA_T(:,3)=table2array(sum(CI(:,logical(idx_G_T)),2));

CI_EA_T_T=array2table(CI_EA_T','VariableNames',Wi_names);

idx_full_tradable=zeros(1,n_industries*n_countries);

for i=1:n_countries
    for j=1:length(sector_aggregation{2})
        idx_full_tradable=idx_full_tradable+contains(Wi_names,[countries{i},sector_aggregation{2}{j}]);
    end
end

TOTAL_C_EA_T=sum(CI_EA_T(:,1));
TOTAL_I_EA_T=sum(CI_EA_T(:,2));
TOTAL_G_EA_T=sum(CI_EA_T(:,3));

CI_EA_aggr_T=table2array(sum(CI_EA_T_T(:,logical(idx_full_tradable)),2));

Tradable_into_CIG_EA_T=[CI_EA_aggr_T(1)/TOTAL_C_EA_T;
CI_EA_aggr_T(2)/TOTAL_I_EA_T;
CI_EA_aggr_T(3)/TOTAL_G_EA_T;];

%% USA CIG Tradable
CI_USA_T=zeros(n_industries*n_countries,3);
idx_C_T=zeros(1,n_CI*n_countries);
idx_I_T=zeros(1,n_CI*n_countries);
idx_G_T=zeros(1,n_CI*n_countries);

for i=1:n_USA_countries
    idx_C_T=idx_C_T+(contains(WCI_names,[USA_countries{i},'_HFCE'])+contains(WCI_names,[USA_countries{i},'_NPISH']));
    idx_I_T=idx_I_T+(contains(WCI_names,[USA_countries{i},'_GFCF'])+contains(WCI_names,[USA_countries{i},'_INVNT']));
    idx_G_T=idx_G_T+contains(WCI_names,[USA_countries{i},'_GGFC']);
end

CI_USA_T(:,1)=table2array(sum(CI(:,logical(idx_C_T)),2));
CI_USA_T(:,2)=table2array(sum(CI(:,logical(idx_I_T)),2));
CI_USA_T(:,3)=table2array(sum(CI(:,logical(idx_G_T)),2));

CI_USA_T_T=array2table(CI_USA_T','VariableNames',Wi_names);

idx_full_tradable=zeros(1,n_industries*n_countries);

for i=1:n_countries
    for j=1:length(sector_aggregation{2})
        idx_full_tradable=idx_full_tradable+contains(Wi_names,[countries{i},sector_aggregation{2}{j}]);
    end
end

TOTAL_C_USA_T=sum(CI_USA_T(:,1));
TOTAL_I_USA_T=sum(CI_USA_T(:,2));
TOTAL_G_USA_T=sum(CI_USA_T(:,3));

CI_USA_aggr_T=table2array(sum(CI_USA_T_T(:,logical(idx_full_tradable)),2));

Tradable_into_CIG_USA_T=[CI_USA_aggr_T(1)/TOTAL_C_USA_T;
CI_USA_aggr_T(2)/TOTAL_I_USA_T;
CI_USA_aggr_T(3)/TOTAL_G_USA_T;];

%% RoW CIG Tradable
CI_RoW_T=zeros(n_industries*n_countries,3);
idx_C_T=zeros(1,n_CI*n_countries);
idx_I_T=zeros(1,n_CI*n_countries);
idx_G_T=zeros(1,n_CI*n_countries);

for i=1:n_RoW_countries
    idx_C_T=idx_C_T+(contains(WCI_names,[RoW_countries{i},'_HFCE'])+contains(WCI_names,[RoW_countries{i},'_NPISH']));
    idx_I_T=idx_I_T+(contains(WCI_names,[RoW_countries{i},'_GFCF'])+contains(WCI_names,[RoW_countries{i},'_INVNT']));
    idx_G_T=idx_G_T+contains(WCI_names,[RoW_countries{i},'_GGFC']);
end

CI_RoW_T(:,1)=table2array(sum(CI(:,logical(idx_C_T)),2));
CI_RoW_T(:,2)=table2array(sum(CI(:,logical(idx_I_T)),2));
CI_RoW_T(:,3)=table2array(sum(CI(:,logical(idx_G_T)),2));

CI_RoW_T_T=array2table(CI_RoW_T','VariableNames',Wi_names);

idx_full_tradable=zeros(1,n_industries*n_countries);

for i=1:n_countries
    for j=1:length(sector_aggregation{2})
        idx_full_tradable=idx_full_tradable+contains(Wi_names,[countries{i},sector_aggregation{2}{j}]);
    end
end

TOTAL_C_RoW_T=sum(CI_RoW_T(:,1));
TOTAL_I_RoW_T=sum(CI_RoW_T(:,2));
TOTAL_G_RoW_T=sum(CI_RoW_T(:,3));

CI_RoW_aggr_T=table2array(sum(CI_RoW_T_T(:,logical(idx_full_tradable)),2));

Tradable_into_CIG_RoW_T=[CI_RoW_aggr_T(1)/TOTAL_C_RoW_T;
CI_RoW_aggr_T(2)/TOTAL_I_RoW_T;
CI_RoW_aggr_T(3)/TOTAL_G_RoW_T;];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% EA CIG Non Tradable 
CI_EA_NT=zeros(n_industries*n_countries,3);
idx_C_NT=zeros(1,n_CI*n_countries);
idx_I_NT=zeros(1,n_CI*n_countries);
idx_G_NT=zeros(1,n_CI*n_countries);

for i=1:n_EA_countries
    idx_C_NT=idx_C_NT+(contains(WCI_names,[EA_countries{i},'_HFCE'])+contains(WCI_names,[EA_countries{i},'_NPISH']));
    idx_I_NT=idx_I_NT+(contains(WCI_names,[EA_countries{i},'_GFCF'])+contains(WCI_names,[EA_countries{i},'_INVNT']));
    idx_G_NT=idx_G_NT+contains(WCI_names,[EA_countries{i},'_GGFC']);
end

CI_EA_NT(:,1)=table2array(sum(CI(:,logical(idx_C_NT)),2));
CI_EA_NT(:,2)=table2array(sum(CI(:,logical(idx_I_NT)),2));
CI_EA_NT(:,3)=table2array(sum(CI(:,logical(idx_G_NT)),2));

CI_EA_T_NT=array2table(CI_EA_NT','VariableNames',Wi_names);

idx_full_non_tradable=zeros(1,n_industries*n_countries);

for i=1:n_countries
    for j=1:length(sector_aggregation{3})
        idx_full_non_tradable=idx_full_non_tradable+contains(Wi_names,[countries{i},sector_aggregation{3}{j}]);
    end
end

TOTAL_C_EA_NT=sum(CI_EA_NT(:,1));
TOTAL_I_EA_NT=sum(CI_EA_NT(:,2));
TOTAL_G_EA_NT=sum(CI_EA_NT(:,3));

CI_EA_aggr_NT=table2array(sum(CI_EA_T_NT(:,logical(idx_full_non_tradable)),2));

Tradable_into_CIG_EA_NT=[CI_EA_aggr_NT(1)/TOTAL_C_EA_NT;
CI_EA_aggr_NT(2)/TOTAL_I_EA_NT;
CI_EA_aggr_NT(3)/TOTAL_G_EA_NT;];

%% USA CIG Non Tradable
CI_USA_NT=zeros(n_industries*n_countries,3);
idx_C_NT=zeros(1,n_CI*n_countries);
idx_I_NT=zeros(1,n_CI*n_countries);
idx_G_NT=zeros(1,n_CI*n_countries);

for i=1:n_USA_countries
    idx_C_NT=idx_C_NT+(contains(WCI_names,[USA_countries{i},'_HFCE'])+contains(WCI_names,[USA_countries{i},'_NPISH']));
    idx_I_NT=idx_I_NT+(contains(WCI_names,[USA_countries{i},'_GFCF'])+contains(WCI_names,[USA_countries{i},'_INVNT']));
    idx_G_NT=idx_G_NT+contains(WCI_names,[USA_countries{i},'_GGFC']);
end

CI_USA_NT(:,1)=table2array(sum(CI(:,logical(idx_C_NT)),2));
CI_USA_NT(:,2)=table2array(sum(CI(:,logical(idx_I_NT)),2));
CI_USA_NT(:,3)=table2array(sum(CI(:,logical(idx_G_NT)),2));

CI_USA_T_NT=array2table(CI_USA_NT','VariableNames',Wi_names);

idx_full_non_tradable=zeros(1,n_industries*n_countries);

for i=1:n_countries
    for j=1:length(sector_aggregation{3})
        idx_full_non_tradable=idx_full_non_tradable+contains(Wi_names,[countries{i},sector_aggregation{3}{j}]);
    end
end

TOTAL_C_USA_NT=sum(CI_USA_NT(:,1));
TOTAL_I_USA_NT=sum(CI_USA_NT(:,2));
TOTAL_G_USA_NT=sum(CI_USA_NT(:,3));

CI_USA_aggr_NT=table2array(sum(CI_USA_T_NT(:,logical(idx_full_non_tradable)),2));

Tradable_into_CIG_USA_NT=[CI_USA_aggr_NT(1)/TOTAL_C_USA_NT;
CI_USA_aggr_NT(2)/TOTAL_I_USA_NT;
CI_USA_aggr_NT(3)/TOTAL_G_USA_NT;];

%% RoW CIG Non Tradable
CI_RoW_NT=zeros(n_industries*n_countries,3);
idx_C_NT=zeros(1,n_CI*n_countries);
idx_I_NT=zeros(1,n_CI*n_countries);
idx_G_NT=zeros(1,n_CI*n_countries);

for i=1:n_RoW_countries
    idx_C_NT=idx_C_NT+(contains(WCI_names,[RoW_countries{i},'_HFCE'])+contains(WCI_names,[RoW_countries{i},'_NPISH']));
    idx_I_NT=idx_I_NT+(contains(WCI_names,[RoW_countries{i},'_GFCF'])+contains(WCI_names,[RoW_countries{i},'_INVNT']));
    idx_G_NT=idx_G_NT+contains(WCI_names,[RoW_countries{i},'_GGFC']);
end

CI_RoW_NT(:,1)=table2array(sum(CI(:,logical(idx_C_NT)),2));
CI_RoW_NT(:,2)=table2array(sum(CI(:,logical(idx_I_NT)),2));
CI_RoW_NT(:,3)=table2array(sum(CI(:,logical(idx_G_NT)),2));

CI_RoW_T_NT=array2table(CI_RoW_NT','VariableNames',Wi_names);

idx_full_non_tradable=zeros(1,n_industries*n_countries);

for i=1:n_countries
    for j=1:length(sector_aggregation{3})
        idx_full_non_tradable=idx_full_non_tradable+contains(Wi_names,[countries{i},sector_aggregation{3}{j}]);
    end
end

TOTAL_C_RoW_NT=sum(CI_RoW_NT(:,1));
TOTAL_I_RoW_NT=sum(CI_RoW_NT(:,2));
TOTAL_G_RoW_NT=sum(CI_RoW_NT(:,3));

CI_RoW_aggr_NT=table2array(sum(CI_RoW_T_NT(:,logical(idx_full_non_tradable)),2));

Tradable_into_CIG_RoW_NT=[CI_RoW_aggr_NT(1)/TOTAL_C_RoW_NT;
CI_RoW_aggr_NT(2)/TOTAL_I_RoW_NT;
CI_RoW_aggr_NT(3)/TOTAL_G_RoW_NT;];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Imported share EA
W_wo_EA_countries=setdiff(countries,EA_countries);
n_W_wo_EA_countries=length(W_wo_EA_countries);

for i=1:n_W_wo_EA_countries
    idx=contains(Wi_names,W_wo_EA_countries{i});
end

Import_EA=table2array(sum(IOtable_si_EAW(:,logical(idx)),2));
Import_EA=array2table(Import_EA','VariableNames',EAs_names);

Import_share_EA=Import_EA./sum(IOtable_ss_WEA,1);

%% Imported share USA
W_wo_USA_countries=setdiff(countries,USA_countries);
n_W_wo_USA_countries=length(W_wo_USA_countries);

for i=1:n_W_wo_USA_countries
    idx=contains(Wi_names,W_wo_USA_countries{i});
end

Import_USA=table2array(sum(IOtable_si_USAW(:,logical(idx)),2));
Import_USA=array2table(Import_USA','VariableNames',USAs_names);

Import_share_USA=Import_USA./sum(IOtable_ss_WUSA,1);

%% Imported share RoW
W_wo_RoW_countries=setdiff(countries,RoW_countries);
n_W_wo_RoW_countries=length(W_wo_RoW_countries);

for i=1:n_W_wo_RoW_countries
    idx=contains(Wi_names,W_wo_RoW_countries{i});
end

Import_RoW=table2array(sum(IOtable_si_RoWW(:,logical(idx)),2));
Import_RoW=array2table(Import_RoW','VariableNames',RoWs_names);

Import_share_RoW=Import_RoW./sum(IOtable_ss_WRoW,1);
