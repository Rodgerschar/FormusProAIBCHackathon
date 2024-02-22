namespace FormusPro.AnalyseBudgetAI;

using Microsoft.Finance.GeneralLedger.Budget;

page 50200 "Analyse Budget"
{
    PageType = PromptDialog;
    Extensible = false;
    IsPreview = true;
    Caption = 'Analyse Budget with Copilot';

    layout
    {
        area(Prompt)
        {
            field(ChatRequest; ChatRequest)
            {
                ShowCaption = false;
                MultiLine = true;
                ApplicationArea = All;

                trigger OnValidate()
                begin
                    CurrPage.Update();
                end;
            }
        }
        area(Content)
        {
            part(Subform; "Analyse Budget Subform")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(SystemActions)
        {
            systemaction(Generate)
            {
                Caption = 'Analyse';
                ToolTip = 'Analyse Budgets with Dynamics 365 Copilot';

                trigger OnAction()
                begin
                    CurrPage.Update();
                    RunAnalysis();
                end;
            }
            systemaction(Cancel)
            {
                Caption = 'Close';
                ToolTip = 'Close the page';
            }
        }
    }

    trigger OnOpenPage()
    begin
        // Little bit of a hack because you can't get the text entered by user to save properly.
        // And you can't present the data through a TableRelation.
        ChatRequest := '2024';
    end;

    procedure SetGLAccountNo(InputGLAccountNo: Code[20])
    begin
        GLAccountNo := InputGLAccountNo;
    end;

    local procedure RunAnalysis()
    begin
        AnalyseBudget.SetUserPrompt(ChatRequest);
        AnalyseBudget.SetGLAccountNo(GLAccountNo);
        AnalyseBudget.Run();
        CurrPage.Subform.Page.SetChatResponse(AnalyseBudget.GetResponse());
    end;

    var
        ChatRequest: Text;
        AnalyseBudget: Codeunit "Analyse Budget";
        GLBudgetName: Record "G/L Budget Name";
        GLAccountNo: Code[20];
}