module class_loader.loader;

import std.math, std.conv, std.typecons, std.file;

import app;
import utils;
import constants;
import attributes;
import class_loader.class_file;


/**
 *
 *
 */
struct BootstrapLoader
{
    ubyte[] input;  /// constains the binary rep of the class file
    size_t offset;  /// position in the 
    
    uint constPoolCnt;    /// size of the constant pool
    uint interfaceCnt;    /// number of interfaces
    uint fieldCnt;        /// number of fields
    uint attrCnt;       /// number of attributes
    uint methodCnt;     /// number of methods

    CP_INFO[] constPool;    /// constant pool

    /**
        Constructor

        Params:
            input = 
     */
    this(ubyte[] input) {
        this.input = input;
    }

    /**
     *
     *
     */
    ClassFile parseClassFile()
    {
        auto magic = this.readBE32();
        auto min_version = this.readBE16();
        auto maj_version = this.readBE16();

        this.constPoolCnt = this.readBE16();
        this.constPool = this.buildConstantPool();

        auto access_flags = this.readBE16();
        auto this_class = this.readBE16();
        auto super_class = this.readBE16();

        auto interface_cnt = this.readBE16();
        auto interfaces = this.buildInterfacesTable();

        this.fieldCnt = readBE16();
        auto fields = this.buildFieldsTable();

        this.methodCnt = this.readBE16();
        auto methods = this.buildMethodTable();

        this.attrCnt = this.readBE16();
        auto attributes = buildAttributesTable();

        auto cf = ClassFile(
            magic, min_version, maj_version, this.constPoolCnt, this.constPool, 
            access_flags, this_class, super_class, interface_cnt, interfaces, 
            this.fieldCnt, fields, this.methodCnt, methods, this.attrCnt, attributes
        );

        return cf;
    }

private:
    CP_INFO[] buildConstantPool()
    {
        CP_INFO[] pool = new CP_INFO[this.constPoolCnt];

        size_t next_index = 1;
        while (next_index < this.constPoolCnt)
        {
            ubyte tag = this.input[this.offset++];
            final switch (tag)
            {
            case Constant.Methodref:
                size_t class_index = this.readBE16();
                size_t name_type_index = this.readBE16();

                pool[next_index++] = CP_INFO(Method(tag, class_index, name_type_index));

                break;
            case Constant.Fieldref:
                immutable class_index = this.readBE16();
                immutable name_type_index = this.readBE16();

                pool[next_index++] = CP_INFO(Field(tag, class_index, name_type_index));

                break;
            case Constant.InterfaceMethodref:
                immutable class_index = this.readBE16();
                immutable name_type_index = this.readBE16();

                pool[next_index++] = CP_INFO(InterfaceMethod(tag, class_index, name_type_index));

                break;
            case Constant.Integer:
                immutable bytes = this.readBE32();
                pool[next_index++] = CP_INFO(Integer(tag, bytes));

                break;
            case Constant.Float:
                float value;
                immutable bytes = readBE32();

                if (bytes == 0x7f800000)
                    value = real.infinity;
                else if (bytes == 0xff800000)
                    value = -real.infinity;
                else if (bytes >= 0x7f800001 && bytes <= 0x7fffffff   || 
                         bytes >= 0xff800001 && bytes <= 0xffffffff)
                {
                    value = float.nan;
                }
                else
                {
                    immutable s = ((bytes >> 31) == 0) ? 1 : -1;
                    immutable e = ((bytes >> 23) & 0xff);
                    immutable m = (e == 0) ? (bytes & 0x7fffff) << 1 : (bytes & 0x7fffff) | 0x800000;

                    value = s * m * (pow(to!float(2), e - 150));
                }

                pool[next_index++] = CP_INFO(Float(tag, value));

                break;
            case Constant.Long:
                immutable high_bytes = to!ulong(this.readBE32());
                immutable low_bytes = to!ulong(this.readBE32());

                immutable bytes = (high_bytes << 32) + low_bytes;
                pool[next_index] = CP_INFO(Long(tag, bytes));

                next_index += 2;

                break;
            case Constant.Double:
                double value;
                immutable high_bytes = to!long(this.readBE32());
                immutable low_bytes = to!long(this.readBE32());

                immutable bytes = (high_bytes << 32) + low_bytes;

                if (bytes == 0x7f80000000000000)
                    value = real.infinity;
                else if (bytes == 0xff80000000000000)
                    value = -real.infinity;
                else if (bytes >= 0x7ff0000000000001 && bytes <= 0x7fffffffffffffff || 
                         bytes >= 0xfff0000000000001 && bytes <= 0xffffffffffffffff)
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

                next_index += 2;

                break;
            case Constant.Klass:
                immutable name_index = this.readBE16();
                pool[next_index++] = CP_INFO(Class(tag, name_index));

                break;
            case Constant.String:
                immutable string_index = this.readBE16();
                pool[next_index++] = CP_INFO(String(tag, string_index));

                break;
            case Constant.NameAndType:
                immutable name_index = this.readBE16();
                immutable descriptor_index = this.readBE16();

                pool[next_index++] = CP_INFO(NameAndType(tag, name_index, descriptor_index));

                break;
            case Constant.Utf8:
                immutable len = this.readBE16();
                immutable bytes = this.input[this.offset .. this.offset+len].idup;

                pool[next_index++] = CP_INFO(UTF8(tag, len, bytes));

                this.offset += len;

                break;
            }
        }

        return pool;
    }

    size_t[] buildInterfacesTable()
    {
        size_t[] interfaces;
        foreach(_; 0..this.interfaceCnt)
        {
            interfaces ~= readBE16();
        }

        return interfaces;
    }

    FieldInfo[] buildFieldsTable()
    {
        FieldInfo[] fields;

        foreach(_; 0..this.fieldCnt)
        {
            auto access_flags = this.readBE16();
            auto name_index = this.readBE16();
            auto descriptor_index = this.readBE16();

            this.attrCnt = this.readBE16();
            auto attributes = this.buildAttributesTable();

            fields ~= FieldInfo(access_flags, name_index, descriptor_index,
                                this.attrCnt, attributes);
        }

        return fields;
    }

    MethodInfo[] buildMethodTable()
    {
        MethodInfo[] methods;
        foreach (_; 0..this.methodCnt)
        {
            auto access_flags = this.readBE16(),
                 name_index = this.readBE16(),
                 descriptor_index = this.readBE16();

            this.attrCnt = this.readBE16();
            auto attributes = this.buildAttributesTable();

            methods ~= MethodInfo(access_flags, name_index, descriptor_index,
                                  this.attrCnt, attributes);
        }

        return methods;
    }

    ATTR_INFO[] buildAttributesTable()
    {
        ATTR_INFO[] attributes = new ATTR_INFO[this.attrCnt];

        for (size_t i = 0; i < this.attrCnt; i++)
        {
            size_t attr_name_index = this.readBE16();
            immutable cnstnt = *this.constPool[attr_name_index].peek!(UTF8);

            if (cnstnt.value == cast(ubyte[]) "SourceFile")
            {
                immutable attribute_len = this.readBE32(),
                          sourcefile_index = this.readBE16();

                attributes[i] = SourceFile(attr_name_index, attribute_len, sourcefile_index);
            }
            else if (cnstnt.value == cast(ubyte[]) "LineNumberTable")
            {
                immutable attribute_len = this.readBE32(),
                          line_num_table_len = this.readBE16();

                LineNumberAttr[] line_number_table;
                foreach(_; 0 .. line_num_table_len)
                {
                    auto start_pc = to!size_t(this.readBE16()),
                         line_number = to!size_t(this.readBE16());

                    line_number_table ~= LineNumberAttr(start_pc, line_number);
                }

                attributes[i] = LineNumberTable(attr_name_index, attribute_len,
                                                line_num_table_len, line_number_table);
            }
            else if (cnstnt.value == cast(ubyte[]) "ConstantValue")
            {
                const attribute_len = this.readBE32(),
                      constantvalue_index = this.readBE16();

                attributes[i] = ConstantValue(attr_name_index, attribute_len, constantvalue_index);
            }
            else if (cnstnt.value == cast(ubyte[]) "Code")
            {
                const attribute_len = this.readBE32(),
                      max_stack = this.readBE16(),
                      max_locals = this.readBE16(),
                     code_length = this.readBE32();

                ubyte[] code = this.input[this.offset.. this.offset+code_length];

                this.offset += code_length;
                const exception_tbl_len = this.readBE16();

                ExceptionAttr[] exception_table;
                if (exception_tbl_len > 0)
                {
                    size_t start_pc = this.readBE16(),
                           end_pc = this.readBE16(),
                           handler_pc = this.readBE16(),
                           catch_type = this.readBE16();

                    exception_table ~= ExceptionAttr(start_pc, end_pc, handler_pc, catch_type);
                }

                const attribute_count = this.readBE16();
                auto attrbt = this.buildAttributesTable();

                const ATTR_INFO a = Code(attr_name_index, attribute_len, max_stack, max_locals, code_length, code,
                        exception_tbl_len, exception_table, attribute_count, attrbt);

                attributes[i] = a;
            }
            else if (cnstnt.value == cast(ubyte[]) "Exception")
            {
                immutable attribute_len = this.readBE32(),
                          num_exceptions = this.readBE16();

                auto exception_index_table = new size_t[num_exceptions];
                foreach (_; 0..num_exceptions)
                {
                    exception_index_table ~= this.readBE16();
                }

                attributes[i] = Excepsion(attr_name_index, attribute_len,
                                          num_exceptions, exception_index_table);
            }
            else if (cnstnt.value == cast(ubyte[]) "LocalVariableTable")
            {
                immutable attribute_len = this.readBE32();
                immutable local_var_tbl_len = this.readBE16();

                LocalVarAttrs[] local_var_table;
                foreach (_; 0 .. local_var_tbl_len)
                {
                    auto start_pc = to!size_t(this.readBE16()),
                         length = to!size_t(this.readBE16()),
                         name_index = to!size_t(this.readBE16()),
                         descriptor_index = to!size_t(this.readBE16()),
                         index = to!size_t(this.readBE16());

                        local_var_table ~= LocalVarAttrs(start_pc, length, name_index, descriptor_index, index);
                }

                attributes[i] = LocalVariableTable(attr_name_index, attribute_len, 
                                                   local_var_tbl_len, local_var_table);
            }
        }

        return attributes;
    }

    /**
	Generate a numerical value from an array of four bytes
	in a big-endian format.

	Params:
		data = an immutable array of bytes of size 4 in big endian format;

	Returns:
		the numerical value of this array representation.
    */
    auto readBE32() 
    {
        auto value =  this.input[this.offset]   << 24 |
                      this.input[this.offset+1] << 16 |
                      this.input[this.offset+2] << 8  |
                      this.input[this.offset+3];

        this.offset += 4;

        return value;
    }

    /**
	Generate the 16-bit numerical value from an array of two bytes
	in a big-endian format.

	Params:
		data = an immutable array of bytes of size 2 in big endian format;

	Returns:
		the 16-bit numerical value of this array representation.
    */
    auto readBE16() 
    {
        auto value =  this.input[this.offset] << 8  | 
                      this.input[this.offset+1];
        
        this.offset += 2;

        return value;
    }
}
