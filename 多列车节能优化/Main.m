%% 多列车全线数据导入
EntireLinevGreen=xlsread('7号线惰行全线结果表.xlsx',1,'A2:A3243');
EntireLinesGreen=xlsread('7号线惰行全线结果表.xlsx',1,'B2:B3243');
EntireLineaGreen=xlsread('7号线惰行全线结果表.xlsx',1,'C2:C3243');
EntireLineVerrorGreen=xlsread('7号线惰行全线结果表.xlsx',1,'D2:D3243');
EntireLineTimeGreen=xlsread('7号线惰行全线结果表.xlsx',1,'E2:E3243');
EntireLineResisGreen=xlsread('7号线惰行全线结果表.xlsx',1,'F2:F3243');
EntireLineCondiGreen=xlsread('7号线惰行全线结果表.xlsx',1,'G2:G3243');

%% 初始化多列车
Length=length(EntireLinevGreen);
EntireLineEnergyConsumption=0;
Tsample=0.07;
TInterval=40; %定义60秒的发车间隔
Train1Stationtime=0;%列车1的停站时间初始化
Train2Stationtime=0;%列车2的停站时间初始化
lockoftrain1stop = 0; %列车1进入停站锁定状态
lockoftrain2stop = 0;%列车2进入停站锁定状态
joftrain1Stationtime=0; %列车1进入停站时，统计本站停站时间是否已经到达
joftrain2Stationtime=0;%列车2进入停站时，统计本站停站时间是否已经到达
for i=1:1:1000000
    if ~lockoftrain1stop
        indextrain1=i-ceil(Train1Stationtime/Tsample);
    else 
        %如果处于停站锁定状态，则停止更新indextrain1，停留在-1的状态
    end
    
    if ~lockoftrain2stop
        indextrain2=i-1*ceil(TInterval/Tsample)- ceil(Train2Stationtime/Tsample);
    else 
        %如果处于停站锁定状态，则停止更新indextrain2，停留在-1的状态
    end
    
    %判断最后一辆列车是否已经到达最后一站
    if indextrain2==Length+1;
        break;
    end
    %体现发车时间的概念
   if indextrain1>0 && indextrain1<Length
        Train1aControl=EntireLineaGreen(indextrain1);
   else
       Train1aControl=0;
   end
   
   if indextrain2>0 && indextrain2<Length
       Train2aControl=EntireLineaGreen(indextrain2);
   else 
       Train2aControl=0;
   end
   
   %体现停站时间的概念
   if Train1aControl == -1
       if ~lockoftrain1stop
           Timeoftrain1thisStation=20; %本列车在此站台的停站时间
           Train1Stationtime = Train1Stationtime + Timeoftrain1thisStation; %本列车在该站台之前的所有停站时间的总和
       end 
       Train1aControl=0;      
       lockoftrain1stop=1;     
       joftrain1Stationtime = joftrain1Stationtime + 1;
       if joftrain1Stationtime > ceil(Timeoftrain1thisStation/Tsample)  %判断是不是停站时间已经到达
           lockoftrain1stop=0;
           joftrain1Stationtime=0;
       end
   end
   
  if Train2aControl == -1
      if ~lockoftrain2stop 
          Timeoftrain2thisStation=20;%本列车在此站台的停站时间
          Train2Stationtime = Train2Stationtime + Timeoftrain2thisStation;  %本列车在该站台之前的所有停站时间的总和
      end
       Train2aControl=0;      
       lockoftrain2stop=1;     
       joftrain2Stationtime = joftrain2Stationtime + 1;
       if joftrain2Stationtime > ceil(Timeoftrain2thisStation/Tsample)  %判断是不是停站时间已经到达
           lockoftrain2stop=0;
           joftrain2Stationtime=0;
       end
   end
   
   % 记录同一供电区间内某一时刻的回收能、牵引能、以及当前时刻所有列车的能耗总和
   consumeEnergy=0;
   regenerativeEnergy=0;
   SumEnergyConsumption=0;
   %求列车1的能耗情况
   if Train1aControl<0
        regenerativeEnergy = regenerativeEnergy + abs(Train1aControl) * (EntireLinesGreen(indextrain1+1)-EntireLinesGreen(indextrain1));  %统计该列车的回收能
   else if Train1aControl > 0
        consumeEnergy = consumeEnergy + Train1aControl * (EntireLinesGreen(indextrain1+1)-EntireLinesGreen(indextrain1));  %统计该列车的牵引能
       end
   end
   %求列车2的能耗情况
   if Train2aControl<0
        regenerativeEnergy = regenerativeEnergy + abs(Train2aControl) * (EntireLinesGreen(indextrain2+1)-EntireLinesGreen(indextrain2));  %统计该列车的回收能
   else if Train2aControl>0
        consumeEnergy = consumeEnergy + Train2aControl * (EntireLinesGreen(indextrain2+1)-EntireLinesGreen(indextrain2));  %统计该列车的牵引能
       end
   end
    
   SumEnergyConsumption=consumeEnergy-regenerativeEnergy;  % 当前时间下所有列车的总能耗
   if SumEnergyConsumption < 0
        SumEnergyConsumption=0;%即产生的回首能大于牵引所需的能量
   end
   
   EntireLineEnergyConsumption=EntireLineEnergyConsumption+SumEnergyConsumption;  %计算全线的总能耗
      
  
end
fprintf('当发车间隔为%d时，',TInterval);
fprintf('两列车的总能耗为%d：',EntireLineEnergyConsumption);