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
    
    auto bl = BootstrapLoader(buffer);
    auto cf = bl.parseClassFile();
    // writeln(cf);
    auto jvm = JVM(cf, class_file);
    jvm.start();
}

/// FIELDS
struct FieldInfo
{
    /// indicates access permissions to this field.
    size_t accessFlags;

    /// index into the constant pool table. The value at that index
    /// must be a UTF-8 constant that represents a valid field name
    size_t nameIndex;

    /// index into the constant pool table.The value at that index
    /// must be a valid UTF-8 constant that represents a valid descriptor name.
    size_t descriptorIndex;

    /// number of attributes of this field
    size_t attributesCount;

    /// Each entry must be a variable length attribute structure.
    ATTR_INFO[] attributes;
}

/// 
struct MethodInfo
{
    /// indicates access permissions to this method
    size_t accessFlags;

    /// The value of the name_index item must be a valid index into the constant_pool table. 
    /// The constant_pool entry at that index must be a CONSTANT_Utf8_info structure representing
    /// either one of the special internal method names, either <init> or <clinit>, or a valid 
    /// Java method name, stored as a simple (not fully qualified) name.
    size_t nameIndex;

    /// index into the constant pool table.The value at that index
    /// must be a valid UTF-8 constant that represents a valid method descriptor.
    size_t descriptorIndex;

    /// number of attributes of this method
    size_t attributesCount;

    /// Each entry must be a variable length attribute structure.
    ATTR_INFO[] attributes;
}
