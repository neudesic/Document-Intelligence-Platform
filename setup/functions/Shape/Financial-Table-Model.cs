namespace Setup.Shape
{
    public class FinancialTableModel : Model
    {
        public string income { get; set; }
        public string extraIncome { get; set; }
        public string totalMonthlyIncome { get; set; }
        public string mortgageOrRent { get; set; }
        public string phone { get; set; }
        public string electricity { get; set; }
        public string housingSubtotal { get; set; }
        public string personal { get; set; }
        public string student { get; set; }
        public string creditCard { get; set; }
        public string loansSubtotal { get; set; }
        public string home { get; set; }
        public string health { get; set; }
        public string life { get; set; }
        public string insuranceSubtotal { get; set; }
        public string totalActualCost { get; set; }
        public string actualBalance { get; set; }

        public FinancialTableModel()
        {
            populateInformation = new KeyText[]
            {
                new KeyText(nameof(income), "income income"),
                new KeyText(nameof(extraIncome), "extra income"),
                new KeyText(nameof(totalMonthlyIncome), "total monthly income"),
                new KeyText(nameof(mortgageOrRent), "mortgage or rent"),
                new KeyText(nameof(phone), "phone"),
                new KeyText(nameof(electricity), "electricity"),
                new KeyText(nameof(housingSubtotal), "housing subtotal"),
                new KeyText(nameof(personal), "personal"),
                new KeyText(nameof(student), "student"),
                new KeyText(nameof(creditCard), "credit card"),
                new KeyText(nameof(loansSubtotal), "loans subtotal"),
                new KeyText(nameof(home), "home"),
                new KeyText(nameof(health), "health"),
                new KeyText(nameof(life), "life"),
                new KeyText(nameof(insuranceSubtotal), "insurance subtotal"),
                new KeyText(nameof(totalActualCost), "total actual cost"),
                new KeyText(nameof(actualBalance), "actual balance")
            };
        }
    }
}