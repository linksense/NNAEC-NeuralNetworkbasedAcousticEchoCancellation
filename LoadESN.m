function [esn] = LoadESN(file_name)
% LOAD_ESN loads the Esn structure saved at file_name and returns it

% Created April 30, 2006, D. Popovici
% Copyright: Fraunhofer IAIS 2006 / Patent pending


load(file_name) ; 
eval (['esn = ', file_name , ';']) ; 
