class System

Markov_Chain mcAula(classe=1);
Markov_Chain mcStudente(classe=2);
Markov_Chain mcGomp(classe=3);
Aula a;
Studente s;
Prodigit p;
Gomp g;
MonitorF1 mf1(numAule = p.numAule, numFasce = p.numFasce);
MonitorF2 mf2(numFasce = p.numFasce, numStudenti = p.numStudenti);
MonitorNF1 mnf1;
MonitorNF2 mnf2;

equation

//connessioni markov chain
connect (a.mc, mcAula.x);
connect (s.mc, mcStudente.x);
connect (g.mc, mcGomp.x);

//connessione studente-prodigit
connect (p.statoStud, s.stato);

//connessioni gomp
connect (g.stato, p.statoGomp);
connect (g.statoAulaIn, a.stato);
connect (g.statoAulaOut, p.statoAula);
connect (g.capienzaAuleIn, a.capienzaOut);
connect (g.capienzaAuleOut, p.capienza);

//connessioni monitor F1
connect (p.postiOccupati, mf1.postiOccupati);
connect (g.capienzaAuleOut, mf1.capienza);

//connessioni monitor F2
connect (p.prenotazioniStudenti, mf2.prenotazioniStudenti);

//connessioni monitor NF1
connect (p.pInCoda, mnf1.pInCoda);
connect (p.pTotGompDown, mnf1.pTotGompDown);

//connessioni monitor NF2
connect (p.richiesteTotali, mnf2.richiesteTotali);
connect (p.richiesteSoddisfatte, mnf2.richiesteSoddisfatte);

end System;
