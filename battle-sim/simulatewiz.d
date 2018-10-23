// Author: Ivan Kazmenko (gassa@mail.ru)
// Calculates winning probability for a battle of two wizards.
// Reads two DNA strings separated by underscores from two command line arguments.
// Writes the result to standard output.
// Example usage (wizards #272 and #2):
// ./simulatewiz 54_39_45_56_44_34_41_47 44_45_55_65_68_32_46_58
// Example output:
// 35.23%
module simulatewiz;
import std.algorithm, std.conv, std.range, std.stdio;
import distribution, wizard;

void main (string [] args)
{
	auto wizard1 = Wizard (args[1].split ("_").map !(to !(int)).array);
	auto wizard2 = Wizard (args[2].split ("_").map !(to !(int)).array);
//	writefln ("%5.2f%%", calcProbabilityOld (wizard1, wizard2) * 100.0);
	writefln ("%5.2f%%", calcProbabilityNew (wizard1, wizard2) * 100.0);
}
