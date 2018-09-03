// Author: Ivan Kazmenko (gassa@mail.ru)
// Auxiliary module to simulate wizard battles.
module wizard;
import std.algorithm, std.conv, std.format, std.math, std.random, std.range, std.stdio, std.string;

immutable int dnaLength = 8; // total number of skills
immutable int mean = 50; // expectation from the rules
immutable int sigma = 8; // standard deviation from the rules
immutable int rounds = 5; // number of rounds in the fight
immutable int simulationSteps = 10_000; // number of simulations

/// uniform random value with right boundary included
alias uniformInclusive = (a, b) => uniform !("[]") (a, b);

struct Wizard
{
	int id;
	int [dnaLength] dna;
	int [dnaLength] attack;
	int [dnaLength] resist;
	int damage;
	string owner;

	// constructor from array
	this (int [] a)
	{
		assert (a.length == dnaLength);
		dna = a;
		calculateAD ();
		damage = 0;
	}

	// constructor from id and array
	this (int id_, int [] a)
	{
		id = id_;
		this (a);
	}

	// constructor from id and owner and array
	this (int id_, string owner_, int [] a)
	{
		owner = owner_;
		this (id_, a);
	}

	// constructor from string
	this (string s)
	{
		this (s.splitter.map !(x => to !(int) (x, 2)).array);
	}

	void calculateAD ()
	{
		foreach (i; 0..dnaLength)
		{
			auto delta = dna[i] - mean;
			if (dna[i] >= mean)
			{
				attack[i] = sigma + delta;
				resist[i] = sigma + delta / 2;
			}
			else
			{
				attack[i] = sigma - delta / 2;
				resist[i] = sigma - delta;
			}
		}
	}

	double ddc () const
	{
		double res = 0.0;
		foreach (i; 0..dnaLength)
		{
			res += abs (dna[i] - mean);
		}
		return res / dnaLength;
	}

	double norm () const
	{
		double res = 0.0;
		foreach (i; 0..dnaLength)
		{
			res += (dna[i] - mean) ^^ 2;
		}
		return sqrt (res / dnaLength);
	}

	auto toString () const
	{
		return format ("dna:    %(%2s %)\nattack: %(%2s %)\nresist: %(%2s %)\n", dna, attack, resist);
	}
}

/// test on Wizard 272 from the rules
unittest
{
	auto dna = [54, 39, 45, 56, 44, 34, 41, 47];
	auto wizard = Wizard (dna);
	debug {writeln (wizard);}
	assert (wizard.attack[] == [12, 13, 10, 14, 11, 16, 12, 9]);
	assert (wizard.resist[] == [10, 19, 13, 11, 14, 24, 17, 11]);
}

bool battle (ref Wizard wizard1, ref Wizard wizard2)
{
	startFight (wizard1, wizard2);
	randomDamage (wizard1, wizard2);
	magicFight (wizard1, wizard2);
	return determineWinner (wizard1, wizard2);
}

/// Phase 0: start a fight
void startFight (ref Wizard wizard1, ref Wizard wizard2)
{
	wizard1.damage = 0;
	wizard2.damage = 0;
}

/// Phase 1: random damage
void randomDamage (ref Wizard wizard1, ref Wizard wizard2)
{
	if (uniform (0, 2))
	{
		wizard1.damage += 1;
	}
	else
	{
		wizard2.damage += 1;
	}
}

/// Phase 2: magic fight
void magicFight (ref Wizard wizard1, ref Wizard wizard2)
{
	foreach (r; 0..rounds)
	{
		int mult = (r == rounds - 1) ? 2 : 1;
		attack (wizard1, wizard2, mult);
		attack (wizard2, wizard1, mult);
	}
}

/// The wizard `attacker` attacks the wizard `defender` with multiplier `mult`
void attack (ref Wizard attacker, ref Wizard defender, int mult)
{
	int skill = uniform (0, dnaLength);
	int attackPower = uniformInclusive (1, attacker.attack[skill]) * mult;
	int resistPower = uniformInclusive (1, defender.resist[skill]);
	if (attackPower > resistPower + sigma)
	{
		defender.damage += 2;
	}
	else if (attackPower > resistPower)
	{
		defender.damage += 1;
	}
}

/// Phase 3: determine winner
bool determineWinner (ref Wizard wizard1, ref Wizard wizard2)
{
	bool result;
	if (wizard1.damage != wizard2.damage)
	{
		result = wizard1.damage < wizard2.damage;
	}
	else
	{
		result = uniform (0, 2).to !(bool);
	}
	
	return result;
}
