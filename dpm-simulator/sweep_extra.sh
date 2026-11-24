#!/usr/bin/env bash
export LC_ALL=C

SIM="./dpm_simulator"
PSM="example/psm.txt"
WORKLOADS=(../workloads/workload_1.txt ../workloads/workload_2.txt)

T1_LIST=(0 0.8)
T2_LIST=(0 0.5 1 2 3 4 5 10 20 50 73.41 75 100 120 150 200)

CSV="sweep_extra.csv"
echo "workload,t1,t2,ed,save,ntr,trun,tidle,tsleep,delay" > "$CSV"

for wl in "${WORKLOADS[@]}"; do
    wln=$(basename "$wl" .txt)
    echo "=== $wln ==="
    printf "%6s %8s | %10s %7s %5s | %8s %8s %8s\n" "T_to" "T_extra" "E_dpm[J]" "save%" "n_tr" "run[s]" "idle[s]" "sleep[s]"

    for t1 in "${T1_LIST[@]}"; do
        for t2 in "${T2_LIST[@]}"; do
            if [ "$(awk -v a="$t2" -v b="$t1" 'BEGIN{print (a < b)}')" -eq 1 ]; then
                continue
            fi

            out=$("$SIM" -te "$t1" "$t2" -psm "$PSM" -wl "$wl" 2>&1)
            
            ed=$(echo "$out" | awk -F'= ' '/Tot\. Energy w\/o DPM/{print $3+0}')
            end=$(echo "$out" | awk -F'= ' '/Tot\. Energy w\/o DPM/{print $2+0}')
            ntr=$(echo "$out" | awk -F'= ' '/N\. of transitions/{print $2+0}')
            trun=$(echo "$out" | awk -F'= ' '/state Run =/{print $2+0}')
            tidle=$(echo "$out" | awk -F'= ' '/state Idle =/{print $2+0}')
            tsleep=$(echo "$out" | awk -F'= ' '/state Sleep =/{print $2+0}')
            tnd=$(echo "$out" | awk -F'= ' '/Tot\. Time w\/o DPM/{print $2+0}')
            td=$(echo "$out" | awk -F'= ' '/Tot\. Time w\/o DPM/{print $3+0}')

            save=$(awk -v ed="$ed" -v end="$end" 'BEGIN{printf "%.3f", 100*(1 - ed/end)}')
            delay=$(awk -v td="$td" -v tnd="$tnd" 'BEGIN{printf "%.3f", (td - tnd)*1000}')

            printf "%6s %8s | %10.6f %7s %5d | %8.4f %8.4f %8.4f\n" "$t1" "$t2" "$ed" "$save" "$ntr" "$trun" "$tidle" "$tsleep"
            echo "$wln,$t1,$t2,$ed,$save,$ntr,$trun,$tidle,$tsleep,$delay" >> "$CSV"
        done
    done
    echo ""
done
