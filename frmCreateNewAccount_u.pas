// ##################################
// ######     IT PAT 2018     #######
// ######      GrowCery       #######
// ######  Tiaan van der Riel #######
// ##################################
unit frmCreateNewAccount_u;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, pngimage, ExtCtrls, StdCtrls, Spin;

type
  TfrmCreateNewAccount = class(TForm)
    rbMale: TRadioButton;
    rbFemale: TRadioButton;
    lblDateOfBirth: TLabel;
    spnedtYearOfBirth: TSpinEdit;
    cbxMonth: TComboBox;
    spnedtDayOfBirth: TSpinEdit;
    lblGenderM: TLabel;
    lblGenderF: TLabel;
    lblGender: TLabel;
    lbledtName: TLabeledEdit;
    lbledtSurname: TLabeledEdit;
    lbledtID: TLabeledEdit;
    lbledtEmailAdress: TLabeledEdit;
    lbledtCellphoneNumber: TLabeledEdit;
    lbledtPassword: TLabeledEdit;
    lbledtRetypePassword: TLabeledEdit;
    btnCreateAccount: TButton;
    btnBack: TButton;
    imgCreateNewAccountBackground: TImage;
    pnlLabels: TPanel;
    imgCreateNewAccountHeading: TImage;
    rgpGrantAdminRights: TRadioGroup;
    spnEdtAssignedTill: TSpinEdit;
    lblAssighnedTill: TLabel;
    btnHelp: TButton;
    procedure btnBackClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCreateAccountClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure rgpGrantAdminRightsClick(Sender: TObject);
  private
    { Private declarations }
    sAccountID: string;
    sName: string;
    sSurname: string;
    bIsAdmin: boolean;
    iAssighnedTill: integer;
    iIDNumber: integer;
    sGender: string;
    sEmailAdress: string;
    sCellphoneNumber: string;
    sPassword: string;
    sPleaseRetypePassword: string;
    iEnteredBirthDay: integer;
    iEnteredBirthMonth: integer;
    iEnteredBirthYear: integer;
    iAdminRigthsIndex: integer;
    sNewAccountID: string;
    /// ============= Custom Procedures =========///
    procedure ResetAll; // Resets form to the way it initially looked
    procedure ShowHelp; // Shows the user a help file
    procedure ShowHelpAfterIncorrectAttempt; //

    // ========= Custom Functions ===============//
    Function IsAllFieldsPresent: boolean; // 1.)  Determines if all fields are entered
    Function IsNameValid: boolean; // 2.) Determines if name is valid
    Function IsSurnameValid: boolean; // 3.) Determine if surname is valid
    Function IsCellphoneNumberValid: boolean; // 4.) Determines if cellphone number is 10 DIGITS long
    Function IsPasswordValid: boolean; // 5.) Checks that password is at least 8 characters long, and contains at least
    // one uppercase letter, one lowercase letter and at least one number.
    // ====== Functions for ID Validation ====== //
    Function IsIDNumberValidNumbers: boolean; // 6.) Function that checks that the ID Number contains only numbers and is 13 digits long
    Function IsIDNumberValidBirthDate: boolean; // 7.)  Checks that the user`s enterd bithdates match ID
    Function IsIDNumberValidGender: boolean; // 8. ) Checks that the user`s gender matches his ID`s
    Function IsIDNumberValidCheckDigit: boolean; // 9.) Checks that the check digit validates according to Luhn`s equation
    //
    Function DeterminePlayerAge: integer; // 10.) Determines the user`s age
    //
    Function GenerateAccountID: string; // 11.) Generates a new, unique AccountID for the new user.
    //
    procedure SaveDataToDatabase; // 12.) Saves all of the new user`s data to the database
  public
    { Public declarations }
  end;

var
  frmCreateNewAccount: TfrmCreateNewAccount;

implementation

uses
  frmAdminHomeScreen_u, dmDatabase_u;
{$R *.dfm}

/// =================== Create New Account Button Click =======================
procedure TfrmCreateNewAccount.btnCreateAccountClick(Sender: TObject);
{ The function of this code is to initialise the checking of all of the criteria
  and then, if all criteria are met, initialise the creation of a new account, or,
  if one is not met, initialise the showing of an error message and a help file }
var
  bAllFieldsEntered: boolean;
  bNamevalid: boolean;
  bSurnamevalid: boolean;
  bCellphoneNumberValid: boolean;
  bPasswordValid: boolean;
  // Boolaens calling functions for ID Validation
  bIDNumberValidNumbers: boolean;
  bIDNumberValidBirthDate: boolean;
  bIDNumberValidGender: boolean;
  bIDNumberValidCheckDigit: boolean;
  // Gets calculated when user`s account gets created

  // Determine from function
  iPlayersAge: integer;

begin

  // 1.) Presence check
  bAllFieldsEntered := IsAllFieldsPresent; // Calls function
  if bAllFieldsEntered = False then
  begin
    ShowHelpAfterIncorrectAttempt;
    Exit;
  end;
  // ================================================
  // 2.) Name Valid
  bNamevalid := IsNameValid; // Calls function
  if bNamevalid = False then
  begin
    ShowHelpAfterIncorrectAttempt;
    Exit;
  end;
  // ================================================
  // 3.) Surname Valid
  bSurnamevalid := IsSurnameValid; // Calls function
  if bSurnamevalid = False then
  begin
    ShowHelpAfterIncorrectAttempt;
    Exit;
  end;
  // ================================================
  // 4.) Cellphone Number Valid
  bCellphoneNumberValid := IsCellphoneNumberValid;
  if bCellphoneNumberValid = False then
  begin
    ShowHelpAfterIncorrectAttempt;
    Exit;
  end;
  // ================================================
  // 5.) Password Valid
  bPasswordValid := IsPasswordValid;
  if bPasswordValid = False then
  begin
    ShowHelpAfterIncorrectAttempt;
    Exit;
  end;
  // Password Retype
  sPleaseRetypePassword := lbledtRetypePassword.Text;
  if NOT(sPleaseRetypePassword = sPassword) then
  begin
    ShowMessage(
      'One of your passwords was entered incorectly and they don`t match.');
    if MessageDlg(
      'You entered your information incorrectly. Would you like to veiw help as to how to enter your information ?', mtInformation, [mbYes, mbNo], 0) = mrYes then
    Begin
      ShowHelp;
    End
    Else
    Begin
      Exit;
    End;
  end;
  // ================================================
  // 6.) Is ID Numeber valid - Only Numbers + correct lenght
  bIDNumberValidNumbers := IsIDNumberValidNumbers;
  if bIDNumberValidNumbers = False then
  begin
    ShowHelpAfterIncorrectAttempt;
    Exit;
  end;
  // ================================================
  // 7.) Checks that the user`s enterd bithdates match ID
  bIDNumberValidBirthDate := IsIDNumberValidBirthDate;
  if bIDNumberValidBirthDate = False then
  begin
    ShowHelpAfterIncorrectAttempt;
    Exit;
  end;
  // ================================================
  // 8.) Checks that the user`s gender matches his ID
  bIDNumberValidGender := IsIDNumberValidGender;
  if bIDNumberValidGender = False then
  begin
    ShowHelpAfterIncorrectAttempt;
    Exit;
  end;
  // ================================================
  // 9.) Checks that the check digit matches what it should be according to Luhn`s equation
  bIDNumberValidCheckDigit := IsIDNumberValidCheckDigit;
  if bIDNumberValidCheckDigit = False then
  begin
    ShowHelpAfterIncorrectAttempt;
    Exit;
  end;

  // Get Gender
  if rbFemale.Checked = True then
    sGender := 'F';
  if rbMale.Checked = True then
    sGender := 'M';

  // Determine the user`s age and check that he/she is at least 16 years old
  iPlayersAge := DeterminePlayerAge;
  if iPlayersAge < 16 then
  Begin
    ShowMessage('The applicant is currently ' + IntToStr(iPlayersAge) +
        ' years of age. Employees need to be at least 16 years of age.');
    Exit;
  End;

  /// Checks that user entered if the new account is a Admin or not
  iAdminRigthsIndex := rgpGrantAdminRights.ItemIndex;
  if (iAdminRigthsIndex < 0) OR (iAdminRigthsIndex > 1) then
  Begin
    begin
      ShowHelpAfterIncorrectAttempt;
      Exit;
    end;
  End;

  // Generate a new, unique Account ID for the user
  sAccountID := GenerateAccountID;
  //
  ShowMessage('Your new Account ID is: ' + sAccountID + #13 +
      'NB Please make sure to remember your Account ID and Password.');
  //
  SaveDataToDatabase;
  /// Saves all of the data
  //
  ResetAll; // Resets all of the fields

end;

/// 1.) ======== Function to detirmine if all fields are entered ==============
function TfrmCreateNewAccount.IsAllFieldsPresent: boolean;
{ The purpose of this procedure is to determine if all of the fields are
  entered }
begin
  IsAllFieldsPresent := True;

  // Name
  sName := lbledtName.Text;
  if sName = '' then
  Begin
    ShowMessage('Please enter a name.');
    lbledtName.EditLabel.Font.Color := clRed;
    lbledtName.EditLabel.Caption := '*** Name:';
    IsAllFieldsPresent := False;
  End;
  // Surname
  sSurname := lbledtSurname.Text;
  if sSurname = '' then
  Begin
    ShowMessage('Please enter a surname.');
    lbledtSurname.EditLabel.Font.Color := clRed;
    lbledtSurname.EditLabel.Caption := '*** Surname:';
    IsAllFieldsPresent := False;
  End;
  // ID Number
  if lbledtID.Text = '' then
  Begin
    ShowMessage('Please enter a ID');
    lbledtID.EditLabel.Font.Color := clRed;
    lbledtID.EditLabel.Caption := '*** ID:';
    IsAllFieldsPresent := False;
  End;
  // Gender
  if (rbMale.Checked = False) AND (rbFemale.Checked = False) then
  Begin
    ShowMessage('Please select a gender. ');
    lblGender.Font.Color := clRed;
    lblGender.Caption := '*** Gender:';
    IsAllFieldsPresent := False;
  End;
  // Email
  sEmailAdress := lbledtEmailAdress.Text;
  if sEmailAdress = '' then
  Begin
    ShowMessage('Please enter a Email Adress.');
    lbledtEmailAdress.EditLabel.Font.Color := clRed;
    lbledtEmailAdress.EditLabel.Caption := '*** Email Aress:';
    IsAllFieldsPresent := False;
  End;
  // Cellphone Number
  sCellphoneNumber := lbledtCellphoneNumber.Text;
  if sCellphoneNumber = '' then
  Begin
    ShowMessage('Please enter a Cellphone Number.');
    lbledtCellphoneNumber.EditLabel.Font.Color := clRed;
    lbledtCellphoneNumber.EditLabel.Caption := '*** Cellphone Number:';
    IsAllFieldsPresent := False;
  End;
  // Password
  sPassword := lbledtPassword.Text;
  if sPassword = '' then
  Begin
    ShowMessage('Please enter a password.');
    lbledtPassword.EditLabel.Font.Color := clRed;
    lbledtPassword.EditLabel.Caption := '*** Password:';
    IsAllFieldsPresent := False;
  End;
  // Please Retype Password
  sPleaseRetypePassword := lbledtRetypePassword.Text;
  if sPleaseRetypePassword = '' then
  Begin
    ShowMessage('Please retype your password.');
    lbledtRetypePassword.EditLabel.Font.Color := clRed;
    lbledtRetypePassword.EditLabel.Caption :=
      '*** Please Retype Your Password:';
    IsAllFieldsPresent := False;
  End;
  // Grant Admin Rights
  if rgpGrantAdminRights.ItemIndex = -1 then
  begin
    ShowMessage(
      'Please select whether or not you want this user to have admin rights.');
    IsAllFieldsPresent := False;
  end;

end;

/// 2.) ================ Function to detirmine is name is valid ===============
function TfrmCreateNewAccount.IsNameValid: boolean;
{ This function checks that the name contains only letters and spaces }
var
  i: integer;
begin
  IsNameValid := True;

  sName := lbledtName.Text;
  for i := 1 to Length(sName) do
  Begin
    sName[i] := Upcase(sName[i]);
    if not(sName[i] in ['A' .. 'Z']) AND (sName[i] <> ' ') then
    begin
      ShowMessage('Your name can only contain letters and spaces.');
      lbledtName.EditLabel.Font.Color := clRed;
      lbledtName.EditLabel.Caption := '*** Name:';
      IsNameValid := False;
    end;
  End;
  sName := lbledtName.Text;
end;

/// 3.) ============= Function to determine if surname is valid ===============
function TfrmCreateNewAccount.IsSurnameValid: boolean;
{ This function checks that the surname contains only letters and spaces }
var
  i: integer;
begin
  IsSurnameValid := True;

  sSurname := lbledtSurname.Text;
  for i := 1 to Length(sSurname) do
  Begin
    sSurname[i] := Upcase(sSurname[i]);
    if not(sSurname[i] in ['A' .. 'Z']) AND (sSurname[i] <> ' ') then
    begin
      ShowMessage('Your surname can only contain letters and spaces.');
      lbledtSurname.EditLabel.Font.Color := clRed;
      lbledtSurname.EditLabel.Caption := '*** Surname:';
      IsSurnameValid := False;
    end;
  End;
  sSurname := lbledtSurname.Text;
end;

/// 4.) == Function that determines if cellphone number is 10 DIGITS long =====
function TfrmCreateNewAccount.IsCellphoneNumberValid: boolean;
{ This function checks that the cellphone number is 10 digits long, and contains
  only numbers }
var
  i: integer;
begin
  IsCellphoneNumberValid := True;
  sCellphoneNumber := lbledtCellphoneNumber.Text;

  if Length(sCellphoneNumber) <> 10 then
  Begin
    ShowMessage('Your cellphone number is not the correct lenght.');
    lbledtCellphoneNumber.EditLabel.Font.Color := clRed;
    lbledtCellphoneNumber.EditLabel.Caption := '*** Cellphone Number:';
    IsCellphoneNumberValid := False;
  End;

  for i := 1 to Length(sCellphoneNumber) do
  Begin
    if NOT(sCellphoneNumber[i] In ['0' .. '9']) then
    Begin
      ShowMessage('Your cellphone number can only contain numbers.');
      lbledtCellphoneNumber.EditLabel.Font.Color := clRed;
      lbledtCellphoneNumber.EditLabel.Caption := '*** Cellphone Number:';
      IsCellphoneNumberValid := False;
    end;

  end;
end;

/// 5.) ================ Function that validates password ====================
function TfrmCreateNewAccount.IsPasswordValid: boolean;
{ Checks that password is at least 8 characters long, and contaains at least
  one uppercase letter, one lowercase letter and at least one number. }
var
  i: integer;
  bContainsUppercase: boolean;
  bContainsLowercase: boolean;
  bContainsNumber: boolean;
begin
  IsPasswordValid := True;
  sPassword := lbledtPassword.Text;

  if Length(sPassword) < 8 then
  Begin
    ShowMessage('Your password needs to be at least 8 characters long.');
    lbledtPassword.EditLabel.Font.Color := clRed;
    lbledtPassword.EditLabel.Caption := '*** Password:';
    IsPasswordValid := False;
  End;

  bContainsUppercase := False;
  bContainsLowercase := False;
  bContainsNumber := False;
  for i := 1 to Length(sPassword) do
  Begin
    if sPassword[i] IN ['a' .. 'z'] then
    Begin
      bContainsLowercase := True;
    End;
    if sPassword[i] IN ['A' .. 'Z'] then
    Begin
      bContainsUppercase := True;
    End;
    if sPassword[i] IN ['0' .. '9'] then
    Begin
      bContainsNumber := True;
    End;
  end;

  if bContainsUppercase = False then
    ShowMessage('Your password does not contain an uppercase letter.');
  if bContainsLowercase = False then
    ShowMessage('Your password does not contain a lowercase letter.');
  if bContainsNumber = False then
    ShowMessage('Your password does not contain a number letter.');

  if (bContainsUppercase = False) OR (bContainsLowercase = False) OR
    (bContainsNumber = False) then
  Begin
    ShowMessage(
      'Your password needs to contain at least one uppercase letter, lowercase letter and number.');
    lbledtPassword.EditLabel.Font.Color := clRed;
    lbledtPassword.EditLabel.Caption := '*** Password:';
    IsPasswordValid := False;
  End;
end;

/// 6.) ==== Function that checks that the ID Number contains only numbers
// and is 13 digits long =====================================================
function TfrmCreateNewAccount.IsIDNumberValidNumbers: boolean;
var
  sEnteredID: string;
  i: integer;
begin
  IsIDNumberValidNumbers := True;
  // Checks that ID Number only contains numbers
  sEnteredID := lbledtID.Text;
  i := 0;
  for i := 1 to Length(sEnteredID) do
  Begin
    if NOT(sEnteredID[i] In ['0' .. '9']) then
    Begin
      ShowMessage('Your ID number can only contain numbers.');
      lbledtID.EditLabel.Font.Color := clRed;
      lbledtID.EditLabel.Caption := '*** ID Number:';
      IsIDNumberValidNumbers := False;
    end;
  End;

  if Length(sEnteredID) <> 13 then
  Begin
    ShowMessage('Your ID number must be 13 digits long.');
    lbledtID.EditLabel.Font.Color := clRed;
    lbledtID.EditLabel.Caption := '*** ID Number:';
    IsIDNumberValidNumbers := False;
  End;
end;

// 7.) ============ Checks that the user`s enterd bithdates match ID  =========
function TfrmCreateNewAccount.IsIDNumberValidBirthDate: boolean;
{ This function determines what the user`s bith date is suppose to be according
  to his ID, and then checks to see that the match }
var
  iIDday: integer;
  iIDmonth: integer;
  sIDyear: string;
  iIDYear: integer;
  sIDNumber: string;

begin
  IsIDNumberValidBirthDate := True;
  // Gets User entered birth information
  iEnteredBirthDay := StrToInt(spnedtDayOfBirth.Text);
  iEnteredBirthMonth := cbxMonth.ItemIndex + 1;
  iEnteredBirthYear := StrToInt(spnedtYearOfBirth.Text);
  // Gets birth dates from ID Number
  sIDNumber := lbledtID.Text;
  iIDday := StrToInt(Copy(sIDNumber, 5, 2));
  iIDmonth := StrToInt(Copy(sIDNumber, 3, 2));
  sIDyear := Copy(sIDNumber, 1, 2);
  if StrToInt(sIDyear) IN [0 .. 18] then
    iIDYear := 2000 + StrToInt(sIDyear)
  else
    iIDYear := 1900 + StrToInt(sIDyear);
  // Compares the two
  // Day
  if iEnteredBirthDay <> iIDday then
  Begin
    ShowMessage('Your ID number`s day of birth does not match your birth day.');
    lbledtID.EditLabel.Font.Color := clRed;
    lbledtID.EditLabel.Caption := '*** ID Number:';
    IsIDNumberValidBirthDate := False;
  End;
  // Month
  if iEnteredBirthMonth <> iIDmonth then
  Begin
    ShowMessage(
      'Your ID number`s month of birth does not match your birth month.');
    lbledtID.EditLabel.Font.Color := clRed;
    lbledtID.EditLabel.Caption := '*** ID Number:';
    IsIDNumberValidBirthDate := False;
  End;
  // Year
  if iEnteredBirthYear <> iIDYear then
  Begin
    ShowMessage
      ('Your ID number`s year of birth does not match your birth year.');
    lbledtID.EditLabel.Font.Color := clRed;
    lbledtID.EditLabel.Caption := '*** ID Number:';
    IsIDNumberValidBirthDate := False;
  End;
end;

// 8.) =========== Checks that the user`s gender matches his ID`s =============
function TfrmCreateNewAccount.IsIDNumberValidGender: boolean;
{ This function determines what the user`s gender is suppose to be according
  to his ID, and then checks to see that the match }
var
  sEnteredID: string;

begin
  IsIDNumberValidGender := True;
  sEnteredID := lbledtID.Text;

  if NOT(((StrToInt(sEnteredID[7]) > 4) AND (rbMale.Checked = True)) OR
      ((StrToInt(sEnteredID[7]) < 4) AND (rbFemale.Checked = True))) then
  begin
    ShowMessage('Your ID number does not match your gender.');
    lbledtID.EditLabel.Font.Color := clRed;
    lbledtID.EditLabel.Caption := '*** ID Number:';
    IsIDNumberValidGender := False;
  end;
end;

// 9.) ============== Function that validates that the check digit matches
// what it should be according to Luhn`s equation ==================
function TfrmCreateNewAccount.IsIDNumberValidCheckDigit: boolean;
{ This function calculates the what the user`s check digit is suppose to be
  according to Luhn`s formula, and then checks to see wheter or not it matches the
  user`s enered ID check digit }
var
  i: integer;
  iSumOdds: integer;
  iSumEvens: integer;
  iTotal: integer;
  iCheck: integer;
  sEvens: string;
  sNumFromEvens: string;
  sEnteredID: string;

begin
  IsIDNumberValidCheckDigit := True;
  sEnteredID := lbledtID.Text;

  // Calculate the sum of all the odd digits in the Id number - excluding the last one
  i := 1;
  iSumOdds := 0;
  while i <= 11 do
  begin
    iSumOdds := iSumOdds + StrToInt(sEnteredID[i]);
    Inc(i, 2);
  end;

  // Create a new number: Using the even positions and multiplying the number by 2
  sEvens := '';
  i := 2;
  while i <= 12 do
  begin
    sEvens := sEvens + sEnteredID[i];
    Inc(i, 2);
  end;
  sNumFromEvens := IntToStr(StrToInt(sEvens) * 2);

  // Add up all the digits in this new number
  iSumEvens := 0;
  for i := 1 to Length(sNumFromEvens) do
  begin
    iSumEvens := iSumEvens + StrToInt(sNumFromEvens[i]);
  end;

  // Add the two numbers
  iTotal := iSumOdds + iSumEvens;

  // Subtract the second digit form 10
  iCheck := (iTotal MOD 10);
  if iCheck = 0 then
  begin
    iCheck := 10;
  end;
  iCheck := 10 - iCheck;

  // Check if the calculated check digit matches the last digit in the ID Number
  if Not(iCheck = StrToInt(sEnteredID[13])) then
  Begin
    ShowMessage
      ('Your ID Number is incorrect. Please re-enter it and try again.');
    lbledtID.EditLabel.Font.Color := clRed;
    lbledtID.EditLabel.Caption := '*** ID Number:';
    IsIDNumberValidCheckDigit := False;
  End;
end;

// 10.)  ============ Function that determines the user`s age =================
function TfrmCreateNewAccount.DeterminePlayerAge: integer;
var
  iDay: integer;
  iMonth: integer;
  iYear: integer;
  sToday: string;
  iThisDay, iThisMonth, iThisYear: integer;
  iAge: integer;
begin
  // Gets User entered birth information
  iDay := StrToInt(spnedtDayOfBirth.Text);
  iMonth := cbxMonth.ItemIndex + 1;
  iYear := StrToInt(spnedtYearOfBirth.Text);
  // Determine Today`s date
  sToday := DateToStr(Date);
  iThisDay := StrToInt(Copy(sToday, 9, 2));
  iThisMonth := StrToInt(Copy(sToday, 6, 2));
  iThisYear := StrToInt(Copy(sToday, 1, 4));
  // Calculate the age the person will become this year
  iAge := iThisYear - iYear;
  // Determine if the person has already had his/her birthday
  if iMonth > iThisMonth then // birthday will be later this year
    Dec(iAge)
  else if iMonth = iThisMonth then // test if birthday is later in the month or has already happened
    if iDay > iThisDay then // bithday will be later in the MonthDays
      Dec(iAge);
  Result := iAge;
  // ShowMessage(IntToStr(iAge));
end;

// 11. ) ============ Create a new account ID for the user ====================
function TfrmCreateNewAccount.GenerateAccountID;
{ This procedure creates a unique account ID for the new account }
var
  iHighest: integer;
  iTemp: integer;
  sHighestWithZeros: string;
begin

  // Determine the highest item index for the day
  iHighest := 0;
  iTemp := 0;
  with dmDatabase Do
  Begin
    tblAccounts.First;
    while NOT tblAccounts.Eof do
    begin
      iTemp := StrToInt(Copy(tblAccounts['AccountID'], 3, 3));
      if iTemp > iHighest then
      Begin
        iHighest := iTemp;
      End;
      tblAccounts.Next;
    end;
    tblAccounts.First;
  end;
  sNewAccountID := Copy(sName, 1, 1) + Copy(sSurname, 1, 1);
  sHighestWithZeros := IntToStr(iHighest + 1);
  // Ads zeros
  if Length(sHighestWithZeros) = 1 then
    sHighestWithZeros := '00' + sHighestWithZeros;
  if Length(sHighestWithZeros) = 2 then
    sHighestWithZeros := '0' + sHighestWithZeros;

  sNewAccountID := sNewAccountID + sHighestWithZeros;
  // Checks wether the user is an admin or not
  if iAdminRigthsIndex = 0 then
    sNewAccountID := sNewAccountID + 'A';
  if iAdminRigthsIndex = 1 then
    sNewAccountID := sNewAccountID + 'T';
  // ShowMessage(sNewAccountID);
  Result := sNewAccountID;
end;

// 12.) ========= Save New User`s Date To The Database ========================
procedure TfrmCreateNewAccount.SaveDataToDatabase;
begin
  with dmDatabase do
  Begin
    tblAccounts.Open;
    tblAccounts.Last;
    tblAccounts.Insert;
    tblAccounts['AccountID'] := sNewAccountID;
    tblAccounts['Name'] := sName;
    tblAccounts['Surname'] := sSurname;
    if iAdminRigthsIndex = 0 then // User is an Admin
    Begin
      tblAccounts['IsAdmin'] := True;
      tblAccounts['AssignedTill'] := '0';
    End;
    if iAdminRigthsIndex = 1 then // User is a Teller
    Begin
      tblAccounts['IsAdmin'] := False;
      tblAccounts['AssignedTill'] := IntToStr(spnEdtAssignedTill.Value);
    End;
    tblAccounts['CellphoneNumber'] := sCellphoneNumber;
    tblAccounts['EmailAdress'] := sEmailAdress;
    tblAccounts['Gender'] := sGender;
    tblAccounts['IDNumber'] := lbledtID.Text;
    tblAccounts['Password'] := sPassword;
    tblAccounts.Post;
    ///
    Beep;
    ShowMessage('Details Successfully Saved.' + #13 +
        'Welcome To The GrowCery Family');
  end;
end;

/// ========================= Procedure ResetAll ==============================
procedure TfrmCreateNewAccount.ResetAll;
begin
  // Name
  lbledtName.EditLabel.Font.Color := clBlack;
  lbledtName.EditLabel.Caption := 'Name:';
  lbledtName.Text := '';
  // Surname
  lbledtSurname.EditLabel.Font.Color := clBlack;
  lbledtSurname.EditLabel.Caption := 'Surname:';
  lbledtSurname.Text := '';
  // ID
  lbledtID.EditLabel.Font.Color := clBlack;
  lbledtID.EditLabel.Caption := 'ID Number:';
  lbledtID.Text := '';
  // Gender
  lblGender.Font.Color := clBlack;
  lblGender.Caption := 'Gender: ';
  rbFemale.Checked := False;
  rbMale.Checked := False;
  // Email
  lbledtEmailAdress.EditLabel.Font.Color := clBlack;
  lbledtEmailAdress.EditLabel.Caption := 'Email Adress:';
  lbledtEmailAdress.Text := '';
  // Cellphone Number
  lbledtCellphoneNumber.EditLabel.Font.Color := clBlack;
  lbledtCellphoneNumber.EditLabel.Caption := 'Cellphone Number:';
  lbledtCellphoneNumber.Text := '';
  // Password
  lbledtPassword.EditLabel.Font.Color := clBlack;
  lbledtPassword.EditLabel.Caption := 'Password:';
  lbledtPassword.Text := '';
  // Please Retype Your Password
  lbledtRetypePassword.EditLabel.Font.Color := clBlack;
  lbledtRetypePassword.EditLabel.Caption := 'Please Retype Your Password:';
  lbledtRetypePassword.Text := '';
  // Grant Admin Rights
  rgpGrantAdminRights.ItemIndex := -1;

end;

/// =========================== Shows The User A Help File ====================
procedure TfrmCreateNewAccount.ShowHelp;
var
  tHelp: TextFile;
  sLine: string;
  sMessage: string;

begin
  sMessage := '========================================';
  AssignFile(tHelp, 'Help_CreateNewAccount.txt');

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
End;

/// =============== Show user help after incorrect attempt ===================
procedure TfrmCreateNewAccount.ShowHelpAfterIncorrectAttempt;
begin
  if MessageDlg(
    'You entered your information incorrectly. Would you like to veiw help as to how to enter your information ?', mtInformation, [mbYes, mbNo], 0) = mrYes then
  Begin
    ShowHelp;
  End
  Else
  Begin
    Exit;
  End;
end;

/// ============================== Back Button ================================
procedure TfrmCreateNewAccount.btnBackClick(Sender: TObject);

begin

  begin
    if MessageDlg(' Are you sure you want to return to your home page ?',
      mtConfirmation, [mbYes, mbCancel], 0) = mrYes then
    begin
      frmCreateNewAccount.Close;
    end
    else
      Exit
  end;
end;

/// ============================= Help Button Click ===========================
procedure TfrmCreateNewAccount.btnHelpClick(Sender: TObject);
begin
  ShowHelp;
end;

/// ========================== Form Gets  Closed ==============================
procedure TfrmCreateNewAccount.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  ResetAll;
  frmAdminHomeScreen.Show;
end;

/// ==================== User Selects Type Of Accout ==========================
procedure TfrmCreateNewAccount.rgpGrantAdminRightsClick(Sender: TObject);
begin
  if rgpGrantAdminRights.ItemIndex = 0 then
    spnEdtAssignedTill.Enabled := False;
  if rgpGrantAdminRights.ItemIndex = 1 then
    spnEdtAssignedTill.Enabled := True;
end;

/// ============================== Form Gets Created ==========================
procedure TfrmCreateNewAccount.FormCreate(Sender: TObject);
begin
  pnlLabels.Color := rgb(139, 198, 99);
end;

end.
