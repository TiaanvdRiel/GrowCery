// ##################################
// ######     IT PAT 2018     #######
// ######      GrowCery       #######
// ######  Tiaan van der Riel #######
// ##################################
unit frmDeleteAnAccount_u;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Grids, DBGrids, pngimage, Mask, DBCtrls, ActnMan,
  ActnColorMaps;

type
  TfrmDeleteAnAccount = class(TForm)
    dbgAccounts: TDBGrid;
    btnBack: TButton;
    imgSuspendAccountBackground: TImage;
    imgSuspendAnAccountHeading: TImage;
    pnlInformation: TPanel;
    lblContactInformation: TLabel;
    lblAccountInformation: TLabel;
    imgLogo: TImage;
    lblAccountID: TLabel;
    lblName: TLabel;
    lblSurname: TLabel;
    lblAllocatedCashRegister: TLabel;
    lblCellphoneNumber: TLabel;
    lblEmailAdress: TLabel;
    btnSuspendAccount: TButton;
    DBEdit1: TDBEdit;
    DBEdit2: TDBEdit;
    DBEdit3: TDBEdit;
    DBEdit4: TDBEdit;
    DBEdit5: TDBEdit;
    DBEdit6: TDBEdit;
    procedure FormActivate(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnSuspendAccountClick(Sender: TObject);
    procedure FormShow(Sender: TObject);

  private
    { Private declarations }
    function IsPasswordCorrect: boolean;
    procedure LocateAndDeleteSelectedAccount;
  public
    { Public declarations }
    sEnteredAdminPassword: string;
    sSelctedAccountID: string;
  end;

var
  frmDeleteAnAccount: TfrmDeleteAnAccount;

implementation

uses
  frmAdminHomeScreen_u, dmDatabase_u;
{$R *.dfm}

{ NB - All accounts will be SUSPENDED, to avoid any orphaned records. Alos from
  a buisiness perspective it makes more sence than simply getting rid of all records
  pretaining to that account, ince they still happended, and those records need to
  be kept for various book keeping and record keeping reasons. }

/// ===================== Suspend The Account =================================
procedure TfrmDeleteAnAccount.btnSuspendAccountClick(Sender: TObject);
var
  bIsPasswordCorrect: boolean;
begin
  begin
    if MessageDlg(' Are you sure you want to suspend this account ?',
      mtWarning, [mbYes, mbCancel], 0) = mrYes then
    begin
      sSelctedAccountID := dmDatabase.tblAccounts['AccountID'];
      // ShowMessage(sSelctedAccountID);
      sEnteredAdminPassword := InputBox('Please enter your password.',
        'Please enter your administrative password in order to complete the suspention of the account.', '');
      // ShowMessage(sEnteredAdminPassword);
      bIsPasswordCorrect := IsPasswordCorrect;
      if bIsPasswordCorrect = True then
      Begin
        // ShowMessage('Correct Password');
        LocateAndDeleteSelectedAccount;
      end
      else
      begin
        Beep;
        ShowMessage('The password you have entered is incorrect.');
      end;
    end
    else
      Exit
  end;
  dmDatabase.tblAccounts.Filter := 'IsAdmin = False';
  dmDatabase.tblAccounts.Filtered := True;
end;

/// ===== Check To See That The User Entered The Correct Password =============
function TfrmDeleteAnAccount.IsPasswordCorrect: boolean;
var
  bAccountIDFound: boolean;
  sCompare: string;
  sLoggedOnUser: string;
  bPasswordMatches: boolean;
begin
  bPasswordMatches := False;
  sLoggedOnUser := frmAdminHomeScreen.sLoggedOnUser;
  bAccountIDFound := False;
  dmDatabase.tblAccounts.Filtered := False;
  dmDatabase.tblAccounts.First;
  while (NOT dmDatabase.tblAccounts.EOF) AND (bPasswordMatches = False) do
  Begin
    sCompare := dmDatabase.tblAccounts['AccountID'];
    if sLoggedOnUser = sCompare then
    Begin
      if dmDatabase.tblAccounts['Password'] = sEnteredAdminPassword then
      Begin
        bPasswordMatches := True;
      End;
    End
    else
    Begin
      dmDatabase.tblAccounts.Next;
    End;
  End; // End of searching for username (EOF)
  dmDatabase.tblAccounts.Filter := 'IsAdmin = False';
  dmDatabase.tblAccounts.Filtered := True;
  Result := bPasswordMatches;
end;

/// ====================== Locate Selected Account ============================
procedure TfrmDeleteAnAccount.LocateAndDeleteSelectedAccount;
var
  bAccountIDFound: boolean;
  sCompare: string;
  sSuspended: string;
begin

  bAccountIDFound := False;
  dmDatabase.tblAccounts.First;
  while (NOT dmDatabase.tblAccounts.EOF) AND (bAccountIDFound = False) do
  Begin
    sCompare := dmDatabase.tblAccounts['AccountID'];
    if sSelctedAccountID = sCompare then // if account found
    Begin
      bAccountIDFound := True;
      // ShowMessage('Selected Account ID Found');
      { check to see that the account has not already been suspended }
      sSuspended := Copy(dmDatabase.tblAccounts['Surname'], length
          (dmDatabase.tblAccounts['Surname']) - 8, length
          (dmDatabase.tblAccounts['Surname']));
      ShowMessage(sSuspended);
      if sSuspended = 'SUSPENDED' then
      Begin
        ShowMessage('ERROR: This account has already been suspended.');
        Exit;
      End;

      // add "SUSPENDED" to the end of the correct account
      dmDatabase.tblAccounts.Edit;
      dmDatabase.tblAccounts['Surname'] := dmDatabase.tblAccounts['Surname']
        + ' - SUSPENDED';
      dmDatabase.tblAccounts.Post;
    End
    else
    Begin
      dmDatabase.tblAccounts.Next;
    End;
  End; // End of searching for account (EOF)
end;

/// ============================= Form Activate  ==============================
procedure TfrmDeleteAnAccount.FormActivate(Sender: TObject);
begin
  pnlInformation.Color := rgb(139, 198, 99);

end;

/// ========================= Back Button =====================================
procedure TfrmDeleteAnAccount.btnBackClick(Sender: TObject);
begin

  begin
    if MessageDlg(' Are you sure you want to return to your home page ?',
      mtConfirmation, [mbYes, mbCancel], 0) = mrYes then
    begin
      frmDeleteAnAccount.Close;
    end
    else
      Exit
  end;
end;

/// ============================= Form Close ==================================
procedure TfrmDeleteAnAccount.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  frmAdminHomeScreen.Show;
end;

procedure TfrmDeleteAnAccount.FormShow(Sender: TObject);
begin
  dmDatabase.tblAccounts.Filter := 'IsAdmin = False';
  dmDatabase.tblAccounts.Filtered := True;
end;

end.
