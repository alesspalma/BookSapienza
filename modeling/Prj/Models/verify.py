#usage: python3 verify.py
#obiettivo: garantire che il sistema rispetti i requisiti per un numero sufficiente di test

import os
import sys
import math
import numpy as np
import time
import os.path

from OMPython import OMCSessionZMQ

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

# begin testing

with open ("log", 'w') as f:
        f.write("Begin log"+"\n")
        f.flush()
        os.fsync(f)
        
with open ("output.txt", 'w') as f: #resoconto test passati e falliti
        f.write("Outcomes"+"\n\n")
        f.flush()
        os.fsync(f)

N = 200 # quantita' di samples di studenti che vengono testati
base_range_students = 100 # numero studenti di partenza
step_range_students = 5 # step con cui incrementiamo gli studenti tra un sample e l'altro
max_aule = 5
num_pass = 0
num_fail = 0

for i in range(1, max_aule+1): #aule

        for j in range(1, N+1): #studenti

                print("Test", i, "x", j)

                with open ("modelica_rand.in", 'w') as f: # scriviamo i parametri da sovrascrive nel sistema modelica
                        numStud = base_range_students + j * step_range_students # calcolo studenti per il test attuale
                        numAule = i

                        f.write("p.numStudenti="+str(numStud)+"\n"+"p.numAule="+str(numAule)+"\n")
                        f.flush()
                        os.fsync(f)

                        with open ("log", 'a') as f:
                                f.write("\nTest (numero aule = "+str(numAule)+", numero studenti = "+str(numStud)+", test n. = "+str(i)+" x "+str(j)+"):\n")
                                f.flush()
                                os.fsync(f)
        
                os.system("./System -overrideFile=modelica_rand.in >> log") # start simulation
                time.sleep(1.0)         # Delay to avoid races on file re-writings
                os.system("rm -f modelica_rand.in")    # to be on the safe side

                # prendiamo i valori dei monitor
                f1 = omc.sendExpression("val(mf1.z, 400.0, \"System_res.mat\")")
                f2 = omc.sendExpression("val(mf2.z, 400.0, \"System_res.mat\")")
                nf1 = omc.sendExpression("val(mnf1.y, 400.0, \"System_res.mat\")")
                nf2 = omc.sendExpression("val(mnf2.z, 400.0, \"System_res.mat\")")
                os.system("rm -f System_res.mat")      # to be on the safe side
        
                print("Monitor values at (num studenti =", numStud, ", num aule =", numAule, ", test n. =", i, "x", j, "): F1",  f1, "F2", f2, "NF1", nf1, "NF2", converti(nf2))

                if f1 <= 0.5 and f2 <= 0.5 and nf1 <= 0.5 and converti(nf2) == 0: # se non ci sono stati errori il test e' passato
                        num_pass += 1
                        with open ("output.txt", 'a') as g:
                                g.write("test n. "+str(i)+" x "+str(j)+" = : PASS with numStudenti = "+str(numStud)+", numAule = "+str(numAule)+"\n")
                                g.flush()
                                os.fsync(g)
                else:
                        num_fail += 1
                        failedMonitor = ""
                        if f1 >= 0.5: failedMonitor += "F1 failed " # controllo quali monitor falliscono
                        if f2 >= 0.5: failedMonitor += "F2 failed "
                        if nf1 >= 0.5: failedMonitor += "NF1 failed "
                        if converti(nf2) == 1: failedMonitor += "NF2 failed "
                        with open ("output.txt", 'a') as g:
                                g.write("test n. "+str(i)+" x "+str(j)+" = : FAIl with numStudenti = "+str(numStud)+", numAule = "+str(numAule)+": "+failedMonitor+"\n")
                                g.flush()
                                os.fsync(g)
                print()

tot_tests = num_pass + num_fail
print ("num pass =", num_pass, ", num fail =", num_fail, ", total tests =",  tot_tests)
print ("pass prob =", num_pass/tot_tests, ", fail prob =", num_fail/tot_tests)
