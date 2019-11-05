import std.typecons : Tuple;

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
    StackFrame[] javaStack;
}

struct StackFrame
{
    // local variables array
    int[] locals;

    // operand stack
    int[] operandStack;

    // reference to the current constant pool
    //CP_INFO[] constPool;

    // exception table
    //Tuple!(size_t, size_t, size_t, size_t) exceptionTable;

    // instructions
    const(ubyte[]) code;

    @safe pure nothrow
    this(size_t locals_size, size_t stack_size, const(ubyte[]) code)
    {
        this.locals = new int[locals_size];
        this.operandStack = new int[stack_size];
        //this.constPool = pool;
        //this.exceptionTable = excp_table;
        this.code = code;
    }
    
}
