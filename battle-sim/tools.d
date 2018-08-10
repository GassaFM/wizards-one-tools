// Author: Ivan Kazmenko (gassa@mail.ru)
// Auxiliary module to read JSON with wizards and tournament table.
module tools;
import std.algorithm, std.conv, std.json, std.range, std.stdio, std.string;
import wizard;

auto readWizards (string fileName)
{
	auto wizardsTable = File ("wizards.json").readln.parseJSON;
	Wizard [] wizards;
	foreach (cur; wizardsTable.array)
	{
		wizards ~= Wizard (cur["id"].integer.to !(int),
		    cur["dna"].array.map !(v => v.integer.to !(int)).array);
	}

	debug
	{
		foreach (wizard; wizards)
		{
			writefln ("Wizard %s:\n%s", wizards[$ - 1].id, wizards[$ - 1]);
		}
	}
	return wizards;
}

auto readWins (string fileName, int n)
{
	auto tableFile = File (fileName);
	auto wins = new int [] [] (n, n);
	foreach (i; 0..n)
	{
		foreach (j; 0..n)
		{
			tableFile.readf (" %s", &wins[i][j]);
		}
	}
	return wins;
}
