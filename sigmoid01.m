function s = sigmoid01(x)
% SIGMOID01 is  a sigmoid with range 0 to 1
% Its formula is tanh(x)/2 + 0.5 
%
% Created April 30, 2006, D. Popovici
% Copyright: Fraunhofer IAIS 2006 / Patent pending

s = tanh(x) / 2 + 0.5;
