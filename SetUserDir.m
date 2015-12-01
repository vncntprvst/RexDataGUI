function userinfo=SetUserDir
%find user, directory and slash type
%added database directory 08/14 - VP
%changed varout to structure

userinfo=struct('directory',[],'slash',[],'user',[],'dbldir',[],...
    'syncdir',[],'mapdr',[],'servrep',[],'mapddataf',[]);
% determines computer type
archst  = computer('arch');

if strcmp(archst, 'maci64')
    name = getenv('USER');
    if strcmp(name, 'zacharyabzug')
        userinfo.directory = '/Users/zacharyabzug/Desktop/zackdata/';
        userinfo.user='Zach';
    elseif strcmp(name, 'zmabzug')
        userinfo.directory = '/Users/zmabzug/Desktop/zackdata/';
        userinfo.user='Zach';
    end
    userinfo.slash = '/';
elseif strcmp(archst, 'win32') || strcmp(archst, 'win64')
    if strcmp(getenv('username'),'SommerVD') || ...
            strcmp(getenv('username'),'LabV') || ...
            strcmp(getenv('username'),'Purkinje') || ...
            strcmp(getenv('username'),'JuanandKimi') || ...
            strcmp(getenv('username'),'vp35')
        userinfo.directory = 'C:\Data\Recordings\';
        userinfo.user='generic';
    elseif strcmp(getenv('username'),'DangerZone')
        userinfo.directory = 'E:\data\Recordings\';
        userinfo.user='Vincent';
        userinfo.dbldir = 'E:\JDBC';
        userinfo.mapddataf='vincedata';
        userinfo.syncdir='E:\BoxSync\Box Sync\Home Folder vp35\Sync\CbTimingPredict\data';
    elseif strcmp(getenv('username'),'Radu')
        userinfo.directory = 'E:\Spike_Sorting\';
        userinfo.user='Radu';
    elseif strcmp(getenv('username'),'The Doctor')
        userinfo.directory = 'C:\Users\The Doctor\Data\';
        userinfo.user='generic';
    else strcmp(getenv('username'),'Vincent')
        userinfo.directory = 'D:\data\Recordings\';
        userinfo.user='Vincent';
        userinfo.dbldir = 'D:\JDBC'; %or C:\Box Sync\Home Folder vp35\Sync\CbTimingPredict\data\JDBC
        userinfo.mapddataf='vincedata';
        userinfo.syncdir='C:\Box Sync\Home Folder vp35\Sync\CbTimingPredict\data';
    end
    userinfo.slash = '\';
    
    %find if one or more remote drives are mapped
    [~,connlist]=system('net use');
    if logical(regexp(connlist,'OK'))
        %in case multiple mapped drives, add some code here
        carrets=regexpi(connlist,'\r\n|\n|\r');
        if ~length(regexp(connlist,':','start'))
            disp('connect remote drive to place files on server')
        elseif length(regexp(connlist,':','start'))==1
            userinfo.servrep=connlist(regexp(connlist,':','start')-1:carrets(find(carrets>regexp(connlist,':','start'),1))-1);
            userinfo.servrep=regexprep(userinfo.servrep,'[^\w\\|.|:|-'']','');
            userinfo.mapdr=userinfo.servrep(1:2);userinfo.servrep=userinfo.servrep(3:end);userinfo.servrep=regexprep(userinfo.servrep,'\\','/');
        elseif length(regexp(connlist,':','start'))>=2
            servs=regexp(connlist,':','start')-1;
            for servl=1:length(servs)
                if logical(strfind(regexprep(connlist(servs(servl):carrets(find(carrets>servs(servl),1))-1),'[^\w\\|.|:|-'']',''),...
                'ccn-sommerserv.win.duke.edu'))
                    userinfo.servrep=regexprep(connlist(servs(servl):carrets(find(carrets>servs(servl),1))-1),'[^\w\\|.|:|-'']','');
                    userinfo.mapdr=userinfo.servrep(1:2);userinfo.servrep=userinfo.servrep(3:end);userinfo.servrep=regexprep(userinfo.servrep,'\\','/');
                    break;
                end
            end
        end
    else 
        [userinfo.servrep,userinfo.mapdr]=deal([]); 
    end
end