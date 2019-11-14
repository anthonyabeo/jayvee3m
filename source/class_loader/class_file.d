module class_loader.class_file;

public import attributes : ATTR_INFO;
import constants : CP_INFO;
import app : FieldInfo, MethodInfo;

/// 
struct ClassFile
{
    /// 
    uint magic;

    /// 
    uint minorVersion, majorVersion;

    /// 
    uint constantPoolCount;

    /// 
    CP_INFO[] constantPool;

    /// 
    uint accessFlags, thisClass, superClass;

    /// 
    uint interfaceCount;

    /// 
    size_t[] interfaces;

    /// 
    uint fieldCount;

    /// 
    FieldInfo[] fields;

    /// 
    uint methodCount;

    /// 
    MethodInfo[] methodInfo;

    /// 
    uint attributeCount;

    /// 
    ATTR_INFO[] attributes;
}
