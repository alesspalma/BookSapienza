block MonitorF2
//monitoriamo F2, quindi ogni studente può essere in una sola aula per ogni fascia oraria
parameter Integer numStudenti = 120;
parameter Integer numFasce = 3;

InputInteger prenotazioniStudenti[numStudenti, numFasce];

output Boolean z;

Integer w[numStudenti,numFasce]; //matrice d'appoggio, se w[i,j] = 1 significa che lo studente i per la fascia j è prenotato in un'aula
Boolean y;

initial equation
z = false;

equation
for i in 1:numStudenti loop
        for j in 1:numFasce loop
                w[i,j] = checkCella(prenotazioniStudenti[i,j]);
        end for;
end for;

y =  sum(w) > numStudenti * numFasce; //al massimo devo avere numStudenti * numFasce prenotazioni nel sistema, cioe' al massimo ogni studente ha una prenotazione per ogni fascia oraria

algorithm

when edge(y) then
        z := true;
end when;

end MonitorF2;



function checkCella

input Integer cella;
output Integer out;

algorithm

if (cella <> 0) then 
        out := 1;
else
        out := 0;
end if;


end checkCella;
