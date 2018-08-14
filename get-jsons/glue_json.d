// Author: Ivan Kazmenko (gassa@mail.ru)
// Glue all wizard JSON files together.
module get_json;
import std.conv, std.exception, std.json, std.range, std.stdio;

immutable int lastId = 16361;

void main ()
{
	string [] s;
	foreach (id; iota (1, lastId + 1))
	{
		stderr.writeln (id);
		try
		{
			auto cur = File (id.text ~ ".txt").readln;
			enforce (!cur.empty);
			auto temp = parseJSON (cur);
			s ~= cur;
		}
		catch (Exception e)
		{
			stderr.writeln (e);
		}
	}
	File ("wizards.json", "w").writefln ("[%-(%s,%)]", s);
}
