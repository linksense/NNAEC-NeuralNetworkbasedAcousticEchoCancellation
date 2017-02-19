function x = sigmoid01_inv(s)
% inverse to sigmoid01 (see sigmoid01.m for more documentation)
% Its formula is atanh((x - 0.5) * 2);
%
% Created April 30, 2006, D. Popovici
% Copyright: Fraunhofer IAIS 2006 / Patent pending

% inverse to sigmoid01
x = atanh((s - 0.5) * 2);
