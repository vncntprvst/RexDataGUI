function [rexnumtrials, trialdirs] = data_info( rdd_filename, reload, skipunproc )

% [nt, curtasktype, trialdirs, saccadeInfo] = data_info( name )
%
% Returns the type of task, how many trials are in the Rex data, and loads a
% number of global variables 
%
% If the data for 'name' are not in memory, num_rex_trials will attempt to
% load them with rex_load_processed.
%
% If for some reason loading fails, num_rex_trials returns 0;

% global rexloadedname rexnumtrials alloriginaltrialnums allnewtrialnums...
%     allcodes alltimes allspkchan allspk allrates ...
%     allh allv allstart allbad alldeleted allsacstart allsacend...
%     allcodelen allspklen alleyelen allsaclen saccadeInfo;
global allcodes alltimes allspkchan allspk allrates ...
        allh allv allstart allbad saccadeInfo;
    
global sessiondata rexloadedname rexnumtrials;
% using the matfile function to access file
sessiondata=matfile(rdd_filename);

if nargin<3
    skipunproc=0;
end

if nargin<2
    reload=0;
end

includeaborted = 1; %by default
rdd_includeaborted = includeaborted;
rexloadedname=get(findobj('Tag','filenamedisplay'),'String');

if ~strcmp(rdd_filename,rexloadedname) || reload; % rexloadedname is created in rex_process
     rexnumtrials = 0;
     %disp( 'File not loaded yet...');
     success = rex_load_processed( rdd_filename, skipunproc);
     if ~success
         return;
     end;
     set(findobj('Tag','filenamedisplay'),'String',rdd_filename);
     set(findobj('Tag','nboftrialsdisplay'),'String',num2str(rexnumtrials));
else 
    rexnumtrials=str2num(get(findobj('Tag','nboftrialsdisplay'),'String'));
    disp( 'File already loaded ...');
end;

% matfile access takes ~3.5s. for the commands below (if initial matfile
% called taken into account). Loading the whole file takes .5s.
% May be due to the file being saved in v7.3 rather than 7 (but we need
% 7.3) . In the future, could be done by saving data into database and
% using http://www.mathworks.com/products/database/
% allcodes = sessiondata.allcodes;
% alltimes = sessiondata.alltimes;
% allspkchan = sessiondata.allspkchan;
% allspk = sessiondata.allspk;
% allrates  = sessiondata.allrates;
% allh = sessiondata.allh;
% allv = sessiondata.allv;
% allstart = sessiondata.allstart;
% allbad = sessiondata.allbad;
% saccadeinfo = sessiondata.saccadeinfo;

% detecting tasktype
curtasktype=taskdetect(allcodes);

set(findobj('Tag','taskdisplay'),'String',curtasktype);

%findings all used directions from ecodes
trialtypes=allcodes(:,2);
trialdirs=unique(trialtypes-floor(trialtypes./10)*10);