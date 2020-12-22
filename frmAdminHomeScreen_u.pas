// ##################################
// ######     IT PAT 2018     #######
// ######      GrowCery       #######
// ######  Tiaan van der Riel #######
// ##################################
unit frmAdminHomeScreen_u;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, pngimage, ExtCtrls, StdCtrls, clsDisplayUserInfo_u;

type
  TfrmAdminHomeScreen = class(TForm)
    btnVeiwAnalytics: TButton;
    btnVeiwStock: TButton;
    btnCreateNewAccount: TButton;
    btnDeleteAnAccount: TButton;
    btnLogOut: TButton;
    imgBackground: TImage;
    imgWelcomeHeading: TImage;
    lblLoggedOnUser: TLabel;
    lblAdminInfo: TLabel;
    imgDarkLogo: TImage;
    btnVeiwTransactions: TButton;
    btnHelp: TButton;
    procedure FormActivate(Sender: TObject);
    procedure btnLogOutClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnVeiwAnalyticsClick(Sender: TObject);
    procedure btnVeiwStockClick(Sender: TObject);
    procedure btnCreateNewAccountClick(Sender: TObject);
    procedure btnDeleteAnAccountClick(Sender: TObject);
    procedure btnVeiwTransactionsClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
  private
    { Private declarations }
    objDisplayUserInfo: TDisplayUserInfo;
  public
    { Public declarations }
    sLoggedOnUser: string;
  end;

var
  frmAdminHomeScreen: TfrmAdminHomeScreen;

implementation

uses
  frmLogIn_u, frmAnalytics_u, frmStock_u, frmCreateNewAccount_u,
  frmDeleteAnAccount_u, frmTransactions_u;
{$R *.dfm}

/// ======================== Form Activate ====================================
procedure TfrmAdminHomeScreen.FormActivate(Sender: TObject);
begin
  { The function of this piece of code is to create the object objDisplayUserInfo,
  this object will make use of the class clsDisplayUserInfo, as the variable
  sLoggedOnUser, to find and return all of the relevant information regarding the
  currently logged in user, and display that information in the top left
  * also used by frmTellerHomeScreeen }
  sLoggedOnUser := frmLogIn.sLoggedOnUser;
  objDisplayUserInfo := TDisplayUserInfo.Create(sLoggedOnUser);
  lblAdminInfo.Caption := objDisplayUserInfo.ToString;
  objDisplayUserInfo.Free;
end;

/// =================== Create A New Account Button ===========================
procedure TfrmAdminHomeScreen.btnCreateNewAccountClick(Sender: TObject);
begin
  frmAdminHomeScreen.Hide;
  frmCreateNewAccount.ShowModal;
end;

procedure TfrmAdminHomeScreen.btnDeleteAnAccountClick(Sender: TObject);
begin
  frmAdminHomeScreen.Hide;
  frmDeleteAnAccount.ShowModal;
end;

/// ======================== Veiw Analytics Button ============================
procedure TfrmAdminHomeScreen.btnVeiwAnalyticsClick(Sender: TObject);
begin
  frmAdminHomeScreen.Hide;
  frmAnalytics.ShowModal;
end;

/// ======================== Veiw Stock Button ================================
procedure TfrmAdminHomeScreen.btnVeiwStockClick(Sender: TObject);
begin
  frmAdminHomeScreen.Hide;
  frmStock.ShowModal;
end;

/// ===================== Veiw Transactions Button ============================
procedure TfrmAdminHomeScreen.btnVeiwTransactionsClick(Sender: TObject);
begin
  frmAdminHomeScreen.Hide;
  frmTransactions.ShowModal;
end;

/// ======================== Form Close =======================================
procedure TfrmAdminHomeScreen.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  /// Log the user out
  ShowMessage('You have been logged out of your account.');
end;

/// ============================ Help Button ==================================
procedure TfrmAdminHomeScreen.btnHelpClick(Sender: TObject);
var
  tHelp: TextFile;
  sLine: string;
  sMessage: string;

begin
  sMessage := '========================================';
  AssignFile(tHelp, 'Help_AdminHomeScreen.txt');

  try { Code that checks to see if the file about the sponsors can be opened
      - displays error if not }
    reset(tHelp);
  Except
    ShowMessage('ERROR: The help file could not be opened.');
    Exit;
  end;

  while NOT EOF(tHelp) do
  begin
    Readln(tHelp, sLine);
    sMessage := sMessage + #13 + sLine;

  end;
  sMessage := sMessage + #13 + '========================================';
  CloseFile(tHelp);
  ShowMessage(sMessage);
end;

/// ======================== Log Out Button ====================================
procedure TfrmAdminHomeScreen.btnLogOutClick(Sender: TObject);
begin
  if MessageDlg(' Are you sure you want to log out of your account ?',
    mtConfirmation, [mbYes, mbCancel], 0) = mrYes then
  begin
    frmAdminHomeScreen.Close;
  end
  else
    Exit
end;

end.
