UNIT uCola;


INTERFACE
uses Graphics;
CONST
  gnNave  = 0;
  gnBalaUsuario = 1;
  gnBalaNave = 2;

TYPE
  PCB = RECORD
          gnPid  : Integer;
          gnDir  : Integer;
          gnTipo : Integer;    //NAVE, BALAU, BALAN.
          gnX, gnY, gnAncho, gnAlto, gnColor: Integer;
          gnHora, gnRetardo: Cardinal;
          gnDureza :Integer;
          gnXDinamico,gnYDinamico : Integer;
          gnEsDinamico:Integer; // 0 = no y 1 = si
          gnSentidoX,gnSentidoY:Integer;
          gnTrayectoria:Integer; // camino 0 o camino 1
          gnExisteBala:Integer; // 0 no existe 1 si existe
          gnTiempo:real;
          gnCambio:Integer; // 0 = no cambio;  1 = si cambio  a dinamico
        END;


CONST
  MAX = 200;

TYPE
  Cola = class
    private
      paVector : Array[1..MAX] of PCB;   //Implementacion: Cola Circular
      pnIndiceFinal, pnIndiceInicial : Integer;

      function next(tnPosicion : Integer) : Integer;

 public
    constructor Create;         //Construye una cola vac?a.
    procedure Init;             //Inicializa la cola.  Es decir, pone a la cola vac?a.
    function Vacia:Boolean;     //Devuelve true si y solo si la cola est? vac?a.
    function Llena:Boolean;     //Devuelve true si y solo si la cola est? llena (ya no se pueden insertar m?s PCB's).
    function Length:Integer;    //Devuelve la cantidad de elementos de la cola.
    procedure Meter(toPCB:PCB); //Inserta P a la cola.
    function Sacar:PCB;         //Saca un PCB de la cola.
    function Cant(tnTipo:Integer):Integer;//DepaVectoruelve la cantidad de elementos encolados, que tienen el Tipo especificado.
                                        //e.g. Cant(BALAU) devuelve la cantidad de PCB's encolados, cuyo Tipo=BALAU
    function CantDinamicos(tnTipo:Integer):Integer;
  end;



IMPLEMENTATION
uses SysUtils;



(* Metodo que crea la instacia cola
   @method  Create()
   @author  Jos? Fernando O?a Carrasco
   @fecha   13-01-2022
*)
constructor Cola.Create;
begin
  Init();
end;



(* Metodo que inicializa la cola
   @method  Init()
   @author  Jos? Fernando O?a Carrasco
   @fecha   13-01-2022
*)
procedure Cola.Init;
begin
  pnIndiceInicial := 0;
end;




(* Metodo que devuelve true si la Cola esta vacia, caso contrario false
   @method  Vacia()
   @author  Jos? Fernando O?a Carrasco
   @fecha   13-01-2022
   @return Boolean true o false
*)
function Cola.Vacia: Boolean;
begin
  Result := (pnIndiceInicial = 0);
end;


(* Metodo que devuelve true si la Cola esta llena, caso contrario false
   @method  Llena()
   @author  Jos? Fernando O?a Carrasco
   @fecha   13-01-2022
   @return Boolean true o false
*)
function Cola.Llena: Boolean;
begin
  Result := (Length() = MAX);
end;



(* Metodo que devuelve la cantidad de PCB que hay en la Cola
   @method  Length()
   @author  Jos? Fernando O?a Carrasco
   @fecha   13-01-2022
   @return cantidad de PCB's
*)
function Cola.Length: Integer;
begin
  if (pnIndiceInicial=0) then
     RESULT := 0
  else
    if (pnIndiceFinal <= pnIndiceInicial) then
       RESULT := pnIndiceInicial-pnIndiceFinal+1
    else
       RESULT := pnIndiceInicial + (MAX-pnIndiceFinal+1);
end;




(* Metodo que inserta el PCB en la Cola
   @method  Meter()
   @author  Jos? Fernando O?a Carrasco
   @fecha   13-01-2022
   @param   toPCB: PCB
*)
procedure Cola.Meter(toPCB: PCB);
begin
  if Llena() then
     raise Exception.Create('Cola.Meter: Cola llena.');
  if (pnIndiceInicial = 0) then
  begin  //Primera inserci?n.
       pnIndiceInicial:=1;  pnIndiceFinal:=1;
  end
  else
    pnIndiceInicial := next(pnIndiceInicial);
  paVector[pnIndiceInicial] := toPCB;
end;




(* Metodo que devuelve el PCB de la Cola
   @method  Sacar()
   @author  Jos? Fernando O?a Carrasco
   @fecha   13-01-2022
   @return  PCB  objeto
*)
function Cola.Sacar: PCB;
begin
  if Vacia() then
     raise Exception.Create('Cola.Sacar: Cola vac?a.');
  RESULT := paVector[pnIndiceFinal];
  if (pnIndiceFinal=pnIndiceInicial) then   //Se est? quitando el ?nico elemento...
     Init()                                 //...dar condici?n de vac?o.
  else
    pnIndiceFinal := next(pnIndiceFinal);
end;




(* Metodo que devuelve la cantidad de elementos encolados, que tienen el Tipo especificado.
   @method  Cant()
   @author  Jos? Fernando O?a Carrasco
   @fecha   13-01-2022
   @param   tnTipo: Integer
   @return cantidad de un tipo especifico
*)
function Cola.Cant(tnTipo: Integer): Integer;
var
lnIndice,lnPosicion,lnContador:integer;
begin
  lnContador := 0;
  lnPosicion := pnIndiceFinal;
  for lnIndice:=1 to Length() do
  begin
    if paVector[lnPosicion].gnTipo = tnTipo then
       Inc(lnContador);
    lnPosicion := next(lnPosicion);
  end;
  Result := lnContador;
end;




(* Metodo que devuelve la cantidad de elementos dinamicos encolados.
   @method  CantDinamicos()
   @author  Jos? Fernando O?a Carrasco
   @fecha   13-01-2022
   @param   tnTipo: Integer
   @return cantidad de dinamicos
*)
function Cola.CantDinamicos(tnTipo: Integer): Integer;
var
lnIndice,lnPosicion,lnContador:integer;
begin
  lnContador := 0;
  lnPosicion := pnIndiceFinal;
  for lnIndice:=1 to Length() do
  begin
    if paVector[lnPosicion].gnEsdinamico = tnTipo then
       Inc(lnContador);
    lnPosicion := next(lnPosicion);
  end;
  Result := lnContador;
end;



(* Metodo devuelve el ?ndice siguiente, circularmente hablando.
   @method  next()
   @author  Jos? Fernando O?a Carrasco
   @fecha   13-01-2022
   @param   tnPosicion: Integer
   @return Indice siguiente
*)
function Cola.next(tnPosicion: Integer): Integer;
begin
  Result := (tnPosicion mod MAX) + 1;
end;

END.
