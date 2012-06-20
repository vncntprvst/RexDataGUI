function SHdaq2mat()

%SHdaq2mat converts the daq files recorded with SH to .mat format
%SHdaq2mat get the trigger timestamps from the trigger channel (ie,
%channel 1, then delete Ch1 data to reduce file size.

%select files to convert
clear all;
DirInfo = dir('*.daq');
filedates = datenum(cat(1,DirInfo(:).datenum));
[maxdate, index] = max(filedates);
recentf=DirInfo(index).name;
[daqfilenames, pathname, filterindex] = uigetfile( ...
    {'*.daq'},'File Selector',recentf,...
    'MultiSelect','on');  % add 'defaultpath'

if filterindex==0
    disp('conversion canceled');
    return
end
if length(char(daqfilenames(1)))==1
    numfiles=1;
else
    numfiles = length (daqfilenames);
end
clear filterindex pathname;
rm_ch_save(daqfilenames, numfiles);

function rm_ch_save(filenames,nbfiles)

for i=1:nbfiles
    try
        if nbfiles==1
            daqfilename=char(filenames);
        else
            daqfilename=char(filenames(i));
        end
        daqinfo=daqread(daqfilename,'info');
        nbsamples=daqinfo.ObjInfo.SamplesAcquired;
        nbchan=size(daqinfo.ObjInfo.Channel,2); %checking there are two channels
        infofilename=cat(2,daqfilename(1:find(daqfilename=='.')-1),'_info.txt');
        if exist(infofilename)
            contxtinfo = importdata(infofilename);
        else
            contxtinfo = 'none';
        end
        
        if nbchan==2
            trigdat=zeros(1000,1);
            trigtime=[];
            smptrigtime=[];
            for i=1:1000:(floor(nbsamples/1000)*1000)-1
                trigdat=daqread(daqfilename,'Channels',2,'Samples',[i i+999]);
                trigdat(find(trigdat>4))=5;
                trigdat(find(trigdat<4))=0;
                trigdat=bwlabeln(trigdat);
                if foundtrig
                    if find(trigdat==1,1)
                        smptrigtime(1,1)=[];
                        smptrigtime(1,2)=find(trigdat==1,1,'last');
                        clear foundtrig
                        if max(trigdat)>1
                            for j=2:max(trigdat)
                                smptrigtime(j,1)=find(trigdat==j,1);
                                smptrigtime(j,2)=find(trigdat==j,1,'last');
                                foundtrig=1;
                            end
                        end
                    end
                end
                
                for j=1:max(trigdat)
                    smptrigtime(j,1)=find(trigdat==j,1);
                    smptrigtime(j,2)=find(trigdat==j,1,'last');
                    foundtrig=1;
                end
                %unless end of last loop was high state already !!!!
                trigtime=[trigtime;smptrigtime];
                smptrigtime=[];
                
            end
        end
        data = daqread(daqfilename,'Channels',1)
        %clear time j trigdat infofilename;
        %varlist=who;
        %varlist=varlist([1 2 4 5 6]);%remove daqfilename and other useless variables from the list of variables to save
        save(cat(2,daqfilename(1:find(daqfilename=='.')-1),'_cv.mat'),'contxtinfo','daqinfo','data','trigtime');
        fclose('all');
        clear daqfilename data time abstime events daqinfo infofilename contxtinfo nbchan trigdat trigtime;
    catch
        fprintf('error (or out of memory) while opening file %s\n',daqfilename);
    end
end
