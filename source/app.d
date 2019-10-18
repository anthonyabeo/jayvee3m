import std.stdio, std.file;

void main()
{
	auto f = File("Main.class", "r");
	auto buffer = f.rawRead(new ubyte[f.size()]);

	auto magic = BE32(buffer[0 .. 4]);
	auto min_version = BE16(buffer[4 .. 6]);
	auto maj_version = BE16(buffer[6 .. 8]);
	auto const_pool_cnt = BE16(buffer[8 .. 10]);
	cp_info[] const_pool = build_const_pool(buffer, 10);

	writefln("%x", magic);
	writefln("%x", min_version);
	writefln("%x", maj_version);
	writefln("%x", const_pool_cnt);
}

auto BE32(ubyte[] data) 
{
	return data[0] << 24 |
	       data[1] << 16 |
		   data[2] << 8  |
		   data[3];
}

auto BE16(ubyte[] data) 
{
	return data[0] << 8  |
		   data[1];
}

cp_info[] build_const_pool(ubyte[] buffer, size_t start_index) 
{
	
}