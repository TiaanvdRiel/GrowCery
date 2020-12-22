// ##################################
// ######     IT PAT 2018     #######
// ######      GrowCery       #######
// ######  Tiaan van der Riel #######
// ##################################
unit dmDatabase_u;

interface

uses
  SysUtils, Classes, DB, ADODB;

type
  TdmDatabase = class(TDataModule)
    conDatabse: TADOConnection;
    tblTransactions: TADOTable;
    tblItemTransactions: TADOTable;
    dsrTransactions: TDataSource;
    tblSuppliers: TADOTable;
    tblItems: TADOTable;
    dsrSuppliers: TDataSource;
    dsrItems: TDataSource;
    tblSuppliersSupplierID: TWideStringField;
    tblSuppliersSupplierName: TWideStringField;
    tblSuppliersContactNumber: TWideStringField;
    tblSuppliersEmailAdress: TWideStringField;
    tblItemsSupplierID: TWideStringField;
    tblItemsBarcode: TWideStringField;
    tblItemsItemName: TWideStringField;
    tblItemsCategory: TWideStringField;
    tblItemsUnitPrice: TWideStringField;
    qryAccounts: TADOQuery;
    tblTransactionsTransID: TWideStringField;
    tblTransactionsAccountID: TWideStringField;
    tblTransactionsDateOfTransaction: TWideStringField;
    tblItemTransactionsID: TAutoIncField;
    tblItemTransactionsTransID: TWideStringField;
    tblItemTransactionsBarcode: TWideStringField;
    tblItemTransactionsQuantity: TIntegerField;
    tblItemTransactionsItemName2: TWideStringField;
    tblItemTransactionsUnitPrice2: TWideStringField;
    tblTransactionsProcessedBy2: TWideStringField;
    qryTransactions: TADOQuery;
    dsrItemTransactions: TDataSource;
    tblAccounts: TADOTable;
    dsrAccounts: TDataSource;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dmDatabase: TdmDatabase;

implementation

{$R *.dfm}

procedure TdmDatabase.DataModuleCreate(Sender: TObject);
var
  sFilePath: string;
begin
  conDatabse.Close;
  sFilePath := ExtractFilePath('GrowCery_p.exe') + 'dbDatabase.mdb';
  conDatabse .ConnectionString :=
    'Provider=Microsoft.Jet.OLEDB.4.0;' + 'Data Source=' + sFilePath;
  tblAccounts.Open;

end;

end.
