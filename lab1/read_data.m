f1 = fopen('received.dat','r');
x = fread(f1,'float32');
realSignal = x(101:2:end);
imagSignal = x(102:2:end);