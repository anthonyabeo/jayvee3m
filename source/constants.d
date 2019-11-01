module constants;

import std.variant;


alias CP_INFO = Algebraic!(Method, Float, Long, Class, String, Double,
                           Field, UTF8, NameAndType, Integer, InterfaceMethod);


enum Constant : ubyte 
{
	Klass = 7,
	Fieldref = 9,
	Methodref = 10,
	InterfaceMethodref = 11,
	String = 8,
	Integer = 3,
	Float = 4,
	Long = 5,
	Double = 6,
	NameAndType = 12,
	Utf8 = 1
}

struct Method
{
	ubyte tag;
	size_t class_index;
	size_t name_type_index;
}

struct Field
{
	ubyte tag;
	size_t class_index;
	size_t name_type_index;
}

struct Class 
{
	ubyte tag;
	size_t name_index;
}

struct Float
{
	ubyte tag;
	float value;
}

struct Long
{
	ubyte tag;
	long value;
}

struct String
{
	ubyte tag;
	size_t string_index;
}

struct Double
{
	ubyte tag;
	double value;
}

struct UTF8
{
	ubyte tag;
	size_t len;
	immutable ubyte[] value;
}

struct NameAndType
{
	ubyte tag;
	size_t name_index;
	size_t descriptor_index;
}

struct Integer
{
	ubyte tag;
	int value;
}

struct InterfaceMethod
{
	ubyte tag;
	size_t class_index;
	size_t name_type_index;
}