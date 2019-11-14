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
    uint minor_version, major_version;

    /// 
    uint const_pool_count;

    /// 
    CP_INFO[] constant_pool;

    /// 
    uint access_flags, this_class, super_class;

    /// 
    uint interface_count;

    /// 
    size_t[] interfaces;

    /// 
    uint field_count;

    /// 
    FieldInfo[] fields;

    /// 
    uint method_cnt;

    /// 
    MethodInfo[] m_info;

    /// 
    uint attribute_count;

    /// 
    ATTR_INFO[] attributes;
}
