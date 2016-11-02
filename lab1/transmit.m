string = 'hello world';
for i=1:100
   string = strcat(string, 'hello world'); 
end
bytes = uint8(string);
bits = zeros(length(bytes)*8,1);
for i = 1:length(bytes)
    bits(8*(i-1)+1:8*(i-1)+8) = de2bi(bytes(i),8,'left-msb'); 
end

addChkdBits = zeros((length(bits)/8)*10,1);
for i = 1:8:length(bits)
    addChkdBits(10*(i-1)/8+1:10*(i-1)/8+2) = [1 0];
    addChkdBits(10*(i-1)/8+3:10*(i-1)/8+10) = bits(i:i+7);
end

reals = addChkdBits(1:2:end);
imags = addChkdBits(2:2:end);

amplitude = 0.5;
encoded2 = ((reals*2-1) * amplitude) + ((imags*2-1) * amplitude * j);

pulse = ones(100, 1);
upSampled = upsample(encoded2, length(pulse));
pulsed = conv(upSampled,pulse);
pulsed = pulsed(1:length(encoded2)*length(pulse));
disp('# of Samples');
disp(length(pulsed));
padded = [zeros(1e5,1); pulsed; zeros(1e5,1)];
file = fopen('sent.dat', 'w');
realSignal = real(padded);
imagSignal = imag(padded);
datFormat = zeros(2*length(padded),1);
datFormat(1:2:end) = realSignal;
datFormat(2:2:end) = imagSignal;
plot(realSignal);
figure
plot(imagSignal);
figure
plot(datFormat);
fwrite(file, datFormat, 'float32');
fclose(file);