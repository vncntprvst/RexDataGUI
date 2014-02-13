function clusnames = GetClusnames( input_args )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
global allspk_clus;
b = []; % count non empty allspk_clus entries
for a = 1:length(allspk_clus)
    if nansum(nansum(allspk_clus{a}))
        b = [b a];
    end
end
clusnames = cell(1,length(b));
for a = 1:length(b)
    clusnames{a} = b(a);
end
end

