# Paystack Integration Setup Guide

This guide will help you set up Paystack payment integration in your Flutter fintech app.

## 🚀 Quick Start

### 1. Get Paystack API Keys

1. Go to [Paystack Dashboard](https://dashboard.paystack.com/#/settings/api-keys)
2. Sign up or log in to your account
3. Navigate to Settings > API Keys
4. Copy your **Public Key** and **Secret Key**

### 2. Set Up Environment Variables

1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit the `.env` file and add your Paystack keys:
   ```env
   PAYSTACK_PUBLIC_KEY=pk_test_your_actual_public_key_here
   PAYSTACK_SECRET_KEY=sk_test_your_actual_secret_key_here
   ```

### 3. Test Your Integration

1. Run the app:
   ```bash
   flutter run
   ```

2. Navigate to the home screen and tap "Add Money" to test wallet funding
3. Use test card numbers from [Paystack Test Cards](https://paystack.com/docs/payments/test-payments/)

## 💳 Features Implemented

### ✅ Wallet Funding
- Users can add money to their wallet using Paystack
- Supports all major cards and bank transfers
- Real-time transaction verification
- Secure payment processing

### ✅ Bank Transfers
- Transfer money directly to Nigerian bank accounts
- Account number verification
- Support for all major Nigerian banks
- Instant transfer processing

### ✅ User-to-User Transfers
- Transfer money between app users
- Real-time balance updates
- Transaction history tracking

### ✅ Authentication
- Email/password login with Firebase
- User registration with data validation
- Secure user session management

## 🏦 Supported Banks

The app supports all major Nigerian banks including:
- Access Bank
- First Bank of Nigeria
- Guaranty Trust Bank
- United Bank for Africa
- Zenith Bank
- And many more...

## 🔧 Technical Details

### Services Created
- `PaystackService`: Handles all Paystack API interactions
- `EnhancedTransferService`: Manages transfers and wallet operations
- `WalletFundingViewModel`: State management for wallet funding
- `BankTransferViewModel`: State management for bank transfers

### Key Features
- **Real-time balance tracking** using Firestore streams
- **Transaction history** with detailed records
- **Account verification** for bank transfers
- **Secure payment processing** with Paystack
- **Error handling** and user feedback

## 🧪 Testing

### Test Card Numbers
Use these test card numbers for testing:

**Successful Payment:**
- Card: 4084084084084081
- CVV: 408
- Expiry: Any future date

**Failed Payment:**
- Card: 4084084084084085
- CVV: 408
- Expiry: Any future date

### Test Bank Account
- Account Number: 0000000000
- Bank: Access Bank (044)

## 📱 Usage

### Adding Money to Wallet
1. Tap "Add Money" on the home screen
2. Enter amount (minimum ₦100)
3. Add optional description
4. Tap "Fund Wallet"
5. Complete payment on Paystack page
6. Money is instantly added to your wallet

### Transferring to Bank
1. Tap "Bank Transfer" on the home screen
2. Select bank from dropdown
3. Enter account number and tap "Verify"
4. Enter amount and transfer reason
5. Tap "Transfer Money"
6. Transfer is processed instantly

### Transferring to Users
1. Tap "Money Transfer" on the home screen
2. Search for recipient by username/email
3. Enter amount and description
4. Confirm transfer
5. Money is transferred instantly

## 🔒 Security Features

- **Environment variables** for API keys
- **Firebase Authentication** for user management
- **Firestore security rules** for data protection
- **Paystack encryption** for payment data
- **Input validation** on all forms
- **Error handling** with user-friendly messages

## 🚨 Important Notes

1. **Never commit your `.env` file** to version control
2. **Use test keys** during development
3. **Switch to live keys** only for production
4. **Monitor transactions** in Paystack dashboard
5. **Set up webhooks** for production (optional)

## 🆘 Troubleshooting

### Common Issues

**"Environment variables not loaded"**
- Make sure `.env` file exists in project root
- Check that `.env` is added to `pubspec.yaml` assets
- Restart the app after adding environment variables

**"Paystack API error"**
- Verify your API keys are correct
- Check if you're using test keys for test transactions
- Ensure you have sufficient balance in your Paystack account

**"Transaction verification failed"**
- Check your internet connection
- Verify the transaction reference is correct
- Check Paystack dashboard for transaction status

## 📞 Support

For issues related to:
- **Paystack API**: Contact Paystack support
- **App functionality**: Check the code comments and documentation
- **Firebase**: Check Firebase console and documentation

## 🔄 Next Steps

1. **Set up webhooks** for real-time transaction updates
2. **Add more payment methods** (mobile money, etc.)
3. **Implement transaction limits** and security features
4. **Add push notifications** for transaction alerts
5. **Create admin dashboard** for transaction monitoring

---

**Happy coding! 🚀**
