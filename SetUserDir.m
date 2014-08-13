%find user, directory and slash type

function [directory,slash,user,dbdir]=SetUserDir

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
        dbdir = 'E:\JDBC';
        user='Vincent';
    elseif strcmp(getenv('username'),'Radu')
        directory = 'E:\Spike_Sorting\';
        user='Radu';
    elseif strcmp(getenv('username'),'The Doctor')
        directory = 'C:\Users\The Doctor\Data\';
        user='generic';
    else strcmp(getenv('username'),'Vincent')
        directory = 'B:\data\Recordings\';
        user='Vincent';
    end
    slash = '\';
end