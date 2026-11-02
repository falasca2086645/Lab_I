# Grafici MATLAB su Ubuntu

## Uso normale

```matlab
S = load('3_1_Misura_Sinusoide_Vp1V_f1Mhz_SPAN50kHz_RBW1kHz..mat');
[fig, ax, linee] = plotDataStruct(S.dataStruct);
```

La funzione usa direttamente `xaxis`, `formattedData` e, se presente,
`xlabel`. Poiché i file forniti non contengono `ylabel`, l'asse verticale
viene chiamato automaticamente `power (dBm)`. Il formato predefinito
riproduce il JPEG di riferimento: linea rossa continua, asse in Hz, font
Helvetica 22, griglia, riquadro e spessore 2.

Per salvare il risultato:

```matlab
savefig(fig, 'grafico.fig')
exportgraphics(fig, 'grafico.png', Resolution=300, BackgroundColor='white')
```

Esempi di personalizzazione:

```matlab
plotDataStruct(S.dataStruct, YLimits=[-120 10])
plotDataStruct(S.dataStruct, FrequencyUnit="MHz")
plotDataStruct(S.dataStruct, Title="Misura 3.1", YLabel="Potenza (dBm)")
```

## Perché la funzione crea molti segmenti brevi

Su questa installazione (MATLAB R2025b, Ubuntu 22.04 e driver grafico Mesa)
una singola polyline lunga può essere visualizzata o esportata con grandi
tratti mancanti. Anche il fondo bianco degli assi può diventare nero.

`plotDataStruct` aggira entrambi i difetti senza modificare i dati:

- ogni coppia di campioni è una breve linea rossa; tutti i segmenti uniti
  appaiono come una sola curva continua;
- un rettangolo bianco reale viene posto dietro alla curva;
- i limiti e i tick mostrano sempre i valori fisici originali.

Non sostituire i segmenti con un unico `plot(x,y)` su questa macchina: nei
test del 18 ottobre 2026 il difetto ricompare sia con OpenGL sia con Painters.

## Installazione e aggiornamenti

Non servono toolbox o pacchetti MATLAB aggiuntivi. La funzione usa soltanto
funzioni base disponibili da MATLAB R2021a. MATLAB installato: R2025b
(25.2.0.2998904).

Non installare il vecchio driver Intel `i965`: la GPU Intel Iris Plus usa il
driver Mesa `iris`. Gli aggiornamenti ordinari di Ubuntu sono consigliabili,
ma non sono necessari per usare il workaround incluso nella funzione.

## Vecchi file FIG

I vecchi FIG possono contenere la polyline che innesca il difetto. Per un
risultato affidabile conviene ricaricare il MAT e chiamare `plotDataStruct`,
anziché aprire direttamente il FIG.
