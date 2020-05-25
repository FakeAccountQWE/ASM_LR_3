.model small
.stack 100h
.data 
    enter db 0dh, 0ah , '$'
    N equ 30
    array dw N dup(?)
    msg1 db  "Enter 30 numbers: ", 0dh , 0ah ,'$'    
    meserr db 0dh, "Error input ! ", 0ah, 0dh , '$'
    msg2 db 10, 13, "Your number: ", '$'
.code 

proc input   
   ;push bp
    xor cx,cx                  ; ��������� �������� �������� �����
esche_chislo:
    xor dx,dx                  ; � dx ��������� �����
input_loop:
    mov ah,01h                 ; ���� �������
    int 21h                    
    cmp al,0dh                 ; ���� enter
    je chislo                  ; ������� ����� � ������
    cmp al,20h                 ; ���� ������
    je chislo                  ; �������
    
    ;push bp
    cmp al, '-'
    jne proverka_minus
    xor bp, bp
    mov bp,1
    jmp input_loop
    proverka_minus:
    cmp al, '0'
    jb notnum
    cmp al, '9'
    ja notnum
    jmp beg
notnum:
    mov ah, 09h
    lea dx, meserr
    int 21h                  
    jmp esche_chislo
beg:    
    sub al,30h                 ; �������� '0'
    mov bl,al                  ; ��������� ����� � bl
    mov ax,dx                  ; � ax - �������� �����
    push dx
    xor dx, dx  
    mov dl,10
    mul dx    
    
    jc notnum
    cmp ax, 32768
    jae notnum                   ; �������� �� 10
    pop dx
    xor bh,bh                  
    add ax,bx
                 ; ��������� ����� �� al
    jc notnum
    cmp ax, 32768 
    jae notnum                 
    mov dx,ax                  ; ����� ����� � dx
    jmp input_loop
chislo:   
    mov bx,cx                  ; � bx ���������� ����� ���������� �����
    shl bx,1                   ; �������� ���������� ����� � �������
    mov array[bx],dx           ; ���������� � ������ ����� 
    mov ah, 09h
    lea dx, enter
    int 21h
    
    inc cx                     ; ����������� ������� �������� �����
    cmp cx,N                   ; ���� ����� �� ��������� �����
    jne esche_chislo           ; �� ����� ��� ����    
ret 
endp input

; ������� ����� �� �������� AX �� �����
; ax - ����� ��� �����������
Show_AX proc
        push    ax
        push    bx
        push    cx
        push    dx
        push    di
 
        mov     cx, 10          ; cx - ��������� ������� ���������
        xor     di, di          ; di - ���������� ���� � �����
 
        ; ���� ����� �������������
        ;1) ���������� '-'
        ;2) ������� ax �������������
        or      ax, ax
        jns     Conv
        push    ax
        mov     dx, '-'
        mov     ah, 2           ; ah - ����� ������� �� �����
        int     21h
        pop     ax
 
        neg     ax
 
Conv:
        xor     dx, dx
        div     cx              ; dl = num mod 10
        add     dl, '0'         ; ������� � ���������� ������
        inc     di
        push    dx              ; ���������� � ����
        or      ax, ax
        jnz     Conv
        ; ������� �� ����� �� �����
Show:
        pop     dx              ; dl = ��������� ������
        mov     ah, 2           ; ah - ����� ������� �� �����
        int     21h
        dec     di              ; ��������� ���� di != 0
        jnz     Show
 
        pop     di
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        ret
Show_AX endp

start:
    mov ax, @data
    mov ds, ax    
    
    mov ah, 09h
    lea dx, msg1                ; ������� 1 ���������
    int 21h    

    call input                  ; ������ ������
    
    mov ah, 09h
    lea dx, msg2                ; ������� 2 ���������
    int 21h
        
    mov dx,N
    shl dx,1
    xor cx,cx                   ; ������� ������������ ���������
    xor ax,ax                   ; ���������
    xor si,si                   ; i = 0
    
for_i:                          ; ���� �� i 
    xor bx,bx                   ; k = 0
    xor di,di                   ; j = 0
    push ax
    mov ax, [array+si]
    for_j:                      ; ���� �� j
        push bx
        mov bx, [array+di]
        cmp ax, bx              ; ����� ���������� ���������
        pop bx
        je nbegin
        jmp begin1
        nbegin:
            inc bx              ; ���������� �������� ���������, k++                
        begin1:
            add di,2            ; j++
            cmp di,dx           ; ����� ����� �� j
            je lol
    jmp for_j 
    lol:
        pop ax
        cmp cx,bx               ; ����������� �������� � ������������ ����������� ���������
        jl kek
        jmp begin2
        kek:
            mov cx,bx           ; ���������� ����������
            mov ax,[array+si]   ; ���������� ���� �������
    begin2: 
        add si,2                ; i++
        cmp si,dx               ; ����� ����� �� i
        je finish   
jmp for_i          
              
finish:
    call Show_Ax
    mov ax, 4c00h
    int 21h
end start