{ ----------------------------------------------------------------------- }
{ Digital Utilities *** MCGA Screen tools ***                             }
{ ----------------------------------------------------------------------- }

Var
  Hatter : ^GScreen;
  VHatter: GScreen absolute $A000:00;
  Sor    : Array [0..199] of Word;

{ Hatter^-t torli }
Procedure HCls;Assembler;
asm
  les di, hatter
  mov cx, 16000
  db 066h;xor ax, ax {xor eax, eax}
  {rep stosw}
  db 066h;rep stosw
  {db 0f3h, 66h, 0abh {= rep stosw !!}
end;

{ Hatter^-t kirajzolja }
Procedure HRajz;Assembler;
asm
  mov bx, ds
  mov ax, 0a000h
  mov es, ax
  xor di, di
  lds si, hatter
  mov cx, 16000
  {rep movsw}
  db 0f3h, 066h, 0a5h
  mov ds, bx
end;

Procedure MCGAInit;
Var I: Word;
begin
  For I := 0 to 199 Do Sor [I] := I*320;
end;

Procedure RW;Assembler;
asm
  mov dx, 03dah
  @j1: in al, dx;test al, 8;jz @j1
  @j2: in al, dx;test al, 8;jnz @j2
end;

