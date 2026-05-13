// passed in api request
class Hardcode {
  static const String stockStatusId = "9f7a589f-0b81-4e69-b29e-5310c730d3d8";
}

// Hardcoded values list of damage types
class DamageType {
  static const damageTypes = ['Package', 'CN'];
}

// Hardcoded values list of damage severities
class DamageSeverity {
  static const severityOptions = ['Minor', 'Major'];
}

enum UserType { vendor, customer, employee, driver }