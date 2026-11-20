# Script di compilazione LaTeX (`docs/thesis`)

Questa directory contiene gli script cross-platform per compilare il documento LaTeX della tesi/relazione in `docs/thesis/` e rimuovere automaticamente i file intermedi di compilazione.

Entrambi gli script possono essere eseguiti da qualsiasi directory di lavoro e gestiscono correttamente percorsi con spazi, `&` e caratteri UTF-8 accentati.

## Script disponibili

- `scripts/build-thesis.sh` — Bash script per macOS, Linux e Git Bash / WSL.
- `scripts/build-thesis.ps1` — PowerShell script compatibile sia con Windows PowerShell 5.1 che con PowerShell 7+ (`pwsh`).

## Motori LaTeX supportati

Con `--engine auto` (o `-Engine auto`), gli script selezionano automaticamente il primo motore disponibile nel seguente ordine:

1. **`latexmk`** (solo se sia `latexmk` sia `perl` sono presenti nel `PATH`)
2. **`tectonic`**
3. **`pdflatex`** (+ `bibtex` se il file `.aux` contiene `\bibdata`, seguito da altri 2 passaggi)
4. **`xelatex`** (+ `bibtex` se necessario, seguito da altri 2 passaggi)
5. **`lualatex`** (+ `bibtex` se necessario, seguito da altri 2 passaggi)

Se nessun motore è disponibile:
- macOS: `brew install tectonic` oppure MacTeX (`brew install --cask mactex-no-gui`)
- Windows: `winget install Tectonic.Tectonic`, [MiKTeX](https://miktex.org/download) o [TeX Live](https://tug.org/texlive/)
- Linux: `tectonic` oppure `texlive-full`

## Opzioni / Parametri

| Funzione | Bash (`build-thesis.sh`) | PowerShell (`build-thesis.ps1`) | Default |
| --- | --- | --- | --- |
| File `.tex` principale (relativo a `thesis-dir`) | `--input <file>` | `-InputFile <file>` | `main.tex` |
| Directory sorgenti LaTeX | `--thesis-dir <dir>` | `-ThesisDir <dir>` | `docs/thesis` |
| Motore di compilazione | `--engine <motore>` | `-Engine <motore>` | `auto` |
| Mantieni i file intermedi dopo il build | `--keep-intermediates` | `-KeepIntermediates` | Disattivo |
| Elimina solo i file intermedi (senza compilare) | `--clean-only` | `-CleanOnly` | Disattivo |
| Mostra la guida | `-h`, `--help` | `-Help` | — |

Valori ammessi per il motore: `auto`, `latexmk`, `tectonic`, `pdflatex`, `xelatex`, `lualatex`.

## Esempi d'uso

### macOS / Linux (`scripts/build-thesis.sh`)

```bash
# 1. Compila main.tex e rimuovi automaticamente i file intermedi
./scripts/build-thesis.sh

# 2. Compila mantenendo i file intermedi (.aux, .log, .bbl, ...)
./scripts/build-thesis.sh --keep-intermediates

# 3. Pulisci soltanto i file intermedi senza compilare
./scripts/build-thesis.sh --clean-only

# 4. Forza un motore specifico
./scripts/build-thesis.sh --engine tectonic
```

### Windows PowerShell / `pwsh` (`scripts/build-thesis.ps1`)

```powershell
# 1. Compila main.tex e rimuovi automaticamente i file intermedi
.\scripts\build-thesis.ps1

# 2. Compila mantenendo i file intermedi
.\scripts\build-thesis.ps1 -KeepIntermediates

# 3. Pulisci soltanto i file intermedi senza compilare
.\scripts\build-thesis.ps1 -CleanOnly

# 4. Forza un motore specifico
.\scripts\build-thesis.ps1 -Engine tectonic
```

## Gestione file intermedi ed errori

- **A compilazione riuscita**: tutti i file intermedi (`.aux`, `.bbl`, `.blg`, `.bcf`, `.dvi`, `.fdb_latexmk`, `.fls`, `.idx`, `.ilg`, `.ind`, `.lof`, `.log`, `.lot`, `.nav`, `.out`, `.run.xml`, `.snm`, `.synctex.gz`, `.synctex(busy)`, `.toc`, `.vrb`, `.xdv`, `.acn`, `.acr`, `.alg`, `.glg`, `.glo`, `.gls`, `.ist`, `.loa`, `.lol`) vengono eliminati ricorsivamente da `docs/thesis/`, lasciando intatti `.tex`, `.bib`, `.pdf`, immagini, `.md` e `.gitkeep`.
- **In caso di errore**: i file `.log` vengono preservati per il debug e vengono stampate le ultime 40 righe del log.
