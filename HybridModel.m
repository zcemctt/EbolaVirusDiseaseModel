hold off
clear
clc
clf
%clears everything
hold on

%% Load real datasets for total cases and deaths from CDC 
[filename, filepath, ~] = uigetfile('*.xlsx');
[~, headers, ~] = xlsread([filepath, filename], 1, '1:1');

tt_1 = transpose(xlsread([filepath, filename], 1, 'A:A'));%day 0 is 25/3/2014
I_real_1 = transpose(xlsread([filepath, filename], 1, 'E:E'));

[filename, filepath, ~] = uigetfile('*.xlsx');
[~, headers, ~] = xlsread([filepath, filename], 1, '1:1');

tt_2 = transpose(xlsread([filepath, filename], 1, 'A:A'));%day 0 is 25/3/2014
I_real_2 = transpose(xlsread([filepath, filename], 1, 'E:E'));
D_real_2 = transpose(xlsread([filepath, filename], 1, 'F:F'));

%% Run Hybrid Model 
runs = 100;
for a = 1:1:runs
%figure;
%hold on;
%box on;
%scatter(tt_2,I_real_2);
%scatter(tt_2,D_real_2);
%legend('Infected Compartment (real)', 'Dead Compartment (real)');
%xlabel('Time (Days)','FontSize',20);
%ylabel('Number of People','FontSize',20);
%set(gca, 'LineWidth',2,'FontSize',15);

width = 301;
height = 301; %define area
tEnd = max(tt_1)+1; %time to run
I = 1; %# of infected
realN = 4000;
N = 200; %# number of agents
R = 0; % number of recovered
xs = zeros(N,1); %x positions
ys = zeros(N,1); %y positions
ixs = ones(N,1)*-1; %infected x positions
iys = ones(N,1)*-1; %infected y positions
rxs = ones(N,1)*-1; 
rys = ones(N,1)*-1; 
pM = 0.6; %probability of movement
pT = 0.7; %probability of transmission
pDU = 0.70; %probability of death (unhospitalized)
pDH = 0.45; %probability of death (hospitalized) 
pH = 0.2 ; %probability of seeking hospitalization 
pF = (1-pH)*pDU ; %probability of funeral, and by extension death
sick = [];
dead = [];
recovered = [];
hospitalized = [];
funeral = [];
healthy = []; %establish tracking
inter = [];

tic


for count = 1:N %initializes the structure definitions of each agent
    population(count).name = count; %gives a label
    population(count).x = round(rand(1,1)*width); %defines x positions randomly
    population(count).y = round(rand(1,1)*height); %defines y position randomly
    population(count).incubation = 0; %defines every agent as healthy
    xs(population(count).name) = population(count).x; %sets the xs value to the x position
    ys(population(count).name) = population(count).y; %sets the ys value to the y position
end
%plot(xs,ys,'.','markersize',20); %starts plot of everyone
for count = 1:I
    population(count).incubation = floor(rand(1,1)*28+2); %sets first x population to be sick
end
ixs(1:I) = xs(1:I); %defines sick xs
iys(1:I) = ys(1:I); %defines sick ys
rxs(1:R) = xs((N-R+1):N); %defines sick xs
rys(1:R) = ys((N-R+1):N); %defines sick ys
%plot(ixs(1:I)>0,iys(1:I)>0,'r.','markersize',20) %plots sick
%plot(rxs(1:R)>0,rys(1:R)>0,'g.','markersize',20) %plots recovered
for t = 1:tEnd %loops for time
    for count = 1:N %loops per agent
        m = rand(1,1); %chance to move
        if m<pM %determines if moves
            m = floor(rand(1,1)*8+1); %determines direction
            %m = 8;
            switch m %goes into case based on direction
                case 1
                    if population(count).x < width
                        population(count).x = population(count).x + 1;
                        xs(count) = population(count).x;
                    else
                        population(count).x = population(count).x - 1;
                        xs(count) = population(count).x;
                    end
                case 2 %example of down and to the right
                    if (population(count).x < width)&&(population(count).y > 0) %checks if not at either bound
                        population(count).x = population(count).x + 1; %moves the x
                        population(count).y = population(count).y - 1; %moves the y
                        xs(count) = population(count).x; %sets xs
                        ys(count) = population(count).y; %sets ys
                    elseif population(count).x < width %checks if it is at just the y bound
                        population(count).y = population(count).y + 1; %bounces the opposite direction
                        ys(count) = population(count).y; %sets ys
                    else
                        population(count).x = population(count).x - 1; %bounces x
                        xs(count) = population(count).x; %sets x
                    end
                case 3
                    if population(count).y > 0
                        population(count).y = population(count).y - 1;
                        ys(count) = population(count).y;
                    else
                        population(count).y = population(count).y + 1;
                        ys(count) = population(count).y;
                    end
                case 4
                    if (population(count).x > 0)&&(population(count).y > 0)
                        population(count).x = population(count).x - 1;
                        population(count).y = population(count).y - 1;
                        xs(count) = population(count).x;
                        ys(count) = population(count).y;
                    elseif population(count).x > 0
                        population(count).y = population(count).y + 1;
                        ys(count) = population(count).y;
                    else
                        population(count).x = population(count).x + 1;
                        xs(count) = population(count).x;
                    end
                case 5
                    if population(count).x > 0
                        population(count).x = population(count).x - 1;
                        xs(count) = population(count).x;
                    else
                        population(count).x = population(count).x + 1;
                        xs(count) = population(count).x;
                    end
                case 6
                    if (population(count).x > 0)&&(population(count).y < height)
                        population(count).x = population(count).x - 1;
                        population(count).y = population(count).y + 1;
                        xs(count) = population(count).x;
                        ys(count) = population(count).y;
                    elseif population(count).x > 0
                        population(count).y = population(count).y - 1;
                        ys(count) = population(count).y;
                    else
                        population(count).x = population(count).x + 1;
                        xs(count) = population(count).x;
                    end
                case 7
                    if population(count).y < height
                        population(count).y = population(count).y + 1;
                        ys(count) = population(count).y;
                    else
                        population(count).y = population(count).y - 1;
                        ys(count) = population(count).y;
                    end
                case 8
                    if (population(count).x < width)&&(population(count).y < height)
                        population(count).x = population(count).x + 1;
                        population(count).y = population(count).y + 1;
                        xs(count) = population(count).x;
                        ys(count) = population(count).y;
                    elseif population(count).x < width
                        population(count).y = population(count).y - 1;
                        ys(count) = population(count).y;
                    else
                        population(count).x = population(count).x - 1;
                        xs(count) = population(count).x;
                    end
            end
        end
    end
    %clf %clears the figure
    %hold on
    %plot(xs,ys,'.','markersize',20) %plots health
    ixs(1:I) = xs(1:I); %defines sick xs
    iys(1:I) = ys(1:I); %defines sick ys
    rxs(1:R) = xs((N-R+1):N); %defines sick xs
    rys(1:R) = ys((N-R+1):N); %defines sick ys
    %xlim([0,width])
    %ylim([0,height])
    for count = 1:N %loops per agent
        for pos = 1:N %loops per sick
            if (xs(count) == ixs(pos))&&(ys(count)==iys(pos))&&population(count).incubation <1 %checks if positions overlap
                T = rand(1,1); %random to pass on disease
                if T<pT %determines if disease passes
                    population(count).incubation = round(rand(1,1)*19+2); %sets incubation
                    rxs(1:sum(ixs == -3)) = xs((N-sum(ixs == -3)+1):N); %defines sick xs
                    rys(1:sum(ixs == -3)) = ys((N-sum(ixs == -3)+1):N); %defines sick ys
                end
            end
        end
           
    end
    for count = 1:N
       if population(count).incubation>0 %checks if infected
           ixs(count) = xs(count); %adds to infected pool
           iys(count) = ys(count);
       else
           ixs(count) = -1; %removes from infected pool if not infected
           iys(count) = -1;
       end
       for state = 1:N
           D = rand(1,1);
           if (D<pDU) && (population(count).incubation > 0) && (population(count).incubation < 5)
               ixs(count) = -2;
           elseif (D>pDU) && (population(count).incubation > 0) && (population(count).incubation < 5)
               rxs(count) = ixs(count); 
               rys(count) = iys(count); 
               ixs(count) = -3;
           end       
           if (D<pDH) && (population(count).incubation > 0) && (population(count).incubation < 5)
               ixs(count) = -2;
           elseif (D>pDH) && (population(count).incubation > 0) && (population(count).incubation < 5)
               rxs(count) = ixs(count); 
               rys(count) = iys(count); 
               ixs(count) = -3;
           end                
           H = rand(1,1);  
           if (H<pH) && (population(count).incubation > 15) && (population(count).incubation < 20)
               ixs(count) = -4;
           end
           F = rand(1,1);
           if (F<pF) && (population(count).incubation > 0) && (population(count).incubation < 5)
               ixs(count) = -5;
           end
       end
       population(count).incubation = population(count).incubation -1; %ticks down incubation
    end
    %plot(ixs(ixs>0),iys(ixs>0),'r.','markersize',20) %plots again
    %plot(rxs(rxs>0),rys(rxs>0),'g.','markersize',20) %plots again
    %xlim([0,width])
    %ylim([0,height])
    %pause(0.001); %waits for display sake
    sick = [sick ; sum(ixs>0)]; %counts number of sick
    dead = [dead ; sum(ixs == -2)+sum(ixs == -5)];
    recovered = [recovered ; sum(ixs == -3)];
    hospitalized = [hospitalized ; sum(ixs == -4)];
    funeral = [funeral ; sum(ixs == -5)];
    healthy = [healthy ; N-sick(t)-dead(t)+recovered(t)-hospitalized(t)]; %counts number of healthy
end

toc
clf

for i = 1:length(tt_1)
    xaa(i) = transpose(sick(tt_1(i)));
end

I_eqn_1(a,:) = cumsum(xaa);

%plot(1:tEnd,healthy,1:tEnd,sick,1:tEnd,dead,1:tEnd,recovered,1:tEnd,hospitalized,1:tEnd,funeral)
%legend('Susceptible','Infected','Dead','Recovered','Hospitalized','Funeral')

%figure;
%hold on;
%box on;
%plot(tt_1,I_eqn_1,'LineWidth',3);
%scatter(tt_1,I_real_1);
%legend('Infected (SIR model)','Infected (real)');
%xlabel('Time (Days)','FontSize',20);
%ylabel('Cumulative Population','FontSize',20);
%set(gca, 'LineWidth',2,'FontSize',15);
%xlim([0 20]);

%RMSE = (immse(I_real_1, I_eqn_1))^0.5;



N    = 7347;          %fit is 3900, normal is 1500000
E    = 32;
I    = I_eqn_1(a,end)/2;
H    = 1.4;
R    = 2.4;
F    = 5.4;
D    = 6.2;
S    = N-E-2*I-2*H-R-F-D;


beta_IR = 0.15;         %fit is 0.230, normal is 0.160
beta_ID = 0.15;         %fit is 0.230, normal is 0.160
beta_HR = 0.062;
beta_HD = 0.062;
beta_F  = 0.489;
theta   = 0.45049;
alpha   = 0.088883;
e_1     = 0.066667;
e_2     = 0.3086;
k_2     = 0.3086;
k_1     = 0.07513148;
pie     = 0.197;
roe     = 0.06297229;
delta   = 0.09930487;
gamma   = 0.4975124;

tspan = linspace(max(tt_1),max(tt_2),139);
%tspan = tt_2;

f = @(t,x) [-(1/N)*(beta_IR*x(1)*x(3)+beta_ID*x(1)*x(4)+beta_HR*x(1)*x(5)+beta_HD*x(1)*x(6)+beta_F*x(1)*x(8));
            (1/N)*(beta_IR*x(1)*x(3)+beta_ID*x(1)*x(4)+beta_HR*x(1)*x(5)+beta_HD*x(1)*x(6)+beta_F*x(1)*x(8))-alpha*x(2);
            (1-theta)*alpha*x(2)-(1-pie)*e_1*x(3)-pie*e_2*x(3);
            theta*alpha*x(2)-(1-pie)*k_1*x(4)-pie*k_2*x(4);
            pie*e_2*x(3)-roe*x(5);
            pie*k_2*x(4)-delta*x(6);
            (1-pie)*e_1*x(3)+roe*x(5);
            (1-pie)*k_1*x(4)-gamma*x(8);
            gamma*x(8)+delta*x(6)];
[t,xa]=ode45(f,tspan, [S E I I H H R F D]);

%figure;
%hold on;
%box on;
%plot(t,xa(:,1),'LineWidth',3);
%plot(t,xa(:,2),'LineWidth',3);
%plot(t,xa(:,3)+xa(:,4),'LineWidth',3);
%plot(t,xa(:,5)+xa(:,6),'LineWidth',3);
%plot(t,xa(:,7),'LineWidth',3);
%plot(t,xa(:,8),'LineWidth',3);
%plot(t,xa(:,9),'LineWidth',3);
%legend('Susceptibles','Exposed','Infectious','Hospitalized','Recovered','Funeral','Deceased');
%xlabel('Time (Days)','FontSize',20);
%ylabel('Population','FontSize',20);
%set(gca, 'LineWidth',2,'FontSize',15);


I_eqn_2(:,a)   = cumsum(xa(:,3)+xa(:,4));
%RMSE_2 = (immse(I_real_2, transpose(I_eqn_2)))^0.5

%figure;
%hold on;
%box on;
%plot(t,I_eqn_2,'LineWidth',3);
%scatter(tt_2,I_real_2);
%legend('Infected (SIR model)','Infected (real)');
%xlabel('Time (Days)','FontSize',20);
%ylabel('Cumulative Population','FontSize',20);
%set(gca, 'LineWidth',2,'FontSize',15);
%xlim([0 1000]);
%ylim([0 20000]);

%I_eqn_3 = [I_eqn_1 transpose(I_eqn_2)];

%RMSE_3 = (immse(I_real_3, I_eqn_3))^0.5
end

%%
tt_3    = [tt_1 tt_2];
I_real_3 = [I_real_1 I_real_2];
I_eqn_1M = median(I_eqn_1);
I_eqn_2M = median(transpose(I_eqn_2));

figure;
hold on;
box on;

    scatter(tt_3,I_real_3,'black');
    plot(tt_1,I_eqn_1M,'w','LineWidth',1.5);
    plot(tspan,I_eqn_2M,'w','LineWidth',1.5);
for ii = 1:runs
    plot(tt_1,I_eqn_1(ii,:),'LineWidth',5);
    plot(tspan,I_eqn_2(:,ii),'LineWidth',5);
end
    plot(tt_1,I_eqn_1M,'w','LineWidth',1.5);
    plot(tspan,I_eqn_2M,'w','LineWidth',1.5);
legend('Infected (CDC Data)','Infected (Median)','Infected (Monte Carlo)');
xlabel('Time (Days)','FontSize',20);
ylabel('Cumulative Population','FontSize',20);
title('Liberia 2014-16');
set(gca, 'LineWidth',2,'FontSize',15);
xlim([0 800]);
ylim([0 15000]);

figure;
hold on;
box on;

    scatter(tt_3,I_real_3,'black');
    plot(tt_1,I_eqn_1M,'w','LineWidth',1.5);
    plot(tspan,I_eqn_2M,'w','LineWidth',1.5);
for ii = 1:runs
    plot(tt_1,I_eqn_1(ii,:),'LineWidth',5);
    plot(tspan,I_eqn_2(:,ii),'LineWidth',5);
end
    plot(tt_1,I_eqn_1M,'w','LineWidth',2.5);
    plot(tspan,I_eqn_2M,'w','LineWidth',2.5);
legend('Infected (CDC Data)','Infected (Median)','Infected (Monte Carlo)');
xlabel('Time (Days)','FontSize',20);
ylabel('Cumulative Population','FontSize',20);
title('Liberia 2014-16');
set(gca, 'LineWidth',2,'FontSize',15);
xlim([0 200]);
ylim([0 5500]);

figure;
hold on;
box on;

    scatter(tt_3,I_real_3,'black');
    plot(tt_1,I_eqn_1M,'w','LineWidth',1.5);
    plot(tspan,I_eqn_2M,'w','LineWidth',1.5);
for ii = 1:runs
    plot(tt_1,I_eqn_1(ii,:),'LineWidth',5);
    plot(tspan,I_eqn_2(:,ii),'LineWidth',5);
end
    plot(tt_1,I_eqn_1M,'w','LineWidth',2.5);
    plot(tspan,I_eqn_2M,'w','LineWidth',2.5);
legend('Infected (CDC Data)','Infected (Median)','Infected (Monte Carlo)');
xlabel('Time (Days)','FontSize',20);
ylabel('Cumulative Population','FontSize',20);
title('Liberia 2014-16');
set(gca, 'LineWidth',2,'FontSize',15);
xlim([120 400]);
ylim([0 15000]);