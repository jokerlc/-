%%%% 清空环境
clc
clear
%% 参数输入
%导入附加阻力表
EntireLinevGreen=xlsread('7号线惰行全线结果表.xlsx',1,'A2:A5069');
EntireLinesGreen=xlsread('7号线惰行全线结果表.xlsx',1,'B2:B5069');
EntireLineaGreen=xlsread('7号线惰行全线结果表.xlsx',1,'C2:C5069');
EntireLineVerrorGreen=xlsread('7号线惰行全线结果表.xlsx',1,'D2:D5069');
EntireLineTimeGreen=xlsread('7号线惰行全线结果表.xlsx',1,'E2:E5069');
EntireLineResisGreen=xlsread('7号线惰行全线结果表.xlsx',1,'F2:F5069');
EntireLineCondiGreen=xlsread('7号线惰行全线结果表.xlsx',1,'G2:G5069');
%% 加载列车2的停站调整时间表范围
TimeofTrain2StationStop=[15,25;15,25];
%% 2、多种群遗传算法
xTimeoftrain2stop=[TimeofTrain2StationStop(:,1)';TimeofTrain2StationStop(:,2)'];
NIND=20;               %个体数目
NVAR=length(TimeofTrain2StationStop(:,1));                %变量的维数
PRECI=20;              %变量的二进制位数
GGAP=0.9;              %代沟
MP=10;                 %种群数目
FieldD=[rep(PRECI,[1,NVAR]);xTimeoftrain2stop;rep([1;0;1;1],[1,NVAR])];  %译码矩阵
for i=1:MP
    Chrom{i}=crtbp(NIND, NVAR*PRECI);                       %创建初始种群
end
pc=0.7+(0.9-0.7)*rand(MP,1);    %在【0.7,0.9】范围i内随机产生交叉概率
pm=0.001+(0.05-0.001)*rand(MP,1);  %在【0.001,0.05】范围内随机产生变异概率
gen=0;  %初始遗传代数
gen0=0; %初始保持代数
MAXGEN=5;  %最优个体最少保持代数
maxY=0; %最优值
for i=1:MP
    ObjV{i}=1./test20170704(bs2rv(Chrom{i}, FieldD),EntireLinevGreen,EntireLinesGreen,EntireLineaGreen,EntireLineVerrorGreen,EntireLineTimeGreen,EntireLineResisGreen,EntireLineCondiGreen);%计算各初始种群个体的目标函数值
end
MaxObjV=zeros(MP,1);           %记录精华种群
MaxChrom=zeros(MP,PRECI*NVAR); %记录精华种群的编码
trace=[];
while gen0<=MAXGEN
    gen=gen+1;       %遗传代数加1
    for i=1:MP
        FitnV{i}=ranking(-ObjV{i});                      % 各种群的适应度
        SelCh{i}=select('sus', Chrom{i}, FitnV{i},GGAP); % 选择操作
        SelCh{i}=recombin('xovsp',SelCh{i}, pc(i));      % 交叉操作
        SelCh{i}=mut(SelCh{i},pm(i));                    % 变异操作
        ObjVSel=1./test20170704(bs2rv(SelCh{i}, FieldD),EntireLinevGreen,EntireLinesGreen,EntireLineaGreen,EntireLineVerrorGreen,EntireLineTimeGreen,EntireLineResisGreen,EntireLineCondiGreen); % 计算子代目标函数值
        [Chrom{i},ObjV{i}]=reins(Chrom{i},SelCh{i},1,1,ObjV{i},ObjVSel);    %重插入操作
    end
    [Chrom,ObjV]=immigrant(Chrom,ObjV);     % 移民操作
    [MaxObjV,MaxChrom]=EliteInduvidual(Chrom,ObjV,MaxObjV,MaxChrom);     % 人工选择精华种群
    YY(gen)=max(MaxObjV);    %找出精华种群中最优的个体
    if YY(gen)>maxY   %判断当前优化值是否与前一次优化值相同
        maxY=YY(gen); %更新最优值
        gen0=0;
    else
        gen0=gen0+1; %最优值保持次数加1
    end
    SUMobjV=0;
    for j=1:MP
        SUMobjV=SUMobjV+sum(ObjV{j}); %最后的效果图，递增还是递减，区别在于是1./ObjV{j}还是ObjV{j}
    end
     avgfitness=SUMobjV / (NIND*MP);
     trace=[trace;avgfitness]; %记录每一代进化中平均适应度
end
%% 进化过程图
figure
plot(1:gen,YY,'--g','LineWidth',2);  %最后的效果图，递增还是递减，区别在于是1./YY还是YY
hold on;
plot(1:gen, trace(:,1),'--b','LineWidth',2);
xlabel('Evolutionary Generations')
ylabel('Fitness')
% title('evolutionary process of MPGA')
grid;

legend('optimal individual fitness of each generation ','the average fitness of each generation',1);

%% 输出最优解
[Y,I]=max(MaxObjV);    %找出精华种群中最优的个体   %最后的效果图，递增还是递减，区别在于是1./MaxObjV还是MaxObjV
X=(bs2rv(MaxChrom(I,:), FieldD));   %最优个体的解码解
disp(['最优值为：',num2str(Y)])
disp(['对应的自变量取值：',num2str(X)])

