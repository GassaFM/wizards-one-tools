// Author: Ivan Kazmenko (gassa@mail.ru)
// Collects statistics for the tournament.
// Uses "wizards.json" and "table.txt".
// Must be run after tournament.
module statistics;
import std.algorithm, std.conv, std.range, std.stdio;
import tools, wizard;

void main ()
{
	auto wizards = readWizards ("wizards.json");
	auto n = wizards.length.to !(int);
	auto wins = readWins ("table.txt", n);

	auto s = wins.map !(sum).array;
	auto p = new int [n];
	makeIndex (s, p);

	auto fileOut = File ("stats.txt", "w");
	foreach_reverse (i; 0..n)
	{
		int k = p[i];
		auto best = wins[k].maxElement;
		auto worst = chain (wins[k][0..k], wins[k][k + 1..$]).minElement;
		fileOut.writefln ("Wizard id=%-5s: score %s, ddc %6.3f, " ~
		    "norm %6.3f, best %s (id=%-5s), worst %s (id=%-5s)",
		    wizards[k].id, s[k], wizards[k].ddc, wizards[k].norm,
		    best, wizards[wins[k].countUntil (best)].id,
		    worst, wizards[wins[k].countUntil (worst)].id);
	}
}
