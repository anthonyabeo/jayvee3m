import std.stdio, core.stdc.stdlib: exit;
	   
import attributes;
import class_loader.loader;


void main(string[] args)
{
	if(args.length < 2) 
	{
		writefln("No class file found.");
		exit(1);
	}

	string class_file = args[1] ~ ".class";

	auto f = File(class_file, "r");
    auto buffer = f.rawRead(new ubyte[f.size()]);

	auto cf = BootstrapLoader.parse_class_file(buffer);
	writeln(cf);
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

// 
struct method_info
{
	size_t access_flags;
	size_t name_index;
	size_t descriptor_index;
	size_t attributes_count;
	ATTR_INFO[] attributes;
}