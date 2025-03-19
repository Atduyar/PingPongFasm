format ELF64

section '.text' executable

public _start

extrn printf
extrn puts
extrn _exit

extrn InitWindow
extrn SetConfigFlags
extrn GetScreenWidth
extrn GetScreenHeight
extrn SetTargetFPS
extrn WindowShouldClose
extrn BeginDrawing
extrn ClearBackground
extrn DrawRectangle
extrn EndDrawing
extrn CloseWindow

_start:

	;void SetConfigFlags(unsigned int flags);                    // Setup init configuration flags (view FLAGS)
	mov rdi, 0
	;or rdi, [raylibConfigFlags.FLAG_FULLSCREEN_MODE]
	or rdi, [raylibConfigFlags.FLAG_WINDOW_RESIZABLE]
	call SetConfigFlags

	;void InitWindow(int width, int height, const char *title);  // Initialize window and OpenGL context
    mov rdi, [windowSize.width]
    mov rsi, [windowSize.height]
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

	;int GetScreenWidth(void);                                   // Get current screen width
	call GetScreenWidth
	mov [windowSize.width], eax
	;int GetScreenHeight(void);                                  // Get current screen height
	call GetScreenHeight
	mov [windowSize.height], eax

	mov rdi, print_int
	mov rsi, [windowSize.height]
	call printf

	;void DrawRectangleLines(int posX, int posY, int width, int height, Color color);                   // Draw rectangle outline
	mov rdi, [pedal_l.x]
	mov rsi, [pedal_l.y]
	mov rdx, [pedal.width]
	mov rcx, [pedal.height]
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
windowSize:
	.width:  dd 800
	.height: dd 450
pedal:
	.width:  dd 20
	.height: dd 120
pedal_l:
	.x: dd 10
	.y: dd 30
pedal_r:
	.x: dd 10
	.y: dd 400

section '.rodata'
print_int: db "test: %d",10,0
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

raylibConfigFlags:
	.FLAG_VSYNC_HINT:               dd 0x00000040   ; Set to try enabling V-Sync on GPU
	.FLAG_FULLSCREEN_MODE:          dd 0x00000002   ; Set to run program in fullscreen
	.FLAG_WINDOW_RESIZABLE:         dd 0x00000004   ; Set to allow resizable window
	.FLAG_WINDOW_UNDECORATED:       dd 0x00000008   ; Set to disable window decoration (frame and buttons)
	.FLAG_WINDOW_HIDDEN:            dd 0x00000080   ; Set to hide window
	.FLAG_WINDOW_MINIMIZED:         dd 0x00000200   ; Set to minimize window (iconify)
	.FLAG_WINDOW_MAXIMIZED:         dd 0x00000400   ; Set to maximize window (expanded to monitor)
	.FLAG_WINDOW_UNFOCUSED:         dd 0x00000800   ; Set to window non focused
	.FLAG_WINDOW_TOPMOST:           dd 0x00001000   ; Set to window always on top
	.FLAG_WINDOW_ALWAYS_RUN:        dd 0x00000100   ; Set to allow windows running while minimized
	.FLAG_WINDOW_TRANSPARENT:       dd 0x00000010   ; Set to allow transparent framebuffer
	.FLAG_WINDOW_HIGHDPI:           dd 0x00002000   ; Set to support HighDPI
	.FLAG_WINDOW_MOUSE_PASSTHROUGH: dd 0x00004000   ; Set to support mouse passthrough, only supported when FLAG_WINDOW_UNDECORATED
	.FLAG_BORDERLESS_WINDOWED_MODE: dd 0x00008000   ; Set to run program in borderless windowed mode
	.FLAG_MSAA_4X_HINT:             dd 0x00000020   ; Set to try enabling MSAA 4X
	.FLAG_INTERLACED_HINT:          dd 0x00010000   ; Set to try enabling interlaced video format (for V3D)


section '.note.GNU-stack'
