function [my_files_names, my_files_dates] = find_all_files_in_directory( file_extension, starting_path )
% find_all_files_in_directory : Finds all files in a directory and its
% subdirectories given the extension. Returns absolute paths of the the
% files and the date of modification. Uses recursion.

my_files_names  = cell(0);
my_files_dates  = cell(0);

wanted_files = dir(strcat(starting_path, '\*.', file_extension));
%or use fullfile
wanted_files_names = {wanted_files.name};
wanted_files_full_names = cell(size(wanted_files_names));
for i=1:numel(wanted_files_names)
    wanted_files_full_names{i} = strcat(starting_path,'\',wanted_files_names{i});
end
% this is gives 'last modification' date. 
% to have the creation date, use DOS command
wanted_files_dates = {wanted_files.date};
my_files_names = cat(2,my_files_names,wanted_files_full_names);
my_files_dates = cat(2,my_files_dates,wanted_files_dates);
subdirectories  = dir(strcat(starting_path,'\*.'));
subdirectories = subdirectories(~ismember({subdirectories.name},{'.','..'}));
    subdirectories_names = {subdirectories.name};
    subdirectories_full_names = cell(size(subdirectories_names));
    
    if ~isempty(subdirectories_names)
        for i=1:numel(subdirectories_names)
            subdirectories_full_names{i} = strcat(starting_path, '\', subdirectories_names{i});
            [wanted_files_full_names, wanted_files_dates] = find_all_files_in_directory( file_extension, subdirectories_full_names{i});              
            my_files_names = cat(2,my_files_names,wanted_files_full_names);
            my_files_dates = cat(2,my_files_dates,wanted_files_dates);
            
        end
    end
    
end

