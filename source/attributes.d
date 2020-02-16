module attributes;

import std.typecons: Tuple;
import sumtype: SumType, match;

alias ATTR_INFO = SumType!(SourceFile, ConstantValue, Excepsion, Code, LineNumberTable, LocalVariableTable);

/**
	Source File Attribute

	sourcefileIndex = index of the name of the source file
 */
struct SourceFile
{	
	size_t attributeNameIndex;	/// attribute name index
	size_t attributeLength;		///	attribute length
	size_t sourcefileIndex;		///	source file index
}

/**
	Constant Value Attribute

	represents the value of a constant field that must be 
	(explicitly or implicitly) static
 */
struct ConstantValue
{	
	size_t attributeNameIndex;	///	attribute name index
	size_t attributeLength;		/// attribute length
	size_t constantValueIndex;	/// constant value index
}

/**
	Exception Attribute

	Indicates which checked exceptions a method may throw
 */
struct Excepsion
{ 
	size_t attributeNameIndex;		///	attribute name index
	size_t attributeLength;			///	attribute length
	size_t numberOfExceptions;		/// number of Exceptions
	size_t[] exceptionIndexTable;	/// exception index table
}

/**
	Code Attribute

	Contains the Java Virtual Machine instructions and auxiliary 
	information for a single Java method
 */
struct Code
{
	size_t attributeNameIndex;			///	attribute name index
	size_t attributeLength;		        ///	attribute length
	size_t maxStack;					/// stack capacity
	size_t maxLocals;					/// max locals
	size_t codeLength;					///	code length
	ubyte[] code;						/// code
	size_t exceptionTableLen;   		/// exception table length
	Tuple!(ulong, ulong, ulong, ulong) exceptionTable;		/// exceptiont able
	size_t attributeCount;				/// number of attributes
	ATTR_INFO[] attributes;				///	attributes
}

/**
 */
struct ExceptionAttr
{
	size_t start_pc;	/// start instruction pointer
	size_t end_pc;		/// end instruction pointer
	size_t handler_pc;	/// handler instruction pointer
	size_t catch_type;	/// catch type
}

/**
	Local Variable Table

	May be used by debuggers to determine the value of a given 
	local variable during the execution of a method.
 */ 
struct LocalVariableTable
{
	size_t attributeNameIndex;			/// attribute name index
	size_t attributeLength;				/// attribute length
	size_t localVarTableLen;			/// local variable table length
	Tuple!(size_t, size_t, size_t ,size_t, size_t)[] localVariableTable;	/// local variable table
}

/**
 */ 
 struct LocalVarAttrs {
	 size_t start_pc;		/// start instruction pointer
	 size_t length;			/// length
	 size_t nameIndex;		/// name index
	 size_t descIndex;		/// descriptor index;	
	 size_t index;			/// index
 }

/**
	Line Number Table
	
	May be used by debuggers to determine which part of the Java 
	Virtual Machine code array corresponds to a given line number 
	in the original Java source file.
 */ 
struct LineNumberTable
{
	size_t attributeNameIndex;					///  attribute name index
	size_t attributeLength;						///  attribute length
	size_t lineNumTableLength;					///  line number table length
	Tuple!(ulong, ulong)[] lineNumberTable;	        ///  line number table
}

/**
 */
struct LineNumberAttr
{
	size_t start_pc;		/// start instruction pointer
	size_t lineNumber;		/// line number
}

auto get_attribute(ATTR_INFO attr)
{
	return attr.match!(
		(Code c) => Code(c.attributeNameIndex, c.attributeLength, c.maxStack, c.maxLocals,
						c.codeLength, c.code, c.exceptionTableLen, c.exceptionTable,
						c.attributeCount, c.attributes),
		_ => Code()
	);
}