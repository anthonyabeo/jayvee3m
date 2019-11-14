module utils;

/**
	Generate a numerical value from an array of four bytes
	in a big-endian format.

	Params:
		data = an immutable array of bytes of size 4 in big endian format;

	Returns:
		the numerical value of this array representation.
*/
auto bigEndian32from(const ubyte[] data) 
{
	return data[0] << 24 |
	       data[1] << 16 |
		   data[2] << 8  |
		   data[3];
}

/**
	Generate the 16-bit numerical value from an array of two bytes
	in a big-endian format.

	Params:
		data = an immutable array of bytes of size 2 in big endian format;

	Returns:
		the 16-bit numerical value of this array representation.
*/
auto bigEndian16from(const ubyte[] data) 
{
	return data[0] << 8  | 
	       data[1];
}