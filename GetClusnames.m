function clusnames = GetClusnames( input_args )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
global allspk_clus;
clusnames = cell(1,length(allspk_clus));
for a = 1:length(allspk_clus)
    clusnames{a} = num2str(a);
end

end

