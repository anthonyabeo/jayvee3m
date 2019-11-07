import std.typecons : Tuple;
import std.container.array : Array;

import class_loader.class_file : ClassFile;
import constants : CP_INFO;

struct Shared
{
    ClassFile[string] method_area;
    // heap
    // native stacks
}

struct PerThread
{
    size_t pc;
    size_t sp;
    Array!StackFrame javaStack;
}

struct StackFrame
{
    // local variables array
    Array!int locals;

    // operand stack
    Array!int operandStack;

    // reference to the current constant pool
    CP_INFO[] constPool;

    // exception table
    //Tuple!(size_t, size_t, size_t, size_t) exceptionTable;

    // instructions
    ubyte[] code;

    pure nothrow this(size_t locals_size, size_t stack_size, ubyte[] code, CP_INFO[] pool)
    {
        this.locals = Array!int();
        this.locals.reserve(locals_size);

        this.operandStack = Array!int();
        this.operandStack.reserve(stack_size);

        this.constPool = pool;
        //this.exceptionTable = excp_table;
        this.code = code;
    }

}
