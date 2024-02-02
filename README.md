# Progetto calcolatrice

**Materia**: architettura degli elaboratori
**Anno accademico**: 2023/2024
**Studente**: Emanuele Galiano

# Strumenti utilizzati

Visual2 versione 2.0.8

# Obiettivo

Creare un programma che svolgesse le 4 operazioni nell’insieme dei numeri Razionali presi come parametri:

1. indirizzi di memoria degli operandi;
2. indirizzo di memoria del tipo di operazione (0 niente, 1 somma, 2 sottrazione, 3 moltiplicazione, 4 divisione);

e restituisse il risultato in due indirizzi di memoria precedentemente scelti.

# Svolgimento

## Allocazione della memoria per input e output (r1-r4)

```nasm
operands     dcd     -23, -5 ; operands
operation    dcd     4 ; 0: exit, 1: sum, 2: subtract, 3: product, 4: division
result       fill    4 ; allocating memory for future result
rem          fill    4 ; allocating space for the remain
```

## Assegnamento dei registri e dei valori in input (r10-r17)

```nasm
main         
             ;       register loading
             mov     r0, #operands
             mov     r2, #operation
             mov     r10, #0
             ldr     r1, [r0, #4]
             ldr     r0, [r0]
             ldr     r2, [r2]
```

In questo codice il registro r0 è utilizzato per il primo operando dell’operazione ed il resto della divisione, r1 per il secondo, r2 per il tipo di operazione e r10 inizialmente inizializzato a 0 per il risultato dell’operazione.

## Decisione dell’operazione da svolgere (r22-r41)

```nasm
	   				 cmp     r2, #0
             beq     finish

             ;       jumping to the sum
             cmp     r2, #1
             beq     sum

             ;       jumping to the subtraction
             cmp     r2, #2
             beq     subtraction

             ;       jumping to the product
             cmp     r2, #3
             beq     product

             ;       jumping to the division
             cmp     r2, #4
             beq     division

             b finish
```

Grazie al registro r2, precedentemente caricato con l’operazione da svolgere, si sceglie la parte di programma da svolgere con dei salti condizionali. Il numero zero viene utilizzato come terminazione del codice; è specificato nel caso si volessero aggiungere altre operazioni in futuro. I numeri da 1 a 4 sono le 4 operazioni come commentato nel codice e tutti gli altri possibili numeri caricati in r2 restituiscono nell’allocazione di memoria del risultato il primo operando.

## Somma (r43-r46)

```nasm
;       SUM
sum          
             add     r10, r0, r1 ; operation
             b       finish ; jumping to the end
```

Una somma del registro r0 al registro r1 salvata in r10. Dopo il programma salta nell’etichetta **finish.**

## Differenza (r49-r52)

```nasm
;       SUBTRACTION
subtraction  
             sub     r10, r0, r1 ; operation
             b       finish ; jumping to the end
```

Una sottrazione tra il registro r0 e il registro r1 salvata in r10. Dopo il programma salta nell’etichetta **finish.**

## Prodotto (r55-r82)

```nasm
;       PRODUCT
product      
             ;       conditional
             cmp     r1, #0 ; check if is negative or zero
             blt     calcNeg
             cmp     r0, #0 ; check if is zero
             beq     zero

             ;       if the second operand is positive
calcPos      
             add     r10, r10, r0 ; operation with a cicle
             subs    r1, r1, #1
             bgt     calcPos ; jumping to the cicle

             b       finish ; jumping to the

             ;       if the second operand is negative
calcNeg      
             sub     r10, r10, r0
             adds    r1, r1, #1
             ble     calcNeg

             b       finish

             ;       if the first of second operand is zero
zero         
             mov     r10, #0
             b       finish ; jumping to the end
```

Il programma per prima cosa controlla il segno del secondo operando, visto che il tipo di calcolo da effettuare dipende unicamente da quello. Se r1 è minore di 0 allora fa una serie di sottrazioni in r10 del primo operando (vedere calcNeg) tante volte quanto è grande r1 e dopo salta alla fine, se r0 è uguale a 0 pone il risultato uguale a 0 e salta alla fine mentre se il secondo operando è positivo (per esclusione rimane solo questo caso) fa una serie di addizioni in r10 del primo operando tante volte quanto è grande r1 e dopo salta alla fine.

## Divisione (r85-r148)

In questo programma viene eseguita la divisone Euclidea: tale divisione deve rispettare la formula:

$$
a = qb+r
$$

Dove $a$ è il primo operando, $q$ è il quoziente della divisione, $b$ è il secondo operando ed $r$ è il resto.

```nasm
division     ;       a = qb + r is the formula of the euclidean division

             cmp     r0, #0
             cmp     r1, #0
             moveq   r0, #0
             moveq   r10, #0
             beq     finish
```

Come primo passo il programma individua se almeno uno dei due operandi è 0. Per semplicità, basta che uno dei due operandi sia 0 per avere 0 come risultato e 0 come resto. Questi compare agiscono da or logico e nel caso almeno uno dei due sia uguale salta alla fine.

```nasm
             cmp     r0, #0 ; comparing first operand with zero
             movgt   r3, #1
             movlt   r3, #0
             rsblt   r0, r0, #0 ; abs value of r0

             cmp     r1, #0 ; comparing second operand with zero only if the first one is greater than 0
             movgt   r4, #1
             movlt   r4, #0
             rsblt   r1, r1, #0 ; abs value of r0
```

Dopo il programma utilizza r3 ed r4 come bit di stato dei due operandi, caricando 1 se il segno è positivo e 0 se è negativo rispettivamente per il primo e secondo operando in r3 ed r4. Dopo utilizza l’operazione **rsb** per trasformare r0 ed r1 nei rispettivi valori assoluti.

```nasm
;       if first operand < second operand skip to the sign check
             cmp     r0, r1
             blt     firstCheck
```

Prima di eseguire la vera e proprio divisione, per ottimizzazione del codice il programma controlla se la divisione è possibile con un confronto tra i due operandi, nel caso salta al controllo del risultato.

```nasm
;       division loop
divisionLoop 
             add     r10, r10, #1
             sub     r0, r0, r1

             cmp     r0, r1
             bge     divisionLoop
```

Il programma esegue un ciclo sommando 1 al risultato e sottraendo al primo operando il secondo. Il ciclo continua finché il primo operando è maggiore del secondo e una volta finito il ciclo in r0 non sarà rimasto più il primo operando ma il resto della divisione.

La divisione Euclidea, per essere eseguita in modo semplice, presenta 4 possibili scenari:

### Primo caso

Il primo caso di questa divisione prevede primo e secondo operando maggiori di zero, che è il caso ideale poiché il programma segna sia in r3 e r4 il valore 1. Il programma non esegue nessun tipo di modifica al risultato (vale $a = qb+r$ per com’è scritta).

### Secondo caso

Il secondo caso prevede il primo operando negativo e il secondo positivo. Come visto prima, il programma segna i bit di stato, in questo caso r3 ha come valore zero ed r4 come valore uno. Una volta accertatasi che siamo in questo caso si modifica la formula:

$$
a = (-q'-1)b + (b-r')
$$

Con $q'$ quoziente della divisione positiva e $r'$ resto della divisione positiva

### Terzo caso

Il terzo caso prevede il primo operando positivo ed il secondo negativo. Una volta segnati i bit di stato con valori r3 uno ed r4 zero, la formula viene modificata:

$$
a = (-q')b+r'
$$

Con $q'$ quoziente della divisione intera ed $r'$ resto della divisione intera.

### Quarto caso

L’ultimo caso prevede sia primo che secondo operando negativi, quindi segna come bit di stato zero e zero in r3 ed r4. La formula viene modificata:

$$
a = (q'+1)b-b-r'
$$

Sempre con $q'$ quoziente della divisione intera e $r'$ resto della divisione intera.

### Controlli

```nasm
firstCheck   ;       condition check of the control bits
             cmp     r3, #0
             bgt     secondCheck
             cmp     r4, #0
             bgt     secondCase
             beq     fourthCase

secondCheck  
             cmp     r4, #0
             bgt     finish
             beq     thirdCase
```

Per prima cosa il programma controlla se il bit di stato del primo operando (r3) è 0, nel caso lo sia significa che siamo nel primo o nel terzo caso e allora controlla il secondo bit di stato. Se è 1 allora va alla fine (il primo caso non modifica i valori del risultato e del resto) altrimenti salta all’etichetta **thirdCase** se uguale a 0.

Se il primo operando ha come bit di stato 0 significa che siamo nel secondo o quarto caso, controlla il bit di stato del secondo operando e salta all’etichetta **secondCase** nel caso sia positivo, **fourthCase** se è uguale a 0.

```nasm
secondCase    ;       first case: first operand < 0, second operand > 0 aka r3 = 0, r4 = 1
             rsb     r10, r10, #0
             sub     r10, r10, #1
             sub     r0, r1, r0
             b       finish

thirdCase   ;       second case: first operand > 0, second operand < 0 aka r3 = 1, r4 = 0
             rsb     r10, r10, #0
             b       finish

fourthCase    ;       third case: first operand < 0, second operand < 0 aka r3 = 0, r4 = 0
             add     r10, r10, #1
             sub     r0, r1, r0 ; should be -(second operand) - remainder but we changed the sign before
             b       finish
```

Il programma modifica il risultato ed il resto (rispettivamente r10 ed r0) come descritto in precedenza. In qualsiasi caso dopo salta alla fine

## Fine (r151-r170)

```nasm
;       FINISH
finish       
             mov     r11, #result ; moving to r11 the address of the result
             str     r10, [r11] ; storing the result from register r10 to the result allocation, previously stored on r11

             cmp     r2, #4 ; if the operation is the division, also save in memory the remainder
             moveq   r12, #rem
             streq   r0, [r12]

             ;       clearing the registers
             mov     r0, #0
             mov     r1, #0
             mov     r2, #0
             mov     r3, #0
             mov     r4, #0
             mov     r10, #0
             mov     r11, #0
             mov     r12, #0
             ;       end of the program
             end
```

Il programma giunge alla fine dopo fa la store di r10 (il risultato delle operazioni) nell’allocazione di memoria del risultato, ottenuta tramite registro r11. 

Fa un confronto tra r2 (l’operazione di esecuzione) e 4 (il numero scelta della divisione), se è uguale copia l’indirizzo del resto in r12 e poi fa la store di r0 (il resto della divisione) in quel risultato. Dopo azzera tutti i registri utilizzati nel programma.

## Bibliografia

**Divisione Euclidea**: dispense di strutture discrete (V. Cutello)