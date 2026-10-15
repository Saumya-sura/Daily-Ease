# Daily-Ease — Quality Assurance & Testing Guide
**Version:** 1.0.0  
**Test Suite Status:** 10/10 Tests Passing (100% Pass Rate)  
**Sample Seed Data:** [`test_data/sample_seed_data.json`](../test_data/sample_seed_data.json)  

---

## 1. Testing Philosophy & Strategy

Daily-Ease implements a multi-tiered testing strategy designed to validate correctness across all layers of the application:
1. **Unit Tests:** Fast, isolated testing of domain models, serialization, state mutations, and business logic.
2. **Widget Tests:** Validation of Flutter UI components, icon badge rendering, status badges, and localization formatting.
3. **Offline & Resilience Tests:** Validating seamless fallback to local Hive cache when network connectivity is lost.
4. **Manual & Acceptance Testing Matrix:** Step-by-step end-to-end verification workflows covering consumer discovery, booking lifecycle, and provider management.

---

## 2. Automated Test Suite Execution

To run the full automated test suite:

```bash
flutter test
```

### Detailed Verbose Output:
```bash
flutter test --reporter=expanded
```

### Running Specific Test Suites:
```bash
# Run BookingModel and state machine tests
flutter test test/booking_model_test.dart

# Run ProviderProfile and pricing format tests
flutter test test/provider_profile_test.dart

# Run Core UI and Catalog widget tests
flutter test test/widget_test.dart
```

---

## 3. Automated Test Coverage Breakdown

| Test Suite | File | Tests | Focus Areas |
| :--- | :--- | :---: | :--- |
| **Booking Model Suite** | `test/booking_model_test.dart` | 3 | JSON serialization, timeline audit parsing, recurring vs. one-time flags, status getters |
| **Provider Profile Suite** | `test/provider_profile_test.dart` | 3 | Pricing formatting (`/hr`, `/month`, `/liter`, `/visit`), verification badge status, JSON serialization |
| **Core & Widget Suite** | `test/widget_test.dart` | 4 | Service catalog completeness, multilingual search aliases (`bai`, `कामवाली`), badge widget rendering, icon fallback |
| **Total Automated** | | **10** | **All Passed (0 errors)** |

---

## 4. Comprehensive Manual QA Matrix & Test Cases

The following test matrix defines end-to-end acceptance criteria for manual and integration verification:

| Test ID | Module | Scenario | Preconditions | Steps | Expected Result |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **TC-01** | Discovery | Multilingual Search Aliases | App running on Home screen | 1. Enter `"maid"` in search bar.<br>2. Clear and enter `"कामवाली"`.<br>3. Clear and enter `"दूधवाला"`. | In all three queries, matching service categories and providers are immediately returned without manual language switching. |
| **TC-02** | Discovery | "Need Help Today" Quick Launcher | App on Home screen | 1. Tap on the *"Need Help Today"* banner.<br>2. Observe filtered results. | Only providers with `is_temporary_job_mode_active = true` and same-day availability are shown. |
| **TC-03** | Society | Housing Complex Filtering | Societies seeded | 1. Navigate to *Societies* tab.<br>2. Select *"Gokuldham Society"*.<br>3. Tap *"View Active Workers"*. | Only service providers registered as serving Gokuldham Society are displayed. |
| **TC-04** | Discovery | Side-by-Side Comparison | At least 2 providers in list | 1. Long-press or tap *"Compare"* on 2 providers.<br>2. Tap *"Compare Now (2)"*. | A modal displays side-by-side pricing, rating, experience, and societies served. |
| **TC-05** | Communication | Direct Calling & Privacy | Provider with contact enabled | 1. Open provider detail screen.<br>2. Tap *"Call Direct"* button. | Native phone dialer opens with provider's phone number. Profile `calls_initiated` metric increments. |
| **TC-06** | Provider | Self-Serve Onboarding | Start at Role Select screen | 1. Tap *"I am a Service Provider"*.<br>2. Fill trade, base price, societies, and phone.<br>3. Tap *"Publish My Listing"*. | Listing is created instantly with `"Self-Listed"` badge without administrative blocking. |
| **TC-07** | Provider | Temporary Job Mode Toggle | In Provider Pro Dashboard | 1. Toggle *"Accept 1-Day Urgent Jobs"* switch to OFF.<br>2. Re-check discovery as consumer. | Provider is immediately excluded from "Need Help Today" urgent filters, while remaining active for recurring arrangements. |
| **TC-08** | Bookings | Create One-Time Booking | Logged in as consumer | 1. Select a plumber provider.<br>2. Choose date, time slot, and enter address.<br>3. Submit booking. | Booking appears under *Bookings* tab with `Requested` badge and timeline event created. |
| **TC-09** | Bookings | Provider Acceptance Flow | Booking in `Requested` status | 1. Switch to provider role.<br>2. Open booking and tap *"Accept Request"*. | Status changes to `Accepted`. Consumer view updates status to `Accepted` with green badge. |
| **TC-10** | Household | Skip Today for Milk Delivery | Recurring booking exists | 1. Go to Household Manager.<br>2. Tap *"Skip Today"* on active milk subscription. | Recurring status transitions to `Skipped Today`. Daily bill tracker deducts today's delivery amount. |
| **TC-11** | Bookings | Provider Cancellation & No-Show | Accepted booking | 1. Open booking.<br>2. Tap *"Report No-Show / Cancel"*.<br>3. Select reason from dropdown. | Booking moves to `Cancelled`, reason is recorded in audit timeline, and no-show flag is set. |
| **TC-12** | Offline | Offline Resilience & Banner | App running | 1. Disable Wi-Fi / Mobile Data.<br>2. Navigate between tabs.<br>3. Inspect cached data. | Amber *"You are currently offline"* banner appears. All previously loaded categories, providers, and bookings render from Hive cache. |
| **TC-13** | Settings | Theme Mode Persistence | In Profile screen | 1. Toggle Dark Mode switch.<br>2. Close and restart application. | App restarts with OLED Slate dark theme preserved from Hive storage. |
| **TC-14** | Localization | Tri-Lingual Language Switching | In Profile screen | 1. Select *"हिंदी"* (Hindi).<br>2. Verify navigation and titles.<br>3. Select *"मराठी"* (Marathi). | All static labels, tab bars, dialogs, and status badges translate immediately with appropriate Devanagari typography. |

---

## 5. Seed Data & Test Fixtures

Sample test data is pre-configured and provided in [`test_data/sample_seed_data.json`](../test_data/sample_seed_data.json). It contains:
- **10 Service Categories:** With English, Hindi, and Marathi names and search aliases.
- **5 Apartment Societies:** Centered in Mumbai / Pune localities (Powai, Chandivali, Mahalaxmi, Vikhroli).
- **5 Realistic Providers:** Verified maid, milkman, plumber, electrician, and home cook.
- **3 Bookings in Varied States:** `accepted` recurring cleaning, `skipped_today` milk delivery, and `completed` plumbing service.
- **Verified Review & Custom Request:** Sample customer feedback and open custom quote request.

### Importing Seed Data to Supabase
To populate a live Supabase project with seed data:
1. Open your Supabase project dashboard at [supabase.com](https://supabase.com).
2. Open the **SQL Editor**.
3. Paste the contents of [`supabase_schema.sql`](../supabase_schema.sql).
4. Click **Run**. All tables, RLS policies, the 5 km Haversine RPC function, and seed catalogs will be created.
