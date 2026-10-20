#!/usr/bin/env bash
# =============================================================================
# sweep_timeout.sh - Assignment 1, Parte 2
# Sweep sistematico del timeout (TTO) per la policy DPM_TIMEOUT,
# con transizione RUN->IDLE e RUN->SLEEP, su uno o piu' workload.
#
# Per ogni combinazione (workload, stato target, TTO) lancia dpm_simulator,
# estrae tutte le statistiche, salva i CSV e stampa la classifica per energia.
#
# Richiede il simulatore modificato con l'opzione  -ts idle|sleep
#
# Uso (dalla cartella principale del simulatore):
#   ./sweep_timeout.sh                       # default: entrambi i workload, idle+sleep
#   ./sweep_timeout.sh -n 10                 # mostra solo i primi 10 per gruppo
#   ./sweep_timeout.sh -m sleep -T "0 50 73 100"
#   ./sweep_timeout.sh -h
# =============================================================================
set -euo pipefail
export LC_ALL=C                 # punto decimale anche con locale italiano

# ------------------------------- default -------------------------------------
SIM=./dpm_simulator
PSM=example/psm.txt
WORKLOADS=(../workloads/workload_1.txt ../workloads/workload_2.txt)
TARGETS=(idle sleep)
TIMEOUTS=()
TOP=0                           # righe per gruppo a terminale (0 = tutte)
OUTBASE=results
PLOT=1

usage() {
cat <<EOF
Uso: $0 [opzioni]
  -s <sim>        eseguibile del simulatore       (default: $SIM)
  -p <psm>        file PSM                        (default: $PSM)
  -w "<wl ...>"   lista dei workload              (default: ${WORKLOADS[*]})
  -m "<t ...>"    stati target: idle e/o sleep    (default: ${TARGETS[*]})
  -T "<to ...>"   lista di TTO in ms              (default: griglia 0..130000 ms)
  -n <N>          righe mostrate per gruppo, 0=tutte (default: $TOP)
  -o <dir>        cartella base dei risultati     (default: $OUTBASE)
  -P              non generare il grafico
  -h              questo aiuto
EOF
}

while getopts "s:p:w:m:T:n:o:Ph" opt; do
    case $opt in
        s) SIM=$OPTARG ;;
        p) PSM=$OPTARG ;;
        w) read -r -a WORKLOADS <<< "$OPTARG" ;;
        m) read -r -a TARGETS   <<< "$OPTARG" ;;
        T) read -r -a TIMEOUTS  <<< "$OPTARG" ;;
        n) TOP=$OPTARG ;;
        o) OUTBASE=$OPTARG ;;
        P) PLOT=0 ;;
        h) usage; exit 0 ;;
        *) usage; exit 1 ;;
    esac
done

# Griglia di default: fitta dove cambiano le cose
#   0..2 ms passo 0.1  -> zona di T_be IDLE (0.8 ms) e gap corti del workload 1 (0-4 ms)
#   3..20 ms passo 1
#   25..200 ms passo 5 -> zona di T_be SLEEP (~73 ms) e gap corti del workload 2 (77-118 ms)
#   300..1000 passo 100, poi qualche valore grande fino a oltre i gap lunghi (~120 s)
if [ ${#TIMEOUTS[@]} -eq 0 ]; then
    mapfile -t TIMEOUTS < <(awk 'BEGIN{
        for (i = 0;   i <= 20;   i++)     printf "%.1f\n", i * 0.1;
        for (t = 3;   t <= 20;   t++)     print t;
        for (t = 25;  t <= 200;  t += 5)  print t;
        for (t = 300; t <= 1000; t += 100) print t;
        print 2000; print 5000; print 10000; print 60000; print 130000 }')
fi

# ------------------------------- controlli -----------------------------------
for tg in "${TARGETS[@]}"; do
    [[ $tg == idle || $tg == sleep ]] || { echo "[error] target non valido: $tg (usa idle o sleep)"; exit 1; }
done
if [ -f Makefile ]; then
    make -s >/dev/null 2>&1 || { echo "[error] make fallito: controlla la compilazione"; exit 1; }
fi
[ -x "$SIM" ] || { echo "[error] simulatore non trovato o non eseguibile: $SIM"; exit 1; }
[ -f "$PSM" ] || { echo "[error] PSM non trovato: $PSM"; exit 1; }
for wl in "${WORKLOADS[@]}"; do
    [ -f "$wl" ] || { echo "[error] workload non trovato: $wl"; exit 1; }
done

# il simulatore supporta -ts? (parse_args ignora le opzioni sconosciute, quindi verifico l'effetto)
if [[ " ${TARGETS[*]} " == *" sleep "* ]]; then
    t_sleep=$("$SIM" -t 0 -ts sleep -psm "$PSM" -wl "${WORKLOADS[0]}" \
              | awk -F'= ' '/state Sleep =/{print $2+0}')
    if awk -v x="${t_sleep:-0}" 'BEGIN{exit !(x == 0)}'; then
        echo "[error] il simulatore non entra mai in SLEEP con '-ts sleep':"
        echo "        applica le modifiche a inc/dpm_policies.h, src/utilities.c, src/dpm_policies.c e ricompila"
        exit 1
    fi
fi

# ------------------------------- output --------------------------------------
OUTDIR="$OUTBASE/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTDIR"
RAW="$OUTDIR/sweep_raw.csv"          # ordine di esecuzione (comodo per i grafici)
SORTED="$OUTDIR/sweep_sorted.csv"    # per workload, target, energia crescente
HEADER="workload,target,timeout_ms,E_dpm_J,E_nodpm_J,saving_pct,n_tran,E_tran_J,t_run_s,t_idle_s,t_sleep_s,t_wait_s,t_tran_s,t_tot_dpm_s,delay_ms"
echo "$HEADER" > "$RAW"

# parser dell'output di dpm_simulator -> una riga CSV
PARSE='
/Tot\. Time w\/o DPM/    { split($0, a, "= "); tnd = a[2] + 0; td = a[3] + 0 }
/state Run =/            { split($0, a, "= "); trun   = a[2] + 0 }
/state Idle =/           { split($0, a, "= "); tidle  = a[2] + 0 }
/state Sleep =/          { split($0, a, "= "); tsleep = a[2] + 0 }
/Timeout waiting time/   { split($0, a, "= "); twait  = a[2] + 0 }
/Transitions time/       { split($0, a, "= "); ttran  = a[2] + 0 }
/N\. of transitions/     { split($0, a, "= "); ntr    = a[2] + 0 }
/Energy for transitions/ { split($0, a, "= "); etr    = a[2] + 0 }
/Tot\. Energy w\/o DPM/  { split($0, a, "= "); end = a[2] + 0; ed = a[3] + 0; ok = 1 }
END {
    if (!ok) exit 1
    printf "%s,%s,%s,%.10f,%.10f,%.4f,%d,%.10f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.4f\n",
        wl, tg, to, ed, end, 100 * (1 - ed / end), ntr, etr,
        trun, tidle, tsleep, twait, ttran, td, (td - tnd) * 1000
}'

total=$(( ${#WORKLOADS[@]} * ${#TARGETS[@]} * ${#TIMEOUTS[@]} ))
k=0
for wl in "${WORKLOADS[@]}"; do
    wln=$(basename "$wl" .txt)
    for tg in "${TARGETS[@]}"; do
        for to in "${TIMEOUTS[@]}"; do
            k=$((k + 1))
            printf '\r[%3d/%3d] %-12s %-5s TTO = %-8s ms' "$k" "$total" "$wln" "$tg" "$to" >&2
            out=$("$SIM" -t "$to" -ts "$tg" -psm "$PSM" -wl "$wl" 2>&1) || true
            if ! printf '%s\n' "$out" | awk -v wl="$wln" -v tg="$tg" -v to="$to" "$PARSE" >> "$RAW"; then
                echo >&2
                echo "[error] simulazione fallita: $wln $tg TTO=$to" >&2
                printf '%s\n' "$out" | grep -E '\[error\]' >&2 || true
                exit 1
            fi
        done
    done
done
echo >&2

{ echo "$HEADER"; tail -n +2 "$RAW" | sort -t, -k1,1 -k2,2 -k4,4g; } > "$SORTED"

# ------------------------------- classifica ----------------------------------
awk -F, -v top="$TOP" '
NR == 1 { next }
{
    g = $1 "  |  RUN -> " toupper($2)
    if (g != cur) {
        if (cur != "") print ""
        cur = g; r = 0; best = $4
        printf "=== %s  |  E senza DPM = %.6f J ===\n", g, $5
        printf "%4s %9s %11s %8s %6s %9s %9s %10s %10s %9s %9s %9s %9s\n",
            "#", "TTO[ms]", "E_dpm[J]", "save[%]", "n_tr", "E_tr[mJ]",
            "t_run[s]", "t_idle[s]", "t_sleep[s]", "t_wait[s]", "t_tr[s]", "delay[ms]", "dE[mJ]"
    }
    r++
    if (top > 0 && r > top) next
    printf "%4d %9s %11.6f %8.3f %6d %9.3f %9.4f %10.4f %10.4f %9.4f %9.4f %9.2f %9.3f\n",
        r, $3, $4, $6, $7, $8 * 1000, $9, $10, $11, $12, $13, $15, ($4 - best) * 1000
}' "$SORTED"

# ------------------------------- riepilogo -----------------------------------
echo
echo "=== Riepilogo: TTO migliore per workload e stato target ==="
printf "%-12s %-6s %9s %11s %8s %6s %9s\n" "workload" "target" "TTO[ms]" "E_dpm[J]" "save[%]" "n_tr" "delay[ms]"
awk -F, 'NR > 1 {
    key = $1 SUBSEP $2
    if (!(key in e) || $4 < e[key]) { e[key] = $4; line[key] = $0 }
} END { for (k in line) print line[k] }' "$SORTED" | sort -t, -k1,1 -k4,4g | \
awk -F, '{
    printf "%-12s %-6s %9s %11.6f %8.3f %6d %9.2f", $1, $2, $3, $4, $6, $7, $15
    if ($1 != prev) { printf "   <- migliore per %s", $1; prev = $1; first = $4 }
    else            { printf "   (+%.3f mJ, +%.1f%%)", ($4 - first) * 1000, 100 * ($4 / first - 1) }
    printf "\n"
}'

# ------------------------------- grafico -------------------------------------
if [ "$PLOT" -eq 1 ]; then
    if command -v python3 >/dev/null 2>&1 && python3 -c "import matplotlib" 2>/dev/null; then
        python3 - "$RAW" "$OUTDIR/sweep_energy.png" <<'PY'
import csv, sys
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

rows = list(csv.DictReader(open(sys.argv[1])))
wls = sorted({r["workload"] for r in rows})
tgs = [t for t in ("idle", "sleep") if any(r["target"] == t for r in rows)]
col = {"idle": "#2a7ab9", "sleep": "#d0643b"}

fig, ax = plt.subplots(2, len(wls), figsize=(6.5 * len(wls), 8), squeeze=False, sharex=True)
for j, wl in enumerate(wls):
    for tg in tgs:
        d = sorted(((float(r["timeout_ms"]), float(r["E_dpm_J"]), int(r["n_tran"]))
                    for r in rows if r["workload"] == wl and r["target"] == tg))
        if not d:
            continue
        x, e, n = zip(*d)
        ib = min(range(len(e)), key=e.__getitem__)
        ax[0][j].plot(x, e, "-o", ms=3, color=col[tg], label=f"RUN->{tg.upper()}")
        ax[0][j].plot(x[ib], e[ib], "*", ms=14, color=col[tg])
        ax[0][j].annotate(f"min {e[ib]:.4f} J @ {x[ib]:g} ms", (x[ib], e[ib]),
                          textcoords="offset points", xytext=(8, 8),
                          color=col[tg], fontsize=8)
        ax[1][j].plot(x, n, "-o", ms=3, color=col[tg], label=f"RUN->{tg.upper()}")
    e0 = float(next(r for r in rows if r["workload"] == wl)["E_nodpm_J"])
    ax[0][j].axhline(e0, ls="--", color="gray", lw=1, label=f"no DPM ({e0:.2f} J)")
    ax[0][j].set_title(wl)
    ax[0][j].set_yscale("log")
    ax[0][j].set_ylabel("Energia con DPM [J]")
    ax[1][j].set_ylabel("N. transizioni")
    ax[1][j].set_xlabel("TTO [ms]")
    for a in ax[:, j]:
        a.set_xscale("symlog", linthresh=1)
        a.grid(True, which="both", alpha=0.3)
        a.legend(fontsize=8)
fig.tight_layout()
fig.savefig(sys.argv[2], dpi=150)
PY
        echo
        echo "Grafico: $OUTDIR/sweep_energy.png"
    else
        echo
        echo "(grafico saltato: serve python3 con matplotlib -> pip install matplotlib)"
    fi
fi

echo "CSV:     $RAW"
echo "         $SORTED"
