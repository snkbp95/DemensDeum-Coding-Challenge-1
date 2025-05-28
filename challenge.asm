bits 64

NULL                              EQU 0
CW_USEDEFAULT                     EQU 0x80000000
WS_OVERLAPPEDWINDOW               EQU 0x00cf0000
WM_DESTROY                        EQU 2
WM_PAINT                          EQU 15
SW_SHOWNORMAL                     EQU 1
Width                             EQU 1920
Height                            EQU 1080
D3D_DRIVER_TYPE_HARDWARE          EQU 1
D3D11_CREATE_DEVICE_BGRA_SUPPORT  EQU 32
D3D11_SDK_VERSION                 EQU 7
DXGI_FORMAT_B8G8R8A8_UNORM        EQU 87
DXGI_USAGE_RENDER_TARGET_OUTPUT   EQU 0x00000020
DXGI_SCALING_NONE                 EQU 1
DXGI_SWAP_EFFECT_FLIP_SEQUENTIAL  EQU 3
DXGI_ALPHA_MODE_IGNORE            EQU 3
D2D1_FACTORY_TYPE_SINGLE_THREADED EQU 0
D2D1_DEVICE_CONTEXT_OPTIONS_NONE  EQU 0
D2D1_ALPHA_MODE_PREMULTIPLIED     EQU 1
D2D1_BITMAP_OPTIONS_TARGET        EQU 1
D2D1_BITMAP_OPTIONS_CANNOT_DRAW   EQU 2
COMPRESS_ALGORITHM_LZMS           EQU 5
DECOMPRESSED_BUFFER_SIZE          EQU 1*1024*1024
MEM_COMMIT                        EQU 0x00001000
PAGE_READWRITE                    EQU 0x00000004
DEMENS_LOGO_SIZE                  EQU demens_logo_end - demens_logo_start
F1920                             EQU 0x44f00000
F1080                             EQU 0x44870000
SYNC_INTERVAL                     EQU 1
PRESENT_FLAGS                     EQU 0

extern GetModuleHandleA
extern RegisterClassA
extern CreateWindowExA
extern ShowWindow
extern TranslateMessage
extern DispatchMessageA
extern DefWindowProcA
extern PostQuitMessage
extern GetMessageA
extern BeginPaint
extern EndPaint
extern ExitProcess
extern D3D11CreateDevice
extern D2D1CreateFactory
extern VirtualAlloc
extern CreateDecompressor
extern Decompress
extern SHCreateMemStream

global Start

section .data
guid_IDXGIDevice:
    dd 0x54ec77fa
    dw 0x1377, 0x44e6
    db 0x8c, 0x32, 0x88, 0xfd, 0x5f, 0x44, 0xc8, 0x4c
guid_IDXGIFactory2:
    dd 0x50c83a1c
    dw 0xe072, 0x4c48
    db 0x87, 0xb0, 0x36, 0x30, 0xfa, 0x36, 0xa6, 0xd0
guid_ID2D1Factory5:
    dd 0xc4349994
    dw 0x838e, 0x4b0f
    db 0x8c, 0xab, 0x44, 0x99, 0x7d, 0x9e, 0xea, 0xcc
guid_ID2D1Device5:
    dd 0xd55ba0a4
    dw 0x6405, 0x4694
    db 0xae, 0xf5, 0x08, 0xee, 0x1a, 0x43, 0x58, 0xb4
guid_IDXGISurface:
    dd 0xcafcb56c
    dw 0x6ac3, 0x4889
    db 0xbf, 0x47, 0x9e, 0x23, 0xbb, 0xd2, 0x60, 0xec
    ClassName  db "Window", 0
    WindowName db "Demens Challenge", 0
demens_logo_start:
    incbin "demens_logo"
demens_logo_end:
    align 16

section .bss
    hInstance             resq 1
    pID3D11Device         resq 1
    pID3D11DeviceContext  resq 1
    pIDXGIDevice          resq 1
    pIDXGIAdapter         resq 1
    pIDXGIFactory2        resq 1
    pIDXGISwapChain1      resq 1
    pID2D1Factory5        resq 1
    pID2D1Device          resq 1
    pID2D1Device5         resq 1
    pID2D1DeviceContext5  resq 1
    pIDXGISurface         resq 1
    pD2DTargetBitmap      resq 1
    pDecompressor         resq 1
    pDecompressedBuffer   resq 1
    pDecompressedDataSize resq 1
    pIStream              resq 1
    pSvgDoc               resq 1

section .text
Start:
    sub rsp, 8 + 32 ; align + shadow space
    xor ecx, ecx
    call GetModuleHandleA
    mov qword [REL hInstance], rax
    add rsp, 32
    call WinMain

.Exit:
    xor ecx, ecx
    call ExitProcess

WinMain:
    push rbp
    mov rbp, rsp
    sub rsp, 216 + 8 + 32; structures + align + shadow space

%define hWnd                                   rbp - 8 ; 8 bytes.
                      
%define wc                                     rbp - 80 ; WNDCLASSA structure, 72 bytes
%define wc.style                               rbp - 80 ; 4 bytes.
%define wc.padding1                            rbp - 76 ; 4 bytes.
%define wc.lpfnWndProc                         rbp - 72 ; 8 bytes.
%define wc.cbClsExtra                          rbp - 64 ; 4 bytes.
%define wc.cbWndExtra                          rbp - 60 ; 4 bytes.
%define wc.hInstance                           rbp - 56 ; 8 bytes.
%define wc.hIcon                               rbp - 48 ; 8 bytes.
%define wc.hCursor                             rbp - 40 ; 8 bytes.
%define wc.hbrBackground                       rbp - 32 ; 8 bytes.
%define wc.lpszMenuName                        rbp - 24 ; 8 bytes.
%define wc.lpszClassName                       rbp - 16 ; 8 bytes.
                      
%define msg                                    rbp - 128 ; MSG structure, 48 bytes
%define msg.hwnd                               rbp - 128 ; 8 bytes
%define msg.message                            rbp - 120 ; 4 bytes
%define msg.padding1                           rbp - 116 ; 4 bytes
%define msg.wParam                             rbp - 112 ; 8 bytes
%define msg.lParam                             rbp - 104 ; 8 bytes
%define msg.time                               rbp - 96  ; 4 bytes
%define msg.pt.x                               rbp - 92  ; 4 bytes
%define msg.pt.y                               rbp - 88  ; 4 bytes
%define msg.padding2                           rbp - 84  ; 4 bytes

%define swapChainDesc                          rbp - 176 ; DXGI_SWAP_CHAIN_DESC1 structure, 48 bytes
%define swapChainDesc.Width                    rbp - 176 ; 4 bytes
%define swapChainDesc.Height                   rbp - 172 ; 4 bytes
%define swapChainDesc.Format                   rbp - 168 ; 4 bytes
%define swapChainDesc.Stereo                   rbp - 164 ; 4 bytes
%define swapChainDesc.SampleDesc.Count         rbp - 160 ; 4 bytes
%define swapChainDesc.SampleDesc.Quality       rbp - 156 ; 4 bytes
%define swapChainDesc.BufferUsage              rbp - 152 ; 4 bytes
%define swapChainDesc.BufferCount              rbp - 148 ; 4 bytes
%define swapChainDesc.Scaling                  rbp - 144 ; 4 bytes
%define swapChainDesc.SwapEffect               rbp - 140 ; 4 bytes
%define swapChainDesc.AlphaMode                rbp - 136 ; 4 bytes
%define swapChainDesc.Flags                    rbp - 132 ; 4 bytes

%define bitmapProperties                       rbp - 208 ; D2D1_BITMAP_PROPERTIES1 structure, 32 bytes
%define bitmapProperties.pixelFormat.format    rbp - 208 ; 4 bytes
%define bitmapProperties.pixelFormat.alphaMode rbp - 204 ; 4 bytes
%define bitmapProperties.dpiX                  rbp - 200 ; 4 bytes
%define bitmapProperties.dpiY                  rbp - 196 ; 4 bytes
%define bitmapProperties.bitmapOptions         rbp - 192 ; 4 bytes
%define bitmapProperties.padding1              rbp - 188 ; 4 bytes
%define bitmapProperties.colorContext          rbp - 184 ; 8 bytes

%define d2dSizeF                               rbp - 216 ; D2D_SIZE_F structure, 8 bytes
%define d2dSizeF.width                         rbp - 216 ; 4 bytes
%define d2dSizeF.height                        rbp - 212 ; 4 bytes

    xor rax, rax
    mov rdi, rsp
    mov ecx, 28
    rep stosq ; zeroing stack memory

    lea rax, [REL WndProc]
    mov qword [wc.lpfnWndProc], rax
    mov rax, qword [REL hInstance]
    mov qword [wc.hInstance], rax
    lea rax, [REL ClassName]
    mov qword [wc.lpszClassName], rax

    mov dword [swapChainDesc.Width], Width
    mov dword [swapChainDesc.Height], Height
    mov dword [swapChainDesc.Format], DXGI_FORMAT_B8G8R8A8_UNORM
    mov dword [swapChainDesc.SampleDesc.Count], 1
    mov dword [swapChainDesc.BufferUsage], DXGI_USAGE_RENDER_TARGET_OUTPUT
    mov dword [swapChainDesc.BufferCount], 2
    mov dword [swapChainDesc.Scaling], DXGI_SCALING_NONE
    mov dword [swapChainDesc.SwapEffect], DXGI_SWAP_EFFECT_FLIP_SEQUENTIAL
    mov dword [swapChainDesc.AlphaMode], DXGI_ALPHA_MODE_IGNORE

    mov dword [bitmapProperties.pixelFormat.format], DXGI_FORMAT_B8G8R8A8_UNORM
    mov dword [bitmapProperties.pixelFormat.alphaMode], D2D1_ALPHA_MODE_PREMULTIPLIED
    mov dword [bitmapProperties.bitmapOptions], D2D1_BITMAP_OPTIONS_TARGET | D2D1_BITMAP_OPTIONS_CANNOT_DRAW
    mov qword [bitmapProperties.colorContext], NULL

    mov dword [d2dSizeF.width], F1920
    mov dword [d2dSizeF.height], F1080

    lea rcx, [wc]
    call RegisterClassA ; RegisterClassA(&wc)

    sub rsp, 64 ; 8 parameters
    xor ecx, ecx
    lea rdx, [REL ClassName]
    lea r8, [REL WindowName]
    mov r9d, WS_OVERLAPPEDWINDOW
    mov dword [rsp + 4 * 8], CW_USEDEFAULT
    mov dword [rsp + 5 * 8], CW_USEDEFAULT
    mov dword [rsp + 6 * 8], Width
    mov dword [rsp + 7 * 8], Height
    mov qword [rsp + 8 * 8], NULL
    mov qword [rsp + 9 * 8], NULL
    mov rax, qword [REL hInstance]
    mov qword [rsp + 10 * 8], rax
    mov qword [rsp + 11 * 8], NULL
    call CreateWindowExA ; CreateWindowExA(0, ClassName, WindowName, WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, CW_USEDEFAULT, Width, Height, NULL, NULL, hInstance, NULL)
    mov qword [hWnd], rax
    add rsp, 64 ; restore rsp

    sub rsp, 48 ; 6 parameters
    xor ecx, ecx
    mov edx, D3D_DRIVER_TYPE_HARDWARE
    xor r8d, r8d
    mov r9d, D3D11_CREATE_DEVICE_BGRA_SUPPORT
    mov qword [rsp + 4 * 8], NULL
    mov dword [rsp + 5 * 8], 0
    mov dword [rsp + 6 * 8], D3D11_SDK_VERSION
    lea rax, [REL pID3D11Device]
    mov qword [rsp + 7 * 8], rax
    mov qword [rsp + 8 * 8], NULL
    lea rax, [REL pID3D11DeviceContext]
    mov qword [rsp + 9 * 8], rax
    call D3D11CreateDevice ; D3D11CreateDevice(NULL, D3D_DRIVER_TYPE_HARDWARE, NULL, D3D11_CREATE_DEVICE_BGRA_SUPPORT, NULL, 0, D3D11_SDK_VERSION, &pID3D11Device, NULL, &pID3D11DeviceContext)
    add rsp, 48 ; restore rsp

    mov rcx, qword [REL pID3D11Device]
    mov rax, qword [rcx]
    lea rdx, [REL guid_IDXGIDevice]
    lea r8, [REL pIDXGIDevice]
    call [rax + 0 * 8] ; ID3D11Device_lpVtbl_QueryInterface(pID3D11Device, &guid_IDXGIDevice, &pIDXGIDevice)

    mov rcx, qword [REL pIDXGIDevice]
    mov rax, qword [rcx]
    lea rdx, [REL pIDXGIAdapter]
    call [rax + 7 * 8] ; IDXGIDevice_lpVtbl_GetAdapter(pIDXGIDevice, &pIDXGIAdapter)

    mov rcx, qword [REL pIDXGIAdapter]
    mov rax, qword [rcx]
    lea rdx, [REL guid_IDXGIFactory2]
    lea r8, [REL pIDXGIFactory2]
    call [rax + 6 * 8] ; IDXGIAdapter_lpVtbl_GetParent(pIDXGIAdapter, &guid_IDXGIFactory2, &pIDXGIFactory2)

    sub rsp, 24 + 8 ; 3 parameters + align
    mov qword [rsp + 4 * 8], NULL
    mov qword [rsp + 5 * 8], NULL
    lea rax, [REL pIDXGISwapChain1]
    mov qword [rsp + 6 * 8], rax
    mov rcx, qword [REL pIDXGIFactory2]
    mov rax, qword [rcx]
    mov rdx, qword [REL pID3D11Device]
    mov r8, qword [hWnd]
    lea r9, [swapChainDesc]
    call [rax + 15 * 8] ; IDXGIFactory2_lpVtbl_CreateSwapChainForHwnd(pIDXGIFactory2, pID3D11Device, hWnd, &swapChainDesc, NULL, NULL, &pIDXGISwapChain1)
    add rsp, 32 ; restore rsp

    mov ecx, D2D1_FACTORY_TYPE_SINGLE_THREADED
    lea rdx, [REL guid_ID2D1Factory5]
    mov r8, NULL
    lea r9, [REL pID2D1Factory5]
    call D2D1CreateFactory ; D2D1CreateFactory(D2D1_FACTORY_TYPE_SINGLE_THREADED, &guid_ID2D1Factory5, NULL, &pID2D1Factory5)

    mov rcx, qword [REL pID2D1Factory5]
    mov rax, qword [rcx]
    mov rdx, qword [REL pIDXGIDevice]
    lea r8, [REL pID2D1Device]
    call [rax + 17 * 8] ; ID2D1Factory5_lpVtbl_CreateDevice(pID2D1Factory5, pIDXGIDevice, &pID2D1Device)

    mov rcx, qword [REL pID2D1Device]
    mov rax, qword [rcx]
    lea rdx, [REL guid_ID2D1Device5]
    lea r8, [REL pID2D1Device5]
    call [rax + 0 * 8] ; ID2D1Device_lpVtbl_QueryInterface(pID2D1Device, &guid_ID2D1Device5, &pID2D1Device5)

    mov rcx, qword [REL pID2D1Device5]
    mov rax, qword [rcx]
    mov edx, D2D1_DEVICE_CONTEXT_OPTIONS_NONE
    lea r8, [REL pID2D1DeviceContext5]
    call [rax + 19 * 8] ; ID2D1Device5_lpVtbl_CreateDeviceContext(pID2D1Device5, D2D1_DEVICE_CONTEXT_OPTIONS_NONE, &pID2D1DeviceContext5)

    mov rcx, qword [REL pIDXGISwapChain1]
    mov rax, qword [rcx]
    xor edx, edx
    lea r8, [REL guid_IDXGISurface]
    lea r9, [REL pIDXGISurface]
    call [rax + 9 * 8] ; IDXGISwapChain1_lpVtbl_GetBuffer(pIDXGISwapChain1, 0, &guid_IDXGISurface, &pIDXGISurface)

    mov rcx, qword [REL pID2D1Factory5]
    mov rax, [rcx]
    lea rdx, [bitmapProperties.dpiX]
    lea r8, [bitmapProperties.dpiY]
    call [rax + 4 * 8] ; ID2D1Factory5_lpVtbl_GetDesktopDpi(pID2D1Factory5, &bitmapProperties.dpiX, &bitmapProperties.dpiY);

    mov rcx, qword [REL pID2D1DeviceContext5]
    mov rax, [rcx]
    mov rdx, [REL pIDXGISurface]
    lea r8, [bitmapProperties]
    lea r9, [REL pD2DTargetBitmap]
    call [rax + 62 * 8] ; ID2D1DeviceContext5_lpVtbl_CreateBitmapFromDxgiSurface(pID2D1DeviceContext5, pIDXGISurface, &bitmapProperties, &pD2DTargetBitmap)

    mov rcx, qword [REL pID2D1DeviceContext5]
    mov rax, qword [rcx]
    mov rdx, qword [REL pD2DTargetBitmap]
    call [rax + 74 * 8] ; ID2D1DeviceContext5_lpVtbl_SetTarget(pID2D1DeviceContext5, pD2DTargetBitmap)

    mov ecx, COMPRESS_ALGORITHM_LZMS
    mov rdx, NULL
    lea r8, [REL pDecompressor]
    call CreateDecompressor ; CreateDecompressor(COMPRESS_ALGORITHM_LZMS, NULL, &pDecompressor)

    mov rcx, NULL
    mov edx, DECOMPRESSED_BUFFER_SIZE
    mov r8d, MEM_COMMIT
    mov r9d, PAGE_READWRITE
    call VirtualAlloc ; VirtualAlloc(NULL, DECOMPRESSED_BUFFER_SIZE, MEM_COMMIT, PAGE_READWRITE);
    mov qword [REL pDecompressedBuffer], rax

    sub rsp, 16 ; 2 parameters
    mov rcx, qword [REL pDecompressor]
    mov rdx, demens_logo_start
    mov r8, DEMENS_LOGO_SIZE
    mov r9, qword [REL pDecompressedBuffer]
    mov qword [rsp + 4 * 8], DECOMPRESSED_BUFFER_SIZE
    lea rax, [REL pDecompressedDataSize]
    mov qword [rsp + 5 * 8], rax
    call Decompress ; Decompress(pDecompressor, demens_logo_start, DEMENS_LOGO_SIZE, pDecompressedBuffer, DECOMPRESSED_BUFFER_SIZE, &pDecompressedDataSize);
    add rsp, 16 ; restore rsp

    mov rcx, qword [REL pDecompressedBuffer]
    mov rdx, qword [REL pDecompressedDataSize]
    call SHCreateMemStream ; SHCreateMemStream(pDecompressedBuffer, pDecompressedDataSize)
    mov qword [REL pIStream], rax

    mov rcx, qword [REL pID2D1DeviceContext5]
    mov rax, [rcx]
    mov rdx, qword [REL pIStream]
    mov r8, qword [d2dSizeF]
    lea r9, [REL pSvgDoc]
    call [rax + 115 * 8] ; ID2D1DeviceContext5_Vtbl_CreateSvgDocument(pID2D1DeviceContext5, pIStream, d2dSizeF, &pSvgDoc)

    mov rcx, qword [hWnd]
    mov edx, SW_SHOWNORMAL
    call ShowWindow ; ShowWindow(hWnd, nShowCmd);

.MessageLoop:
    sub rsp, 32 ; shadow space
    lea rcx, [msg]
    xor edx, edx
    xor r8d, r8d
    xor r9d, r9d
    call GetMessageA ; GetMessageA(&msg, NULL, 0, 0)
    add rsp, 32 ; restore rsp
    cmp rax, 0
    je .Done

    sub rsp, 32 ; shadow space
    lea rcx, [msg]
    call TranslateMessage ; TranslateMessage(&msg)

    lea rcx, [msg]
    call DispatchMessageA ; DispatchMessageA(&msg)
    add rsp, 32 ; restore rsp
    jmp .MessageLoop

.Done:
    mov rsp, rbp
    pop rbp
    xor eax, eax
    ret

WndProc:
    push rbp
    mov rbp, rsp

%define hWnd   rbp + 16 ; shadow space
%define uMsg   rbp + 24
%define wParam rbp + 32
%define lParam rbp + 40

    mov qword [hWnd], rcx
    mov qword [uMsg], rdx
    mov qword [wParam], r8
    mov qword [lParam], r9
    cmp qword [uMsg], WM_DESTROY
    je WM_DESTROY
    cmp qword [uMsg], WM_PAINT
    je WMPAINT

DefaultMessage:
    sub rsp, 32 ; shadow space
    mov rcx, qword [hWnd]
    mov rdx, qword [uMsg]
    mov r8, qword [wParam]
    mov r9, qword [lParam]
    call DefWindowProcA ; DefWindowProcA(hWnd, uMsg, wParam, lParam)
    add rsp, 32 ; restore rsp
    mov rsp, rbp
    pop rbp
    ret

WMPAINT:
    sub rsp, 68 + 12 + 32; structure + align + shadow space

%define ps rbp - 80; PAINTSTRUCT structure, 68 bytes

    xor rax, rax
    mov rdi, rsp
    mov ecx, 10
    rep stosq ; zeroing ps memory

    mov rcx, qword [hWnd]
    lea rdx, [ps]
    call BeginPaint ; BeginPaint(hWnd, &ps)

    mov rcx, qword [REL pID2D1DeviceContext5]
    mov rax, qword [rcx]
    call [rax + 48 * 8] ; ID2D1DeviceContext5_Vtbl_BeginDraw(pID2D1DeviceContext5)
    
    mov rcx, qword [REL pID2D1DeviceContext5]
    mov rax, qword [rcx]
    mov rdx, qword [REL pSvgDoc]
    call [rax + 116 * 8] ; ID2D1DeviceContext5_Vtbl_DrawSvgDocument(pID2D1DeviceContext5, pSvgDoc)

    mov rcx, qword [REL pID2D1DeviceContext5]
    mov rax, qword [rcx]
    mov rdx, NULL
    mov r8, NULL
    call [rax + 49 * 8] ; ID2D1DeviceContext5_Vtbl_EndDraw(pID2D1DeviceContext5, NULL, NULL)
    
    mov rcx, qword [REL pIDXGISwapChain1]
    mov rax, qword [rcx]
    mov edx, SYNC_INTERVAL
    mov r8d, PRESENT_FLAGS
    call [rax + 8 * 8] ; IDXGISwapChain1_Vtbl_Present(pIDXGISwapChain1, SYNC_INTERVAL, PRESENT_FLAGS)

    mov rcx, qword [hWnd]
    lea rdx, [ps]
    call EndPaint ; EndPaint(hWnd, &ps)
    add rsp, 32 ; restore rsp

    jmp DefaultMessage

WMDESTROY:
    sub rsp, 32 ; shadow space
    xor ecx, ecx
    call PostQuitMessage ; PostQuitMessage(0)
    add rsp, 32 ; restore rsp
    xor eax, eax
    mov rsp, rbp
    pop rbp
    ret