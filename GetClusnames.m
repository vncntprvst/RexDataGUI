function clusnames = GetClusnames(input_args)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
global allspk_clus directory slash;
comments = false;
try
    if strcmp(input_args(1),'S')                     
        fhandle = fopen([directory 'Sixx' slash 'Spike2Exports' slash input_args(1:end-4) 'n.txt']);
    elseif strcmp(input_args(1),'R')
        fhandle = fopen([directory 'Rigel' slash 'Spike2Exports' slash input_args(1:end-4) 'n.txt']);
    elseif strcmp(input_args(1),'H')
        fhandle = fopen([directory 'Hilda' slash 'Spike2Exports' slash input_args(1:end-4) 'n.txt']);
    end
    comments = true;
catch
    comments = false;
end
if comments
    a = 1;
    clusnames{a} = fgetl(fhandle);
    while ischar(clusnames{a})
        a = a+1;
        clusnames{a} = fgetl(fhandle);
    end
    clusnames{a} = [];
else
    b = []; % count non empty allspk_clus entries
    for a = 1:length(allspk_clus)
        if nansum(nansum(allspk_clus{a}))
            b = [b a];
        end
    end
    clusnames = cell(1,length(b));
    for a = 1:length(b)
        clusnames{a} = num2str(b(a));
    end
end
end

