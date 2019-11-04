import std.stdio;

import memory: Shared, PerThread;
import class_loader.class_file: ClassFile;


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

    static PerThread newPerThread() {
        return PerThread(0, 0);
    }

    void start()
    {
        auto mainClassFile = this.sharedMemory.method_area[this.mainClass];
        writeln(mainClassFile.m_info);
    }
}