/**
 * class responsible for converting a Product_Pricing__mdt record
 * into a ProductInfo DTO.
 *
 * Purpose:
 *   • Keeps mapping logic in one place
 *   • Applies simple null‑safety defaults for numeric fields
 */
public class ProductPricingMapper {
    public static ProductInfo toDTO(Product_Pricing__mdt m) {
        if (m == null) return null;

        String  prod    = m.Product_Name__c;
        String  country = m.Country_Code__c;
        Decimal monthly = (m.Monthly_Cost__c == null) ? 0 : m.Monthly_Cost__c;
        Decimal atm     = (m.ATM_Fee__c == null) ? 0 : m.ATM_Fee__c;
        Decimal card    = (m.Card_Replacement_Cost__c == null) ? 0 : m.Card_Replacement_Cost__c;
        Boolean isDef   = (m.Is_Default__c == null) ? false : m.Is_Default__c;

        return new ProductInfo(prod, country, monthly, atm, card, isDef);
    }
}