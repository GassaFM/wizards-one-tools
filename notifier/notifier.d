// Author: Ivan Kazmenko (gassa@mail.ru)
// Monitors the magic shop.
// When an item with previous supply 0 appears,
// plays a sound and prints a message.
module notifier;
import core.stdc.stdlib, core.thread, std.datetime, std.exception;
import std.format, std.json, std.net.curl, std.range, std.stdio, std.string;
import allegro5.allegro;
import allegro5.allegro_audio;
import allegro5.allegro_acodec;

pragma (lib, "dallegro5");
pragma (lib, "allegro");
pragma (lib, "allegro_audio");
pragma (lib, "allegro_acodec");

immutable string apiEndpoint = "https://api.eosnewyork.io";
immutable string apiQuery = "/v1/chain/get_table_rows";
immutable string apiData = format ("{%(%s,%)}", [
    `"scope":"wizardstoken"`,
    `"code":"wizardstoken"`,
    `"table":"shop"`,
    `"json":"true"`,
    ]);

immutable auto once = ALLEGRO_PLAYMODE.ALLEGRO_PLAYMODE_ONCE;

ALLEGRO_SAMPLE * soundSample;

void searchForNew (ref JSONValue prev, ref JSONValue next)
{
	auto n = next["rows"].array.length;
	int s = 0;
	foreach (i; 0..n)
	{
		auto k = next["rows"][i]["possible"].array.length;
		foreach (j; 0..k)
		{
			if (prev["rows"][i]["possible"][j].integer == 0 &&
			    next["rows"][i]["possible"][j].integer != 0)
			{
				al_play_sample (soundSample, 0.5, 0.5, 1.0,
				    once, null);
				writeln ("New item in the shop! ",
				    "type = ", i, ", id = ", j);
			}
			s += next["rows"][i]["possible"][j].integer;
		}
	}
	writeln ("[", Clock.currTime !(ClockType.second).toString, "]",
	    "  Total supply: ", s, " items.");
	stdout.flush ();
}

void mainLoop ()
{
	JSONValue prev, next;
	while (true)
	{
		Thread.sleep (1000.msecs);
		try
		{
			next = parseJSON (post (apiEndpoint ~ apiQuery,
			    `{"scope":"wizardstoken","code":"wizardstoken",` ~
			    `"table":"shop","json":"true"}`));
		}
		catch (Exception e)
		{
			stderr.writeln (e);
			continue;
		}

		if (prev.type != JSON_TYPE.NULL && next.type != JSON_TYPE.NULL)
		{
			searchForNew (prev, next);
		}
		if (next.type != JSON_TYPE.NULL)
		{
			prev = next;
		}
	}
}

void init ()
{
	enforce (al_init ());
	enforce (al_install_audio ());
	enforce (al_init_acodec_addon ());
	enforce (al_reserve_samples (32));

	soundSample = al_load_sample ("sound-notifier.ogg".toStringz);
	enforce (soundSample !is null);
}

void happyEnd ()
{
	al_destroy_sample (soundSample);

	exit (EXIT_SUCCESS);
}

int main (string [] args)
{
	return al_run_allegro
	({
		init ();
		mainLoop ();
		happyEnd ();
		return 0;
	});
}
