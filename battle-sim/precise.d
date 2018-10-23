// Author: Ivan Kazmenko (gassa@mail.ru)
// Calculates precise winning probabilities for all pairs of wizards.
// Runs a tournament for all wizards from "wizard.csv".
// To get a CSV, go to http://cryptobeings.com/wizardcsv.php.
// Writes resulting table to "precise.txt".
module precise;
import std.algorithm;
import std.conv;
import std.range;
import std.stdio;
import distribution;
import wizard;

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

void main ()
{
	auto wizards = readWizardsCSV ("wizard.csv");
	auto fileOut = File ("precise.txt", "wt");
	foreach (w1; wizards)
	{
		double prob = 0.0;
		double num = 0.0;
		double lo = 1.0;
		double hi = 0.0;
		int loId = -1;
		int hiId = -1;
		double [] probs;
		probs.reserve (wizards.length - 1);
//		stderr.writeln (w1.id);
		foreach (w2; wizards)
		{
			if (w2.id != w1.id)
			{
				auto cur = calcProbabilityNew (w1, w2);
				probs ~= cur;
				prob += cur;
				num += 1;
				if (lo > cur)
				{
					lo = cur;
					loId = w2.id;
				}
				if (hi < cur)
				{
					hi = cur;
					hiId = w2.id;
				}
			}
		}
		sort (probs);
		auto median = (probs[($ - 1) / 2] + probs[$ / 2]) *
		    0.5 * 100.0;
		prob = prob * 100.0 / num;
		lo = lo * 100.0;
		hi = hi * 100.0;
		fileOut.writefln ("Wizard #%-5s of %12s: ddc=%6.3f, " ~
		    "mean %5.2f%%, median %5.2f%%, " ~
		    "best %5.2f%% vs. #%-5s, worst %5.2f%% vs. #%-5s",
		    w1.id, w1.owner, w1.ddc, prob, median, hi, hiId, lo, loId);
		fileOut.flush ();
	}
}
