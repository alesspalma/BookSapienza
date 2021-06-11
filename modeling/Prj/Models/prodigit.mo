block Prodigit

import Rng = MLibrary.Random.Generator;

parameter Integer numStudenti = 120;
parameter Integer numAule = 3;
parameter Integer numFasce = 3;

parameter Real T = 4.2; //valore trovato tramite il synth.py, massimizza il tempo che prodigit puo passare offline pur soddisfacendo il requisito NF2
parameter Real soglia = 0.1; //probabilita' con cui prodigit puo cambiare stato

InputStatoStudente statoStud;
InputStatoAula statoAula;
InputInteger capienza;
InputStatoGomp statoGomp;

OutputInteger prenotazioniStudenti[numStudenti, numFasce]; //prenotazioniStudenti[i,j] = id aula per cui lo studente i è prenotato nella fascia oraria j
OutputInteger postiOccupati[numAule, numFasce]; //postiOccupati[i,j] = numero di prenotati per l'aula i nella fascia oraria j
OutputInteger pTotGompDown, pInCoda; //pTotGompDown = prenotazioni totali che arrivano mentre il gomp è down, pInCoda = prenotazioni messe in coda mentre il gomp è down
OutputInteger richiesteTotali, richiesteSoddisfatte; //richiesteTotali = richieste totali degli studenti che arrivano durante l'esecuzione, richiesteSoddisfatte = richieste che arrivano mentre prodigit è online
output RispostaPrenotazione risposta; //risposta di prodigit ad una richiesta di prenotazione o cancellazione

Real tempoOffline; //tempo passato da prodigit nello stato offline

StatoProdigit statoProd;

Integer coda[numStudenti, numFasce]; //coda[i,j] = id aula per cui lo studente i si vuole prenotare nella fascia oraria j, ma gomp è attualmente offline quindi non possiamo risolvere la richiesta

//distribuzioni di probabilità uniformi, calcolate in base ai parametri di input
Real distrFasce[numFasce] = {1/numFasce for i in 1:numFasce};
Real distrAula[numAule] = {1/numAule for i in 1:numAule};
Real distrStudente[numStudenti] = {1/numStudenti for i in 1:numStudenti};

Rng.generator1024 randomGenAula(samplePeriod=0.1, globalSeed = 46534, localSeed = 851);
Rng.generator1024 randomGenStudente(samplePeriod=0.1, globalSeed = 12, localSeed = 9433);
Rng.generator1024 randomGenFasce(samplePeriod=0.1, globalSeed = 2972, localSeed = 3838);
Rng.generator1024 randomGenProdigit(samplePeriod=0.1, globalSeed = 111, localSeed = 34328);

Integer s,a,f; //variabili di appoggio: studente, aula, fascia
discrete Real t1;

initial equation
statoProd = StatoProdigit.online;

algorithm

when sample(0, T) then //prodigit puo cambiare stato tra online e offline
        if(pre(statoProd)==StatoProdigit.offline) then //accumulo il tempo che prodigit passa nello stato offline per fare una misurazione
                tempoOffline := tempoOffline + (time - t1);
        end if;
        if (randomGenProdigit.r1024 > soglia) then
                statoProd := StatoProdigit.online;
        else
                t1 := time;
                statoProd := StatoProdigit.offline;
        end if;
end when;

//se lo studente vuole prenotare
when (statoStud == StatoStudente.vuolePrenotare) then
        richiesteTotali := richiesteTotali + 1;
        if (statoProd == StatoProdigit.online) then
                richiesteSoddisfatte := richiesteSoddisfatte + 1;
                //prendo una terna s,a,f randomica
                s := pick(randomGenStudente.r1024, distrStudente);
                a := pick(randomGenAula.r1024, distrAula);
                f := pick(randomGenFasce.r1024, distrFasce);
                if (statoGomp == StatoGomp.up) then
                        if (statoAula == StatoAula.agibile) and (capienza > postiOccupati[a, f]) and (prenotazioniStudenti[s, f] == 0) then //se l'aula è agibile, c'e' posto, e lo studente era libero per quella fascia oraria allora lo prenoto
                                postiOccupati[a, f] := postiOccupati[a, f] + 1;
                                prenotazioniStudenti[s, f] := a;
                                risposta := RispostaPrenotazione.confermata;
                        else
                                risposta := RispostaPrenotazione.rifiutata;
                        end if;
                //se gomp è down e lo studente è gia prenotato in quella fascia oppure ha gia una prenotazione in coda
                elseif (prenotazioniStudenti[s, f] <> 0) or (coda[s, f] <> 0) then
                        risposta := RispostaPrenotazione.rifiutata;
                        pTotGompDown := pTotGompDown + 1;

                //se gomp è down e lo studente è libero in quella fascia e non ha nessuna prenotazione in coda
                elseif (prenotazioniStudenti[s, f] == 0) and (coda[s, f] == 0) then
                        coda[s, f] := a;
                        risposta := RispostaPrenotazione.inCoda;
                        pInCoda := pInCoda + 1;
                        pTotGompDown := pTotGompDown + 1;
                end if;
        end if;

//se lo studente vuole cancellare
elsewhen (statoStud == StatoStudente.vuoleCancellare) then
        richiesteTotali := richiesteTotali + 1;
        if (statoProd == StatoProdigit.online) then
                richiesteSoddisfatte := richiesteSoddisfatte + 1;
	        s := pick(randomGenStudente.r1024, distrStudente);
	        a := pick(randomGenAula.r1024, distrAula);
	        f := pick(randomGenFasce.r1024, distrFasce);
	        if (prenotazioniStudenti[s, f] == a) then //permettiamo la cancellazione solo se lo studente era effettivamente prenotato per quell'aula in quella fascia
		        postiOccupati[a, f] := postiOccupati[a, f] - 1;
		        prenotazioniStudenti[s, f] := 0;
		        risposta := RispostaPrenotazione.cancellata;
	        end if;
	end if;
	
end when;

//quando gomp transisce da down a up risolvo tutte le prenotazioni che sono state messe in coda, controllando se gli studenti hanno diritto o meno ad essere prenotati
when (statoGomp == StatoGomp.up) then
        for i in 1:numStudenti loop
                for j in 1:numFasce loop
                        if (coda[i,j] <> 0) and (statoAula == StatoAula.agibile) then
                                if (capienza > postiOccupati[coda[i,j], j]) then
                                        postiOccupati[coda[i,j], j] := postiOccupati[coda[i,j], j] + 1;
                                        prenotazioniStudenti[i, j] := coda[i,j];
                                end if;
                        end if;
                        coda[i,j] := 0;
                end for;
        end for;
end when;

	
end Prodigit;


function pick

input Real random;
input Real distribuzione[:];
output Integer out;

protected
Integer i;
Real acc;

algorithm
i := 1;
acc := distribuzione[i];
while((random > acc) and (i < size(distribuzione,1))) loop
	i := i+1;
	acc := acc + distribuzione[i];
end while;
out := i;

end pick;

