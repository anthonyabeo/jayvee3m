module class_loader.class_file;

public import attributes : ATTR_INFO;
import constants : CP_INFO;
import app : FieldInfo, MethodInfo;

/// class file data structure
struct ClassFile
{
    /// magic number 0xcafebabe
    uint magic;

    /// minor and major versions of the compiler that generated the class file.
    uint minorVersion, majorVersion;

    /// number of items in the constant pool.
    uint constantPoolCount;

    /// an array of constants
    CP_INFO[] constantPool;

    /// accessFlags = mask of modifiers used with class and interface declarations.
    /// thisClass = a valid index into the constant_pool table.
    /// superClass = either must be zero or must be a valid index into the constant_pool table
    uint accessFlags, thisClass, superClass;

    /// number of entries in the interface table.
    uint interfaceCount;

    /// Each value in the interfaces array must be a valid index into the constant_pool table.
    size_t[] interfaces;

    /// the number of field_info structures in the fields table.
    uint fieldCount;

    /// a variable-length field_info structure giving a complete description of a 
    /// field in the class or interface type.
    FieldInfo[] fields;

    /// number of method_info structures in the methods table.
    uint methodCount;

    /// variable-length method_info structure giving a complete description of and
    /// Java Virtual Machine code for a method in the class or interface.
    MethodInfo[] methodInfo;

    /// number of attributes in the attributes table of this class
    uint attributeCount;

    /// variable-length attribute structure
    ATTR_INFO[] attributes;
}
