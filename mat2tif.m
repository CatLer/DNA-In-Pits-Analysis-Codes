function [] = mat2tif(matrix,frames,path)

matrix = double(matrix);
for i=1:frames
  tiff = matrix(:, :, i);
  outputFileName = path;
  imwrite(tiff,outputFileName,'WriteMode', 'append')
end
