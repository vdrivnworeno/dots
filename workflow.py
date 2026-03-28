
#!/usr/bin/python3

from subprocess import run

SNAME = "SERVERS"
run('tmux -u -2 new -d -s '+SNAME, shell=True)

SN = (
        "FW-RTR",
        "AREKUNA",
        "WKDA",
        "CNMA",
        "TPUN",
        "XKKNAN",
        "CMPMA",
        "XTPY",
        "TPY",
        "NAS",
        "URYN",
        "WRMSEN",
        "KMA",
        "KMRKTO",
        "ZCNMA",
        "CHRN-MRU",
        "KMRUAY",
        "MRON",
        "MRON4",
        "CYNI",
        "AMURI",
        "UCMA",
        "WDMA",
        "URIMAN",
        "ORNCO",
        "ANGSTRA",
        "ZBBX",
        "PORTAL",)

SA = (
        "firewall-router",
        "arekuna",
        "wakada",
        "canaima",
        "teipun",
        "xkukenan",
        "campoma",
        "xtepuy",
        "tepuy",
        "nas",
        "uruyen",
        "waramasen",
        "kama",
        "kamarakoto",
        "zcanaima",
        "churun-meru",
        "kamaruay",
        "moron",
        "moron4",
        "cuyuni",
        "amuri",
        "ucaima",
        "wadaima",
        "uriman",
        "orinoco",
        "angostura",
        "zabbix",
        "www.uneg.edu.ve",)

n = 0
for name, server in zip(SN, SA):
    run(f'tmux neww -k -t {n} -n {name}', shell=True)
    run(f'tmux send -t {SNAME}:{n} "ssh {server} -t \'if ps -e | grep -E tmux; then tmux a; else tmux; fi\'"', shell=True)
    n += 1


SNAME = "WORK"
run('tmux -u -2 new -d -s '+SNAME, shell=True)

SNAME = "DEV"
run(f'tmux -u -2 new -d -s {SNAME} -c ~/dev', shell=True)

run('tmux a', shell=True)

