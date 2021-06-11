block MonitorNF2
//monitoriamo NF2, quindi prodigit deve garantire che almeno il 90% delle richieste totali siano soddisfatte

InputInteger richiesteTotali; //richieste totali arrivate a prodigit
InputInteger richiesteSoddisfatte; //richieste arrivate mentre prodigit era online

output Real z;

equation

z = (richiesteSoddisfatte / (richiesteTotali + 0.01)); //0.01 per evitare divisioni per zero

end MonitorNF2;

