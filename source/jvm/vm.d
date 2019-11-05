import std.stdio;

import memory : Shared, PerThread, StackFrame;
import class_loader.class_file : ClassFile;
import constants : UTF8;
import attributes : ATTR_INFO, Code, get_attribute;
import instructions: Opcode;

struct JVM
{
    string mainClass;
    Shared sharedMemory;
    PerThread perThread;

    this(ClassFile cf, string mainClass)
    {
        this.mainClass = mainClass;
        this.sharedMemory = Shared([mainClass: cf]);
        this.perThread = newPerThread();
    }

    static PerThread newPerThread()
    {
        StackFrame[] frame;
        return PerThread(0, 0, frame);
    }

    void start()
    {
        auto mainClassFile = this.sharedMemory.method_area[this.mainClass];

        // Call Main's constructor
        foreach (mthd; mainClassFile.m_info)
        {
            const name = *mainClassFile.constant_pool[mthd.name_index].peek!(UTF8);
            const descrptor = *mainClassFile.constant_pool[mthd.descriptor_index].peek!(UTF8);

            bool isMainConstructor = mthd.access_flags == 0x01 &&
                                     name.value == cast(ubyte[]) "<init>" &&
                                     descrptor.value == cast(ubyte[]) "()V";

            if (isMainConstructor)
            {
                foreach (attribute; mthd.attributes)
                {
                    auto c = get_attribute(attribute);
                    auto frame = StackFrame(c.max_locals, c.max_stack, c.code);

                    this.perThread.javaStack ~= frame;
                    execute();
                }
            }
        }
    }

    void execute()
    {
        const curStack = this.perThread.javaStack[0];
        writeln(curStack);

        while(this.perThread.pc < curStack.code.length)
        {
            immutable opcode = curStack.code[this.perThread.pc];
            final switch(opcode)
            {
                case Opcode.aload_0:
                    writeln("executing: aload_0");
                    this.perThread.pc += 1;
                    break;
                case Opcode.invokespecial:
                    writeln("executing: invokespecial");
                    this.perThread.pc += 3;
                    break;
                case Opcode.riturn:
                    writeln("executing: return");
                    this.perThread.pc += 1;
                    break;
            }
        }

    }
}