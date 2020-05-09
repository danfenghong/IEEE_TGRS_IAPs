function data = unPad(paddedData,shape)
if ndims(paddedData) == 3

c = shape / 2 - 0.5;

ds = size(paddedData);

hds = ds / 2 + 0.5;

startPoint = round(hds - c);

endPoint = startPoint + shape - 1;

data = paddedData(startPoint(1):endPoint(1),startPoint(2):endPoint(2),startPoint(3):endPoint(3));

else

c = shape / 2 - 0.5;

ds = size(paddedData);

hds = ds / 2 + 0.5;

startPoint = round(hds - c);

endPoint = startPoint + shape - 1;

data = paddedData(startPoint(1):endPoint(1),startPoint(2):endPoint(2));
end
    

