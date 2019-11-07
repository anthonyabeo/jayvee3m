import std.stdio;
import std.container.array : Array;

import memory : Shared, PerThread, StackFrame;
import class_loader.class_file : ClassFile;
import constants : UTF8, Method;
import attributes : ATTR_INFO, Code, get_attribute;
import instructions : Opcode;
import utils : bigEndian16from;

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
        Array!StackFrame frame;
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

            bool isMainConstructor = mthd.access_flags == 0x01
                && name.value == cast(ubyte[]) "<init>" && descrptor.value == cast(ubyte[]) "()V";

            if (isMainConstructor)
            {
                foreach (attribute; mthd.attributes)
                {
                    auto c = get_attribute(attribute);
                    auto frame = StackFrame(c.max_locals, c.max_stack, c.code,
                            mainClassFile.constant_pool);

                    this.perThread.javaStack ~= frame;
                    execute();
                }
            }
        }
    }

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
