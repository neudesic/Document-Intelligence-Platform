/*
Component representing applicant list page
*/

import { Component, OnInit, ViewChild } from '@angular/core';
import { ListService } from './list.service';
import { Observable, from } from 'rxjs';
import { DataSource } from '@angular/cdk/collections';
import { DocumentsEntity } from './applicants.model';
import { HttpClient } from '@angular/common/http';
import { ActivatedRoute } from '@angular/router';


@Component({
  selector: 'app-wb-listview',
  templateUrl: './wb-listview.component.html',
  styleUrls: ['./wb-listview.component.css']
})

export class WbListviewComponent implements OnInit {

  private status;
  dataSource;
  displayedColumns = ['applicant'];

  constructor(private route: ActivatedRoute, private listService: ListService, private http: HttpClient) {
  }

  ngOnInit() {
    this.route.queryParamMap.subscribe(params => {
      this.status = params.get('status'); // status represents either approved/rejected/pending/all applicants
      this.dataSource = new ApplicantDataSource(this.listService, this.http, this.status, false);
    });
  }

  // Retrieves text from search request and updates the list of applicants to match the search response
  submitSearch(event) {
    if (event.keyCode == 13) {
      console.log(event.target.value);
      const searchResults: string[] = new Array<string>();
      this.listService.searchUrl(event.target.value).subscribe(val => {
        // tslint:disable-next-line: forin
        for (const doc in val) {
          searchResults.push((val[doc]['metadata_storage_path'].split('/').pop()));
        }
        this.dataSource = new ApplicantDataSource(this.listService, this.http, this.listService.sendRequest(this.listService.statusSearchOverlap(this.status, searchResults)), true);
        event.target.value = '';
      });
    }
  }

}

// Datasource for the list of applicants
export class ApplicantDataSource extends DataSource<any> {
  constructor(private listService: ListService, private http: HttpClient, private status: any, private search: boolean) {
    super();
  }

  connect(): Observable<DocumentsEntity[]> {
    if (this.search === false) {
      return this.listService.getApplicants(this.status);
    } else {
      return this.status;
    }
  }
  disconnect() { }

}
