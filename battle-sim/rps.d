// Author: Ivan Kazmenko (gassa@mail.ru)
// Find rock-paper-scissors triples of wizards in the tournament table.
// Uses "wizards.json" and "table.txt".
// Must be run after tournament.
module rps;
import std.algorithm, std.conv, std.math, std.range, std.stdio;
import tools, wizard;

void main ()
{
	auto wizards = readWizards ("wizards.json");
	auto n = wizards.length.to !(int);
	auto wins = readWins ("table.txt", n);

	auto s = wins.map !(sum).array;
	auto p = new int [n];
	makeIndex (s, p);

	auto fileOut = File ("rps.txt", "w");
	immutable int threshold = simulationSteps / 2 + sqrt (simulationSteps * 1.0).to !(int);
	foreach (i; 0..n)
	{
		foreach (j; i + 1..n)
		{
			foreach (k; i + 1..n)
			{
				if (wins[i][j] > threshold &&
				    wins[j][k] > threshold &&
				    wins[k][i] > threshold)
				{
					fileOut.writefln ("id%s id%s id%s: " ~
					    "%s %s %s", wizards[i].id,
					    wizards[j].id, wizards[k].id,
					    wins[i][j], wins[j][k],
					    wins[k][i]);
				}
			}
		}
	}
}
