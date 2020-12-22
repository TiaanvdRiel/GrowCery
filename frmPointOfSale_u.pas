// ##################################
// ######     IT PAT 2018     #######
// ######      GrowCery       #######
// ######  Tiaan van der Riel #######
// ##################################
unit frmPointOfSale_u;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Spin, StdCtrls, ExtCtrls, ComCtrls, Grids, DBGrids, pngimage,
  DBCtrls, clsDisplayUserInfo_u, Printers;

const
  MAX = 250;

type
  TfrmPointOfSale = class(TForm)
    imgLogo: TImage;
    dbgStock: TDBGrid;
    redTransactionSummary: TRichEdit;
    pnlTransactionTotal: TPanel;
    btn1: TButton;
    btn2: TButton;
    btn3: TButton;
    btn4: TButton;
    btn5: TButton;
    btn6: TButton;
    btn7: TButton;
    btn8: TButton;
    btn9: TButton;
    btn0: TButton;
    edtBarcode: TEdit;
    lblSearchBarcode: TLabel;
    btnNewSale: TButton;
    btnVoidSale: TButton;
    btnAddItem: TButton;
    btnCheckout: TButton;
    lblStockSearch: TLabel;
    lblTransactionSummary: TLabel;
    lblTellarInfo: TLabel;
    lblTransactionTotalHeading: TLabel;
    lblTransactionTotalAmount: TLabel;
    imgCompanyName: TImage;
    btnEndShift: TButton;
    DBNavigator1: TDBNavigator;
    btnBackspace: TButton;
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnVoidSaleClick(Sender: TObject);
    procedure btnNewSaleClick(Sender: TObject);
    procedure btnCheckoutClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnAddItemClick(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure btn3Click(Sender: TObject);
    procedure btn4Click(Sender: TObject);
    procedure btn5Click(Sender: TObject);
    procedure btn6Click(Sender: TObject);
    procedure btn7Click(Sender: TObject);
    procedure btn8Click(Sender: TObject);
    procedure btn9Click(Sender: TObject);
    procedure btn0Click(Sender: TObject);
    procedure edtBarcodeChange(Sender: TObject);
    procedure btnBackspaceClick(Sender: TObject);
    procedure btnEndShiftClick(Sender: TObject);
  private
    { Private declarations }
    objDisplayUserInfo: TDisplayUserInfo;
    // Arrays
    arrItemNames: array [1 .. MAX] of string;
    arrUnitPrices: array [1 .. MAX] of real;
    arrBarcodes: array [1 .. MAX] of string;

    // Arrays that contain no duplicates
    arrItemsNoDuplicates: array [1 .. MAX] Of string;
    arrPricesNoDuplicates: array [1 .. MAX] of real;
    arrBarcodesNoDuplicates: array [1 .. MAX] of string;
    arrQTYNoDuplicates: array [1 .. MAX] of integer;

    // Procedures
    procedure DisableButtons;
    // 1-2. Done as items are added
    procedure UpdateTransactionSummary; // 1.)
    procedure UpdateSaleTotal; // 2.)
    // Part of checkout procedure
    procedure RemoveDuplicates; // 3.)
    procedure DetremineQuantities; // 4.)
    procedure GenerateTransactionID; // 5.)
    procedure CreateTillSlip; // 6.)
    procedure PrintTillSlip; // 7.)
    procedure SaveTransactionToDatabase; // 8.)
    procedure ClearArrays;
    procedure VoidCurrentSale;
  public
    { Public declarations }
    sLoggedOnUser: string;
    sLoggedOnUserName: string;
    sTodaysDate: string;
    iNoOfElements: integer;
    rTransactionTotal: real;
    iNoElemntsWithoutDup: integer;
    sNewTransactionID: string;
    rTotalDue: real;
  end;

var
  frmPointOfSale: TfrmPointOfSale;

implementation

uses
  frmTellerHomeScreen_u, dmDatabase_u;
{$R *.dfm}

/// =============================== New Sale Button ===========================
procedure TfrmPointOfSale.btnNewSaleClick(Sender: TObject);
{ The purpose of this piece of code is to enable all of the neccesary buttons
  as soon as a sale is started, having the buttons disabled pefore a sale is
  statred prevents the user from adding items to a sale that does not exist }
begin
  Beep;
  ShowMessage('NEW TRANSACTION STARTED.');
  btnNewSale.Enabled := False;
  btnVoidSale.Enabled := True;
  btnAddItem.Enabled := True;
  btnCheckout.Enabled := True;
  btn0.Enabled := True;
  btn1.Enabled := True;
  btn2.Enabled := True;
  btn3.Enabled := True;
  btn4.Enabled := True;
  btn5.Enabled := True;
  btn6.Enabled := True;
  btn7.Enabled := True;
  btn8.Enabled := True;
  btn9.Enabled := True;
  redTransactionSummary.Lines.Add('Item Name:' + #9 + 'Unit Price:');
  redTransactionSummary.Lines.Add(
    '===========================================================');
end;

/// ===================== Button Add The Selected Item ========================
procedure TfrmPointOfSale.btnAddItemClick(Sender: TObject);
var
  sSelectedItemName: string;
  sSelectedItemPrice: string;
  sSelectedItemBarcode: string;
begin
  // Input
  with dmDatabase do
  Begin
    sSelectedItemName := tblItems['ItemName'];
    sSelectedItemPrice := tblItems['UnitPrice'];
    sSelectedItemBarcode := tblItems['Barcode'];
  End;

  Inc(iNoOfElements);
  if iNoOfElements <= MAX then
  Begin
    arrItemNames[iNoOfElements] := sSelectedItemName;
    arrUnitPrices[iNoOfElements] := StrToFloat(sSelectedItemPrice);
    arrBarcodes[iNoOfElements] := sSelectedItemBarcode;
    /// /
    UpdateTransactionSummary; // 1.)
    UpdateSaleTotal; // 2.)
    /// /
    Windows.Beep(1000, 50);
  End
  else
  // MAX number exceeded
  begin
    ShowMessage(
      'You have exceded the maximum amount of items purchasable, please request the assistance of a manager.');
  end;
end;

/// 1.) ================== Update The Transaction Summary =====================
procedure TfrmPointOfSale.UpdateTransactionSummary;
var
  K: integer;
begin
  redTransactionSummary.Lines.Clear;
  redTransactionSummary.Lines.Add('Item Name:' + #9 + 'Unit Price:');
  redTransactionSummary.Lines.Add(
    '===========================================================');
  for K := 1 to iNoOfElements do
  Begin
    redTransactionSummary.Lines.Add(arrItemNames[K] + #9 + FloatToStrF
        (arrUnitPrices[K], ffCurrency, 8, 2));
  End;

end;

/// 2.) ====================== Update Sale Total ==============================
procedure TfrmPointOfSale.UpdateSaleTotal;
var
  K: integer;
begin
  rTransactionTotal := 0;
  for K := 1 to iNoOfElements do
  Begin
    rTransactionTotal := rTransactionTotal + arrUnitPrices[K];
    lblTransactionTotalAmount.Caption := FloatToStrF
      (rTransactionTotal, ffCurrency, 8, 2);
  End;
  if iNoOfElements = 0 then
  Begin
     lblTransactionTotalAmount.Caption := FloatToStrF
      (0.00, ffCurrency, 8, 2);
  End;
end;

/// ======================== Checkout Button ==================================
procedure TfrmPointOfSale.btnCheckoutClick(Sender: TObject);
begin
  ShowMessage('Total Amount Due: ' + FloatToStr(rTransactionTotal));
  ShowMessage('Printing till-slip');
  RemoveDuplicates; // 3.)
  DetremineQuantities; // 4.)
  GenerateTransactionID; // 5.)
  CreateTillSlip; // 6.)
  PrintTillSlip; // 7.)
  SaveTransactionToDatabase; // 8.)
end;

/// 3.) ==================== Procedure To Remove Duplicates ===================
procedure TfrmPointOfSale.RemoveDuplicates;
{ Each individual item`s name and unit price (as well as barcode when saved) is
  only shown once on the till slip, and saved once in the database, together with the
  'quantity' bought of each - the duplicates consequently need to be removed }
var
  K: integer;
  iCheck: integer;
  bDup: boolean;
begin
  iNoElemntsWithoutDup := 0;
  for K := 1 to iNoOfElements - 1 do
  Begin
    iCheck := K + 1;
    bDup := False;
    while (iCheck <= iNoOfElements) AND (NOT bDup) do
    begin
      if arrItemNames[K] = arrItemNames[iCheck] then
        bDup := True
      else
        Inc(iCheck);
    end; // while
    if NOT(bDup) then
    begin
      Inc(iNoElemntsWithoutDup);
      arrItemsNoDuplicates[iNoElemntsWithoutDup] := arrItemNames[K];
      arrPricesNoDuplicates[iNoElemntsWithoutDup] := arrUnitPrices[K];
      arrBarcodesNoDuplicates[iNoElemntsWithoutDup] := arrBarcodes[K];
    end;
  End; // for

  // The last item cannot be compared to anythin and has to be added
  Inc(iNoElemntsWithoutDup);
  arrItemsNoDuplicates[iNoElemntsWithoutDup] := arrItemNames[iNoOfElements];
  arrPricesNoDuplicates[iNoElemntsWithoutDup] := arrUnitPrices[iNoOfElements];
  arrBarcodesNoDuplicates[iNoElemntsWithoutDup] := arrBarcodes[iNoOfElements];

  { ///////////// Testing purposes //////////////////
    redTransactionSummary.Lines.Add(
    '===========================================================');
    for K := 1 to iNoElemntsWithoutDup do
    Begin
    redTransactionSummary.Lines.Add(arrItemsNoDuplicates[K] + #9 + FloatToStrF
    (arrPricesNoDuplicates[K], ffCurrency, 8, 2));
    End;
    }
end;

/// 4.) ======= Procedure To Determine The Quantity Of Each Item ==============
procedure TfrmPointOfSale.DetremineQuantities;
{ This procedur checks each item in the array without duplicates, and sees how many
  times each unique record appears in the array with duplicates, in order to determine
  the 'quantity' of that item purchased
  - This needs to be done since each unique item bought is only showed once on the
  till slip and saved once in the database, together with the 'Quantity' of each bought }
var
  K: integer; // Counter - Outer Loop
  sTemp: string;
  L: integer; // Counter - Inner Loop
begin

  for K := 1 to iNoElemntsWithoutDup do
  Begin
    sTemp := arrItemsNoDuplicates[K];
    for L := 1 to iNoOfElements do
    Begin
      if sTemp = arrItemNames[L] then
        arrQTYNoDuplicates[K] := arrQTYNoDuplicates[K] + 1;
    End; // For - inner loop
  End; // For outer loop

  { ///////////// Testing purposes //////////////////
    redTransactionSummary.Lines.Add(
    '===========================================================');
    for K := 1 to iNoElemntsWithoutDup do
    Begin
    redTransactionSummary.Lines.Add(arrItemsNoDuplicates[K] + #9 + IntToStr
    (arrQTYNoDuplicates[K]));
    End;
    redTransactionSummary.Lines.Add(
    '===========================================================');
    }
end;

/// 5.) ====================== Genrate Transaction ID =========================
procedure TfrmPointOfSale.GenerateTransactionID;
var
  iTemp: integer;
  iHighest: integer;
  iNoOfZeros: integer;
  K: integer;
begin
  // Get all of the appropriate TransactionIDs
  with dmDatabase do
  Begin
    dsrTransactions.DataSet := qryTransactions;
    qryTransactions.SQL.Clear;
    qryTransactions.SQL.Add('SELECT AccountID, DateOfTransaction, TransID ');
    qryTransactions.SQL.Add('FROM Transactions ');
    qryTransactions.SQL.Add(' WHERE (AccountID = ' + QuotedStr(sLoggedOnUser)
        + ')');
    qryTransactions.SQL.Add(' AND (DateOfTransaction = ' + QuotedStr
        (sTodaysDate) + ')');
    qryTransactions.SQL.Add(' GROUP BY TransID, AccountID, DateOfTransaction ');
    qryTransactions.Open;

    // Determine the highest item index for the day
    iHighest := 0;
    iTemp := 0;
    while NOT qryTransactions.Eof do
    begin
      iTemp := StrToInt(Copy(qryTransactions['TransID'], 9, 4));
      if iTemp > iHighest then
      Begin
        iHighest := iTemp;
      End;
      qryTransactions.Next;
    end;
    qryTransactions.First;
  End;

  // Fomat all the data into the TransactionID
  sNewTransactionID := Copy(sTodaysDate, 1, 4) + Copy(sTodaysDate, 6, 2) + Copy
    (sTodaysDate, 9, 2);
  iNoOfZeros := 4 - Length(IntToStr(iHighest));
  for K := 1 to iNoOfZeros do
  Begin
    sNewTransactionID := sNewTransactionID + '0';
  End;
  sNewTransactionID := sNewTransactionID + IntToStr(iHighest + 1);
  // Inc Highest
  sNewTransactionID := sNewTransactionID + Copy(sLoggedOnUser, 1, 2);
  // ShowMessage(sNewTransactionID);

end;

/// 6.) =========================== Create Till Slip ==========================
procedure TfrmPointOfSale.CreateTillSlip;
var
  TillSlip: TextFile;
  K: integer;
  rTotalVatEXCL: real;
  rTotalVAT: real;
begin
  AssignFile(TillSlip, sNewTransactionID + '.txt');
  Rewrite(TillSlip);
  Writeln(TillSlip, '');
  Writeln(TillSlip,
    '                              GrowCery                            ');
  Writeln(TillSlip,
    '                           Protea Heights                         ');
  Writeln(TillSlip,
    '                            021 982 4774                          ');
  Writeln(TillSlip, '');
  Writeln(TillSlip, 'Cashier ID: ' + sLoggedOnUser);
  Writeln(TillSlip, 'Cashier Name: ' + sLoggedOnUserName);
  Writeln(TillSlip,
    '=================================================================');
  Writeln(TillSlip, '');
  Writeln(TillSlip,
    'ITEM:                                              QTY:  PRICE:  ');
  // Adds all of the items
  for K := 1 to iNoElemntsWithoutDup do
  Begin
    Writeln(TillSlip, arrItemsNoDuplicates[K], ' ':51 - Length
        (arrItemsNoDuplicates[K]), IntToStr(arrQTYNoDuplicates[K]),
      ' ':6 - Length(IntToStr(arrQTYNoDuplicates[K])), FloatToStr
        (arrPricesNoDuplicates[K]));

  End;
  Writeln(TillSlip, '');
  Writeln(TillSlip, 'TOTAL DUE:', ' ':57 - Length('TOTAL DUE:'), FloatToStr
      (rTransactionTotal));
  /// VAT
  Writeln(TillSlip,
    '============================TAX INVOICE==========================');
  Writeln(TillSlip,
    'VAT RATE:                                                15.00%  ');
  rTotalVatEXCL := rTransactionTotal / (1 + 0.15);
  rTotalVAT := rTransactionTotal - rTotalVatEXCL;
  ///
  Writeln(TillSlip, 'TOTAL VAT INCL:', ' ':57 - Length('TOTAL VAT INCL:'),
    FloatToStr(rTransactionTotal));
  Writeln(TillSlip, 'TOTAL VAT EXCL:', ' ':57 - Length('TOTAL VAT EXCL:'),
    FloatToStrF(rTotalVatEXCL, ffNumber, 8, 2));
  Writeln(TillSlip, 'TOTAL VAT:', ' ':57 - Length('TOTAL VAT:'), FloatToStrF
      (rTotalVAT, ffNumber, 8, 2)); ;
  Writeln(TillSlip, '');
  Writeln(TillSlip, 'Vat No. 49101756960 ');
  Writeln(TillSlip,
    '=================================================================');
  Writeln(TillSlip,
    'Date:                                                 Time:  ');
  Writeln(TillSlip, sTodaysDate, ' ':54 - 10, TimeToStr(Time));
  Writeln(TillSlip,
    '=================================================================');
  Writeln(TillSlip, '                            Thank you');
  Writeln(TillSlip, '                      for shopping with us.');
  CloseFile(TillSlip);

end;

/// 7.) ======================== Print Till Slip ==============================
procedure TfrmPointOfSale.PrintTillSlip;
var
  printDialog: TPrintDialog;
  myPrinter: TPrinter;
  //
  sLine: string;
  tTillSlip: TextFile;
  //
  y: integer; { This variable determines the location of the line on the y-axis
    of the till slip }

begin
  // Create a printer selection dialog
  printDialog := TPrintDialog.Create(frmPointOfSale);
  if printDialog.Execute then
  begin
    myPrinter := printer;
    with myPrinter do
    begin
      // Start the page
      BeginDoc;
      Canvas.Font.Name := 'Consolas';
      Canvas.Font.Size := 9;
      Canvas.Font.Color := clBlack;

      // Find the till slip
      AssignFile(tTillSlip, sNewTransactionID + '.txt');
      Try
        Reset(tTillSlip);
      Except
        ShowMessage(
          'The till slip could not be found. Please request a manager for assistance');
        Exit;
      End;
      // Write out the till slip
      y := 300;
      while NOT Eof(tTillSlip) do
      begin
        Readln(tTillSlip, sLine);
        y := y + 100;
        Canvas.TextOut(200, y, sLine);
      end;
      // Finish printing
      EndDoc;
      CloseFile(tTillSlip);
    end;
  end;
end;

/// 8.) ================= Save Transaction To Database ========================
procedure TfrmPointOfSale.SaveTransactionToDatabase;
{ The functio of this procedure is to save all of the items purchased in the
  transaction into the database }
var
  K: integer;
begin
  with dmDatabase do
  Begin
    tblTransactions.Open;
    tblTransactions.Last;
    tblTransactions.Insert;
    tblTransactions['TransID'] := sNewTransactionID;
    tblTransactions['AccountID'] := sLoggedOnUser;
    tblTransactions['ProcessedBy'] := sLoggedOnUserName;
    tblTransactions['DateOfTransaction'] := sTodaysDate;
    tblTransactions.Post;
    ///
    tblItemTransactions.Open;
    for K := 1 to iNoElemntsWithoutDup do
    Begin
      tblItemTransactions.Last;
      tblItemTransactions.Insert;
      tblItemTransactions['TransID'] := sNewTransactionID;
      tblItemTransactions['Barcode'] := arrBarcodesNoDuplicates[K];
      tblItemTransactions['ItemName'] := arrItemsNoDuplicates[K];
      tblItemTransactions['Quantity'] := arrQTYNoDuplicates[K];
      tblItemTransactions['UnitPrice'] := arrPricesNoDuplicates[K];
      tblItemTransactions.Post;
    end;
  End;
  ShowMessage('Items Added To Database.');
end;

/// ========================= Form Gets Activated =============================
procedure TfrmPointOfSale.FormActivate(Sender: TObject);
var
  sTellarInfo: string;
begin
  sLoggedOnUser := frmTellerHomeScreen.sLoggedOnUser;
  sLoggedOnUserName := frmTellerHomeScreen.sLoggedOnUserName;
  sTodaysDate := frmTellerHomeScreen.sTodaysDate;
  // Get the full name of the logged on user
  // Object to display user information
  objDisplayUserInfo := TDisplayUserInfo.Create(sLoggedOnUser);
  lblTellarInfo.Caption := objDisplayUserInfo.ToString;
  objDisplayUserInfo.Free;
  lblTellarInfo.Caption := lblTellarInfo.Caption + #13 + 'Today`s date: ' +
    sTodaysDate;
  lblTellarInfo.Font.Color := rgb(161, 255, 94);
  //
  DisableButtons;
  //
  with redTransactionSummary do
  begin
    Paragraph.TabCount := 3;
    Paragraph.Tab[0] := 292;
    Paragraph.Tab[1] := 330;
    Font.Size := 9;
  end;
  imgLogo.Height := 83;
end;

/// =============== Procedure That Disables All Of The Buttons ================

procedure TfrmPointOfSale.DisableButtons;
begin
  btnNewSale.Enabled := True;
  btnVoidSale.Enabled := False;
  btnAddItem.Enabled := False;
  btnCheckout.Enabled := False;
  btn0.Enabled := False;
  btn1.Enabled := False;
  btn2.Enabled := False;
  btn3.Enabled := False;
  btn4.Enabled := False;
  btn5.Enabled := False;
  btn6.Enabled := False;
  btn7.Enabled := False;
  btn8.Enabled := False;
  btn9.Enabled := False;
  redTransactionSummary.Lines.Clear;
end;

/// ============================== Form Gets Closed ===========================
procedure TfrmPointOfSale.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ShowMessage('Ending your shift.');
  // The user closes the form while a sale is still in progress
  if rTransactionTotal > 0 then
  Begin
    MessageDlg('You are leaving while a sale is still in progress.' + #13 +
        'THE CURRENT SALE WILL BE VOIDED', mtWarning, [mbOK], 0);
    VoidCurrentSale;
  end;
  frmTellerHomeScreen.Show;
end;

/// ============================= Void Sale Button ============================
procedure TfrmPointOfSale.btnVoidSaleClick(Sender: TObject);
begin
  begin
    if MessageDlg(' Are you sure you want to void the current sale ?',
      mtWarning, [mbYes, mbCancel], 0) = mrYes then
    begin
      VoidCurrentSale;
    end
    else
      Exit
  end;
end;

/// ==================== Void Current Sale Procedure ==========================
procedure TfrmPointOfSale.VoidCurrentSale;
begin
  ShowMessage('VOIDING SALE.');
  DisableButtons;
  /// CLEAR THE ARRAYS
  ClearArrays;
  redTransactionSummary.Lines.Clear;
  /// Set Total back to 0 and display it
  rTransactionTotal := 0;
  UpdateSaleTotal;
  ShowMessage('Sale Successfully voided');
end;

/// ==================== Procedure To Clear The Arrays ========================
procedure TfrmPointOfSale.ClearArrays;
var
  i: integer;
begin
  for i := 1 to iNoOfElements do
  Begin
    arrItemNames[i] := '';
    arrUnitPrices[i] := 0;
    arrBarcodes[i] := '';
  End;
  iNoOfElements := 0;
end;

/// =========================== Form Gets Shown ===============================
procedure TfrmPointOfSale.FormShow(Sender: TObject);
begin
  with dmDatabase do
  begin
    tblItems.Open;
    tblItems.First;
  end;
  iNoOfElements := 0;
end;

/// =================== Search For A Spesific Barcode =========================
procedure TfrmPointOfSale.edtBarcodeChange(Sender: TObject);
{ This porcedure is used to search, and filter the table of items, to
  display the smilar barcodes, as the user types a barcode into the edit field }
begin
  if (edtBarcode.Text <> '') then
  Begin
    dmDatabase.tblItems.Filter := 'Barcode LIKE ''' + (edtBarcode.Text)
      + '%''     ';
    dmDatabase.tblItems.Filtered := True;
  End
  else
  begin
    dmDatabase.tblItems.Filtered := False;
  end;
end;

/// ============================= Buttons 0 - 9 ===============================
procedure TfrmPointOfSale.btn0Click(Sender: TObject);
begin
  edtBarcode.Text := edtBarcode.Text + '0';
end;

procedure TfrmPointOfSale.btn1Click(Sender: TObject);
begin
  edtBarcode.Text := edtBarcode.Text + '1';
end;

procedure TfrmPointOfSale.btn2Click(Sender: TObject);
begin
  edtBarcode.Text := edtBarcode.Text + '2';
end;

procedure TfrmPointOfSale.btn3Click(Sender: TObject);
begin
  edtBarcode.Text := edtBarcode.Text + '3';
end;

procedure TfrmPointOfSale.btn4Click(Sender: TObject);
begin
  edtBarcode.Text := edtBarcode.Text + '4';
end;

procedure TfrmPointOfSale.btn5Click(Sender: TObject);
begin
  edtBarcode.Text := edtBarcode.Text + '5';
end;

procedure TfrmPointOfSale.btn6Click(Sender: TObject);
begin
  edtBarcode.Text := edtBarcode.Text + '6';
end;

procedure TfrmPointOfSale.btn7Click(Sender: TObject);
begin
  edtBarcode.Text := edtBarcode.Text + '7';
end;

procedure TfrmPointOfSale.btn8Click(Sender: TObject);
begin
  edtBarcode.Text := edtBarcode.Text + '8';
end;

procedure TfrmPointOfSale.btn9Click(Sender: TObject);
begin
  edtBarcode.Text := edtBarcode.Text + '9';
end;

/// ========================== Backspace Button ===============================
procedure TfrmPointOfSale.btnBackspaceClick(Sender: TObject);
begin
  edtBarcode.Text := Copy(edtBarcode.Text, 1, Length(edtBarcode.Text) - 1);
end;

/// ========================== Exit POS Button ================================
procedure TfrmPointOfSale.btnEndShiftClick(Sender: TObject);
begin
  if MessageDlg(' Are you sure you want exit your POS ?', mtConfirmation,
    [mbYes, mbCancel], 0) = mrYes then
  begin
    frmPointOfSale.Close;
  end
  else
    Exit
end;

end.
