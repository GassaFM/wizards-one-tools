// Author: Ivan Kazmenko (gassa@mail.ru)
// Calculates winning probability for a battle of two wizards.
// Reads two DNA strings of binaries from standard input.
// Writes result to standard output.
// Example usage: "./probability < simulate.in".
module probability;
import std.stdio;
import distribution;
import wizard;

void main ()
{
	auto wizard1 = Wizard (readln);
	auto wizard2 = Wizard (readln);

	writeln ("Wizard 1:\n", wizard1);
	writeln ("Wizard 2:\n", wizard2);

	writefln ("The %s wizard won!", battle (wizard1, wizard2) ? "first" : "second");
	writefln ("Damage taken: %s:%s", wizard1.damage, wizard2.damage);

	int wins1 = 0;
	int wins2 = 0;
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
	writefln ("Over %s steps: %s:%s victories", simulationSteps, wins1, wins2);

/*
	foreach (i; 0..10 ^^ 6)
	{
		calcProbability (wizard1, wizard2);
	}
*/
	writefln ("Probability: %.10f", calcProbability (wizard1, wizard2));
}
