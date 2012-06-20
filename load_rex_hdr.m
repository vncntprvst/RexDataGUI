function data = load_rex_hdr(name)

% % function data = load_rex_hdr(name)

if ~exist('currloadedhdrname')
	persistent currloadedhdrname;
	persistent hdr;
end;

% if the vars don't hold the current expt, load it
if ~strcmp(currloadedhdrname, name)
	currloadedhdrname = name;
	
	
	SPECIALNUM = 1210832817;
	
	% set up the file names
	if ~nargin
		[f,d] = uigetfile('*','Open REX data file (A or E)');
		if ~f
			name = 'v_a_fef_01';
			fname = [rawdatadir,name];
		else
			fname = [d,f(1:(end-1))];
		end;
	else
		if ~exist('rawdatadir')
			errordlg('You need the function ''rawdatadir''','No rawdatadir()');
		end;	
		fname = [rawdatadir,name];
	end;
	
	aname = [fname,'A'];
	ename = [fname,'E'];
	
	% see if we know what we're doing in terms of byte order
    ismac = 1;
	comptype = ismac;
	if comptype == 1 | comptype == 0  % know mac and pc same
		byteorder = 'ieee-le';
		% short to long and short array (Nx2) to long array (Nx1)
		if ~exist('sa2la')
			s2l = inline('double(uint8(s(1)))+256*double(uint8(s(2)))','s');
			sa2la = inline('double(uint8(s(:,1)))+256.*double(uint8(s(:,2)))','s');
			
			assignin('base','s2l',s2l);
			assignin('base','sa2la',sa2la);
		end;
		
	else
		errordlg('Not sure how to decode a file on this computer','Unknown host');
		return;
	end;
	
	% open the files
	efp = fopen(ename, 'r', byteorder);
	afp = fopen(aname, 'r', byteorder);
	
	if efp == -1 | afp == -1
		data = [];
		errordlg(['Could not open files for ', name],'Open error');
		return;
	end;
	
	% get the afile header
	% block size
	toread = 1;
	[blksz, hdr] = fread(afp, toread, 'short');
	
	toread = 1;
	% file name used for creation
	nm = [];
	[hdrchar, nread] = fread(afp, toread, 'char');
	while hdrchar ~= 10
		nm = [nm,char(hdrchar)];
		[hdrchar, nread] = fread(afp, toread, 'char');
	end;
	
	% date and time
	tm = [];
	[hdrchar, nread] = fread(afp, toread, 'char');
	while hdrchar ~= 10
		tm = [tm,char(hdrchar)];
		[hdrchar, nread] = fread(afp, toread, 'char');
	end;
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% don't know what this is supposed to be
	fu = [];
	[hdrchar, nread] = fread(afp, toread, 'char');
	while hdrchar ~= 10
		fu = [fu,char(hdrchar)];
		[hdrchar, nread] = fread(afp, toread, 'char');
	end;
	
	% creator (REX and version number)
	vr = [];
	[hdrchar, nread] = fread(afp, toread, 'char');
	while hdrchar ~= 10
		vr = [vr,char(hdrchar)];
		[hdrchar, nread] = fread(afp, toread, 'char');
	end;
	
	% find distance from 512 to end
	% here's the end
	fseek(efp, 0, 'eof');
	endpt = ftell(efp);
	% here's the distance
	numdat = (endpt - 512)/2;  % /2 since we're going to read shorts
	
	% back to just after the header
	fseek(efp, 512, 'bof');
	toread = numdat;
	
	% read the data in one big chunk - faster
	[alldat, nread] = fread(efp, toread, 'short');
	numrec = numdat/4;  % rows are 4 bytes wide - hence /4
	
	numrec = floor(numrec);
	% shape the stream into a numrec x 4 array
	% edat = reshape(alldat, 4, numrec)';
	edat = reshape(alldat, 4, numrec)';
	
	% pull out the values
	seqnum = edat(:,1);
	ecode = edat(:,2);
	
	% columns 3 and 4 are parts of a long
	% first: convert these shorts into ushorts
	negshort = find(edat(:,3) < 0);
	edat(negshort,3) = (2^16)+edat(negshort,3);
	% second: convert each pair into a long
	offset = (2^16).*edat(:,4) + edat(:,3);
	
	% force allocation of the whole thing to start
	erecs.e = zeros(numrec,3);
	
	% make the e-file records a matrix of "doubles" for 
	% easy searching via Matlab later
	erecs.e(1:numrec,1) = seqnum(1:numrec);
	erecs.e(1:numrec,2) = ecode(1:numrec);
	erecs.e(1:numrec,3) = offset(1:numrec);
	
	% find all pointers into the a-file
	aidx = find(ecode < 0);
	nacode = length(aidx);
	
	if nacode > 0
		currseq = seqnum(aidx(1));
		currcode = ecode(aidx(1));
		curroffset = offset(aidx(1));
		
		[aseq, aecode, atime, auser, acont, adata] = rex_analog(afp, curroffset);
	else
		adata = [];
	end;
	
	fclose(afp);
	fclose(efp);
	
	data = adata;
	hdr = data;
else
	data = hdr;
end;