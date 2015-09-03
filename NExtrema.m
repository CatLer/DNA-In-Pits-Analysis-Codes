function [extrema,indices] = NExtrema(varargin)
%NEXTREMA : Returns the first N extrema (min or max), given (X,N,type) or
%(X,N,type,dim), where X is the matrix to extremize, N is the number of
%extrema, type is 'min' or 'max', dim is along which dimension to extremize
%(1,2,3). If no dimension specified, indices are [row,column], if dim=1,
%the indices for each row is given in the corresponding column, if dim=2,
%the indices for each column is given in the corresponding row, and if
%dim=3, the indices are given along the 3rd dimension. 
%   Uses sorting.
narginchk(3,4);
X=varargin{1}; N=varargin{2}; type=varargin{3}; dim=0;
if nargin==4
    dim=varargin{4};
end
if ~strcmpi(type,'min') && ~strcmpi(type,'max')
    error('Please, choose ''min'' or ''max'' as ''type''.')
else
    if strcmpi(type,'min')
        type='ascend';
    else
        type='descend';
    end
end

extrema=[]; indices=[];
if dim~=0
   [X_prime,I]=sort(X,dim,type);
   if dim==1
       extrema=X_prime(1:N,:,:);
       indices=I(1:N,:,:);
   else
       if dim==2
          extrema=X_prime(:,1:N,:); 
          indices=I(:,1:N,:);
       else
           if dim==3
               extrema=X_prime(:,:,1:N);
               indices=I(:,:,1:N);
           end
       end
   end
else
    X_prime=X(:); 
    [X_prime,I]=sort(X_prime,type);
    extrema=X_prime(1:N);
    indices=I(1:N);
    [indices(:,1),indices(:,2)]=ind2sub(size(X),indices);
end


end
