function [] = batchstats(InterAxn, FRout, FRfortestB, FRfortestA, FRfortestT);

global hAll

if strcmp(InterAxn, 'TT')
    h1 = ttest2(FRfortestB(1,:), FRfortestB(2,:));
    h2 = ttest2(FRfortestB(3,:), FRfortestB(4,:));
    h3 = ttest2(FRfortestA(1,:), FRfortestA(2,:));
    h4 = ttest2(FRfortestA(3,:), FRfortestA(4,:));
    bigh = [h1 h3; h2 h4];
elseif strcmp(InterAxn, 'Interaction')
    h1 = ttest2(FRfortestB(1,:), FRfortestB(2,:));
    h2 = ttest2(FRfortestB(1,:), FRfortestB(3,:));
    h3 = ttest2(FRfortestB(2,:), FRfortestB(4,:));
    h4 = ttest2(FRfortestB(3,:), FRfortestB(4,:));
    h5 = ttest2(FRfortestA(1,:), FRfortestA(2,:));
    h6 = ttest2(FRfortestA(1,:), FRfortestA(3,:));
    h7 = ttest2(FRfortestA(2,:), FRfortestA(4,:));
    h8 = ttest2(FRfortestA(3,:), FRfortestA(4,:));   
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
    hAll = pAll<0.05;
end