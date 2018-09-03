// Author: Ivan Kazmenko (gassa@mail.ru)
// Auxiliary module to calculate probabilities for wizard battles.
module distribution;
import std.algorithm;
import std.range;
import std.stdio;
import wizard;

immutable int damageLimit = rounds * 2 + 1;
immutable int precalcLimit = wizard.mean * 2 + 1;

struct Distribution
{
	double [] p;
	alias p this;

	this (size_t limit)
	{
		p = new double [limit];
	}

	Distribution opBinary (string op)
	    (const auto ref Distribution that) const
	    if (op == "+")
	{
		auto res = Distribution (this.length + that.length - 1);
		res[] = 0.0;
		foreach (i; 0..this.length)
		{
			foreach (j; 0..that.length)
			{
				res[i + j] += this[i] * that[j];
			}
		}
		return res;
	}
}

Distribution meanDistribution (Distribution [] d)
{
	auto res = Distribution (d.map !(x => x.length).maxElement);
	res[] = 0.0;
	foreach (ref distribution; d)
	{
		res[0..distribution.length] += distribution[];
	}
	res[] /= d.length;
	return res;
}

Distribution [] [] precalcAD;

Distribution roundDamage (int attack, int resist)
{
	auto res = Distribution (3);
	res[] = 0.0;
	foreach (i; 1..attack + 1)
	{
		int lo = max (1, min (resist + 1, i - sigma));
		int hi = max (1, min (resist + 1, i));
		res[0] += resist + 1 - hi;
		res[1] += hi - lo;
		res[2] += lo - 1;
	}
	res[] /= attack * resist;
	return res;
}

Distribution roundDamageNaive (int attack, int resist)
{
	auto res = Distribution (3);
	res[] = 0.0;
	foreach (i; 1..attack + 1)
	{
		foreach (j; 1..resist + 1)
		{
			res[(i > j + sigma) + (i > j)] += 1;
		}
	}
	res[] /= attack * resist;
	return res;
}

auto doPrecalcAD ()
{
	auto res = new Distribution [] [] (precalcLimit, precalcLimit);
	foreach (i; 1..precalcLimit)
	{
		foreach (j; 1..precalcLimit)
		{
			res[i][j] = roundDamage (i, j);
		}
	}
	return res;
}

static this ()
{
	precalcAD = doPrecalcAD ();
}

Distribution damageDistribution (ref Wizard attacker, ref Wizard defender)
{
	Distribution [] d;
	Distribution [] e;
	foreach (skill; 0..dnaLength)
	{
		auto attackLimit = attacker.attack[skill];
		auto resistLimit = defender.resist[skill];
		d ~= precalcAD[attackLimit][resistLimit];
		e ~= precalcAD[attackLimit * 2][resistLimit];
	}
	Distribution p = meanDistribution (d);
	p = p + p; // 2 rounds
	p = p + p; // 2 * 2 = 4 rounds
	p = p + meanDistribution (e); // last round
	return p;
}

double [] [] factor;

static this ()
{
	factor = new double [] [] (damageLimit, damageLimit);
	foreach (d1; 0..damageLimit)
	{
		foreach (d2; 0..damageLimit)
		{
			factor[d1][d2] = max (0.0, min (1.0,
			    (d1 - d2 + 2) * 0.25));
		}
	}
}

double calcProbability (ref Wizard wizard1, ref Wizard wizard2)
{
	auto p = damageDistribution (wizard1, wizard2);
	auto q = damageDistribution (wizard2, wizard1);

	double res = 0.0;
	foreach (d1; 0..damageLimit)
	{
		foreach (d2; 0..damageLimit)
		{
			res += p[d1] * q[d2] * factor[d1][d2];
		}
	}
	return res;
}
