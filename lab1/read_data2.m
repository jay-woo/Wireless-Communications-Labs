clear all;

% Unpacks the received data file
f1 = fopen('received.dat','r');
x = fread(f1,'float32');
realSignal = x(101:2:end);
imaginarySignal = x(102:2:end);
stripped = (realSignal + imaginarySignal * 1i);
graph1 = stripped;

% Initializes variables
actualSignal = zeros(length(stripped), 1);
chunkSize = 1e4;

actualSignal = stripped;

% Corrects for frequency offset
for i=1:chunkSize:length(stripped)
    % Prevents indexing errors
    if i+chunkSize > length(stripped)
        chunk = stripped(i:end);
    else
        chunk = stripped(i:i+chunkSize);
    end
    
    % Multiplies signal with a complex exponential @ a particular frequency
    f = fftshift(fft(chunk.^4));
    frequencies = linspace(-1, 1, length(f));
    [foo, maxFreqIndex] = max(abs(f));
    freqOffset = frequencies(maxFreqIndex)/4;
    times = (0:length(chunk)-1)';
    correctedChunk = chunk .* exp(-times*1i*pi*freqOffset);

    % Prevents indexing errors
    if i+chunkSize > length(stripped)
        actualSignal(i:end) = correctedChunk;
    else
        actualSignal(i:i+chunkSize) = correctedChunk;
    end
end

% Normalizes the data for the Costas loop
graph2 = actualSignal;
h = rms(actualSignal);
actualSignal = actualSignal / h;

% Costas loop
error_sum = 0;
psi = 0;
P = 0.1;
I = 0.;
for m=1:length(actualSignal)
    actualSignal(m) = actualSignal(m) * exp(1j * psi);
    s = actualSignal(m);
    e = sign(real(s)) * imag(s) - sign(imag(s)) * real(s);
    error_sum = error_sum + e;
    psi = psi + P * e + I * error_sum;
end

% Looks at just the real component (imag should be zero)
realSignal = real(actualSignal);
imagSignal = imag(actualSignal);

% Selects the beginning and the end of the signal using a threshold
threshold = max(realSignal)*3/4;
i = 1;
while abs(realSignal(i)) < threshold && i < length(realSignal)
    i = i+1;
end
j = length(realSignal);
while abs(realSignal(j)) < threshold && j > 0
    j = j-1;
end
realStripped = realSignal(i:j);
imagStripped = imagSignal(i:j);
subplot(2,1,1);
plot(realStripped(1:2.5e3));
subplot(2,1,2);
plot(imagStripped(1:2.5e3));

% Compares the result to the original string
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

real_bits = addChkdBits(1:2:end);
imag_bits = addChkdBits(2:2:end);

% Converts received data into bits and calculates error rate
realSamples = sign(downsample(realStripped(5:end),10));
imagSamples = sign(downsample(imagStripped(5:end),10));
realSamples = (realSamples + 1) / 2;
imagSamples = (imagSamples + 1) / 2;

realFlipped = zeros(length(real_bits), 1);
imagFlipped = zeros(length(imag_bits), 1);
for i = 1:10:length(real_bits)
   realCheckBits = real_bits(i:i+1);
   if(realCheckBits == [0; 1])
       realFlipped(i:i+9) = not(real_bits(i:i+9));
   else
       realFlipped(i:i+9) = real_bits(i:i+9);
   end

   imagCheckBits = imag_bits(i:i+1);
   if(imagCheckBits == [0; 1])
       imagFlipped(i:i+9) = not(imag_bits(i:i+9));
   else
       imagFlipped(i:i+9) = imag_bits(i:i+9);
   end
end
% sum(abs(flipped - addChkdBits)) / length(flipped)
