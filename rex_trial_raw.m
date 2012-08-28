function [ecodeout, etimeout, spkchan, spk, arate, h, v, start_time, badtrial, analog_time] =...
    rex_trial_raw(name, trial, includeaborted)

% function [ecodeout, etimeout, spkchan, spk, arate, h, v, start_time] =
%       rex_trial_raw(name, trial, atrace)
% 
% returns data from REX afile and efile for a given trial.
% name is the file name root (sans A or E), trial is the
% desired trial number, and atrace (optional) selects which
% analog channel to return (default = first channel)
% by James Cavanaugh 2001
% 
% Alteration, Robin C. Ashmore, 2008
% For some reason the Rex data files put down their -112 codes in a 
% funny place.  JC's code assumes that each trial start (1001) is 
% followed somewhere by a -112 code that gives info on where to find the analog
% data that matches the trial (starting at the 1001).  However, in the
% files I tested, the -112 code (and the time for that code stored in
% etimes) for the current trial is stored after the NEXT 1001 appears
% (after the 1001 indicating the start of the next trial).  What gives?
% But with the changes added here, the output matches what is seen
% in DEX.
%
% Robin C. Ashmore, February 2010
% Yeah, but only in some cases.  As a cludge for now, there are two
% processing modes that seem to cover all Rex data file cases.  Which is
% used depends on the value returned by rex_processing_mode.m.  See that
% file and comments below for more details.  If one mode doesn't work, try
% the other one by changing what rex_processing_mode.m returns.



persistent s2l;
persistent sa2la;
persistent currecodename;
persistent ecodes;
persistent etimes;
persistent trialstarttimes;
persistent trialendtimes;
persistent arecs;

NULL = 32768;  % -1 signed int
BADCODE = 17385;

badtrial = 0;
badtt = 0;

%% short to long conversions
if isempty(sa2la)
	bitlen = '8';
	mult = eval(['2^',bitlen]);
	mult = num2str(mult);
	stype = 'uint';
	s2l = inline(['double(',stype,bitlen,'(s(1)))+',mult,'*double(',stype,bitlen,'(s(2)))'],'s');
	sa2la = inline(['double(',stype,bitlen,'(s(:,1)))+',mult,'.*double(',stype,bitlen,'(s(:,2)))'],'s');
end;

if nargin < 3
	includeaborted = 1;
end;
if nargin < 2
	trial = 1;
end;


%% grab all the ecodes
ecname = [name,'_ecodes'];
etname = [name,'_etimes'];

if ~strcmp(currecodename, ecname)
	currecodename = ecname;
    
	arecs = rex_arecs(name);
	[ecodes, etimes] = rex_ecodes(name);
	
	% trial start and ends
	trialstart = find(ecodes == 1001);
	
	lastevent = length(ecodes);
	trialend = [trialstart(2:end);lastevent];
	
	numtrials = length(trialstart);

    %  Ok, now remove bad trials if we're supposed to.
   
    if ~includeaborted
        nobadtrialnum = 1;
        for d=1:numtrials
            nextcodes = ecodes( trialstart(d):trialend(d) );
            fbad = find( nextcodes == BADCODE );
            if isempty( fbad )
                nobadtrialstart( nobadtrialnum ) = trialstart( d );
                nobadtrialend( nobadtrialnum ) = trialend(d);
                nobadtrialnum = nobadtrialnum + 1;
%                 disp( 'including good trial' );
%             else
%                 disp( 'ignoring bad trial' );
            end;
        end;
        trialstart = nobadtrialstart;
        trialend = nobadtrialend;
        numtrials = length( trialstart );
    end;               
        
   	trialtimes = etimes(trialstart);
 
    
%RCA - DON'T remove bad trials here.    
% 	
% 	% remove bad trials
% 	badtrial = find(ecodes == 17385);  % or so I think...
% 	if ~isempty(badtrial)
% 		badtrialtime = etimes(badtrial);
% 		bad = [];
% 		for b = 1:length(badtrial)
% 			bd = max(find(badtrialtime(b) > trialtimes));
% 			bad = [bad;bd];
% 		end;
% 		ok = setxor(bad, (1:numtrials));
% 		trialstart = trialstart(ok);
% 		trialend = trialend(ok);
% 	end;
% 	
	% find last e-record time
	% not sure this is the right way to do it...
	trialstarttimes = etimes(trialstart);
	trialendtimes = etimes(trialend);
    
	
end;

%% indices of start and end of this trial
idx1 = find((ecodes == 1001) & (etimes == trialstarttimes(trial)));
idx2 = find((ecodes == 1001) & (etimes == trialendtimes(trial)));

% RCA - the above line fails for the last trial.
if isempty( idx2 )
    idx2 = length(ecodes);
end;

idx1 = idx1(end);
idx2 = idx2(end);

%% ecodes and times for this trial
currcode = ecodes(idx1:idx2);
currtime = etimes(idx1:idx2);

% 
% for j = 1:length( currcode );
%      s = sprintf( 'trial %d, #%d code is %d at time %d.', trial, j, currcode( j ), currtime( j ) );
%      disp( s );
% end;
% pause;

fbt = find( currcode == BADCODE );
if ~isempty( fbt )
    badtt = currtime( fbt );
    if length(badtt)>1
        % there was a botched trial
        % take a look at currcode>999
        str=sprintf('two error codes found in trial %d',trial);
        disp(str);
        disp('see rex_trial_raw line 160');
    end
end;

%% RCA - This is where it gets funny.
% find analog references, but don't just look at the ones in the 
% current list of codes as in:
% aidx = find(currcode == -112);
% aoffset = currtime(aidx);
% but rather look at all future -112s, and see if one fits the time frame.
aidx = find( ecodes( idx1:end ) == -112 );
temptimes = etimes( idx1:end );
aoffset = temptimes( aidx );


% aidx = find( currcode == -112 );
% aoffset = currtime( aidx );

    
% % RCA - try this instead, look to the NEXT -112 following the next 1001.
% nidx1 = find(ecodes(idx2:end) == -112 );
% 
% if ~isempty(nidx1)
%     aidx = nidx1( 1 );
%     aoffset = etimes( aidx + idx2 - 1 );
% else
%     aidx = [];
% end;
% % RCA - end of my inexplicable code.



%% grab analog data for this trial
adat = [];
foundanalogdata = 0;  % See comment below, 08/27/08.
if ~isempty(aidx)
    % RCA - change the loop so that it will stop when the analog data
    % times get past the trial times.  Since now we're looking at all -112s
    % from this time to the end, this loop could take a looooong time
    % if we don't do this.
    cnt112 = 1;
    ofst = 0;
    atm = 0;
    startofthistrial = currtime( 1 );
    endofthistrial = currtime( end );
    keepgoing = 1;
    timeok = 0;
    continuationdataok = 0;



    if rex_processing_mode()

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        %   Processing Version 1
        %
        %   Rex sometimes puts out files where the code into the analog data is all
        %   messed up and it needs a different algorithm.  If the function
        %   rex_processing_mode() returns 1, it will do this version.  If not, it
        %   will do Processing Version 2.
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%%%%%   Uncomment the first for processing mode 1
        %%%%%%%%%%%%%%%%%%%%%%%%   Reverse for mode 2.

        while (cnt112 <= length( aoffset )) && keepgoing
            %%%while (cnt112 <= length( aoffset )) && (atm < endofthistrial) %-101 )
        try
            [aseq, acd, atm, ausr, acont, adata] = rex_analog(name, aoffset(cnt112));
        catch err_rexanalog
               errmess= regexp(err_rexanalog.identifier,':\w+$','match');
               errmess=['problem at rex_analog',errmess{:}];
               disp(errmess);
            return
        end
            
            % s = sprintf( 'first code time: %d, atm: %d, acont: %d, ofst: %d', startofthistrial, atm, acont, ofst );
            % disp( s );

            % RCA - do these data actually go with this trial?
            % Be sure to include continuation data, where atm comes back 0 but
            % acont is 1.  Only include these after we find the first atm time
            % in this trial (when it's not 0).  We know that's true because
            % we increment ofst when we find that first atm > startofthistrial.

            % RCA 08/27/08 - One thing that seems to happen occasionally is
            % that atm is NEVER between the start and end of this trial, which
            % I guess means that there is no analog data for this trial.  To
            % handle that, I'm inserting a foundanalogdata flag.
            %  pause;
            if (foundanalogdata && atm>0 && ~acont)
                keepgoing = 0;
            end;
            % RCA 01/30/09 - Ok, maybe not.  Assume that the -112s in this trial go to
            % this trial.  Something else might be wrong here, and I don't know why
            % some rex files had -112s in the next trial.  Until I solve this, I'm
            % leaving the possibility of two types of processing.

            %%%%%%%%%%%%%%%  Uncomment the first for processing mode 1.
            %%%%%%%%%%%%%%%  Reverse for mode 2.
            if (atm > 0 && ofst==0)
                %%%if ((atm >= startofthistrial) && (atm < endofthistrial))

                timeok = 1;
                continuationdataok = 1;
            else
                timeok = 0;
            end;
            if timeok || (ofst && acont && continuationdataok )

                % s = sprintf( 'start of trial %d is time %d, end is %d, atm was %d, ofst is %d and acont is %d.', trial, startofthistrial, endofthistrial, atm, ofst, acont );
                %  disp( s );
                %  disp( 'analog data accepted.' );
                %  pause;
                foundanalogdata = 1;
                ofst = ofst + 1;
                if ofst == 1
                    analog_time = atm;
                end;

                % check the returned values
                codeok = (acd == -112);
                contok = (acont == (ofst ~= 1));
                usrok = (ausr == (ofst-1));

                if codeok & usrok & contok
                    adat = [adat; adata(:)];
                else
                    % something wrong - return null data for this trial
                    disp( 'something wrong, returning null data for this trial' );
                    s = sprintf( 'code ok %d     usrok %d     contok %d', codeok, usrok, contok );
                    disp( s );
                    s = sprintf( 'acd=%d     acont=%d     ofst=%d     ausr=%d', acd, acont, ofst, ausr );
                    disp( s );
                    ecodeout = [];
                    etimeout = [];
                    spkchan = [];
                    spk = [];
                    arate = [];
                    h = [];
                    v = [];
                    start_time = [];
                    return;
                end;  % data read were ok
            end;  %RCA - end of time checking condition.
            cnt112 = cnt112 + 1; %RCA - also mine, after removing for loop.
        end;  % looping through afile offsets
        
    else  % The other processing mode.

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        %   Processing Version 2
        %
        %   If the function rex_processing_mode() returns 0, version 2 below 
        %   be done.
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%%%%%   Uncomment the first for processing mode 1
        %%%%%%%%%%%%%%%%%%%%%%%%   Reverse for mode 2.

        %%%while (cnt112 <= length( aoffset )) && keepgoing
        while (cnt112 <= length( aoffset )) && (atm < endofthistrial) %-101 )

            [aseq, acd, atm, ausr, acont, adata] = rex_analog(name, aoffset(cnt112));
            % s = sprintf( 'first code time: %d, atm: %d, acont: %d, ofst: %d', startofthistrial, atm, acont, ofst );
            % disp( s );

            % RCA - do these data actually go with this trial?
            % Be sure to include continuation data, where atm comes back 0 but
            % acont is 1.  Only include these after we find the first atm time
            % in this trial (when it's not 0).  We know that's true because
            % we increment ofst when we find that first atm > startofthistrial.

            % RCA 08/27/08 - One thing that seems to happen occasionally is
            % that atm is NEVER between the start and end of this trial, which
            % I guess means that there is no analog data for this trial.  To
            % handle that, I'm inserting a foundanalogdata flag.
            %  pause;
            if (foundanalogdata && atm>0 && ~acont)
                keepgoing = 0;
            end;
            % RCA 01/30/09 - Ok, maybe not.  Assume that the -112s in this trial go to
            % this trial.  Something else might be wrong here, and I don't know why
            % some rex files had -112s in the next trial.  Until I solve this, I'm
            % leaving the possibility of two types of processing.

            %%%%%%%%%%%%%%%  Uncomment the first for processing mode 1.
            %%%%%%%%%%%%%%%  Reverse for mode 2.
            %%%if (atm > 0 && ofst==0)
            if ((atm >= startofthistrial) && (atm < endofthistrial))

                timeok = 1;
                continuationdataok = 1;
            else
                timeok = 0;
            end;
            if timeok || (ofst && acont && continuationdataok )

                % s = sprintf( 'start of trial %d is time %d, end is %d, atm was %d, ofst is %d and acont is %d.', trial, startofthistrial, endofthistrial, atm, ofst, acont );
                %  disp( s );
                %  disp( 'analog data accepted.' );
                %  pause;
                foundanalogdata = 1;
                ofst = ofst + 1;
                if ofst == 1
                    analog_time = atm;
                end;

                % check the returned values
                codeok = (acd == -112);
                contok = (acont == (ofst ~= 1));
                usrok = (ausr == (ofst-1));

                if codeok & usrok & contok
                    adat = [adat; adata(:)];
                else
                    % something wrong - return null data for this trial
                    disp( 'something wrong, returning null data for this trial' );
                    s = sprintf( 'code ok %d     usrok %d     contok %d', codeok, usrok, contok );
                    disp( s );
                    s = sprintf( 'acd=%d     acont=%d     ofst=%d     ausr=%d', acd, acont, ofst, ausr );
                    disp( s );
                    ecodeout = [];
                    etimeout = [];
                    spkchan = [];
                    spk = [];
                    arate = [];
                    h = [];
                    v = [];
                    start_time = [];
                    return;
                end;  % data read were ok
            end;  %RCA - end of time checking condition.
            cnt112 = cnt112 + 1; %RCA - also mine, after removing for loop.
        end;  % looping through afile offsets
    end;  % if rex_processing_mode()
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %   End of version shenanigans
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    max_samp = arecs.max_samp_rate;
    min_samp = arecs.min_samp_rate;
    store_rate = arecs.store_rate;
    ad_shift = arecs.shift;

    % check for proper number of subframes
    sbfrm = max_samp/min_samp;

    if sbfrm ~= arecs.num_subframe
        error('Wrong # signals in subframe from samp rates');
    end;

    if arecs.numsig ~= length(store_rate)
        arecs.numsig
        store_rate
        error('Wrong # signals in store_rate[]');
    end;

    assignin('base','arecs2',arecs);
    % how often do signals appear in subframes
    sfreq = store_rate./min_samp;
    step = sbfrm./sfreq;
    nullstep = sbfrm/2;
    frm = {};

    % which subframes contain which signals
    totsig = 0;
    for s = 1:arecs.numsig
        if store_rate(s) ~= NULL
            frm{s} = 0:step(s):(sbfrm-1);
            totsig = totsig + length(frm{s});
        else
            frm{s} = 0:nullstep:(sbfrm-1);
            totsig = totsig + length(frm{s});
        end;
    end;

    if totsig ~= arecs.sig_in_frm
        totsig
        arecs.sig_in_frm
        error('Calculated wrong # signals in frame');
    end;


    % show how signals are laid out in linear frame
    sigs = [];
    for f = 0:(sbfrm-1)
        for s = 1:arecs.numsig
            whichfrm = frm{s};
            if ~isempty(find(f==whichfrm))
                sigs = [sigs;s];
            end;
        end;
    end;

    if 0

        disp('0 is true.  The universe will now end.');
        % sigs shows which shorts belong to which signal in a frame
        sigs = [sigs,sigs];
        sigs = reshape(sigs', prod(size(sigs)), 1);
        % sigs now shows which bytes belong to which signal

        numa = length(adat);
        totnumfrm = numa/length(sigs);
        allidx = [];

        % handles when storage is turned off mid-trial
        totnumfrm = floor(totnumfrm);
        numa = length(sigs)*totnumfrm;


        allidx = reshape(sigs(:)*ones(1,totnumfrm), numa, 1);

        hrate = store_rate(1);
        vrate = store_rate(2);
        hsig = adat(allidx == 1);
        vsig = adat(allidx == 2);

        hsig = reshape(hsig, 2, prod(size(hsig))/2);
        vsig = reshape(vsig, 2, prod(size(vsig))/2);
        hsig = hsig';
        vsig = vsig';


        % analog data are split in 2 - recombine 2 shorts into single long
        for x = 1:2
            % which 2 streams to look at
            if x == 1
                sig = hsig;
            else
                sig = vsig;
            end;

            shift_calib = ad_shift(x);
            col1 = sig(:,1);
            col2 = sig(:,2);



            % 		a = sa2la([col1,col2]);
            a = col2.*256 + col1;

            a = bitshift(a, -shift_calib);
            a = a - arecs.a_d_radix_comp;
            a = a./40;

            wrap = find(a > 51.2);
            a(wrap) = 0-(102.4 - a(wrap));

            if x == 1
                h = a;
            elseif x == 2
                v = a;
            end;
        end;

    else
        adat = shorts2longs(adat);

        numa = length(adat);
        totnumfrm = numa/length(sigs);
        allidx = [];

        % handles when storage is turned off mid-trial
        totnumfrm = floor(totnumfrm);
        numa = length(sigs)*totnumfrm;
        allidx = reshape(sigs(:)*ones(1,totnumfrm), numa, 1);
        hsig = adat(allidx==1);
        vsig = adat(allidx==2);

        hrate = store_rate(1);
        vrate = store_rate(2);

        h = bitshift(hsig, -ad_shift(1));
        h = h - arecs.a_d_radix_comp;
        % turn into signed ints
        h = u16tos16(h, -ad_shift(1));
        h = h./40;

        v = bitshift(vsig, -ad_shift(2));
        v = v - arecs.a_d_radix_comp;
        v = u16tos16(v, -ad_shift(2));
        v = v./40;

    end;

end;

%% RCA 08/27/08 - Either aidx was empty, or none of the analog data
% references pointed to something in this trial.  There is no analog data
% for this trial.
if ~foundanalogdata
    analog_time = etimes(1);
    h = [];
    v = [];
    ss = sprintf( 'No analog data found for trial #%d.', trial );
    disp( ss );
end;

%% user-defined ecodes
eidx = find(currcode > 999);
ecodeout = currcode(eidx);
etimeout = currtime(eidx) - analog_time;
% absolute trigger times
% triggin=etimes(idx1-1);
% triggout=currtime(find(currcode==1502,1));

% if nargout == 8
% 	start_time = analog_time;
% end;
% if nargout == 9
%     badtrial = badtt;
% end;
start_time = analog_time;
badtrial = badtt;

%% spikes!
sidx = find(currcode > 600 & currcode < 700);

uspk = sort(unique(currcode(sidx)));
numspkchan = length(uspk);

%% each channels spikes are in a cell in array spk
if numspkchan == 0
    spkchan = [];
    spk = [];
else
    for s = 1:numspkchan
        spkchan(s) = uspk(s);
        spk{s} = currtime(find(currcode == uspk(s))) - analog_time;
    end;  % looping through spike channels
end;

if ~isempty(h)
    % subsample analog signals if necessary
    % analog x is per millisecond
    hinc = floor(1000/hrate);
    vinc = floor(1000/vrate);
    ehx = (0:(length(h)-1)).*hinc;
    evx = (0:(length(v)-1)).*vinc;

    % subsample higher rate analog channel to match lower rate
    if hrate > vrate  % subsample h
        arate = vrate;
        hidx = 1:vinc:length(h);
        h = h(hidx);
    elseif vrate > hrate  % subsample v
        arate = hrate;
        vidx = 1:hinc:length(v);
        v = v(vidx);
    else
        arate = hrate;
    end;

    if length(h) ~= length(v)
        length(h)
        length(v)
        error('Problem subsampling analog channels');
    end;

    ainc = 1000/arate;
else
    arate = [];
end;
