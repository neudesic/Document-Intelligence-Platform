import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { ApplicantStatusService } from '../wb-dashboard/applicant-status.service';


@Component({
  selector: 'app-wb-dashboard',
  templateUrl: './wb-dashboard.component.html',
  styleUrls: ['./wb-dashboard.component.css']
})

export class WbDashboardComponent implements OnInit {

  constructor(private router: Router, public applicantStatus: ApplicantStatusService) { }

  ngOnInit() { }

}
