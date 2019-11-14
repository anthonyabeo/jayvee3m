module constants;

import std.variant;

alias CP_INFO = Algebraic!(Method, Float, Long, Class, String, Double, Field,
        UTF8, NameAndType, Integer, InterfaceMethod);

///
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

///
struct Method
{
    ///
    ubyte tag;

    ///
    size_t classIndex;

    ///
    size_t nameTypeIndex;
}

///
struct Field
{
    ///
    ubyte tag;

    ///
    size_t classIndex;

    ///
    size_t nameTypeIndex;
}

///
struct Class
{
    ///
    ubyte tag;

    ///
    size_t nameIndex;
}

///
struct Float
{
    ///
    ubyte tag;

    ///
    float value;
}

///
struct Long
{
    ///
    ubyte tag;

    ///
    long value;
}

///
struct String
{
    ///
    ubyte tag;

    ///
    size_t stringIndex;
}

///
struct Double
{
    ///
    ubyte tag;

    ///
    double value;
}

///
struct UTF8
{
    ///
    ubyte tag;

    ///
    size_t len;

    ///
    immutable ubyte[] value;
}

///
struct NameAndType
{
    ///
    ubyte tag;

    ///
    size_t nameIndex;

    ///
    size_t descriptorIndex;
}

///
struct Integer
{
    ///
    ubyte tag;

    ///
    int value;
}

///
struct InterfaceMethod
{
    ///
    ubyte tag;

    ///
    size_t classIndex;

    ///
    size_t nameTypeIndex;
}
