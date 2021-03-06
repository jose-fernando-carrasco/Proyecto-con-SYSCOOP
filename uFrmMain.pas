UNIT uFrmMain;

interface

uses uCola,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, Vcl.Grids, Vcl.StdCtrls, System.Math, MMSystem,
  Vcl.MPlayer, Vcl.Imaging.pngimage, Vcl.ExtCtrls, Vcl.Imaging.jpeg;



type
  TForm1 = class(TForm)
    MainMenu : TMainMenu;
    Juego1 : TMenuItem;
    N1     : TMenuItem;
    Salir  : TMenuItem;
    MediaPlayer1: TMediaPlayer;
    Jugar1: TMenuItem;
    TituloPrincipal: TLabel;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;

    procedure FormCreate(Sender: TObject);
    procedure SalirClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Jugar1Click(Sender: TObject);

  private
    poUser   : PCB;       //Para almacenar al personaje del usuario.  Este PCB no se encolar?, y por tanto no lo manipular? el PlanificadorRR.
    poCola   : Cola;      //Cola del Planificador RR.
    pnEstado : Integer;   //0=No pasa nada, 1=Muri? el poUser, 2=Muri? la Nave
    pnSentido :Integer;     // Controlar el sentido
    pnSentidox, pnSentidoy :Integer;

    procedure InitJuego();
    procedure CicloJuego;
    function ColiNaves(toBalin:PCB):Boolean; // Verifica si la bala del user le dio a alguna nave
    procedure VerificarColi2;
    function ColiBalasNaves(var toBalaUser:PCB):Boolean;
    procedure ColibalasUser( var toBalaNave:PCB);
    function colision(toObjeto1,toObjeto2:PCB):boolean;
    function colisionBalaUConNaves(toObjeto1,toObjeto2:PCB):boolean;

    procedure cls;
    procedure Dibujar(toPCB:PCB);
    procedure Dibujar2(toPCB: PCB);
    procedure Borrar(toPCB:PCB);
    procedure Borrar2(toPCB: PCB);
    function  Interpolar(tnX1,tnX2:Integer; tnVel:real):Integer;
    procedure Rectangulo(tnX, tnY, tnAncho, tnAlto, Color: Integer);
    function  MaxX : Integer;
    function  MaxY : Integer;

    procedure PlanificadorRR;
    procedure MoverNave(toPRUN : PCB);
    procedure MoverBalaU(toPRUN : PCB);
    procedure MoverBalaN(toPRUN : PCB);

  public

  end;

var
  Form1: TForm1;

implementation
{$R *.dfm}


(* Metodo que crea la instancia Cola e Inicia el Sonido
   @method  FormCreate()
   @author  Jos? Fernando O?a Carrasco
   @fecha   13-01-2022
   @param   Sender:TObject
*)
procedure TForm1.FormCreate(Sender: TObject);
begin
  poCola := Cola.Create;    //Construir (new) la cola del PlanificadorRR.
  sndPlaySound('Recursos/Principal.wav',SND_ASYNC);
end;



(* Metodo que inicia el juego
   @method  Jugar1Click()
   @author  Jos? Fernando O?a Carrasco
   @fecha   13-01-2022
   @param   Sender:TObject
*)
procedure TForm1.Jugar1Click(Sender: TObject);
begin
   InitJuego();
end;



(* Metodo para salir del ciclo del Juego
   @method  SalirClick()
   @author  Jos? Fernando O?a Carrasco
   @fecha   13-01-2022
   @param   Sender:TObject
*)
procedure TForm1.SalirClick(Sender: TObject);
begin
  pnEstado := 100;
  Application.Terminate;
end;



(* Metodo para cerrar el formulario
   @method  FormClose()
   @author  Jos? Fernando O?a Carrasco
   @fecha   13-01-2022
   @param   Sender:TObject, Action:TCloseAction
*)
procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SalirClick(Sender);
end;



(* Metodo para manejar el ca?on del Usuario
   @method  FormClose()
   @author  Jos? Fernando O?a Carrasco
   @fecha   13-01-2022
   @param   Key: Word
*)
procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
loP:PCB;
llpresiono: Boolean;
begin
   llpresiono := false;
   case Key of
     VK_RIGHT : begin  //El user puls? la tecla Flecha-Derecha
                   Borrar(poUser);
                   poUser.gnX := poUser.gnX + 15;
                   VerificarColi2;
                   if (poUser.gnX>= MaxX-30) then
                       poUser.gnX := MaxX-30;
                   Dibujar(poUser);
                   llpresiono := true;
                end;

      VK_LEFT : begin   //El user puls? la tecla Flecha-Izquierda
                   Borrar(poUser);
                   poUser.gnX := poUser.gnX - 15;
                   VerificarColi2;
                   if (poUser.gnX < 0) then
                       poUser.gnX := 0;
                   Dibujar(poUser);
                   llpresiono := true;
                 end;

      VK_DOWN : begin   //El user puls? la tecla Flecha-Abajo
                   Borrar(poUser);
                   poUser.gnY := poUser.gnY + 15;
                   VerificarColi2;
                   if (poUser.gnY>MaxY-30) then
                       poUser.gnY := MaxY-30;
                   Dibujar(poUser);
                   llpresiono := true;
                 end;

      VK_UP : begin   //El user puls? la tecla Flecha-Arriba
                   Borrar(poUser);
                   poUser.gnY := poUser.gnY - 15;
                   VerificarColi2;
                   if (poUser.gnY<0) then
                       poUser.gnY := 0;
                   Dibujar(poUser);
                   llpresiono := true;
              end;

      VK_SPACE : begin   //Crear un proceso BALAU
                   loP.gnExisteBala := 1;
                   loP.gnTipo  := gnBalaUsuario;
                   loP.gnAncho := 5;
                   loP.gnAlto  := 10;
                   loP.gnColor := clBlue;

                   loP.gnX     := (poUser.gnAncho-loP.gnAncho) div 2 + poUser.gnX;
                   loP.gnY     :=  poUser.gnY - loP.gnAlto;

                   loP.gnRetardo := 50;
                   loP.gnHora    := GetTickCount;
                   Dibujar(loP);
                   poCola.Meter(loP);
                   sndPlaySound('Recursos/disparo lases.wav',SND_ASYNC);
                 end;
   end;
end;




(* Metodo para Cargar el juego
   @method  InitJuego()
   @author  Jos? Fernando O?a Carrasco
   @fecha   13-01-2022
*)
procedure TForm1.InitJuego;
var
loN:PCB;
lnIndice,lnIncrementoA,lnIndiceJ:integer;
begin
   sndPlaySound(nil,SND_ASYNC);//Apagar Musica Intro
   cls();                      //Borrar el formulario
   poCola.Init();                   //Vaciar la cola

   MediaPlayer1.FileName := 'Recursos/lavender-town.wav';
   MediaPlayer1.Open;
   MediaPlayer1.Play;          //Iniciar Musica Juego

   pnSentido := 5;

   for lnIndice := 1 to 3 do
   begin
       lnIncrementoA := 140;
       for lnIndiceJ := 1 to 5 do
       begin
           loN.gnCambio := 0;
           loN.gnTiempo := 0.0005;
           loN.gnDureza := 1;
           loN.gnTipo   := gnNave;
           loN.gnAncho  := 30;
           loN.gnAlto   := 30;
           loN.gnColor  := clPurple;
           loN.gnX      := ClientWidth - lnIncrementoA;
           loN.gnY      := 5+(loN.gnAlto+20)*(lnIndice-1);
           loN.gnHora   := GetTickCount;
           loN.gnRetardo:= 100;

           loN.gnXDinamico := loN.gnX;
           loN.gnYDinamico := loN.gnY;
           loN.gnEsdinamico := 0;

           Dibujar(loN);
           poCola.Meter(loN);
           lnIncrementoA := lnIncrementoA +100;
       end;
   end;

   poUser.gnAncho := 30;                                      //Tanque Usuario.
   poUser.gnAlto  := 30;
   poUser.gnColor := clGreen;
   poUser.gnX     := (ClientWidth - poUser.gnAncho) div 2;
   poUser.gnY     := MaxY - poUser.gnAlto - 1;
   Dibujar(poUser);

   CicloJuego();
   MediaPlayer1.Stop;                                      //Parar Musica Principal

   if (pnEstado = 2) then begin
      sndPlaySound('Recursos/Ganaste.wav',SND_ASYNC);      //Musica Ganador
      ShowMessage('Felicidades Ganaste');
   end
   else begin
      sndPlaySound('Recursos/MisionFallida.wav',SND_ASYNC);//Musica Perdedor
      ShowMessage('Perdiste Suerte la Proxima');
   end;

    Application.Terminate;
end;




(* Metodo para Ejecutar el ciclo del juego
   @method  CicloJuego()
   @author  Jos? Fernando O?a Carrasco
   @fecha   13-01-2022
*)
procedure TForm1.CicloJuego;
begin
    pnEstado := 0;
    while (pnEstado = 0) do
      begin
        PlanificadorRR();
        Application.ProcessMessages();//Para que se procesen eventos (click, teclas, etc)
      end;
end;




(* Metodo que atiende a los procesos de la Cola
   @method  PlanificadorRR()
   @author  Jos? Fernando O?a Carrasco
   @fecha   13-01-2022
*)
procedure TForm1.PlanificadorRR;
var
loPRUN:PCB;
begin
   loPRUN := poCola.Sacar();

   if (loPRUN.gnX>=MaxX-30) and (loPRUN.gnTipo = gnNave) then
       pnSentido := -5;

   if (loPRUN.gnX<=0) and (loPRUN.gnTipo = gnNave) then
       pnSentido := 5;

   if (loPRUN.gnHora + loPRUN.gnRetardo > GetTickCount) then
     poCola.Meter(loPRUN)
   else
      case loPRUN.gnTipo of
         gnNave  : MoverNave(loPRUN);
         gnBalaUsuario : MoverBalaU(loPRUN);
         gnBalaNave : MoverBalaN(loPRUN);
      end;
end;




(* Metodo que hace que un punto A(x1,y1) llegue a un punto B(x2,y2)
   @method  Interpolar()
   @author  Jos? Fernando O?a Carrasco
   @fecha   13-01-2022
   @param   x1,x2:Integer; vel:real
   @return  integer incremento de x1
*)
function TForm1.Interpolar(tnX1,tnX2:Integer; tnVel:real):Integer;
begin
    result := ceil((tnX2-tnX1)*tnVel+tnX1);
end;




(* Metodo que se encargar de movilizar las Naves
   @method  MoverNave()
   @author  Jos? Fernando O?a Carrasco
   @fecha   13-01-2022
   @param   toPRUN:PCB
*)
procedure TForm1.MoverNave(toPRUN: PCB);
var
loPCB:PCB;
lnXAux,lnYAux:integer;
begin
  if (toPRUN.gnEsdinamico = 1) then
  begin

     if (toPRUN.gnCambio = 1) then begin
         Borrar(toPRUN);
         toPRUN.gnCambio := 0;
         sndPlaySound(nil,SND_ASYNC);
         sndPlaySound('Recursos/Nuevo_Dinamico.wav',SND_ASYNC);
     end;

     Borrar2(toPRUN);
     toPRUN.gnTiempo    := toPRUN.gnTiempo + 0.0005;
     toPRUN.gnXDinamico := Interpolar(toPRUN.gnXDinamico,poUser.gnX,toPRUN.gnTiempo);
     toPRUN.gnYDinamico := Interpolar(toPRUN.gnYDinamico,poUser.gnY,toPRUN.gnTiempo);
     if (colision(toPRUN,poUser)) then
         pnEstado := 1;

     Dibujar2(toPRUN);
     lnXAux := toPRUN.gnXDinamico;
     lnYAux := toPRUN.gnYDinamico;
  end else
  begin
     Borrar(toPRUN);
     toPRUN.gnX := toPRUN.gnX + pnSentido;
     if (colision(toPRUN,poUser)) then
          pnEstado := 1;
      Dibujar(toPRUN);
      lnXAux := toPRUN.gnX;
      lnYAux := toPRUN.gnY;
  end;

  toPRUN.gnHora := GetTickCount;
  poCola.Meter(toPRUN);

  if Random(80)= 0 then                    //Disparar crear un proceso BALAN
      begin
         loPCB.gnExisteBala := 1;
         loPCB.gnTipo  := gnBalaNave;
         loPCB.gnAncho := 5;
         loPCB.gnAlto  := 10;
         loPCB.gnColor := clblack;

         loPCB.gnX :=  (toPRUN.gnAncho-loPCB.gnAncho) div 2 + lnXAux;
         loPCB.gnY :=  lnYAux + toPRUN.gnAlto + loPCB.gnAlto;

         loPCB.gnRetardo := 50;
         loPCB.gnHora    := GetTickCount;
         Dibujar(loPCB);

         loPCB.gnEsDinamico := 0;
         poCola.Meter(loPCB);
      end;
end;



(* Metodo retorna true si hay colision entre dos Objetos
   y false caso contrario
   @method  colision()
   @author  Jos? Fernando O?a Carrasco
   @fecha   13-01-2022
   @param   toObjeto1,toObjeto2:PCB
   @return  Boolean true o false
*)
function TForm1.colision(toObjeto1,toObjeto2:PCB):boolean;
var
lnX,lnY:integer;
begin
    if (toObjeto1.gnEsDinamico = 1) then
    begin
        lnX := toObjeto1.gnXDinamico;
        lnY := toObjeto1.gnYDinamico;
    end else begin
        lnX := toObjeto1.gnX;
        lnY := toObjeto1.gnY;
    end;

    if(lnX+toObjeto1.gnAncho>=toObjeto2.gnX) and
      (lnX<=toObjeto2.gnX+toObjeto2.gnAncho)    and
      (lnY<=toObjeto2.gnY+toObjeto2.gnAlto)     and
      (lnY+toObjeto1.gnAlto>=toObjeto2.gnY)     then
        Result := true
    else
        Result := false;
end;



(* Metodo que mueve las balas de las Naves
   @method  MoverBalaN()
   @author  Jos? Fernando O?a Carrasco
   @fecha   13-01-2022
   @param   toPRUN: PCB
   @return  Boolean true o false
*)
procedure TForm1.MoverBalaN(toPRUN: PCB);
begin                                    //Algoritmo para mover la bala de la nave (BALAN)
  Borrar(toPRUN);
  toPRUN.gnY := toPRUN.gnY + 5;                  //Mover la BALAN 5 px (p?xeles) hacia abajo.

  if (colision(toPRUN,poUser)) then
      pnEstado := 1;                       //Rompemos el ciclo Murio el user

  ColibalasUser(toPRUN);                   //PRUN.existeBala retorna 0 si ya no existe
  if (toPRUN.gnY < MaxY) and (toPRUN.gnExisteBala = 1) then//SI (la BALAN a?n no toc? el suelo)
    begin
      toPRUN.gnHora := GetTickCount;
      Dibujar(toPRUN);
      poCola.Meter(toPRUN);
    end;
end;



(* Metodo retorna true si hay colision entre las Balas del User
   y las Naves, caso contrario false.
   @method  ColiNaves()
   @author  Jos? Fernando O?a Carrasco
   @fecha   13-01-2022
   @param   Balin:PCB
   @return  Boolean true o false
*)
function TForm1.ColiNaves(toBalin:PCB):Boolean;
var
loCopia:PCB;
lnIndice,XAux,YAux:integer;
llColisiono:Boolean;
begin
     llColisiono := false;
     for lnIndice := 1 to poCola.Length do
     begin
        loCopia := poCola.Sacar();
        if (loCopia.gnTipo = gnNave) then
        begin
            if (colisionBalaUConNaves(toBalin,loCopia))  then
               begin
                 if (poCola.Cant(gnNave) = 0) and (loCopia.gnDureza = 3) then
                        pnEstado := 2;                             // Murieron Todas las Naves = 2

                 if (loCopia.gnDureza = 3) then begin
                     if (loCopia.gnEsDinamico = 1) then
                        Borrar2(loCopia)
                     else
                        Borrar(loCopia);
                 end else
                 begin
                     inc(loCopia.gnDureza);
                     if (loCopia.gnDureza = 2) then
                         loCopia.gnColor := clMaroon
                     else
                         loCopia.gnColor := clRed;
                     poCola.Meter(loCopia);
                 end;
                 llColisiono := true;
               end else
                   poCola.Meter(loCopia);
        end else
            poCola.Meter(loCopia);
     end;
    Result := llColisiono;
end;




(* Metodo retorna true si hay colision entre las Balas del User
   y las balas de las Naves, caso contrario false.
   @method  ColiBalasNaves()
   @author  Jos? Fernando O?a Carrasco
   @fecha   13-01-2022
   @param   BalaUser:PCB
   @return  Boolean true o false
*)
function TForm1.ColiBalasNaves( var toBalaUser:PCB):Boolean;
var
loCopia:PCB;
lnIndice:integer;
llColisiono:Boolean;
begin
     llColisiono := false;
     for lnIndice := 1 to poCola.Length do
     begin
        loCopia := poCola.Sacar();
        if (loCopia.gnTipo = gnBalaNave) then
        begin
            if (colision(toBalaUser,loCopia))  then
               begin
                    toBalaUser.gnExisteBala := 0;
                    Borrar(loCopia);
                    llColisiono := true;
               end else
                 poCola.Meter(loCopia);
        end else
           poCola.Meter(loCopia);
     end;
    Result := llColisiono;
end;




(* Metodo retorna true si hay colision entre las Balas de las Naves
   y las balas del User, caso contrario false.
   @method  ColibalasUser()
   @author  Jos? Fernando O?a Carrasco
   @fecha   13-01-2022
   @param   BalaUser:PCB
   @return  Boolean true o false
*)
procedure TForm1.ColibalasUser( var toBalaNave:PCB);
var
loCopia:PCB;
lnIndice:integer;
begin
     for lnIndice := 1 to poCola.Length do
     begin
        loCopia := poCola.Sacar();
        if (loCopia.gnTipo = gnBalaUsuario) then
        begin
            if(colision(toBalaNave,loCopia))  then
               begin
                    toBalaNave.gnExisteBala := 0;
                    Borrar(loCopia);
               end else
                    poCola.Meter(loCopia);
        end else
            poCola.Meter(loCopia);
     end;
end;




(* Metodo que cambia el estado si hay colision entre el User
   y las Naves, caso contrario false.
   @method  VerificarColi2()
   @author  Jos? Fernando O?a Carrasco
   @fecha   13-01-2022
*)
procedure TForm1.VerificarColi2;
var
loCopia:PCB;
lnIndice:integer;
begin

     for lnIndice := 1 to poCola.Length do
     begin
        loCopia := poCola.Sacar();
        if (loCopia.gnTipo = gnNave) then
        begin
            if (loCopia.gnEsDinamico = 1) then begin
                if (poUser.gnX<=loCopia.gnXDinamico+loCopia.gnAncho)   and
                   (poUser.gnX+poUser.gnAncho>=loCopia.gnXDinamico) and
                   (poUser.gnY<=loCopia.gnYDinamico+loCopia.gnAlto)    and
                   (poUser.gnY+poUser.gnAlto>=loCopia.gnYDinamico)  then
                   begin
                     pnEstado := 1;
                   end;
            end else
              if (poUser.gnX<=loCopia.gnX+loCopia.gnAncho)   and
                 (poUser.gnX+poUser.gnAncho>=loCopia.gnX) and
                 (poUser.gnY<=loCopia.gnY+loCopia.gnAlto)    and
                 (poUser.gnY+poUser.gnAlto>=loCopia.gnY)  then
                 begin
                    pnEstado := 1;
                 end;
        end;
        poCola.Meter(loCopia);
     end;
end;




(* Metodo retorna true si hay colision entre las Balas del User
   con las Naves, caso contrario false.
   @method  colisionBalaUConNaves()
   @author  Jos? Fernando O?a Carrasco
   @fecha   13-01-2022
   @param   BalaUser:PCB
   @return  Boolean true o false
*)
function TForm1.colisionBalaUConNaves(toObjeto1,toObjeto2:PCB):boolean;
var
lnXAux,lnYAux:integer;
begin
   if (toObjeto2.gnEsDinamico = 1) then
   begin
      lnXAux := toObjeto2.gnXDinamico;
      lnYAux := toObjeto2.gnYDinamico;
   end else begin
      lnXAux := toObjeto2.gnX;
      lnYAux := toObjeto2.gnY;
   end;

   if (toObjeto1.gnX<=lnXAux+toObjeto2.gnAncho) and
      (toObjeto1.gnX+toObjeto1.gnAncho>=lnXAux) and
      (toObjeto1.gnY<=lnYAux+toObjeto2.gnalto)  and
      (toObjeto1.gnY+toObjeto1.gnAlto>=lnYAux)  then
       Result := true
   else
       Result := false;
end;



(* Metodo se encarga de Mover las balas del User
   @method  MoverBalaU()
   @author  Jos? Fernando O?a Carrasco
   @fecha   13-01-2022
   @param   BalaUser:PCB
*)
procedure TForm1.MoverBalaU(toPRUN: PCB);
var
llcolisiono,llNoHayDinamico:Boolean;
loNave:PCB;
lnIndice:Integer;
begin
  Borrar(toPRUN);
  toPRUN.gnY := toPRUN.gnY - 5;
  ColiBalasNaves(toPRUN);            //retorna PRUN.existeBala 0 si choco con una bala Nave
  llcolisiono := not (ColiNaves(toPRUN));      //la balaU no choc? con una Nave?

  if (toPRUN.gnY > 0) and (llcolisiono) and (toPRUN.gnExisteBala = 1) then  //IF (la BALAU a?n no toc? el techo)
  begin
     toPRUN.gnHora := GetTickCount;
     Dibujar(toPRUN);
     poCola.Meter(toPRUN);
  end;

  llNoHayDinamico := true;
  if (poCola.CantDinamicos(1) = 0) then //0
      for lnIndice := 1 to poCola.Length do begin
          loNave := poCola.Sacar();
          if (loNave.gnTipo = gnNave) and (llNoHayDinamico) then begin
              if (loNave.gnEsDinamico = 0) then begin
                  loNave.gnEsDinamico := 1;
                  llNoHayDinamico := false;
                  loNave.gnCambio := 1;
                  loNave.gnXDinamico := loNave.gnX;
                  loNave.gnYDinamico := loNave.gnY;
              end;
          end;
            poCola.Meter(loNave);
      end;
end;




(* Metodo para Manipular los "Gr?ficos". Borra el Canvas del Form
   @method  cls()
   @author  Jos? Fernando O?a Carrasco
   @fecha   13-01-2022
*)
procedure TForm1.cls;
begin
  Rectangulo(0,0,ClientWidth, ClientHeight, SELF.Color);
end;




(* Metodo para Manipular los "Gr?ficos". Dibuja al PCB como un rectangulo en la pantalla.
   @method  Dibujar()
   @author  Jos? Fernando O?a Carrasco
   @fecha   13-01-2022
   @param   toPCB: PCB
*)
procedure TForm1.Dibujar(toPCB: PCB);
begin
  Rectangulo(toPCB.gnX, toPCB.gnY, toPCB.gnAncho, toPCB.gnAlto, toPCB.gnColor);
end;



(* Metodo para Manipular los "Gr?ficos".Dibuja al PCB Dinamico como un rectangulo en la pantalla.
   @method  Dibujar2()
   @author  Jos? Fernando O?a Carrasco
   @fecha   13-01-2022
   @param   toPCB: PCB
*)
procedure TForm1.Dibujar2(toPCB: PCB);
begin
  Rectangulo(toPCB.gnXDinamico, toPCB.gnYDinamico, toPCB.gnAncho, toPCB.gnAlto, toPCB.gnColor);
end;




(* Metodo para Manipular los "Gr?ficos".//Dibuja al PCB como un rectangulo en la pantalla,
   del mismo color del Form.
   @method  Borrar()
   @author  Jos? Fernando O?a Carrasco
   @fecha   13-01-2022
   @param   toPCB: PCB
*)
procedure TForm1.Borrar(toPCB: PCB);
begin
   Rectangulo(toPCB.gnX, toPCB.gnY, toPCB.gnAncho, toPCB.gnAlto, SELF.Color);
end;




(* Metodo para Manipular los "Gr?ficos".Dibuja un rectangulo con esquina superior Izq en (x,y)..
   @method  Rectangulo()
   @author  Jos? Fernando O?a Carrasco
   @fecha   13-01-2022
   @param   tnX, tnY, tnAncho, tnAlto, Color: Integer
*)
procedure TForm1.Rectangulo(tnX, tnY, tnAncho, tnAlto, Color: Integer);
begin
  Canvas.Pen.Color := Color;
  Canvas.Brush.Color := Color;
  Canvas.Rectangle(tnX, tnY, tnX+tnAncho-1, tnY+tnAlto-1);
end;



(* Metodo que dibuja al PCB Dinamico como un rectangulo en la pantalla, del mismo color
   del Form.
   @method  Borrar2()
   @author  Jos? Fernando O?a Carrasco
   @fecha   13-01-2022
   @param   toPCB: PCB
*)
procedure TForm1.Borrar2(toPCB: PCB);
begin
  Rectangulo(toPCB.gnXDinamico, toPCB.gnYDinamico, toPCB.gnAncho, toPCB.gnAlto, SELF.Color);
end;




(* Metodo que devuelve el ancho maximo del Form.
   @method  MaxX()
   @author  Jos? Fernando O?a Carrasco
   @fecha   13-01-2022
   @return max ancho
*)
function TForm1.MaxX: Integer;
begin
  RESULT := ClientWidth-1;
end;



(* Metodo que devuelve el alto maximo del Form.
   @method  MaxY()
   @author  Jos? Fernando O?a Carrasco
   @fecha   13-01-2022
   @return max altura
*)
function TForm1.MaxY: Integer;
begin
  RESULT := ClientHeight-1;
end;

END.
