clearvars; close all; clc;


fid = fopen('positions_mode2.txt','r');



txt = textscan(fid, 't, x, y',1);
data = textscan(fid, '%f %f %f %f %f %f %f');

Time = data{1};
x2nd = data{2}-mean(data{2});
y2nd = data{3}-mean(data{3});
xhalf = data{4}-mean(data{4});
yhalf = data{5}-mean(data{5});
xend = data{6}-mean(data{6});
yend = data{7}-mean(data{7});


XLIMS = [1100 1300];

figure(1)
hold on
plot(Time, y2nd,'r')
plot(Time, yhalf,'g')
plot(Time, yend,'b')
title('y-coordinate'); ylabel('y displacement'); xlabel('time');
grid on
xlim(XLIMS);
legend('1/4','middle','end','location','best')

figure(2)
hold on
plot(Time, x2nd,'r')
plot(Time, xhalf,'g')
plot(Time, xend,'b')
title('x-coordinate'); ylabel('x displacement'); xlabel('time');
grid on
xlim(XLIMS);
legend('1/4','middle','end','location','best')




% fprintf('Period of the pendulum is approx: %f \n',abs(t2-t1));