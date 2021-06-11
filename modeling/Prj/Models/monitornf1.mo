block MonitorNF1
//monitoriamo NF1, quindi il sistema deve salvare in coda almeno il 25% delle prenotazioni che arrivano mentre il gomp è down
InputInteger pTotGompDown;
InputInteger pInCoda;

output Boolean y;

Boolean w;

initial equation
y = false;

equation

w = (pInCoda/(pTotGompDown + 0.01)) < 0.25; //0.01 per evitare divisioni per zero


algorithm

when edge(w) then
        y := true;
end when;

end MonitorNF1;

