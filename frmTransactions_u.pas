// ##################################
// ######     IT PAT 2018     #######
// ######      GrowCery       #######
// ######  Tiaan van der Riel #######
// ##################################
unit frmTransactions_u;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Grids, DBGrids, Buttons, ExtCtrls, pngimage,
  Mask, DBCtrls;

type
  TfrmTransactions = class(TForm)
    dbgAccounts: TDBGrid;
    dbgTransactions: TDBGrid;
    redTransactionDetails: TRichEdit;
    pnlLeft: TPanel;
    imgDarkLogo: TImage;
    btnBack: TButton;
    pnlTop: TPanel;
    lblSearchTellerName: TLabel;
    edtSearhTellerID: TEdit;
    lblAccounts: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label5: TLabel;
    lblTransactionTotal: TEdit;
    Label6: TLabel;
    lblNumberOfItemsSold: TEdit;
    lblNumItemsSold: TLabel;
    Label8: TLabel;
    lblNumTrans: TEdit;
    btnHelp: TButton;
    lblTransactionInfo: TLabel;
    Label9: TLabel;
    lblName: TDBEdit;
    Label10: TLabel;
    lblSurname: TDBEdit;
    lblSelectedTeller: TLabel;
    lblAccountID: TLabel;
    DBEdit1: TDBEdit;
    DBNavigator1: TDBNavigator;
    procedure btnBackClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure dbgAccountsCellClick(Column: TColumn);
    procedure dbgTransactionsCellClick(Column: TColumn);
    procedure edtSearhTellerIDChange(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmTransactions: TfrmTransactions;

implementation

uses
  frmAdminHomeScreen_u, dmDatabase_u;
{$R *.dfm}

/// ========================= Click Accounts Grid =============================
procedure TfrmTransactions.dbgAccountsCellClick(Column: TColumn);
var
  sAccountID: string[6];
begin
  dbgTransactions.DataSource := nil;
  redTransactionDetails.Clear;
  lblTransactionTotal.Text := '';
  lblNumTrans.Text := '';
  lblNumberOfItemsSold.Text := '';

  redTransactionDetails.Clear; // To clear the print summary of the previous customer
  redTransactionDetails.Font.Size := 9;
  lblTransactionInfo.Caption := '';

  Beep;
  Screen.Cursor := crHourGlass;
  Sleep(150);
  with dmDatabase do
  begin
    sAccountID := tblAccounts['AccountID'];
    dbgTransactions.DataSource := dmDatabase.dsrTransactions;
    tblTransactions.Filtered := False;
    tblTransactions.Filter := 'AccountID=' + QuotedStr(sAccountID);
    tblTransactions.Sort := 'TransID DESC';
    tblTransactions.Filtered := True;
    lblTransactionInfo.Caption := IntToStr(tblTransactions.RecordCount)
      + ' transactions(s) for Teller ' + sAccountID + ': ' + #13 + tblAccounts
      ['Name'] + ' ' + tblAccounts['Surname'] + '. Click on an order.';
    lblNumTrans.Text := IntToStr(tblTransactions.RecordCount);
  end;
  Screen.Cursor := crDefault;
end;

/// ========================= Transaction Gets Chosen =========================
procedure TfrmTransactions.dbgTransactionsCellClick(Column: TColumn);
var
  iNumItems: integer;
  iQuantity: integer;
  rUnitPrice: real;
  rTotal: real;
begin
  redTransactionDetails.Clear;
  Beep;
  Screen.Cursor := crHourGlass;
  iNumItems := 0;
  rTotal := 0;
  with dmDatabase do
  begin
    dsrTransactions.DataSet := tblTransactions;
    tblItemTransactions.First;
    redTransactionDetails.Lines.Add
      ('Transaction ID: ' + tblTransactions['TransID']);
    redTransactionDetails.Lines.Add
      ('Proscessed by: ' + tblTransactions['ProcessedBy']);
    redTransactionDetails.Lines.Add(' ');
    redTransactionDetails.Lines.Add(
      '=====================================================================');
    redTransactionDetails.Lines.Add
      ('Product Name:' + #9 + 'QTY:' + #9 + 'Unit Price:');
    redTransactionDetails.Lines.Add(' ');

    /// Search for all the transactions by the selected teller
    while NOT(tblItemTransactions.Eof) do
    begin
      if tblItemTransactions['TransID'] = tblTransactions['TransID'] then
      begin // Search for all the items sold in that transaction
        iQuantity := tblItemTransactions['Quantity'];
        iNumItems := iNumItems + iQuantity;
        rUnitPrice := StrToFloat(tblItemTransactions['UnitPrice']);
        rTotal := rTotal + (rUnitPrice * iQuantity);
        redTransactionDetails.Lines.Add
          (tblItemTransactions['ItemName'] + #9 + IntToStr(iQuantity)
            + #9 + FloatToStrF(rUnitPrice, ffCurrency, 6, 2));
      end; // if
      tblItemTransactions.Next;
    end; // while

    redTransactionDetails.Lines.Add(
      '=====================================================================');
    redTransactionDetails.Lines.Add('');
    redTransactionDetails.Lines.Add('Number Of Items Sold: ' + IntToStr
        (iNumItems));
    redTransactionDetails.Lines.Add
      ('Total for order ' + tblTransactions['TransID'] + ': ' + FloatToStrF
        (rTotal, ffCurrency, 10, 2));
    lblNumberOfItemsSold.Text := IntToStr(iNumItems);
    lblTransactionTotal.Text := FloatToStrF(rTotal, ffCurrency, 10, 2);
  end;
  Screen.Cursor := crDefault;
end;

/// =================== Search For A Spesific Account ID ======================
procedure TfrmTransactions.edtSearhTellerIDChange(Sender: TObject);
{ This porcedure is used to search, and filter the table of accounts, to
  display the smilar usernames, as the user types a username into the edit field }
begin
  if (edtSearhTellerID.Text <> '') then
  Begin
    dmDatabase.tblAccounts.Filter := 'AccountID LIKE ''' +
      (edtSearhTellerID.Text) + '%''     ';
    dmDatabase.tblAccounts.Filtered := True;
  End
  else
  begin
    dmDatabase.tblAccounts.Filtered := False;
  end;
end;

/// ============================= Form Gets Activated =========================
procedure TfrmTransactions.FormActivate(Sender: TObject);
begin
  pnlLeft.Color := rgb(139, 198, 99);
  pnlTop.Color := rgb(139, 198, 99);
end;

/// ======================== Form Gets Created ================================
procedure TfrmTransactions.FormCreate(Sender: TObject);
begin
  with redTransactionDetails do
  begin
    Paragraph.TabCount := 3;
    Paragraph.Tab[0] := 300;
    Paragraph.Tab[1] := 350;
    Paragraph.Tab[2] := 375;
    Font.Name := 'Courier';
    Font.Size := 9;
  end;
end;

/// =========================== Form Gets Shown ===============================
procedure TfrmTransactions.FormShow(Sender: TObject);
begin
  with dmDatabase do
  begin
    tblAccounts.Open;
    tblAccounts.First;
    tblTransactions.Open;
    tblItemTransactions.Open;
    tblAccounts.Filtered := False;
    tblAccounts.Filter := 'IsAdmin= false';
    tblAccounts.Filtered := True;
  end;
  dbgTransactions.DataSource := nil;
end;

/// ================================ Back Button ==============================
procedure TfrmTransactions.btnBackClick(Sender: TObject);
begin
  begin
    if MessageDlg(' Are you sure you want to return to your home page ?',
      mtConfirmation, [mbYes, mbCancel], 0) = mrYes then
    begin
      frmTransactions.Close;
    end
    else
      Exit
  end;
end;

/// ============================ Form Gets Closed =============================
procedure TfrmTransactions.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  frmAdminHomeScreen.Show;
end;

/// ============================ Help Button ==================================
procedure TfrmTransactions.btnHelpClick(Sender: TObject);
var
  tHelp: TextFile;
  sLine: string;
  sMessage: string;

begin
  sMessage := '========================================';
  AssignFile(tHelp, 'Help_Transactions.txt');

  try { Code that checks to see if the file about the sponsors can be opened
      - displays error if not }
    reset(tHelp);
  Except
    ShowMessage('ERROR: The help file could not be opened.');
    Exit;
  end;

  while NOT Eof(tHelp) do
  begin
    Readln(tHelp, sLine);
    sMessage := sMessage + #13 + sLine;

  end;
  sMessage := sMessage + #13 + '========================================';
  CloseFile(tHelp);
  ShowMessage(sMessage);
end;

end.
