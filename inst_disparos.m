%% Intancias de disparo
%Cuantificacion de actividad neuronal, indica momentos en que dispara,
%latencia y frecuencia en los casos posibles
%Fiamma Liz Leites
%Matlab 2018a

%% PRIMERA SECCI�N: Levanto picos de respuesta neuronal en todo el estimulo deseado
%Ploteo el raster e histograma con picos marcados con lineas para contar y
%ver

%Preparo lo que necesito
n=1; %numero que corresponde a BOS, CON o REV8
binsize= 0.005; %calibrado para este binsize, es el que mejor funciona para el algoritmo
points_bins=1000; 

%Ploteo
f2=figure(n+1); %para que no se superponga si hay otra figura
        
ax(1)=subplot(5,1,1);
       
%Audio del estimulo
        plot(t_audio_stim{n}, audio_stim{n},'Color','k'); %grafico el audio
        hold on
        line([0 0],ax(1).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5]); %linea de principio de estimulo
        line((t_audio_stim{n}(length(t_audio_stim{n}))*[1 1])',ax(1).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5 0.6]); %linea de fin de estimulo en gris
        hold on
        if n<=length(tg) %solo si est�n los datos del textgrid los levanta y hace parches + nombres
        num_silb=length(tg(n).tier{1,1}.Label);
        for tx=1:num_silb
        patch([tg(n).tier{1,1}.T1(tx) tg(n).tier{1,1}.T1(tx) tg(n).tier{1,1}.T2(tx) tg(n).tier{1,1}.T2(tx)],[ax(1).YLim(1) ax(1).YLim(2) ax(1).YLim(2) ax(1).YLim(1)],colorp{tx,1},'FaceAlpha',0.15,'EdgeColor','none');
        hold on
        line(tg(n).tier{1,1}.T1(tx)*[1 1],ax(1).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5]);
        line(tg(n).tier{1,1}.T2(tx)*[1 1],ax(1).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5]); 
        end
        clear tx
        %Escribe los nombres de las s�labas centrados en el parche a 3/4 de altura
        for k=1:num_silb
        text((tg(n).tier{1,1}.T1(k)+tg(n).tier{1,1}.T2(k))/2,(ax(1).YLim(2))*3/4,tg(n).tier{1,1}.Label(k),'FontSize',10,'Interpreter','none');
        end
        clear k
        end
        hold off
        xlim([-L duracion_stim(n)+L]); %pongo de limite a la ventana seleccionada
        title 'Estimulo, Raster e Histograma';
        ylabel 'Estimulo'
        
        %Espectograma del estimulo
        window_width=sample_rate/100;   %points
        [~,f,t,p] = spectrogram(audio_stim{n},...
        gausswin(window_width,5),...
        ceil(0.75*window_width),...
        linspace(0,ceil(sample_rate/2),...
        round(sample_rate/window_width)),...
        sample_rate,'yaxis');
    
        ax(2)=subplot(5,1,2); %ploteo de espectograma
        imagesc('XData',t,'YData',f,'CData',10*log10(p(1:100,:)));
        colormap(jet);
        ylim([0 10000]);
        xlim([-L duracion_stim(n)+L]); %limite de ventana en x
        hold on
        line([0 0],ax(2).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5]); %linea de principio de estimulo
        line((t_audio_stim{n}(length(t_audio_stim{n}))*[1 1])',ax(2).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5 0.6]); %linea de fin de estimulo
        if n<=length(tg)
        for tx=1:num_silb
        line(tg(n).tier{1,1}.T1(tx)*[1 1],ax(2).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5]); %divido en los mismos parches segun silaba
        line(tg(n).tier{1,1}.T2(tx)*[1 1],ax(2).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5]); 
        end
        clear tx
        end
        clear num_silb
        hold off
        ylabel 'Espectograma';
        clear t
        clear f
        clear p
        clear window_width
        
        %histograma con suavizado y marcas de instancias de disparo
        ax(3)=subplot(5,1,3);    
        hist_spikes=cell2mat(spike_stim(n).trial); %agrupo todos los trials de un mismo estimulo 
        counts=histogram(hist_spikes,'BinWidth',binsize,'Normalization','pdf'); %levanto datos de histograma para suavizado
        hold on
        num_points=counts.NumBins*points_bins;
        [f,xi]=ksdensity(hist_spikes,'BandWidth',binsize,'function','pdf','NumPoints',num_points); %funcion de suavizado
        baseline= median([f(1:L*sample_rate-1) f(duracion_stim*sample_rate+1:end)]); %calculo la mediana del suavizado antes de comenzar el est�mulo como baseline
        %[~,lcs_disparos,~,p]= findpeaks(f,'MinPeakHeight',baseline*2); %encuentra las instancias de disparos, con criterio de que sea 2 veces la linea base, preliminar para ver las prominencias (si es bimodal, saco las de menor)
        %pause
        %h=histogram(p,'BinWidth',0.0025) %ploteo histograma con prominencias
        prominencia=0.07; %prominencia a quitar observada en el histograma f3 para no tener picos peque�os entre medio de los buscados
        disp(['Prominencia usada= ' num2str(prominencia)]);
        [~,lcs_disparos]= findpeaks(f,'MinPeakProminence',prominencia,'MinPeakHeight',baseline*2); %encuentra las instancias de disparos, con criterio de que sea 2 veces la linea base y con una prominencia determinada por lo que de el histograma de p
        instancia_disparos=xi(lcs_disparos); %guardo los tiempos donde dispara
        altura_disparos = f(lcs_disparos); %guardo altura de los picos
        plot(xi,f,'LineWidth',1,'Color','r') %ploteo suavizado sobre el histograma
        line((instancia_disparos'*[1 1])',ax(3).YLim,'LineStyle','-','MarkerSize',4,'Color','k','LineWidth',0.05);%ploteo instancias de disparo
        hold off
        clear hist_spikes
        clear counts
        clear num_points
        clear f
        clear xi
        clear lcs_disparos

        ax(4)=subplot(5,1,4);
        %Raster
        for i= 1:(ntrials(n)) %para todos los trials en el estimulo n
            for g= 1: length(spike_stim(n).trial{1,i})
            line(spike_stim(n).trial{1,i}(g)'*[1 1],[-0.5 0.5] + i,'LineStyle','-','MarkerSize',4,'Color','b'); %extrae las instancias de disparo y hace lineas azules, apil�ndolas por cada trial 
            end
            clear g
            hold on
            line([0 0],ax(4).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5]); %linea de principio de estimulo
            line((t_audio_stim{n}(length(t_audio_stim{n}))*[1 1])',ax(4).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5 0.6]); %linea de fin de estimulo
            hold off
            xlim([-L duracion_stim(n)+L]); %pongo de limite en x a la ventana seleccionada
            ylim([0 ntrials(n)+2]) %pongo de limite en y dos filas mas que el numero de trials porque arranca en 1
            ylabel 'Raster';
        end 
        clear i
        equispace(f2)  
        linkaxes(ax,'x');
        
        
        %% SEGUNDA SECCION: cuantificaciones
        
        %Para BOS
        silaba= 'P0(H)'; %poner s�laba que me va a interesar levantar data
        n=1; %el numero que corresponde al estimulo segun estimulos.txt
        g=1; %si esa silaba esta mas de una vez en el estimulo, las veo de a una
        %silabas=(:); %para seleccionar zona con mas persistencia si es necesario
        
        %encuentro la silaba en el audio
        find_sil= strfind(tg(n).tier{1,1}.Label,silaba); %encuentra los indices donde esta la silaba de interes
        frase_position_logical = ~cellfun(@isempty,find_sil); %paso a array logico para poder indexar
        frase_position_init=tg(n).tier{1,1}.T1(frase_position_logical); %encuentro el valor de tiempo inicial de la frase en esos indices
        frase_position_end=tg(n).tier{1,1}.T2(frase_position_logical);  %y el final de la frase
        instancia_disparos_frase=instancia_disparos(instancia_disparos>=frase_position_init(g)&instancia_disparos<=frase_position_end(g)); %guardo los tiempos donde dispara en esa frase aisladamente
        clear sil_position_logical     
        clear find_sil
        
        %calculo latencia (transicion de frase)
        latency_shoot=instancia_disparos_frase(1)-frase_position_init(g); %calculo el delay que tarda entre que empez� la silaba y el primer disparo, para P0 y las respuestas tipo principio de frase
        latency_shoot_r= latency_shoot/(frase_position_end(g)-frase_position_init(g)); %latencia relativa a la extension de la frase
        disp(['Latencia=' num2str(latency_shoot)]);
        disp(['Latencia relativa=' num2str(latency_shoot_r)]);
        
        %Calculo tasa de picos de acitivdad (respuesta con tasa silabica)
        frecuency_shoot_m= 1/mean(diff(instancia_disparos_frase)); %calculo frecuencia promedio, para P1 y P2
        disp(['Tasa de picos de actividad=' num2str(frecuency_shoot_m)]);
        %frecuency_shoot_partial= 1/mean(diff(instancia_disparos_frase(silabas))); %por si no responde
        %a todas y selecciono zona con mas persistencia
        %disp(['Tasa de picos de actividad=' num2str(frecuency_shoot_partial)]);
        %clear silabas
     
        %para todas, altura del pico en el PSTH
        altura_promedio_s= mean(altura_disparos((instancia_disparos>=frase_position_init(g)&instancia_disparos<=frase_position_end(g))))-baseline;
        altura_std=std(altura_disparos((instancia_disparos>=frase_position_init(g)&instancia_disparos<=frase_position_end(g))));
        disp(['MR=' num2str(altura_promedio_s)]);
        disp(['std MR=' num2str(altura_std)]);
        clear n
        clear g
        clear silaba
        
        %% Para CON
        
        %A MANO para CON 
        frase_position_init= 11.057247523525064; %inicio de frase
        frase_position_end= 12.53931941741445; %final de frase
        g=1;
        
        %silabas=(1:3); %por si no es persistente
        instancia_disparos_frase=instancia_disparos(instancia_disparos>=frase_position_init(g)&instancia_disparos<=frase_position_end(g)); %guardo los tiempos donde dispara aisladamente
        
        %Calculo latencia de disparo (transicion de frase)
        latency_shoot=instancia_disparos_frase(1)-frase_position_init(g); %calculo el delay que tarda entre que empez� la silaba y el primer disparo, para P0 y las respuestas tipo principio de frase
        disp(['Latencia=' num2str(latency_shoot)]);
        disp(['Latencia relativa=' num2str(latency_shoot_r)]);
        
        %Tasa de picos de actividad (respuesta con tasa silabica)
        frecuency_shoot_m= 1/mean(diff(instancia_disparos_frase)); %calculo frecuencia promedio, para P1 y P2
        disp(['Tasa de picos de actividad=' num2str(frecuency_shoot_m)]);
        %frecuency_shoot_parcial= 1/mean(diff(instancia_disparos_frase(silabas))); %por si no responde a todas
        %clear silabas
        
        %para todos
        altura_promedio_s= mean(altura_disparos((instancia_disparos>=frase_position_init(g)&instancia_disparos<=frase_position_end(g))))-baseline;
        altura_std=std(altura_disparos((instancia_disparos>=frase_position_init(g)&instancia_disparos<=frase_position_end(g))));
        disp(['MR=' num2str(altura_promedio_s)]);
        disp(['std MR=' num2str(altura_std)]);
        
        clear frase_position_init
        clear frase_position_end
        clear instancia_disparos_frase
        clear g
        
        %% Para REV:
        silaba= 'P0(H)'; %poner s�laba que me va a interesar levantar data
        g=1; %si esa silaba esta mas de una vez en el estimulo, las veo de a una
        n=3;
        
        %Encuentro la frase
        find_sil= strfind(tg(1).tier{1,1}.Label,silaba); %encuentra los indices donde esta la silaba de interes
        frase_position_logical = ~cellfun(@isempty,find_sil); %paso a array logico para poder indexar
        frase_position_init= duracion_stim(n)-tg(1).tier{1,1}.T2(frase_position_logical)  ; 
        frase_position_end= duracion_stim(n)-tg(1).tier{1,1}.T1(frase_position_logical); 
        instancia_disparos_frase=instancia_disparos(instancia_disparos>=frase_position_init(g)&instancia_disparos<=frase_position_end(g)); %guardo los tiempos donde dispara aisladamente
        clear find_sil
        clear frase_position_logical
        
        %Calculo latencia de disparo (transicion de frase)
        latency_shoot=instancia_disparos_frase(1)-frase_position_init(g); %calculo el delay que tarda entre que empez� la silaba y el primer disparo, para P0 y las respuestas tipo principio de frase
        disp(['Latencia=' num2str(latency_shoot)]);
        disp(['Latencia relativa=' num2str(latency_shoot_r)]);
        
        %Tasa de picos de actividad (respuesta con tasa silabica)
        frecuency_shoot_m= 1/mean(diff(instancia_disparos_frase)); %calculo frecuencia promedio, para P1 y P2
        disp(['Tasa de picos de actividad=' num2str(frecuency_shoot_m)]);
        %frecuency_shoot_parcial= 1/mean(diff(instancia_disparos_frase(silabas))); %por si no responde a todas
        %clear silabas
        
        %para todos
        altura_promedio_s= mean(altura_disparos((instancia_disparos>=frase_position_init(g)&instancia_disparos<=frase_position_end(g))))-baseline;
        altura_std=std(altura_disparos((instancia_disparos>=frase_position_init(g)&instancia_disparos<=frase_position_end(g))));
        disp(['MR=' num2str(altura_promedio_s)]);
        disp(['std MR=' num2str(altura_std)]);
        
        clear frase_position_init
        clear frase_position_end
        clear instancia_disparos_frase
        clear g
        
        %% TERCERA SECCI�N: latencia respecto al inicio de la s�laba
        
        %Datos necesarios
 silaba= 'P0(H)'; %poner identidad de s�laba que me va a interesar
 n=1; %identificador del estimulo (BOS/CON/REV)
 g=1;
 
 %Para extraer el momento temporal de la silaba en BOS
 find_sil= strfind(tg(n).tier{1,1}.Label,silaba); %encuentra los indices donde esta la silaba de interes
 frase_position_logical = ~cellfun(@isempty,find_sil); %paso a array logico para poder indexar
 frase_position_init=tg(n).tier{1,1}.T1(frase_position_logical); %encuentro el valor de tiempo inicial de la frase en esos indices
 frase_position_end=tg(n).tier{1,1}.T2(frase_position_logical);  %y el final de la frase
 sound=audio_stim{n}(t_audio_stim{n}>=(frase_position_init(g))& t_audio_stim{n}<=frase_position_end(g));
 times= t_audio_stim{n}(t_audio_stim{n}>=(frase_position_init(g))& t_audio_stim{n}<=frase_position_end(g));
 clear find_sil
 clear frase_position_logical
 
%Detecto inicios y finales de s�laba
params.fs=sample_rate;
params.birdname='BF';
params=def_params(params);
[gtes]=find_gte(sound,params);
onsets=times(gtes.gtes1);
offsets=times(gtes.gtes2);

clear gtes
clear params

%Testeo para ver si me detecto bien los inicios de las silabas

ax(1)=subplot(1,1,1);
plot(times,sound);
hold on
for j=1:length(onsets)
line(onsets(j)*[1 1],ax(1).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5]);
end
clear j

%Ahora calculo latencias de disparo

 instancia_disparos_frase=instancia_disparos(instancia_disparos>=(frase_position_init(g))&instancia_disparos<=(frase_position_end(g))); %guardo las instancias de disparo de la frase
 for p=1:(length(onsets)-1) %no hay ventanita para la ultima as� que para la ultima lo hago aparte
     instancia_disparo=instancia_disparos_frase(instancia_disparos_frase>=(onsets(p))&instancia_disparos_frase<=(onsets(p+1))); %tomo solo los disparos que ocurren en la ventana de tiempo entre el inicio de una silaba y otra
     latency_shoot_s=zeros(1, length(onsets));
     if isempty(instancia_disparo)==0   %si dispara en esa silaba
         latency_shoot_s(p)=instancia_disparo(1)-onsets(p); %siempre toma el primer pico de actividad
     else
         latency_shoot_s(p)=5000000000000; %Es un numero ridiculo de latencia, entonces si no llega a disparar en esa silaba aparece este numero
     end 
 end 
 
 
 %Y ahora calculo el ultimo porque quedo colgado
  instancia_disparo=instancia_disparos_frase(instancia_disparos_frase>=(onsets(end))); %tomo ventana entre inicio de ultima silaba y comienzo de la siguiente frase
  if isempty(instancia_disparo)==0   %si dispara en esa silaba
         latency_shoot_s(p+1)=instancia_disparo(1)-onsets(end); %siempre toma el primer pico de actividad
     else
         latency_shoot_s(p+1)=5000000000000; %Es un numero ridiculo de latencia, entonces si no llega a disparar en esa silaba aparece este numero
  end 
  
  latency_shoot_sil= latency_shoot_s'; %traspongo por comodidad
  clear instancia_disparos_frase
  
  %Calculo valores relativos
  duracion_silabas= offsets-onsets;
  latency_shoot_r_sil=latency_shoot_s./duracion_silabas';
  
  clear duracion_silabas
  clear p
  clear n
  clear g
  clear silaba
  
    %% CUARTA SECCION: Contador de numero de spikes (persistencia)
        %Datos necesarios
 silaba= 'P0(H)'; %poner identidad de s�laba que me va a interesar
 n=1; %identificador del estimulo (BOS/CON/REV)
 g=1;
 
 %Para extraer el momento temporal de la silaba en BOS
 find_sil= strfind(tg(n).tier{1,1}.Label,silaba); %encuentra los indices donde esta la silaba de interes
 frase_position_logical = ~cellfun(@isempty,find_sil); %paso a array logico para poder indexar
 frase_position_init=tg(n).tier{1,1}.T1(frase_position_logical); %encuentro el valor de tiempo inicial de la frase en esos indices
 frase_position_end=tg(n).tier{1,1}.T2(frase_position_logical);  %y el final de la frase
 sound=audio_stim{n}(t_audio_stim{n}>=(frase_position_init(g))& t_audio_stim{n}<=frase_position_end(g));
 times= t_audio_stim{n}(t_audio_stim{n}>=(frase_position_init(g))& t_audio_stim{n}<=frase_position_end(g));
 clear find_sil
 clear frase_position_logical
 
%Detecto inicios y finales de s�laba
params.fs=sample_rate;
params.birdname='BF';
params=def_params(params);
[gtes]=find_gte(sound,params);
onsets=times(gtes.gtes1);
offsets=times(gtes.gtes2);

clear gtes
clear params

%Testeo para ver si me detecto bien los inicios de las silabas

ax(1)=subplot(1,1,1);
plot(times,sound);
hold on
for j=1:length(onsets)
line(onsets(j)*[1 1],ax(1).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5]);
end
clear j

%Opci�n 1: decaimiento de la respuesta a lo largo de las repeticiones
    %(desensibilizacion)
    
       num_spikes_trial=zeros(1, length(ntrials(n)));
     for i= 1:(ntrials(n)) %para todos los trials en el estimulo n
       spikes_frase= spike_stim(n).trial{1,i}(spike_stim(n).trial{1,i}>=(frase_position_init(g))&spike_stim(n).trial{1,i}<=(frase_position_end(g))); %guardo las instancias de disparo de la frase
       num_spikes_trial(i)= length(spikes_frase);      %cuento los spikes en cada repeticion de la frase
     end 
   
    clear i
    
    %Opcion 2: decaimiento de la respuesta a lo largo de la frase en cada
    %repeticion
     
    spikes_silaba_i=cell(1,length(onsets));
    spikes_silaba=zeros(1, length(onsets));
    spikes_repeticiones=cell(1,length(ntrials(n)));
    
    %obtengo los spikes que suceden entre onset y onset
     for i= 1:(ntrials(n)) %para todos los trials en el estimulo n
      for p=1:(length(onsets)-1) %no hay ventanita para la ultima as� que para la ultima lo hago aparte
       spikes_silaba_i{p}=spike_stim(n).trial{1,i}(spike_stim(n).trial{1,i}>=(onsets(p))&spike_stim(n).trial{1,i}<=(onsets(p+1))); %guardo las instancias de disparo de la silaba
       spikes_silaba(p)=length(spikes_silaba_i{1,p}); %cuento cantidad de spikes en esa ventana de tiempo
      end 
      
      %ultima silaba
    spikes_silaba_i{p+1}=spike_stim(n).trial{1,i}(spike_stim(n).trial{1,i}>=(onsets(p+1))&spike_stim(n).trial{1,i}<=frase_position_end(g)); %guardo las instancias de disparo de la frase
    spikes_silaba(p+1)=length(spikes_silaba_i{1,p+1});
    spikes_repeticiones{i,1}= spikes_silaba; %guardo los valores por repeticiones
     end 
     clear i
     clear p
     
     spikes_repeticiones2= cell2mat(spikes_repeticiones); %convierto a matriz para poder seguir
     clear spikes_repeticiones
     
     half_spikes1=sum(spikes_repeticiones2(1:ntrials(n)/2,:)); %tomo la primer mitad de los trials y agrupo
     half_spikes2=sum(spikes_repeticiones2(ntrials(n)/2+1:end,:)); %tomo la segunda mitad de los trials y agrupo
    
    %Intento 1: umbral con media de spikes en silencio
    duracion_promedio_silaba= mean(diff(onsets)); %calculo cuanto dura en promedio una silaba, para que sea comparable
    disparos_basales=zeros(1,length(ntrials(n)));
    
     for i= 1:(ntrials(n)) %para todos los trials en el estimulo n
   disparos_basales(i)= length(spike_stim(n).trial{1,i}(spike_stim(n).trial{1,i}>duracion_stim(n))); %calculo el numero de disparos en el silencio por fuera del estimulo, en cada trial. Uso como ventana de tiempo la duracion promedio de la silaba
     end 
     
    %Calculo umbrales
    thr_disparos= mean(disparos_basales)/L*duracion_promedio_silaba; %calculo promedio del numero de disparos para umbral
    thr_disparos_half1=mean(sum(disparos_basales(1:ntrials(n)/2)))/L*duracion_promedio_silaba; %calculo de umbral para la primera mitad
    thr_disparos_half2=mean(sum(disparos_basales(ntrials(n)/2+1:end)))/L*duracion_promedio_silaba; %calculo de umbral para la segunda mitad
    clear duracion_promedio_silaba
    clear disparos_basales 
    
    %Calculo persistencias
        %persistencia por trial
    positive_shoot= spikes_repeticiones2>thr_disparos; %cuales trials superan el umbral, individuales
    persistencia_trial=zeros(1,length(ntrials(n))); 
    for i=1:(ntrials(n))
    persistencia_trial(i)= length(find(positive_shoot(i,:)))*100/length(onsets); 
    end 
    clear positive_shoot
        %persistencia por mitades
        
    positive_shoot_half1=half_spikes1>thr_disparos_half1;
    persistencia_half(1)=length(find(positive_shoot_half1))*100/length(onsets); %primera mitad
    clear positive_shoot_half1
    
    positive_shoot_half2=half_spikes2>thr_disparos_half2;
    persistencia_half(2)=length(find(positive_shoot_half2))*100/length(onsets); %segunda mitad
    clear positive_shoot_half2
    
    disp(['Persistencias= ' num2str(persistencia_half)]);
 
clear spikes_silaba_i
clear spikes_silaba
clear spikes_repeticiones2
