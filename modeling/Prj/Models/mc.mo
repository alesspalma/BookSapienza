block Markov_Chain

import Rng = MLibrary.Random.Generator ;

parameter Integer x_0 = 1;  // initial state MC
parameter Integer classe = 1; // 1 = markov chain per aula, 2 = markov chain per studente, 3 = markov chain per gomp
parameter Real T = 0.1;

OutputInteger x;

// Transition Matrix MC
Real probAula[2,2] =
[
0.9, 0.1; 
0.8, 0.2
];

Real probStudente[3,3] =
[
0.1, 0.8, 0.1;
0.5, 0.1, 0.4;
0.5, 0.4, 0.1
];

Real probGomp[2,2] =
[
0.7, 0.3;
0.7, 0.3
];

Rng.generator1024 randomGen(samplePeriod=0.1, globalSeed = 156, localSeed = 1689);


algorithm

when initial() then
        x := x_0;

elsewhen sample(0,T) then
        if (classe == 1) then
                x := pickStato(randomGen.r1024, pre(x), probAula);
        elseif (classe == 2) then
                x := pickStato(randomGen.r1024, pre(x), probStudente);
        else
                x := pickStato(randomGen.r1024, pre(x), probGomp);
				
        end if;
		
end when;


end Markov_Chain;


function pickStato
input Real z;   // uniformly random input
input Integer x;  // present state
input Real[:,:] A;   // Transition Matrix
output Integer w;  // next state

protected
Integer i;
Real y;

algorithm


i := 1;
y := A[x, i];

while ((z > y) and (i < size(A, 2))) loop
  i := i + 1;
  y := y + A[x, i];
end while;

w := i;

end pickStato;
