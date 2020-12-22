// ##################################
// ######     IT PAT 2018     #######
// ######      GrowCery       #######
// ######  Tiaan van der Riel #######
// ##################################
unit clsAnalyticsCalculator_u;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, TeEngine, TeeProcs, Chart, Grids, DBGrids,
  pngimage, Buttons, ComCtrls, Mask;

type
  TAnalyticsCalculator = class(TObject)

  private
    fSelectedAccountID: string;
    fStartDate: string;
    fEndDate: string;

  public
    // Variables
    iCount: integer;
    rTotalSales: real;
    rAverageSalesValue: real;
    iTotalNumberOfItemsSold: integer;
    iAverageNumberOfItemsSold: integer;
    // Constructor
    constructor Create(sSelectedAccountID: string; sStartDate: string;
      sEndDate: string);
    // Functions
    function CalcTotalSales: real;
    function CalcAverageSales: real;
    function CalcTotalItemsSold: integer;
    function CalcAverageItemsSold: integer;
    // Procedure
    procedure BuildSQL;
  end;

implementation

uses
  dmDatabase_u;

{ TAnalyticsCalculator }

{
This class is used to calculate the analytics of a given account whitin a certain
period of time, using a start date and a end date. The following can be calculated:
1.)  Total value of the items sold
2.) Average value of the items sold for each day
3.) Total number of items sold
4.) Average number of items sold each day

* This class is used by the from frmAnalytics to calcylate the analytics within a certain
  time period, to be displayed on panels, and a graph.

* This class is also repurposed by the form frmTellerHomeScreen, to obtain the totals (nr. 1 and 2)
  form the current day, and the previous day.
  - This is done by setting the end and start dates to the same day, effectively telling
    the class to only calculate the analytics for that one day
}

// Constructor
constructor TAnalyticsCalculator.Create(sSelectedAccountID, sStartDate,
  sEndDate: string);
begin
  fSelectedAccountID := sSelectedAccountID;
  fStartDate := fStartDate;
  fEndDate := sEndDate;
  BuildSQL;
end;

// Builds the SQL
procedure TAnalyticsCalculator.BuildSQL;
begin
  with dmDatabase do
  Begin
    // ShowMessage(sSelectedAccountID);
    qryTransactions.SQL.Clear;
    qryTransactions.SQL.Add('SELECT TT.AccountID, TT.DateOfTransaction');
    qryTransactions.SQL.Add(', SUM(Quantity) AS [Number Of Items Sold]');
    qryTransactions.SQL.Add(
      ' ,SUM(IT.Quantity * IT.UnitPrice) AS [Total For The Day] ');
    qryTransactions.SQL.Add('FROM Transactions TT, ItemTransactions IT');
    qryTransactions.SQL.Add(' WHERE (AccountID = ' + QuotedStr
        (fSelectedAccountID) + ')');
    qryTransactions.SQL.Add(' AND (DateOfTransaction BETWEEN ' + QuotedStr
        (fStartDate) + ' AND ' + QuotedStr(fEndDate) + ') ');
    qryTransactions.SQL.Add(' AND TT.TransID = IT.TransID ');
    qryTransactions.SQL.Add(' GROUP BY TT.DateOfTransaction, TT.AccountID ');
    qryTransactions.Open;
    iCount := 0;
    rTotalSales := 0;
    iTotalNumberOfItemsSold := 0;
    // Runs through the query and sums up the fields
    while NOT qryTransactions.Eof do
    begin
      Inc(iCount);
      rTotalSales := rTotalSales + qryTransactions['Total For The Day'];
      iTotalNumberOfItemsSold := iTotalNumberOfItemsSold + qryTransactions
        ['Number Of Items Sold'];
      qryTransactions.Next;
    end;
    qryTransactions.First;
  End;
end;

// 1.) Total value of the items sold
function TAnalyticsCalculator.CalcTotalSales: real;
begin
  if rTotalSales = 0 then
  Begin
    Result := 0;
  End
  Else
  Begin
    Result := rTotalSales;
  End;
end;

// 2.) Average value of the items sold for each day
function TAnalyticsCalculator.CalcAverageSales: real;
begin
  { If no sales where made on that day. Cannot divide by 0 for average. }
  if rTotalSales = 0 then
  Begin
    Result := 0;
  End
  Else
  Begin
    rAverageSalesValue := rTotalSales / iCount;
    Result := rAverageSalesValue;
  end;
end;

// 3.) Total number of items sold
function TAnalyticsCalculator.CalcTotalItemsSold: integer;
begin
  Result := iTotalNumberOfItemsSold;
end;

// 4.) Average number of items sold each day
function TAnalyticsCalculator.CalcAverageItemsSold: integer;
begin
  { If no sales where made on that day. Cannot divide by 0 for average. }
  if iTotalNumberOfItemsSold = 0 then
  Begin
    Result := 0;
  End
  Else
  Begin
    iAverageNumberOfItemsSold := Round(iTotalNumberOfItemsSold / iCount);
    Result := iAverageNumberOfItemsSold;
  End;
end;

end.
