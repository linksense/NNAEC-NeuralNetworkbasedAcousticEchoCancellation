function out = loaddouble( filename );

% Reads file with 64 bit double data from the disk
% 
% Usage:    A = loaddouble( filename )
%
%           filename : string with input path and file name
%           A        : signal loaded into MATLAB
%
% Technische Universität Braunschweig, IfN, 2006 - 11 - 15
% (c) Prof. Dr.-Ing. Tim Fingscheidt
%--------------------------------------------------------------------------

infid = fopen(filename,'r');

if infid==-1
   error(['LOADDOUBLE: File ', filename , ' could not be opened!']);
   return;
end;

[A,count] = fread(infid,'double');

if fclose(infid)~=0
   error(['LOADDOUBLE: File ', filename , ' is not closed properly!']);
end;

out = A;