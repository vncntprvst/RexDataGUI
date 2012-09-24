% Data clinic
function allcodes=dataclinic(cure,firstarg,secarg)

%% check, and if necessary, fix wrong directions ecodes in countermanding task
if strcmp(cure,'fixdircs') || strcmp(cure,'fixdirol')
    
    if strcmp(cure,'fixdircs')
        % (the issue appears when using negative x values for tab3)
        % treatedfile='S121L4A5_13091.mat';
        % load(treatedfile);
        allcodes=firstarg;
        saccadeInfo=secarg;
        basecode=6040;
    elseif strcmp(cure,'fixdirol')
        load(firstarg);
        %         allcodes=firstarg;
        %         saccadeInfo=secarg;
        basecode=6010;
%         optilocstruct=[
%           28          28        6011
%           40           0        6012
%           28         -28        6013
%           84          84        6011
%          120           0        6012
%           84         -84        6013
%          140         140        6011
%          200           0        6012
%          140        -140        6013]; %6011=TR; 6012=SR; 6013=BR
    end
    
    alldirs=reshape({saccadeInfo.direction},size(saccadeInfo)); % all directions found in saccadeInfo
    alldirs=alldirs'; %needs to be transposed because the logical indexing below will be done column by column, not row by row
    allgoodsacs=~cellfun('isempty',reshape({saccadeInfo.latency},size(saccadeInfo)));
    %removing stop trials that may be included
    allgoodsacs(floor(allcodes(:,2)./1000)~=6,:)=0;
    %indexing good sac trials
        % if saccade detection corrected, there may two 'good' saccades
        if max(sum(allgoodsacs,2))>1
            twogoods=find(sum(allgoodsacs,2)>1);
            for dblsac=1:length(twogoods)
                allgoodsacs(twogoods(dblsac),find(allgoodsacs(twogoods(dblsac),:),1))=0;
            end
        end
    goodsacindex=logical(sum(allgoodsacs,2));
    %translate ecodes into directions
    goodsactrialecodes=allcodes(goodsacindex,:);
    %getting basecode
    gsacbasecode=goodsactrialecodes(:,2);
    %getting all good directions
    allgooddirs=cell2mat(alldirs(allgoodsacs'));
    
    % convert codes to directions (going anticlockwise because codes are
    % inverted left-right)
    gsacbcodeangle=nan(size(gsacbasecode));
        if strcmp(cure,'fixdircs')
            gsacbcodeangle(gsacbasecode-basecode==0)=0;
            gsacbcodeangle(gsacbasecode-basecode==7)=45;
            gsacbcodeangle(gsacbasecode-basecode==6)=90;
            gsacbcodeangle(gsacbasecode-basecode==5)=135;
            gsacbcodeangle(gsacbasecode-basecode==4)=180;
            gsacbcodeangle(gsacbasecode-basecode==3)=225;
            gsacbcodeangle(gsacbasecode-basecode==2)=270;
            gsacbcodeangle(gsacbasecode-basecode==1)=315;
        elseif strcmp(cure,'fixdirol')
            gsacbcodeangle(gsacbasecode-basecode==1)=45;
            gsacbcodeangle(gsacbasecode-basecode==2)=90;
            gsacbcodeangle(gsacbasecode-basecode==3)=135;
        end
    
    % compare code angle with actual saccade direction
    anglediff=allgooddirs-gsacbcodeangle;
    
    anglediff(anglediff<45)
    
    % find out range of wrong trials
    trialq=find(goodsacindex);
    wrongdircode=abs(anglediff)>45; %indexing in good saccade trials
    %wrongconditions=max(bwlabel(wrongdircode)); %should hopefully be one at most. Although, if bad conditions are contiguous, it will not be detected here
    wrongdircode=trialq(find(wrongdircode,1)); % first wrong trial in all trials
    % wrong direction digit
    if allcodes(wrongdircode,2)-basecode>4
        wrgdirdg=[allcodes(wrongdircode,2)-basecode allcodes(wrongdircode,2)-6044];
    else
        wrgdirdg=[allcodes(wrongdircode,2)-basecode allcodes(wrongdircode,2)-6036];
    end
    
    %find if stop trials before, and if yes, if wrong direction too
    
    % foo=allcodes;
    %foo(wrongdircode-4:wrongdircode-1,2)=4075;
    if ~isempty(wrongdircode)
        firstwrongcode=wrongdircode;
        while floor(allcodes(firstwrongcode-1,2)/10)==407 && firstwrongcode~=1
            firstwrongcode=firstwrongcode-1;
        end
        if firstwrongcode~=1 || (firstwrongcode==1 && wrongdircode==firstwrongcode) %otherwise it means there's no way to differentiate previous condition
            % testing direction of potential wrong dir stop trials
            while ~(allcodes(firstwrongcode,2)-4070==wrgdirdg(1) || allcodes(firstwrongcode,2)-4070==wrgdirdg(2)) && firstwrongcode~=wrongdircode
                firstwrongcode=firstwrongcode+1;
            end
        end
        if floor(allcodes(firstwrongcode,2)/10)==407 && max(allcodes(firstwrongcode-1,2)-basecode==wrgdirdg)
            firstwrongcode=firstwrongcode+1; %just to be conservative
        end
        % same story for last wrong trial
        wrongdircode=abs(anglediff)>45; %re-indexing
        %wrongconditions=max(bwlabel(wrongdircode)); %should hopefully be one at most. Although, if bad conditions are contiguous, it will not be detected here
        wrongdircode=trialq(find(wrongdircode,1,'last'));
        lastwrongcode=wrongdircode;
        %foo(wrongdircode+1:wrongdircode+4,2)=4072;
        while floor(allcodes(lastwrongcode+1,2)/10)==407 && lastwrongcode~=size(allcodes,1)
            lastwrongcode=lastwrongcode+1;
        end
        if (lastwrongcode~=size(allcodes,1) || (lastwrongcode==size(allcodes,1) && wrongdircode==lastwrongcode))
            % testing direction of potential wrong dir stop trials
            while ~(allcodes(lastwrongcode,2)-4070==wrgdirdg(1) || allcodes(lastwrongcode,2)-4070==wrgdirdg(2)) && lastwrongcode~=wrongdircode
                lastwrongcode=lastwrongcode+1;
            end
        end
        if floor(allcodes(lastwrongcode,2)/10)==407 && max(allcodes(lastwrongcode+1,2)-basecode==wrgdirdg)
            lastwrongcode=lastwrongcode-1; % same conservative principle
        end
        
        % now find the correct code direction
        wrongdircode=abs(anglediff)>45; %re-re-indexing
        gooddirs=allgooddirs(wrongdircode);
        [~,gooddirlim]=hist(gooddirs,2);
        gooddirlowval=ceil(median(gooddirs(gooddirs<gooddirlim(1))));
        gooddirupval=ceil(median(gooddirs(gooddirs>gooddirlim(2))));
        allanglecodes=[0 45 90 135 180 225 270 315];
        alldirscode=[0 7 6 5 4 3 2 1]; % counterclockwise to replicate leftward inversion
        % "absolute" correct directions
        % gooddirlowval=allanglecodes(abs(gooddirlowval-allanglecodes)==min(abs(gooddirlowval-allanglecodes)));
        % gooddirupval=allanglecodes(abs(gooddirupval-allanglecodes)==min(abs(gooddirupval-allanglecodes)));
        % corresponding ecode direction
        gooddirfirstvalcode=alldirscode(abs(gooddirlowval-allanglecodes)==min(abs(gooddirlowval-allanglecodes)));
        gooddirsecvalcode=alldirscode(abs(gooddirupval-allanglecodes)==min(abs(gooddirupval-allanglecodes)));
        %find the corresponding wrong dir
        firstwrongdirvalcode=goodsactrialecodes(find(wrongdircode,1),2)-floor(goodsactrialecodes(find(wrongdircode,1),2)/10)*10;
        if allgooddirs(find(wrongdircode,1))<gooddirlim(1);
            wrongdirfirstvalcode=firstwrongdirvalcode;
            if firstwrongdirvalcode<4
                wrongdirsecvalcode=firstwrongdirvalcode+4;
            else
                wrongdirsecvalcode=firstwrongdirvalcode-4;
            end
        else
            if firstwrongdirvalcode<4
                wrongdirfirstvalcode=firstwrongdirvalcode+4;
            else
                wrongdirfirstvalcode=firstwrongdirvalcode-4;
            end
            wrongdirsecvalcode=firstwrongdirvalcode;
        end
        
        % then replace values in allcodes
        rangewtrials=firstwrongcode:lastwrongcode;
        for wtr=1:length(rangewtrials)
            wtrdir=allcodes(rangewtrials(wtr),2)-floor(allcodes(rangewtrials(wtr),2)/10)*10;
            if wtrdir==wrongdirfirstvalcode
                replacedir=gooddirfirstvalcode;
            else
                replacedir=gooddirsecvalcode;
            end
            trbasecd=floor((allcodes(rangewtrials(wtr),2))/10)*10;
            findwrcd=trbasecd+wtrdir;
            while logical(sum(find(allcodes(rangewtrials(wtr),:)==findwrcd)))
                allcodes(rangewtrials(wtr),find(allcodes(rangewtrials(wtr),:)==findwrcd))=...
                    floor(findwrcd/10)*10+replacedir;
                findwrcd=findwrcd+200; % next ecode in line
            end
        end
        
        %save allcodes in file
        % corecdata=matfile(treatedfile);
        % corecdata.Properties.Writable = true;
        % corecdata.allcodes=allcodes;
    end
    
    
    %% individual trial tests
    % trialw=233;
    % trialq=find(goodsacindex);
    % trialq=trialq(trialw);
    % %trialq=104;
    % trialgsac(1)=saccadeInfo(trialq,find(allgoodsacs(trialq,:))).starttime;
    % trialgsac(2)=saccadeInfo(trialq,find(allgoodsacs(trialq,:))).endtime;
    
    % % double check what was done in find_saccade_3
    %     % getting amplitudes
    %     checkamp=saccadeInfo(trialq,find(allgoodsacs(trialq,:))).amplitude;
    %     sacamp=sqrt((allh(trialq,trialgsac(2))-allh(trialq,trialgsac(1)))^2 + ...
    %                     (allv(trialq,trialgsac(2))-allv(trialq,trialgsac(1)))^2);
    %     % getting angle
    %     sacdeg=abs(atand((allh(trialq,trialgsac(2))-allh(trialq,trialgsac(1)))/(allv(trialq,trialgsac(2))-allv(trialq,trialgsac(1)))));
    %
    %     % sign adjustements
    %         if allv(trialq,trialgsac(2))<allv(trialq,trialgsac(1)) % vertical flip
    %             sacdeg=180-sacdeg;
    %         end
    %
    %         if allh(trialq,trialgsac(2))>allh(trialq,trialgsac(1))% inverted signal: leftward is in postive range.
    %                                                           % Correcting to negative.
    %         sacamp=-sacamp;
    %         sacdeg=360-sacdeg; % mirror image;
    %         end
    %
    %
    %     %comparisons
    %     ampdiff=sacamp-checkamp
    %     angldiff=sacdeg-gsacbcodeangle(trialw)
    %
    %     figure(21)
    %     plot(allh(trialq,trialgsac(1):trialgsac(2)));
    %     hold on;
    %     plot(allv(trialq,trialgsac(1):trialgsac(2)),'r');
    %     hold off
end

end
%% access outliers and mismatch
