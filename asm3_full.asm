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
    xor cx,cx                  ; начальное значение счётчика чисел
esche_chislo:
    xor dx,dx                  ; в dx очередное число
input_loop:
    mov ah,01h                 ; ввод символа
    int 21h                    
    cmp al,0dh                 ; если enter
    je chislo                  ; занести число в массив
    cmp al,20h                 ; если пробел
    je chislo                  ; занести
    
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
    sub al,30h                 ; вычитаем '0'
    mov bl,al                  ; сохраняем цифру в bl
    mov ax,dx                  ; в ax - введённое число
    push dx
    xor dx, dx  
    mov dl,10
    mul dx    
    
    jc notnum
    cmp ax, 32768
    jae notnum                   ; умножаем на 10
    pop dx
    xor bh,bh                  
    add ax,bx
                 ; добавляем цифру из al
    jc notnum
    cmp ax, 32768 
    jae notnum                 
    mov dx,ax                  ; число снова в dx
    jmp input_loop
chislo:   
    mov bx,cx                  ; в bx порядковый номер очередного числа
    shl bx,1                   ; смещение очередного числа в массиве
    mov array[bx],dx           ; записываем в массив число 
    mov ah, 09h
    lea dx, enter
    int 21h
    
    inc cx                     ; увеличиваем счётчик введённых чисел
    cmp cx,N                   ; если ввели не последнее число
    jne esche_chislo           ; то введём ещё одно    
ret 
endp input

; выводим число из регистра AX на экран
; ax - число для отображения
Show_AX proc
        push    ax
        push    bx
        push    cx
        push    dx
        push    di
 
        mov     cx, 10          ; cx - основание системы счисления
        xor     di, di          ; di - количество цифр в числе
 
        ; если число отрицательное
        ;1) напечатать '-'
        ;2) сделать ax положительным
        or      ax, ax
        jns     Conv
        push    ax
        mov     dx, '-'
        mov     ah, 2           ; ah - вывод символа на экран
        int     21h
        pop     ax
 
        neg     ax
 
Conv:
        xor     dx, dx
        div     cx              ; dl = num mod 10
        add     dl, '0'         ; перевод в символьный формат
        inc     di
        push    dx              ; складываем в стек
        or      ax, ax
        jnz     Conv
        ; выводим из стека на экран
Show:
        pop     dx              ; dl = очередной символ
        mov     ah, 2           ; ah - вывод символа на экран
        int     21h
        dec     di              ; повторяем пока di != 0
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
    lea dx, msg1                ; выводим 1 сообщение
    int 21h    

    call input                  ; вводим массив
    
    mov ah, 09h
    lea dx, msg2                ; выводим 2 сообщение
    int 21h
        
    mov dx,N
    shl dx,1
    xor cx,cx                   ; счётчик максимальных вхождений
    xor ax,ax                   ; результат
    xor si,si                   ; i = 0
    
for_i:                          ; цикл по i 
    xor bx,bx                   ; k = 0
    xor di,di                   ; j = 0
    push ax
    mov ax, [array+si]
    for_j:                      ; цикл по j
        push bx
        mov bx, [array+di]
        cmp ax, bx              ; поиск одинаковых элементов
        pop bx
        je nbegin
        jmp begin1
        nbegin:
            inc bx              ; увеличение счётчика найденных, k++                
        begin1:
            add di,2            ; j++
            cmp di,dx           ; конец цикла по j
            je lol
    jmp for_j 
    lol:
        pop ax
        cmp cx,bx               ; определение элемента с максимальным количеством вхождений
        jl kek
        jmp begin2
        kek:
            mov cx,bx           ; запоминаем количество
            mov ax,[array+si]   ; запоминаем этот элемент
    begin2: 
        add si,2                ; i++
        cmp si,dx               ; конец цикла по i
        je finish   
jmp for_i          
              
finish:
    call Show_Ax
    mov ax, 4c00h
    int 21h
end start