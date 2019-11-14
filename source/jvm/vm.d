import std.stdio;
import std.container.array : Array;

import memory : Shared, PerThread, StackFrame;
import class_loader.class_file : ClassFile;
import constants : UTF8, Method;
import attributes : ATTR_INFO, Code, get_attribute;
import instructions : Opcode;
import utils : bigEndian16from;

/// 
struct JVM
{
    /// name of the class that contains the main method.
    string mainClass;

    /// an instance of shared memory regions.
    Shared sharedMemory;

    /// an instance of the memory areas for each thread.
    PerThread perThread;

    /** 
     * Constructor for creating and instance of a JVM.
     *
     * Params:
     *   cf = class file object created from parsing a .class file
     *   mainClass = The name of the class that contains the main method.
     */
    this(ClassFile cf, string mainClass)
    {
        this.mainClass = mainClass;
        this.sharedMemory = Shared([mainClass: cf]);
        this.perThread = newPerThread();
    }

    /** 
     * creates and returns a new object that holds the instruction pointer,
        stack pointer and stack frame.

     * Returns: a new instance of PerThread that has the IP, SP and stack frame
                 initialized to zero their respective default values.
     */
    static PerThread newPerThread()
    {
        Array!StackFrame frame;
        return PerThread(0, 0, frame);
    }

    ///
    void start()
    {
        auto mainClassFile = this.sharedMemory.method_area[this.mainClass];

        // Call Main's constructor
        foreach (mthd; mainClassFile.methodInfo)
        {
            const name = *mainClassFile.constantPool[mthd.nameIndex].peek!(UTF8);
            const descrptor = *mainClassFile.constantPool[mthd.descriptorIndex].peek!(UTF8);

            bool isMainConstructor = mthd.accessFlags == 0x01
                && name.value == cast(ubyte[]) "<init>" && descrptor.value == cast(ubyte[]) "()V";

            if (isMainConstructor)
            {
                foreach (attribute; mthd.attributes)
                {
                    auto c = get_attribute(attribute);
                    auto frame = StackFrame(c.maxLocals, c.maxStack, c.code,
                            mainClassFile.constantPool);

                    this.perThread.javaStack ~= frame;
                    execute();
                }
            }
        }
    }

    ///
    void execute()
    {
        auto curStackFrame = this.perThread.javaStack.back;
        //writeln(curStackFrame);

        while (this.perThread.pc < curStackFrame.code.length)
        {
            immutable opcode = curStackFrame.code[this.perThread.pc];
            final switch (opcode)
            {
            case Opcode.aload_0:
                writeln("executing: aload_0");
                //curStackFrame.operandStack ~= curStackFrame.locals[0];

                this.perThread.pc += 1;
                break;

            case Opcode.invokespecial:
                writeln("executing: invokespecial");
                //immutable i = this.perThread.pc;
                //immutable index = bigEndian16from(curStackFrame.code[i+1 .. i+3]);
                //
                //auto entry = curStackFrame.constPool[index];
                //
                //immutable method = *entry.peek!(Method);

                this.perThread.pc += 3;
                break;

            case Opcode.riturn:
                writeln("executing: return");
                //this.perThread.javaStack.removeBack();

                this.perThread.pc += 1;
                break;
            }
        }

    }
}
