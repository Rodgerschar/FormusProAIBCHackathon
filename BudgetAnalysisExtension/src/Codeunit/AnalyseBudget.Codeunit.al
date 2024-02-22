namespace FormusPro.AnalyseBudgetAI;

using System.Environment;
using System.AI;
using System.Utilities;

codeunit 50200 "Analyse Budget"
{
    trigger OnRun()
    begin
        GenerateItemProposal();
    end;

    procedure SetUserPrompt(InputUserPrompt: Text)
    begin
        UserPrompt := InputUserPrompt;
    end;

    procedure SetGLAccountNo(InputGLAccountNo: Text)
    begin
        GlAccountNo := InputGLAccountNo;
    end;

    local procedure SetResponse(Result: Text)
    begin
        ChatResponse := Result;
    end;

    procedure GetResponse(): Text
    begin
        exit(ChatResponse);
    end;

    local procedure GenerateItemProposal()
    var
        TempBlob: Codeunit "Temp Blob";
    begin
        Clear(ChatResponse);
        SetResponse(Chat(GetSystemPrompt(), GetFinalUserPrompt(UserPrompt)));
    end;

    local procedure Chat(ChatSystemPrompt: Text; ChatUserPrompt: Text): Text
    var
        AzureOpenAI: Codeunit "Azure OpenAI";
        EnvironmentInformation: Codeunit "Environment Information";
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params";
        AOAIChatMessages: Codeunit "AOAI Chat Messages";
        IsolatedStorageWrapper: Codeunit "Isolated Storage Wrapper";
        Result: Text;
        EntityTextModuleInfo: ModuleInfo;
    begin
        // These funtions in the "Azure Open AI" codeunit will be available in Business Central online later this year.
        // You will need to use your own key for Azure OpenAI for all your Copilot features (for both development and production).
        AzureOpenAI.SetAuthorization(Enum::"AOAI Model Type"::"Chat Completions", IsolatedStorageWrapper.GetEndpoint(), IsolatedStorageWrapper.GetDeployment(), IsolatedStorageWrapper.GetSecretKey());

        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"Analyse Budgets");

        AOAIChatCompletionParams.SetMaxTokens(2500);
        AOAIChatCompletionParams.SetTemperature(0);

        AOAIChatMessages.AddSystemMessage(ChatSystemPrompt);
        AOAIChatMessages.AddUserMessage(ChatUserPrompt);

        AzureOpenAI.GenerateChatCompletion(AOAIChatMessages, AOAIChatCompletionParams, AOAIOperationResponse);

        if AOAIOperationResponse.IsSuccess() then
            Result := AOAIChatMessages.GetLastMessage()
        else
            Error(AOAIOperationResponse.GetError());

        exit(Result);
    end;

    local procedure GetFinalUserPrompt(InputUserPrompt: Text) FinalUserPrompt: Text
    var
        PrepareBudgetData: Codeunit "Prepare Budget Data";
    begin
        PrepareBudgetData.PrepareBudgetData(InputUserPrompt, GlAccountNo);
        FinalUserPrompt := StrSubstNo('The datasets I would like analysed are: %1%2', PrepareBudgetData.GetGLData(), PrepareBudgetData.GetBudgetData());
    end;

    local procedure GetSystemPrompt() SystemPrompt: Text
    begin
        SystemPrompt += 'The user will provide a dataset for G/L Entries and Budget Entries. Your task is to analyse the G/L Entries, make a correlation of the amount spent and then predict what month of the current year the yearly Budget will be exceeded.';
        SystemPrompt += 'The G/L Entries defines the amount spent in the current month. The Budget Entries defines the Budget for that current month.';
        SystemPrompt += 'The total amount of the Budget Entries is defined by the Budget for the year.';
        SystemPrompt += 'Please provide the month in which the yearly budget will be exceeded.';
        SystemPrompt += 'If the yearly budget will not be exceeded, then just say it will not be.';
    end;

    var
        UserPrompt: Text;
        ChatResponse: Text;
        GlAccountNo: Code[20];
}