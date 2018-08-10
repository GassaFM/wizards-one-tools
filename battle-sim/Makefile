dc = dmd
dcopts = -O -inline

all: simulate tournament statistics rps

clean:
	rm -f simulate{,.exe,.obj} \
	      tournament{,.exe,.obj} \
	      statistics{,.exe,.obj} \
	      rps{,.exe,.obj}

simulate: simulate.d wizard.d
	$(dc) $(dcopts) simulate.d wizard.d

tournament: tournament.d wizard.d tools.d
	$(dc) $(dcopts) tournament.d wizard.d tools.d

statistics: statistics.d wizard.d tools.d
	$(dc) $(dcopts) statistics.d wizard.d tools.d

rps: rps.d wizard.d tools.d
	$(dc) $(dcopts) rps.d wizard.d tools.d
