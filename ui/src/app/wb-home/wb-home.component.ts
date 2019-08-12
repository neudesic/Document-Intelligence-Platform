import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { AccountService } from './account.service';


@Component({
  selector: 'app-wb-home',
  templateUrl: './wb-home.component.html',
  styleUrls: ['./wb-home.component.css']
})

export class WbHomeComponent implements OnInit {

  constructor(private router: Router, private account: AccountService) { }

  ngOnInit() { }

}
