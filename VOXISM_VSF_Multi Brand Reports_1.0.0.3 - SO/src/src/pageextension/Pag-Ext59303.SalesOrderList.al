pageextension 59303 "Sales Order List" extends "Sales Order List"
{
    layout
    {
    }
    actions
    {
        addafter("Pick Instruction_Promoted")
        {
            actionref("Pre Shipment Packing List_Promoted"; "Multi-Brand Pre-Shipment Packing List") { }
        }
        addafter("&Print")
        {
            action("Multi-Brand Pre-Shipment Packing List")
            {
                Caption = 'Multi-Brand Pre-Shipment Packing List';
                Image = Print;
                ApplicationArea = Basic, Suite;
                Ellipsis = true;
                ToolTip = 'Executes the Pre-Shipment Packing List action.';

                trigger OnAction()
                var
                    SalesHeader: Record "Sales Header";
                begin
                    SalesHeader.Reset();
                    SalesHeader.SetRange("No.", rec."No.");
                    if SalesHeader.FindFirst() then
                        Report.RunModal(Report::"Pre-Shipment Packing List_VOX", true, false, SalesHeader);
                end;
            }
        }
    }
}