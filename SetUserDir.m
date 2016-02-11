function [directory,slash,user,dbldir,mapdr,servrep,mapddataf]=SetUserDir
%find user, directory and slash type
%added database directory 08/14 - VP

% should switch by hostname: [~,foo]=system('hostname')

% determines computer type
archst  = computer('arch'); 

if strcmp(archst, 'maci64')
    name = getenv('USER');
    if strcmp(name, 'zacharyabzug')
        directory = '/Users/zacharyabzug/Desktop/zackdata/';
        user='Zach';
    elseif strcmp(name, 'zmabzug')
        directory = '/Users/zmabzug/Desktop/zackdata/';
        user='Zach';
    end
    slash = '/';
elseif strcmp(archst, 'win32') || strcmp(archst, 'win64')
    if strcmp(getenv('username'),'SommerVD') || ...
            strcmp(getenv('username'),'LabV') || ...
            strcmp(getenv('username'),'Purkinje') || ...
            strcmp(getenv('username'),'JuanandKimi') || ...
            strcmp(getenv('username'),'vp35')
        directory = 'C:\Data\Recordings\';
        user='generic';
    elseif strcmp(getenv('username'),'DangerZone')
        directory = 'E:\data\Recordings\';
        user='Vincent';
        dbldir = 'E:\JDBC';
        mapddataf='vincedata';
    elseif strcmp(getenv('username'),'Radu')
        directory = 'E:\Spike_Sorting\';
        user='Radu';
    elseif strcmp(getenv('username'),'The Doctor')
        directory = 'C:\Users\The Doctor\Data\';
        user='generic';
    else strcmp(getenv('username'),'Vincent')
        directory = 'D:\data\Recordings\';
        user='Vincent';
        dbldir = 'D:\JDBC';
        mapddataf='vincedata';
    end
    slash = '\';
    
    %find if one or more remote drives are mapped
    [~,connlist]=system('net use');
    if logical(regexp(connlist,'OK'))
        %in case multiple mapped drives, add some code here
        carrets=regexpi(connlist,'\r\n|\n|\r');
        if ~length(regexp(connlist,':','start'))
            disp('connect remote drive to place files on server')
        elseif length(regexp(connlist,':','start'))==1
            servrep=connlist(regexp(connlist,':','start')-1:carrets(find(carrets>regexp(connlist,':','start'),1))-1);
            servrep=regexprep(servrep,'[^\w\\|.|:|-'']','');
            mapdr=servrep(1:2);servrep=servrep(3:end);servrep=regexprep(servrep,'\\','/');
        elseif length(regexp(connlist,':','start'))>=2
            servs=regexp(connlist,':','start')-1;
            for servl=1:length(servs)
                if logical(strfind(regexprep(connlist(servs(servl):carrets(find(carrets>servs(servl),1))-1),'[^\w\\|.|:|-'']',''),...
                'ccn-sommerserv.win.duke.edu'))
                    servrep=regexprep(connlist(servs(servl):carrets(find(carrets>servs(servl),1))-1),'[^\w\\|.|:|-'']','');
                    mapdr=servrep(1:2);servrep=servrep(3:end);servrep=regexprep(servrep,'\\','/');
                    break;
                end
            end
        end
    else 
        [servrep,mapdr]=deal([]); 
    end
end