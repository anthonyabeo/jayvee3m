import std.stdio;
import std.file;
import core.stdc.stdlib : exit;

import vm : JVM;
import attributes;
import class_loader.loader;

void main(string[] args)
{
    if (args.length < 2)
    {
        writefln("No class file found.");
        exit(1);
    }

    string class_file = args[1] ~ ".class";

    auto f = File(class_file, "r");
    auto buffer = f.rawRead(new ubyte[f.size()]);

    auto cf = BootstrapLoader.parse_class_file(buffer);
    // writeln(cf);
    auto jvm = JVM(cf, class_file);
    jvm.start();
}

// FIELDS
struct FieldInfo
{
    size_t access_flags;
    size_t name_index;
    size_t descriptor_index;
    size_t attributes_count;
    ATTR_INFO[] attributes;
}

// 
struct MethodInfo
{
    size_t access_flags;
    size_t name_index;
    size_t descriptor_index;
    size_t attributes_count;
    ATTR_INFO[] attributes;
}
