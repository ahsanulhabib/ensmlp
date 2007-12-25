% DEMTECATORMIXENSGROUP Learn Tecator with mixture of ensembles and grouped prior.

% ENSMLP

priortype = 'group';
nhidden = 8;
nhidden = 8;
dataset = 'tecator';
load([dataset]);


clear netres evidres TsIn1 tsIn2 TsOut1 TsOut2 errcom errtest errtrain
nin = 10;
nout = 1;


xtrain = [tecatorTrIn(:, 1:nin); tecatorValIn(:, 1:nin)];
ttrain = [tecatorTrOut(:, 1); tecatorValOut(:, 1)];
xtest = tecatorTsIn(:, 1:nin);
ttest = tecatorTsOut(:, 1);


meanxtrain = mean(xtrain);
xtrain = (xtrain - ones(size(xtrain, 1), 1)*meanxtrain);
stdxtrain = std(xtrain);
xtrain = xtrain./(ones(size(xtrain, 1), 1)*stdxtrain);
xtest = (xtest - ones(size(xtest, 1), 1)*meanxtrain) ...
	./(ones(size(xtest, 1), 1)*stdxtrain);
meanttrain = mean(ttrain);
ttrain = ttrain - meanttrain;
stdttrain = std(ttrain);
ttrain = ttrain/stdttrain;
ttest = (ttest - meanttrain)/stdttrain;

clear tecatorTrIn tecatorValIn tecatorTsIn tecatorTrOut tecatorValOut tecatorTrOut

ncomp1 = 3;
ncomp2 = 5;

load([dataset '_ens_' priortype '_' num2str(nhidden) ...
      'hidden.mat'])
[void, index] = max(lllRes);
initnet = netRes(index);
clear netRes
clear lllRes
clear nmsepRes
clear SEPRes
initnet = ensrmnode(initnet, 2, [2 3 4 6 8]);
for n = ncomp2:-1:ncomp1
  netRes(n-ncomp1+1) = mixenslearn(initnet, xtrain, ttrain, n, dataset);
  lllRes(n-ncomp1+1) = mixenslll(netRes(n-ncomp1+1), xtrain, ttrain);
  ytest = mixensoutputexpec(netRes(n-ncomp1+1), xtest);
  nmsepRes(n-ncomp1+1) = sum(((ttest - ytest).^2))./sum((ttest - mean(ttrain)).^2);
  SEPRes(n-ncomp1+1) = sqrt(mean((stdttrain*(ttest -ytest)).^2));
end
save([dataset '_mixens_' initnet.alphaprior.type '_' ...
     num2str(initnet.nhidden) 'hidden.mat'], 'netRes', 'lllRes', ...
     'nmsepRes', 'SEPRes')






