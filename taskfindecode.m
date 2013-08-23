function [fixcode fixoffcode tgtcode tgtoffcode saccode...
    stopcode rewcode tokcode errcode1 errcode2 errcode3 basecode] = taskfindecode(tasktype);

%define ecodes according to task (reverses taskdetect basically)
%add last number for direction
% called by rdd_rasters_sdf

fixcode=[];
fixoffcode=[];
tgtcode=[];
tgtoffcode=[];
saccode=[];
stopcode=[];
rewcode=1030;
errcode1=17385;
errcode2=16386;
errcode3=16387;
tokcode=1501;
basecode=[];

if strcmp(tasktype,'vg_saccades') || strcmp(tasktype,'optiloc')
    basecode=601;
    fixcode=621;
    fixoffcode=661;
    tgtcode=681;
    tgtoffcode=103;
    saccode=701;
elseif strcmp(tasktype,'base2rem50')
    basecode=[602,604,608];
    fixcode=[622;624;628];
    fixoffcode=[702;664;688];
    tgtcode=[662;684;668];
    tgtoffcode=[662;103;103];
    saccode=[722;704;708];
elseif strcmp(tasktype,'st_saccades')
    basecode=602;
    fixcode=622;
    fixoffcode=742;
    tgtcode=662;
    tgtoffcode=682;
    saccode=702;
elseif strcmp(tasktype,'gapstop')
    basecode=[604,407];
    fixcode=[624,427];
    fixoffcode=[664,467];
    tgtcode=[684,487];
    tgtoffcode=[103,103];
    saccode=[704];
    stopcode=[507];
elseif strcmp(tasktype,'tokens')
    basecode=406;
    fixcode=426;
    fixoffcode=103; %none
    tgtcode=tokcode;
    tgtoffcode=103; %none
    saccode=466;
elseif strcmp(tasktype,'twoafc') % need to add additional ecodes
    basecode=405;
    fixcode=425;
    fixoffcode=485;
    tgtcode=465;
    tgtoffcode=585; %none but hacking this code: eye in fix pt window
    saccode=505;
    errcode2=17386;
elseif strcmp(tasktype,'fixation')
    basecode=401;
    fixcode=421;
    fixoffcode=103; %none
    tgtcode=fixcode;
    tgtoffcode=103; %none
    saccode=441;
elseif strcmp(tasktype,'gapsac')
    basecode=604;
    fixcode=624;
    fixoffcode=664;
    tgtcode=684;
    tgtoffcode=103;
    saccode=704;
else
    disp('task type no recognized');
    return
end
% if nargout == 1
% end