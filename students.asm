MAX_NUM equ 16
new_line macro
  push dx
  push ax
  mov ah,2
  mov dl, 0dh
  int 21h
  mov dl, 0ah
  int 21h
  pop ax
  pop dx
endm
print_ch macro x
  push dx
  push ax
  mov dl, x
  mov ah,2
  int 21h
  pop ax
  pop dx
endm
print_str macro s, off
  push dx
  push ax
  mov dx, offset s
  mov ah,9
  int 21h
  pop ax
  pop dx
endm
print_str_with_off macro s, off
  push dx
  push ax
  mov dx, offset s
  add dx, off
  mov ah,9
  int 21h
  pop ax
  pop dx
endm
input_function macro
  push ax
  mov ah,1
  int 21h
  cbw
  mov func_id, ax
  pop ax
endm


data segment
  args dw 10 dup(0)                ;????
  count dw 0                       ;????????????
  func_id dw 0                     ;???????
  ids db 256 dup (0)               ;???
  names db 256 dup (0))            ;????
  classes db 64 dup (0))           ;??
  grades db 64 dup (0))            ;??��BCD???????
  qbsy dw 1000, 100, 10, 1
  grades_int dw 16 dup (0)
  grade_avg db 3 dup(0)
  db '.0$'
  ini_info db 'Hello, this is a student information manage system, 1, 2, 3 or 4 are for different functions$'
  request_FID db 'Please input for function:$'
  table dw Register, Sort, Average, Statistics
  R_name db 'Register: Name: $'
  R_id db 'Register: Id: $'
  R_grade db 'Register: Grade: $'
  R_class db 'Register: Class: $'
  request_add_more db 'Please press y if you would like to add more: $'
  A_info db 'Average: $'
  S_info db 'Sort by grades (high score first): $'
  sorted dw 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
  St_060 db 'Failed: $'
  St_6070 db '60 to 70: $'
  St_7080 db '70 to 80: $'
  St_8090 db '80 to 90: $'
  St_90100 db '90 to 100: $'
  goodbye db 'Goodbye!$'
  ten dw 10
data ends

stack segment
  dw 128 dup(0)
stack ends

code segment
  assume cs: code, ds: data, ss: stack
start:mov ax, data
      mov ds, ax
      print_str ini_info
      new_line
stt:
      print_str request_FID
      input_function
      new_line
      mov bx, func_id
      cmp bx, '4'
      jg endc
      cmp bx, '1'
      jl endc
      sub bx, '1'
      shl bx, 1
      jmp table[bx]
Register:
      call pRegister
      jmp stt
Sort:
      call pSort
      jmp stt
Average:
      call pAverage
      jmp stt
Statistics:
      call pStatistics
      jmp stt
endc: print_str Goodbye
      mov ax, 4c00h
      int 21h

pStatistics proc near
  print_str St_060
  new_line
  mov cx, count
  mov si, 0
lp_060:
  mov bx, sorted[si]
  shl bx, 1
  add si, 2
  mov dx, grades_int[bx]
  cmp dx, 600
  jge end060
  shr bx, 1
  call print_stu_info
end060:
  loop lp_060

  print_str St_6070
  new_line
  mov cx, count
  mov si, 0
lp_6070:
  mov bx, sorted[si]
  shl bx, 1
  add si, 2
  mov dx, grades_int[bx]
  cmp dx, 600
  jl end6070
  cmp dx, 700
  jge end6070
  shr bx, 1
  call print_stu_info
end6070:
  loop lp_6070

  print_str St_7080
  new_line
  mov cx, count
  mov si, 0
lp_7080:
  mov bx, sorted[si]
  shl bx, 1
  add si, 2
  mov dx, grades_int[bx]
  cmp dx, 700
  jl end7080
  cmp dx, 800
  jge end7080
  shr bx, 1
  call print_stu_info
end7080:
  loop lp_7080

  print_str St_8090
  new_line
  mov cx, count
  mov si, 0
lp_8090:
  mov bx, sorted[si]
  shl bx, 1
  add si, 2
  mov dx, grades_int[bx]
  cmp dx, 800
  jl end8090
  cmp dx, 900
  jge end8090
  shr bx, 1
  call print_stu_info
end8090:
  loop lp_8090

  print_str St_90100
  new_line
  mov cx, count
  mov si, 0
lp_90100:
  mov bx, sorted[si]
  shl bx, 1
  add si, 2
  mov dx, grades_int[bx]
  cmp dx, 900
  jl end90100
  shr bx, 1
  call print_stu_info
end90100:
  loop lp_90100


  ret
pStatistics endp



pSort proc near
  push ax
  push bx
  push cx
  push dx
  push si
  push di
  push bp
  print_str S_info
  new_line
sort_grade:
  mov cx, count
  dec cx
  mov bp, 2
  mov di, 2
lp_out_grade:
  mov dx, cx                          ;dx save cx of out
  mov bx, 0
lp_in_grade:
  mov si, sorted[bx]
  mov bp, sorted[bx+di]
  shl si, 1                          ; si is ip of grades
  shl bp, 1
  mov ax, grades_int[si]
  cmp ax, grades_int ds:[bp]
  jae cont_grade
  shr si, 1
  xchg si, sorted[bx+di]
  mov sorted[bx], si
cont_grade:
  add bx, 2
  loop lp_in_grade
  mov cx, dx
  loop lp_out_grade
  jmp ends

ends:
  mov si, 0
  mov cx, count
prt_sorted:
  mov bx, sorted[si]
  call print_stu_info
  add si, 2
  loop prt_sorted

  pop bp
  pop di
  pop si
  pop dx
  pop cx
  pop bx
  pop ax
  ret
pSort endp

print_stu_info proc near
  push bx
  push si
  push ax
  shl bx, 4
  print_str_with_off names bx
  print_ch ' '
  print_str_with_off ids bx
  print_ch ' '
  shr bx, 2
  print_str_with_off classes bx
  print_ch ' '
  mov si, 0
lp1:
  mov al, grades[bx+si]
  print_ch al
  inc si
  cmp si, 3
  jnz non_dot
  print_ch '.'
non_dot:
  cmp si, 3
  jle lp1
  new_line
  pop ax
  pop si
  pop bx
  ret
endp


pAverage proc near
  print_str A_info
  push ax
  push bx
  push cx
  push dx
  mov cx, count
  mov bx, 0
  mov ax, 0
lp_avg:
  add ax, grades_int[bx]
  add bx, 2
  loop lp_avg

  mov dx, 0
  div count  ; the avg is in ax
  mov cx, 4
  mov bx, 4
sto_avg:
  mov dx, 0
  div ten     ; ax is rest, dx is module
  add dx, '0'
  cmp bx, 3
  jnz skip_dec_bx
  dec bx
skip_dec_bx:
  mov grade_avg[bx], dl
  dec bx
  loop sto_avg
  print_str grade_avg
  new_line
  pop dx
  pop cx
  pop bx
  pop ax
  ret
pAverage endp


pRegister proc near
  push cx
  mov cx, count
in_info:
  print_str R_name
  call input_name
  new_line
  print_str R_id
  call input_id
  new_line
  print_str R_class
  call input_class
  new_line
  print_str R_grade
  call input_grade
  new_line
  inc cx
  print_str request_add_more
  input_function
  new_line
  cmp func_id, 'y'
  jz in_info

  mov count, cx
  pop cx
  ret
pRegister endp


input_name proc near
  push bx
  push ax
  push si
  mov bx, cx
  shl bx, 4
  mov si, 0
in_name:
  mov ah, 1
  int 21h
  cmp al, 0dh
  jz exit_name
  mov names[bx+si], al
  inc si
  jmp in_name
exit_name:
  mov names[bx+si], '$'
  pop si
  pop ax
  pop bx
  ret
input_name endp


input_id proc near
  push bx
  push ax
  push si
  mov bx, cx
  shl bx, 4
  mov si, 0
in_id:
  mov ah, 1
  int 21h
  cmp al, 0dh
  jz exit_id
  mov ids[bx+si], al
  inc si
  jmp in_id
exit_id:
  mov ids[bx+si], '$'
  pop si
  pop ax
  pop bx
  ret
input_id endp


input_class proc near
  push bx
  push ax
  push si
  mov bx, cx
  shl bx, 2
  mov si, 0
in_class:
  mov ah, 1
  int 21h
  cmp al, 0dh
  jz exit_class
  mov classes[bx+si], al
  inc si
  jmp in_class
exit_class:
  mov classes[bx+si], '$'
  pop si
  pop ax
  pop bx
  ret
input_class endp


input_grade proc near ; cx is the arg which is for the nth
  push bx
  push ax
  push si
  push dx
  push di
  mov di, 0
  mov bx, cx
  shl bx, 2
  mov si, 0
in_grade:                     ;si is for the ip
  mov ah, 1
  int 21h
  cmp al, '.'
  jz in_grade
  cmp al, 0dh
  jz exit_grade
  mov grades[bx+si], al
  cbw
  mov dx, ax
  sub dx, '0'
  push si
  shl si, 1
  mov ax, qbsy[si]            ;1000? 100? 10? 1?
  pop si
  mul dx
  add di, ax
  inc si
  jmp in_grade
exit_grade:
  shr bx, 1
  mov grades_int[bx], di
  pop di
  pop dx
  pop si
  pop ax
  pop bx
  ret
input_grade endp


code ends
