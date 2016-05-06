function [ Curvy_Baseline ] = CurvyBaseline( x,Baseline )
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

Curvy_Baseline = Baseline;
Baseline_Gradient = gradient(Baseline);
Baseline_Gradient = Baseline_Gradient./max(abs(Baseline_Gradient));

% %======================== GRADIENT TEST ===================================
% % step function
% 
% [~,q] = findpeaks(abs(Baseline_Gradient));
% Points = cat(1, 1, q(:), numel(x));
% [a,b] = meshgrid(Points, Points);
% pairs = [a(:) b(:)];
% pairs = pairs(diff(pairs,1,2)~=0,:);
% pairs = unique(sort(pairs,2),'rows');
% 
% for i=1:size(pairs,1)
%     my_data = Curvy_Baseline(pairs(i,1):pairs(i,2));
%     my_data = my_data-min(my_data);
%     my_data = my_data./max(abs(my_data));
%     square_pulse = ones(size(my_data));
%     Remainder = mean(square_pulse - my_data);
%     if Remainder<0.2     
%         figure
%         hold on
%         plot(x(pairs(i,1):pairs(i,2)), Curvy_Baseline(pairs(i,1):pairs(i,2)))
%         Curvy_Baseline(pairs(i,1):pairs(i,2)) = interp1(x,Curvy_Baseline,pairs(i,1):pairs(i,2),'linear');
%         Curvy_Baseline = medfilt1(Curvy_Baseline);
%         plot(x(pairs(i,1):pairs(i,2)), Curvy_Baseline(pairs(i,1):pairs(i,2)))
%         hold off
%         sprintf('o')
%     end
% end

%========================= CURVATURE TEST =================================

Baseline_Curvature = gradient(Baseline_Gradient);
Baseline_Curvature = Baseline_Curvature./max(abs(Baseline_Curvature));
Baseline_Curvature = sign(Baseline_Curvature);
% relaxation parameter
lambda = abs(mean(Baseline_Curvature));
lambda_prime = lambda;
lambda_prime_prime = lambda_prime;

%---------------------- Smoothing the baseline ----------------------------

% work with the relaxation parameter conditions

while lambda<1 && lambda>0 && sign(lambda_prime_prime-lambda_prime)*sign(lambda_prime-lambda)>=0
    
    lambda_prime_prime = lambda_prime;
    lambda_prime = lambda;
    Curvy_Baseline = smooth(x,Curvy_Baseline);
    Baseline_Gradient = gradient(Curvy_Baseline);
    Baseline_Curvature = gradient(Baseline_Gradient);
    Baseline_Curvature = Baseline_Curvature./max(abs(Baseline_Curvature));
    Baseline_Curvature = sign(Baseline_Curvature);    
    lambda = abs(mean(Baseline_Curvature));
    
end


end
