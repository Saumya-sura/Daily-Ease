import '../../features/discovery/domain/service_category.dart';

class ServiceCategoriesCatalog {
  static final List<ServiceCategory> defaultCategories = [
    const ServiceCategory(
      id: 'maid',
      nameEn: 'Maid / Helper',
      nameHi: 'कामवाली बाई',
      nameMr: 'कामवाली मावशी',
      iconName: 'maid',
      searchAliases: ['maid', 'bai', 'kamwali', 'househelp', 'बाई', 'कामवाली', 'मावशी'],
      supportedBillingModels: ['monthly', 'per_visit', 'daily'],
      dynamicFields: [
        CategoryFormField(
          key: 'chores',
          label: 'Chores Provided',
          fieldType: 'multiselect',
          options: ['Sweeping & Mopping', 'Utensil Washing', 'Dusting', 'Babysitting', 'Clothes Washing'],
        ),
        CategoryFormField(
          key: 'work_type',
          label: 'Work Arrangement',
          fieldType: 'dropdown',
          options: ['Full-time (8-10 hrs)', 'Part-time Morning', 'Part-time Evening', '1-Day Temporary'],
        ),
      ],
    ),
    const ServiceCategory(
      id: 'milkman',
      nameEn: 'Milk Delivery',
      nameHi: 'दूध डिलीवरी',
      nameMr: 'दूधवाला',
      iconName: 'milkman',
      searchAliases: ['milk', 'milkman', 'doodhwala', 'dairy', 'दूध', 'दूधवाला'],
      supportedBillingModels: ['per_liter', 'monthly'],
      dynamicFields: [
        CategoryFormField(
          key: 'milk_type',
          label: 'Milk Varieties Offered',
          fieldType: 'multiselect',
          options: ['Fresh Cow Milk', 'Buffalo Pure Milk', 'A2 Organic Desi Cow', 'Toned Packaged'],
        ),
        CategoryFormField(
          key: 'delivery_slot',
          label: 'Morning Delivery Window',
          fieldType: 'dropdown',
          options: ['05:00 AM - 06:30 AM', '06:30 AM - 08:00 AM'],
        ),
      ],
    ),
    const ServiceCategory(
      id: 'watchman',
      nameEn: 'Watchman / Security',
      nameHi: 'सुरक्षा गार्ड / चौकीदार',
      nameMr: 'सुरक्षारक्षक / वॉचमन',
      iconName: 'watchman',
      searchAliases: ['watchman', 'security', 'guard', 'chowkidar', 'चौकीदार', 'सुरक्षारक्षक'],
      supportedBillingModels: ['monthly', 'daily'],
      dynamicFields: [
        CategoryFormField(
          key: 'shift_type',
          label: 'Shift Availability',
          fieldType: 'dropdown',
          options: ['Day Shift (12 hrs)', 'Night Shift (12 hrs)', '24 Hours Resident', 'Temporary Event Guard'],
        ),
        CategoryFormField(
          key: 'verification_docs',
          label: 'Verification Provided',
          fieldType: 'multiselect',
          options: ['Police Clearance Certificate', 'Aadhaar Verified', 'Prior Society Reference'],
        ),
      ],
    ),
    const ServiceCategory(
      id: 'plumber',
      nameEn: 'Plumber',
      nameHi: 'प्लंबर',
      nameMr: 'प्लंबर',
      iconName: 'plumber',
      searchAliases: ['plumber', 'pipe', 'leak', 'tap', 'प्लंबर', 'नळ'],
      supportedBillingModels: ['per_visit', 'hourly'],
      dynamicFields: [
        CategoryFormField(
          key: 'specializations',
          label: 'Plumbing Skills',
          fieldType: 'multiselect',
          options: ['Pipe Leak Repair', 'Water Tank Cleaning', 'Bathroom Fitting', 'Motor / Pump Installation'],
        ),
      ],
    ),
    const ServiceCategory(
      id: 'electrician',
      nameEn: 'Electrician',
      nameHi: 'इलेक्ट्रीशियन',
      nameMr: 'इलेक्ट्रिशियन',
      iconName: 'electrician',
      searchAliases: ['electrician', 'wiring', 'fuse', 'inverter', 'इलेक्ट्रीशियन', 'लाईट'],
      supportedBillingModels: ['per_visit', 'hourly'],
      dynamicFields: [
        CategoryFormField(
          key: 'specializations',
          label: 'Electrical Services',
          fieldType: 'multiselect',
          options: ['Fan & Light Installation', 'MCB Tripping & Wiring', 'Inverter Battery Setup', 'Appliance Repair'],
        ),
      ],
    ),
    const ServiceCategory(
      id: 'carpenter',
      nameEn: 'Carpenter',
      nameHi: 'बढ़ई',
      nameMr: 'सुतार',
      iconName: 'carpenter',
      searchAliases: ['carpenter', 'wood', 'furniture', 'badhai', 'बढ़ई', 'सुतार'],
      supportedBillingModels: ['per_visit', 'daily'],
      dynamicFields: [
        CategoryFormField(
          key: 'specializations',
          label: 'Woodworking Expertise',
          fieldType: 'multiselect',
          options: ['Door Lock & Hinge Repair', 'Modular Furniture Assembly', 'Custom Woodwork', 'Bed & Sofa Repair'],
        ),
      ],
    ),
    const ServiceCategory(
      id: 'cook',
      nameEn: 'Cook / Chef',
      nameHi: 'रसोइया',
      nameMr: 'आचारी / स्वयंपाकी',
      iconName: 'cook',
      searchAliases: ['cook', 'chef', 'food', 'rasoiya', 'रसोइया', 'आचारी', 'स्वयंपाक'],
      supportedBillingModels: ['monthly', 'per_visit', 'daily'],
      dynamicFields: [
        CategoryFormField(
          key: 'cuisines',
          label: 'Cuisines Prepared',
          fieldType: 'multiselect',
          options: ['North Indian', 'South Indian', 'Maharashtrian', 'Gujarati / Jain Satvik', 'Chinese / Snacks'],
        ),
        CategoryFormField(
          key: 'family_capacity',
          label: 'Cooking Capacity',
          fieldType: 'dropdown',
          options: ['Up to 4 Persons', '5 to 8 Persons', 'Large Family / Gathering'],
        ),
      ],
    ),
    const ServiceCategory(
      id: 'cleaner',
      nameEn: 'Deep Cleaning',
      nameHi: 'गहरी सफाई',
      nameMr: 'सखोल स्वच्छता',
      iconName: 'cleaner',
      searchAliases: ['cleaner', 'cleaning', 'safai', 'deep cleaning', 'सफाई', 'स्वच्छता'],
      supportedBillingModels: ['per_visit', 'hourly'],
      dynamicFields: [
        CategoryFormField(
          key: 'clean_areas',
          label: 'Cleaning Packages',
          fieldType: 'multiselect',
          options: ['Full House Deep Clean', 'Kitchen Degreasing', 'Bathroom Scrubbing & Sanitization', 'Sofa & Mattress Shampoo'],
        ),
      ],
    ),
  ];
}
