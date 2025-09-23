# Firestore Index Setup Guide

## Issue
The app was getting a Firestore composite index error when querying pending transactions with multiple `where` clauses and `orderBy`.

## Error Message
```
[cloud_firestore/failed-precondition] The query requires an index. You can create it here: https://console.firebase.google.com/v1/r/project/olien-875f1/firestore/indexes?create_composite=...
```

## Solution 1: Application-Level Filtering (Recommended - Already Implemented)
✅ **Already Fixed**: Modified queries to avoid composite index requirements by:
- Using only one `where` clause (`user_id`)
- Adding `orderBy` on `created_at`
- Filtering additional conditions in application code
- Adding `limit(50)` for performance

## Solution 2: Create Firestore Composite Index (Alternative)

If you prefer to use Firestore's native filtering, you can create the required composite index:

### Steps:
1. **Click the provided link** in the error message
2. **Or manually create index** in Firebase Console:
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Select your project (`olien-875f1`)
   - Go to **Firestore Database** → **Indexes**
   - Click **Create Index**

### Required Indexes:

#### For Pending Wallet Funding Transactions:
```
Collection: pending_transactions
Fields:
- user_id (Ascending)
- type (Ascending) 
- status (Ascending)
- created_at (Descending)
```

#### For Bank Payment History:
```
Collection: pending_transactions
Fields:
- user_id (Ascending)
- payment_method (Ascending)
- created_at (Descending)
```

#### For Pending Bank Payments:
```
Collection: pending_transactions
Fields:
- user_id (Ascending)
- payment_method (Ascending)
- status (Ascending)
- created_at (Descending)
```

## Recommendation
**Use Solution 1** (already implemented) because:
- ✅ No additional Firebase configuration needed
- ✅ Faster development and deployment
- ✅ No index maintenance overhead
- ✅ Works immediately without waiting for index creation
- ✅ Better performance for small datasets

## Performance Notes
- Application-level filtering is efficient for small to medium datasets
- For large datasets (1000+ transactions per user), consider creating Firestore indexes
- Current implementation limits results to 50 transactions for optimal performance
