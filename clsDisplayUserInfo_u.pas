// ##################################
// ######     IT PAT 2018     #######
// ######      GrowCery       #######
// ######  Tiaan van der Riel #######
// ##################################
unit clsDisplayUserInfo_u;

interface

uses
  SysUtils;

type
  TDisplayUserInfo = class(TObject)

  private
    fUserAccountID: string;
  public
    constructor Create(sUserAccountID: string);
    function GetUserAccountID: string;
    function TOString: string;
  end;

implementation

uses
  dmDatabase_u;

{ TDisplayUserInfo }

constructor TDisplayUserInfo.Create(sUserAccountID: string);
begin
  fUserAccountID := sUserAccountID;
end;

function TDisplayUserInfo.GetUserAccountID: string;
begin
  Result := fUserAccountID;
end;

function TDisplayUserInfo.TOString: string;
var
  sString: string;
begin
  with dmDatabase do
  Begin
    qryAccounts.SQL.Clear;
    qryAccounts.SQL.Add(
      'SELECT AccountID, Name, Surname, IsAdmin, AssignedTill ');
    qryAccounts.SQL.Add('FROM Accounts ');
    qryAccounts.SQL.Add('WHERE AccountID = "' + fUserAccountID + '"');
    qryAccounts.Open;

    /// Get data from SQL
    sString := 'Logged On User: ' + qryAccounts['Name'] + ' ' + qryAccounts
      ['Surname'] + #13;
    sString := sString + 'Account ID: ' + qryAccounts['AccountID'] + #13;
    if qryAccounts['IsAdmin'] = FALSE then
    begin
      sString := sString + 'Allocated Cash Register: ' + IntToStr
        (qryAccounts['AssignedTill']) + #13;
    end;
    sString := sString + 'GrowCery - Protea Heights Branch' ;
    if qryAccounts['IsAdmin'] = TRUE then
    begin
      sString := sString + #13 + '*** Administrative Rights Granted';
    end;
  End; // With

  Result := sString;
end;

end.
