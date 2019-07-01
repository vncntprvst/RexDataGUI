function [success] = load_REXfile( rexmatname )

global allcodes alltimes allspkchan allspk allspk_clus allrates ...
        allh allv allstart allbad saccadeInfo;
    
global sessiondata rexloadedname rexnumtrials;


baseDir='E:\Data\Recordings\processed';
if strcmp(rexmatname(1),'R')
    dirName=[baseDir filesep 'Rigel'];
elseif strcmp(rexmatname(1),'S')
    dirName=[baseDir filesep 'Sixx'];
elseif strcmp(rexmatname(1),'H')
    dirName=[baseDir filesep 'Hilda'];
end

try 
load( [dirName filesep rexmatname]);
success=true;
if ~strcmp(regexp(rexmatname,'\w+$', 'match'),'mat') 
    rexloadedname=rexmatname;
else % should always be that way
    rexloadedname=rexmatname(1:end-4);
end
catch
    return;
end

