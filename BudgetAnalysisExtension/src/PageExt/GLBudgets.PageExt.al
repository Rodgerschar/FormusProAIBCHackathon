
namespace FormusPro.AnalyseBudgetAI;

using Microsoft.Finance.Analysis;
using Microsoft.Finance.GeneralLedger.Budget;
using Microsoft.Finance.Dimension;

pageextension 50200 GLBudgetExt extends "Budget Matrix"
{
    actions
    {
        addafter(GLAccBalanceBudget)
        {

            action(AnalyseBudget)
            {
                Caption = 'Analyse with Copilot ';
                Image = Sparkle;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    FetchDatesWithAI(Rec);
                end;
            }
        }
    }

    local procedure FetchDatesWithAI(Rec: Record "Dimension Code Buffer")
    var
        AnalyseBudget: Page "Analyse Budget";
    begin
        AnalyseBudget.SetGLAccountNo(Rec.Code);
        AnalyseBudget.RunModal();
        CurrPage.Update(false);
    end;
}