Program FastTri04;

Uses DU, DUTypes, Crt;

{$I DUMCGA.INC}

{ Vonalhuzashoz }
Var r1, r2, r3, r4, r5: Word;
Const SegA000: Word = $A000;
      NTab   : Array [0..11] of Integer = (
             -321,-320,-319,000,
             -001,000,001,000,
             319,320,321,000);

Procedure Line (x1,y1,x2,y2: Word;Color: Byte);Assembler;
asm
    lea di, sor          {Cimszamitas: ax=320*y1}
    add di, y1
    add di, y1
    mov ax, ds:[di]

    les  di, Hatter      { Az ES-t r  ll¡tjuk a k‚pre }

    add  ax,x1
    add  di,ax          { A DI a kezd”ponthoz tartoz¢ c¡met tartalmazza }

    mov  al,Color
    mov  es:[di],al     { A kezd”pont kirajzol sa a k‚pre }

    mov  bx,0101h       { sgn X (BL) ‚s sgn Y (BH) , mindkett” +1 }

    mov  dx,X2
    sub  dx,X1          { DX = X2-X1 }
    jnc  @t1
    neg  dx             { DX = abs X  (ahol X=X2-X1) }
    mov  bl,255         { BL = sgn X }
@t1:
    mov  si,Y2
    sub  si,Y1          { SI = Y2-Y1 }
    jnc  @t2
    neg  si             { SI = abs Y  (ahol Y=Y2-Y1) }
    mov  bh,255         { BH = sgn Y }
@t2:
    mov  cx,si          { CX = abs Y }
    mov  r2,bx          { r2 = sgn X sgn Y t rol sa k‚s”bbi haszn latra }

    cmp  dx,si          { Eld”nti, hogy melyik lesz a f”ir ny (X/Y) }
    jnc  @x_ge_y
    mov  r1, dx          { r1 = abs X }
    xor  bl,bl          { sgn X = 0 , teh t X n”vekm‚nyes ferde vonal }
    jmp  @t3

@x_ge_y:
    test dx,dx          { Akkor l‚p ki, ha  abs X=abs Y=0 (csak egy pont) }
    jz   @exit
    mov  r1,si          { r1 = abs Y }
    mov  cx,dx          { cx = abs X }
    xor  bh,bh          { sgn Y = 0 , teh t Y n”vekm‚nyes ferde vonal }
@t3:
    mov  r3,cx          { CX darab pontot kell kirakni }

    mov  ax,cx
    shr  ax,1           { Az AX-be kerl az INT(CX/2) ‚rt‚k }

    { A line-loop ciklus a vonal pontjait rajzolja fel }

@line_loop:
    add  ax,r1          { a n”vekm‚ny hozz ad sa az AX-hez }
    jc   @diag          { ha t£lcsordul, akkor egy  tl¢ ir ny£ l‚p‚s j”n }
    cmp  ax,r3
    jc   @vhl           { ha kisebb az r3-n l, akkor V vagy H l‚p‚s }

@diag:                  {  tl¢s l‚p‚s }
    sub  ax,r3          { az ”sszead s korrig l sa }
    mov  r4,ax          { az AX t rol sa k‚s”bbre  }
    mov  ax,r2          { az eredeti sgn X ‚s sgn Y ‚rt‚k kell }
    jmp  @nextplot      { ugr s a pontrajzol sra }

@vhl:                   { v¡zszintes vagy horizont lis l‚p‚s }
    mov  r4,ax          { az AX t rol sa k‚s”bbre  }
    mov  ax,bx          { a sz m¡tott sgn X ‚s sgn Y kell (valamelyik nulla) }

@nextplot:              { pontrajzol s }
    mov  r5,bx          { a BX regiszter t rol sa }

    inc  al
    shl  al,1           { AL = (sgn X+1)*2, ez 0,2,4 ‚rt‚k lehet  }
    inc  ah
    shl  ah,3           { AH = (sgn Y+1)*8, ez 0,8,16 ‚rt‚k lehet }
    add  al,ah
    xor  ah,ah
    lea  bx,Ntab        { Most a BX az Ntab megfelel” elem‚re mutat }
    add  bx,ax
    add  di,[bx]        { A k‚pc¡m n”vel‚se, elmozdul s a megfelel” ir nyba }
    mov  al,Color
    mov  ES:[di],al     { A pont kirajzol sa }

    mov  ax, r4          { A t rolt ‚rt‚kek visszah¡v sa }
    mov  bx, r5
    loop @line_loop     { vissza, ha van m‚g kirajzoland¢ k‚ppont }
@exit:
end;

Procedure HLine (x1,x2,y: Integer;Szin: Byte);Assembler;
asm
  {y > 199 ? Ha igen y1 := 199}
  cmp y, 199
  jbe @neegyenlitsd0
  mov y, 199

@neegyenlitsd0:

  {x1 > 319 ? Ha igen, x1 := 319}
  cmp x1, 319
  jbe @neegyenlitsd
  mov x1, 319

@neegyenlitsd:

  {x2 > 319 ? Ha igen, x2 := 319}
  cmp x2, 319
  jbe @neegyenlitsd2
  mov x2, 319

@neegyenlitsd2:

  {x1 = x2 ? ha igen, csupan pottyrakas}
  mov ax, x2
  cmp x1, ax
  jne @vonalhuzas
  {pottyrakas}
  lea di, sor
  add di, y
  add di, y
  mov ax, ds:[di]
  add ax, x1
  les di, hatter
  add di, ax
  mov al, szin
  mov es:[di], al
  jmp @vege

@vonalhuzas:

  {x2 < x1 ? Ha igen, CSERE}
  mov ax, x2
  cmp x1, ax
  jbe @necsereld
  mov bx, x1
  xchg x2, bx
  mov x1, bx

@necsereld:

  lea di, sor          {Cimszamitas: ax=320*y1}
  add di, y
  add di, y
  mov ax, ds:[di]

  les di, hatter

  add ax, x1
  add di, ax
  mov cx, x2
  sub cx, x1
  mov al, szin
@cimke:
  stosb
  loop @cimke

@vege:
end;


Procedure FTri (x1,y1,x2,y2,x3,y3: Integer;Szin: Byte);
Var xx1, yy1, xx2, yy2, xx3, yy3: LongInt;
    xp1, yp1, xp2, yp2, xp3, yp3: Integer;
    I                           : Byte;
    Le1, Le2                    : LongInt;
    H, M                        : Word;
    { A   }
    {  o  }
    {o  o }
    {ooooo}
    {B   C}
Begin
  Line (x1,y1,x2,y2,Szin);
  Line (x2,y2,x3,y3,Szin);
  Line (x3,y3,x1,y1,Szin);

  If (y1 < y2) then
  begin
    {Az 1. a 2. felett}
    If (y1 < y3) then
    begin
      {Az 1. van legfelul}
      xp1 := x1;yp1 := y1;
      If (y2 > y3) then
      begin
        {1., 2, 3.}
        xp2 := x2;yp2 := y2;
        xp3 := x3;yp3 := y3;
      end else
      begin
        {1, 3, 2}
        xp2 := x3;yp2 := y3;
        xp3 := x2;yp3 := y2;
      end;
    end else
    begin
      {3, 2, 1}
      xp1 := x3;yp1 := y3;
      xp2 := x2;yp2 := y2;
      xp3 := x1;yp3 := y1;
    end;

  xx1 := LongInt (xp1*100000);
  yy1 := LongInt (yp1*100000);
  xx2 := LongInt (xp2*100000);
  yy2 := LongInt (yp2*100000);
  xx3 := LongInt (xp3*100000);
  yy3 := LongInt (yp3*100000);

  {***}
  {FAST-FILL! [1]}
  {x1,y1 - Top left}
  {x2,y2 - Bottom}
  {x3,y3 - Middle on the right}
  If (yp1 < yp3) then
  begin
    Le1 := (xx2-xx1) div (yp2-yp1);
    Le2 := (xx3-xx1) div (yp3-yp1);
    I := yp1;
    If le1 < le2 then
    Repeat
      H := xp1+(le1*(i-yp1)) div 100000;
      M := xp1+(le2*(i-yp1)) div 100000;
      HLine (H,M,I,Szin);
      Inc (I);
    Until I = yp3 else
    Repeat
      H := xp1+(le1*(i-yp1)) div 100000;
      M := xp1+(le2*(i-yp1)) div 100000;
      HLine (M, H, I, Szin);
      Inc (I);
    Until I = yp3;
  end else I := yp3;
  If (yp3 < yp2) then
  begin
    Le1 := (xx2-xx1) div (yp2-yp1);
    Le2 := (xx3-xx2) div (yp2-yp3);
    Repeat
      H := xp1+(le1*(i-yp1)) div 100000;
      M := xp3-(le2*(i-yp3)) div 100000;
      HLine (M, H, I, Szin);
      Inc (I);
    Until I = yp2;
  end;
end;

End;

Var Eg, Ex, Ey: Word;

Begin
  MCGAINIT;
  New (Hatter);
  GrOn;

  Repeat
    HCls;
    GetMousePos (EG, EX, EY);
    Ex := Ex shr 1;
    FTri (20,20,60,60,EX,EY,50);
    HRajz;
  Until (Port [$60] = 1) or (EG = 2);

  GrOff;
  Dispose (Hatter);
End.