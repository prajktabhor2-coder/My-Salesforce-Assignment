import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getProductSummary from '@salesforce/apex/ProductInfoService.getProductSummary';
import CASE_CONTACT from '@salesforce/schema/Case.ContactId';

const COLUMNS = [
  {
    label: 'Product',
    fieldName: 'productName',
    type: 'text'
  },
  {
    label: 'Monthly cost',
    fieldName: 'monthlyCost',
    type: 'currency',
    typeAttributes: { currencyCode: 'EUR', minimumFractionDigits: 2 }
  },
  {
    label: 'ATM fee',
    fieldName: 'atmFeeLabel',
    type: 'text'
  },
  {
    label: 'Card replacement',
    fieldName: 'cardReplacementCost',
    type: 'currency',
    typeAttributes: { currencyCode: 'EUR', minimumFractionDigits: 2 }
  }
];

export default class ProductSummaryTable extends LightningElement {
  @api recordId; // Case Id

  columns = COLUMNS;
  rows;
  isLoading = true;
  error;

  contactId;

  // 1) Get Case.ContactId
  @wire(getRecord, { recordId: '$recordId', fields: [CASE_CONTACT] })
  wiredCase({ error, data }) {
    if (data) {
      this.contactId = data.fields.ContactId
        ? data.fields.ContactId.value
        : null;
      this.error = undefined;
      this.loadRow(); 
    } else if (error) {
      this.contactId = null;
      this.error = 'Error loading Case.';
      this.isLoading = false;
      this.rows = null;
    }
  }

  get contactId() {
    return this.contactId;
  }

  loadRow() {
    if (!this.contactId) {
      this.rows = null;
      this.isLoading = false;
      return;
    }

    this.isLoading = true;

    getProductSummary({ contactId: this.contactId })
      .then(info => {
        if (!info) {
          this.rows = null;
          this.error = undefined;
          this.isLoading = false;
          return;
        }

        // Build ATM fee label
        const atmVal = info.atmFee;
        let atmLabel = '-';

        if (atmVal !== null && atmVal !== undefined) {
          const n = Number(atmVal);
          if (!isNaN(n) && Math.abs(n) <= 100) {
            // treat as percentage
            atmLabel =
              (n % 1 === 0
                ? n.toFixed(0)
                : n.toFixed(2).replace(/\.?0+$/, '')) + '%';
          } else {
            // treat as currency
            atmLabel = new Intl.NumberFormat('de-DE', {
              style: 'currency',
              currency: 'EUR'
            }).format(n);
          }        
          if( n === 0) {
            atmLabel = 'Free';
          }
        }

        this.rows = [
          {
            productName: info.productName,
            monthlyCost: info.monthlyCost,
            atmFee: info.atmFee,
            atmFeeLabel: atmLabel,
            cardReplacementCost: info.cardReplacementCost,
            countryCode: info.countryCode,
            isDefault: info.isDefault
          }
        ];

        this.error = undefined;
        this.isLoading = false;
      })
      .catch(() => {
        this.error = 'Could not load product information.';
        this.rows = null;
        this.isLoading = false;
      });
  }

  get noRows() {
    return !this.rows || this.rows.length === 0;
  }
}
