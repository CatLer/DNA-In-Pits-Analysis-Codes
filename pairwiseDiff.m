function [diffMat, N, edges] = pairwiseDiff(x,nbins,varargin)
    if nargin < 2
        nbins = round(length(x)*sqrt(1/2));
    end
    plotHist = 0;
    for iVa = 1:length(varargin)
        if any(strcmpi(varargin{iVa},{'plotHist','makeHist','makePlot'}))
            plotHist = varargin{iVa+1};
            if ischar(plotHist) && any(strcmpi(plotHist,{'no','n','f','false','0'}))
                plotHist = 0;
            end
        end
    end
    diffMat = triu(bsxfun(@minus,x,x'));
    if str2num(subElem(version('-release'),1:4))<=2013
        %use hist
        [N, binCtrs] = hist(diffMat(diffMat~=0),nbins);
        binWidth = mean(diff(binCtrs));
        edges = [binCtrs binCtrs(end)+binWidth]-binWidth/2;
    else
        [N, edges] = histcounts(diffMat(diffMat~=0),nbins);
        binCtrs = (edges(1:end-1)+edges(2:end))./2;
    end
    if plotHist
        figure;bar(binCtrs,N);
    end
end