# Assignment 1 – Parte 1: timeout RUN → IDLE

Policy di default del simulatore: solo transizioni Run ↔ Idle, Sleep mai usato.
Unità del simulatore: tempo in **ms**, potenza in **mW**, energia in **mJ**. Nota utile: **mW · ms = µJ**.

## PSM

| Stato | Potenza |
|---|---|
| Run | 27.6 mW |
| Idle | 0.57 mW |
| Sleep | 0.09 mW (non usato in questa parte) |

| Transizione | Energia | Tempo |
|---|---|---|
| Run → Idle | 0.01 mJ | 0.4 ms |
| Idle → Run | 0.01 mJ | 0.4 ms |

Costo di un'andata e ritorno Run → Idle → Run: $E_{tr} = 0.02\ mJ = 20\ \mu J$, $T_{tr} = 0.8\ ms$.

## Quando conviene andare in Idle (break-even)

Per un gap di inattività di durata $T$, entrare in Idle conviene se:

$$T_{be} = \max\left(T_{tr},\ \frac{E_{tr} - P_{idle}\,T_{tr}}{P_{run} - P_{idle}}\right)$$

- $T \ge T_{tr}$: il gap deve essere abbastanza lungo da contenere andata e ritorno.
- Pareggio energetico: l'energia spesa con la transizione deve essere minore di quella spesa restando in Run.

Con i valori del PSM:

$$T_{be} = \max\left(0.8\ ms,\ \frac{20 - 0.57\cdot 0.8}{27.6 - 0.57}\ ms\right) = \max(0.8,\ 0.72) = \mathbf{0.8\ ms}$$

La soglia è imposta dal vincolo di tempo, non da quello energetico.

Ogni ms passato in Run invece che in Idle costa **27.03 µJ** ($= 27.6 - 0.57$ mW $\times$ 1 ms).

Esempio con un gap di 3 ms:
- restare in Run: $27.6 \cdot 3 = 82.8\ \mu J = \mathbf{0.083\ mJ}$
- passare da Idle: $0.02\ mJ$ di transizioni + $0.57 \cdot 2.2 \approx 1.3\ \mu J$ in Idle $\approx \mathbf{0.021\ mJ}$

Anche per un gap di 3 ms l'Idle conviene di circa 4 volte.

## Struttura dei due workload (gap = arrivo − fine del lavoro precedente)

| | workload_1 (sensori "fast") | workload_2 (sensori "slow") |
|---|---|---|
| Gap totali | 104 | 99 |
| Gap lunghi (attesa tra cicli) | 9, circa 120 s | 9, circa 120 s |
| Gap corti (tra letture sensori) | 76 da 1 a 4 ms, più 19 gap da 0 ms (nessuna inattività) | 89 da 77 a 118 ms, più un gap iniziale da 994 ms |
| Tempo attivo | 2.924 s | 2.547 s |
| Energia senza DPM | 29.879 J | 30.139 J |

Nel workload_1 tutti i gap non nulli (≥ 1 ms) sono sopra $T_{be} = 0.8$ ms. Nel workload_2 sono tutti centinaia di volte sopra. In nessuno dei due esiste un gap in cui restare in Run convenga.

## Workload 1: risultati

| Timeout (ms) | N. transizioni | Waiting in Run (s) | Energia con DPM (J) |
|---|---|---|---|
| 0 | 170 | 0.0085 | **0.69800** |
| 5 | 18 | 0.2651 | 0.70345 |
| 10 | 18 | 0.3101 | 0.70466 |
| 15 | 18 | 0.3551 | 0.70588 |
| 25 | 18 | 0.4451 | 0.70831 |
| 30 | 18 | 0.4901 | 0.70953 |
| 35 | 18 | 0.5351 | 0.71074 |
| 40 | 18 | 0.5801 | 0.71196 |
| 50 | 18 | 0.6701 | 0.71439 |
| 60 | 18 | 0.7601 | 0.71683 |

Energia senza DPM: 29.879 J. Con timeout 0 il risparmio è del **97.7 %**.

Cosa si vede e perché:

1. **Il minimo è a T = 0.** Ogni ms di timeout è tempo speso in Run senza lavorare, a 27 µJ/ms in più rispetto a Idle. Con $T_{be} = 0.8$ ms nessun gap non nullo è abbastanza corto da rendere la transizione svantaggiosa, quindi aspettare non evita mai una transizione inutile: costa e basta.
2. **Salto da 170 a 18 transizioni tra T = 0 e T = 5.** I 76 gap corti durano al massimo 4 ms, quindi con T ≥ 5 il timeout non scade mai al loro interno e restano interamente in Run. Restano solo le 9 coppie dei gap lunghi (9 × 2 = 18). Il passaggio è graduale tra 0 e 5: per esempio con T = 1 le transizioni sono 138 e con T = 3 sono 82, perché i gap da 1, 2, 3 ms vengono esclusi uno dopo l'altro.
3. **Salita lineare per T ≥ 5.** Da 5 a 60 ms l'energia cresce di 13.38 mJ, cioè 0.243 mJ per ms di timeout in più. Corrisponde a $9 \times 27.03\ \mu J = 0.243\ mJ$: ogni ms di timeout in più è sprecato in Run solo sui 9 gap lunghi.
4. **Costo del passaggio da T = 0 a T = 5: +5.45 mJ.** Circa 1.2 mJ vengono dai 9 gap lunghi ($9 \times 5\ ms \times 27\ \mu J/ms$). Il resto (circa 4.2 mJ) viene dai 76 gap corti, che passano da Idle a Run (circa 223 ms totali a 27 µJ/ms in più) al netto delle 76 coppie di transizioni evitate (76 × 0.02 mJ).
5. **Il risparmio delle transizioni è trascurabile.** Con T = 0 le transizioni costano in tutto 1.7 mJ ($170 \times 0.01$ mJ) su 698 mJ totali.
6. **Penalità di prestazioni trascurabile.** Il tempo totale con DPM è 1082.5765 s contro 1082.5760 s: 0.5 ms in più su 1082 s.

Nota sulla discretizzazione: il simulatore avanza a passi da 0.1 ms e la condizione è `t_curr > t_inactive_start + timeout` (strettamente maggiore). Con T = 0 il primo step resta quindi in Run e il passaggio a Idle avviene dopo 0.1 ms. Lo si vede dal waiting time: 0.0085 s $= 85 \times 0.1$ ms, cioè uno step per ognuno degli 85 gap non nulli.

## Workload 2: risultati

| Timeout (ms) | N. transizioni | Waiting in Run (s) | Energia con DPM (J) |
|---|---|---|---|
| 0 | 198 | 0.0099 | **0.69348** |
| 1 | 198 | 0.1058 | 0.69607 |
| 5 | 198 | 0.5018 | 0.70678 |
| 10 | 198 | 0.9968 | 0.72016 |
| 20 | 198 | 1.9867 | 0.74691 |
| 50 | 198 | 4.9567 | 0.82719 |
| 80 | 194 | 7.9228 | 0.90733 |
| 100 | 56 | 9.4217 | 0.94649 |
| 200 | 20 | 10.5592 | 0.97689 |

Energia senza DPM: 30.139 J. Con timeout 0 il risparmio è del **97.7 %**.

Cosa si vede e perché:

1. **Il minimo è ancora T = 0**, per lo stesso motivo del workload 1: tutti i 99 gap sono molto sopra $T_{be} = 0.8$ ms, quindi l'Idle conviene sempre e ogni ms di timeout è puro spreco.
2. **Il numero di transizioni è costante (198 = 99 coppie) fino a T = 50**, e la curva è una retta. La pendenza è circa 2.7 mJ per ms ($99 \times 27.03\ \mu J = 2.68\ mJ/ms$), cioè **11 volte quella del workload 1** (0.243 mJ/ms). Nel workload 1 con T ≥ 5 solo i 9 gap lunghi pagavano il timeout, perché i gap corti restavano in Run comunque. Nel workload 2 tutti i gap, anche quelli corti, sono più lunghi del timeout, quindi pagano tutti.
3. **Il "gradino" delle transizioni si sposta da ~4 ms a ~100 ms.** I gap corti del workload 2 durano 77–118 ms, quindi il timeout inizia a escluderli solo da T ≈ 77 ms in poi (194 transizioni a 80 ms, 56 a 100 ms, 20 a 200 ms). A quel punto l'energia sale ancora, perché i gap corti restano in Run: ciascuno da circa 96 ms $\times$ 27.6 mW $\approx$ 2.7 mJ.
4. **L'effetto dei sensori lenti non cambia il timeout ottimo, ma cambia il costo di sbagliarlo.** Con sensori lenti i gap corti sono molto più lunghi, quindi un timeout scelto male costa molto di più (a T = 10 ms: +3.8 % rispetto a T = 0 nel workload 2, +0.9 % nel workload 1).

## Conclusione Parte 1

Con la sola transizione Run ↔ Idle, il timeout migliore è **T = 0 su entrambi i workload**. Il motivo è fisico: $T_{be}$ vale 0.8 ms ed è dominato dal tempo di transizione, e in entrambi i workload ogni gap di inattività reale lo supera. Aspettare prima di spegnere non evita nessuna transizione svantaggiosa e consuma 27 µJ per ogni ms. Ha senso un timeout maggiore di zero solo quando esistono gap più corti di $T_{be}$ che vanno protetti, oppure quando entrare in Idle ha un costo (energia o latenza) molto maggiore di quello di questo PSM.

> I valori del workload 2 e quelli del workload 1 per T = 1 e T = 3 sono stati calcolati con una replica Python del simulatore (`dpm_decide_state` timeout verso Idle). La replica riproduce esattamente i tuoi output sul workload 1 (T = 0, 5, 10, 60: stesse energie, stesse transizioni, stessi waiting time). Rilancia comunque `./dpm_simulator` sul workload 2 prima di consegnare i numeri nel report.
