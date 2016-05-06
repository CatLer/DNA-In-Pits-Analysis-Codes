function [ N ] = Number_Of_Molecules_In_Pit( I )

% NUMBER_OF_MOLECULES_IN_PIT : Gives the number of molecules (N) in the
% nanopit, given signal I.
%   Gets the number of molecules from the intensity by localising steps in
%   the signal corresponding to the absorption or emission of photons.
%   Convolves the signal with a Heaviside step function and get the
%   peaks where are located the steps.

data = I;
data_size = numel(data);

N = zeros(1,floor(data_size/2)-1);

% find the number of molecules for different window sizes

for b=1:floor(data_size/200)-1

%=================== CONVOLUTION ==========================================

% define the window size (2*b-1)

% define the 2 antisymmetric Heaviside step functions
X_R = -b*100:b*100;
X_L = fliplr(X_R);

% do the convolution to the antisymmetric Heaviside functions

Z_R = zeros(size(data));
Z_L = Z_R;

for a=b*100+1:data_size-b*100
    
data_average = mean(data(X_R+a));    
data_prime = data(X_R+a)-min(data(X_R+a));
W_R = data_average*heaviside(X_R);
W_L = data_average*heaviside(X_L);
Z_R(a) = sum(data_prime.*W_R);
Z_L(a) = sum(data_prime.*W_L);

end

%===================== FIND STEPS =========================================

% give where there would be steps

[peak_R, ind_R] = findpeaks(Z_R);
[peak_L, ind_L] = findpeaks(Z_L);

%===================== LABELLING =========================================

% classify the peaks acccording to if they rise or fall

% Rise = 1 
% Fall = 2

Rise =[];
Fall = [];

% check if some indices are repeated for both cases

[Ind, Ind_R, Ind_L] = intersect(ind_R, ind_L);

if ~isempty(Ind_R) && ~isempty(Ind_L)

Q = cat(1, peak_R(Ind_R), peak_L(Ind_L));
[~,Q] = max(Q,[],1);
P_1 = Q==1;
P_2 = Q==2;

Rise = cat(2, Rise, Ind(P_1));
Fall = cat(2, Fall, Ind(P_2));

end

% add the values that didn't intersect in the first place

% values of ind_R not in ind_L
P_1 = setdiff(ind_R,ind_L);

% values of ind_L not in ind_R
P_2 = setdiff(ind_L,ind_R);

Rise = cat(2, Rise, P_1);
Fall = cat(2, Fall, P_2);

%===================== COUNTING ===========================================

% Count the number of molecules
N(b) = max(numel(Rise), numel(Fall));

end

 Possible_N = unique(N);
 Occurence_N = histc(N(:),Possible_N);
[~,i] = max(Occurence_N);

N = Possible_N(i);

%==================== PLOT ================================================
 
plot(data)
   
end


    

