dc = dmd
dcopts = -O -inline

all: simulate probability precise tournament statistics rps

clean:
	rm -f simulate{,.exe,.obj} \
	      probability{,.exe,.obj} \
	      precise{,.exe,.obj} \
	      tournament{,.exe,.obj} \
	      statistics{,.exe,.obj} \
	      rps{,.exe,.obj}

simulate: simulate.d wizard.d
	$(dc) $(dcopts) simulate.d wizard.d

probability: probability.d wizard.d distribution.d
	$(dc) $(dcopts) probability.d wizard.d distribution.d

precise: precise.d wizard.d distribution.d
	$(dc) $(dcopts) precise.d wizard.d distribution.d

tournament: tournament.d wizard.d tools.d
	$(dc) $(dcopts) tournament.d wizard.d tools.d

statistics: statistics.d wizard.d tools.d
	$(dc) $(dcopts) statistics.d wizard.d tools.d

rps: rps.d wizard.d tools.d
	$(dc) $(dcopts) rps.d wizard.d tools.d
