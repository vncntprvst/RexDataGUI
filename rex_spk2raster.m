function [rasterline, rastersize] = rex_spk2raster( spk, channel, minsize )

%  [rasterline, rastersize] = rex_spk2raster( spk,  channel, minsize )
% 
%  Takes the spikes array found from Rex data files, as read by things like
%  rex_trial, and converts it to a full raster of 1s and 0s.  Another
%  way to view it is that spk is a list of indices in rasterline to set to 1. 
%
%  Sometimes we may want a minimum size (the raster must be at 
%  least so long).  No way to specify maximum size though.
%  Can be used for multiple channels in spk, but a separate call for each
%  channel, with a separate value passed in for channel, has to be made.
%  Channel is 1 by default.
%
% EXAMPLE:
%     [ecodeout, etimeout, spkchan, spk, arate, h, v, start_time, badtrial ] = rex_trial(name, d );
%     if ~isempty( spk )
%         [raster, last] = rex_spk2raster( spk, 1, length( h ) );
%         plot( spike_density( raster, 5 ) );
%     end;


if nargin < 2
    channel = 1;
end;
if nargin < 3
    minsize = 0;
end;

rasterline = [];
rastersize = 0;

% This code used to assume that spike times were relative to start time.
% This is no longer the case, and was causing spikes to be shifted to times
% that were too late.  This has been corrected (1/6/2009).  Now, however,
% it is conceivable to have a spike time that it negative, so we must
% elliminate those (which is what nonnegnrl is for).

if ~isempty( spk )
    %nrl = 1+spk{channel} - starttime;
    if iscell( spk )
        nrl = spk{channel,:};
    else
        nrl = spk(channel,:);
    end;
    f = find( nrl > 0 );
    nonnegnrl = nrl( f );
    if ~isempty(nonnegnrl)
       rastersize = max( nonnegnrl( end ), minsize );
       rasterline = zeros( 1, rastersize );
       rasterline( nonnegnrl ) = 1;
    end;
end;
