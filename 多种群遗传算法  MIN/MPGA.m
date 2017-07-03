%%%% 清空环境
close all
clc
clear
%% 初始化线路，按站区间划分
StationTableofgudinsuchasheet2=[262, 1661;
                               1662, 3897;
                               3898, 4869;
                               4870, 6227;
                               6228, 8250;
                               8251, 9572;
                               9573, 10437;
                               10438, 11563;
                               11564, 12673;
                               12674, 13701;
                               13702, 14577;
                               14578, 15688;
                               15689, 16635;
                               16636, 17402;
                               17403, 18750;
                               18751, 19671;
                               19672, 20537;
                               20538, 21646;
                               21647, 22591;
                               22592, 23965;
                               23966, 24803;
                               24804, 25543;
                               25544, 27286;
                               27287, 28344;
                               28345, 29164;
                               29165, 29863;
                               29864, 30829;
                               30830,32014;
                               32015, 33139;
                               33140, 34351;
                               34352, 35850;
                               35851, 37038]; %每站包含一个起点和终点
%% 每站包含一个起点和终点
StationTableoftujiansheet1=[2, 32;
                           32, 86;
                           86, 100;
                           100, 128;
                           128, 154;
                           154, 182;
                           182, 206;
                           206, 234;
                           234, 268;
                           268, 294;
                           294, 310;
                           310, 332;
                           332, 360;
                           360, 380;
                           380, 410;
                           410, 432;
                           432, 454;
                           454, 480;
                           480, 504;
                           504, 538;
                           538, 550;
                           550, 574;
                           574, 622;
                           622, 642;
                           642, 662;
                           662, 680;
                           680, 704;
                           704, 732;
                           732, 756;
                           756, 778;
                           778, 802;
                           802, 828];   
%% 每站中包含惰行种群初始化的左右边界，每个站区间都不一样(实验阶段，先取粗略值)
StationTableofregionofcoasting=[900, 1200, -1, -1;
                                2450, 2700, 3500, 4500;
                                5400, 5600, -1, -1;
                                6400, 6600, -1, -1;
                                8138.2, 9600.7, 8862.097, 9900.0;
                                11060, 11400, -1, -1;
                                12092, 12120, -1, -1;
                                13600, 13900, -1, -1;
                                14672, 14684, -1, -1;
                                15708, 16036, -1, -1;
                                16940, 17208, -1, -1;
                                18496, 18528, -1, -1;
                                19272, 19616, -1, -1;
                                20388, 20556, -1, -1;
                                22060, 22308, -1, -1;
                                23008, 23236, -1, -1;
                                23808, 23948, -1, -1;
                                25272, 25452, -1, -1;
                                26412, 26564, -1, -1;
                                27584, 27572, 27968, 28120;
                                29000, 29152, -1, -1;
                                29892, 29932, -1, -1;
                                31308, 31416, -1, -1;
                                33000, 33368, -1, -1;
                                34000, 34344, -1, -1;
                                34900, 35140, -1, -1;
                                36188, 36224, -1, -1;
                                37260, 37600, -1, -1;
                                38844, 39052, -1, -1;
                                39628, 39876, -1, -1;
                                41068, 41096, 42040,42344;
                                43764, 43792, -1, -1;                                                        
                                ]; 
%%  每站中惰行终点的位置
StationTableofCostingEnd=[1248, -1;
                          2808, 4816;
                          5784, -1;
                          6820, -1;
                          8900, 10212;
                          11908, -1;
                          12240, -1;
                          14184, -1;
                          14968, -1;
                          16284, -1;
                          17584, -1;
                          18872, -1;
                          19836, -1;
                          20660, -1;
                          22628, -1;
                          23640, -1;
                          24032, -1;
                          25808, -1;
                          26892, -1;
                          27652, 28584;
                          29496, -1;
                          30292, -1;
                          31480, -1;
                          33804, -1;
                          34528, -1;
                          35240, -1;
                          36520, -1;
                          38016, -1;
                          39432, -1;
                          40876, -1;
                          41228, 42716;
                          44092, -1;
                          ]; 

%% 大循环
SGreen=xlsread('上行全线固定速差检测3.xls',2,'D2:D37038');
VGreen=xlsread('上行全线固定速差检测3.xls',2,'E2:E37038');

SRed=xlsread('7号线土建数据.xls',1,'F2:F828');
VRed=xlsread('7号线土建数据.xls',1,'I2:I828');
%导入附加阻力表
adds=0;
adda=0;
adds=xlsread('上行全线固定速差检测3.xls',3,'E2:E44931');
adda=xlsread('上行全线固定速差检测3.xls',3,'R2:R44931');
addv=xlsread('上行全线固定速差检测3.xls',3,'F2:F44931');
k=length(adds);
for i=1:1:k
    Addw=2.5711*10^-2+3.403*10^-6*addv(i)^2;  %基本阻力
    adda(i)=adda(i)-Addw;   %附加阻力
end
myadd=myfilt(adds,adda);   %附加阻力拟合曲线
%% 保存整条7号线线路的惰行参考线
EntireLinevGreen=[];
EntireLinesGreen=[];
EntireLineaGreen=[];
EntireLineVerrorGreen=[];
EntireLineTimeGreen=[];
EntireLineResisGreen=[];
EntireLineCondiGreen=[];
for TableRow=31:1:size(StationTableofgudinsuchasheet2)
    %% 参数输入
    %% 谢婷版线路条件
    sGreen=SGreen(StationTableofgudinsuchasheet2(TableRow,1)-1:StationTableofgudinsuchasheet2(TableRow,2)-1,:);
    vGreen=VGreen(StationTableofgudinsuchasheet2(TableRow,1)-1:StationTableofgudinsuchasheet2(TableRow,2)-1,:);

    sRed=SRed(StationTableoftujiansheet1(TableRow,1)-1:StationTableoftujiansheet1(TableRow,2)-1,:);
    vRed=VRed(StationTableoftujiansheet1(TableRow,1)-1:StationTableoftujiansheet1(TableRow,2)-1,:);
    %% 2、多种群遗传算法
    if(StationTableofCostingEnd(TableRow,2)>0)
        NVAR=2;                %变量的维数
        xend=StationTableofCostingEnd(TableRow,1:2);
        xcoastingregion=[StationTableofregionofcoasting(TableRow,1),StationTableofregionofcoasting(TableRow,3)];
        xcoastingregion=[xcoastingregion;StationTableofregionofcoasting(TableRow,2),StationTableofregionofcoasting(TableRow,4)];
    else
        NVAR=1; 
        xend=StationTableofCostingEnd(TableRow,1);
        xcoastingregion=StationTableofregionofcoasting(TableRow,1);
        xcoastingregion=[xcoastingregion;StationTableofregionofcoasting(TableRow,2)];
    end   
    NIND=3;               %个体数目
    PRECI=20;              %变量的二进制位数
    GGAP=0.9;              %代沟
    MP=3;                 %种群数目
    FieldD=[rep(PRECI,[1,NVAR]);xcoastingregion;rep([1;0;1;1],[1,NVAR])];  %译码矩阵  
    for i=1:MP
        Chrom{i}=crtbp(NIND, NVAR*PRECI);                       %创建初始种群
    end
    pc=0.7+(0.9-0.7)*rand(MP,1);    %在【0.7,0.9】范围i内随机产生交叉概率
    pm=0.001+(0.05-0.001)*rand(MP,1);  %在【0.001,0.05】范围内随机产生变异概率
    gen=0;  %初始遗传代数
    gen0=0; %初始保持代数
    MAXGEN=2;  %最优个体最少保持代数
    maxY=0; %最优值
    for i=1:MP
        ObjV{i}=1./test20161019(bs2rv(Chrom{i}, FieldD),vGreen,sGreen,myadd,sRed,vRed, xend);%计算各初始种群个体的目标函数值
    end
    MaxObjV=zeros(MP,1);           %记录精华种群
    MaxChrom=zeros(MP,PRECI*NVAR); %记录精华种群的编码
    trace=[];
    YY=[];
    while gen0<=MAXGEN
        gen=gen+1;       %遗传代数加1
        for i=1:MP
            FitnV{i}=ranking(-ObjV{i});                      % 各种群的适应度
            SelCh{i}=select('sus', Chrom{i}, FitnV{i},GGAP); % 选择操作
            SelCh{i}=recombin('xovsp',SelCh{i}, pc(i));      % 交叉操作
            SelCh{i}=mut(SelCh{i},pm(i));                    % 变异操作
            ObjVSel=1./test20161019(bs2rv(SelCh{i}, FieldD),vGreen,sGreen,myadd,sRed,vRed, xend); % 计算子代目标函数值
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
            SUMobjV=SUMobjV+sum(1./ObjV{j});
        end
         avgfitness=SUMobjV / (NIND*MP);
         trace=[trace;avgfitness]; %记录每一代进化中平均适应度
    end
    %% 进化过程图
    figure
    plot(1:gen,1./YY,'--g','LineWidth',2);
    hold on;
    plot(1:gen, trace(:,1),'--b','LineWidth',2);
    xlabel('Evolutionary Generations')
    ylabel('Fitness')
    % title('evolutionary process of MPGA')
    grid;

    legend('optimal individual fitness of each generation ','the average fitness of each generation',1);

    %% 输出最优解
    [Y,I]=max(1./MaxObjV);    %找出精华种群中最优的个体
    X=(bs2rv(MaxChrom(I,:), FieldD));   %最优个体的解码解
    disp(['最优值为：',num2str(Y)])
    disp(['对应的自变量取值：',num2str(X)])

    %%  输出最优解的运行曲线图
    figure
    [BESTfitness,StationLinevGreen,StationLinesGreen,StationLineaGreen,StationLineVerrorGreen,StationLineTimeGreen,StationLineResisGreen,StationLineCondiGreen]=OutputCoastpic(X,vGreen,sGreen,myadd,sRed,vRed,xend); %传入惰行点求出最佳的惰行曲线
    %% 保存全线的惰行线路参数
    EntireLinevGreen=[EntireLinevGreen,StationLinevGreen];
    EntireLinesGreen=[EntireLinesGreen,StationLinesGreen];
    EntireLineaGreen=[EntireLineaGreen,StationLineaGreen];
    EntireLineVerrorGreen=[EntireLineVerrorGreen,StationLineVerrorGreen];
    EntireLineTimeGreen=[EntireLineTimeGreen,StationLineTimeGreen];
    EntireLineResisGreen=[EntireLineResisGreen,StationLineResisGreen];
    EntireLineCondiGreen=[EntireLineCondiGreen,StationLineCondiGreen];
    EntireLinevGreen=[EntireLinevGreen,-1];
    EntireLinesGreen=[EntireLinesGreen,-1];
    EntireLineaGreen=[EntireLineaGreen,-1];
    EntireLineVerrorGreen=[EntireLineVerrorGreen,-1];
    EntireLineTimeGreen=[EntireLineTimeGreen,-1];
    EntireLineResisGreen=[EntireLineResisGreen,-1];
    EntireLineCondiGreen=[EntireLineCondiGreen,-1];
    %% 合并入全牵引曲线
    Tsample=0.07;
    vcontrol=[];
    vcontrol(1)=0;
    
    scontrol=[];
    scontrol(1)=sGreen(2);
    
    acontrol=[];
    acontrol(1)=0;
    
    error=[];
    error(1)=0;
    
    SumError=0;
    Times=0;
    k=1;
    stableVelocity=0; 
    LC=length(sGreen);
    for i=1:1:100000
        if(scontrol(i)<sGreen(length(sGreen)))
            for j=k:1:length(sGreen)
                if(i==1)
                    error(i)=vGreen(j)-vcontrol(i);
                    k=j;
                    break;
                else if(scontrol(i)<= sGreen(j))
                    error(i)=vGreen(j-1)-vcontrol(i);%i时刻速度偏差
                    stableVelocity=vGreen(j-1);
                    k=j;
                    break;
                    end
                end
            end
        else
            error(i)=0-vcontrol(i);
            stableVelocity=0;
        end

        if(error(i)>0)  %牵引
            acontrol(i)=1.0;
            Addw=2.5711*10^-2+3.403*10^-6*vcontrol(i)^2;%基本阻力
            sumAcc=acontrol(i)-Addw-myadd(scontrol(i));%加速度和
            dv=sumAcc*Tsample;
            ds=vcontrol(i) * Tsample + 0.5 * sumAcc * Tsample^2;
            vcontrol(i+1)=vcontrol(i)+dv;
            scontrol(i+1)=scontrol(i)+ds;  
        end

        if(error(i)<=0)  %跟随
            acontrol(i)=-1.1;
            Addw=2.5711*10^-2+3.403*10^-6*vcontrol(i)^2;%基本阻力
            sumAcc=acontrol(i)-Addw-myadd(scontrol(i));%加速度和
            dv=sumAcc*Tsample;
            ds=vcontrol(i) * Tsample + 0.5 * sumAcc * Tsample^2;
            vcontrol(i+1)=vcontrol(i)+dv;
            scontrol(i+1)=scontrol(i)+ds; 

        end

        if(vcontrol(i+1)<0.001)
            vcontrol(i+1)=0;
            Times=0.07*i;
            break; %结束
        end

    end
    %% 绘图
    plot(scontrol,vcontrol,'Color','m');
    legend('最快运行参考线',1);
    %hold on;
end
xlswrite('7号线惰行全线结果表.xlsx',EntireLinevGreen',1,'A2');
xlswrite('7号线惰行全线结果表.xlsx',EntireLinesGreen',1,'B2');
xlswrite('7号线惰行全线结果表.xlsx',EntireLineaGreen',1,'C2');
xlswrite('7号线惰行全线结果表.xlsx',EntireLineVerrorGreen',1,'D2');
xlswrite('7号线惰行全线结果表.xlsx',EntireLineTimeGreen',1,'E2');
xlswrite('7号线惰行全线结果表.xlsx',EntireLineResisGreen',1,'F2');
xlswrite('7号线惰行全线结果表.xlsx',EntireLineCondiGreen',1,'G2');




