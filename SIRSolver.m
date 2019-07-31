function dx = SIRSolver(t,x,par)
dx = zeros(9,1);
N = par(1);
beta_IR = par(2);
beta_ID = par(3);
beta_HR = par(4);
beta_HD = par(5);
beta_F = par(6);
theta = par(7);
alpha = par(8);
e_1 = par(9);
e_2 = par(10);
k_2 = par(11);
k_1 = par(12);
pie = par(13);
roe = par(14);
delta = par(15);
gamma = par(16);

dx(1) = -(1/N)*(beta_IR*x(1)*x(3)+beta_ID*x(1)*x(4)+beta_HR*x(1)*x(5)+beta_HD*x(1)*x(6)+beta_F*x(1)*x(8));
dx(2) =  (1/N)*(beta_IR*x(1)*x(3)+beta_ID*x(1)*x(4)+beta_HR*x(1)*x(5)+beta_HD*x(1)*x(6)+beta_F*x(1)*x(8))-alpha*x(2);
dx(3) =  (1-theta)*alpha*x(2)-(1-pie)*e_1*x(3)-pie*e_2*x(3);
dx(4) =  theta*alpha*x(2)-(1-pie)*k_1*x(4)-pie*k_2*x(4);
dx(5) =  pie*e_2*x(3)-roe*x(5);
dx(6) =  pie*k_2*x(4)-delta*x(6);
dx(7) =  (1-pie)*e_1*x(3)+roe*x(5);
dx(8) =  (1-pie)*k_1*x(4)-gamma*x(8);
dx(9) =  gamma*x(8)+delta*x(6);
end