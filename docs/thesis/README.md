# Documentazione LaTeX -- Progetto DashMe

Questa cartella contiene il sorgente LaTeX dell'elaborato accademico per il corso di **Project Management & Business Intelligence** (Università Politecnica delle Marche -- UnivPM).

## Struttura della cartella

```text
docs/
├── Tableau/                    # Esportazioni immagini delle dashboard Tableau
│   ├── Dash1.jpeg              # Dashboard 1 (già presente)
│   └── Dash3.png               # Dashboard 3 (già presente)
└── thesis/
    ├── main.tex                # Documento principale (copertina, abstract, capitoli, bibliografia)
    ├── preamble.tex            # Pacchetti, palette colori, header/footer e macro custom
    ├── references.bib          # Bibliografia in formato BibTeX (natbib + unsrtnat)
    ├── figures/                # Eventuali figure aggiuntive locali al documento
    │   └── .gitkeep
    ├── sections/               # Capitoli dell'elaborato (01_introduction ... 05_conclusions)
    └── README.md               # Questa guida
```

## Macro personalizzate disponibili (`preamble.tex`)

Nelle sezioni (`docs/thesis/sections/*.tex`) è possibile utilizzare le seguenti macro:

- **`\todo{testo}`**: inserisce un riquadro monocromatico `[DA COMPLETARE: testo]` per segnalare parti da integrare manualmente (sicuro sia inline sia come breve paragrafo).
- **`\dashboardfig[larghezza]{nome_file}{didascalia}{etichetta}`**: inserisce una figura centrata cercando prima in `docs/Tableau/<nome_file>` e poi in `docs/thesis/figures/<nome_file>`. Se l'immagine non esiste ancora (es. `Dash2.png`), genera automaticamente un riquadro segnaposto senza errori di compilazione.
  - Esempio: `\dashboardfig{Dash1.jpeg}{Geografia industriale e profili di rischio.}{fig:dash1}`
- **`\keyinsight{titolo}{corpo}`**: inserisce un riquadro evidenziato di sintesi in scala di grigi (bordo nero, sfondo grigio neutro) per mettere in risalto i principali risultati analitici.

## Aggiungere `Dash2.png`

La Dashboard 2 non è ancora stata esportata. Per includerla automaticamente nell'elaborato:

1. Esportare la dashboard da Tableau (`src/Tableau/dashsmash3.twb`) in formato PNG o JPEG.
2. Salvare il file esattamente come `docs/Tableau/Dash2.png`.
3. Ricompilare il documento: il segnaposto verrà sostituito automaticamente dall'immagine esportata.

## Compilazione e pulizia

Dalla radice del repository è possibile compilare l'elaborato (tramite Tectonic o `latexmk`/TeX standard) e ripulire i file ausiliari utilizzando gli script dedicati:

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
