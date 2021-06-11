block Aula

parameter Integer capienza = 40; //capienza aule nel sistema
parameter Real T = 2.0;
InputInteger mc; //markov chain
OutputStatoAula stato;
OutputInteger capienzaOut;

initial equation
stato = StatoAula.agibile;
capienzaOut = capienza;

algorithm //l'aula transisce randomicamente

when sample(0, T) then
if (mc == 1) then 
	stato := StatoAula.agibile;
	capienzaOut := capienza;
else 
	stato := StatoAula.inagibile;
	capienzaOut := capienza;
	
end if;

end when;

end Aula;
