module attributes;

import std.typecons: Tuple;
import sumtype: SumType, match;

alias ATTR_INFO = SumType!(SourceFile, ConstantValue, Excepsion, Code, LineNumberTable, LocalVariableTable);

///
struct SourceFile
{	
	/// 
	size_t attributeNameIndex;

	/// 
	size_t attributeLength;

	/// 
	size_t sourcefileIndex;
}

///
struct ConstantValue
{	
	/// 
	size_t attributeNameIndex;

	/// 
	size_t attributeLength;

	/// 
	size_t constantValueIndex;
}

/// 
struct Excepsion
{
	/// 
	size_t attributeNameIndex;

	/// 
	size_t attributeLength;

	/// 
	size_t numberOfExceptions;

	/// 
	size_t[] exceptionIndexTable;
}

/// 
struct Code
{
	/// 
	size_t attributeNameIndex;

	/// 
	size_t attributeLength;

	/// 
	size_t maxStack;

	/// 
	size_t maxLocals;

	/// 
	size_t codeLength;

	/// 
	ubyte[] code;

	/// 
	size_t exceptionTableLength;

	/// 
	Tuple!(size_t, size_t, size_t, size_t) exceptionTable;

	/// 
	size_t attributeCount;

	/// 
	ATTR_INFO[] attributes;
}

/// 
struct LocalVariableTable
{
	/// 
	size_t attributeNameIndex;

	/// 
	size_t attributeLength;

	/// 
	size_t localVariableTableLength;

	/// 
	Tuple!(size_t, size_t, size_t, size_t, size_t)[] localVariableTable;
}

/// 
struct LineNumberTable
{
	/// 
	size_t attributeNameIndex;

	/// 
	size_t attributeLength;

	/// 
	size_t lineNumberTableLength;

	/// 
	Tuple!(size_t, size_t)[] lineNumberTable;
}

auto get_attribute(ATTR_INFO attr)
{
	return attr.match!(
		(Code c) => Code(c.attributeNameIndex, c.attributeLength, c.maxStack, c.maxLocals,
						c.codeLength, c.code, c.exceptionTableLength, c.exceptionTable,
						c.attributeCount, c.attributes),
		_ => Code()
	);
}