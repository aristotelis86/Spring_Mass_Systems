clearvars; close all; clc;


fid = fopen('positions.txt','r');


txt = textscan(fid, 't, x, y',1);
data = textscan(fid, '%f %f %f %f %f %f %f');

Time = data{1};
theta2nd = atan((data{2}-400)./(data{3}-30));
thetamid = atan((data{6}-400)./(data{7}-30));
thetalast = atan((data{4}-400)./(data{5}-30));

const = (pi/10).*ones(1,length(Time));
const_m = -(pi/10).*ones(1,length(Time)); 


figure(1)
hold on
plot(Time, theta2nd,'r')
plot(Time, thetalast,'g')
plot(Time, thetamid,'b')
plot(Time, const,'--k')
plot(Time, const_m,'--k')
xlabel('time'); ylabel('theta');
legend('2nd','last','middle')
grid on





% fprintf('Period of the pendulum is approx: %f \n',abs(t2-t1));