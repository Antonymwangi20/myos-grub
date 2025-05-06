section .multiboot
; ... (keep your existing multiboot header) ...

bits 64
section .text
global _start
extern kmain

_start:
    ; 1. Set up stack with guard page
    mov rsp, stack_top - 4096
    
    ; 2. Verify Multiboot info pointer
    test rbx, rbx
    jz .no_mb_info
    
    ; 3. Call kernel with verified pointers
    mov rdi, 0x36d76289  ; Expected magic value
    mov rsi, rbx         ; mb_info
    call kmain
    
.no_mb_info:
    ; Fallback: display error pattern
    mov edi, 0xB8000
    mov word [edi], 0x4F45 ; Red 'E'
    mov word [edi+2], 0x4F52 ; Red 'R'
    mov word [edi+4], 0x4F52 ; Red 'R'
    cli
    hlt

section .bss
align 4096
stack_bottom:
    resb 65536  ; 64KB stack with guard page
stack_top: