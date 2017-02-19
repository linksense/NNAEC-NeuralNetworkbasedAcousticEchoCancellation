function internalState = twi_esn(totalstate , esn , normDiff)
% Update internal state according to the time-warping invariant model
%
% input arguments:
% totalstate: the previous totalstate, vector of size 
%     (esn.nInternalUnits + esn.nInputUnits + esn.nOutputUnits) x 1
% esn: the ESN structure
% normDiff: the diff
%
% output: 
% internalState: the updated internal state, size esn.nInternalUnits x 1
%
% Created June 7, 2006, H.Jaeger
% Copyright: Fraunhofer IAIS 2006 / Patent pending
% Revision 1, June 23, 2007, H. Jaeger (include esn.feedbackScaling)
% Revision 2, July 1, 2007, H. Jaeger (change from uniform timeConstant to
%                                      neuron-specific timeConstants)
   
previousInternalState = totalstate(1:esn.nInternalUnits, 1);
internalState = (1 - normDiff * esn.leakage * esn.timeConstants / esn.avDist) .* ...
    previousInternalState + (normDiff * esn.timeConstants / esn.avDist) .* ...
        feval(esn.reservoirActivationFunction ,...
        [ esn.internalWeights, esn.inputWeights, esn.feedbackWeights * diag(esn.feedbackScaling )] * totalstate) ; 
    
    %%%% add noise to the Esn 
internalState = internalState + esn.noiseLevel * (rand(esn.nInternalUnits,1) - 0.5) ; 
