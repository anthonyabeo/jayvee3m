module attributes;

import std.typecons;
import sumtype;

alias ATTR_INFO = SumType!(SourceFile, ConstantValue, Excepsion, Code, LineNumberTable, LocalVariableTable);

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

struct Excepsion
{
	size_t attribute_name_index;
	size_t attribute_len;
	size_t number_of_exceptions;
	size_t[] exception_index_table;
}

struct Code
{
	size_t attribute_name_index;
	size_t attribute_len;
	size_t max_stack;
	size_t max_locals;
	size_t code_length;
	const(ubyte[]) code;
	size_t exception_table_length;
	Tuple!(size_t, size_t, size_t, size_t) exception_table;
	size_t attribute_count;
	ATTR_INFO[] attributes;
}

struct LocalVariableTable
{
	size_t attribute_name_index;
	size_t attribute_len;
	size_t local_variable_table_length;
	Tuple!(size_t, size_t, size_t, size_t, size_t)[] local_variable_table;
}

struct LineNumberTable
{
	size_t attribute_name_index;
	size_t attribute_len;
	size_t line_number_table_length;
	Tuple!(size_t, size_t)[] line_number_table;
}