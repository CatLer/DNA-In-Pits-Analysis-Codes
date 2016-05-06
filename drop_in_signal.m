function [drop,time,lt,ut,LT,UT,TIME,DROP,int,err] = drop_in_signal(Intensity,num_rows,num_cols)

lt = zeros(num_rows,num_cols);
ut = zeros(num_rows,num_cols);
time = zeros(num_rows,num_cols);
drop = zeros(num_rows,num_cols);
int = zeros(num_rows,num_cols);
err = zeros(num_rows,num_cols);

for i=1:num_rows
    for j=1:num_cols
        my_intensity = permute(Intensity(i,j,:),[3,2,1]);
        X = statelevels(my_intensity);
%       my_intensity = my_intensity - X(1);
        drop(i,j) = diff(X);
%       my_intensity = my_intensity/drop(i,j);
        [T,lT,uT]=falltime(permute(Intensity(i,j,:),[3,2,1]));
        lt = uT;
        ut = lT;
        if isempty(T)
        [T,lT,uT]=risetime(permute(Intensity(i,j,:),[3,2,1]));
        ut = uT;
        lt = lT;
        end
        time(i,j) = T;
        int(i,j) = mean(my_intensity(1:round(lt)));
        err(i,j) = std(my_intensity(1:round(lt)));
    end
end

LT = mean(lt(:));
UT = mean(ut(:));
TIME = mean(time(:));
DROP = mean(drop(:));

end