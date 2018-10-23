// Author: Ivan Kazmenko (gassa@mail.ru)
// Picks the best matchup agains a given wizard for DNA battle.
// Needs "wizard.csv" to load wizards data.
// To get a CSV, go to http://cryptobeings.com/wizardcsv.php.
// Writes results to standard output.
module matchup;
import std.algorithm;
import std.conv;
import std.exception;
import std.range;
import std.stdio;
import distribution;
import wizard;

immutable int NA = -1;

Wizard [] readWizardsCSV (string fileName)
{
	auto f = File (fileName, "rt");
	Wizard [] res;
	foreach (line; f.byLineCopy.drop (1).map !(x => x.split (";")))
	{
		auto p = line[5..13].map !(to !(int)).array;
		if (sum (p) > 0)
		{
			res ~= Wizard (line[0].to !(int), line[1], p);
		}
	}
	debug {writeln (res.length);}
	reverse (res);
	return res;
}

void main (string [] args)
{
	Wizard [] wizards;
	try
	{
		wizards = readWizardsCSV ("wizard.csv");
	}
	catch (Exception e)
	{
		stderr.writeln (e);
		writeln ("This program needs \"wizard.csv\" to load wizards data.");
		writeln ("Please visit http://cryptobeings.com/wizardcsv.php to obtain it.");
		return;
	}

	int id1;
	string account2;
	real ddcLo = 0.0;
	real ddcHi = 99.99;
	bool toMatch = false;
	try
	{
		enforce (args.length > 2);
		id1 = args[1].to !(int);
		account2 = args[2];
		if (args.length > 3 && args[3] == "match")
		{
			toMatch = true;
		}
		else if (args.length > 4)
		{
			ddcLo = args[3].to !(real);
			ddcHi = args[4].to !(real);
		}
	}
	catch (Exception e)
	{
		stderr.writeln (e);
		writeln ("Usage 1 (any wizard):  matchup <wizard-id> <player-name>");
		writeln ("Usage 2 (match DDC):   matchup <wizard-id> <player-name> match");
		writeln ("Usage 3 (DDC limits):  matchup <wizard-id> <player-name> <ddc-from> <ddc-to>");
		return;
	}

	int w1Num = NA;
	foreach (num, w1; wizards)
	{
		if (w1.id == id1)
		{
			w1Num = num;
			break;
		}
	}
	if (w1Num == NA)
	{
		writefln ("Wizard #%-5s not found", id1);
		return;
	}

	auto w1 = wizards[w1Num];
	writefln ("Searching for counter to wizard #%-5s of %12s: ddc=%6.3f",
	    w1.id, w1.owner, w1.ddc);

	if (toMatch)
	{
		ddcLo = wizards[w1Num].ddc;
		ddcHi = wizards[w1Num].ddc;
	}

	double hi = 0.0;
	int hiNum = NA;
	foreach (num2, w2; wizards)
	{
		if (w2.owner != account2 || w2.id == w1.id ||
		    w2.ddc < ddcLo || ddcHi < w2.ddc)
		{
			continue;
		}
		auto cur = calcProbabilityNew (w2, w1);
		if (hi < cur)
		{
			hi = cur;
			hiNum = num2;
		}
		writefln ("Wizard #%-5s of %12s: " ~
		    "ddc=%6.3f, probability %5.2f%%",
		    w2.id, w2.owner, w2.ddc, cur * 100.0);
	}
	if (hiNum == NA)
	{
		writefln ("No counter found");
	}
	hi = hi * 100.0;
	auto w2 = wizards[hiNum];
	writefln ("Best counter is wizard #%-5s of %12s: " ~
	    "ddc=%6.3f, probability %5.2f%%", w2.id, w2.owner, w2.ddc, hi);
}
