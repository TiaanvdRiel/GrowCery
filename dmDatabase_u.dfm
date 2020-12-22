object dmDatabase: TdmDatabase
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 547
  Width = 556
  object conDatabse: TADOConnection
    Connected = True
    ConnectionString = 
      'Provider=Microsoft.Jet.OLEDB.4.0;User ID=Admin;Data Source=D:\Gr' +
      'owCery\35. GrowCery - Working Saving Transactions\dbDatabase.mdb' +
      ';Mode=ReadWrite;Persist Security Info=False;Jet OLEDB:System dat' +
      'abase="";Jet OLEDB:Registry Path="";Jet OLEDB:Database Password=' +
      '"";Jet OLEDB:Engine Type=5;Jet OLEDB:Database Locking Mode=1;Jet' +
      ' OLEDB:Global Partial Bulk Ops=2;Jet OLEDB:Global Bulk Transacti' +
      'ons=1;Jet OLEDB:New Database Password="";Jet OLEDB:Create System' +
      ' Database=False;Jet OLEDB:Encrypt Database=False;Jet OLEDB:Don'#39't' +
      ' Copy Locale on Compact=False;Jet OLEDB:Compact Without Replica ' +
      'Repair=False;Jet OLEDB:SFP=False'
    LoginPrompt = False
    Mode = cmReadWrite
    Provider = 'Microsoft.Jet.OLEDB.4.0'
    Left = 24
    Top = 240
  end
  object tblTransactions: TADOTable
    Active = True
    Connection = conDatabse
    CursorType = ctStatic
    TableName = 'Transactions'
    Left = 248
    Top = 144
    object tblTransactionsTransID: TWideStringField
      FieldName = 'TransID'
      Size = 14
    end
    object tblTransactionsAccountID: TWideStringField
      FieldName = 'AccountID'
      Size = 6
    end
    object tblTransactionsDateOfTransaction: TWideStringField
      FieldName = 'DateOfTransaction'
      Size = 10
    end
    object tblTransactionsProcessedBy2: TWideStringField
      FieldName = 'ProcessedBy'
      Size = 50
    end
  end
  object tblItemTransactions: TADOTable
    Active = True
    Connection = conDatabse
    CursorType = ctStatic
    TableName = 'ItemTransactions'
    Left = 248
    Top = 240
    object tblItemTransactionsID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object tblItemTransactionsTransID: TWideStringField
      FieldName = 'TransID'
      Size = 14
    end
    object tblItemTransactionsBarcode: TWideStringField
      FieldName = 'Barcode'
      Size = 7
    end
    object tblItemTransactionsQuantity: TIntegerField
      FieldName = 'Quantity'
    end
    object tblItemTransactionsItemName2: TWideStringField
      FieldName = 'ItemName'
      Size = 40
    end
    object tblItemTransactionsUnitPrice2: TWideStringField
      FieldName = 'UnitPrice'
      Size = 10
    end
  end
  object dsrTransactions: TDataSource
    DataSet = tblTransactions
    Left = 136
    Top = 128
  end
  object tblSuppliers: TADOTable
    Active = True
    Connection = conDatabse
    CursorType = ctStatic
    Filtered = True
    TableName = 'Suppliers'
    Left = 248
    Top = 336
    object tblSuppliersSupplierID: TWideStringField
      FieldName = 'SupplierID'
      Size = 10
    end
    object tblSuppliersSupplierName: TWideStringField
      FieldName = 'SupplierName'
      Size = 35
    end
    object tblSuppliersContactNumber: TWideStringField
      FieldName = 'ContactNumber'
      Size = 10
    end
    object tblSuppliersEmailAdress: TWideStringField
      FieldName = 'EmailAdress'
      Size = 30
    end
  end
  object tblItems: TADOTable
    Active = True
    Connection = conDatabse
    CursorType = ctStatic
    TableName = 'Items'
    Left = 240
    Top = 432
    object tblItemsSupplierID: TWideStringField
      FieldName = 'SupplierID'
      Size = 10
    end
    object tblItemsBarcode: TWideStringField
      FieldName = 'Barcode'
      Size = 7
    end
    object tblItemsItemName: TWideStringField
      FieldName = 'ItemName'
      Size = 50
    end
    object tblItemsCategory: TWideStringField
      FieldName = 'Category'
      Size = 15
    end
    object tblItemsUnitPrice: TWideStringField
      FieldName = 'UnitPrice'
      Size = 10
    end
  end
  object dsrSuppliers: TDataSource
    DataSet = tblSuppliers
    Left = 136
    Top = 328
  end
  object dsrItems: TDataSource
    DataSet = tblItems
    Left = 128
    Top = 432
  end
  object qryAccounts: TADOQuery
    Connection = conDatabse
    Parameters = <>
    Left = 312
    Top = 32
  end
  object qryTransactions: TADOQuery
    Connection = conDatabse
    Parameters = <>
    Left = 320
    Top = 136
  end
  object dsrItemTransactions: TDataSource
    DataSet = tblItemTransactions
    Left = 136
    Top = 240
  end
  object tblAccounts: TADOTable
    Active = True
    Connection = conDatabse
    CursorType = ctStatic
    TableName = 'Accounts'
    Left = 224
    Top = 40
  end
  object dsrAccounts: TDataSource
    DataSet = tblAccounts
    Left = 136
    Top = 48
  end
end
