program GrowCery_p;

uses
  Forms,
  frmGrowCery_u in 'frmGrowCery_u.pas' {frmWelcome},
  frmAdminHomeScreen_u in 'frmAdminHomeScreen_u.pas' {frmAdminHomeScreen},
  frmLogIn_u in 'frmLogIn_u.pas' {frmLogIn},
  frmTellerHomeScreen_u in 'frmTellerHomeScreen_u.pas' {frmTellerHomeScreen},
  frmPointOfSale_u in 'frmPointOfSale_u.pas' {frmPointOfSale},
  frmAnalytics_u in 'frmAnalytics_u.pas' {frmAnalytics},
  frmStock_u in 'frmStock_u.pas' {frmStock},
  frmCreateNewAccount_u in 'frmCreateNewAccount_u.pas' {frmCreateNewAccount},
  frmDeleteAnAccount_u in 'frmDeleteAnAccount_u.pas' {frmDeleteAnAccount},
  frmTransactions_u in 'frmTransactions_u.pas' {frmTransactions},
  dmDatabase_u in 'dmDatabase_u.pas' {dmDatabase: TDataModule},
  clsDisplayUserInfo_u in 'clsDisplayUserInfo_u.pas',
  clsAnalyticsCalculator_u in 'clsAnalyticsCalculator_u.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'GrowCery';
  Application.CreateForm(TfrmWelcome, frmWelcome);
  Application.CreateForm(TfrmAdminHomeScreen, frmAdminHomeScreen);
  Application.CreateForm(TfrmLogIn, frmLogIn);
  Application.CreateForm(TfrmTellerHomeScreen, frmTellerHomeScreen);
  Application.CreateForm(TfrmPointOfSale, frmPointOfSale);
  Application.CreateForm(TfrmAnalytics, frmAnalytics);
  Application.CreateForm(TfrmStock, frmStock);
  Application.CreateForm(TfrmCreateNewAccount, frmCreateNewAccount);
  Application.CreateForm(TfrmDeleteAnAccount, frmDeleteAnAccount);
  Application.CreateForm(TfrmTransactions, frmTransactions);
  Application.CreateForm(TdmDatabase, dmDatabase);
  Application.Run;
end.
