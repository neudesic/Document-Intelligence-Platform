import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { WbListviewComponent } from './wb-listview.component';

describe('WbListviewComponent', () => {
  let component: WbListviewComponent;
  let fixture: ComponentFixture<WbListviewComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ WbListviewComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(WbListviewComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
