# DemensDeum-Coding-Challenge-1
## Building
The following tools are required:
- [NASM](https://www.nasm.us/pub/nasm/releasebuilds/2.16.03/win64/nasm-2.16.03-installer-x64.exe)
- [Go Linker](http://godevtool.com/Golink.zip) (add to PATH)

Execute the following commands:
```
nasm -f win64 challenge.asm -o challenge.obj
golink /entry:Start kernel32.dll user32.dll d3d11.dll d2d1.dll cabinet.dll shlwapi.dll ole32.dll challenge.obj
```
