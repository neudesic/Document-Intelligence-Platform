import { BrowserModule, DomSanitizer } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { NgModule } from '@angular/core';
import { BsDropdownModule } from 'ngx-bootstrap';
import { CollapseModule } from 'ngx-bootstrap';
import { ModalModule, BsModalService } from 'ngx-bootstrap/modal';
import { RoutingModule, RootRoutes } from './app.route.module';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { HttpClientModule } from '@angular/common/http';
import { MatSlideToggleModule } from '@angular/material/slide-toggle';
import { MatIconModule } from '@angular/material/icon';
import { MatGridListModule } from '@angular/material/grid-list';
import { MatCardModule } from '@angular/material/card';
import { MatTabsModule } from '@angular/material/tabs';
import { MatListModule } from '@angular/material/list';
import { TabsModule } from 'ngx-bootstrap/tabs';
import { MatTableModule, MatPaginatorModule, MatSortModule } from '@angular/material';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatSnackBarModule } from '@angular/material/snack-bar';
import { AppComponent } from './app.component';
import { WbApplicationDetailService } from '../app/wb-application/wb-application-detail.service';
import { WbHomeComponent } from './wb-home/wb-home.component';
import { WbListviewComponent } from './wb-listview/wb-listview.component';
import { WbApplicationComponent } from './wb-application/wb-application.component';
import { WbDashboardComponent } from './wb-dashboard/wb-dashboard.component';
import { ListService } from './wb-listview/list.service';
import { PdfViewerModule } from 'ng2-pdf-viewer';
import { WbUploadComponent } from './wb-upload/wb-upload.component';


@NgModule({
  declarations: [
    AppComponent,
    WbHomeComponent,
    WbListviewComponent,
    WbApplicationComponent,
    WbHomeComponent,
    WbDashboardComponent,
    WbHomeComponent,
    WbListviewComponent,
    WbApplicationComponent,
    WbDashboardComponent,
    WbUploadComponent,
  ],
  imports: [
    BrowserModule,
    RoutingModule,
    FormsModule,
    ReactiveFormsModule,
    HttpClientModule,
    MatSlideToggleModule,
    MatIconModule,
    MatGridListModule,
    MatCardModule,
    MatTabsModule,
    MatListModule,
    BsDropdownModule.forRoot(),
    CollapseModule.forRoot(),
    ModalModule.forRoot(),
    BrowserAnimationsModule,
    MatTabsModule,
    TabsModule.forRoot(),
    MatTableModule,
    MatPaginatorModule,
    MatSortModule,
    MatProgressSpinnerModule,
    MatSnackBarModule,
    PdfViewerModule
   ],
  providers: [
    BsModalService,
    ListService,
    WbApplicationDetailService
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
