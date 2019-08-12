import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { WbDashboardComponent } from './wb-dashboard.component';

describe('WbDashboardComponent', () => {
  let component: WbDashboardComponent;
  let fixture: ComponentFixture<WbDashboardComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ WbDashboardComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(WbDashboardComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
