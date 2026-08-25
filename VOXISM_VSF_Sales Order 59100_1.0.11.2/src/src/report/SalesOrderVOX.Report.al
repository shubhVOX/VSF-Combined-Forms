report 59100 "Sales Order_VOX"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Report/SalesOrder.rdl';
    Caption = 'Sales Order';

    dataset
    {
        dataitem("Sales Header"; "Sales Header")
        {
            DataItemTableView = sorting("Document Type", "No.") where("Document Type" = const(Order));
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Sell-to Customer No.", "Bill-to Customer No.", "Ship-to Code", "No. Printed";
            RequestFilterHeading = 'Sales Order';
            column(No_SalesHeader; "No.")
            {
            }
            dataitem("Sales Line"; "Sales Line")
            {
                DataItemLink = "Document No." = field("No.");
                DataItemTableView = sorting("Document Type", "Document No.", "Line No.") where("Document Type" = const(Order));
                dataitem(SalesLineComments; "Sales Comment Line")
                {
                    DataItemLink = "No." = field("Document No."), "Document Line No." = field("Line No.");
                    DataItemTableView = sorting("Document Type", "No.", "Document Line No.", "Line No.") where("Document Type" = const(Order), "Print On Order Confirmation" = const(true));

                    trigger OnAfterGetRecord()
                    begin
                        InsertTempLine(Comment, 10)
                    end;
                }

                trigger OnPreDataItem()
                begin
                    TempSalesLine.Reset();
                    TempSalesLine.DeleteAll();
                    TempSalesLineAsm.Reset();
                    TempSalesLineAsm.DeleteAll();
                end;

                trigger OnAfterGetRecord()
                begin
                    TempSalesLine := "Sales Line";
                    TempSalesLine.Insert();
                    TempSalesLineAsm := "Sales Line";
                    TempSalesLineAsm.Insert();

                    HighestLineNo := "Line No.";
                    if ("Sales Header"."Tax Area Code" <> '') and not UseExternalTaxEngine then
                        SalesTaxCalc.AddSalesLine(TempSalesLine);
                end;

                trigger OnPostDataItem()
                begin
                    if "Sales Header"."Tax Area Code" <> '' then begin
                        if UseExternalTaxEngine then
                            SalesTaxCalc.CallExternalTaxEngineForSales("Sales Header", true)
                        else
                            SalesTaxCalc.EndSalesTaxCalculation(UseDate);
                        SalesTaxCalc.DistTaxOverSalesLines(TempSalesLine);
                        SalesTaxCalc.GetSummarizedSalesTaxTable(TempSalesTaxAmtLine);
                        BrkIdx := 0;
                        PrevPrintOrder := 0;
                        PrevTaxPercent := 0;
                        TempSalesTaxAmtLine.Reset();
                        TempSalesTaxAmtLine.SetCurrentKey("Print Order", "Tax Area Code for Key", "Tax Jurisdiction Code");
                        if TempSalesTaxAmtLine.Find('-') then
                            repeat
                                if (TempSalesTaxAmtLine."Print Order" = 0) or
                                   (TempSalesTaxAmtLine."Print Order" <> PrevPrintOrder) or
                                   (TempSalesTaxAmtLine."Tax %" <> PrevTaxPercent)
                                then begin
                                    BrkIdx := BrkIdx + 1;
                                    if BrkIdx > 1 then
                                        if TaxArea."Country/Region" = TaxArea."Country/Region"::CA then
                                            BreakdownTitle := Text006Lbl
                                        else
                                            BreakdownTitle := Text003Lbl;
                                    if BrkIdx > ArrayLen(BreakdownAmt) then begin
                                        BrkIdx := BrkIdx - 1;
                                        BreakdownLabel[BrkIdx] := Text004Lbl;
                                    end else
                                        BreakdownLabel[BrkIdx] := StrSubstNo(TempSalesTaxAmtLine."Print Description", TempSalesTaxAmtLine."Tax %");
                                end;
                                BreakdownAmt[BrkIdx] := BreakdownAmt[BrkIdx] + TempSalesTaxAmtLine."Tax Amount";
                            until TempSalesTaxAmtLine.Next() = 0;
                        if BrkIdx = 1 then begin
                            Clear(BreakdownLabel);
                            Clear(BreakdownAmt);
                        end;
                    end;
                end;
            }
            dataitem("Sales Comment Line"; "Sales Comment Line")
            {
                DataItemLink = "No." = field("No.");
                DataItemTableView = sorting("Document Type", "No.", "Document Line No.", "Line No.") where("Document Type" = const(Order), "Print On Order Confirmation" = const(true), "Document Line No." = const(0));

                trigger OnPreDataItem()
                begin
                    TempSalesLine.Init();
                    TempSalesLine."Document Type" := "Sales Header"."Document Type";
                    TempSalesLine."Document No." := "Sales Header"."No.";
                    TempSalesLine."Line No." := HighestLineNo + 1000;
                    HighestLineNo := TempSalesLine."Line No.";
                    TempSalesLine.Insert();
                end;

                trigger OnAfterGetRecord()
                begin
                    InsertTempLine(Comment, 1000);
                end;
            }
            dataitem(CopyLoop; "Integer")
            {
                DataItemTableView = sorting(Number);
                dataitem(PageLoop; "Integer")
                {
                    DataItemTableView = sorting(Number) where(Number = const(1));
                    column(CompanyInfoPic; CompanyInformation.Picture)
                    {
                    }
                    column(CompanyInfo2Picture; CompanyInfo2.Picture)
                    {
                    }
                    column(CompanyInfo1Picture; CompanyInfo1.Picture)
                    {
                    }
                    column(CompanyInfoPicture; CompanyInfo3.Picture)
                    {
                    }
                    column(CompanyAddress1; CompanyAddress[1])
                    {
                    }
                    column(CompanyAddress2; CompanyAddress[2])
                    {
                    }
                    column(CompanyAddress3; CompanyAddress[3])
                    {
                    }
                    column(CompanyAddress4; CompanyAddress[4])
                    {
                    }
                    column(CompanyAddress5; CompanyAddress[5])
                    {
                    }
                    column(CompanyAddress6; CompanyAddress[6])
                    {
                    }
                    column(CopyTxt; CopyTxt)
                    {
                    }
                    column(BillToAddress1; BillToAddress[1])
                    {
                    }
                    column(BillToAddress2; BillToAddress[2])
                    {
                    }
                    column(BillToAddress3; BillToAddress[3])
                    {
                    }
                    column(BillToAddress4; BillToAddress[4])
                    {
                    }
                    column(BillToAddress5; BillToAddress[5])
                    {
                    }
                    column(BillToAddress6; BillToAddress[6])
                    {
                    }
                    column(BillToAddress7; BillToAddress[7])
                    {
                    }
                    column(ShptDate_SalesHeader; "Sales Header"."Shipment Date")
                    {
                    }
                    column(ShipmentMethodCode; "Sales Header"."Shipment Method Code")
                    {
                    }
                    column(ShipmentAgentCode; "Sales Header"."Shipping Agent Code")
                    {
                    }
                    column(ShipToAddress1; ShipToAddress[1])
                    {
                    }
                    column(ShipToAddress2; ShipToAddress[2])
                    {
                    }
                    column(ShipToAddress3; ShipToAddress[3])
                    {
                    }
                    column(ShipToAddress4; ShipToAddress[4])
                    {
                    }
                    column(ShipToAddress5; ShipToAddress[5])
                    {
                    }
                    column(ShipToAddress6; ShipToAddress[6])
                    {
                    }
                    column(ShipToAddress7; ShipToAddress[7])
                    {
                    }
                    column(BilltoCustNo_SalesHeader; "Sales Header"."Bill-to Customer No.")
                    {
                    }
                    column(ExtDocNo_SalesHeader; "Sales Header"."External Document No.")
                    {
                    }
                    column(SalesPurchPersonName; SalesPurchPerson.Name)
                    {
                    }
                    column(OrderDate_SalesHeader; "Sales Header"."Order Date")
                    {
                    }
                    column(CompanyAddress7; CompanyAddress[7])
                    {
                    }
                    column(CompanyAddress8; CompanyAddress[8])
                    {
                    }
                    column(BillToAddress8; BillToAddress[8])
                    {
                    }
                    column(ShipToAddress8; ShipToAddress[8])
                    {
                    }
                    column(ShipmentMethodDesc; ShipmentMethod.Description)
                    {
                    }
                    column(PaymentTermsDesc; PaymentTerms.Description)
                    {
                    }
                    column(TaxRegLabel; TaxRegLabel)
                    {
                    }
                    column(TaxRegNo; TaxRegNo)
                    {
                    }
                    column(CopyNo; CopyNo)
                    {
                    }
                    column(CustTaxIdentificationType; Format(Cust."Tax Identification Type"))
                    {
                    }
                    column(SoldCaption; SoldCaptionLbl)
                    {
                    }
                    column(ToCaption; ToCaptionLbl)
                    {
                    }
                    column(ShipDateCaption; ShipDateCaptionLbl)
                    {
                    }
                    column(CustomerIDCaption; CustomerIDCaptionLbl)
                    {
                    }
                    column(PONumberCaption; PONumberCaptionLbl)
                    {
                    }
                    column(SalesPersonCaption; SalesPersonCaptionLbl)
                    {
                    }
                    column(ShipCaption; ShipCaptionLbl)
                    {
                    }
                    column(SalesOrderCaption; SalesOrderCaptionLbl)
                    {
                    }
                    column(SalesOrderNumberCaption; SalesOrderNumberCaptionLbl)
                    {
                    }
                    column(SalesOrderDateCaption; SalesOrderDateCaptionLbl)
                    {
                    }
                    column(PageCaption; PageCaptionLbl)
                    {
                    }
                    column(ShipViaCaption; ShipViaCaptionLbl)
                    {
                    }
                    column(TermsCaption; TermsCaptionLbl)
                    {
                    }
                    column(PODateCaption; PODateCaptionLbl)
                    {
                    }
                    column(TaxIdentTypeCaption; TaxIdentTypeCaptionLbl)
                    {
                    }
                    column(YourPOCaption; YourPOCaptionLbl)
                    {
                    }
                    column(PhoneCaption; PhoneCaptionLbl)
                    {
                    }
                    column(EmailCaption; EmailCaptionLbl)
                    {
                    }
                    column(ShipmentMethodCodeCaption; ShipmentMethodCodeCapLbl)
                    {
                    }
                    column(SalesHeaderComment; SalesHeaderComment)
                    {
                    }
                    column(SalesOrderCommentCaption; SalesOrderCommentCapLbl)
                    {
                    }
                    column(OrderComments; OrderComments)
                    {
                    }
                    column(SalesOrderDate; SalesOrderDate)
                    {
                    }
                    column(CurrencyCode_SalesHeader; "Sales Header"."Currency Code")
                    {
                    }
                    column(PhoneNo_Val; PhoneNo_Val)
                    {
                    }
                    column(Email_Val; Email_Val)
                    {
                    }
                    column(ShippingAGentDesc; ShippingAGentDesc)
                    {
                    }
                    dataitem(SalesLine; "Integer")
                    {
                        DataItemTableView = sorting(Number);
                        column(AmountExclInvDisc; AmountExclInvDisc)
                        {
                        }
                        column(TempSalesLineNo; TempSalesLine."No.")
                        {
                        }
                        column(TempSalesLineVariantCode; TempSalesLine."Variant Code")
                        {
                        }
                        column(Type_SalesLine; TempSalesLine.Type)
                        {
                        }
                        column(TempSalesLineUOM; TempSalesLine."Unit of Measure")
                        {
                        }
                        column(TempSalesLineQuantity; TempSalesLine.Quantity)
                        {
                            DecimalPlaces = 0 : 5;
                        }
                        column(CrossRefNo_SalesLine; TempSalesLine."Item Reference No.")
                        {
                        }
                        column(RequestedDelDate_SalesLine; TempSalesLine."Requested Delivery Date")
                        {
                        }
                        column(Discount_SalesLine; TempSalesLine."Line Discount %")
                        {
                        }
                        column(LineAmount_SalesLine; TempSalesLine."Line Amount")
                        {
                        }
                        column(UnitPriceToPrint; UnitPriceToPrint)
                        {
                            DecimalPlaces = 2 : 5;
                        }
                        column(TempSalesLineDesc; TempSalesLine.Description)
                        {
                        }
                        column(TempSalesLineDesc2; TempSalesLine."Description 2")
                        {
                        }
                        column(TempSalesLineDocumentNo; TempSalesLine."Document No.")
                        {
                        }
                        column(TempSalesLineLineNo; TempSalesLine."Line No.")
                        {
                        }
                        column(AsmInfoExistsForLine; AsmInfoExistsForLine)
                        {
                        }
                        column(TaxLiable; TaxLiable)
                        {
                        }
                        column(TempSalesLineLineAmtTaxLiable; TempSalesLine."Line Amount" - TaxLiable)
                        {
                        }
                        column(TempSalesLineInvDiscAmt; TempSalesLine."Inv. Discount Amount")
                        {
                        }
                        column(TaxAmount; TaxAmount)
                        {
                        }
                        column(TempSalesLineLineAmtTaxAmtInvDiscAmt; TempSalesLine."Line Amount" + TaxAmount - TempSalesLine."Inv. Discount Amount")
                        {
                        }
                        column(BreakdownTitle; BreakdownTitle)
                        {
                        }
                        column(BreakdownLabel1; BreakdownLabel[1])
                        {
                        }
                        column(BreakdownLabel2; BreakdownLabel[2])
                        {
                        }
                        column(BreakdownLabel3; BreakdownLabel[3])
                        {
                        }
                        column(BreakdownAmt1; BreakdownAmt[1])
                        {
                        }
                        column(BreakdownAmt2; BreakdownAmt[2])
                        {
                        }
                        column(BreakdownAmt3; BreakdownAmt[3])
                        {
                        }
                        column(BreakdownAmt4; BreakdownAmt[4])
                        {
                        }
                        column(BreakdownLabel4; BreakdownLabel[4])
                        {
                        }
                        column(TotalTaxLabel; TotalTaxLabel)
                        {
                        }
                        column(ItemNoCaption; ItemNoCaptionLbl)
                        {
                        }
                        column(UnitCaption; UnitCaptionLbl)
                        {
                        }
                        column(DescriptionCaption; DescriptionCaptionLbl)
                        {
                        }
                        column(QuantityCaption; QuantityCaptionLbl)
                        {
                        }
                        column(UnitPriceCaption; UnitPriceCaptionLbl)
                        {
                        }
                        column(TotalPriceCaption; TotalPriceCaptionLbl)
                        {
                        }
                        column(SubtotalCaption; SubtotalCaptionLbl)
                        {
                        }
                        column(InvoiceDiscountCaption; InvoiceDiscountCaptionLbl)
                        {
                        }
                        column(TotalCaption; TotalCaptionLbl)
                        {
                        }
                        column(AmtSubjecttoSalesTaxCptn; AmtSubjecttoSalesTaxCptnLbl)
                        {
                        }
                        column(AmtExemptfromSalesTaxCptn; AmtExemptfromSalesTaxCptnLbl)
                        {
                        }
                        column(ItemNo; ItemNo)
                        {
                        }
                        column(GLAccount; GLAccount)
                        {
                        }
                        column(CrossRef; CrossRef)
                        {
                        }
                        column(VariantBool; VariantBool)
                        {
                        }
                        column(Discount; Discount)
                        {
                        }
                        column(Description1; Description1)
                        {
                        }
                        column(Desc2; Desc2)
                        {
                        }
                        column(LineComments; LineComments)
                        {
                        }
                        column(ExtendedText; ExtendedText)
                        {
                        }
                        column(ItemAttribute; ItemAttribute)
                        {
                        }
                        column(SeperatorLine; SeperatorLine)
                        {
                        }
                        column(CrossRefCaption; CrossRefCapLbl)
                        {
                        }
                        column(VariantCaption; VariantCapLbl)
                        {
                        }
                        column(DiscountCaption; DiscountCapLbl)
                        {
                        }
                        column(LineAmountCaption; LineAmountCapLbl)
                        {
                        }
                        column(ReqDelDateCaption; ReqDelDateCapLbl)
                        {
                        }
                        column(SalesLineComment; SalesLineComment)
                        {
                        }
                        column(RequestedDeliveryDate; RequestedDeliveryDate)
                        {
                        }
                        column(ExtendedText_var; ExtendedText_var)
                        {
                        }
                        column(ItemAttributeValue1; ItemAttributeValue[1])
                        {
                        }
                        column(ItemAttributeValue2; ItemAttributeValue[2])
                        {
                        }
                        column(ItemAttributeValue3; ItemAttributeValue[3])
                        {
                        }
                        column(ItemAttributeValue4; ItemAttributeValue[4])
                        {
                        }
                        column(ItemAttributeValue5; ItemAttributeValue[5])
                        {
                        }
                        column(ItemAttributeValue6; ItemAttributeValue[6])
                        {
                        }
                        column(TagLine1Value; TagLine1Value)
                        {
                        }
                        column(TagLine2Value; TagLine2Value)
                        {
                        }
                        column(SuppressOUnitPrice; Suppress0UnitPrice) { }
                        column(TempSalesLine_UnitPrice; TempSalesLine."Unit Price")
                        {
                        }
                        column(ShowVariant; ShowVariant)
                        {
                        }
                        column(Type_TempSalesLine; TempSalesLine.Type)
                        {
                        }
                        column(LotNo; LotNo) { }
                        dataitem(AsmLoop; "Integer")
                        {
                            DataItemTableView = sorting(Number);
                            column(AsmLineUnitOfMeasureText; GetUnitOfMeasureDescr(AsmLine."Unit of Measure Code"))
                            {
                            }
                            column(AsmLineQuantity; AsmLine.Quantity)
                            {
                            }
                            column(AsmLineDescription; BlanksForIndent() + AsmLine.Description)
                            {
                            }
                            column(AsmLineNo; BlanksForIndent() + AsmLine."No.")
                            {
                            }
                            column(AsmLineType; AsmLine.Type)
                            {
                            }

                            trigger OnPreDataItem()
                            begin
                                if not DisplayAssemblyInformation then
                                    CurrReport.Break();
                                if not AsmInfoExistsForLine then
                                    CurrReport.Break();
                                AsmLine.SetRange("Document Type", AsmHeader."Document Type");
                                AsmLine.SetRange("Document No.", AsmHeader."No.");
                                SetRange(Number, 1, AsmLine.Count);
                            end;

                            trigger OnAfterGetRecord()
                            begin
                                if Number = 1 then
                                    AsmLine.FindSet()
                                else begin
                                    AsmLine.Next();
                                    TaxLiable := 0;
                                    TaxAmount := 0;
                                    AmountExclInvDisc := 0;
                                    TempSalesLine."Line Amount" := 0;
                                    TempSalesLine."Inv. Discount Amount" := 0;
                                end;
                            end;
                        }

                        trigger OnPreDataItem()
                        begin
                            Clear(TaxLiable);
                            Clear(TaxAmount);
                            Clear(AmountExclInvDisc);

                            TempSalesLine.Reset();
                            NumberOfLines := TempSalesLine.Count;
                            SetRange(Number, 1, NumberOfLines);
                            OnLineNumber := 0;
                            ///TempSalesLine.SETCURRENTKEY(TempSalesLine."Line No.");
                        end;

                        trigger OnAfterGetRecord()
                        var
                            SalesLine: Record "Sales Line";
                        begin
                            OnLineNumber := OnLineNumber + 1;

                            if OnLineNumber = 1 then
                                TempSalesLine.Find('-')
                            else
                                TempSalesLine.Next();

                            if TempSalesLine.Type = TempSalesLine.Type::" " then begin
                                TempSalesLine."No." := '';
                                TempSalesLine."Unit of Measure" := '';
                                TempSalesLine."Line Amount" := 0;
                                TempSalesLine."Inv. Discount Amount" := 0;
                                TempSalesLine.Quantity := 0;
                            end else
                                //MQ YOGI.P 30-JAN-2020
                                if TempSalesLine.Type = TempSalesLine.Type::"G/L Account" then
                                    if GLAccount = true then
                                        TempSalesLine."No." := TempSalesLine."No.";
                            //MQ YOGI.P 30-JAN-2020
                            if TempSalesLine."Tax Area Code" <> '' then
                                TaxAmount := TempSalesLine."Amount Including VAT" - TempSalesLine.Amount
                            else
                                TaxAmount := 0;

                            if TaxAmount <> 0 then
                                TaxLiable := TempSalesLine.Amount
                            else
                                TaxLiable := 0;

                            OnAfterCalculateSalesTax("Sales Header", TempSalesLine, TaxAmount, TaxLiable); // Avalara

                            AmountExclInvDisc := TempSalesLine."Line Amount";

                            if TempSalesLine.Quantity = 0 then
                                UnitPriceToPrint := 0 // so it won't print
                            else
                                UnitPriceToPrint := Round(AmountExclInvDisc / TempSalesLine.Quantity, 0.00001);
                            if DisplayAssemblyInformation then begin
                                AsmInfoExistsForLine := false;
                                if TempSalesLineAsm.Get(TempSalesLine."Document Type", TempSalesLine."Document No.", TempSalesLine."Line No.") then begin
                                    SalesLine.Get(TempSalesLine."Document Type", TempSalesLine."Document No.", TempSalesLine."Line No.");
                                    AsmInfoExistsForLine := SalesLine.AsmToOrderExists(AsmHeader);
                                end;
                            end;
                            //MQ 01-23-2019
                            SalesLineComment := '';
                            CrLf[1] := 13;
                            CrLf[2] := 10;
                            SalesComment.RESET();
                            SalesComment.SETRANGE("Document Type", SalesComment."Document Type"::Order);
                            SalesComment.SETRANGE("No.", TempSalesLine."Document No.");
                            SalesComment.SETRANGE("Document Line No.", TempSalesLine."Line No.");
                            if SalesComment.FINDFIRST() then
                                repeat
                                    if SalesLineComment <> '' then
                                        SalesLineComment := SalesLineComment + FORMAT(CrLf[2]) + SalesComment.Comment
                                    else
                                        SalesLineComment := SalesComment.Comment;
                                until SalesComment.NEXT() = 0;
                            //MQ 01-23-2019

                            //MQ 01-24-2019
                            ExtendedText_var := '';
                            CrLf[1] := 13;
                            CrLf[2] := 10;
                            ExtendedTextLine.Reset();
                            ExtendedTextLine.SETRANGE("No.", TempSalesLine."No.");
                            //ExtendedTextLine.SetRange("Table Name",Database::Item);
                            if ExtendedTextLine.FindSet() then
                                repeat
                                    if ExtendedText_var <> '' then
                                        ExtendedText_var := ExtendedText_var + FORMAT(CrLf[2]) + ExtendedTextLine.Text
                                    else
                                        ExtendedText_var := ExtendedTextLine.Text;
                                until ExtendedTextLine.NEXT() = 0;
                            //MQ 01-24-2019

                            //MQ 01-24-2019
                            CLEAR(RequestedDeliveryDate);
                            if "Date Format" = "Date Format"::"yyyy/mm/dd" then
                                RequestedDeliveryDate := FORMAT(TempSalesLine."Requested Delivery Date", 0, '<Year4>/<Month,2>/<Day,2>')
                            else
                                if
                             "Date Format" = "Date Format"::"mm/dd/yyyy" then
                                    RequestedDeliveryDate := FORMAT(TempSalesLine."Requested Delivery Date", 0, '<Month,2>/<Day,2>/<Year4>')
                                else
                                    if
                                 "Date Format" = "Date Format"::"mmm/dd/yyyy" then
                                        RequestedDeliveryDate := FORMAT(TempSalesLine."Requested Delivery Date", 0, '<Month Text,3> <Day,2>, <Year4>');
                            //MQ 01-24-2019

                            // >>MQ YOGI.P 24-JAN-2020
                            CLEAR(i);
                            CLEAR(ItemAttributeValue);
                            ItemAttributeValueMapping.SETRANGE("No.", TempSalesLine."No.");
                            ItemAttributeValueMapping.SETRANGE("Table ID", 27);
                            if ItemAttributeValueMapping.FINDSET() then
                                repeat
                                    i := i + 1;
                                    if ItemAttributeValueRec.GET(ItemAttributeValueMapping."Item Attribute ID", ItemAttributeValueMapping."Item Attribute Value ID") then
                                        ItemAttributeValue[i] := ItemAttributeValueRec.GetAttributeNameInCurrentLanguage() + '- ' + ItemAttributeValueRec.Value;
                                until ItemAttributeValueMapping.NEXT() = 0;
                            COMPRESSARRAY(ItemAttributeValue);
                            // <<MQ YOGI.P 24-JAN-2020

                            Clear(LotNo);
                            if PrintLotNo then begin
                                ReservationEntry.Reset();
                                ReservationEntry.SetRange("Item No.", TempSalesLine."No.");
                                ReservationEntry.SetRange("Source Type", 37);
                                ReservationEntry.SetRange("Source ID", TempSalesLine."Document No.");
                                ReservationEntry.SetRange("Source Ref. No.", TempSalesLine."Line No.");
                                if ReservationEntry.FindSet() then
                                    repeat
                                        if LotNo <> '' then
                                            LotNo := LotNo + ',' + ReservationEntry."Lot No."
                                        else
                                            LotNo := ReservationEntry."Lot No.";
                                    until ReservationEntry.Next() = 0;
                            end;
                        end;
                    }
                }

                trigger OnPreDataItem()
                begin
                    NoCopies := 0;
                    NoLoops := 1 + Abs(NoCopies);
                    if NoLoops <= 0 then
                        NoLoops := 1;
                    CopyNo := 0;
                end;

                trigger OnAfterGetRecord()
                begin
                    if CopyNo = NoLoops then begin
                        if not CurrReport.Preview then
                            SalesPrinted.Run("Sales Header");
                        CurrReport.Break();
                    end;
                    CopyNo := CopyNo + 1;
                    if CopyNo = 1 then // Original
                        Clear(CopyTxt)
                    else
                        CopyTxt := Text000Lbl;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if PrintCompany then
                    if RespCenter.Get("Responsibility Center") then begin
                        FormatAddress.RespCenter(CompanyAddress, RespCenter);
                        CompanyInformation."Phone No." := RespCenter."Phone No.";
                        CompanyInformation."Fax No." := RespCenter."Fax No.";
                    end;

                CurrReport.Language := Language_gvar.GetLanguageIdOrDefault("Language Code");

                FormatDocumentFields("Sales Header");

                if not Cust.Get("Sell-to Customer No.") then
                    Clear(Cust);

                //MQ 01-23-2019
                BillToAddress[1] := "Sales Header"."Bill-to Name";
                BillToAddress[2] := "Sales Header"."Bill-to Address";
                BillToAddress[3] := "Sales Header"."Bill-to Address 2";
                BillToAddress[4] := "Sales Header"."Bill-to City" + ',' + ' ' + "Sales Header"."Bill-to County" + ',' + ' ' + "Sales Header"."Bill-to Post Code";
                if CountryRegionRec.GET("Bill-to Country/Region Code") then;
                BillToAddress[5] := CountryRegionRec.Name;
                COMPRESSARRAY(BillToAddress);
                ShipToAddress[1] := "Sales Header"."Ship-to Name";
                ShipToAddress[2] := "Sales Header"."Ship-to Address";
                ShipToAddress[3] := "Sales Header"."Ship-to Address 2";
                ShipToAddress[4] := "Sales Header"."Ship-to City" + ',' + ' ' + "Sales Header"."Ship-to County" + ',' + ' ' + "Sales Header"."Ship-to Post Code";
                if CountryRegionRec.GET("Ship-to Country/Region Code") then
                    ShipToAddress[5] := CountryRegionRec.Name;
                COMPRESSARRAY(ShipToAddress);

                //MQ 01-23-2019
                if not CurrReport.Preview then begin
                    if ArchiveDocument then
                        ArchiveManagement.StoreSalesDocument("Sales Header", LogInteraction);

                    if LogInteraction then begin
                        CalcFields("No. of Archived Versions");
                        if "Bill-to Contact No." <> '' then
                            SegManagement.LogDocument(
                              3, "No.", "Doc. No. Occurrence",
                              "No. of Archived Versions", DATABASE::Contact, "Bill-to Contact No."
                              , "Salesperson Code", "Campaign No.", "Posting Description", "Opportunity No.")
                        else
                            SegManagement.LogDocument(
                              3, "No.", "Doc. No. Occurrence",
                              "No. of Archived Versions", DATABASE::Customer, "Bill-to Customer No.",
                              "Salesperson Code", "Campaign No.", "Posting Description", "Opportunity No.");
                    end;
                end;

                Clear(BreakdownTitle);
                Clear(BreakdownLabel);
                Clear(BreakdownAmt);
                TotalTaxLabel := Text008Lbl;
                TaxRegNo := '';
                TaxRegLabel := '';
                if "Tax Area Code" <> '' then begin
                    TaxArea.Get("Tax Area Code");
                    case TaxArea."Country/Region" of
                        TaxArea."Country/Region"::US:
                            TotalTaxLabel := Text005Lbl;
                        TaxArea."Country/Region"::CA:
                            begin
                                TotalTaxLabel := Text007Lbl;
                                TaxRegNo := CompanyInformation."VAT Registration No.";
                                TaxRegLabel := CompanyInformation.FieldCaption("VAT Registration No.");
                            end;
                    end;
                    UseExternalTaxEngine := TaxArea."Use External Tax Engine";
                    SalesTaxCalc.StartSalesTaxCalculation();
                end;

                if "Posting Date" <> 0D then
                    UseDate := "Posting Date"
                else
                    UseDate := WorkDate();

                //MQ 01-23-2019
                CrLf[1] := 13;
                CrLf[2] := 10;
                SalesComment.RESET();
                SalesComment.SETRANGE("Document Type", "Sales Header"."Document Type");
                SalesComment.SETRANGE("No.", "Sales Header"."No.");
                SalesComment.SETRANGE("Document Line No.", 0);
                //>> YOgi.P DEC122025
                if not OrderComments then
                    SalesComment.SetRange("Print On Order Confirmation", true);
                //<< YOgi.P DEC122025
                if SalesComment.FINDFIRST() then
                    repeat
                        if SalesHeaderComment <> '' then
                            SalesHeaderComment := SalesHeaderComment + FORMAT(CrLf[2]) + SalesComment.Comment
                        else
                            SalesHeaderComment := SalesComment.Comment;
                    until SalesComment.NEXT() = 0;
                //MQ 01-23-2019

                //MQ 01-24-2019
                CLEAR(SalesOrderDate);
                if "Date Format" = "Date Format"::"yyyy/mm/dd" then
                    SalesOrderDate := FORMAT("Sales Header"."Order Date", 0, '<Year4>/<Month,2>/<Day,2>')
                else
                    if
                 "Date Format" = "Date Format"::"mm/dd/yyyy" then
                        SalesOrderDate := FORMAT("Sales Header"."Order Date", 0, '<Month,2>/<Day,2>/<Year4>')
                    else
                        if
                     "Date Format" = "Date Format"::"mmm/dd/yyyy" then
                            SalesOrderDate := FORMAT("Sales Header"."Order Date", 0, '<Month Text,3> <Day,2>, <Year4>');
                //MQ 01-24-2019

                //MQ 01-27-2019
                if "Sales Header"."Currency Code" = '' then
                    "Sales Header"."Currency Code" := GeneralLedgerSetup."LCY Code";
                //MQ 01-27-2019

                //MQ 01-31-2020
                if Cust.Get("Sell-to Customer No.") then
                    PhoneNo_Val := Cust."Phone No.";
                Email_Val := Cust."E-Mail";
                //MQ 01-31-2020

                //MQ 01-31-2020
                if ShippingAgent.Get("Shipping Agent Code") then
                    ShippingAGentDesc := ShippingAgent.Name;
                //MQ 01-31-2020

                if TempSalesLine."Variant Code" = '' then
                    ShowVariant := ''
                else
                    ShowVariant := 'Variant'
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';

                    field(PrintCompanyAddress; PrintCompany)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Print Company Address';
                        ToolTip = 'Specifies if your company address is printed at the top of the sheet, because you do not use pre-printed paper. Leave this check box blank to omit your company''s address.';
                    }
                    field(ArchiveDocument_; ArchiveDocument)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Archive Document';
                        Enabled = ArchiveDocumentEnable;
                        ToolTip = 'Specifies if the document is archived after you preview or print it.';

                        trigger OnValidate()
                        begin
                            if not ArchiveDocument then
                                LogInteraction := false;
                        end;
                    }
                    field(LogInteraction_; LogInteraction)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Log Interaction';
                        Enabled = LogInteractionEnable;
                        ToolTip = 'Specifies if you want to record the related interactions with the involved contact person in the Interaction Log Entry table.';

                        trigger OnValidate()
                        begin
                            if LogInteraction then
                                ArchiveDocument := ArchiveDocumentEnable;
                        end;
                    }
                    field("Display Assembly information"; DisplayAssemblyInformation)
                    {
                        ApplicationArea = Assembly;
                        Caption = 'Show Assembly Components';
                        ToolTip = 'Specifies if you want the report to include information about components that were used in linked assembly orders that supplied the item(s) being sold.';
                    }
                    field("Date Format_"; "Date Format")
                    {
                        ApplicationArea = All;
                        Caption = 'Date Format';
                        ToolTip = 'Specifies the value of the Date Format field.';
                        OptionCaption = 'mm/dd/yyyy,yyyy/mm/dd,mmm/dd/yyyy';
                    }
                    field("Order Comments"; OrderComments)
                    {
                        ApplicationArea = All;
                        Caption = 'Order Comments';
                        ToolTip = 'Specifies the value of the Order Comments field.';
                    }
                    field("Item No"; ItemNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Item No.';
                        ToolTip = 'Specifies the value of the Item No. field.';
                    }
                    field("GL Account"; GLAccount)
                    {
                        ApplicationArea = All;
                        Caption = 'Show GL Acct Code';
                        ToolTip = 'Specifies the value of the Show GL Acct Code field.';
                    }
                    field("Cross Reference"; CrossRef)
                    {
                        ApplicationArea = All;
                        Caption = 'Item Reference No.';
                        ToolTip = 'Specifies the value of the Item Reference No. field.';
                    }
                    field(Discount_; Discount)
                    {
                        ApplicationArea = All;
                        Caption = 'Discount';
                        ToolTip = 'Specifies the value of the Discount field.';
                    }
                    field("Description 1"; Description1)
                    {
                        ApplicationArea = All;
                        Caption = 'Description 1';
                        ToolTip = 'Specifies the value of the Description 1 field.';
                    }
                    field("Description 2"; Desc2)
                    {
                        ApplicationArea = All;
                        Caption = 'Description 2';
                        ToolTip = 'Specifies the value of the Description 2 field.';
                    }
                    field("Line Comments"; LineComments)
                    {
                        ApplicationArea = All;
                        Caption = 'Line Comments';
                        ToolTip = 'Specifies the value of the Line Comments field.';
                    }
                    field("Extended Text"; ExtendedText)
                    {
                        ApplicationArea = All;
                        Caption = 'Extended Text';
                        ToolTip = 'Specifies the value of the Extended Text field.';
                    }
                    field("Item Attribute"; ItemAttribute)
                    {
                        ApplicationArea = All;
                        Caption = 'Item Attribute';
                        ToolTip = 'Specifies the value of the Item Attribute field.';
                    }
                    field("Seperator Line"; SeperatorLine)
                    {
                        ApplicationArea = All;
                        Caption = 'Seperator Line';
                        ToolTip = 'Specifies the value of the Seperator Line field.';
                    }
                    field(PrintLotNo_; PrintLotNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Print Lot No.';
                        ToolTip = 'Specifies the value of the Print Lot No. field.';
                    }
                    field(Suppress0UnitPrice_; Suppress0UnitPrice)
                    {
                        ApplicationArea = All;
                        Caption = 'Suppress "0" Unit Price Line';
                        ToolTip = 'Specifies the value of the Suppress "0" Unit Price Line field.';
                    }
                    field("Tag Line 1"; TagLine1Value)
                    {
                        ApplicationArea = All;
                        Caption = 'Tag Line 1';
                        ToolTip = 'Specifies the value of the Tag Line 1 field.';
                    }
                    field("Tag Line 2"; TagLine2Value)
                    {
                        ApplicationArea = All;
                        Caption = 'Tag Line 2';
                        ToolTip = 'Specifies the value of the Tag Line 2 field.';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnInit()
        begin
            LogInteractionEnable := true;
            ArchiveDocumentEnable := true;
            PrintCompany := true;
            ItemNo := true;
            Description1 := true;
            SeperatorLine := true;
            //>> Yogi.P DEC122025
            OrderComments := false;
            //><< Yogi.P DEC122025
        end;

        trigger OnOpenPage()
        begin
            ArchiveDocument := SalesSetup."Archive Orders";
            LogInteraction := SegManagement.FindInteractionTemplateCode("Interaction Log Entry Document Type"::"Sales Ord. Cnfrmn.") <> '';

            ArchiveDocumentEnable := ArchiveDocument;
            LogInteractionEnable := LogInteraction;
        end;
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        GeneralLedgerSetup.GET();//MQ 01-27-2019
        CompanyInformation.Get();
        SalesSetup.Get();
        FormatDocument.SetLogoPosition(SalesSetup."Logo Position on Documents", CompanyInfo1, CompanyInfo2, CompanyInfo3);
        CompanyInformation.CALCFIELDS(Picture);//MQ 01-26-2019

        if PrintCompany then begin
            //MQ 01-23-2019
            CompanyAddress[1] := CompanyInformation.Name;
            CompanyAddress[2] := CompanyInformation.Address;
            CompanyAddress[3] := CompanyInformation."Address 2";
            if CountryRegionRec.GET(CompanyInformation."Country/Region Code") then;
            CompanyAddress[4] := CompanyInformation.City + ',' + ' ' + CompanyInformation.County + ',' + ' ' + CountryRegionRec.Name + '  ' + CompanyInformation."Post Code";
            CompanyAddress[5] := CompanyInformation."Phone No.";
            CompanyAddress[6] := CompanyInformation."E-Mail";
            CompanyAddress[7] := '';
            COMPRESSARRAY(CompanyAddress);
        end
        else
            CLEAR(CompanyAddress);
        //MQ 01-23-2019
    end;

    var

        AsmHeader: Record "Assembly Header";
        AsmLine: Record "Assembly Line";
        CompanyInfo1: Record "Company Information";
        CompanyInfo2: Record "Company Information";
        CompanyInfo3: Record "Company Information";
        CompanyInformation: Record "Company Information";
        CountryRegionRec: Record "Country/Region";
        Cust: Record Customer;
        ExtendedTextLine: Record "Extended Text Line";
        GeneralLedgerSetup: Record "General Ledger Setup";
        ItemAttributeValueRec: Record "Item Attribute Value";
        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
        PaymentTerms: Record "Payment Terms";
        ReservationEntry: Record "Reservation Entry";
        RespCenter: Record "Responsibility Center";
        SalesSetup: Record "Sales & Receivables Setup";
        SalesComment: Record "Sales Comment Line";
        TempSalesLine: Record "Sales Line" temporary;
        TempSalesLineAsm: Record "Sales Line" temporary;
        SalesPurchPerson: Record "Salesperson/Purchaser";
        TempSalesTaxAmtLine: Record "Sales Tax Amount Line" temporary;
        ShipmentMethod: Record "Shipment Method";
        ShippingAgent: Record "Shipping Agent";
        TaxArea: Record "Tax Area";
        ArchiveManagement: Codeunit ArchiveManagement;
        FormatAddress: Codeunit "Format Address";
        FormatDocument: Codeunit "Format Document";
        Language_gvar: Codeunit Language;
        SalesPrinted: Codeunit "Sales-Printed";
        SalesTaxCalc: Codeunit "Sales Tax Calculate";
        SegManagement: Codeunit SegManagement;
        ArchiveDocument: Boolean;
        ArchiveDocumentEnable: Boolean;
        AsmInfoExistsForLine: Boolean;
        CrossRef: Boolean;
        Desc2: Boolean;
        Description1: Boolean;
        Discount: Boolean;
        DisplayAssemblyInformation: Boolean;
        ExtendedText: Boolean;
        GLAccount: Boolean;
        ItemAttribute: Boolean;
        ItemNo: Boolean;
        LineComments: Boolean;
        LogInteraction: Boolean;
        LogInteractionEnable: Boolean;
        OrderComments: Boolean;
        PrintCompany: Boolean;
        PrintLotNo: Boolean;
        SeperatorLine: Boolean;
        Suppress0UnitPrice: Boolean;
        UseExternalTaxEngine: Boolean;
        VariantBool: Boolean;
        CrLf: array[2] of Char;
        UseDate: Date;
        AmountExclInvDisc: Decimal;
        BreakdownAmt: array[4] of Decimal;
        PrevTaxPercent: Decimal;
        TaxAmount: Decimal;
        TaxLiable: Decimal;
        UnitPriceToPrint: Decimal;
        BrkIdx: Integer;
        CopyNo: Integer;
        HighestLineNo: Integer;
        i: Integer;
        NoCopies: Integer;
        NoLoops: Integer;
        NumberOfLines: Integer;
        OnLineNumber: Integer;
        PrevPrintOrder: Integer;
        AmtExemptfromSalesTaxCptnLbl: Label 'Amount Exempt from Sales Tax';
        AmtSubjecttoSalesTaxCptnLbl: Label 'Amount Subject to Sales Tax';
        CrossRefCapLbl: Label 'Item reference No.';
        CustomerIDCaptionLbl: Label 'Customer ID';
        DescriptionCaptionLbl: Label 'Description';
        DiscountCapLbl: Label 'Disc. %';
        EmailCaptionLbl: Label 'Email:';
        InvoiceDiscountCaptionLbl: Label 'Invoice Discount:';
        ItemNoCaptionLbl: Label 'Item No.';
        LineAmountCapLbl: Label 'Line Amount';
        PageCaptionLbl: Label 'Page:';
        PhoneCaptionLbl: Label 'Phone:';
        PODateCaptionLbl: Label 'P.O. Date';
        PONumberCaptionLbl: Label 'P.O. Number';
        QuantityCaptionLbl: Label 'Quantity';
        ReqDelDateCapLbl: Label 'Requested Delivery Date';
        SalesOrderCaptionLbl: Label 'SALES ORDER';
        SalesOrderCommentCapLbl: Label 'Comments:';
        SalesOrderDateCaptionLbl: Label 'Sales Order Date:';
        SalesOrderNumberCaptionLbl: Label 'Sales Order Number:';
        SalesPersonCaptionLbl: Label 'SalesPerson';
        ShipCaptionLbl: Label 'Ship';
        ShipDateCaptionLbl: Label 'Ship Date';
        ShipmentMethodCodeCapLbl: Label 'Shipment Method Code';
        ShipViaCaptionLbl: Label 'Ship Via';
        SoldCaptionLbl: Label 'Sold';
        SubtotalCaptionLbl: Label 'Subtotal:';
        TaxIdentTypeCaptionLbl: Label 'Tax Ident. Type';
        TermsCaptionLbl: Label 'Terms';
        Text000Lbl: Label 'COPY';
        Text003Lbl: Label 'Sales Tax Breakdown:';
        Text004Lbl: Label 'Other Taxes';
        Text005Lbl: Label 'Total Sales Tax:';
        Text006Lbl: Label 'Tax Breakdown:';
        Text007Lbl: Label 'Total Tax:';
        Text008Lbl: Label 'Tax:';
        ToCaptionLbl: Label 'To:';
        TotalCaptionLbl: Label 'Total';
        TotalPriceCaptionLbl: Label 'Total Price';
        UnitCaptionLbl: Label 'Unit';
        UnitPriceCaptionLbl: Label 'Unit Price';
        VariantCapLbl: Label 'Variant';
        YourPOCaptionLbl: Label 'Your PO:';
        "Date Format": Option "mm/dd/yyyy","yyyy/mm/dd","mmm/dd/yyyy";
        BreakdownLabel: array[4] of Text;
        BreakdownTitle: Text;
        CompanyAddress: array[8] of Text;
        CopyTxt: Text;
        ExtendedText_var: Text;
        ItemAttributeValue: array[30] of Text;
        LotNo: Text;
        RequestedDeliveryDate: Text;
        SalesHeaderComment: Text;
        SalesLineComment: Text;
        SalesOrderDate: Text;
        ShowVariant: Text;
        TaxRegLabel: Text;
        TaxRegNo: Text;
        TotalTaxLabel: Text;
        PhoneNo_Val: Text[30];
        SalespersonText: Text[50];
        ShippingAGentDesc: Text[50];
        Email_Val: Text[80];
        BillToAddress: array[8] of Text[100];
        ShipToAddress: array[8] of Text[100];
        TagLine1Value: Text[100];
        TagLine2Value: Text[100];

    procedure GetUnitOfMeasureDescr(UOMCode: Code[10]): Text[50]
    var
        UnitOfMeasure: Record "Unit of Measure";
    begin
        if not UnitOfMeasure.Get(UOMCode) then
            exit(UOMCode);
        exit(UnitOfMeasure.Description);
    end;

    procedure BlanksForIndent(): Text[10]
    begin
        exit(PadStr('', 2, ' '));
    end;

    local procedure FormatDocumentFields(SalesHeader: Record "Sales Header")
    begin
        FormatDocument.SetSalesPerson(SalesPurchPerson, SalesHeader."Salesperson Code", SalespersonText);
        FormatDocument.SetPaymentTerms(PaymentTerms, SalesHeader."Payment Terms Code", SalesHeader."Language Code");
        FormatDocument.SetShipmentMethod(ShipmentMethod, SalesHeader."Shipment Method Code", SalesHeader."Language Code");
    end;

    local procedure InsertTempLine(Comment: Text[80]; IncrNo: Integer)
    begin
        TempSalesLine.Init();
        TempSalesLine."Document Type" := "Sales Header"."Document Type";
        TempSalesLine."Document No." := "Sales Header"."No.";
        TempSalesLine."Line No." := HighestLineNo + IncrNo;
        HighestLineNo := TempSalesLine."Line No.";
#pragma warning disable AA0139
        FormatDocument.ParseComment(Comment, TempSalesLine.Description, TempSalesLine."Description 2");
#pragma warning restore AA0139
        TempSalesLine.Insert();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalculateSalesTax(var SalesHeaderParm: Record "Sales Header"; var SalesLineParm: Record "Sales Line"; var TaxAmount: Decimal; var TaxLiable: Decimal)
    begin
    end;
}
