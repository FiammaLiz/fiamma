function spikeshape(w_pre,w_post,desired_channels_neural,canales,channel_neural_data,numch, spike_lcs_ss,sample_rate, num_stim, ntrials, ave, fecha, file, name_stim, profundidad, thr)
 %Devuelve spike shapes de los canales seleccionados en diferentes
 %subplots, hace una figura por estimulo.
 %Version 06/08/2020
 %Matlab 2017a

for k=1:length(unique(num_stim)) %para cada tipo de estimulo
        for ch=1:numch %y para cada canal
 for m=1:length(spike_lcs_ss{1,k}) %tomo cada instancia de spike
     hold on
     spikeshapes(:,m)=channel_neural_data(spike_lcs_ss{1,k}(m)-w_pre*sample_rate : spike_lcs_ss{1,k}(m)+w_post*sample_rate,ch); %y tomo la ventana que yo le seteé
 end
     spikeshapes_ch(ch).ch=spikeshapes; %voy guardando cada uno de ese conjunto de spikes en un struct por canal
        end 
        
ss=figure(k); %armo tantas figuras como tipos de estimulos tenga
t_ss= (1:length(spikeshapes(:,1)))/sample_rate; %tiempo que duran los spikes para poder plotear

for ch=1:numch %para cada canal hago un subplot para apilarlos
    sss=subplot(length(desired_channels_neural)+1,1,ch);
for m=1:length(spike_lcs_ss{k}) %ploteo cada spike apilandolos en un plot por canal 
    plot (t_ss,spikeshapes(:,m),'color',[0.4940 0.1840 0.5560 0.5]); %color violeta con cierta transparencia, cuando se apilan se oscurece las partes donde coinciden
    hold on
   % pause %por si quiero ir viendo los spikes mientras apila
end 
    %pause %por si quiero ver los spikes apilados antes de poner media +
    %desvio
    plot (t_ss, mean(spikeshapes,2),'color',[0 0 0.8 0.5],'LineWidth',2); %ploteo la media superpuesta a los spikes
    desv_std= std(spikeshapes'); %calculo el desvio estandard de la media
    errorbar(t_ss,mean(spikeshapes,2),desv_std,'color',[0 0 0.8 0.5],'LineWidth',0.01); %ploteo barras de error
    hold off
    ylabel(desired_channels_neural(ch)) %nombra los ejes y con el numero de canal que le corresponde
    xlabel 'tiempo/[s]'
    
end 
linkaxes(sss,'x'); %alinea los ejes
equispace(ss); %pega los ejes y

%Tabla de datos
 estimulo=name_stim(num_stim==k); %nombre del estimulo
        estimulo=char(estimulo(1)); %para tenerlo una sola vez
        move_to_base_workspace(estimulo);
        
        for i= 1:(ntrials(k)) %para todos los trials del estimulo
        spikenumtrial(i)=numel(spike_lcs_ss{k}); %cuenta el número de spikes 
        move_to_base_workspace(spikenumtrial);
        numspikes= sum(spikenumtrial(1:i)); %y los suma para tener #spikes/trial
        end
colnames={'Ave', 'Fecha', 'Protocolo', 'Estimulo','Profundidad', 'Canales', 'Umbral', 'Spikes'};
valuetable={ave, fecha, file, estimulo, profundidad, canales, thr, numspikes};       
uitable(ss,'Data', valuetable, 'RowName', [], 'ColumnName', colnames,'Position', [50 30 1000 40.5]);

end 

return

 function move_to_base_workspace(variable)

% move_to_base_workspace(variable)
%
% Move variable from function workspace to base MATLAB workspace so
% user will have access to it after the program ends.

variable_name = inputname(1);
assignin('base', variable_name, variable);

 return;