function [whichversion] = rex_processing_mode()

%  [whichversion] = rex_processing_mode()
%
%  This function is consulted when converting a set of Rex files (A E
%  files) into matlab files (rex_trial_raw.m)
%
%  If it returns 1, the "Version 1" algorithm is used.  This is default.
%  Change it to return 0, and an alternate version will be used.  This is
%  useful if, for instance, after converting data, the trials all look
%  misaligned between the spikes and codes on one hand and the eye data on
%  the other.  If that happens, try the other version.  See
%  rex_trial_raw.m for more, but probably not more helpful, information.

whichversion = 1;