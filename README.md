# Kisaan Kart Customer Flutter App

Updated customer-side Flutter MVP inspired by Blinkit/Amazon quick-commerce UI.

## Login
- Phone: any 10 digit number
- OTP: `1234`

## Included
- Login with phone + OTP
- Home dashboard with banners, categories, product cards and functional search
- Bottom navigation: Home, Categories, Cart, Orders, Profile
- Category listing and product detail navigation
- Add/remove cart from dashboard, category listing and detail screen
- Cart calculations: item total, delivery fee, handling, GST, total
- Address book with add/edit/delete and dummy addresses
- Dummy order history with detail screen and reorder flow
- Uses actual planned category/product structure: Kisan Mart stores, Grains, Pulses, Vegetables, Fruits, Others, Wheat/Rice/Barley/Maize, Mustard/Peanuts, pack sizes etc.

## Run
If Flutter project platform folders are not present, run once inside this folder:

```bash
flutter create .
flutter pub get
flutter run -d chrome
```

For Android/iOS:

```bash
flutter run
```
