function internalState = plain_esn(totalstate , esn , varargin)

% PLAIN_ESN computes the new internal states of the ESN by using the simple
% esn equations
%
% input arguments:
% totalstate: the previous totalstate, vector of size 
%     (esn.nInternalUnits + esn.nInputUnits + esn.nOutputUnits) x 1
% esn: the ESN structure
%
% output: 
% internalState: the updated internal state, size esn.nInternalUnits x 1
%
% Created April 30, 2006, D. Popovici
% Copyright: Fraunhofer IAIS 2006 / Patent pending%
% Revision 1, June 6, 2006, H.Jaeger
% Revision 2, June 23, 2007, H. Jaeger (include esn.feedbackScaling)


internalState =  feval( esn.reservoirActivationFunction , ...
    [esn.internalWeights , esn.inputWeights , esn.feedbackWeights * diag(esn.feedbackScaling )] * totalstate)  ;   
%%%% add noise to the Esn 
internalState = internalState + esn.noiseLevel * (rand(esn.nInternalUnits,1) - 0.5) ; 

