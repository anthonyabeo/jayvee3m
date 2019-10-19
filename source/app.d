import std.stdio, std.file, std.variant, std.math, std.conv;


alias CP_INFO = Algebraic!(MethodRef, Float, Long, Class, String, Double, FieldRef, UTF8);

void main()
{
	auto f = File("Main.class", "r");
	auto buffer = f.rawRead(new ubyte[f.size()]);

	auto magic = BE32(buffer[0 .. 4]);
	auto min_version = BE16(buffer[4 .. 6]);
	auto maj_version = BE16(buffer[6 .. 8]);
	auto const_pool_cnt = BE16(buffer[8 .. 10]);
	build_const_pool(buffer, const_pool_cnt, 10);

	writefln("%x", magic);
	writefln("%x", min_version);
	writefln("%x", maj_version);
	writefln("%x", const_pool_cnt);
}

auto BE32(const ubyte[] data) 
{
	return data[0] << 24 |
	       data[1] << 16 |
		   data[2] << 8  |
		   data[3];
}

auto BE16(const ubyte[] data) 
{
	return data[0] << 8  | 
	       data[1];
}

void build_const_pool(const ubyte[] buffer, size_t pool_cnt, size_t start) 
{
	CP_INFO[] pool = new CP_INFO[buffer.length];

	size_t i = start, next_index = 1;
	while(next_index < pool_cnt)
	{
		ubyte tag = buffer[i];
		final switch(tag) 
		{
			case Constant.Methodref:
				writeln("methodoligical");
				size_t class_index = BE16(buffer[i+1 .. i+3]);
				size_t name_type_index = BE16(buffer[i+3 .. i+5]);

				pool[next_index] = CP_INFO(MethodRef(tag, class_index, name_type_index));

				next_index += 1;
				i += 5;

				break;

			case Constant.Fieldref:
				writeln("field you best");

				immutable class_index = BE16(buffer[i+1 .. i+3]);
				immutable name_type_index = BE16(buffer[i+3 .. i+5]);

				pool[next_index] = CP_INFO(FieldRef(tag, class_index, name_type_index));

				next_index += 1;
				i += 5;

				break;
			
			case Constant.InterfaceMethodref:
				writeln("interfacing methods");
				
				next_index += 1;
				i += 5;

				break;

			case Constant.Integer:
				writeln("integral");
				
				next_index += 1;
				i += 5;

				break;

			case Constant.Float:
				writeln("floating away");
				float value;
				immutable bytes = BE32(buffer[i+1 .. i+5]);

				if(bytes == 0x7f800000) 
					value = real.infinity;
				else if(bytes == 0xff800000) 
					value = -real.infinity;
				else if(((bytes >= 0x7f800001) && (bytes <= 0x7fffffff)) || 
				        ((bytes >= 0xff800001) && (bytes <= 0xffffffff))) 
				{
					value = float.nan;
				}
				else 
				{
					immutable s = ((bytes >> 31) == 0) ? 1 : -1;
					immutable e = ((bytes >> 23) & 0xff);
					immutable m = (e == 0) ? (bytes & 0x7fffff) << 1 :
							                 (bytes & 0x7fffff) | 0x800000;

					value = s * m * (pow(to!float(2), e - 150));
				}

				pool[next_index] = CP_INFO(Float(tag, value));

				next_index += 1; 
				i += 5;

				break;

			case Constant.Long:
				writeln("longing for love");

				immutable high_bytes = to!ulong(BE32(buffer[i+1 .. i+5]));
				immutable low_bytes = to!ulong(BE32(buffer[i+5 .. i+9]));

				immutable bytes = (high_bytes << 32) + low_bytes;
				pool[next_index] = CP_INFO(Long(tag, bytes));

				writeln(bytes);

				next_index += 2;
				i += 9;

				break;

			case Constant.Double:
				writeln("doubling down");

				double value;
				immutable high_bytes = to!long(BE32(buffer[i+1 .. i+5]));
				immutable low_bytes = to!long(BE32(buffer[i+5 .. i+9]));

				immutable bytes = (high_bytes << 32) + low_bytes;

				if(bytes == 0x7f80000000000000) 
					value = real.infinity;
				else if(bytes == 0xff80000000000000) 
					value = -real.infinity;
				else if(((bytes >= 0x7ff0000000000001) && (bytes <= 0x7fffffffffffffff)) || 
						((bytes >= 0xfff0000000000001) && (bytes <= 0xffffffffffffffff))) 
				{
					value = double.nan;
				}
				else 
				{
					immutable s = ((bytes >> 63) == 0) ? 1 : -1;
					immutable e = to!int((bytes >> 52) & 0x7ff);
					immutable m = (e == 0) ? (bytes & 0xfffffffffffff) << 1 :
										     (bytes & 0xfffffffffffff) | 0x10000000000000;

					value = s * m * (pow(to!double(2), e - 1075));
				}

				pool[next_index] = CP_INFO(Double(tag, value));
				writeln(value);

				next_index += 2;
				i += 9;
				
				break;

			case Constant.Klass:
				writeln("classless cassidy");

				immutable name_index = BE16(buffer[i+1 .. i+3]);
				pool[next_index] = CP_INFO(Class(tag, name_index));

				next_index += 1;
				i += 3;

				break;
			
			case Constant.String:
				writeln("stringifying");

				immutable string_index = BE16(buffer[i+1 .. i+3]);
				pool[next_index] = CP_INFO(String(tag, string_index));
				writeln(string_index);

				next_index += 1;
				i += 3;

				break;

			case Constant.NameAndType:
				writeln("Name Type");

				next_index += 1;
				i += 5;
				break;

			case Constant.Utf8:
				writeln("UTF-8 for the win");

				immutable len = BE16(buffer[i+1 .. i+3]);
				immutable bytes = buffer[i+3 .. i+3+len].idup;

				pool[next_index] = CP_INFO(UTF8(tag, len, bytes));
				writeln(bytes);

				next_index += 1;
				i += (len+3);

				break;
		}
	}
}

enum Constant : ubyte 
{
	Klass = 7,
	Fieldref = 9,
	Methodref = 10,
	InterfaceMethodref = 11,
	String = 8,
	Integer = 3,
	Float = 4,
	Long = 5,
	Double = 6,
	NameAndType = 12,
	Utf8 = 1
}

struct MethodRef 
{
	ubyte tag;
	size_t class_index;
	size_t name_type_index;
}

struct FieldRef
{
	ubyte tag;
	size_t class_index;
	size_t name_type_index;
}

struct Class 
{
	ubyte tag;
	size_t name_index;
}

struct Float
{
	ubyte tag;
	float value;
}

struct Long
{
	ubyte tag;
	long value;
}

struct String
{
	ubyte tag;
	size_t string_index;
}

struct Double
{
	ubyte tag;
	double value;
}

struct UTF8
{
	ubyte tag;
	size_t len;
	immutable ubyte[] value;
}