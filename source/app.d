import std.stdio, std.file, std.variant, std.math, std.conv;


alias CP_INFO = Algebraic!(MethodRef, Float, Long);

void main()
{
	auto f = File("Main.class", "r");
	auto buffer = f.rawRead(new ubyte[f.size()]);

	auto magic = BE32(buffer[0 .. 4]);
	auto min_version = BE16(buffer[4 .. 6]);
	auto maj_version = BE16(buffer[6 .. 8]);
	auto const_pool_cnt = BE16(buffer[8 .. 10]);
	build_const_pool(buffer[10 .. const_pool_cnt + 10]);

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

void build_const_pool(const ubyte[] buffer) 
{
	CP_INFO[] pool = new CP_INFO[buffer.length];

	size_t i = 0, next_index = 1;
	while(i < 50)
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

				// writeln(method_ref);
				// writeln(pool);
				break;

			case Constant.Fieldref:
				writeln("field you best");

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
				else if(((bytes >= 0x7f800001) && (bytes <= 0x7fffffff)) || ((bytes >= 0xff800001) && (bytes <= 0xffffffff))) 
					value = float.nan;
				else {
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

				next_index += 1;
				i += 9;
				break;

			case Constant.Klass:
				writeln("classless cassidy");

				next_index += 1;
				i += 3;

				break;
			
			case Constant.String:
				writeln("stringifying");

				next_index += 1;
				i += 3;

				break;

			case Constant.NameAndType:
				writeln("Name Type");

				next_index += 1;
				i += 5;
				break;

			case Constant.Utf8:
				next_index += 1;

				break;
		}
		// break;
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

	this(ubyte tag, size_t class_index, size_t name_type_index) {
		this.tag = tag;
		this.class_index = class_index;
		this.name_type_index = name_type_index;
	}
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