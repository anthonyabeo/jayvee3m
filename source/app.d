import std.stdio, std.file, std.variant, std.math, std.conv, std.typecons;
import constants, utils;


alias CP_INFO = Algebraic!(Method, Float, Long, Class, String, Double, 
                           Field, UTF8, NameAndType, Integer, InterfaceMethod);

alias ATTR_INFO = Algebraic!(SourceFile, ConstantValue);


void main()
{
	auto f = File("Main.class", "r");
	auto buffer = f.rawRead(new ubyte[f.size()]);

	auto magic = BE32(buffer[0 .. 4]);
	auto min_version = BE16(buffer[4 .. 6]);
	auto maj_version = BE16(buffer[6 .. 8]);
	auto const_pool_cnt = BE16(buffer[8 .. 10]);
	auto data = build_const_pool(buffer, const_pool_cnt, 10);
	// writeln(data[0]);
	writeln(data[1]);
	auto i = data[1];
	auto access_flags = BE16(buffer[i .. i+2]);
	auto this_class = BE16(buffer[i+2 .. i+4]);
	auto super_class = BE16(buffer[i+4 .. i+6]);
	auto interface_cnt = BE16(buffer[i+6 .. i+8]);
	auto intrfcs = build_interfaces_table(buffer, interface_cnt, i+8);

	i = intrfcs[1];
	auto field_cnt = BE16(buffer[i .. i+2]);
	auto flds = build_fields_table(buffer, field_cnt, i+2, data[0]);

	i = flds[1];
	auto methods_cnt = BE16(buffer[i .. i+2]);
	auto mthds = build_method_table(buffer, methods_cnt, i+2);

	writefln("%x", magic);
	writefln("%x", min_version);
	writefln("%x", maj_version);
	writefln("%x", const_pool_cnt);
	writefln("%x", access_flags);
	writefln("%x", this_class);
	writefln("%x", super_class);
	writefln("%x", interface_cnt);
	writeln(intrfcs[0]);
	writeln(intrfcs[1]);
	writefln("%x", field_cnt);
	writeln(flds[0]);
	writeln(flds[1]);
	writefln("%x", methods_cnt);
}

Tuple!(CP_INFO[], size_t) build_const_pool(const ubyte[] buffer, size_t pool_cnt, size_t start) 
{
	CP_INFO[] pool = new CP_INFO[pool_cnt];

	size_t i = start, next_index = 1;
	while(next_index < pool_cnt)
	{
		ubyte tag = buffer[i];
		final switch(tag) 
		{
			case Constant.Methodref:
				// writeln("methodoligical");
				size_t class_index = BE16(buffer[i+1 .. i+3]);
				size_t name_type_index = BE16(buffer[i+3 .. i+5]);

				pool[next_index] = CP_INFO(Method(tag, class_index, name_type_index));

				next_index += 1;
				i += 5;

				break;

			case Constant.Fieldref:
				// writeln("field you best");

				immutable class_index = BE16(buffer[i+1 .. i+3]);
				immutable name_type_index = BE16(buffer[i+3 .. i+5]);

				pool[next_index] = CP_INFO(Field(tag, class_index, name_type_index));

				next_index += 1;
				i += 5;

				break;
			
			case Constant.InterfaceMethodref:
				// writeln("interfacing methods");
				
				immutable class_index = BE16(buffer[i+1 .. i+3]);
				immutable name_type_index = BE16(buffer[i+3 .. i+5]);

				pool[next_index] = CP_INFO(InterfaceMethod(tag, class_index, name_type_index));

				next_index += 1;
				i += 5;

				break;

			case Constant.Integer:
				// writeln("integral");

				immutable bytes = BE32(buffer[i+1 .. i+5]);
				pool[next_index] =  CP_INFO(Integer(tag, bytes));

				next_index += 1;
				i += 5;

				break;

			case Constant.Float:
				// writeln("floating away");
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
				// writeln("longing for love");

				immutable high_bytes = to!ulong(BE32(buffer[i+1 .. i+5]));
				immutable low_bytes = to!ulong(BE32(buffer[i+5 .. i+9]));

				immutable bytes = (high_bytes << 32) + low_bytes;
				pool[next_index] = CP_INFO(Long(tag, bytes));

				// writeln(bytes);

				next_index += 2;
				i += 9;

				break;

			case Constant.Double:
				// writeln("doubling down");

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
				// writeln(value);

				next_index += 2;
				i += 9;
				
				break;

			case Constant.Klass:
				// writeln("classless cassidy");

				immutable name_index = BE16(buffer[i+1 .. i+3]);
				pool[next_index] = CP_INFO(Class(tag, name_index));

				next_index += 1;
				i += 3;

				break;
			
			case Constant.String:
				// writeln("stringifying");

				immutable string_index = BE16(buffer[i+1 .. i+3]);
				pool[next_index] = CP_INFO(String(tag, string_index));
				// writeln(string_index);

				next_index += 1;
				i += 3;

				break;

			case Constant.NameAndType:
				// writeln("Name Type");

				immutable name_index = BE16(buffer[i+1 .. i+3]);
				immutable descriptor_index = BE16(buffer[i+3 .. i+5]);

				pool[next_index] =  CP_INFO(NameAndType(tag, name_index, descriptor_index));

				next_index += 1;
				i += 5;

				break;

			case Constant.Utf8:
				// writeln("UTF-8 for the win");

				immutable len = BE16(buffer[i+1 .. i+3]);
				immutable bytes = buffer[i+3 .. i+3+len].idup;

				pool[next_index] = CP_INFO(UTF8(tag, len, bytes));
				// writeln(bytes);

				next_index += 1;
				i += (len+3);

				break;
		}
	}

	pool = pool[0 .. pool_cnt];
	return Tuple!(CP_INFO[], "const_pool", size_t, "start")(pool, i);
}

Tuple!(size_t[], size_t) build_interfaces_table(const ubyte[] buffer, size_t interface_cnt, size_t start)
{
	size_t[] interfaces = new size_t[interface_cnt];
	size_t i = 0;
	while(i < interface_cnt)
	{
		interfaces ~= BE16(buffer[start .. start+2]);
		start += 2;
		i += 1;
	}

	return Tuple!(size_t[], size_t) (interfaces, start);
}

Tuple!(field_info[], size_t) build_fields_table(const ubyte[] buffer, size_t field_cnt, size_t start, CP_INFO[] pool)
{
	field_info[] fields = new field_info[field_cnt];

	for(size_t i = 0; i < field_cnt; i++)
	{
		auto access_flags = BE16(buffer[start .. start+2]);
		auto name_index = BE16(buffer[start+2 .. start+4]);
		auto descriptor_index = BE16(buffer[start+4 .. start+6]);
		auto attributes_count = BE16(buffer[start+6 .. start+8]);
		auto attributes = build_attributes_table(buffer, attributes_count, start+8, pool);

		fields ~= field_info(access_flags, name_index, descriptor_index, attributes_count, attributes[0]);
		start += attributes[1];
	}
	
	return Tuple!(field_info[], size_t) (fields, start);
}

Tuple!(ATTR_INFO[], size_t) build_attributes_table(const ubyte[] buffer, size_t attr_cnt, size_t start, CP_INFO[] pool)
{
	ATTR_INFO[] attributes = new ATTR_INFO[attr_cnt];

	for(size_t i = 0; i < attr_cnt; i++)
	{
		size_t attr_name_index = BE16(buffer[start .. start+2]);
		immutable cnstnt = *pool[attr_name_index].peek!(UTF8);

		if(cnstnt.value == cast(ubyte[])"SourceFilex") 
		{
			immutable attribute_len = BE32(buffer[start+2 .. start+6]);
			immutable sourcefile_index = BE16(buffer[start+6 .. start+8]);

			attributes[i] = SourceFile(attr_name_index, attribute_len, sourcefile_index);

			start += 8;
		} 
		else if(cnstnt.value == cast(ubyte[])"LineNumberTable")
		{

		}
		else if(cnstnt.value == cast(ubyte[])"ConstantValue")
		{
			immutable attribute_len = BE32(buffer[start+2 .. start+6]);
			immutable constantvalue_index = BE16(buffer[start+6 .. start+8]);

			attributes[i] = ConstantValue(attr_name_index, attribute_len, constantvalue_index);
			start += 8;
		}
		else if(cnstnt.value == cast(ubyte[])"Code")
		{

		}
		else if(cnstnt.value == cast(ubyte[])"Exception")
		{

		}
		else if(cnstnt.value == cast(ubyte[])"LocalVariableTable")
		{

		}
	}

	return Tuple!(ATTR_INFO[], size_t) (attributes, start);
}



// FIELDS
struct field_info
{
	size_t access_flags;
	size_t name_index;
	size_t descriptor_index;
	size_t attributes_count;
	ATTR_INFO[] attributes;
}


// ATTRIBUTES
struct SourceFile
{	
	size_t attribute_name_index;
	size_t attribute_len;
	size_t sourcefile_index;
}

struct ConstantValue
{	
	size_t attribute_name_index;
	size_t attribute_len;
	size_t constantvalue_index;
}