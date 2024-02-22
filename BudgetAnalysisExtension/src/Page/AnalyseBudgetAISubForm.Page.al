namespace FormusPro.AnalyseBudgetAI;

page 50201 "Analyse Budget Subform"
{
    PageType = CardPart;
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            field(Response; ChatResponse)
            {
                ShowCaption = false;
                MultiLine = true;
                ApplicationArea = All;
            }
        }
    }

    procedure SetChatResponse(Response: Text)
    begin
        ChatResponse := Response;
        Message(ChatResponse);
    end;

    var
        ChatResponse: Text;
}