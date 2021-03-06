function [z,StationLinevGreen,StationLinesGreen,StationLineaGreen,StationLineVerrorGreen,StationLineTimeGreen,StationLineResisGreen,StationLineCondiGreen]=OutputCoastpic(x,vGreen,sGreen,myadd,sRed,vRed,xend)
%% 初始化参考线
Tsample=0.07;
% %% currentState 结构体定义
% currentState.velocity=0;
% currentState.verror=0;
% currentState.position=0;
% currentState.time=0;
% currentState.condition=0;  
% currentState.tractionAcc=0;
% currentState.breakforce=0;
% currentState.resistance=0;
% currentState;
%% 控制器
xStart=x;
xEnd=xend;

vcontrol(1)=0;
scontrol(1)=sGreen(2);
acontrol(1)=0;
verrorControl(1)=0;
timeControl(1)=0;
resistanceControl(1)=0;
conditionControl(1)=1;% 1是启动

SumError=0;
Times=0;
k=1;
Xindex=1;
stableVelocity=0;

% symbolGreen=[8138.217, 9655.078]; 
for i=1:1:100000
    if(scontrol(i)<sGreen(length(sGreen)))
        for j=k:1:length(sGreen)
            if(i==1)
                verrorControl(i)=vGreen(j)-vcontrol(i);
                k=j;
                break;
            else if(scontrol(i)<= sGreen(j))
                verrorControl(i)=vGreen(j-1)-vcontrol(i);%i时刻速度偏差
                stableVelocity=vGreen(j-1);
                k=j;
                break;
                end
            end
        end
    else
        verrorControl(i)=0-vcontrol(i);
        stableVelocity=0;
    end
    
    
    if(scontrol(i)>xStart(Xindex) && scontrol(i)<=xEnd(Xindex) && verrorControl(i)>=0)
        acontrol(i)=0.0;  %牵引力为0
        Addw=2.5711*10^-2+3.403*10^-6*vcontrol(i)^2;%基本阻力
        sumAcc=acontrol(i)-Addw-myadd(scontrol(i));%加速度和
        dv=sumAcc*Tsample;
        ds=vcontrol(i) * Tsample + 0.5 * sumAcc * Tsample^2;
        
        vcontrol(i+1)=vcontrol(i)+dv;
        scontrol(i+1)=scontrol(i)+ds;               
        conditionControl(i+1)=4; %惰行
        resistanceControl(i+1)=Addw;
        timeControl(i+1)=timeControl(i)+Tsample;

          
    else if(verrorControl(i)>0)  %牵引
        acontrol(i)=1.0;
        Addw=2.5711*10^-2+3.403*10^-6*vcontrol(i)^2;%基本阻力
        sumAcc=acontrol(i)-Addw-myadd(scontrol(i));%加速度和
        dv=sumAcc*Tsample;
        ds=vcontrol(i) * Tsample + 0.5 * sumAcc * Tsample^2;
        
        vcontrol(i+1)=vcontrol(i)+dv;
        scontrol(i+1)=scontrol(i)+ds;  
        conditionControl(i+1)=2; %惰行
        resistanceControl(i+1)=Addw;
        timeControl(i+1)=timeControl(i)+Tsample;


    
    else if(verrorControl(i)<=0)  %跟随
%         Addw=2.5711*10^-2+3.403*10^-6*vcontrol(i)^2;
%         acontrol(i)=Addw+myadd(scontrol(i));%基本阻力用于求能耗，此处位于计算效果，制动力取线路基本数据+曲线变化率
%         vcontrol(i)=stableVelocity;
%         dv=0;
%         ds=vcontrol(i)*Tsample; 
        acontrol(i)=-1.1;
        Addw=2.5711*10^-2+3.403*10^-6*vcontrol(i)^2;%基本阻力
        sumAcc=acontrol(i)-Addw-myadd(scontrol(i));%加速度和
        dv=sumAcc*Tsample;
        ds=vcontrol(i) * Tsample + 0.5 * sumAcc * Tsample^2;
        
        vcontrol(i+1)=vcontrol(i)+dv;
        scontrol(i+1)=scontrol(i)+ds; 
        conditionControl(i+1)=5; %减速
        resistanceControl(i+1)=Addw;
        timeControl(i+1)=timeControl(i)+Tsample;

       
          end
        end
    end
    
    if(scontrol(i+1)>xEnd(Xindex) && scontrol(i)<xEnd(Xindex))
        if(Xindex<length(xEnd))  %最后一次不更新
         Xindex=Xindex+1;
        end          
    end
    
    if(vcontrol(i+1)<0.001 && i>100)
        vcontrol(i+1)=0;
        % 补齐最后两个点
        acontrol=[acontrol,0];
        verrorControl=[verrorControl,0];
        Times=0.07*i;
        break; %结束
     end

end

%% 绘图
sGreen=sGreen';
vGreen=vGreen';

sRed=sRed';
vRed=vRed';


plot(sRed,vRed,'Color','Red');
hold on;
plot(sGreen,vGreen,'Color','Green');
hold on;
plot(scontrol,vcontrol,'Color','Black');
hold on;
xlabel('线路位置(m)','fontsize',10);ylabel('速度(m/s)','fontsize',10);

legend('土建限速','运行参考线','优化后的运行参考线',1);
title('优化后的列车运行参考线');
grid;

M=370527+22046.7;
Energy=0;
Comfort=0;
StationError=0;
TimeError=abs(length(scontrol)*0.07+1.2-191);   %时间性能输出

for i=1:1:length(acontrol)-1    %能耗性能输出
    if(acontrol(i)>0)   %只计算牵引时的能量消耗
        Energy=Energy+M*abs(acontrol(i))*abs(scontrol(i+1)-scontrol(i));  
    end
    Comfort=Comfort+abs((acontrol(i+1)-acontrol(i))/0.07);
end


StationError = scontrol(length(scontrol))-10214.23
Energy
Times
EnergyOFF=(1.9512*10^8-Energy)/(1.9512*10^8)
TimesUP=(Times-166.6700)/166.6700

StationLinevGreen=vcontrol; %用于保存当前站的的惰行参考线
StationLinesGreen=scontrol;
StationLineaGreen=acontrol;
StationLineVerrorGreen=verrorControl;
StationLineTimeGreen=timeControl;
StationLineResisGreen=resistanceControl;
StationLineCondiGreen=conditionControl;
z=(1/M)*Energy+20*Times;

