#usage: python3 verify.py
#obiettivo: massimizzare il valore p.T (timestep con cui prodigit puo cambiare stato online/offline)

import os
import sys
import math
import numpy as np
import time
import os.path

from OMPython import OMCSessionZMQ

print ("removing old System (if any) ...")
os.system("rm -f ./System")    # remove previous executable, if any.
print ("done!")

def converti(valore): # restituisce 0 se NF2 è soddsifatto, 1 altrimenti
        if valore < 0.9: return 1
        else: return 0

omc = OMCSessionZMQ()
omc.sendExpression("getVersion()")
omc.sendExpression("cd()")
omc.sendExpression("loadModel(Modelica)")
omc.sendExpression("getErrorString()")

omc.sendExpression("loadFile(\"../MLibrary/package.mo\")")
omc.sendExpression("getErrorString()")

omc.sendExpression("loadFile(\"connectors.mo\")")
omc.sendExpression("getErrorString()")

omc.sendExpression("loadFile(\"prodigit.mo\")")
omc.sendExpression("getErrorString()")

omc.sendExpression("loadFile(\"mc.mo\")")
omc.sendExpression("getErrorString()")

omc.sendExpression("loadFile(\"types.mo\")")
omc.sendExpression("getErrorString()")

omc.sendExpression("loadFile(\"aula.mo\")")
omc.sendExpression("getErrorString()")

omc.sendExpression("loadFile(\"gomp.mo\")")
omc.sendExpression("getErrorString()")

omc.sendExpression("loadFile(\"ctr.mo\")")
omc.sendExpression("getErrorString()")

omc.sendExpression("loadFile(\"studente.mo\")")
omc.sendExpression("getErrorString()")

omc.sendExpression("loadFile(\"monitorf1.mo\")")
omc.sendExpression("getErrorString()")

omc.sendExpression("loadFile(\"monitorf2.mo\")")
omc.sendExpression("getErrorString()")

omc.sendExpression("loadFile(\"monitornf1.mo\")")
omc.sendExpression("getErrorString()")

omc.sendExpression("loadFile(\"monitornf2.mo\")")
omc.sendExpression("getErrorString()")

omc.sendExpression("loadFile(\"system.mo\")")
omc.sendExpression("getErrorString()")

omc.sendExpression("buildModel(System, stopTime=400)")

#  Grid Search
p = 50 # number of grid points for T

# limiti T
min_T = 1.0
max_T = 6.0
delta_T = (max_T - min_T)/p

N = 50 # quantita' di samples di studenti che vengono testati
base_range_students = 100 # numero studenti di partenza
step_range_students = 5 # step con cui incrementiamo gli studenti tra un sample e l'altro

best_T = 0.0 # conterrà il miglior timestep T di prodigit
best_tempo_offline = -1.0 # conterrà il tempo che prodigit passa offline quando Prodigit.T=best_t

with open ("output.txt", 'w') as f: #resoconto test passati e falliti
        f.write("Outcomes"+"\n\n")
        f.flush()
        os.fsync(f)

for i in range(0, p): # ciclo sui timestep
        timestep = round(max_T - delta_T * i, 1) # calcolo timestep per i test attuali

        num_fail = 0.0
        num_pass = 0.0

        for j in range(1, N+1): # ciclo sul numero di studenti
                numStud = base_range_students + j * step_range_students  # calcolo studenti per il test attuale

                print ("Simulation number:",  i+1, "x", j, ", timestep:", timestep, "num_studenti:", numStud)

                with open ("modelica_rand.in", 'w') as f: # scriviamo i parametri da sovrascrive nel sistema modelica
                        f.write("p.T="+str(timestep)+"\n"+"p.numStudenti="+str(numStud)+"\n")
                        f.flush()
                        os.fsync(f)

                os.system("./System -overrideFile=modelica_rand.in >> log")  # start simulation
                time.sleep(1.0)  # Delay to avoid races on file re-writings
                os.system("rm -f modelica_rand.in")  # to be on the safe side

                print ("Simulation done!")

                # prendiamo i valori che ci interessano
                monitor = omc.sendExpression("val(mnf2.z, 400.0, \"System_res.mat\")")
                tempo_off = round(omc.sendExpression("val(p.tempoOffline, 400.0, \"System_res.mat\")"), 1)

                os.system("rm -f System_res.mat")      # .... to be on the safe side

                if (converti(monitor) == 0) : # feasible
                        num_pass += 1
                        if tempo_off > best_tempo_offline: # se massimizzo il tempo che prodigit puo restare offline
                                best_T = timestep # salvo i parametri che hanno portato test corretti
                                best_tempo_offline = tempo_off
                        with open ("output.txt", 'a') as g:
                                g.write("Feasible: p.T="+str(timestep)+", p.numStudenti="+str(numStud)+"; tempo offline= "+str(tempo_off)+"/400 = "+str(round(tempo_off/400*100, 1))+"%\n")
                                g.flush()
                                os.fsync(g)

                else: # infeasible
                        num_fail += 1
                        with open ("output.txt", 'a') as g:
                                g.write("Infeasible: p.T="+str(timestep)+", p.numStudenti="+str(numStud)+"; tempo offline= "+str(tempo_off)+"/400 = "+str(round(tempo_off/400*100, 1))+"%\n")
                                g.flush()
                                os.fsync(g)
                        break

        print("Simulations whit timestep=", timestep, "completed: num pass =", num_pass, ", num fail =", num_fail)
        if (best_tempo_offline != -1.0): print("The best until now is timestep=", best_T, "offline time=", best_tempo_offline, "("+str(round(best_tempo_offline/400*100, 1))+"%)")
        print()


print ("Best solution: ")
print ("timestep =", best_T, "tempo offline =", str(best_tempo_offline)+"/400", "percentage =", str(round(best_tempo_offline/400*100, 1))+"%")