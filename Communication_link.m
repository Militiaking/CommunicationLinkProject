clc;
close all;
clear all;

%Loading the required packages.
pkg load communications;
pkg load signal;

%Generating the random input bit sequence.
x=randint(1,10);
in = x; % Used for BER Calculations
ps= x;

%carrier frequency 
fc=2;
t=linspace(0,1/fc,50);

%Amplitude of the carrier signal.
a=1;

%The Carrier Signal.
carrierfreq=a*sin(2*pi*fc*t);

modulated=[];

carrier=[];

binary=[];

%Modulation of carrier signal with respect to the carrier signal.
for i=1:length(x)

modulated=[modulated (2*x(i)-1).*carrierfreq];

carrier=[carrier carrierfreq];

binary=[binary x(i)*ones(1,50)];

end

%Ploting of the input sequence with Unipolar NRZ line coding.
subplot(4,1,1);

plot(binary,'k','linewidth',2);

xlabel('Time(sec)');

ylabel('Amplitude(volts)');

title('Message signal');

%Ploting of Carrier Signal.
subplot(4,1,2);

plot(carrier,'k','linewidth',2);

xlabel('Time(sec)');

ylabel('Amplitude(volts)');

title('carrier signal');

%Ploting of Modulated Signal.
subplot(4,1,3);

plot(modulated,'k','linewidth',2);
xlabel('Time(sec)');
ylabel('Amplitude(volts)');
title('Modulated signal');

%Mapping the input sequence to the BPSK Condition.
for i=1:length(x)
  if x(i)==1
    map(i)=1;
  else
    map(i) = -1;
  endif
endfor

%Change snr value
snr = 20;

%passing the modulated signal to the AWGN Channel.
y = awgn(complex(modulated), snr);

%Maximum Livelyhood Decision.
out=[];
for i=2:50:length(modulated)
  if real(y(i)) > 0
    out =[out 1];
  else
    out= [out 0];
  endif
endfor
%demodulation

demodulatedsignal=modulated.*carrier;

% Cut off frequency
fa = 50; 

% Sampling rate
fs = 1000;

[b,a] = butter(3,fa/(fs/2)); % Butterworth filter 

x = filter(b,a,demodulatedsignal);

subplot(4,1,4);

plot(x,'k','linewidth',2);

xlabel('Time(sec)');

ylabel('Amplitude(volts)');

title('Demodulated signal');
%Ploting the signal constellation of the BPSK.
y = awgn(complex(map), snr);
scatterplot(y);
axis([-2 2 -2 2]);
title("Signal Constellation of the BPSK");

%Calculation of BER(Bit Error Rate).
[noise ber] = biterr(in,out);
printf("The bit Error Rate is : %d \n", ber);
printf("The total no bits predicted wrong: %d \n ", noise);
% BER vs SNR Graph ploting
total_ber = [];
for snr=0:2:20
  out=[];
  y = awgn(complex(modulated), snr);
for i=2:50:length(modulated)
  if real(y(i)) > 0
    out =[out 1];
  else
    out= [out 0];
  endif
endfor
[noise ber] = biterr(in,out);
total_ber = [total_ber ber];
endfor
snr = 0:2:20;
total_ber
figure(3);
semilogy(snr,total_ber,'k','linewidth',2);
%axis([0 20 10^-10 1]);
xlabel("SNR(db)");
ylabel("BER");
title("BER vs SNR");
hold on;
grid on;

%PSD calculation for input signal
figure(4);
l = length(modulated);
N = 64;
psd = abs(fft(modulated,N).^2/l);
stem((0:(N-1))/N, psd);
xlabel("frequency ");
ylabel("Power");
title("Power Spectrum of the transmitted signal");

%PSD calculation for output signal
figure(5);
l = length(y);
N = 64;
psd = abs(fft(y,N).^2/l);
stem((0:(N-1))/N, psd);
xlabel("frequency ");
ylabel("Power");
title("Power Spectrum of the received signal");

