block Studente

parameter Real T = 0.1;

InputInteger mc; //markov chain
OutputStatoStudente stato;

initial equation 
stato = StatoStudente.nulla;

algorithm

when sample(0,T) then //transizioni random
if (mc == 1) then 
	stato := StatoStudente.nulla;
elseif (mc == 2) then
	stato := StatoStudente.vuolePrenotare;
else
	stato := StatoStudente.vuoleCancellare;

end if;

end when;

end Studente;





