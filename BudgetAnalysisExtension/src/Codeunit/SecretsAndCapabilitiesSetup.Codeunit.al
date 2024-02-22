namespace FormusPro.AnalyseBudgetAI;

using System.AI;
using System.Environment;

codeunit 50202 "Secrets And Capabilities Setup"
{
    Subtype = Install;
    InherentEntitlements = X;
    InherentPermissions = X;
    Access = Internal;

    trigger OnInstallAppPerDatabase()
    begin
        RegisterCapability();
    end;

    local procedure RegisterCapability()
    var
        CopilotCapability: Codeunit "Copilot Capability";
        IsolatedStorageWrapper: Codeunit "Isolated Storage Wrapper";
        LearnMoreUrlTxt: Label 'https://example.com/CopilotToolkit', Locked = true;
    begin
        if not CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"Analyse Budgets") then
            CopilotCapability.RegisterCapability(Enum::"Copilot Capability"::"Analyse Budgets", Enum::"Copilot Availability"::Preview, LearnMoreUrlTxt);

        // You will need to use your own key for Azure OpenAI for all your Copilot features (for both development and production).
        // Error('Set up your secrets here before publishing the app.');
        IsolatedStorageWrapper.SetSecretKey('b29c7e8723ec4d30a27a2703e842d881');
        IsolatedStorageWrapper.SetDeployment('gpt-35-turbo');
        IsolatedStorageWrapper.SetEndpoint('https://bc-ai-hackaton-2024.openai.azure.com/');
    end;
}