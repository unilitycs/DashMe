# Valori nulli in `ResultValue`

Il campo `ResultValue` di `Contamination_european_food.csv` (2.424.475 righe) ha tre casi:

| Valore | Significato | Righe |
|---|---|---|
| > 0 | Contaminante rilevato (positivo) | 959.424 |
| 0 | Analisi fatta, sotto la soglia di rilevabilità (< LOD) | 1.461.721 |
| vuoto (null) | Risultato mancante nel CSV | 3.330 |

Conteggi verificati sul CSV.

## Come vengono trattati

Su una riga con `ResultValue` vuoto non si può dire se l'analisi sia positiva o negativa, quindi quelle righe non entrano nel denominatore del tasso di positività.

```
Tasso di Positività % =
    DIVIDE(
        [Analisi Positive (> LOD)],
        CALCULATE(COUNTROWS(Fact_Contaminazioni), NOT(ISBLANK(Fact_Contaminazioni[ResultValue])))
    )
```

- Con i null esclusi: 959.424 / 2.421.145 = **39,63%** (valore mostrato nella card).
- Con tutte le righe: 959.424 / 2.424.475 = 39,57% (cifra citata in `REPORT_POWERBI.html`).

La differenza è di 0,06 punti percentuali. Si usa il 39,63%.
