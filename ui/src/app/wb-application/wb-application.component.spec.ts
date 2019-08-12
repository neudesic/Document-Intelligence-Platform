import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { WbApplicationComponent } from './wb-application.component';

describe('WbApplicationComponent', () => {
  let component: WbApplicationComponent;
  let fixture: ComponentFixture<WbApplicationComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ WbApplicationComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(WbApplicationComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
