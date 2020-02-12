[bits 16]           ; tell assembler that working in real mode(16 bit mode)  
[org 0x7c00]        ; organize from 0x7C00 memory location where BIOS will load us  


start:
  ; cls
  mov ax, 0xb800
  push ax
  mov es, ax
  xor di, di
  mov cx, 0x07d0
  mov ax, 0x0000
  rep stosw
  pop ax
  mov ds, ax

  mov bl, '0' ;; init turn
  mov [turn], bl

draw:
  mov ax, 0xb800
  mov es, ax
  mov word [0], 0x0731
  mov word [2], 0x087C ; |
  mov word [4], 0x0732
  mov word [6], 0x087C ; |
  mov word [8], 0x0733

  mov word [160], 0x082D
  mov word [162], 0x082B ; +
  mov word [164], 0x082D
  mov word [166], 0x082B ; +
  mov word [168], 0x082D

  mov word [320], 0x0734
  mov word [322], 0x087C ; |
  mov word [324], 0x0735
  mov word [326], 0x087C ; |
  mov word [328], 0x0736

  mov word [480], 0x082D
  mov word [482], 0x082B ; +
  mov word [484], 0x082D
  mov word [486], 0x082B ; +
  mov word [488], 0x082D

  mov word [640], 0x0737
  mov word [642], 0x087C ; |
  mov word [644], 0x0738
  mov word [646], 0x087C ; |
  mov word [648], 0x0739

;;;;;;;;
playmore:
  mov bx, 0x0458; 'X'
  call play

  mov bx, 0x024F; 'O'
  call play

  jmp playmore


play: 
	call getnum; key in al, player in bx
	; mov dx, ax
  cbw
  mov ch, 3 
  div ch
  mov cl, ah ; rem
  shl cl, 2
  cbw ; al into ax
	push cx ; save cause mul will destroy it
  mov cx, 320 
  mul cx

	pop cx
  xor ch,ch

  add ax, cx
  mov si, ax

  mov cx, word [si]
	cmp cl, 0x40	; check if number (already played this cell)
	jnc play

  mov word [si], bx
	; lea ax, [ax + ax*2]
	; mov dx, [bx + 2*ax]
	mov cx, bx
  shl cx, 1
	add cx, bx; = cx*3

	;; check win
	; lines 1-3
  mov ax, word [0]
  add ax, word [4]
  add ax, word [8]
  cmp ax, cx
  jz winner

  mov ax, word [320]
  add ax, word [324]
  add ax, word [328]
  cmp ax, cx
  jz winner

  mov ax, word [640]
  add ax, word [644]
  add ax, word [648]
  cmp ax, cx
  jz winner

  ;columns 1-3
  mov ax, word [0]
  add ax, word [320]
  add ax, word [640]
  cmp ax, cx
  jz winner

  mov ax, word [4]
  add ax, word [324]
  add ax, word [644]
  cmp ax, cx
  jz winner

  mov ax, word [8]
  add ax, word [328]
  add ax, word [648]
  cmp ax, cx
  jz winner

  ;2 diagonals, first top left to bottom right
  mov ax, word [0]
  add ax, word [324]
  add ax, word [648]
  cmp ax, cx
  jz winner

  mov ax, word [8]
  add ax, word [324]
  add ax, word [640]
  cmp ax, cx
  jz winner

  mov bl, [turn] ;; check tie
  inc bl
  cmp bl, '9'
  je tie
  mov [turn],bl
  ret

winner: ; win symbol + color in bx
  mov di, 0x14
  mov ah, bh ; color
  mov al, 'W'
  stosw
  mov al, 'i'
  stosw
  mov al, 'n'
  stosw
  mov al, 'n'
  stosw
  mov al, 'e'
  stosw
  mov al, 'r'
  stosw
  inc di
  inc di
  mov ax, bx
  stosw

  mov ah, 0               ; wait for key
  int 0x16

  db 0EAh                 ; machine language to jump to FFFF:0000 (reboot)
  dw 0000h
  dw 0FFFFh

tie:
  mov di, 0x14
  mov ax, 0x0254
  stosw
  mov al, 'i'
  stosw
  mov al, 'e'
  stosw
	ret;	
  
getnum: ; accepts 1..9
  mov ah, 0               ; wait for key
  int 0x16
	sub al,0x31 ; Subtract code for ASCII digit 1
	jc getnum ; Is it less than? Wait for another key
	cmp al,0x09 ; Comparison with 9
	jnc getnum ; Is it greater than or equal to? Wait 
	ret;

message:                        ; Dump si to screen.
  ;xor di, di
	mov di, 20
.loop:
  mov cl, [si]
  test cl, cl
  jz .done
  mov ch, bh
  mov word [es:di], cx
  inc di
  inc di
  inc si
  jmp .loop
.done:
  ret

turn equ 0x30

times (510 - ($ - $$)) db 0x00     ;set 512 BS
dw 0xAA55
