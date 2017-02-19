function A = loadshort(filename);

% Reads file with 16 bit short data from the disk
% 
% Usage:    A = loadshort( filename )
%
%           filename : string with input path and file name
%           A        : signal loaded into MATLAB
%
% Technische Universität Braunschweig, IfN, 2006 - 09 - 26
% (c) Prof. Dr.-Ing. Tim Fingscheidt
%--------------------------------------------------------------------------

infid = fopen(filename,'r');

if infid==-1
   error(['LOADSHORT: File ', filename , ' could not be opened!']);
   return;
end;

[A,count] = fread(infid,'short');

if fclose(infid)~=0
   error(['LOADSHORT: File ', filename , ' is not closed properly!']);
end;

