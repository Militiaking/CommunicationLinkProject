clc;
clear all;
close all;
pkg load communications;
pkg load signal;

%Generation of Random input signal.
x = randint(1,1000);

%Mapping the input signal.
for i=1:length(x)
  if x(i)==1
    t(i)=1;
    r(i) = 1;
  else
    t(i) = -1;
    r(i) = -1;
  endif
endfor

%At the transmitter.
scatterplot(complex(t));
axis([-2 2 -2 2]);
title("Signal Constellation of the input sequence for BPSK at the transmitter");

%Changing the snr for different values of the input sequences.
snr = 8;    % Change SNR here for various scatter plot.


y = awgn(complex(r),snr);
scatterplot(y);
axis([-2 2 -2 2]);
title("Signal Constellation of the input sequence for BPSK at the receiver");
total_ber = [];
for snr=0:2:20
y = awgn(complex(t),snr);
for i=1:length(y)
  if real(y(i)) >=0
    r(i)=1;
  else
    r(i)=0;
  endif
endfor
[noise ber] = biterr(x,r);
total_ber = [total_ber ber];
endfor
total_ber
snr = 0:2:20;
figure(3);
semilogy(snr,total_ber,'k','linewidth',2);
xlabel("SNR(db)");
ylabel("BER");
title("BER vs SNR");
hold on;
grid on;

