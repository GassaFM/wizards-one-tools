// Author: Ivan Kazmenko (gassa@mail.ru)
// Get JSON files for all available wizards from api.wizards.one site.
// Stores wizard number ID in file "ID.txt".
// Warning: it takes a long time!
module get_json;
import std.conv, std.net.curl, std.range, std.stdio;

immutable int lastId = 16361;

void main ()
{
	foreach (id; iota (1, lastId + 1))
	{
		stderr.writeln (id);
		try
		{
			File (id.text ~ ".txt", "w").write (get
			    ("api.wizards.one/wizards/" ~ id.text));
		}
		catch (Exception e)
		{
			stderr.writeln (e);
		}
	}
}
