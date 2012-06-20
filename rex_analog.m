function [aseq, aecode, t, u, c, d] = rex_analog(name, offset)

% % % function [aseq, aecode, t, u, c, d] = rex_analog(name, offset)
% % % returns the analog stream from the afile indexed by 'offset'
% % % from the efile
% % % note that name can be a file pointer
% % % returns sequence number, ecode, time of trace, user code, cont code, data
% % % by James R. Cavanaugh 2001

SPECIALNUM = 1210832817;  % magic number for testing integrity

persistent s2l;
persistent sa2la;


if ~isstr(name)  % name is a file pointer
    afp = name;
    opened_it = 0;
else  % name is a string
    fname = [rawdatadir, name, 'A'];

    % see if we understand how to unload the data
    comptype = lower(computer);

    if strcmp(comptype(1:3),'mac') | strcmp(comptype(1:2),'pc')
        byteorder = 'ieee-le';
        % short to long and short array (Nx2) to long array (Nx1)
        if isempty(sa2la)
            s2l = inline('double(uint8(s(1)))+256*double(uint8(s(2)))','s');
            sa2la = inline('double(uint8(s(:,1)))+256.*double(uint8(s(:,2)))','s');
        end;

    else
        errordlg('Not sure how to decode a file on this computer','Unknown host');
        error('check byteorder in rex_analog()');
    end;

    % open the file
    afp = fopen(fname, 'r', byteorder);
    if afp == -1
        data = [];
        errordlg(['Could not open files for ', name],'Open error');
        return;
    end;
    opened_it = 1;
end;

% shoot right to the specified offset
fseek(afp, offset, 'bof');

% get the magic number
[magicnum, nread] = fread(afp, 1, 'long');

if magicnum ~= SPECIALNUM
    disp([dec2hex(magicnum),', ',dec2bin(magicnum)]);
    disp('should be');
    disp([dec2hex(SPECIALNUM),', ',dec2bin(SPECIALNUM)]);
    disp(['at offset ', num2str(offset)]);
    error('magic number wrong');
end;

% sequence number
[aseq, nread] = fread(afp, 1, 'short');

% event code
[aecode, nread] = fread(afp, 1, 'short');

% time
[atime, nread] = fread(afp, 1, 'long');

% user assigned
[auser, nread] = fread(afp, 1, 'long');

% continuation flag
[acont, nread] = fread(afp, 1, 'short');

% data record length
[adatalen, nread] = fread(afp, 1, 'short');

% variable length data record
[adata, nread] = fread(afp, adatalen, 'uchar');

if opened_it
	fclose(afp);
end;

t = atime;
u = auser;
c = acont;
d = adata;

