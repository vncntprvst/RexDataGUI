function [] = batchstats(InterAxn, FRout, FRfortestB, FRfortestA, FRfortestT, smallrast);

global hAll

if strcmp(InterAxn, 'TT')
    h1 = ttest2(FRfortestB(1,:), FRfortestB(2,:));
    h2 = ttest2(FRfortestB(3,:), FRfortestB(4,:));
    h3 = ttest2(FRfortestA(1,:), FRfortestA(2,:));
    h4 = ttest2(FRfortestA(3,:), FRfortestA(4,:));
    bigh = [h1 h3; h2 h4];
elseif strcmp(InterAxn, 'Interaction')
    h1 = ttest2(FRfortestB(1,:), FRfortestB(2,:)); % SS0 - SS1
    h2 = ttest2(FRfortestB(1,:), FRfortestB(3,:)); % SS0 - IN0
    h3 = ttest2(FRfortestB(2,:), FRfortestB(4,:)); % SS1 - IN1
    h4 = ttest2(FRfortestB(3,:), FRfortestB(4,:)); % IN0 - IN1
    h5 = ttest2(FRfortestA(1,:), FRfortestA(2,:));
    h6 = ttest2(FRfortestA(1,:), FRfortestA(3,:));
    h7 = ttest2(FRfortestA(2,:), FRfortestA(4,:));
    h8 = ttest2(FRfortestA(3,:), FRfortestA(4,:));   
    h9 = ttest2(FRfortestT(1,:), FRfortestT(2,:));
    h10 = ttest2(FRfortestT(1,:), FRfortestT(3,:));
    h11 = ttest2(FRfortestT(2,:), FRfortestT(4,:));
    h12 = ttest2(FRfortestT(3,:), FRfortestT(4,:)); 
    bigh = [h1 h5; h2 h6; h3 h7; h4 h8];
    % anova
    FRvecB = [FRfortestB(1,:) FRfortestB(2,:) FRfortestB(3,:) FRfortestB(4,:)]; %put into vector
    FRvecB = FRvecB(isfinite(FRvecB)); % remove NaNs from cat_variable_size_row
    FRvecA = [FRfortestA(1,:) FRfortestA(2,:) FRfortestA(3,:) FRfortestA(4,:)]; %put into vector
    FRvecA = FRvecA(isfinite(FRvecA));
    FRvecT = [FRfortestT(1,:) FRfortestT(2,:) FRfortestT(3,:) FRfortestT(4,:)]; %put into vector
    FRvecT = FRvecT(isfinite(FRvecT));
    TT = [0.*ones(1,FRout(1,3)) 0.*ones(1,FRout(2,3)) 1.*ones(1,FRout(3,3)) 1.*ones(1,FRout(4,3))];
    RR = [0.*ones(1,FRout(1,3)) 1.*ones(1,FRout(2,3)) 0.*ones(1,FRout(3,3)) 1.*ones(1,FRout(4,3))];
    pB = anovan(FRvecB, {TT RR}, 'display', 'off', 'model', 'interaction');
    pA = anovan(FRvecA, {TT RR}, 'display', 'off', 'model', 'interaction');
    pT = anovan(FRvecT, {TT RR}, 'display', 'off', 'model', 'interaction'); 
    pAll = [pB' pA' pT'];
    hAll = pAll;%<0.05;
    %hAll = [h1 h4 h5 h8 h9 h12];
end

lr = 0;
binsize = 50;
if lr==1 && strcmp(InterAxn, 'Interaction');
    nsub = [size(smallrast{1},1) size(smallrast{2},1) size(smallrast{3},1) size(smallrast{4},1)];
    allrastmat = [smallrast{1}; smallrast{2}; smallrast{3}; smallrast{4}];
    nT = size(allrastmat,1); % # of trials
    nL = size(allrastmat,2); % # of timepoints
    nbins = floor(nL/binsize);
    % key is trials x 2. first column is tt (SS=0, IN=1), second column is r
    key = [zeros(1,80) ones(1,80); zeros(1,40) ones(1,40) zeros(1,40) ones(1,40)]';
    % Binning through time
    for b = 1:nbins;
        binned(:,b) = sum(allrastmat(:,(b-1)*binsize+1:b*binsize),2);
    end
    [er ec] = find(binned==0);
    for n=1:nT;
        index = boolean(ones(nT,1));
        index(n) = false;
        shortrast = binned(index,:);
        shortkey = key(index,:);
        B = mnrfit(shortrast,shortkey);
        pihat = mnrval(B,binned(n,:));
    end
end
