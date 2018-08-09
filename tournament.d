// Author: Ivan Kazmenko (gassa@mail.ru)
// Runs a tournament for all wizards from "wizards.json".
// Example command line to get a JSON with 100 wizards:
// wget https://api.wizards.one/user/rebeccablack/wizards && mv wizards wizards.json
// Writes resulting table to "table.txt".
module tournament;
import std.conv, std.parallelism, std.range, std.stdio;
import tools, wizard;

void main ()
{
	auto wizards = readWizards ("wizards.json");
	auto n = wizards.length.to !(int);

	auto wins = new int [] [] (n, n);
	foreach (i; iota (0, n).parallel)
	{
		stderr.writeln ("i = ", i);
		foreach (j; i + 1..n)
		{
			int wins1 = 0;
			int wins2 = 0;
			auto wizard1 = wizards[i];
			auto wizard2 = wizards[j];
			foreach (step; 0..simulationSteps)
			{
				if (battle (wizard1, wizard2))
				{
					wins1 += 1;
				}
				else
				{
					wins2 += 1;
				}
			}
			wins[i][j] += wins1;
			wins[j][i] += wins2;
		}
	}

	File ("table.txt", "w").writefln ("%(%(%4s %)\n%)", wins);
}
