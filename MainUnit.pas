unit MainUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  System.JSON;

type
  TMainForm = class(TForm)
    DataMemo: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
    json:TJSONObject;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
var
  str,line:string;
  filename:string;
  f:TextFile;
  i:integer;
  arr,pictures:TJSONArray;
  shopSku,status:string;
begin
filename:=ExtractFilePath(Application.ExeName)+'/IncomingData.json';
if FileExists(filename) then begin
  // Reading JSON data from file
  AssignFile(f,filename);
  Reset(f);
  str:='';
  while (not EOF(f)) do begin
    Readln(f, line);
    str:=str+line;
  end;
  // Creating JSON object, and parse data from string variable
  json:=TJSONObject.ParseJSONValue(str) as TJSONObject;
  if json.TryGetValue('result.offerMappingEntries',arr) and (arr.Count>0) then
    for i:=0 to Pred(arr.Count) do begin
      if arr.Items[i].TryGetValue('offer.shopSku',shopSku)
         and arr.Items[i].TryGetValue('offer.processingState.status',status)
         and arr.Items[i].TryGetValue('offer.pictures',pictures) then
         DataMemo.Lines.Add(shopSku+'   '+status+'   '+IntToStr(pictures.Count));
    end;
  end;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
json.Free;
end;

end.
