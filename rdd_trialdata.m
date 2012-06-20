function [] = rdd_trialdata(rdd_filename, trialnumber, reload)

%%former rdt_displaytrial
% changed to accomodate new GUI, 02/2012
%% new analysis, VP 08/2011 - 01/2012, mostly outsourced to rex_process. See ackowledgements there.

%%
% %global rdt_nt;
% global rdt_badtrial;
% global rdt_fh;
% global rdt_trialnumber;
% global rdt_filename;
% global rdt_ecodes;
% global rdt_etimes;
% global rdt_includeaborted;
% %global filtvel;
% %global ecodeout etimeout spkchan spk arate h v start_time eddhv;
% %global noiseIdx nativevel nativeacc;
% %global rdt_trialnumber filtvel filtacc velPeakIdx minwidth minfixwidth saccadeVelocityTreshold peakDetectionThreshold filth filtv;
% %global finalsacs finalsace;
%global sessiondata;
%global nwsacstart nwsacend;

%   ecodeout - a list of the rex codes for the trial
%   etimeout - a list of the times at which those codes occur
%   spkchan - I think this is the id number of neural data channels.  All of
%         code at present assumes only one channel. For one channel, spkchan=610
%   spk - an array of spike times as established by MEX.  See also
%         rex_rasters_trialtype() and rex_spk2raster().
%   arate - sampling rate (e.g. 1000 for 1kHz )
%   h - the horizontal eye movement trace for the trial
%   v - the vertical eye movement trace for the trial
%   start_time - Already accounted for when adjusting the
%         values for etimeout. 
%   badtrial - is this a bad trial (marked BAD or ABORTED)
    
if nargin<3
    reload=0;
end

[ecodeout, etimeout, spkchan, spk, arate, h, v, start_time, badtrial, curtrialsacInfo] = rdd_rex_trial(rdd_filename, trialnumber, reload);%, rdt_includeaborted);

    clear noiseIdx ssacbound esacbound last; %newsacstartposition newsacendposition
    
    rdt_ecodes = ecodeout;
    rdt_etimes = etimeout;
%%   
    hcolor = 'b';
    vcolor = 'r';
    scolor = 'g';
    nscolor = 'm';
    
    if isempty(h) || isempty(ecodeout)
        disp( 'Something wrong with trial, no data.' );
    else
        secondcode = ecodeout(2);
        s = sprintf( '%s trial #%d, code is %d.', rdd_filename, trialnumber, secondcode );
        if badtrial
            s= cat( 2, s, '  BAD TRIAL' );
            hcolor = 'k';
            vcolor = 'k';
            scolor = 'y';
        end;

%         edhv = sqrt( (h .* h) + (v .* v ) );
%         dedhv = diff( edhv );


%% get saccade times from processed file (see rex_process)
%[sstarts, sends] = rex_trial_saccade_times( rdd_filename, trialnumber);%, rdt_includeaborted );  


   % discontinuing old method     
%         gunk = h .* 0;
%         if ~isempty( sstarts )
%             for d = 1:length( sstarts )
%                 if sstarts(d) == 0 || sends( d ) == 0
%                  %d
%                  %sstarts( d )
%                  %sends( d )
%                 else
%                 gunk( sstarts(d):sends(d) ) = 20;
%                 end;
%             end;
%         end;
%         
  % and getting tsame info but with new method for saccade detection (also
  % see rex_process)
  
  nwsacstart=cat(1,curtrialsacInfo.starttime);
  nwsacend=cat(1,curtrialsacInfo.endtime);
   
   % a little formatting for later use, same as above
        grime = h .* 0;
        if ~isempty( nwsacstart )
            for d = 1:length( nwsacstart )
            grime( nwsacstart(d):nwsacend(d) ) = 20;
            end;
        end;
  


%% Some not so important vestigial code, could be replaced or eventually discarded
        lasttime = max( etimeout );
        last = max( lasttime, length( h ) );
        codetrain = zeros( 1, last );
        ettemp = etimeout;
        ettemp(ettemp < 1) = 1; % local indexing faster than find
        codetrain( ettemp ) = ecodeout;
        
        eddhv = sqrt( ( diff( h ) .* diff( h ) ) + ( diff( v ) .* diff( v ) ) ); % had to add it, find_saccades didn't want to transfer ederiv's value properly
        
%% Ecode selector based on task type.
        curtasktype=get(findobj('Tag','taskdisplay'),'String');
        % need to fuse taskdetect and taskfindecode at some point
        [tasktype, ecodecueon, ecodesacstart, ecodesacend]=taskdetect(ecodeout, curtasktype); 

            % if it's gapstop, ecode 8 is stopcode=507Y, and
            % ecode 9 is 1025 FPOFFCD , ecode 10 REWCD, etc ...
        
        wide = max( [length(eddhv) length(codetrain) length(h)] );
        
        
%% some redux version of noise detection code (already done in rex_process)

% Calculate velocity and acceleration

minwidth = 5;
[filth, filtv, filtvel, filtacc, nativevel, nativeacc] = cal_velacc(h,v,minwidth);

% Detect noise

VelocityThreshold = 1.5;     %peak velocity is almost never more than 1000deg/s, so if vel > 1.5 deg/ms, it is noise (or blinks for eye tracker)
AccThreshold = 0.1;          %if acc > 100000 degrees/s^2, that is 0.1 deg/ms^2, it is noise (or blinks)

    noisebg= median(nativevel)*2;
    
    % Detect possible noise (if the eyes move too fast)
    noiseIdx = nativevel> VelocityThreshold | abs(filtacc) > AccThreshold;
    %label groups of noisy data
    noiselabels = bwlabel(noiseIdx);
    
    % Process one noise period at the time
    for k = 1:max(noiselabels)

        % The samples related to the current event
        noisyperiod = find(noiselabels == k);

        % Go back in time to see where the noise started
        sEventIdx = find(nativevel(noisyperiod(1):-1:1) <= noisebg);
        if isempty(sEventIdx), continue, end
        sEventIdx = noisyperiod(1) - sEventIdx(1) + 1;
        noiseIdx(sEventIdx:noisyperiod(1)) = 1;      

        % Go forward in time to see where the noise ended    
        eEventIdx = find(nativevel(noisyperiod(end):end) <= noisebg);
        if isempty(eEventIdx), continue, end    
        eEventIdx = (noisyperiod(end) + eEventIdx(1) - 1);
        noiseIdx(noisyperiod(end):eEventIdx) = 1;

    end

    % possible correction already done in rex_process
     noiselabels = bwlabel(noiseIdx);
     str = sprintf('%d remaining noise periods in trial #%d', max(noiselabels), trialnumber);
     disp(str);

        if logical(sum(noiseIdx))
        snoisearea = find(diff(noiseIdx) > 0);
        enoisearea = find(diff(noiseIdx) < 0);
        if isempty(snoisearea) || snoisearea(1) > enoisearea(1) % plot is shaded from start
            snoisearea = [1 snoisearea];
        end
        if isempty(enoisearea) || snoisearea(end) > enoisearea(end) % plot is shaded until end
            enoisearea = [enoisearea length(noiseIdx)];
        end
        end
    
   
% Implicitly detect fixations
%----------------------------
        % to be written if needed

       
%% caveat for wrong trials: ecodes times do not fit with eye position timeline after trial abort time
        %two condition: first is standard error, second is for early
        %saccade error
        if logical(sum(find(ecodeout==17385))) || logical(sum(etimeout(ecodesacstart)>length(h)))  
            str = sprintf('bad trial # %d or data. Adjusting trial to recorded eye position',trialnumber);
            disp(str);
            wide = max( [length(eddhv) length(h)] );
            errtrial=1; % partly redundant with badtrial but more inclusive
        	%if find(ecodeout==16386)    %that would be for the second condition above
            %end                          %16386 is error code for early
                                        %saccade in st_sac
                                        
                                                        
        else % if correct trial, proceed
            
                    errtrial=0;   

        %% crop timeframe to display only portion relevant to saccade for subplot 2
        % also doing important search for saccade time based on the
        % accurate saccade detection methode
        
            %ssacbound=etimeout(ecodesacstart)-200; %used to be framed by saccade ecodes
                                                    %but turned out to be wrong
                                                    
            if strcmp(tasktype,'tokens')
                sacofint=nwsacstart>etimeout(ecodesacstart)-40; % the token task is special 
                              % in that we do not detect the saccade itself, but the eye leaving
                              % the fixation window. The small delay (40ms) reflects that
                
                %  a little bit of housekeeping to set anticipated saccades (ie, before second token) as bad trial
%                     if length(ecodecueon)>=2 &&  nwsacstart(find(sacofint,1))<etimeout(ecodecueon(2))
%                     recfile=matfile(rdd_filename);
%                     recfile.Properties.Writable = true;
%                     recfile.allbad(1,trialnumber)=1;
%                     errtrial=1;
%                     end
            
            else
                sacofint=nwsacstart>etimeout(ecodesacstart-1); %considering all saccades occuring after the ecode
            end
            for k=find(sacofint,1,'first'):length(sacofint)%preceding the saccade ecode, which is often erroneous
                ampsacofint(1,k)=abs(getfield(curtrialsacInfo, {k}, 'amplitude'));
            end       
            
            if strcmp(tasktype,'gapstop') && (floor(ecodeout(2)./10))*10==4070 && ~exist('ampsacofint')
            % stop trial, might not have saccades at all
            ampsacofint=0;
            end            
            
            %start time of first saccade greater than 3 degrees (typical
            %restriction window) after relevant ecode (ecodesacstart-1)
            if logical(sum(ampsacofint>3))
            mainsacs=getfield(curtrialsacInfo, {find(ampsacofint>3,1,'first')}, 'starttime');
            %end time of that saccade
            mainsace=getfield(curtrialsacInfo, {find(ampsacofint>3,1,'first')}, 'endtime');
                        
            %define boundaries for cropped display based on this saccade
            ssacbound=mainsacs-200;
                if ssacbound<1
                    ssacbound=1;
                end
            esacbound=mainsace+200;
                if esacbound>length(h) %|| esacbound <= ssacbound %obsolete condition
                    esacbound=length(h);    
                end 
            else % else, it is a correct trial whithout significant saccade. 
                    %Either it's a countermanding task, or there was a real
                    %saccade just after the one detected here, which is
                    %more a glissade %now correctd in find_saccade_3
                ssacbound=etimeout(ecodesacstart)-200;
                esacbound=etimeout(ecodesacend)+200;
            end
            
                newh=h(ssacbound:esacbound);
                newv=v(ssacbound:esacbound);
                neweddhv=eddhv(ssacbound:esacbound-1);
                newcodetrain=codetrain(ssacbound:esacbound);
                %old method's data
%                 newgunk=gunk(ssacbound:esacbound);
%                 newgunks = find(diff(newgunk) > 0);
%                 newgunke = find(diff(newgunk) < 0);
%                 if length(newgunks)> length(newgunke) % because end saccade may be cut in the focus window
%                     newgunks=newgunks(1:length(newgunke));
%                 end
%                 if length(newgunke)> length(newgunks) % reciprocal, although unlikely
%                     newgunke=newgunke(length(newgunke)-length(newgunks)+1:length(newgunke));
%                 end
                %new method's data
                newgrime=grime(ssacbound:esacbound);
                newgrimes = find(diff(newgrime) > 0);
                newgrimee = find(diff(newgrime) < 0);
                if length(newgrimes)> length(newgrimee) % because end saccade may be cut in the focus window
                    newgrimes=newgrimes(1:length(newgrimee));
                end
                if length(newgrimee)> length(newgrimes) % reciprocal, although unlikely
                    newgrimee=newgrimee(length(newgrimee)-length(newgrimes)+1:length(newgrimee));
                end
                newwide = max( [length( neweddhv ) length( newcodetrain ) length( newh )] );
                %ecode's data
                ecodesactime=etimeout(ecodesacend)-etimeout(ecodesacstart);
                if etimeout(ecodesacstart)>ssacbound && etimeout(ecodesacend)<esacbound
                    newecsacs=etimeout(ecodesacstart)-ssacbound;
                    newecsace=newecsacs+ecodesactime;
                else
                    newecsacs=1;
                    newecsace=1;
                end
                          
           end
               
%%
%%%%%%%%%%%%%%%%%%%%%%%%%% PLOTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% first plot: eye movement traces
        axes(findobj('Tag','fulltrialdata')); 
        cla reset; % deletes from the current axes all graphics objects and resets all axes properties, except Position and Units, to their default values.
        set(gca,'Tag','fulltrialdata');
        % a few cosmetic preparation
        timeline=1:1:length(noiseIdx);
        if ~errtrial %if trial aborted, cut display to recorded eye position's duration
            newtl=1:1:newwide;
        end
        %xlim([timeline(1) timeline(end)]);% force plot to go from edge to edge
%         padding = 5/100*(max(v)-min(v));% spacing at top and bottom of plotted line
%         ylim([min(v)-padding max(v)+padding]); % default leaves too much space around graph
        % plot noise period with shaded regions (original code is from ShadePlotForEmphasis.m by
        % Michael Robbins on Matlab Central).
        hold all %very important :)
        plot(h, hcolor );  
            %set(gca,'ColorOrder',[1 0 0;0 1 0]);
            %eyeposlines=line(h,v,'LineWidth',2);
        
        if logical(sum(noiseIdx)) %if there are noise period remaining, display them here
            disp('displaying noise period(s)');
            for j = 1:length(snoisearea)
                patch([repmat(timeline(snoisearea(j)),1,2) repmat(timeline(enoisearea(j)),1,2)], ...
                [get(gca,'YLim') fliplr(get(gca,'YLim'))], ...
                [0 0 0 0],[1 0 0],'EdgeColor','none','FaceAlpha',0.5);
            end
        end
        set(gca, 'layer', 'top'); % put ticks back on top of colour patch
        %title( s );
        plot(v, vcolor );
       % plot(gunk, scolor );
                
        scatter(nwsacstart,5.*ones(1,length(nwsacstart)),'g','d');
        scatter(nwsacend,5.*ones(1,length(nwsacend)),'r','d');
        
        %plot visual cue epoch(s)as shaded areas
        if ecodecueon
        for cuenb = 1:length(ecodecueon)
            cueontime=etimeout(ecodecueon(cuenb));
            cueofftime=cueontime+10;
            patch([repmat(timeline(cueontime),1,2) repmat(timeline(cueofftime),1,2)], ...
            [get(gca,'YLim') fliplr(get(gca,'YLim'))], ...
            [0 0 0 0],[1 0 0],'EdgeColor','none','FaceAlpha',0.3);
        end
        end
        
        hold off;
        ax = axis(gca);     
        ax(2) = wide;   
        axis(ax);
        
%        last = 0;

        
 %% second plot: eye movement traces restricted to saccade
        axes(findobj('Tag','saccadecentered'));
        cla reset;
        set(gca,'Tag','saccadecentered');
        if errtrial
            title( 'bad trial' );
        else
            hold all
            plot(newh, hcolor,'LineWidth',1.5);
            %title( 'Focused on saccade - grey: ecodes, brown: old method, blue: new method' );
            plot(newv, vcolor,'LineWidth',1.5);
            % shading area for ecode saccade detection in grey
            patch([repmat(newtl(newecsacs),1,2) repmat(newtl(newecsace),1,2)], ...
            [get(gca,'YLim') fliplr(get(gca,'YLim'))], ...
            [0 0 0 0],[0 0 0],'EdgeColor','none','FaceAlpha',0.1);
        
            %plot( newgunk, scolor ); % not used anymore
            % shading area for old method saccade detection in brown
%             for j = 1:length(newgunks)
%             patch([repmat(newtl(newgunks(j)),1,2) repmat(newtl(newgunke(j)),1,2)], ...
%             [get(gca,'YLim') fliplr(get(gca,'YLim'))], ...
%             [0 0 0 0],[1 0.7 0],'EdgeColor','none','FaceAlpha',0.3);
%             end    
            
            % shading area for new method saccade detection in blue
            for j = 1:length(newgrimes)
            patch([repmat(newtl(newgrimes(j)),1,2) repmat(newtl(newgrimee(j)),1,2)], ...
            [get(gca,'YLim') fliplr(get(gca,'YLim'))], ...
            [0 0 0 0],[0 0 1],'EdgeColor','none','FaceAlpha',0.3);
            end 
            set(gca, 'layer', 'top');
%            scatter(newsacstartposition(1,:),newsacstartposition(2,:),'k','d');
%            scatter(200,10,'k','^');
%            scatter(newsacendposition(1,:),newsacendposition(2,:),'r','d');
%            scatter(sactimefr-200,10,'r','^');
            hold off;
            ax = axis(gca);
            ax(2) = newwide;
            axis( ax );
    %        last = 0;
        end

 %% third plot: eye velocity (not spikes, there are none for the moment
        %train = [];        
%         subplot( 3, 1, 3 );
%         if ~errtrial
%             plot(neweddhv);
%             ax = axis();
%             ax(2) = newwide;
%             axis( ax );
%             title( 'EYE VELOCITY' );    
%         else
%             title( 'bad trial' );
%             cla;
%         end

    end;
        