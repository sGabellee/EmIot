#!/usr/bin/env bash
# =============================================================================
# sweep_history.sh - Assignment 1, Parte 3
# Sweep sistematico dei parametri per la policy DPM_HISTORY.
#
# Esplora diverse combinazioni di predittori (alpha) e soglie (IDLE e SLEEP).
#
# Uso:
#   ./sweep_history.sh                       # usa i default (consigliato per iniziare)
#   ./sweep_history.sh -n 5                  # mostra solo i top 5 per ogni workload
#   ./sweep_history.sh -h                    # mostra l'aiuto
# =============================================================================
set -euo pipefail
export LC_ALL=C

# ------------------------------- default -------------------------------------
SIM=./dpm_simulator
PSM=example/psm.txt
WORKLOADS=(../workloads/workload_1.txt ../workloads/workload_2.txt)

# Set di coefficienti alpha (DPM_HIST_WIND_SIZE = 5)
# 1. "Last value": prevede che il prossimo inattivo sia uguale all'ultimo (alpha[1]=1)
# 2. "Moving average 2": media degli ultimi 2
# 3. "Moving average 4": media degli ultimi 4
ALPHAS=(
    "0 1 0 0 0"
    "0 0.5 0.5 0 0"
    "0 0.25 0.25 0.25 0.25"
)

# Soglie per IDLE (attorno al Break-Even Time di IDLE, ~0.8ms)
TH_IDLE=(0.0 0.5 0.8 1.0 2.0)

# Soglie per SLEEP (attorno al Break-Even Time di SLEEP, ~73ms)
TH_SLEEP=(50 73 80 100 120 150)

TOP=0
OUTBASE=results_hist
PLOT=1

usage() {
cat <<EOF
Uso: $0 [opzioni]
  -s <sim>        eseguibile del simulatore       (default: $SIM)
  -p <psm>        file PSM                        (default: $PSM)
  -n <N>          righe mostrate per gruppo       (default: $TOP, 0=tutte)
  -o <dir>        cartella risultati              (default: $OUTBASE)
  -P              non generare il grafico
  -h              questo aiuto
EOF
}

while getopts "s:p:n:o:Ph" opt; do
    case $opt in
        s) SIM=$OPTARG ;;
        p) PSM=$OPTARG ;;
        n) TOP=$OPTARG ;;
        o) OUTBASE=$OPTARG ;;
        P) PLOT=0 ;;
        h) usage; exit 0 ;;
        *) usage; exit 1 ;;
    esac
done

# ------------------------------- controlli -----------------------------------
if [ -f Makefile ]; then make -s >/dev/null 2>&1 || true; fi
[ -x "$SIM" ] || { echo "[error] simulatore non trovato: $SIM"; exit 1; }
[ -f "$PSM" ] || { echo "[error] PSM non trovato: $PSM"; exit 1; }
for wl in "${WORKLOADS[@]}"; do
    [ -f "$wl" ] || { echo "[error] workload non trovato: $wl"; exit 1; }
done

# ------------------------------- output --------------------------------------
OUTDIR="$OUTBASE/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTDIR"
RAW="$OUTDIR/sweep_raw.csv"
SORTED="$OUTDIR/sweep_sorted.csv"
HEADER="workload,alphas,th_idle,th_sleep,E_dpm_J,E_nodpm_J,saving_pct,n_tran,E_tran_J,t_run_s,t_idle_s,t_sleep_s,t_wait_s,t_tran_s,t_tot_dpm_s"
echo "$HEADER" > "$RAW"

# Parser awk (identico a quello per timeout)
PARSE='
/Tot\. Time w\/o DPM/    { split($0, a, "= "); tnd = a[2]+0; td = a[3]+0 }
/state Run =/            { split($0, a, "= "); trun   = a[2]+0 }
/state Idle =/           { split($0, a, "= "); tidle  = a[2]+0 }
/state Sleep =/          { split($0, a, "= "); tsleep = a[2]+0 }
/Timeout waiting time/   { split($0, a, "= "); twait  = a[2]+0 }
/Transitions time/       { split($0, a, "= "); ttran  = a[2]+0 }
/N\. of transitions/     { split($0, a, "= "); ntr    = a[2]+0 }
/Energy for transitions/ { split($0, a, "= "); etr    = a[2]+0 }
/Tot\. Energy w\/o DPM/  { split($0, a, "= "); end = a[2]+0; ed = a[3]+0; ok=1 }
END {
    if (!ok) exit 1
    # per history formattiamo gli alpha sostituendo gli spazi con +
    gsub(" ", "+", alpha)
    printf "%s,%s,%s,%s,%.10f,%.10f,%.4f,%d,%.10f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f\n",
        wl, alpha, thi, ths, ed, end, 100*(1-ed/end), ntr, etr,
        trun, tidle, tsleep, twait, ttran, td
}'

total=$(( ${#WORKLOADS[@]} * ${#ALPHAS[@]} * ${#TH_IDLE[@]} * ${#TH_SLEEP[@]} ))
k=0

for wl in "${WORKLOADS[@]}"; do
    wln=$(basename "$wl" .txt)
    for alpha in "${ALPHAS[@]}"; do
        for thi in "${TH_IDLE[@]}"; do
            for ths in "${TH_SLEEP[@]}"; do
                k=$((k + 1))
                printf '\r[%3d/%3d] %-12s Alpha:[%s] ThI=%-3s ThS=%-3s' "$k" "$total" "$wln" "$alpha" "$thi" "$ths" >&2
                
                # Esegui il simulatore passando gli array completi
                out=$("$SIM" -psm "$PSM" -wl "$wl" -h $alpha $thi $ths 2>&1) || true
                
                if ! printf '%s\n' "$out" | awk -v wl="$wln" -v alpha="$alpha" -v thi="$thi" -v ths="$ths" "$PARSE" >> "$RAW"; then
                    echo >&2
                    echo "[error] simulazione fallita: $wln -h $alpha $thi $ths" >&2
                    exit 1
                fi
            done
        done
    done
done
echo >&2

# Ordina per Workload e Energia
{ echo "$HEADER"; tail -n +2 "$RAW" | sort -t, -k1,1 -k5,5g; } > "$SORTED"

# ------------------------------- classifica ----------------------------------
awk -F, -v top="$TOP" '
NR == 1 { next }
{
    g = $1
    if (g != cur) {
        if (cur != "") print ""
        cur = g; r = 0; best = $5
        printf "=== %s  |  Migliori combinazioni HISTORY ===\n", g
        printf "%4s %20s %7s %7s %10s %8s %6s %10s %10s %9s\n",
            "#", "Alphas", "Th_IDLE", "Th_SLEEP", "E_dpm[J]", "save[%]", "n_tr", "t_idle[s]", "t_sleep[s]", "dE[mJ]"
    }
    r++
    if (top > 0 && r > top) next
    printf "%4d %20s %7s %7s %10.6f %8.3f %6d %10.4f %10.4f %9.3f\n",
        r, $2, $3, $4, $5, $7, $8, $11, $12, ($5 - best) * 1000
}' "$SORTED"

# ------------------------------- grafico -------------------------------------
if [ "$PLOT" -eq 1 ]; then
    if command -v python3 >/dev/null 2>&1 && python3 -c "import matplotlib" 2>/dev/null; then
        python3 - "$RAW" "$OUTDIR/sweep_hist_energy.png" <<'PY'
import csv, sys
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

rows = list(csv.DictReader(open(sys.argv[1])))
wls = sorted({r["workload"] for r in rows})
alphas = sorted({r["alphas"] for r in rows})
# Colori automatici per i diversi predittori
colors = plt.cm.tab10.colors 

fig, ax = plt.subplots(1, len(wls), figsize=(7 * len(wls), 5), squeeze=False)
for j, wl in enumerate(wls):
    for i, a in enumerate(alphas):
        # Raccogliamo i dati per questo predittore
        data = [r for r in rows if r["workload"] == wl and r["alphas"] == a]
        if not data: continue
        
        # Per tracciare un grafico 2D, per ogni Th_SLEEP prendiamo la combinazione che 
        # ha l'energia minore (indipendentemente da Th_IDLE)
        th_sleeps = sorted(list(set(float(r["th_sleep"]) for r in data)))
        best_e = []
        for ts in th_sleeps:
            min_e = min(float(r["E_dpm_J"]) for r in data if float(r["th_sleep"]) == ts)
            best_e.append(min_e)
            
        ax[0][j].plot(th_sleeps, best_e, "-o", ms=4, color=colors[i%10], label=f"Alpha: {a}")
        
    e0 = float(next(r for r in rows if r["workload"] == wl)["E_nodpm_J"])
    ax[0][j].axhline(e0, ls="--", color="gray", lw=1, label="no DPM")
    ax[0][j].set_title(wl)
    ax[0][j].set_ylabel("Energia Minima Ottenibile [J]")
    ax[0][j].set_xlabel("Soglia SLEEP [ms]")
    ax[0][j].grid(True, alpha=0.3)
    ax[0][j].legend(fontsize=8)
    
fig.tight_layout()
fig.savefig(sys.argv[2], dpi=150)
PY
        echo
        echo "Grafico: $OUTDIR/sweep_hist_energy.png"
    fi
fi