block Gomp

parameter Real T = 1.0;

InputInteger mc; //markov chain
InputStatoAula statoAulaIn; //il gomp mostra a prodigit lo stato e la capienza delle aule
InputInteger capienzaAuleIn;
OutputStatoGomp stato;
OutputStatoAula statoAulaOut;
OutputInteger capienzaAuleOut;

initial equation
stato = StatoGomp.up;

equation
statoAulaOut = statoAulaIn;
capienzaAuleOut = capienzaAuleIn;

algorithm //il gomp transisce randomicamente

when sample(0,T) then

if (mc == 1) then 
	stato := StatoGomp.up;
else 
	stato := StatoGomp.down;

end if;

end when;

end Gomp;


