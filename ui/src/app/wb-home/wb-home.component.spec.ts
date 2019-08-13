import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { WbHomeComponent } from './wb-home.component';

describe('WbHomeComponent', () => {
  let component: WbHomeComponent;
  let fixture: ComponentFixture<WbHomeComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ WbHomeComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(WbHomeComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
