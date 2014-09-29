function clusnames = GetClusnames(input_args)
%GetClusnames Summary of this function goes here
%   Detailed explanation goes here
if strcmp(input_args(end-2:end),'REX')
    clusnames = {'1',' '};
else    
    global allspk_clus directory slash;
    comments = false; % is there an "n" file with names and notes for the clusters?
    if strcmp(input_args(1),'S')
        fhandle = fopen([directory 'Sixx' slash 'Spike2Exports' slash input_args(1:end-4) 'n.txt']);
    elseif strcmp(input_args(1),'R')
        fhandle = fopen([directory 'Rigel' slash 'Spike2Exports' slash input_args(1:end-4) 'n.txt']);
    elseif strcmp(input_args(1),'H')
        fhandle = fopen([directory 'Hilda' slash 'Spike2Exports' slash input_args(1:end-4) 'n.txt']);
    end
    if fhandle ~= -1
        comments = true;
    end
    if comments
        clusidx = 1;
        clusnames{clusidx} = fgetl(fhandle);
        while ischar(clusnames{clusidx})
            clusidx = clusidx+1;
            clusnames{clusidx} = fgetl(fhandle);
        end
        clusnames{clusidx} = [];
        fclose(fhandle);
    else
        nzent = []; % count non empty allspk_clus entries
        for clusidx = 1:length(allspk_clus)
            if nansum(nansum(allspk_clus{clusidx}))
                nzent = [nzent clusidx];
            end
        end
        clusnames = cell(1,length(nzent));
        for clusidx = 1:length(nzent)
            clusnames{clusidx} = num2str(nzent(clusidx));
        end
    end
end
end

