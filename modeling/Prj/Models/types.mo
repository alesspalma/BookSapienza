type StatoAula = enumeration(
agibile,
inagibile);

type StatoStudente = enumeration(
nulla,
vuolePrenotare,
vuoleCancellare);

type StatoGomp = enumeration(
up,
down);

type StatoProdigit = enumeration(
online,
offline);

//possibili risposte del sistema prodigit ad una richiesta di prenotazione o cancellazione di uno studente
type RispostaPrenotazione = enumeration(
confermata,
rifiutata,
inCoda,
cancellata);
