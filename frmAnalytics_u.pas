// ##################################
// ######     IT PAT 2018     #######
// ######      GrowCery       #######
// ######  Tiaan van der Riel #######
// ##################################
unit frmAnalytics_u;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, TeEngine, TeeProcs, Chart, Grids, DBGrids,
  pngimage, Buttons, ComCtrls, Mask, DBCtrls, Series, TeeDBEdit, TeeDBCrossTab,
  clsAnalyticsCalculator_u;

type
  TfrmAnalytics = class(TForm)
    dbgAccounts: TDBGrid;
    btnBack: TButton;
    pnlInfo: TPanel;
    lblSearchAccountID: TLabel;
    lblChartStart: TLabel;
    lblChartEnd: TLabel;
    edtSearhAccountID: TEdit;
    imgLogo: TImage;
    btnHelp: TButton;
    Label1: TLabel;
    DBEdit1: TDBEdit;
    Label2: TLabel;
    DBEdit2: TDBEdit;
    Label3: TLabel;
    DBEdit3: TDBEdit;
    dbgTransactionsByDate: TDBGrid;
    pnlTop: TPanel;
    lblAccounts: TLabel;
    lblAccountsHeading: TLabel;
    lblTransactionsWithinPeriod: TLabel;
    edtDateStart: TEdit;
    edtDtaeEnd: TEdit;
    rgbStyleOfChart: TRadioGroup;
    DBCrossTabSource1: TDBCrossTabSource;
    DBCrossTabSource2: TDBCrossTabSource;
    pnlAverageNumberSold: TPanel;
    pnlInfoBorder: TPanel;
    pnlTotalItems: TPanel;
    pnlAverageValue: TPanel;
    pnlTotalValue: TPanel;
    lblTotalValue: TLabel;
    lblAverageValue: TLabel;
    lblTotalItems: TLabel;
    lblAverageNumberSold: TLabel;
    Chart1: TChart;
    Series1: TBarSeries;
    Series2: TLineSeries;
    procedure FormActivate(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure edtSearhAccountIDChange(Sender: TObject);
    procedure dbgAccountsCellClick(Column: TColumn);
    procedure rgbStyleOfChartClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    objAnalyticsCalculator: TAnalyticsCalculator;
    iStyleOfChartNumber: integer;
    procedure UpdateChart;

    { Public declarations }
  end;

var
  frmAnalytics: TfrmAnalytics;

implementation

uses
  frmAdminHomeScreen_u, dmDatabase_u;
{$R *.dfm}

/// ===================== User Clicks On A Different Cell =====================
procedure TfrmAnalytics.dbgAccountsCellClick(Column: TColumn);
var
  sSelectedAccountID: string;
  sStartDate: string;
  sEndDate: string;

  iCount: integer;
  rTotalSales: real;
  rAverageSalesValue: real;
  iTotalNumberOfItemsSold: integer;
  rAverageNumberOfItemsSold: real;

begin
  Beep;
  Screen.Cursor := crHourGlass;
  Sleep(150);

  // Determines what style of chart the user wants
  if rgbStyleOfChart.ItemIndex = 0 then
  begin
    iStyleOfChartNumber := 1;
  end;
  if rgbStyleOfChart.ItemIndex = 1 then
  begin
    iStyleOfChartNumber := 2;
  end;

  // Gets the start and the end date
  sStartDate := edtDateStart.Text;
  sEndDate := edtDtaeEnd.Text;
  // Determines what account is selected
  with dmDatabase do
  Begin
    dsrTransactions.DataSet := qryTransactions;
    sSelectedAccountID := tblAccounts['AccountID'];
  End;

  // Creates object and sends over paramaters
  objAnalyticsCalculator := TAnalyticsCalculator.Create
    (sSelectedAccountID, sStartDate, sEndDate);

  // Calls the functions of the object in order to recieve processed data back
  pnlTotalValue.Caption := FloatToStrF(objAnalyticsCalculator.CalcTotalSales,
    ffCurrency, 8, 2);
  pnlAverageValue.Caption := FloatToStrF
    (objAnalyticsCalculator.CalcAverageSales, ffCurrency, 8, 2);
  pnlTotalItems.Caption := IntToStr(objAnalyticsCalculator.CalcTotalItemsSold);
  pnlAverageNumberSold.Caption := IntToStr
    (objAnalyticsCalculator.CalcAverageItemsSold);
  objAnalyticsCalculator.Free;
  //
  UpdateChart;
  //
  if pnlTotalItems.Caption = '0' then
  Begin
    Beep;
    Dialogs.MessageDlg(
      'No transactions where found within the period you selected.' + #13 +
        'Please check the dates you entered to verify that they are correct.',
      mtError, [mbOk], 0, mbOk);
  End;

  Screen.Cursor := crDefault;
end;

/// ============ User Eneters An AccountID Into The Search Field ==============
procedure TfrmAnalytics.edtSearhAccountIDChange(Sender: TObject);
{ This porcedure is used to search, and filter the table of accounts, to
  display the smilar names, as the user types a name into the edit field }
begin
  if (edtSearhAccountID.Text <> '') then
  Begin
    dmDatabase.tblAccounts.Filter := 'AccountID LIKE ''' +
      (edtSearhAccountID.Text) + '%''     ';
    dmDatabase.tblAccounts.Filtered := True;
  End
  else
  begin
    dmDatabase.tblAccounts.Filtered := False;
  end;
end;

/// ====================== Form Gets Activated ================================
procedure TfrmAnalytics.FormActivate(Sender: TObject);
begin
  //
  pnlInfo.Color := rgb(139, 198, 99);
  pnlTop.Color := rgb(139, 198, 99);
  dmDatabase.tblAccounts.Filter := 'IsAdmin = False';
  dmDatabase.tblAccounts.Filtered := True;
  //
end;

/// =========================== Form Gets Closed ==============================
procedure TfrmAnalytics.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  frmAdminHomeScreen.Show;
end;

procedure TfrmAnalytics.FormShow(Sender: TObject);
begin

end;

/// ====================== User Selects A Style Of Chart ======================
procedure TfrmAnalytics.rgbStyleOfChartClick(Sender: TObject);
begin

  if rgbStyleOfChart.ItemIndex = 0 then
  begin
    iStyleOfChartNumber := 1;
  end;

  if rgbStyleOfChart.ItemIndex = 1 then
  begin
    iStyleOfChartNumber := 2;
  end;

  UpdateChart;

end;

/// ====================== Procedure To Update Chart ==========================
procedure TfrmAnalytics.UpdateChart;
var
  sNameOfSeries: string;
begin
  Series1.Clear;
  Series2.Clear;
  sNameOfSeries := 'Series' + IntToStr(iStyleOfChartNumber);
  Chart1.Title.Caption := dmDatabase.tblAccounts['Name']
    + ' ' + +dmDatabase.tblAccounts['Surname'];

  { User Selects to veiw 'Totals for the day', chart style 'Series2' will display
    these values }
  if sNameOfSeries = 'Series1' then
  Begin
    while NOT dmDatabase.qryTransactions.Eof do
    Begin
      Series1.Add(StrToFloat(dmDatabase.qryTransactions['Total For The Day']),
        dmDatabase.qryTransactions['DateOfTransaction'], clGreen);
      dmDatabase.qryTransactions.Next;
    End;
  End;

  { User Selects to veiw 'Number Of Items Sold', chart style 'Series2' will display
    these values }
  if sNameOfSeries = 'Series2' then
  Begin
    while NOT dmDatabase.qryTransactions.Eof do
    Begin
      Series1.Add(StrToFloat(dmDatabase.qryTransactions['Number Of Items Sold'])
          , dmDatabase.qryTransactions['DateOfTransaction'], clGreen);
      dmDatabase.qryTransactions.Next;
    End;
  End;

end;

/// ===================== User Clicks On Back Button ==========================
procedure TfrmAnalytics.btnBackClick(Sender: TObject);
begin
  begin
    if MessageDlg(' Are you sure you want to return to your home page ?',
      mtConfirmation, [mbYes, mbCancel], 0) = mrYes then
    begin
      frmAnalytics.Close;
    end
    else
      Exit
  end;
end;

/// ============================ Help Button ==================================
procedure TfrmAnalytics.btnHelpClick(Sender: TObject);
var
  tHelp: TextFile;
  sLine: string;
  sMessage: string;

begin
  sMessage := '========================================';
  AssignFile(tHelp, 'Help_Analytics.txt');

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
