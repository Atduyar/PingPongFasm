format ELF64

; Stdio
extrn printf
extrn puts
extrn _exit

; Raylib
extrn InitWindow
extrn SetConfigFlags
extrn GetScreenWidth
extrn GetScreenHeight
extrn SetTargetFPS
extrn WindowShouldClose
extrn BeginDrawing
extrn ClearBackground
extrn IsKeyPressed
extrn IsKeyDown
extrn DrawRectangle
extrn DrawCircle
extrn EndDrawing
extrn CloseWindow

section '.text' executable
public _start
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
	test al, al
	jne .mainGameLoopEnd

	;void BeginDrawing(void);                                    // Setup canvas (framebuffer) to start drawing
	call BeginDrawing

	;void ClearBackground(Color color);                          // Set background color (framebuffer clear color)
	mov rdi, [pico.2]
	call ClearBackground

	; Updates
	call UpdateWindowSize
	call HandlePedalLogic
	call HandleBallLogic

	; Draws
	call DrawPedal
	call DrawBall

	;void EndDrawing(void);                                      // End canvas drawing and swap buffers (double buffering)
	call EndDrawing

	jmp .mainGameLoopStart
	.mainGameLoopEnd:

	call CloseWindow
	mov rdi, 0
	call _exit

DrawPedal:
	;void DrawRectangleLines(int posX, int posY, int width, int height, Color color);                   // Draw rectangle outline
	mov rdi, [pedal_l.x]
	mov rsi, [pedal_l.y]
	mov rdx, [pedal.width]
	mov rcx, [pedal.height]
	mov r8, [pico.7]
	call DrawRectangle
	ret

DrawBall:
	; void DrawCircle(int centerX, int centerY, float radius, Color color); // Draws circle
	mov rdi, [ball.x]
	mov rsi, [ball.y]
	movd xmm0, [ball.r]
	mov rdx, [pico.8]
	call DrawCircle
	ret

HandlePedalLogic:
	;bool IsKeyPressed(int key);                             // Check if a key has been pressed once
	mov rdi, [ratlibKeyboardKey.KEY_DOWN]
	call IsKeyDown

	test al, al
	je .EndPressDown
	add qword[pedal_l.y], 5
	.EndPressDown:

	;bool IsKeyPressed(int key);                             // Check if a key has been pressed once
	mov rdi, [ratlibKeyboardKey.KEY_UP]
	call IsKeyDown

	test al, al
	je .EndPressUp
	sub qword[pedal_l.y], 5
	.EndPressUp:
	ret

HandleBallMovement:
	; This part handles moving on X axis (left/right)
	mov rsi, [ball.moveSpeed] ; We hold movement speed in rsi so we can reuse it later

	; Switched to using cl instead of al
	mov cl, [ball.moveX]
	test cl, cl ; Is cl == 0?
	jnz .updateBallPositionMoveLeft ; Not? Okay, move left
	;add qword[ball.x], rsi ; Yes? Okay, move right
	jmp .updateBallPositionMoveLeftEnd

	.updateBallPositionMoveLeft:
		;sub qword[ball.x], rsi
	.updateBallPositionMoveLeftEnd:

	; This part handles moving on Y axis (up/down)

	mov cl, [ball.moveY]
	test cl, cl ; Is cl == 0?
	jnz .updateBallPositionMoveUp ; Not? Okay, move up
	add qword[ball.y], rsi ; Yes? Okay, move down
	jmp .updateBallPositionMoveUpEnd

	.updateBallPositionMoveUp:
		sub qword[ball.y], rsi
	.updateBallPositionMoveUpEnd:
	ret

HandleBallLogic:
	call HandleBallMovement

	mov edx, [ball.y]
	sub edx, [ball.copyR] ; If I use ball.r instead of copyR, stuff breaks... I AM LOST

	cmp edx, 0 ; Is ball hitting the ceiling?
	jg .skipUpperBounce ; No? Skip Bounce

	; Yes? Bounce Off
	mov cl, 0
	mov [ball.moveY], cl

	.skipUpperBounce:
		; Skipped

	; Add Ball's Radius twice since we are going from the top of the hitbox to the bottom
	add edx, [ball.copyR] ; If I use ball.r instead of copyR, stuff breaks... I AM LOST
	add edx, [ball.copyR] ; If I use ball.r instead of copyR, stuff breaks... I AM LOST

	cmp edx, [windowSize.height] ; Is ball hitting the floor?
	jl .skipLowerBounce ; No? Skip Bounce

	; Yes? Bounce Off
	mov cl, 1
	mov [ball.moveY], cl

	.skipLowerBounce:
		; Skipped

	ret

UpdateWindowSize:
	;int GetScreenWidth(void);                                   // Get current screen width
	call GetScreenWidth
	mov [windowSize.width], eax
	;int GetScreenHeight(void);                                  // Get current screen height
	call GetScreenHeight
	mov [windowSize.height], eax
	ret

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
ball:
	.x: dd 400
	.y: dd 225
	.r: dd 15.0
	.copyR: dd 15 ; Has to be the same as .r
	.moveX: db 1 ; 1 = Moves Left, 0 = Moves Right
	.moveY: db 0; 1 = Moves Up, 0 = Moves Down
	.moveSpeed: dd 5 ; Movement speed of the ball, for easier changing

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

ratlibKeyboardKey:
	.KEY_NULL:            dd 0        ; Key: NULL, used for no key pressed
    ; Alphanumeric keys
	.KEY_APOSTROPHE:      dd 39       ; Key: '
	.KEY_COMMA:           dd 44       ; Key: ,
	.KEY_MINUS:           dd 45       ; Key: -
	.KEY_PERIOD:          dd 46       ; Key: .
	.KEY_SLASH:           dd 47       ; Key: /
	.KEY_ZERO:            dd 48       ; Key: 0
	.KEY_ONE:             dd 49       ; Key: 1
	.KEY_TWO:             dd 50       ; Key: 2
	.KEY_THREE:           dd 51       ; Key: 3
	.KEY_FOUR:            dd 52       ; Key: 4
	.KEY_FIVE:            dd 53       ; Key: 5
	.KEY_SIX:             dd 54       ; Key: 6
	.KEY_SEVEN:           dd 55       ; Key: 7
	.KEY_EIGHT:           dd 56       ; Key: 8
	.KEY_NINE:            dd 57       ; Key: 9
	.KEY_SEMICOLON:       dd 59       ; Key: ;
	.KEY_EQUAL:           dd 61       ; Key: =
	.KEY_A:               dd 65       ; Key: A | a
	.KEY_B:               dd 66       ; Key: B | b
	.KEY_C:               dd 67       ; Key: C | c
	.KEY_D:               dd 68       ; Key: D | d
	.KEY_E:               dd 69       ; Key: E | e
	.KEY_F:               dd 70       ; Key: F | f
	.KEY_G:               dd 71       ; Key: G | g
	.KEY_H:               dd 72       ; Key: H | h
	.KEY_I:               dd 73       ; Key: I | i
	.KEY_J:               dd 74       ; Key: J | j
	.KEY_K:               dd 75       ; Key: K | k
	.KEY_L:               dd 76       ; Key: L | l
	.KEY_M:               dd 77       ; Key: M | m
	.KEY_N:               dd 78       ; Key: N | n
	.KEY_O:               dd 79       ; Key: O | o
	.KEY_P:               dd 80       ; Key: P | p
	.KEY_Q:               dd 81       ; Key: Q | q
	.KEY_R:               dd 82       ; Key: R | r
	.KEY_S:               dd 83       ; Key: S | s
	.KEY_T:               dd 84       ; Key: T | t
	.KEY_U:               dd 85       ; Key: U | u
	.KEY_V:               dd 86       ; Key: V | v
	.KEY_W:               dd 87       ; Key: W | w
	.KEY_X:               dd 88       ; Key: X | x
	.KEY_Y:               dd 89       ; Key: Y | y
	.KEY_Z:               dd 90       ; Key: Z | z
	.KEY_LEFT_BRACKET:    dd 91       ; Key: [
	.KEY_BACKSLASH:       dd 92       ; Key: '\'
	.KEY_RIGHT_BRACKET:   dd 93       ; Key: ]
	.KEY_GRAVE:           dd 96       ; Key: `
    ; Function keys
	.KEY_SPACE:           dd 32       ; Key: Space
	.KEY_ESCAPE:          dd 256      ; Key: Esc
	.KEY_ENTER:           dd 257      ; Key: Enter
	.KEY_TAB:             dd 258      ; Key: Tab
	.KEY_BACKSPACE:       dd 259      ; Key: Backspace
	.KEY_INSERT:          dd 260      ; Key: Ins
	.KEY_DELETE:          dd 261      ; Key: Del
	.KEY_RIGHT:           dd 262      ; Key: Cursor right
	.KEY_LEFT:            dd 263      ; Key: Cursor left
	.KEY_DOWN:            dd 264      ; Key: Cursor down
	.KEY_UP:              dd 265      ; Key: Cursor up
	.KEY_PAGE_UP:         dd 266      ; Key: Page up
	.KEY_PAGE_DOWN:       dd 267      ; Key: Page down
	.KEY_HOME:            dd 268      ; Key: Home
	.KEY_END:             dd 269      ; Key: End
	.KEY_CAPS_LOCK:       dd 280      ; Key: Caps lock
	.KEY_SCROLL_LOCK:     dd 281      ; Key: Scroll down
	.KEY_NUM_LOCK:        dd 282      ; Key: Num lock
	.KEY_PRINT_SCREEN:    dd 283      ; Key: Print screen
	.KEY_PAUSE:           dd 284      ; Key: Pause
	.KEY_F1:              dd 290      ; Key: F1
	.KEY_F2:              dd 291      ; Key: F2
	.KEY_F3:              dd 292      ; Key: F3
	.KEY_F4:              dd 293      ; Key: F4
	.KEY_F5:              dd 294      ; Key: F5
	.KEY_F6:              dd 295      ; Key: F6
	.KEY_F7:              dd 296      ; Key: F7
	.KEY_F8:              dd 297      ; Key: F8
	.KEY_F9:              dd 298      ; Key: F9
	.KEY_F10:             dd 299      ; Key: F10
	.KEY_F11:             dd 300      ; Key: F11
	.KEY_F12:             dd 301      ; Key: F12
	.KEY_LEFT_SHIFT:      dd 340      ; Key: Shift left
	.KEY_LEFT_CONTROL:    dd 341      ; Key: Control left
	.KEY_LEFT_ALT:        dd 342      ; Key: Alt left
	.KEY_LEFT_SUPER:      dd 343      ; Key: Super left
	.KEY_RIGHT_SHIFT:     dd 344      ; Key: Shift right
	.KEY_RIGHT_CONTROL:   dd 345      ; Key: Control right
	.KEY_RIGHT_ALT:       dd 346      ; Key: Alt right
	.KEY_RIGHT_SUPER:     dd 347      ; Key: Super right
	.KEY_KB_MENU:         dd 348      ; Key: KB menu
    ; Keypad keys
	.KEY_KP_0:            dd 320      ; Key: Keypad 0
	.KEY_KP_1:            dd 321      ; Key: Keypad 1
	.KEY_KP_2:            dd 322      ; Key: Keypad 2
	.KEY_KP_3:            dd 323      ; Key: Keypad 3
	.KEY_KP_4:            dd 324      ; Key: Keypad 4
	.KEY_KP_5:            dd 325      ; Key: Keypad 5
	.KEY_KP_6:            dd 326      ; Key: Keypad 6
	.KEY_KP_7:            dd 327      ; Key: Keypad 7
	.KEY_KP_8:            dd 328      ; Key: Keypad 8
	.KEY_KP_9:            dd 329      ; Key: Keypad 9
	.KEY_KP_DECIMAL:      dd 330      ; Key: Keypad .
	.KEY_KP_DIVIDE:       dd 331      ; Key: Keypad /
	.KEY_KP_MULTIPLY:     dd 332      ; Key: Keypad *
	.KEY_KP_SUBTRACT:     dd 333      ; Key: Keypad -
	.KEY_KP_ADD:          dd 334      ; Key: Keypad +
	.KEY_KP_ENTER:        dd 335      ; Key: Keypad Enter
	.KEY_KP_EQUAL:        dd 336      ; Key: Keypad =
    ; Android key buttons
	.KEY_BACK:            dd 4        ; Key: Android back button
	.KEY_MENU:            dd 5        ; Key: Android menu button
	.KEY_VOLUME_UP:       dd 24       ; Key: Android volume up button
	.KEY_VOLUME_DOWN:     dd 25       ; Key: Android volume down button


section '.note.GNU-stack'
