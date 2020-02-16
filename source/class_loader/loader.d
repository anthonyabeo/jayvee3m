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
    ClassFile parseClassFile(ubyte[] buffer)
    {
        auto magic = this.readBE32();
        auto min_version = this.readBE16();
        auto maj_version = this.readBE16();
        this.constPoolCnt = this.readBE16();
        auto const_pool = this.buildConstantPool();

        auto i = const_pool[1];
        auto access_flags = bigEndian16from(buffer[i .. i + 2]);
        auto this_class = bigEndian16from(buffer[i + 2 .. i + 4]);
        auto super_class = bigEndian16from(buffer[i + 4 .. i + 6]);
        auto interface_cnt = bigEndian16from(buffer[i + 6 .. i + 8]);
        auto interfaces = buildInterfacesTable(buffer, interface_cnt, i + 8);

        i = interfaces[1];
        auto field_cnt = bigEndian16from(buffer[i .. i + 2]);
        auto fields = buildFieldsTable(buffer, field_cnt, i + 2, const_pool[0]);

        i = fields[1];
        const methods_cnt = bigEndian16from(buffer[i .. i + 2]);
        auto methods = build_method_table(buffer, methods_cnt, i + 2, const_pool[0]);

        i = methods[1];
        const attr_cnt = bigEndian16from(buffer[i .. i + 2]);
        auto attributes = buildAttributesTable(buffer, attr_cnt, i + 2, const_pool[0]);

        auto cf = ClassFile(magic, min_version, maj_version, this.constPoolCnt, const_pool[0], access_flags,
                this_class, super_class, interface_cnt, interfaces[0], field_cnt,
                fields[0], methods_cnt, methods[0], attr_cnt, attributes[0]);

        return cf;
    }

private:
    Tuple!(CP_INFO[], size_t) buildConstantPool()
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

        // pool = pool[0 .. pool_cnt];
        return Tuple!(CP_INFO[], "const_pool", size_t, "start")(pool, this.offset);
    }

    static Tuple!(size_t[], size_t) buildInterfacesTable(ubyte[] buffer,
            size_t interface_cnt, size_t start)
    {
        size_t[] interfaces; //= new size_t[interface_cnt];
        size_t i = 0;
        while (i < interface_cnt)
        {
            interfaces ~= bigEndian16from(buffer[start .. start + 2]);
            start += 2;
            i += 1;
        }

        return Tuple!(size_t[], size_t)(interfaces, start);
    }

    static Tuple!(FieldInfo[], size_t) buildFieldsTable(ubyte[] buffer,
            size_t field_cnt, size_t start, CP_INFO[] pool)
    {
        FieldInfo[] fields; //= new FieldInfo[field_cnt];

        for (size_t i = 0; i < field_cnt; i++)
        {
            auto access_flags = bigEndian16from(buffer[start .. start + 2]);
            auto name_index = bigEndian16from(buffer[start + 2 .. start + 4]);
            auto descriptor_index = bigEndian16from(buffer[start + 4 .. start + 6]);
            auto attributes_count = bigEndian16from(buffer[start + 6 .. start + 8]);
            auto attributes = buildAttributesTable(buffer, attributes_count, start + 8, pool);

            fields ~= FieldInfo(access_flags, name_index, descriptor_index,
                    attributes_count, attributes[0]);
            start += attributes[1];
        }

        return Tuple!(FieldInfo[], size_t)(fields, start);
    }

    static Tuple!(MethodInfo[], size_t) build_method_table(ubyte[] buffer,
            size_t method_cnt, size_t start, CP_INFO[] pool)
    {
        MethodInfo[] methods;
        for (size_t i = 0; i < method_cnt; i++)
        {
            auto access_flags = bigEndian16from(buffer[start .. start + 2]),
                name_index = bigEndian16from(buffer[start + 2 .. start + 4]),
                descriptor_index = bigEndian16from(buffer[start + 4 .. start + 6]),
                attributes_count = bigEndian16from(buffer[start + 6 .. start + 8]),
                attributes = buildAttributesTable(buffer, attributes_count, start + 8, pool);

            methods ~= MethodInfo(access_flags, name_index, descriptor_index,
                    attributes_count, attributes[0]);
            start = attributes[1];
        }

        return Tuple!(MethodInfo[], size_t)(methods, start);
    }

    static Tuple!(ATTR_INFO[], size_t) buildAttributesTable(ubyte[] buffer,
            size_t attr_cnt, size_t start, CP_INFO[] pool)
    {
        ATTR_INFO[] attributes = new ATTR_INFO[attr_cnt];

        for (size_t i = 0; i < attr_cnt; i++)
        {
            size_t attr_name_index = bigEndian16from(buffer[start .. start + 2]);
            immutable cnstnt = *pool[attr_name_index].peek!(UTF8);

            if (cnstnt.value == cast(ubyte[]) "SourceFile")
            {
                immutable attribute_len = bigEndian32from(buffer[start + 2 .. start + 6]),
                    sourcefile_index = bigEndian16from(buffer[start + 6 .. start + 8]);

                attributes[i] = SourceFile(attr_name_index, attribute_len, sourcefile_index);

                start += 8;
            }
            else if (cnstnt.value == cast(ubyte[]) "LineNumberTable")
            {
                immutable attribute_len = bigEndian32from(buffer[start + 2 .. start + 6]),
                    line_num_table_len = bigEndian16from(buffer[start + 6 .. start + 8]);

                Tuple!(size_t, size_t)[] line_number_table;

                start += 8;
                for (size_t j = 0; j < line_num_table_len; j++)
                {
                    auto start_pc = to!size_t(bigEndian16from(buffer[start .. start + 2])),
                        line_number = to!size_t(bigEndian16from(buffer[start + 2 .. start + 4]));

                    line_number_table ~= tuple(start_pc, line_number);
                    start += 4;
                }

                attributes[i] = LineNumberTable(attr_name_index, attribute_len,
                        line_num_table_len, line_number_table);
            }
            else if (cnstnt.value == cast(ubyte[]) "ConstantValue")
            {
                const attribute_len = bigEndian32from(buffer[start + 2 .. start + 6]),
                    constantvalue_index = bigEndian16from(buffer[start + 6 .. start + 8]);

                attributes[i] = ConstantValue(attr_name_index, attribute_len, constantvalue_index);
                start += 8;
            }
            else if (cnstnt.value == cast(ubyte[]) "Code")
            {
                const attribute_len = bigEndian32from(buffer[start + 2 .. start + 6]),
                    max_stack = bigEndian16from(buffer[start + 6 .. start + 8]),
                    max_locals = bigEndian16from(buffer[start + 8 .. start + 10]),
                    code_length = bigEndian32from(buffer[start + 10 .. start + 14]);
                ubyte[] code = buffer[start + 14 .. start + 14 + code_length];

                start += (code_length + 14);
                const exception_tbl_len = bigEndian16from(buffer[start .. start + 2]);

                start += 2;
                Tuple!(size_t, size_t, size_t, size_t) exception_table;
                if (exception_tbl_len > 0)
                {
                    size_t start_pc = bigEndian16from(buffer[start .. start + 2]),
                        end_pc = bigEndian16from(buffer[start + 2 .. start + 4]),
                        handler_pc = bigEndian16from(buffer[start + 4 .. start + 6]),
                        catch_type = bigEndian16from(buffer[start + 6 .. start + 8]);

                    exception_table = tuple(start_pc, end_pc, handler_pc, catch_type);
                    start += 8;
                }

                const attribute_count = bigEndian16from(buffer[start .. start + 2]);
                auto attrbt = buildAttributesTable(buffer, attribute_count, start + 2, pool);

                const ATTR_INFO a = Code(attr_name_index, attribute_len, max_stack, max_locals, code_length, code,
                        exception_tbl_len, exception_table, attribute_count, attrbt[0]);

                attributes[i] = a;
                start = attrbt[1];
            }
            else if (cnstnt.value == cast(ubyte[]) "Exception")
            {
                immutable attribute_len = bigEndian32from(buffer[start + 2 .. start + 6]),
                    num_exceptions = bigEndian16from(buffer[start + 6 .. start + 8]);

                auto exception_index_table = new size_t[num_exceptions];
                start += 8;
                for (size_t j = 0; j < num_exceptions; j++)
                {
                    exception_index_table ~= bigEndian16from(buffer[start .. start + 2]);
                    start += 2;
                }

                attributes[i] = Excepsion(attr_name_index, attribute_len,
                        num_exceptions, exception_index_table);
            }
            else if (cnstnt.value == cast(ubyte[]) "LocalVariableTable")
            {
                immutable attribute_len = bigEndian32from(buffer[start + 2 .. start + 6]);
                immutable local_var_tbl_len = bigEndian16from(buffer[start + 6 .. start + 8]);

                start += 8;
                auto local_var_table = new Tuple!(size_t, size_t, size_t, size_t, size_t)[local_var_tbl_len];

                auto start_pc = to!size_t(bigEndian16from(buffer[start .. start + 2])),
                    length = to!size_t(bigEndian16from(buffer[start + 2 .. start + 4])),
                    name_index = to!size_t(bigEndian16from(buffer[start + 4 .. start + 6])),
                    descriptor_index = to!size_t(bigEndian16from(buffer[start + 6 .. start + 8])),
                    index = to!size_t(bigEndian16from(buffer[start + 8 .. start + 10]));

                for (size_t j = 0; j < local_var_tbl_len; j++)
                {
                    local_var_table ~= tuple(start_pc, length, name_index,
                            descriptor_index, index);
                    start += 10;
                }

                attributes[i] = LocalVariableTable(attr_name_index,
                        attribute_len, local_var_tbl_len, local_var_table);
            }
        }

        return Tuple!(ATTR_INFO[], size_t)(attributes, start);
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
