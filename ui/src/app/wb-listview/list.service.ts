/*
Contains methods for retrieving all of the information necessary for displaying a list of applicants (approved, rejected, pending and all)
*/


import { Injectable, TemplateRef } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, from } from 'rxjs';
import { map } from 'rxjs/operators';
import { Applicant, DocumentsEntity } from './applicants.model';
import * as Crypto from 'crypto-js';
import { HttpHeaders } from '@angular/common/http';
import { ApplicantStatusService } from '../wb-dashboard/applicant-status.service';
import { AccountService } from '../wb-home/account.service';
import { Search } from './search.model';


@Injectable()

export class ListService {

  private cosmosAccount = this.account.cosmosAccount;
  private cosmosKey = this.account.cosmosKey;
  private searchAccount = this.account.searchAccount;
  private searchKey = this.account.searchKey;

  constructor(private http: HttpClient, private applicantStatus: ApplicantStatusService, private account: AccountService) { }

  headers = {
    headers: new HttpHeaders({
      'Content-Type': 'application/json+query',
      'Authorization': this.getAuthorization(),
      'x-ms-date': new Date().toUTCString(),
      'x-ms-version': '2018-12-31'
    })
  };

  // Returns Observable containing array of either approved/rejected/pending/all applicants
  getApplicants(status: string): Observable<DocumentsEntity[]> {
    if (status === 'approved') {
      return this.sendRequest(this.applicantStatus.approvedApplicants);
    } else if (status === 'rejected') {
      return this.sendRequest(this.applicantStatus.rejectedApplicants);
    } else if (status === 'pending') {
      if (this.applicantStatus.loaded === false) {
        this.applicantStatus.loaded = true;
        const applicants = this.http.get<Applicant[]>(this.getCosmosUrl(this.cosmosAccount), this.headers).pipe(map(val => val['Documents']));
        applicants.subscribe(val => {
          for (const x in val) {
            this.applicantStatus.pendingApplicants.push(val[x]['id']);
          }
        });
        return this.http.get<Applicant[]>(this.getCosmosUrl(this.cosmosAccount), this.headers).pipe(map(val => val['Documents']));
      }
      return this.sendRequest(this.applicantStatus.pendingApplicants);
    } else if (status === 'upload') {
      const applicants = this.http.get<Applicant[]>(this.getCosmosUrl(this.cosmosAccount), this.headers).pipe(map(val => val['Documents']));
      applicants.subscribe(val => {
        this.applicantStatus.loaded = true;
        for (const x in val) {
          if (!this.applicantStatus.pendingApplicants.includes(val[x]['id']) && !this.applicantStatus.approvedApplicants.includes(val[x]['id']) && !this.applicantStatus.rejectedApplicants.includes(val[x]['id'])) {
            this.applicantStatus.pendingApplicants.push(val[x]['id']);
          }
        }
        return this.sendRequest(this.applicantStatus.pendingApplicants);
      });
    } else {
      return this.http.get<Applicant[]>(this.getCosmosUrl(this.cosmosAccount), this.headers).pipe(map(val => val['Documents']));
    }
  }

  // Returns response from CosmosDB REST api request of all collections
  sendRequest(status: Array<String>): any {
    return this.http.get<Applicant[]>(this.getCosmosUrl(this.cosmosAccount), this.headers).pipe(map(val => val['Documents']), map(val => val.filter(doc => status.includes(doc['id']))));
  }

  // Returns authorization key for CosmosDB REST api
  getAuthorization(): string {
    const resourceType = 'docs';
    const masterKey = this.cosmosKey;
    const resourceId = 'dbs/dip-github-db/colls/w2-form';
    const utcDate = new Date().toUTCString();
    const verb = 'GET';
    const text = (verb || '').toLowerCase() + '\n' + (resourceType || '').toLowerCase() + '\n' + (resourceId || '') + '\n' + utcDate.toLowerCase() + '\n' + '' + '\n';
    const key = Crypto.enc.Base64.parse(masterKey);
    const signature = Crypto.HmacSHA256(text, key).toString(Crypto.enc.Base64);
    const MasterToken = 'master';
    const TokenVersion = '1.0';
    const authToken = encodeURIComponent('type=' + MasterToken + '&ver=' + TokenVersion + '&sig=' + signature);
    return authToken;
  }

  // Returns url for CosmosDB REST api
  getCosmosUrl(cosmosAccount: string): string {
    return 'https://cors-anywhere.herokuapp.com/https://' + cosmosAccount + '.documents.azure.com/dbs/dip-github-db/colls/w2-form/docs';
  }

  // Returns url for Azure Search REST api
  searchUrl(value: string) {
    return this.http.get<Search>('https://cors-anywhere.herokuapp.com/https://' + this.searchAccount + '.search.windows.net/indexes/dipgithub-index/docs?api-version=2019-05-06&api-key=' + this.searchKey + '&search=' + value + '*').pipe(map(val => val['value']));
  }

  // Returns Array of applicants that represents the overlap between the list of applicants returned by the Azure Search REST api and the applicants in the current collection (approved/rejected/pending/all)
  statusSearchOverlap(status: string, search: Array<string>): Array<string> {
    let applicants;
    if (status === 'approved') {
      applicants = this.applicantStatus.approvedApplicants;
    } else if (status === 'rejected') {
      applicants = this.applicantStatus.rejectedApplicants;
    } else if (status === 'pending') {
      applicants = this.applicantStatus.pendingApplicants;
    } else {
      applicants.push(...this.applicantStatus.pendingApplicants).push(...this.applicantStatus.approvedApplicants).push(...this.applicantStatus.rejectedApplicants);
    }
    return applicants.filter(val => search.includes(val));
  }

}
