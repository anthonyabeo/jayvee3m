module constants;

import std.variant;

alias CP_INFO = Algebraic!(Method, Float, Long, Class, String, Double, Field,
        UTF8, NameAndType, Integer, InterfaceMethod);

/**
 * Tags for identifying the various constant types supported in the JVM.
 */
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

/**
 * Represents a reference to method as indicated by a tag value of 10.
 * The classIndex field points to the class (in the constant pool) for
 * which this method belongs. The nameTypeIndex refers to the constant
 * holding the name and descriptor of the method.
 */
struct Method
{
    ubyte tag;              /// tag
    size_t classIndex;      /// class index
    size_t nameTypeIndex;   /// name type index
}

/**
 * Represents a reference to field as indicated by a tag value of 9.
 * The classIndex field points to the class (in the constant pool) for
 * which this field belongs. The nameTypeIndex refers to the constant
 * holding the name and descriptor of the field.
 */
struct Field
{
    ubyte tag;              /// tag
    size_t classIndex;      /// class index
    size_t nameTypeIndex;   /// name type index
}

/**
 * the nameIndex field must be a valid index that points to a UTF8 in the
 * constant pool. The UTF8 should hold the valid binary class or interface
 * name encoded in internal form.
 */
struct Class
{
    ubyte tag;          /// tag
    size_t nameIndex;   /// name index
}

/**
 * Represents a 4-byte (32-bit) signed float value. 
 * It has a tag value of 4
 */
struct Float
{
    ubyte tag;      /// tag
    float value;    /// value
}

/**
 * Represents an 8-byte (64-bit) signed long value. 
 * It has a tag value of 5;
 */
struct Long
{
    ubyte tag;      /// tag
    long value;     /// value
}

/**
 * String constants have a tag of 8. The stringIndex is a valid index to the
 * constant pool and points to a UT8-constant that holds the actual UTF-8
 * bytes that make up the actual string.
 */
struct String
{
    ubyte tag;          /// tag
    size_t stringIndex; /// string index
}

/**
 * Represents an 8-byte (64-bit) signed double value. 
 * It has a tag value of 6;
 */
struct Double
{
    ubyte tag;      /// tag
    double value;   /// value
}

/**
 *  The value of the len field is the number of bytes in the string. The value
 *  array holds the actual bytes that make up the string.
 *
 *  NB: the len field does not necessarily indicate the length of the string.
 */
struct UTF8
{
    ubyte tag;                  /// tag
    size_t len;                 /// length
    immutable ubyte[] value;    /// value
}

/**
 * Represents the name and descriptor of a field or method. The nameIndex and descriptorIndex 
 * must be a valid constant pool indices that points to a UTF8 constants. This UTF8 constant 
 * holds the actual bytes that make up the name and descriptor of a field or method. 
 */
struct NameAndType
{
    ubyte tag;                  /// tag
    size_t nameIndex;           /// name index
    size_t descriptorIndex;     /// descriptor index
}

/**
 * Represents a 4-byte (32-bit) signed integer value. 
 * It has a tag value of 3.
 */
struct Integer
{
    ubyte tag;  /// tag
    int value;  /// value
}

/**
 * Represents a reference to an Interface method as indicated by a tag value of 11.
 * The classIndex field points to the class or interface (in the constant pool) for
 * which this method belongs. The nameTypeIndex refers to the constant holding the
 * name and descriptor of the interface method.
 */
struct InterfaceMethod
{
    ubyte tag;              /// tag
    size_t classIndex;      /// class index
    size_t nameTypeIndex;   /// name type index
}
