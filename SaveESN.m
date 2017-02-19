function SaveESN(esn,file_name,varargin)

% SAVE_ESN save an Esn structure to disk. It's saved under the name
% file_name. 
%
% inputs: 
% esn - our Esn structure we want to save
% file_name - a string containing the file we want 
% option - string containing further options that will be forwarded to
% the matlab save instruction
%
% usages: 
% save_esn(our_trained_esn, 'esn_28_apr_2006', '-V6')
% save_esn(our_trained_esn, 'esn_28_apr_2006')

% Created April 30, 2006, D. Popovici
% Copyright: Fraunhofer IAIS 2006 / Patent pending


if length(varargin) > 0
    option = char(varargin{1}) ; 
else
    option = '' ; 
end


eval([file_name , '=' , 'esn ; '])
eval(['save ',file_name,' ',file_name , ' ', option ])

%TODO: check if file_name is a valid string, i.e. starts with a letter
