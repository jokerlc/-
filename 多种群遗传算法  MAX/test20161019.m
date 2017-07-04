function z=test20161019(xstart,vGreen,sGreen,myadd,sRed,vRed, xend)
col=size(xstart,1);
%% 初始化参考线
Tsample=0.07;
for m=1:col
%% 控制器
% x1=8170.305; %惰行开始的起点
% x2=9655.078; %惰行开始的起点
% x1=xstart(m,1); %惰行开始的起点
% x2=xstart(m,2); %惰行开始的起点
xStart=xstart(m,:);
xEnd=xend;
% x3=9222.039;%每一个惰行的终点位置,且每一站都是一样的
% x4=10214.31;%每一个惰行的终点位置，且每一站都是一样的
% xEnd=[x3 x4]; 

Xindex=1;
vcontrol(1)=0;
scontrol(1)=sGreen(2);
acontrol(1)=0;
error(1)=0;
SumError=0;
Times=0;
k=1;
stableVelocity=0;
Disofend=sGreen(length(sGreen));
% symbolGreen=[8138.217, 9655.078]; 
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
    
    
    if(scontrol(i)>xStart(Xindex) && scontrol(i)<=xEnd(Xindex) && error(i)>=0)
        acontrol(i)=0.0;  %牵引力为0
        Addw=2.5711*10^-2+3.403*10^-6*vcontrol(i)^2;%基本阻力
        sumAcc=acontrol(i)-Addw-myadd(scontrol(i));%加速度和
        dv=sumAcc*Tsample;
        ds=vcontrol(i) * Tsample + 0.5 * sumAcc * Tsample^2;
        vcontrol(i+1)=vcontrol(i)+dv;
        scontrol(i+1)=scontrol(i)+ds;        
          
    else if(error(i)>0)  %牵引
        acontrol(i)=1.0;
        Addw=2.5711*10^-2+3.403*10^-6*vcontrol(i)^2;%基本阻力
        sumAcc=acontrol(i)-Addw-myadd(scontrol(i));%加速度和
        dv=sumAcc*Tsample;
        ds=vcontrol(i) * Tsample + 0.5 * sumAcc * Tsample^2;
        vcontrol(i+1)=vcontrol(i)+dv;
        scontrol(i+1)=scontrol(i)+ds;  

    
    else if(error(i)<=0)  %跟随
        acontrol(i)=-1.1;
        Addw=2.5711*10^-2+3.403*10^-6*vcontrol(i)^2;%基本阻力
        sumAcc=acontrol(i)-Addw-myadd(scontrol(i));%加速度和
        dv=sumAcc*Tsample;
        ds=vcontrol(i) * Tsample + 0.5 * sumAcc * Tsample^2;
        vcontrol(i+1)=vcontrol(i)+dv;
        scontrol(i+1)=scontrol(i)+ds; 
       
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
        Times=0.07*i;
        break; %结束
     end

end
%% 绘图
% sGreen=sGreen';
% vGreen=vGreen';
% 
% sRed=sRed';
% vRed=vRed';
% 
% plot(scontrol,vcontrol,'Color','Black');
% hold on;
% plot(sRed,vRed,'Color','Red');
% hold on;
% plot(sGreen,vGreen,'Color','Green');
% hold on;
% grid;

Energy=0;
Comfort=0;
StationError=0;
TimeError=abs(length(scontrol)*0.07+1.2-191);   %时间性能输出
M=370527+22046.7;

for i=1:1:length(acontrol)-1    %能耗性能输出
    if(acontrol(i)>0)   %只计算牵引时的能量消耗
        Energy=Energy+M*abs(acontrol(i))*abs(scontrol(i+1)-scontrol(i));  
    end
    Comfort=Comfort+abs((acontrol(i+1)-acontrol(i))/0.07);
end


StationError = scontrol(length(scontrol))-sGreen(length(sGreen))
Times
Energy
z(m,1)=((1/M)*Energy+20*Times)    %设置速度和时间兼顾的参数
end
% z=Energy
% z=Times
