format ELF64

section '.text' executable

public _start

extrn printf
extrn puts
extrn _exit

extrn InitWindow
extrn SetTargetFPS
extrn WindowShouldClose
extrn BeginDrawing
extrn ClearBackground
extrn DrawRectangle
extrn EndDrawing
extrn CloseWindow

_start:
	;void InitWindow(int width, int height, const char *title);  // Initialize window and OpenGL context
    mov rdi, 800
    mov rsi, 450
    mov rdx, windowTitle
    call InitWindow

	;void SetTargetFPS(int fps);                                 // Set target FPS (maximum)
    mov rdi, 60
    call SetTargetFPS

.mainGameLoopStart:
	;bool WindowShouldClose(void);                               // Check if application should close (KEY_ESCAPE pressed or windows close icon clicked)
	call WindowShouldClose
	test eax, eax
	jne .mainGameLoopEnd

	;void BeginDrawing(void);                                    // Setup canvas (framebuffer) to start drawing
	call BeginDrawing

	;void ClearBackground(Color color);                          // Set background color (framebuffer clear color)
	mov rdi, [pico.2]
	call ClearBackground

	;void DrawRectangleLines(int posX, int posY, int width, int height, Color color);                   // Draw rectangle outline
	mov rdi, 10
	mov rsi, 30
	mov rdx, 20
	mov rcx, 120
	mov r8, [pico.7]
	call DrawRectangle
    
	;void EndDrawing(void);                                      // End canvas drawing and swap buffers (double buffering)
	call EndDrawing

	jmp .mainGameLoopStart
.mainGameLoopEnd:
	
;.loop:
;	jmp .loop

	call CloseWindow
	mov rdi, 0
	call _exit

section '.data' writeable



section '.rodata'
windowTitle: db "Ping Ping FASM",0
	; pico-8 color palet https://lospec.com/palette-list/pico-8
	; adjusted for big-endian (a, b, g, r)
pico:
	.1:  dd 0xFF000000
	.2:  dd 0xFF532B1D
	.3:  dd 0xFF53257E
	.4:  dd 0xFF518700
	.5:  dd 0xFF3652AB
	.6:  dd 0xFF4F575F
	.7:  dd 0xFFC7C3C2
	.8:  dd 0xFFE8F1FF
	.9:  dd 0xFF4D00FF
	.10: dd 0xFF00A3FF
	.11: dd 0xFF27ECFF
	.12: dd 0xFF36E400
	.13: dd 0xFFFFAD29
	.14: dd 0xFF9C7683
	.15: dd 0xFFA877FF
	.16: dd 0xFFAACCFF

section '.note.GNU-stack'
