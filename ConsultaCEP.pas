unit ConsultaCEP;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  Vcl.Mask,
  VazMaskEdit,
  VazEdit,
  IdHTTP,
  IdSSLOpenSSL,
  System.Json,
  Vcl.Buttons;

type
  TForm1 = class( TForm )
    EdRua: TVazEdit;
    EdCEP: TVazMaskEdit;
    Label1: TLabel;
    Panel1: TPanel;
    EdBairro: TVazEdit;
    EdCidade: TVazEdit;
    EdUF: TVazEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    SpeedButton1: TSpeedButton;
    Panel2: TPanel;
    Panel3: TPanel;
    SpeedButton2: TSpeedButton;
    Image1: TImage;
    procedure EdCEPExit( Sender: TObject );
    procedure FormShow( Sender: TObject );
    procedure SpeedButton2Click( Sender: TObject );
  private
    { Private declarations }
    function GetCEP( PCEP: string ): TJSONObject;
    procedure CarregaCEP( JSON: TJSONObject );
    procedure LimparObj( LimparCEP: Boolean = True );
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

{ TForm1 }

procedure TForm1.CarregaCEP( JSON: TJSONObject );
begin
  EdRua.Text    := JSON.Get( 'logradouro' ).JsonValue.Value;
  EdCidade.Text := UpperCase( JSON.Get( 'localidade' ).JsonValue.Value );
  EdBairro.Text := JSON.Get( 'bairro' ).JsonValue.Value;
  EdUF.Text     := JSON.Get( 'uf' ).JsonValue.Value;

end;

procedure TForm1.EdCEPExit( Sender: TObject );
var
  LJsonObj: TJSONObject;
  Str: string;
begin
  if Length( EdCEP.Text ) <> 8 then
  begin
    ShowMessage( 'CEP incorreto' );
    LimparObj( True );
    Image1.Picture.LoadFromFile( 'C:\Users\Vaz\OneDrive\Documentos\Testes\Consulta CEP\icon\cancelar.bmp' );
    EdCEP.SetFocus;
    Exit;
  end;

  LJsonObj := GetCEP( EdCEP.Text );

  if LJsonObj <> nil then
  begin
    if LJsonObj.Get( 'erro' ) = nil then
    begin
      CarregaCep( LJsonObj );
      Image1.Picture.LoadFromFile( 'C:\Users\Vaz\OneDrive\Documentos\Testes\Consulta CEP\icon\marca-de-verificacao.bmp' );
    end
    else
    begin
      ShowMessage( 'CEP inv�lido ou n�o encontrado' );
      LimparObj( True );
      Image1.Picture.LoadFromFile( 'C:\Users\Vaz\OneDrive\Documentos\Testes\Consulta CEP\icon\cancelar.bmp' );
      EdCEP.SetFocus;
      Exit;
    end;
  end;
end;

procedure TForm1.FormShow( Sender: TObject );
begin
  EdCEP.SetFocus;

end;

function TForm1.GetCEP( PCEP: string ): TJSONObject;
var
  _idHTTP: TIdHTTP;
  _idSSlHandler: TIdSSLIOHandlerSocketOpenSSL;
  _ssRetorno: TStringStream;
  LJsonObj: TJSONObject;
begin
  try
    _idHTTP                              := TIdHTTP.Create;
    _idSSlHandler                        := TIdSSLIOHandlerSocketOpenSSL.Create;
    _idHTTP.IOHandler                    := _idSSlHandler;
    _idSSlHandler.SSLOptions.SSLVersions := [ SslvTLSv1, SslvTLSv1_1, SslvTLSv1_2 ];

    _ssRetorno := TStringStream.Create( '' );

    _idHTTP.Get( 'https://viacep.com.br/ws/' + PCEP + '/json', _ssRetorno );

    if ( _idHTTP.ResponseCode = 200 ) and
                ( not( Utf8ToAnsi( _ssRetorno.DataString ) = '{'#$A' "erro": true'#$A'}' ) ) then
      Result := TJSONObject.ParseJSONValue( TEncoding.ASCII.GetBytes( Utf8ToAnsi( _ssRetorno.DataString ) ), 0 ) as TJSONObject;

  finally
    FreeAndNil( _idHTTP );
    FreeAndNil( _idSSlHandler );
    _ssRetorno.Destroy;
  end;
end;

procedure TForm1.LimparObj( LimparCEP: Boolean );
begin
  EdRua.Clear;
  EdCidade.Clear;
  EdBairro.Clear;
  EdUF.Clear;
end;

procedure TForm1.SpeedButton2Click( Sender: TObject );
begin
  Close;
end;

end.
