pageextension 59301 "Responsibility Center Card" extends "Responsibility Center Card"
{
    layout
    {
        addlast(General)
        {
            field("VAT Registration No."; Rec."VAT Registration No.")
            {
                ApplicationArea = All;
                Caption = 'VAT Registration No.';
                ToolTip = 'Specifies the value of the VAT Registration No. field.';
            }
            field(Logo; Rec.Logo)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the Logo that has been set up for the company, such as a company logo.';

                trigger OnValidate()
                begin
                    CurrPage.SaveRecord();
                end;
            }

        }
    }
}