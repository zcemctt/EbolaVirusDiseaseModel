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

tt_3    = [tt_1 tt_2];
I_real_3 = [I_real_1 I_real_2];

%% Automatic Switch 

figure;
f = fit(transpose(tt_3(1:50)),transpose(I_real_3(1:50)),'exp1');
plot(f,tt_3(1:50),I_real_3(1:50));
Coeff = coeffvalues(f);
A = Coeff(1);
B = Coeff(2);
F = A*exp(B*tt_3(1:50));

syms x 

y = A*exp(B*x)
inflex = eval((subs(diff(y,x,1),x,tt_3(1:50))));

for ii = 1:length(tt_3(1:50))
    if (inflex(ii)>5) && inflex(ii)<6 
        cutoff = ii
    end
end

tt_1    = tt_3(1:cutoff);
tt_2    = tt_3(cutoff:length(tt_3));

I_real_1 = I_real_3(1:cutoff);
I_real_2 = I_real_3(cutoff:length(tt_3));


%%
runs = 1000;

I_eqn_1 = zeros(runs,50);
NUM = [];

for a = 1:1:runs
xaa = zeros(1,50);
xa = [];
tspan = [];
a
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
    population(count).incubation = round(log(lognrnd(12.7,4.31))); %sets first x population to be sick
end
ixs(1:I) = xs(1:I); %defines sick xs
iys(1:I) = ys(1:I); %defines sick ys
rxs(1:R) = xs((N-R+1):N); %defines sick xs
rys(1:R) = ys((N-R+1):N); %defines sick ys
%plot(ixs(1:I)>0,iys(1:I)>0,'r.','markersize',20) %plots sick
%plot(rxs(1:R)>0,rys(1:R)>0,'g.','markersize',20) %plots recovered
for t = 1:200 %loops for time
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
                    population(count).incubation = round(log(lognrnd(12.7,4.31))); %sets incubation
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
    thres = cumsum(sick)/2;
    if (thres(end) > 3) && (thres(end) < 7)
        NUM(a) = t;
    end
end

NUM_average = mean(NUM)
NUM_std     = std(NUM);

clf

tt_1     = tt_3(1:NUM(a));
tt_2     = tt_3(NUM(a):length(tt_3));
I_real_1 = I_real_3(1:NUM(a));
I_real_2 = I_real_3(NUM(a):length(tt_3));

for i = 1:NUM(a)
    xaa(i) = transpose(sick(tt_1(i)));
end

I_eqn_1(a,:) = cumsum(xaa);
InfectThres(a)  = I_eqn_1(a,end);


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

% Parameter Optimization

N    = 5454;          %fit is 3900, normal is 1500000
E    = 32;
I    = I_eqn_1(a,end)/2;
H    = 1.4;
R    = 2.4;
F    = 5.4;
D    = 6.2;
S    = N-E-2*I-2*H-R-F-D;


beta_IR = 0.158490176;         %fit is 0.230, normal is 0.160
beta_ID = 0.159444067;         %fit is 0.230, normal is 0.160
beta_HR = 0.067783592;
beta_HD = 0.065233397;
beta_F  = 0.496898755;
theta   = 0.470332299;
alpha   = 0.081158;
e_1     = 0.060641228;
e_2     = 0.273568178;
k_2     = 0.284861083;
k_1     = 0.069847851;
pie     = 0.147526368;
roe     = 0.066902752;
delta   = 0.105661641;
gamma   = 0.53288435;

tspan = linspace(max(tt_1),max(tt_2),(165-NUM(a)));

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

%I_eqn_2(:,a) = cumsum(xa(:,3)+xa(:,4));

sx = size(cumsum(xaa(1:NUM(a))));
sy = size(transpose(cumsum(xa(:,3)+xa(:,4))));
dims = max(sx(1),sy(1));
I_eqn_3_F(a,:) = [[cumsum(xaa(1:NUM(a)));zeros(abs([dims 0]-sx))],[transpose(cumsum(xa(:,3)+xa(:,4)));zeros(abs([dims,0]-sy))]];
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



toc

end

%AverageParams = [mean(N_est);mean(beta_IR_est);mean(beta_ID_est);mean(beta_HR_est);mean(beta_HD_est);mean(beta_F_est);mean(theta_est);mean(alpha_est);mean(e_1_est);mean(e_2_est);mean(k_2_est);mean(k_1_est);mean(pie_est);mean(roe_est);mean(delta_est);mean(gamma_est)];
%stdParams = [std(N_est);std(beta_IR_est);std(beta_ID_est);std(beta_HR_est);std(beta_HD_est);std(beta_F_est);std(theta_est);std(alpha_est);std(e_1_est);std(e_2_est);std(k_2_est);std(k_1_est);std(pie_est);std(roe_est);std(delta_est);std(gamma_est)];
%%
tt_3    = [tt_1 tt_2];
tt_4    = [tt_1 tspan];
tt_4    = tt_4(1:165);
I_real_3 = [I_real_1 I_real_2];
I_eqn_3_Fs = I_eqn_3_F(:,1:length(tt_4));
%I_eqn_3_Fs = I_eqn_3_F;
I_eqn_3M = mean(I_eqn_3_Fs);

RMSE_3 = (immse(I_real_3(1:165), I_eqn_3M))^0.5

figure;
hold on;
box on;

    scatter(tt_3,I_real_3,'red','filled');
    plot(tt_4,I_eqn_3_Fs(3,:),'Color','[0.66,0.66,0.66]','LineWidth',3);
    plot(tt_4,I_eqn_3M,'Color','black','LineWidth',3); 
    
    SPM = tt_3(round(NUM_average-NUM_std));
    SPP = tt_3(round(NUM_average+NUM_std));
    SP  = round((SPM+SPP)/2);
    line([SP, SP], [0, 30000], 'LineWidth', 3, 'Color', '[0 0.5 1]');
    line([SPM, SPM], [0, 30000], 'LineWidth', 3, 'Color', '[0.055 0.301 0.570]'); 
    line([SPP, SPP], [0, 30000], 'LineWidth', 3, 'Color', '[0.055 0.301 0.570]');
    
for ii = 1:runs
    plot(tt_4,I_eqn_3_Fs(ii,:),'Color','[0.66,0.66,0.66]','LineWidth',8);    
end
    plot(tt_4,I_eqn_3M,'black','LineWidth',3); 
    scatter(tt_3,I_real_3,'r','filled');
    

%legend('Infected (CDC Data)','Infected (Hybrid Model)','Infected (Median)','Model Switch Date: Median','Model Switch Date: 1?');
xlabel('Time (Days)','FontSize',20);
ylabel('Total Cases','FontSize',20);
title('Liberia 2014-16');
set(gca, 'LineWidth',2,'FontSize',15);
xlim([0 700]);
ylim([0 15000]);