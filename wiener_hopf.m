function outputWeights = wiener_hopf(stateCollectMat,teachCollectMat)
% computes ESN output weights from collected network states and collected 
% teacher outputs. Mathematically this is a linear regression. 
% Uses the Wiener-Hopf solution, which runs faster (but is less numerically
% stable) than if the weights are computed via the pseudoinverse.
%
% Created April 30, 2006, D. Popovici
% Copyright: Fraunhofer IAIS 2006 / Patent pending

runlength = size(stateCollectMat,1);
covMat    = stateCollectMat'*stateCollectMat/runlength;
pVec      = stateCollectMat'*teachCollectMat/runlength;
outputWeights = (covMat\pVec)';

