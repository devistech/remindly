import '../../l10n/app_localizations.dart';

extension CategoryLocalization on AppLocalizations {
  String getCategoryLocalizedName(String categoryName) {
    switch (categoryName) {
      case 'Mobile Recharge':
        return mobileRecharge;
      case 'Electricity Bill':
        return electricityBill;
      case 'Water Bill':
        return waterBill;
      case 'Credit Card Bill':
        return creditCardBill;
      case 'Loan EMI':
        return loanEmi;
      case 'Rent':
        return rent;
      case 'Insurance Premium':
        return insurancePremium;
      case 'SIP Investment':
        return sipInvestment;
      case 'GST Filing':
        return gstFiling;
      case 'Income Tax Filing':
        return incomeTaxFiling;
      case 'OTT':
        return ott;
      case 'Music':
        return music;
      case 'App Subscriptions':
        return appSubscriptions;
      case 'Exams':
        return exams;
      case 'Fees':
        return fees;
      case 'Medicine':
        return medicine;
      case 'Gym':
        return gym;
      case 'Birthdays':
        return birthdays;
      case 'Anniversaries':
        return anniversaries;
      case 'Vehicle Service':
        return vehicleService;
      case 'Insurance Renewal':
        return insuranceRenewal;
      case 'Pollution (PUC)':
        return pollutionPuc;
      default:
        return categoryName;
    }
  }

  String getRepeatTypeLocalizedName(String repeatType) {
    switch (repeatType) {
      case 'None':
        return none;
      case 'Daily':
        return daily;
      case 'Weekly':
        return weekly;
      case 'Monthly':
        return monthly;
      case 'Yearly':
        return yearly;
      case 'Custom':
        return custom;
      default:
        return repeatType;
    }
  }
}
