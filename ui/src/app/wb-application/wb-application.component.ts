/*
Component representing a single applicant page
*/


import { Component, OnInit } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { WbApplicationDetailService } from './wb-application-detail.service';
import { HttpClient } from '@angular/common/http';
import { ApplicantStatusService } from '../wb-dashboard/applicant-status.service';


@Component({
  selector: 'app-wb-application',
  templateUrl: './wb-application.component.html',
  styleUrls: ['./wb-application.component.css']
})

export class WbApplicationComponent implements OnInit {

  w2;
  w2Enriched;
  financial;
  financialEnriched;
  processed;
  private applicantId: string;
  private w2Pdf;
  private financialPdf;
  private totalTaxes;
  private grossIncome;
  private disposableIncome;
  private yearlyNet;
  private totalExpense;
  private totalDebt;
  private percentageGrossIncomeInsurance;
  private percentageGrossIncomeMortgage;

  constructor(private route: ActivatedRoute, private applicantService: WbApplicationDetailService, private http: HttpClient, private applicantStatus: ApplicantStatusService) {
  }

  ngOnInit() {
    this.route.paramMap.subscribe(params => {
      this.applicantId = params.get('applicantId');
    });
    console.log(this.applicantId);

    // Gets document with id = "applicantId" from w2-form collection and formats certain fields
    this.applicantService.getW2(this.applicantId).subscribe(val => {
      this.w2 = val;
      this.totalTaxes = (+val['federalIncomeTaxWithheld']) + (+val['medicareTaxWithheld']) + (+val['ssTaxWithheld']);
      this.totalTaxes = this.applicantService.numberBeautify(Math.round(this.totalTaxes * 100) / 100);
      this.grossIncome = this.applicantService.numberBeautify(+val['compensation']);
    });

    // Gets document with id = "applicantId" from w2-form-enriched collection and formats certain fields
    this.applicantService.getW2Enriched(this.applicantId).subscribe(val => {
      this.w2Enriched = val;
      this.disposableIncome = this.applicantService.numberBeautify(Math.round(+val['disposableIncome'] * 100) / 100);
    });

    // Gets document with id = "applicantId" from financial-table collection and formats certain fields
    this.applicantService.getFinancial(this.applicantId).subscribe(val => {
      this.financial = val;
      this.totalExpense = this.applicantService.numberBeautify((this.applicantService.removeDollarSignComma(val['totalActualCost']) * 12));
      this.totalDebt = this.applicantService.numberBeautify(this.applicantService.removeDollarSignComma(val['loansSubtotal']) + this.applicantService.removeDollarSignComma(val['mortgageOrRent']));
    });

    // Gets document with id = "applicantId" from financial-table-enriched collection
    this.applicantService.getFinancialEnriched(this.applicantId).subscribe(val => this.financialEnriched = val);

    // Gets document with id = "applicantId" from processed collection and formats certain fields
    this.applicantService.getProcessed(this.applicantId).subscribe(val => {
      this.processed = val;
      if (String(+val['yearlyInsuranceForecast'] * 100).length > 4) {
        this.percentageGrossIncomeInsurance = String(+val['yearlyInsuranceForecast'] * 100).substring(0, 4) + '%';
      } else {
        this.percentageGrossIncomeInsurance = (+val['yearlyInsuranceForecast'] * 100) + '%';
      }
      if (String(+val['yearlyMortageForecast'] * 100).length > 4) {
        this.percentageGrossIncomeMortgage = String(+val['yearlyMortageForecast'] * 100).substring(0, 4) + '%';
      } else {
        this.percentageGrossIncomeMortgage = (+val['yearlyMortageForecast'] * 100) + '%';
      }
      if (+val['yearlyNetForecast'] < 0) {
        this.yearlyNet = '-' + this.applicantService.numberBeautify((Math.round(+val['yearlyNetForecast'] * 100) / 100) * -1);
      } else {
        this.yearlyNet = '' + this.applicantService.numberBeautify((Math.round(+val['yearlyNetForecast'] * 100) / 100));
      }
    });

    // Gets blob with filename = "applicantId" from w2-form container
    this.applicantService.getW2Blob(this.applicantId).subscribe(data => {
      const pdf = new Blob([data], { type: 'application/pdf' });
      this.w2Pdf = URL.createObjectURL(pdf);
    });
    // Gets blob with filename = "applicantId" from financial-table container
    this.applicantService.getFinancialBlob(this.applicantId).subscribe(data => {
      const pdf = new Blob([data], { type: 'application/pdf' });
      this.financialPdf = URL.createObjectURL(pdf);
    });
  }

  // Adds applicant with id = "applicantId" to collection of approved applicants
  approveLoan() {
    this.applicantStatus.addApproved(this.applicantId);
  }

  // Adds applicant with id = "applicantId" to collection of rejected applicants
  rejectLoan() {
    this.applicantStatus.addRejected(this.applicantId);
  }

}
