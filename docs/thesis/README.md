# Documentazione LaTeX -- Progetto DashMe

Questa cartella contiene il sorgente LaTeX dell'elaborato accademico per il corso di **Project Management & Business Intelligence** (Università Politecnica delle Marche -- UnivPM), dedicato all'analisi multi-piattaforma della sicurezza alimentare e regolatoria tramite **Qlik Sense (RASFF)**, **Tableau (FDA)** e **Microsoft Power BI (EFSA / WHO GEMS)**.

## Struttura della cartella

```text
docs/
├── Tableau/                                # Esportazioni originali Tableau
├── PowerBI/                                # Esportazioni originali Power BI (PDF)
└── thesis/
    ├── main.tex                            # Documento principale (copertina, abstract, indice, 7 capitoli, bibliografia)
    ├── preamble.tex                        # Pacchetti, tipografia, header/footer e macro custom
    ├── references.bib                      # Bibliografia in formato BibTeX (natbib + unsrtnat)
    ├── images/                             # Tutte le 10 tavole delle dashboard integrate nell'elaborato
    │   ├── qlik_sintesi_esecutiva.png      # Qlik Sense - Dashboard 1
    │   ├── qlik_geopolitica_controlli.png  # Qlik Sense - Dashboard 2
    │   ├── qlik_matrici_alimentari.png     # Qlik Sense - Dashboard 3
    │   ├── qlik_tracciabilita_supply_chain.png # Qlik Sense - Dashboard 4
    │   ├── tableau_dash1.jpeg              # Tableau - Dashboard 1
    │   ├── tableau_dash2.png               # Tableau - Dashboard 2
    │   ├── tableau_dash3.png               # Tableau - Dashboard 3
    │   ├── powerbi_dash1.png               # Power BI - Dashboard 1
    │   ├── powerbi_dash2.png               # Power BI - Dashboard 2
    │   └── powerbi_dash3.png               # Power BI - Dashboard 3
    ├── figures/                            # Eventuali figure aggiuntive locali al documento
    │   └── .gitkeep
    ├── sections/                           # I 7 capitoli dell'elaborato
    │   ├── 01_introduction.tex             # Capitolo 1: Introduzione e Research Questions
    │   ├── 02_methodology.tex              # Capitolo 2: Metodologia e Architettura Multi-Piattaforma
    │   ├── 03_qlik_analysis.tex            # Capitolo 3: Analisi Qlik Sense (RASFF)
    │   ├── 04_tableau_analysis.tex         # Capitolo 4: Analisi Tableau (FDA)
    │   ├── 05_powerbi_analysis.tex         # Capitolo 5: Analisi Power BI (EFSA / WHO GEMS)
    │   ├── 06_discussion.tex               # Capitolo 6: Discussione Trasversale e Comparazione BI
    │   └── 07_conclusions.tex              # Capitolo 7: Conclusioni e Sviluppi Futuri
    └── README.md                           # Questa guida
```

## Macro personalizzate disponibili (`preamble.tex`)

Nelle sezioni (`docs/thesis/sections/*.tex`) sono disponibili le seguenti macro personalizzate:

- **`\dashboardfig[larghezza]{nome_file}{didascalia}{etichetta}`**: inserisce una figura centrata cercando in sequenza nei percorsi `docs/thesis/images/<nome_file>`, `docs/thesis/figures/<nome_file>` e infine `docs/Tableau/<nome_file>`. Nel caso in cui il file non sia presente su disco, genera automaticamente un riquadro segnaposto pulito senza interrompere la compilazione LaTeX.
  - Esempio: `\dashboardfig{qlik_sintesi_esecutiva.png}{Dashboard 1 Qlik Sense: Sintesi Esecutiva e Valutazione dei Rischi.}{fig:qlik_dash1}`
- **`\keyinsight{titolo}{corpo}`**: inserisce un riquadro evidenziato di sintesi in scala di grigi (bordo nero, sfondo grigio neutro) per mettere in risalto i principali risultati analitici.
- **`\todo{testo}`**: inserisce un riquadro monocromatico `[DA COMPLETARE: testo]` per segnalare eventuali annotazioni redazionali pendenti (nessun `\todo` deve permanere nella versione finale).

## Compilazione e pulizia

Dalla radice del repository è possibile compilare l'elaborato (tramite Tectonic, `latexmk` o distribuzione TeX standard) e ripulire i file ausiliari utilizzando gli script dedicati:

- **macOS / Linux**:
  ```bash
  ./scripts/build-thesis.sh
  ./scripts/build-thesis.sh --clean-only
  ```
- **Windows (PowerShell)**:
  ```powershell
  .\scripts\build-thesis.ps1
  .\scripts\build-thesis.ps1 -CleanOnly
  ```

> **Nota sul percorso del repository:** il percorso locale può contenere spazi, `&` e caratteri accentati; tutte le inclusioni in `main.tex` e `preamble.tex` utilizzano esclusivamente percorsi relativi per garantire la portabilità tra Tectonic, pdfLaTeX, XeLaTeX e LuaLaTeX.
