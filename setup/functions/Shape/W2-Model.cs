namespace Setup.Shape
{
    public class W2Model : Model
    {
        public string ss { get; set; }
        public string identificationNumber { get; set; }
        public string compensation { get; set; }
        public string federalIncomeTaxWithheld { get; set; }
        public string employerInformation { get; set; }
        public string ssWages { get; set; }
        public string ssTaxWithheld { get; set; }
        public string medicareWages { get; set; }
        public string medicareTaxWithheld { get; set; }
        public string ssTips { get; set; }
        public string controlNumber { get; set; }
        public string dependentCareBenifits { get; set; }
        public string employeeInformation { get; set; }

        public W2Model()
        {
            populateInformation = new KeyText[]
            {
                new KeyText(nameof(ss), "Employee’s social security"),
                new KeyText(nameof(identificationNumber), "Employer identification number"),
                new KeyText(nameof(compensation), "Wages, tips, other compensation"),
                new KeyText(nameof(federalIncomeTaxWithheld), "Federal income tax withheld"),
                new KeyText(nameof(employerInformation), "Employer’s name, address, and ZIP code"),
                new KeyText(nameof(ssWages), "Social security wages"),
                new KeyText(nameof(ssTaxWithheld), "Social security tax withheld"),
                new KeyText(nameof(medicareWages), "Medicare wages and tips"),
                new KeyText(nameof(medicareTaxWithheld), "Medicare tax withheld"),
                new KeyText(nameof(ssTips), "Social security tips"),
                new KeyText(nameof(controlNumber), "Control number"),
                new KeyText(nameof(dependentCareBenifits), "Dependent care benefits"),
                new KeyText(nameof(employeeInformation), "Employee’s first name and initial")
            };
        }

    }
}