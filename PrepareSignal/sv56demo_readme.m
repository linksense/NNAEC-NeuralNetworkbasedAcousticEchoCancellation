% SV56DEMO - SIGNAL NORMALIZATION BASED ON ITU-T TOOLS
%
% usage:  s_out = sv56demo(s_in, parameter)    
%
%         This function normalizes the input (active) signal to the desired 
%         level based on the ITU-T tools.
%         In this routine, active speech level of the input signal will be 
%         measured. The active speech level then is applied to compute the
%         normalization factor to reach the desired signal level.
%                                                                             
%         s_out         : normalized signal
%         s_in          : input signal
%         parameter     : control normalization parameters
%           -lev ndB    : ndB is the desired normalization level [dB]
%           -sf f       : f is the sampling frequency of input signal [Hz]
%           -bits n     : n is the bit resolution of input signal 
%           -rms        : to normalize the output file using the RMS long-
%                         term level, instead of the active speech level
%           -blk len    : len is the normalization block size [samples]
%           -start sb   : sb is the first block to be processed
%           -end eb     : eb is the last block to be processed
%           -n nb       : nb is the number of blocks to be processed
%           -log file   : to log statistics into file rather than stdout
%           -q          : quiet operation - not to print the progress flag.
%                         Saves time and avoids trash in batch processings.
%           -qq         : print short statistics summary; no progress flag.
%
% Technische Universität Braunschweig, IfN, 2006 - 12 - 30
% (c) Suhadi
%--------------------------------------------------------------------------
