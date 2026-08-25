tableextension 59301 "MQ_ResponsibilityCenter" extends "Responsibility Center" //5714
{
    DataCaptionFields = Address;
    fields
    {
        field(50100; Logo; BLOB)
        {
            Caption = 'Logo';
            SubType = Bitmap;
        }
        field(50115; "VAT Registration No."; Text[20])
        {
            Caption = 'VAT Registration No.';
        }
    }
}