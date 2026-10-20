``` bash
sgabelli@GabrieleTP:~/EmIot/dpm-simulator/dpm-simulator$ ./dpm_simulator -t 0 -psm example/psm.txt -wl ../../workloads/workloads/workload_1.txt 
[psm] State Run: power = 27.6000mW
[psm] State Idle: power = 0.5700mW
[psm] State Sleep: power = 0.0900mW
[psm] Run -> Idle transition: energy  = 0.0100mJ, time = 0.4000ms
[psm] Run -> Sleep transition: energy  = 0.0200mJ, time = 1.0000ms
[psm] Idle -> Run transition: energy  = 0.0100mJ, time = 0.4000ms
[psm] Sleep -> Run transition: energy  = 2.0000mJ, time = 4.0000ms

[sim] Active time in profile = 2.924000s 
[sim] Inactive time in profile = 1079.652000s
[sim] Tot. Time w/o DPM = 1082.576000s, Tot. Time w DPM = 1082.576500s
[sim] Total time in state Run = 2.932500s
[sim] Total time in state Idle = 1079.576000s
[sim] Total time in state Sleep = 0.000000s
[sim] Timeout waiting time = 0.008500s
[sim] Transitions time = 0.068000s
[sim] N. of transitions = 170
[sim] Energy for transitions = 0.0017000000J
[sim] Tot. Energy w/o DPM = 29.8790976000J, Tot. Energy w DPM = 0.6979953200J

sgabelli@GabrieleTP:~/EmIot/dpm-simulator/dpm-simulator$ ./dpm_simulator -t 5 -psm example/psm.txt -wl ../../workloads/workloads/workload_1.txt 
...

[sim] Active time in profile = 2.924000s 
[sim] Inactive time in profile = 1079.652000s
[sim] Tot. Time w/o DPM = 1082.576000s, Tot. Time w DPM = 1082.576100s
[sim] Total time in state Run = 3.189100s
[sim] Total time in state Idle = 1079.379800s
[sim] Total time in state Sleep = 0.000000s
[sim] Timeout waiting time = 0.265100s
[sim] Transitions time = 0.007200s
[sim] N. of transitions = 18
[sim] Energy for transitions = 0.0001800000J
[sim] Tot. Energy w/o DPM = 29.8790976000J, Tot. Energy w DPM = 0.7034456460J

sgabelli@GabrieleTP:~/EmIot/dpm-simulator/dpm-simulator$ ./dpm_simulator -t 10 -psm example/psm.txt -wl ../../workloads/workloads/workload_1.txt 
...

[sim] Active time in profile = 2.924000s 
[sim] Inactive time in profile = 1079.652000s
[sim] Tot. Time w/o DPM = 1082.576000s, Tot. Time w DPM = 1082.576100s
[sim] Total time in state Run = 3.234100s
[sim] Total time in state Idle = 1079.334800s
[sim] Total time in state Sleep = 0.000000s
[sim] Timeout waiting time = 0.310100s
[sim] Transitions time = 0.007200s
[sim] N. of transitions = 18
[sim] Energy for transitions = 0.0001800000J
[sim] Tot. Energy w/o DPM = 29.8790976000J, Tot. Energy w DPM = 0.7046619960J

sgabelli@GabrieleTP:~/EmIot/dpm-simulator/dpm-simulator$ ./dpm_simulator -t 15 -psm example/psm.txt -wl ../../workloads/workloads/workload_1.txt 
...


[sim] Active time in profile = 2.924000s 
[sim] Inactive time in profile = 1079.652000s
[sim] Tot. Time w/o DPM = 1082.576000s, Tot. Time w DPM = 1082.576100s
[sim] Total time in state Run = 3.279100s
[sim] Total time in state Idle = 1079.289800s
[sim] Total time in state Sleep = 0.000000s
[sim] Timeout waiting time = 0.355100s
[sim] Transitions time = 0.007200s
[sim] N. of transitions = 18
[sim] Energy for transitions = 0.0001800000J
[sim] Tot. Energy w/o DPM = 29.8790976000J, Tot. Energy w DPM = 0.7058783460J

sgabelli@GabrieleTP:~/EmIot/dpm-simulator/dpm-simulator$ ./dpm_simulator -t 25 -psm example/psm.txt -wl ../../workloads/workloads/workload_1.txt 
...

[sim] Active time in profile = 2.924000s 
[sim] Inactive time in profile = 1079.652000s
[sim] Tot. Time w/o DPM = 1082.576000s, Tot. Time w DPM = 1082.576100s
[sim] Total time in state Run = 3.369100s
[sim] Total time in state Idle = 1079.199800s
[sim] Total time in state Sleep = 0.000000s
[sim] Timeout waiting time = 0.445100s
[sim] Transitions time = 0.007200s
[sim] N. of transitions = 18
[sim] Energy for transitions = 0.0001800000J
[sim] Tot. Energy w/o DPM = 29.8790976000J, Tot. Energy w DPM = 0.7083110460J

sgabelli@GabrieleTP:~/EmIot/dpm-simulator/dpm-simulator$ ./dpm_simulator -t 30 -psm example/psm.txt -wl ../../workloads/workloads/workload_1.txt 
...


[sim] Active time in profile = 2.924000s 
[sim] Inactive time in profile = 1079.652000s
[sim] Tot. Time w/o DPM = 1082.576000s, Tot. Time w DPM = 1082.576100s
[sim] Total time in state Run = 3.414100s
[sim] Total time in state Idle = 1079.154800s
[sim] Total time in state Sleep = 0.000000s
[sim] Timeout waiting time = 0.490100s
[sim] Transitions time = 0.007200s
[sim] N. of transitions = 18
[sim] Energy for transitions = 0.0001800000J
[sim] Tot. Energy w/o DPM = 29.8790976000J, Tot. Energy w DPM = 0.7095273960J
sgabelli@GabrieleTP:~/EmIot/dpm-simulator/dpm-simulator$ ./dpm_simulator -t 35 -psm example/psm.txt -wl ../../workloads/workloads/workload_1.txt 
...

[sim] Active time in profile = 2.924000s 
[sim] Inactive time in profile = 1079.652000s
[sim] Tot. Time w/o DPM = 1082.576000s, Tot. Time w DPM = 1082.576100s
[sim] Total time in state Run = 3.459100s
[sim] Total time in state Idle = 1079.109800s
[sim] Total time in state Sleep = 0.000000s
[sim] Timeout waiting time = 0.535100s
[sim] Transitions time = 0.007200s
[sim] N. of transitions = 18
[sim] Energy for transitions = 0.0001800000J
[sim] Tot. Energy w/o DPM = 29.8790976000J, Tot. Energy w DPM = 0.7107437460J
sgabelli@GabrieleTP:~/EmIot/dpm-simulator/dpm-simulator$ ./dpm_simulator -t 40 -psm example/psm.txt -wl ../../workloads/workloads/workload_1.txt 
...

[sim] Active time in profile = 2.924000s 
[sim] Inactive time in profile = 1079.652000s
[sim] Tot. Time w/o DPM = 1082.576000s, Tot. Time w DPM = 1082.576100s
[sim] Total time in state Run = 3.504100s
[sim] Total time in state Idle = 1079.064800s
[sim] Total time in state Sleep = 0.000000s
[sim] Timeout waiting time = 0.580100s
[sim] Transitions time = 0.007200s
[sim] N. of transitions = 18
[sim] Energy for transitions = 0.0001800000J
[sim] Tot. Energy w/o DPM = 29.8790976000J, Tot. Energy w DPM = 0.7119600960J
sgabelli@GabrieleTP:~/EmIot/dpm-simulator/dpm-simulator$ ./dpm_simulator -t 50 -psm example/psm.txt -wl ../../workloads/workloads/workload_1.txt 
...

[sim] Active time in profile = 2.924000s 
[sim] Inactive time in profile = 1079.652000s
[sim] Tot. Time w/o DPM = 1082.576000s, Tot. Time w DPM = 1082.576100s
[sim] Total time in state Run = 3.594100s
[sim] Total time in state Idle = 1078.974800s
[sim] Total time in state Sleep = 0.000000s
[sim] Timeout waiting time = 0.670100s
[sim] Transitions time = 0.007200s
[sim] N. of transitions = 18
[sim] Energy for transitions = 0.0001800000J
[sim] Tot. Energy w/o DPM = 29.8790976000J, Tot. Energy w DPM = 0.7143927960J
sgabelli@GabrieleTP:~/EmIot/dpm-simulator/dpm-simulator$ ./dpm_simulator -t 60 -psm example/psm.txt -wl ../../workloads/workloads/workload_1.txt 
...

[sim] Active time in profile = 2.924000s 
[sim] Inactive time in profile = 1079.652000s
[sim] Tot. Time w/o DPM = 1082.576000s, Tot. Time w DPM = 1082.576100s
[sim] Total time in state Run = 3.684100s
[sim] Total time in state Idle = 1078.884800s
[sim] Total time in state Sleep = 0.000000s
[sim] Timeout waiting time = 0.760100s
[sim] Transitions time = 0.007200s
[sim] N. of transitions = 18
[sim] Energy for transitions = 0.0001800000J
[sim] Tot. Energy w/o DPM = 29.8790976000J, Tot. Energy w DPM = 0.7168254960J
```
## Scelta timeout
con la sola transizione **idle** **run** nel primo workload il timeout migliore è 0 perchè il consumo in run è troppo eccessivo rispetto all'**idle** e non esistono tempi tra due **run** tanto **piccoli** da creare una necessita in termini di consumi di restare in **run**.

Ogni *ms* che si sta in run e non in idle si consumano **27mW** rispetto ad andare direttamente in idle.

Fare un passaggio in idle anche solo per *3ms* consuma **0.2mJ** stare in run **0.083mJ**.

Per un **gap di durata T,** andare in uno stato a basso consumo **conviene** se:
$T_be = max( T_tr , (E_tr − P_low·T_tr) / (P_run − P_low) )$
- $T_tr$ e $E_tr$ sono tempo ed energia totali di andata e ritorno.
- Serve $T ≥ T_tr$.
- Serve anche il pareggio energetico, cioè consumare meno che stare in Run.