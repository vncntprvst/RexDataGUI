function [curtasktype, ecodecueon, ecodesacstart, ecodesacend]=taskdetect(codes, curtasktype)

% identifies task, and also tells which ecodes correspond to which event
% called by rex_process_inGUI and by data_info

if nargin<2
    curtasktype=[];
end

global tasktype;

ecodecueon=[];
ecodesacstart=[];
ecodesacend=[];

if size(codes,2)==1
    codes=codes';
end

if iscell(curtasktype)
    curtasktype=cell2mat(curtasktype);
end

alltasktypes={'vg_saccades','base2rem50','memguided','st_saccades','gapstop','gapsac','delayedsac','optiloc','tokens','fixation'};
%fsttlecode=floor(allcodes(1,2)/10)*10;
if size(codes,1)>1 %for a full file of ecodes
    ecodetypes=unique(floor(codes(:,2)/10)*10); %gives away the different ecode if mixed task
else %if called during a trial, there's only one line
    ecodetypes=floor(codes(2)/10)*10;
end
if ~sum(curtasktype) || strcmp(curtasktype,'Task') %then find task!
    if ecodetypes(1)==6010 % Visually guided saccades task type, including 'amp', 'dir' and 'optiloc'
        if strcmp(tasktype,'optiloc')
             curtasktype=alltasktypes(8); %optiloc
             tasktype=alltasktypes(8); 
        elseif size(codes,1)>1 && logical(sum(find(codes==16386,1)))
            curtasktype=alltasktypes(8); %optiloc
        else
            if find(codes==16386)
                curtasktype='reproc';
                tasktype=alltasktypes(8);
                return;
            else
            curtasktype=alltasktypes(1);
            end 
        end
    elseif ecodetypes(1)==6020
        %make sure this is consistent over older recordings
        % default memory guided saccade is the self-timed saccade, but check if it is correct
        if isempty(find(codes==16386, 1))
            if length(ecodetypes)>1 && find(ecodetypes==6040) && find(ecodetypes==6080)
                curtasktype=alltasktypes(2); %base2rem50
            else
                if ~size(codes,2)
                    taskdisambig = questdlg('Is this a Memory guided task ?','Ambiguous Task','Yes','Yes but self timed','Cancel','Yes');
                    switch taskdisambig
                        case 'Yes'
                            curtasktype=alltasktypes(3); %memory guided
                        case 'Yes but self timed'
                            curtasktype=alltasktypes(4); %self timed saccade task
                        case 'Cancel'
                            return;
                    end
                else %single trial
                    %if isempty(tasktype) %instead of asking question, assume that it's the rare 
                                         %ambiguous case where it's memory
                                         %guided task. Later on, if it
                                         %appears to be a self-timed
                                         %saccade task, the file will be
                                         %reprocessed
%                         taskdisambig = questdlg('Is this a Memory guided task ?','Ambiguous Task','Yes','Yes but self timed','Cancel','Yes');
%                         switch taskdisambig
%                             case 'Yes'
%                                 curtasktype=alltasktypes(3); %memory guided
%                                 tasktype=alltasktypes(3); %memory guided
%                             case 'Yes but self timed'
%                                 curtasktype=alltasktypes(4); %self timed saccade task
%                                 tasktype=alltasktypes(4);
%                             case 'Cancel'
%                                 return;
%                         end
                    if strcmp(tasktype,'memguided')
                        curtasktype=alltasktypes(3); %memory guided
                        tasktype=alltasktypes(3); %memory guided
                    elseif strcmp(tasktype,'st_saccades')
                        curtasktype=alltasktypes(4); %self timed saccade task
                        tasktype=alltasktypes(4);
                    elseif strcmp(tasktype,'base2rem50')
                        curtasktype=alltasktypes(2); %base2rem50
                        tasktype=alltasktypes(2);
                    else 
                        %have to assume the default is self timed saccade,
                        %because Rigel managed to do entire recordings
                        %without the 16386 error code!
                        curtasktype=alltasktypes(4); %self timed saccade task
                        tasktype=alltasktypes(4); %self timed saccade task
                    end
                    
                end
            end
        else
            if strcmp(tasktype,'memguided')
                curtasktype='reproc';
                tasktype=alltasktypes(4);
                return;
            else
                curtasktype=alltasktypes(4); %self timed saccade task
                tasktype=alltasktypes(4);
            end
        end
    elseif ecodetypes(1)==6040
        if (length(ecodetypes)>1 && find(ecodetypes==6020) && find(ecodetypes==6080)) || strcmp(tasktype,'base2rem50')
            curtasktype=alltasktypes(2); %base2rem50
            tasktype=alltasktypes(2);
        elseif length(ecodetypes)>1 && find(ecodetypes==4070)
            curtasktype=alltasktypes(5); %gapstop
            tasktype=alltasktypes(5);
        elseif ~strcmp(tasktype,'gapstop')
            curtasktype=alltasktypes(6); %gapsac
            tasktype=alltasktypes(6);
        else
            curtasktype=alltasktypes(5); %gapstop
            tasktype=alltasktypes(5);
        end
    elseif ecodetypes(1)==6050
        return;
    elseif ecodetypes(1)==6080
        if (length(ecodetypes)>1 && find(ecodetypes==6020) && find(ecodetypes==6040)) || strcmp(tasktype,'base2rem50')
            curtasktype=alltasktypes(2); %base2rem50
            tasktype=alltasktypes(2);
        else
            if strcmp(tasktype,'memguided') || strcmp(tasktype,'gapsac') || strcmp(tasktype,'st_saccades')
                curtasktype='reproc';
                tasktype=alltasktypes(2);
                return;
            else
                curtasktype=alltasktypes(7);% delayedsac
            end 
        end
    elseif ecodetypes(1)==4010
        curtasktype=alltasktypes(10);
    elseif ecodetypes(1)==4050
        return;
    elseif ecodetypes(1)==4060
        curtasktype=alltasktypes(9);% tokens
    elseif ecodetypes(1)==4070
        if length(ecodetypes)>1 && find(ecodetypes==6040) % for full set of ecodes
             curtasktype=alltasktypes(5); %gapstop
        else
            curtasktype=alltasktypes(5); %gapstop
            if strcmp(tasktype,'st_saccades') %for that one weird mixed-up file
                curtasktype='gapstop';
                tasktype=alltasktypes(5);
            elseif ~strcmp(tasktype,'gapstop')
                curtasktype='reproc';
                tasktype=alltasktypes(5);
                return;
            end
        end
    elseif ecodetypes(1)==4080
        return;
    end
end
%%
if ~isempty(curtasktype) && ~sum(find(codes==17385))
    if iscell(curtasktype)
        curtasktype=cell2mat(curtasktype);
    end
    switch curtasktype
        case 'vg_saccades'
            ecodecueon=7;
            ecodesacstart=8;
            ecodesacend=9;
        case 'base2rem50' %variable
        case 'st_saccades'
            ecodecueon=6;
            ecodesacstart=8;
            ecodesacend=9;
        case 'gapstop'
            ecodecueon=7;
            if ~isempty(find(codes==1503, 1)) 
            ecodesacstart=9;
%               ecode to control for stop signal delay value, introduced between target code and stop code
%               stopcode is at 9, not 8 anymore 
            else
            ecodesacstart=8;
            end
            ecodesacend=9;
        case 'memguided'
            disp('check task ecodes in taskdetect');
            ecodecueon=6;
            ecodesacstart=9;
            ecodesacend=10;
        case 'gapsac'
            ecodecueon=7;
            ecodesacstart=8;
            ecodesacend=9;
        case 'delayedsac' % to change ?!
            disp('check task ecodes for delayedsac in taskdetect');
            ecodecueon=6;
            ecodesacstart=8;
            ecodesacend=9;
        case 'tokens'
            %cue on is variable. returns all tokens event numbers
            ecodecueon=find(codes==1501);
            %sacstart is variable too.
            ecodesacstart=find(floor(codes/10)==466);
            if find(codes==16386) %in case it's a saccade to the wrong target, there's no saccade end ecode, but we want the other informations still
                ecodesacend=ecodesacstart;
            else
                ecodesacend=find(floor(codes/10)==486);
            end
         case 'optiloc'
            ecodecueon=7;
            ecodesacstart=8;
            ecodesacend=9;
    end
end
