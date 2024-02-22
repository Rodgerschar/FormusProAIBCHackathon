namespace FormusPro.AnalyseBudgetAI;

using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Budget;

codeunit 50203 "Prepare Budget Data"
{
    Access = Internal;

    procedure PrepareBudgetData(BudgetName: Code[10]; GLAccountNo: Code[20])
    var
        GLBudgetName: Record "G/L Budget Name";
    begin
        GLBudgetName.Reset();

        if not GLBudgetName.Get(BudgetName) then
            Error(NoBudgetNameErr, BudgetName);

        InitDataTexts();
        PrepareBudgetEntries(GLBudgetName, GLAccountNo);
    end;

    procedure GetBudgetData(): Text
    begin
        exit(BudgetEntryData);
    end;

    procedure GetGLData(): Text
    begin
        exit(GLEntryData);
    end;

    local procedure InitDataTexts()
    begin
        Newline := 10;

        Clear(GLEntryData);
        Clear(BudgetEntryData);

        GLEntryData := Newline + 'G/L Entries:' + Newline;
        BudgetEntryData := Newline + 'Budget Entries: ' + Newline;
    end;

    local procedure PrepareBudgetEntries(var GLBudgetName: Record "G/L Budget Name"; GLAccountNo: Code[20])
    var
        GLBudgetEntry: Record "G/L Budget Entry";
    begin
        GLBudgetEntry.Reset();

        GLBudgetEntry.SetCurrentKey("Budget Name", "G/L Account No.", Date);
        GLBudgetEntry.SetFilter("Budget Name", GLBudgetName.Name);
        GLBudgetEntry.SetFilter("G/L Account No.", GLAccountNo);
        if not GLBudgetEntry.FindSet() then
            Error(NoBudgetEntriesErr, GLBudgetName.Name);

        repeat
            BudgetEntryData += StrSubstNo(BudgetEntryDataFormat, GLBudgetEntry."G/L Account No.", GLBudgetEntry.Date, CalcDate('CM', GLBudgetEntry.Date), GLBudgetEntry.Amount);
            BudgetEntryData += Newline;
            PrepareGLEntries(GLBudgetEntry);
        until GLBudgetEntry.Next() = 0;
    end;

    local procedure PrepareGLEntries(GLBudgetEntry: Record "G/L Budget Entry")
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.Reset();

        GLEntry.SetCurrentKey("G/L Account No.", "Posting Date");
        GLEntry.SetFilter("G/L Account No.", GLBudgetEntry."G/L Account No.");
        GLEntry.SetRange("Posting Date", GLBudgetEntry.Date, CalcDate('CM', GLBudgetEntry.Date));
        if GLEntry.FindSet() then
            repeat
                GLEntryData += StrSubstNo(GLEntryDataFormat, GLEntry."G/L Account No.", GLEntry."Posting Date", GLEntry.Amount) + Newline;
            until GLEntry.Next() = 0;
    end;

    var
        NoBudgetNameErr: Label 'A G/L Budget with the name of %1 does not exist.';
        NoBudgetEntriesErr: Label 'The G/L Budget with the name of %2 does not have any G/L Budget Entries';
        NoGLEntriesMsg: Label 'G/L Account No. = %1, Name = %2 has no G/L Account Entries.';
        GLEntryDataFormat: Label 'G/L Account No.: %1, Posting Date: %2, Amount: %3';
        BudgetEntryDataFormat: Label 'G/L Account No.: %1, Start Date: %2, Ending Date: %3, Amount: %4';
        GLEntryData: Text;
        BudgetEntryData: Text;
        Newline: Char;
}