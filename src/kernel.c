#define VGA_BASE 0xB8000
#define VGA_WIDTH 80
#define VGA_HEIGHT 25

// Memory-safe I/O functions
static inline uint8_t inb(uint16_t port) {
    uint8_t ret;
    asm volatile("inb %1, %0" : "=a"(ret) : "Nd"(port));
    return ret;
}

static inline void outb(uint16_t port, uint8_t val) {
    asm volatile("outb %0, %1" : : "a"(val), "Nd"(port));
}

// Memory-safe VGA writing
void vga_write(uint16_t *vga, int x, int y, uint16_t entry) {
    if (x >= 0 && x < VGA_WIDTH && y >= 0 && y < VGA_HEIGHT) {
        vga[y * VGA_WIDTH + x] = entry;
    }
}

void kmain(unsigned long magic, unsigned long *mb_info) {
    volatile uint16_t *vga = (volatile uint16_t*)VGA_BASE;
    
    // 1. Initialize VGA controller
    outb(0x3D4, 0x0A); outb(0x3D5, 0x20); // Disable cursor
    
    // 2. Clear screen safely
    for (int y = 0; y < VGA_HEIGHT; y++) {
        for (int x = 0; x < VGA_WIDTH; x++) {
            vga_write(vga, x, y, 0x0F00 | ' ');
        }
    }
    
    // 3. Write test pattern safely
    vga_write(vga, 0, 0, 0x1F41); // White 'A' on blue
    vga_write(vga, 1, 0, 0x1F42); // White 'B' on blue
    vga_write(vga, 2, 0, 0x1F43); // White 'C' on blue
    
    // 4. Proper halt with memory synchronization
    asm volatile("cli; hlt; wbinvd");
}