// ##################################
// ######     IT PAT 2018     #######
// ######      GrowCery       #######
// ######  Tiaan van der Riel #######
// ##################################
unit frmGrowCery_u;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, pngimage, ExtCtrls, StdCtrls;

type
  TfrmWelcome = class(TForm)
    imgWelcomeBackground: TImage;
    btnContinue: TButton;
    procedure btnContinueClick(Sender: TObject);
    procedure FormShow(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmWelcome: TfrmWelcome;

implementation

uses
  frmLogIn_u, dmDatabase_u;
{$R *.dfm}
/// ============================ Form Gets Shown ==============================
procedure TfrmWelcome.FormShow(Sender: TObject);
begin
  btnContinue.Left := 543;
  btnContinue.Top := 561;
end;

/// ======================== Continue Button Clicked ==========================
procedure TfrmWelcome.btnContinueClick(Sender: TObject);
begin
  frmWelcome.Hide;
  frmLogIn.ShowModal;
end;

end.
