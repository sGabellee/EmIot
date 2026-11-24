import csv
import matplotlib.pyplot as plt

rows = list(csv.DictReader(open("sweep_extra.csv")))
wls = sorted({r["workload"] for r in rows})
t1_vals = sorted({float(r["t1"]) for r in rows})
colors = ["#2a7ab9", "#d0643b"]

fig, ax = plt.subplots(2, len(wls), figsize=(6.5 * len(wls), 7.5), squeeze=False, sharex=True)

for j, wl in enumerate(wls):
    for idx, t1 in enumerate(t1_vals):
        d = sorted((float(r["t2"]), float(r["ed"]), int(r["ntr"]))
                   for r in rows if r["workload"] == wl and float(r["t1"]) == t1 and r["ed"])
        if not d:
            continue
        x, e, n = zip(*d)
        ib = min(range(len(e)), key=e.__getitem__)
        c = colors[idx]

        ax[0][j].plot(x, e, "-o", ms=3.5, color=c, label=f"$T_{{TO}} = {t1:g}$ ms")
        ax[0][j].plot(x[ib], e[ib], "*", ms=14, color=c)
        
        offset = (-65, -15) if idx == 0 else (-65, 12)
        ax[0][j].annotate(f"min {e[ib]:.4f} J @ {x[ib]:g} ms", (x[ib], e[ib]),
                          textcoords="offset points", xytext=offset, color=c, fontsize=8.5, fontweight="bold")
        ax[1][j].plot(x, n, "-o", ms=3.5, color=c, label=f"$T_{{TO}} = {t1:g}$ ms")

    ax[0][j].set_title(wl)
    ax[0][j].set_ylabel("Energy with DPM [J]")
    ax[0][j].set_ylim(0.175, None) 
    ax[1][j].set_ylabel("Number of transitions")
    ax[1][j].set_xlabel("$T_{TO,EXTRA}$ [ms]")

    for a in ax[:, j]:
        a.set_xscale("symlog", linthresh=1)
        a.set_xlim(0.3, 350)
        a.grid(True, which="both", alpha=0.3)
        a.legend(fontsize=8.5, loc="upper right" if j == 0 else "center left")

fig.tight_layout()
fig.savefig("sweep_extra.png", dpi=150)
print("Salvato sweep_extra.png")
