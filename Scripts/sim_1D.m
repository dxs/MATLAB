% 1D simulation of rocket with thrust curve and mass variation
clear all
close all

% System variables
Cd = 0.6;       % estimated drag coefficient
mi = 30;        % initial mass [kg]
mp = 4.2;     % propellant mass
mf = mi-mp;     % final mass
bt = 10;        % burn time [s]
S = 1.767e-2;   % exposed section [m^2]

% Sim parameters
tSpan = [0, 30];
x0 = [1401;0];

data = load('Thrust_Curves/HyperTEK_Mgrain.mat');    % Thrust Curve data Tdat(:,1) = time [s], Tdat(:,2) = Thrust [N]
Tdat = data.Tdat;

% Add values to thrust curve at initial time and final time 
Tdat = [0, Tdat(1,2); Tdat; bt+0.1, 0; tSpan(2), 0];

% assume linear mass variation
m = @(t) ((mf-mi)/bt * t + mi)*(t<=bt) + mf*(t>bt);
m_dot = @(t) (mf-mi)/bt*(t<=bt);

% Interpolate Thrust curve from Thrust data
Ft = @(t) interp1(Tdat(:,1)', Tdat(:,2)', t);

odefun = @(t, x) xdot_1D(t,x,m, m_dot, Ft, Cd, S);
[t, x] = ode45(odefun, tSpan, x0);

[T, a, p, rho] = stdAtmos(x(:,1));

display(['Apogee: ' num2str(max(x(:,1) - x0(1))) ' m'])

figure

subplot(4,1,1)
plot(t, x(:, 1)-x0(1));
title 'Altitude';
ylabel 'z [m]';

subplot(4,1,2);
plot(t, x(:, 2)./a);
title 'Mach'
ylabel 'Ma = v/a [-]'

subplot(4,1,3);
plot(t(1:end-1), diff(x(:, 2))./diff(t)/9.8);
title 'g'
ylabel 'g = a/g_0 [-]'

subplot(4,1,4)
plot(t, Ft(t));
title 'Thrust'
xlabel 't [s]'
ylabel 'Thrust [N]'


