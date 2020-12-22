// ##################################
// ######     IT PAT 2018     #######
// ######      GrowCery       #######
// ######  Tiaan van der Riel #######
// ##################################
unit frmLogIn_u;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, pngimage, ExtCtrls;

type
  TfrmLogIn = class(TForm)
    imgLogInBackground: TImage;
    lblPassword: TLabel;
    btnHelp: TButton;
    btnLogIn: TButton;
    edtPassword: TEdit;
    edtAccountID: TEdit;
    lblAccountID: TLabel;
    btnBack: TButton;
    procedure btnLogInClick(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnHelpClick(Sender: TObject);
  private
    { Private declarations }
    /// Variables
    sEnteredAcountID: string;
    sEnteredPassword: string;
    /// Procedures
    procedure ClearAllFields;
    /// Functions
    function PresenceCheck(sEnteredAcountID: string; sEnteredPassword: string)
      : boolean;
    function LocateAcountID(sEnteredAcountID: string): boolean;
    function CheckPassword(sEnteredPassword: string): boolean;

  public
    { Public declarations }
    sLoggedOnUser: string;

  end;

var
  frmLogIn: TfrmLogIn;

implementation

uses
  frmGrowCery_u, frmAdminHomeScreen_u, frmTellerHomeScreen_u,
  dmDatabase_u;
{$R *.dfm}

/// =============================== Back Button ===============================
procedure TfrmLogIn.btnBackClick(Sender: TObject);
begin
  // clear all fields
  frmLogIn.Close; // more done On Close event
end;

/// ============================ Help Button ==================================
procedure TfrmLogIn.btnHelpClick(Sender: TObject);
var
  tHelp: TextFile;
  sLine: string;
  sMessage: string;

begin
  sMessage := '========================================';
  AssignFile(tHelp, 'Help_LogIn.txt');

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

/// ============================ Log In Button ================================
procedure TfrmLogIn.btnLogInClick(Sender: TObject);
begin
  sEnteredAcountID := edtAccountID.Text;
  sEnteredPassword := edtPassword.Text;

  if PresenceCheck(sEnteredAcountID, sEnteredPassword) = FALSE then
  Begin
    Exit;
  End;

  if LocateAcountID(sEnteredAcountID) = FALSE then
  Begin
    ShowMessage('AccountID or Password incorrect');
    Exit;
  End;

  if CheckPassword(sEnteredPassword) = FALSE then
  Begin
    ShowMessage('Password or Account ID incorrect');
    Exit;
  End;

  // Log In was succesfull
  // User has logged into an administrative account
  if dmDatabase.tblAccounts['IsAdmin'] = TRUE then
  Begin
    if MessageDlg('Welcome ' + dmDatabase.tblAccounts['Name']
        + ' ' + dmDatabase.tblAccounts['Surname'] +
        ' you have logged into an admin account.' + #13 +
        'Do you wich to continue ?', mtConfirmation, [mbYes, mbCancel], 0)
      = mrYes then
    Begin
      /// Assign The Logged on user
      sLoggedOnUser := dmDatabase.tblAccounts['AccountID'];
      /// Go To Admin Form
      ClearAllFields;
      frmLogIn.Hide;
      frmLogIn.Close;
      frmAdminHomeScreen.ShowModal
    End;
  End
  Else
  // User has logged into a teller account
    if MessageDlg('Welcome ' + dmDatabase.tblAccounts['Name']
      + ' ' + dmDatabase.tblAccounts['Surname'] + #13 +
      'Log In succesfull. Do you wich to continue ?', mtConfirmation,
    [mbYes, mbCancel], 0) = mrYes then
  Begin
    /// Assign The Logged on user
    sLoggedOnUser := dmDatabase.tblAccounts['AccountID'];
    /// Go To Admin Form
    ClearAllFields;
    frmLogIn.Hide;
    frmLogIn.Close;
    frmTellerHomeScreen.ShowModal

  End;
end;

/// =============================== Clear All Fields ===========================
procedure TfrmLogIn.ClearAllFields;
begin
  lblAccountID.Font.Color := clBlack;
  lblPassword.Font.Color := clBlack;
  edtAccountID.Text := '';
  edtPassword.Text := '';
  lblAccountID.Caption := 'Account ID:';
  lblPassword.Caption := 'Password:';
end;

/// ================================Presence Check =============================
function TfrmLogIn.PresenceCheck(sEnteredAcountID, sEnteredPassword: string)
  : boolean;
begin
  /// Check fields are not empty
  if sEnteredAcountID = '' then
  begin
    ShowMessage('Please enter your Account ID');
    lblAccountID.Font.Color := clred;
    lblAccountID.Caption := '*** Account ID:';
    Result := FALSE;
  end;
  if sEnteredPassword = '' then
  begin
    ShowMessage('Please enter your Password');
    lblPassword.Font.Color := clred;
    lblPassword.Caption := '***Password:';
    Result := FALSE;
  end;
end;

/// =============================== Find Account ID ============================
function TfrmLogIn.LocateAcountID(sEnteredAcountID: string): boolean;
var
  bAccountIDFound: boolean;
  sCompare: string;
begin
  bAccountIDFound := FALSE;
  dmDatabase.tblAccounts.First;
  while (NOT dmDatabase.tblAccounts.EOF) AND (bAccountIDFound = FALSE) do
  Begin
    sCompare := dmDatabase.tblAccounts['AccountID'];
    if sEnteredAcountID = sCompare then
    Begin
      bAccountIDFound := TRUE;
      // ShowMessage('Account ID Found');
    End
    else
    Begin
      dmDatabase.tblAccounts.Next;
    End;
  End; // End of searching for username (EOF)
  Result := bAccountIDFound;
end;

/// ============================= Check Password ==============================
function TfrmLogIn.CheckPassword(sEnteredPassword: string): boolean;
var
  bPasswordMatches: boolean;
begin
  bPasswordMatches := FALSE;
  if sEnteredPassword = dmDatabase.tblAccounts['Password'] then
  Begin
    bPasswordMatches := TRUE;
  End;
  Result := bPasswordMatches;
end;

/// ================================= Form Close ==============================
procedure TfrmLogIn.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ClearAllFields; // procedure that clears all of the entered information
  frmWelcome.Show;
end;

end.
