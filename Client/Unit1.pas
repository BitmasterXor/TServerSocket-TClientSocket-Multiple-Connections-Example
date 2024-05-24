unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.Win.ScktComp;

type
  TForm1 = class(TForm)
    Button1: TButton;
    ClientSocket1: TClientSocket;
    Edit1: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure ClientSocket1Connect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ClientSocket1Read(Sender: TObject; Socket: TCustomWinSocket);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
//This button will connect the client socket to the server socket...
procedure TForm1.Button1Click(Sender: TObject);
begin
self.ClientSocket1.Host:='localhost'; //setting up the HOST IP address to connect the client to...
self.ClientSocket1.Port:= 3434; //setting the PORT number on which the client socket will connect on to the server...
self.ClientSocket1.Open; //Telling the client to try and go ahead and connect to the server socket...
end;

//The following happens when the client socket connects successfully to the Server socket...
procedure TForm1.ClientSocket1Connect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
self.ClientSocket1.Socket.SendText('NewCon|' + self.Edit1.Text); // So when the client successfully connects it sends the NewCon command and its Unique ID to the server...
end;

//The following code executes every single time the client socket recieves data from the Server...
procedure TForm1.ClientSocket1Read(Sender: TObject;
  Socket: TCustomWinSocket);
begin
self.Caption:=socket.ReceiveText;// if we recieve any text from the server we just change the clients form caption to whatever text message we recived from the server...
end;

end.
