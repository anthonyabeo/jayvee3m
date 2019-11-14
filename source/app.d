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

    auto cf = BootstrapLoader.parseClassFile(buffer);
    // writeln(cf);
    auto jvm = JVM(cf, class_file);
    jvm.start();
}

/// FIELDS
struct FieldInfo
{
    /// 
    size_t accessFlags;

    /// 
    size_t nameIndex;

    /// 
    size_t descriptorIndex;

    /// 
    size_t attributesCount;

    /// 
    ATTR_INFO[] attributes;
}

/// 
struct MethodInfo
{
    /// 
    size_t accessFlags;

    /// 
    size_t nameIndex;

    /// 
    size_t descriptorIndex;

    /// 
    size_t attributesCount;

    /// 
    ATTR_INFO[] attributes;
}
