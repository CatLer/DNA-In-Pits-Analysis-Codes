function [background,Background] = CalculateBackground(Input,r)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%============================= BACKGROUND =================================
%----------------------- Convert to cell array ----------------------------
input=double(Input);
input=mat2cell(input,size(input,1),size(input,2),ones(1,size(input,3)));
%--------------------------------------------------------------------------
%----------------------------- Background ---------------------------------
mat=ones(4*ceil(r)); mat=mat/numel(mat); h=fspecial('disk',ceil(r)); 
background=cellfun(@(x) FastConv(x,mat),input,'UniformOutput',false);
%-------------------------- Fast convolution ------------------------------
    function e=FastConv(a,b) % check if valid
        m=size(a,1)+size(b,1)-1; 
        n=size(a,2)+size(b,2)-1; 
        c=fft2(a,m,n); d=fft2(b,m,n);
        e=ifft2(c.*d); 
        m1=(size(b,1)-1)/2; n1=(size(b,2)-1)/2; 
        e=e(ceil(m1)+1:end-floor(m1),ceil(n1)+1:end-floor(n1));
        e=imfilter(e,h);
    end
%--------------------------------------------------------------------------
%==========================================================================

Background=cell2mat(background);

end

