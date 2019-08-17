import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { WbHomeComponent } from './wb-home/wb-home.component';
import { WbListviewComponent } from './wb-listview/wb-listview.component';
import { WbApplicationComponent } from './wb-application/wb-application.component';
import { WbDashboardComponent } from './wb-dashboard/wb-dashboard.component';
import { HttpClientModule } from '@angular/common/http';
import { MatTableModule } from '@angular/material';
import { WbUploadComponent } from './wb-upload/wb-upload.component';

export const RootRoutes: Routes = [
  {
    path: '',
    redirectTo: 'Home',
    pathMatch: 'full',
  },
  {
    path: 'Home',
    component: WbHomeComponent,
    children: [
      {
        path: '',
        redirectTo: 'Dashboard',
        pathMatch: 'full'
      },
      {
        path: 'Dashboard',
        component: WbDashboardComponent
      },
      {
        path: 'ListView',
        component: WbListviewComponent
      },
      {
        path: 'Applicant/:applicantId',
        component: WbApplicationComponent
      },
      {
        path: 'Upload',
        component: WbUploadComponent
      }
    ]
  },
];

@NgModule({
  imports: [RouterModule.forRoot(RootRoutes),
    HttpClientModule,
    MatTableModule],
  exports: [
    RouterModule
  ],
  providers: []
})
export class RoutingModule { }
