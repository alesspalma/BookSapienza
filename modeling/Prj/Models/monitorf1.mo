block MonitorF1
//monitoriamo F1, quindi le prenotazioni non devono mai superare la capienza delle aule, o scendere sotto 0
parameter Integer numAule = 3;
parameter Integer numFasce = 3;

InputInteger postiOccupati[numAule, numFasce];
InputInteger capienza;
output Boolean z;

Boolean y;
Boolean w[numAule, numFasce]; //matrice d'appoggio, se w[i,j] = true vuol dire che per l'aula i la fascia j ha piu prenotazioni della capienza consentita, oppure meno di 0

initial equation
z = false;

equation

for i in 1:numAule loop
        for j in 1:numFasce loop
                w[i,j] = (postiOccupati[i,j] > capienza) or (postiOccupati[i,j] < 0);
        end for;
end for;

y = sum(w); //appena y diventa > 0 devo segnalare l'errore

algorithm

when edge(y) then
        z := true;
end when;

end MonitorF1;

