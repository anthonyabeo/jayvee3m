import class_loader.class_file : ClassFile;

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
    // java stack
}
