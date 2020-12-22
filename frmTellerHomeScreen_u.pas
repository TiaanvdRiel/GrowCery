// ##################################
// ######     IT PAT 2018     #######
// ######      GrowCery       #######
// ######  Tiaan van der Riel #######
// ##################################
unit frmTellerHomeScreen_u;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, pngimage, ExtCtrls, StdCtrls, ComCtrls, jpeg, clsDisplayUserInfo_u,
  clsAnalyticsCalculator_u, DateUtils;

type
  TfrmTellerHomeScreen = class(TForm)
    btnStartShift: TButton;
    btnLogOut: TButton;
    imgBacground: TImage;
    imgWelcomeHeading: TImage;
    lblLoggedOnUser: TLabel;
    lblTellerInfo: TLabel;
    imgDarkLogo: TImage;
    btHelp: TButton;
    lblTotalNumberYesterday: TLabel;
    lblTotalValueYesterday: TLabel;
    lblTotalNumberToday: TLabel;
    lblTotalValueToday: TLabel;
    lblYesterday: TLabel;
    lblToday: TLabel;
    pnlTotalNumberYesterday: TPanel;
    pnlTotalNumberToday: TPanel;
    pnlTotalValueYesterday: TPanel;
    pnlTotalValueToday: TPanel;
    lblTodaysDate: TLabel;
    lblYesterdaysDate: TLabel;
    lblNoDataYesterday: TLabel;
    lblDifferenceInNumberSold: TLabel;
    lblDifferenceValue: TLabel;
    procedure FormActivate(Sender: TObject);
    procedure btnLogOutClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnStartShiftClick(Sender: TObject);
    procedure btHelpClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    objDisplayUserInfo: TDisplayUserInfo;
    objAnalyticsCalculator: TAnalyticsCalculator;
    procedure DetermindeYesterdaysDate;
    procedure CalculateDifferences;
    procedure GetUserFullName;
  public
    { Public declarations }
    sLoggedOnUser: string;
    sLoggedOnUserName: string;
    sTodaysDate: string;
    sYesterdaysDate: string;
    rTodayTotalValue: real;
    rYesterdayTotalValue: real;
    iTodayTotalNumSold: integer;
    iYesterdayTotalNumSold: integer;
  end;

var
  frmTellerHomeScreen: TfrmTellerHomeScreen;

implementation

uses
  frmLogIn_u, frmPointOfSale_u, dmDatabase_u;
{$R *.dfm}


/// ========================= Start Shift Button ==============================
procedure TfrmTellerHomeScreen.btnStartShiftClick(Sender: TObject);
begin
  frmTellerHomeScreen.Hide;
  frmPointOfSale.ShowModal;
end;

/// ======================== Form Activate ====================================
procedure TfrmTellerHomeScreen.FormActivate(Sender: TObject);
var
  sSelectedAccountID: string;
  sStartDate: string;
  sEndDate: string;
begin
  // Obtains the logged in user`s name from frmLogIn
  sLoggedOnUser := frmLogIn.sLoggedOnUser;
  GetUserFullName;
  lblLoggedOnUser.Caption := sLoggedOnUserName;
  // Object to display user information
  { The function of this piece of code is to create the object objDisplayUserInfo,
  this object will make use of the class clsDisplayUserInfo, as the variable
  sLoggedOnUser, to find and return all of the relevant information regarding the
  currently logged in user, and display that information in the top left
  * also used by frmAdminHomeScreeen }
  objDisplayUserInfo := TDisplayUserInfo.Create(sLoggedOnUser);
  lblTellerInfo.Caption := objDisplayUserInfo.ToString;
  objDisplayUserInfo.Free;

  // Get the analytics for TODAY
  with dmDatabase do
  Begin
    dsrTransactions.DataSet := qryTransactions;
  End;
  { The function of this code is to send over the paramaters to clsAnalyticsCalsulator
    so that the totals for the CURRENT DATE can be calculated
    - see class clsAnalyticsCalculator on more information as to how this is done.}
  sSelectedAccountID := sLoggedOnUser;
  sStartDate := sTodaysDate;
  sEndDate := sTodaysDate;
  objAnalyticsCalculator := TAnalyticsCalculator.Create
    (sSelectedAccountID, sStartDate, sEndDate);
  iTodayTotalNumSold := objAnalyticsCalculator.CalcTotalItemsSold;
  pnlTotalNumberToday.Caption := IntToStr(iTodayTotalNumSold);
  rTodayTotalValue := objAnalyticsCalculator.CalcTotalSales;
  pnlTotalValueToday.Caption := FloatToStrF(rTodayTotalValue, ffCurrency, 8, 2);
  objAnalyticsCalculator.Free;
  lblTodaysDate.Caption := sTodaysDate;

  // Get the analytics for YESTERDAY
  DetermindeYesterdaysDate;
  lblYesterdaysDate.Caption := sYesterdaysDate;
  sSelectedAccountID := sLoggedOnUser;
  sStartDate := sYesterdaysDate;
  sEndDate := sYesterdaysDate;
  objAnalyticsCalculator := TAnalyticsCalculator.Create
    (sSelectedAccountID, sStartDate, sEndDate);
  iYesterdayTotalNumSold := objAnalyticsCalculator.CalcTotalItemsSold;
  pnlTotalNumberYesterday.Caption := IntToStr(iYesterdayTotalNumSold);
  rYesterdayTotalValue := objAnalyticsCalculator.CalcTotalSales;
  pnlTotalValueYesterday.Caption := FloatToStrF
    (rYesterdayTotalValue, ffCurrency, 8, 2);
  objAnalyticsCalculator.Free;
  //

  iYesterdayTotalNumSold := StrToInt(pnlTotalNumberYesterday.Caption);
  { If no items where sold yesterday, that means that teller either didn`t work
    the previous day, OR IT IS THE BEGGING OF A NEW WORK CYCLE/WEEK - data gets "archived"
    every 6 days }
  if iYesterdayTotalNumSold = 0 then
  Begin
    lblNoDataYesterday.Visible := True;
    lblTotalNumberYesterday.Visible := False;
    lblTotalValueYesterday.Visible := False;
    lblDifferenceInNumberSold.Visible := False;
    lblDifferenceValue.Visible := False;
    pnlTotalValueYesterday.Visible := False;
    pnlTotalNumberYesterday.Visible := False;
  End
  Else
  Begin
    CalculateDifferences;
  End;

  //
  pnlTotalNumberYesterday.Color := rgb(139, 198, 99);
  pnlTotalValueYesterday.Color := rgb(139, 198, 99);
  pnlTotalNumberToday.Color := rgb(139, 198, 99);
  pnlTotalValueToday.Color := rgb(139, 198, 99);
end;

/// ========================= Determine Yesterday`s date ======================
procedure TfrmTellerHomeScreen.DetermindeYesterdaysDate;
{ This procedure calculats the previous date, this will work no matter if the
previous date is in another month, or even a previous year}
var
  GivenDate: TdateTime;
  iYear: word;
  iMonth: word;
  iDay: word;
  PreviousDate: TdateTime;
begin
  iYear := StrToInt(Copy(sTodaysDate, 1, 4));
  iMonth := StrToInt(Copy(sTodaysDate, 6, 2));
  iDay := StrToInt(Copy(sTodaysDate, 9, 2));
  GivenDate := EncodeDate(iYear, iMonth, iDay);
  /////////////////// NB /////////////////////
  { Increases the given date (today`s date) by -1, effectively calculating the
    previuos day, yesterday }
  /////////////////// NB /////////////////////
  PreviousDate := IncDay(GivenDate, -1);
  sYesterdaysDate := DateToStr(PreviousDate);
  // ShowMessage(sYesterdaysDate);
  sYesterdaysDate := Copy(sYesterdaysDate, 1, 4) + '-' + Copy
    (sYesterdaysDate, 6, 2) + '-' + Copy(sYesterdaysDate, 9, 2);
  // ShowMessage(sYesterdaysDate);
  lblYesterdaysDate.Caption := sYesterdaysDate;
end;

// ================ Calculates the difference in the number of items sold and
// value of the current day and previous day =================================
procedure TfrmTellerHomeScreen.CalculateDifferences;
var
  iDifferenceInNumSold: integer;
  rDifferenceInValue: real;
begin

  iDifferenceInNumSold := iTodayTotalNumSold - iYesterdayTotalNumSold;
  rDifferenceInValue := rTodayTotalValue - rYesterdayTotalValue;

  if iDifferenceInNumSold = 0 then
  Begin
    lblDifferenceInNumberSold.Font.Color := clBlack;
    lblDifferenceInNumberSold.Caption := 'No Difference ' + IntToStr
      (iDifferenceInNumSold);
  End;
  if iDifferenceInNumSold > 0 then
  Begin
    lblDifferenceInNumberSold.Font.Color := clGreen;
    lblDifferenceInNumberSold.Caption := '↑ Up by ' + IntToStr
      (iDifferenceInNumSold);
  End;
  if iDifferenceInNumSold < 0 then
  Begin
    lblDifferenceInNumberSold.Font.Color := clRed;
    lblDifferenceInNumberSold.Caption := '↓ Down by ' + IntToStr
      (iDifferenceInNumSold);
  end;

  if rDifferenceInValue = 0 then
  Begin
    lblDifferenceValue.Font.Color := clBlack;
    lblDifferenceValue.Caption := 'No Difference ' + FloatToStrF
      (rDifferenceInValue, ffCurrency, 8, 2)
  End;
  if rDifferenceInValue > 0 then
  Begin
    lblDifferenceValue.Font.Color := clGreen;
    lblDifferenceValue.Caption := '↑ Up by ' + FloatToStrF
      (rDifferenceInValue, ffCurrency, 8, 2);
  End;
  if rDifferenceInValue < 0 then
  Begin
    lblDifferenceValue.Font.Color := clRed;
    lblDifferenceValue.Caption := '↓ Down by ' + FloatToStrF
      (rDifferenceInValue, ffCurrency, 8, 2);
  End;

end;

/// ========================= Form Close ======================================
procedure TfrmTellerHomeScreen.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  ShowMessage('You have been logged out of your account.');
  // Date gets reset
  sTodaysDate := '';
end;

/// ======================== Log Out Button ===================================
procedure TfrmTellerHomeScreen.btnLogOutClick(Sender: TObject);
begin
  if MessageDlg(' Are you sure you want to log out of your account ?',
    mtConfirmation, [mbYes, mbCancel], 0) = mrYes then
  begin
    frmTellerHomeScreen.Close;
  end
  else
    Exit
end;

/// ======================= Form Gets Shown ===================================
procedure TfrmTellerHomeScreen.FormShow(Sender: TObject);
begin
  if sTodaysDate = '' then
  Begin
    sTodaysDate := InputBox('Today`s Date',
      'Please enter today`s date' + #9 + '(yyyy-mm-dd)', '2018-01-02');
  End;
end;

/// ================== Get The Sull Name Of the User ==========================
procedure TfrmTellerHomeScreen.GetUserFullName;
var
  bAccountIDFound: boolean;
  sCompare: string;
begin
  bAccountIDFound := False;
  dmDatabase.tblAccounts.First;
  while (NOT dmDatabase.tblAccounts.EOF) AND (bAccountIDFound = False) do
  Begin
    sCompare := dmDatabase.tblAccounts['AccountID'];
    if sLoggedOnUser = sCompare then
    Begin
      bAccountIDFound := True;
      sLoggedOnUserName := dmDatabase.tblAccounts['Name']
        + ' ' + dmDatabase.tblAccounts['Surname'];
      // ShowMessage('Account ID Found');
    End
    else
    Begin
      dmDatabase.tblAccounts.Next;
    End;
  End; // End of searching for username (EOF)
End;

/// ============================= Help Button =================================
procedure TfrmTellerHomeScreen.btHelpClick(Sender: TObject);
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

end.
