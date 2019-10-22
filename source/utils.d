module utils;

auto bigEndian32from(const ubyte[] data) 
{
	return data[0] << 24 |
	       data[1] << 16 |
		   data[2] << 8  |
		   data[3];
}

auto bigEndian16from(const ubyte[] data) 
{
	return data[0] << 8  | 
	       data[1];
}