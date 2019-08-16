/*
Keeps track of the approved, rejected, and pending applicants
*/


import { Injectable } from '@angular/core';


@Injectable({
  providedIn: 'root'
})
export class ApplicantStatusService {

  public approvedApplicants = new Array<any>();
  public rejectedApplicants = new Array<any>();
  public pendingApplicants = new Array<any>();
  public loaded = false;


  constructor() { }

  // Adds applicant with id = "applicantId" to approved collection and removes it from pending/rejected collections
  addApproved(applicantId: string) {
    if (!this.approvedApplicants.includes(applicantId)) {
      this.approvedApplicants.push(applicantId);
      let index: number = this.rejectedApplicants.indexOf(applicantId);
      if (index !== -1) {
        this.rejectedApplicants.splice(index, 1);
      }
      index = this.pendingApplicants.indexOf(applicantId);
      if (index !== -1) {
        this.pendingApplicants.splice(index, 1);
      }
    }
  }

  // Adds applicant with id = "applicantId" to rejected collection and removes it from pending/approved collections
  addRejected(applicantId: string) {
    if (!this.rejectedApplicants.includes(applicantId)) {
      this.rejectedApplicants.push(applicantId);
      let index: number = this.approvedApplicants.indexOf(applicantId);
      if (index !== -1) {
        this.approvedApplicants.splice(index, 1);
      }
      index = this.pendingApplicants.indexOf(applicantId);
      if (index !== -1) {
        this.pendingApplicants.splice(index, 1);
      }
    }
  }

}
