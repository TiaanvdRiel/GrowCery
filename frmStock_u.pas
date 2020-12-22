// ##################################
// ######     IT PAT 2018     #######
// ######      GrowCery       #######
// ######  Tiaan van der Riel #######
// ##################################
unit frmStock_u;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls, Grids, DBGrids, DBCtrls, pngimage,
  Mask;

type
  TfrmStock = class(TForm)
    pnlInfo: TPanel;
    pnlDbgHeadings: TPanel;
    btnBack: TButton;
    imgLogo: TImage;
    dbnStock: TDBNavigator;
    dbgSuppliers: TDBGrid;
    dbgItems: TDBGrid;
    lblSupplierTable: TLabel;
    lblItemsTable: TLabel;
    lblSearchSupplier: TLabel;
    lblSearchName: TLabel;
    edtSearchSupplier: TEdit;
    edtSearchItemName: TEdit;
    btnHelp: TButton;
    lblSupplier: TLabel;
    lblSupplierInfo: TLabel;
    Label1: TLabel;
    DBEdit1: TDBEdit;
    Label2: TLabel;
    DBEdit2: TDBEdit;
    Label3: TLabel;
    DBEdit3: TDBEdit;
    Label4: TLabel;
    Label5: TLabel;
    DBEdit4: TDBEdit;
    Label6: TLabel;
    DBEdit5: TDBEdit;
    Label7: TLabel;
    DBEdit6: TDBEdit;
    btnShowAllItems: TButton;
    procedure btnBackClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure dbgSuppliersCellClick(Column: TColumn);
    procedure btnHelpClick(Sender: TObject);
    procedure btnShowAllItemsClick(Sender: TObject);
    procedure edtSearchSupplierChange(Sender: TObject);
    procedure edtSearchItemNameChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmStock: TfrmStock;

implementation

uses
  frmAdminHomeScreen_u, dmDatabase_u;
{$R *.dfm}


/// ========================== Search Items ===================================
procedure TfrmStock.edtSearchItemNameChange(Sender: TObject);
begin
 { This porcedure is used to search, and filter the table of suppliers, to
  display the smilar names, as the user types a name into the edit field }
begin
  if (edtSearchItemName.Text <> '') then
  Begin
    dmDatabase.tblItems.Filter := 'ItemName LIKE ''' +
      (edtSearchItemName.Text) + '%''     ';
    dmDatabase.tblItems.Filtered := True;
  End
  else
  begin
    dmDatabase.tblItems.Filtered := False;
  end;
end;
end;

/// ======================== Search Suppliers =================================
procedure TfrmStock.edtSearchSupplierChange(Sender: TObject);
{ This porcedure is used to search, and filter the table of suppliers, to
  display the smilar names, as the user types a name into the edit field }
begin
  if (edtSearchSupplier.Text <> '') then
  Begin
    dmDatabase.tblSuppliers.Filter := 'SupplierName LIKE ''' +
      (edtSearchSupplier.Text) + '%''     ';
    dmDatabase.tblSuppliers.Filtered := True;
  End
  else
  begin
    dmDatabase.tblSuppliers.Filtered := False;
  end;
end;

/// ======================= User Clicks On A Supplier =========================
procedure TfrmStock.dbgSuppliersCellClick(Column: TColumn);
var
  sSuppID: string;
begin
  with dmDatabase do
  Begin
    sSuppID := tblSuppliers['SupplierID'];
    dbgItems.DataSource := dmDatabase.dsrItems;
    tblItems.Filtered := false;
    tblItems.Filter := 'SupplierID=' + QuotedStr(sSuppID);
    tblItems.Sort := 'Barcode ASC';
    tblItems.Filtered := True;
    lblSupplierInfo.Caption := IntToStr(tblItems.RecordCount)
      + ' item(s) supplied by ' + tblSuppliers['SupplierName'];
  End;
end;

/// ================================ Form Activate ============================
procedure TfrmStock.FormActivate(Sender: TObject);
begin
  pnlInfo.Color := rgb(139, 198, 99);
  pnlDbgHeadings.Color := rgb(139, 198, 99);
end;

/// =============================== Form Close ================================
procedure TfrmStock.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  frmAdminHomeScreen.Show;
end;

/// =============================== Form Show =================================
procedure TfrmStock.FormShow(Sender: TObject);
begin
  with dmDatabase do
  begin
    tblSuppliers.Open;
    tblSuppliers.First;
    tblItems.Open;
  end;
  dbgItems.DataSource := nil;
end;

/// ============================= Help Button =================================
procedure TfrmStock.btnHelpClick(Sender: TObject);
var
  tHelp: TextFile;
  sLine: string;
  sMessage: string;

begin
  sMessage := '========================================';
  AssignFile(tHelp, 'Help_Stock.txt');

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

/// ====================== Show All Items Button ==============================
procedure TfrmStock.btnShowAllItemsClick(Sender: TObject);
begin
  dbgItems.DataSource := nil;
  with dmDatabase do
  begin
    dbgItems.DataSource := dmDatabase.dsrItems;
    tblItems.Filtered := false;
  end;
end;

/// ============================ Back Button ==================================
procedure TfrmStock.btnBackClick(Sender: TObject);
begin
  begin
    begin
      if MessageDlg(' Are you sure you want to return to your home page ?',
        mtConfirmation, [mbYes, mbCancel], 0) = mrYes then
      begin
        frmStock.Close;
      end
      else
        Exit
    end;
  end;
end;

end.
