function [nt, curtasktype] = num_rex_trials( name )

% [nt, curtasktype] = num_rex_trials( name )
%
% How many trials are in the Rex data given by 'name'.
%
% If the data for 'name' are not in memory, num_rex_trials will attempt to
% load them with rex_load_processed.
%
% If for some reason loading fails, num_rex_trials returns 0;

global rexloadedname;
%rexnumtrials alloriginaltrialnums allnewtrialnums...
%     allcodes alltimes allspkchan allspk allrates ...
%     allh allv allstart allbad alldeleted allsacstart allsacend...
%     allcodelen allspklen alleyelen allsaclen saccadeInfo;


nt = 0;

if ~strcmp( name,rexloadedname ); % rexloadedname is created in rex_process
     success = rex_load_processed( name );
     if ~success
         return;
     end;
end;

% detecting tasktype

alltasktypes={'vg_saccades','base2rem50','st_saccades','gapstop'};
%fsttlecode=floor(allcodes(1,2)/10)*10;
ecodetypes=unique(floor(allcodes(:,2)/10)*10); %gives away the different ecode if mixed task
if ecodetypes(1)==6010 % Visually guided saccades task type, including 'amp', 'dir' and 'optiloc'
    curtasktype=alltasktypes(1);
elseif ecodetypes(1)==6020
    %make sure this is consistent over older recordings
    % default memory guided saccade is the self-timed saccade, but check if it is correct
    if isempty(find(allcodes==16386))
        if length(ecodetypes)>1 && find(ecodetypes==6040) && find(ecodetypes==6080)
            curtasktype=alltasktypes(2); %base2rem50
        else
            disp( 'Is this a Memory guided task ?');
            %prompt something
            return;
        end
    else
        curtasktype=alltasktypes(3); %self timed saccade task
    end
elseif ecodetypes(1)==6040
    if length(ecodetypes)>1 && find(ecodetypes==6020) && find(ecodetypes==6080)
        curtasktype=alltasktypes(2); %base2rem50
    elseif length(ecodetypes)>1 && find(ecodetypes==4070)
        curtasktype=alltasktypes(4); %gapstop
    else
        return;
    end
elseif ecodetypes(1)==6050
    return;  
elseif ecodetypes(1)==6080
    if length(ecodetypes)>1 && find(ecodetypes==6020) && find(ecodetypes==6040)
        curtasktype=alltasktypes(2); %base2rem50
    else
        return
    end
elseif ecodetypes(1)==4050
    return;
elseif ecodetypes(1)==4060
    return;
elseif ecodetypes(1)==4070
    if length(ecodetypes)>1 && find(ecodetypes==6040)
        curtasktype=alltasktypes(4); %gapstop
    else
        return;
    end
elseif ecodetypes(1)==4080
    return;
end



nt = rexnumtrials;