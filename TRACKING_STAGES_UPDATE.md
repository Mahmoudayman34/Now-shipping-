# Order Tracking Stages - Show Completed Only

## 🎯 Objective

Updated the order tracking timeline to **display ONLY completed stages** (`isCompleted: true`) from the API response.

## 📋 Changes Made

### 1. Updated `trackingStepsProvider` Logic

**File:** `lib/features/business/orders/providers/order_details_provider.dart`

#### Key Changes:

1. **Filter stageTimeline**: Only show stages where `isCompleted: true`
2. **Filter orderStages**: For return orders, only show return stages where `isCompleted: true`
3. **Dynamic Display**: The timeline automatically adjusts based on API data

#### Before vs After:

**Before:**
- Showed ALL stages from `stageTimeline` (both completed and incomplete)
- Timeline included future stages that haven't happened yet

**After:**
- Shows ONLY stages where `isCompleted: true`
- Timeline displays only what has actually happened

## 🔍 How It Works

### For Deliver Orders

The system reads `stageTimeline` from the API and filters it:

```json
"stageTimeline": [
    {
        "stage": "orderPlaced",
        "isCompleted": true,           ← SHOWN ✓
        "completedAt": "2025-10-20T23:50:40.732Z",
        "notes": "Order has been created."
    },
    {
        "stage": "packed",
        "isCompleted": false,          ← HIDDEN ✗
        "completedAt": null,
        "notes": ""
    },
    {
        "stage": "shipping",
        "isCompleted": false,          ← HIDDEN ✗
        "completedAt": null,
        "notes": ""
    }
]
```

**Result:** Only "Order Placed" appears in the timeline.

### For Return Orders

The system combines:
1. **Completed stages from `stageTimeline`** (deliver flow)
2. **Completed stages from `orderStages`** (return flow)

Example with your API response:

```json
{
    "orderType": "Return",
    "stageTimeline": [
        {
            "stage": "orderPlaced",
            "isCompleted": true        ← SHOWN ✓
        }
    ],
    "orderStages": {
        "orderPlaced": {
            "isCompleted": true        ← Already in timeline
        },
        "returnInitiated": {
            "isCompleted": true,       ← SHOWN ✓ (added from orderStages)
            "completedAt": "2025-10-20T23:50:40.733Z",
            "notes": "Return order initiated by business.",
            "initiatedBy": "business",
            "reason": "Customer requested return"
        },
        "returnAssigned": {
            "isCompleted": false       ← HIDDEN ✗
        },
        "returnPickedUp": {
            "isCompleted": false       ← HIDDEN ✗
        }
    }
}
```

**Result:** Timeline shows:
1. ✅ Order Placed - "20 Oct 2025 - 23:50"
2. ✅ Return Initiated - "20 Oct 2025 - 23:50"

## 📊 Implementation Details

### Code Logic

```dart
// Build tracking steps from ONLY completed stages in the timeline
final List<Map<String, dynamic>> trackingSteps = [];

for (int i = 0; i < stageTimeline.length; i++) {
  final stage = stageTimeline[i] as Map<String, dynamic>;
  final isCompleted = stage['isCompleted'] as bool? ?? false;
  
  // ONLY add stages that are completed
  if (!isCompleted) {
    continue;  // Skip incomplete stages
  }
  
  // Add completed stage to timeline
  trackingSteps.add({
    'title': displayName,
    'status': stageName,
    'description': notes,
    'time': formattedTime,
    'isCompleted': true,
  });
}

// For return orders, also check orderStages for completed return stages
if (orderType == 'Return') {
  final returnStageKeys = [
    'returnInitiated',
    'returnAssigned',
    'returnPickedUp',
    'returnAtWarehouse',
    'returnInspection',
    'returnProcessing',
    'returnToBusiness',
    'returnCompleted',
  ];
  
  for (final stageKey in returnStageKeys) {
    final stageData = orderStages[stageKey];
    // Only add if completed AND not already in timeline
    if (stageData['isCompleted'] == true && !alreadyInTimeline) {
      trackingSteps.add({ /* stage info */ });
    }
  }
}
```

### Debug Output

Added debug logging to track what's being displayed:

```
DEBUG TRACKING: Order type: Return
DEBUG TRACKING: Stage timeline length: 6
DEBUG TRACKING: Order stages keys: [orderPlaced, packed, shipping, ...]
DEBUG TRACKING: Generated 2 completed tracking steps
  - Order Placed: 20 Oct 2025 - 23:50
  - Return Initiated: 20 Oct 2025 - 23:50
```

## 🎨 UI Impact

### Example 1: New Return Order (Just Created)

**API State:**
- `orderPlaced.isCompleted = true`
- `returnInitiated.isCompleted = true`
- All other stages = `false`

**Timeline Display:**
```
┌─────────────────────────────────┐
│ ● Order Placed                  │
│   20 Oct 2025 - 23:50          │
│   Order has been created.       │
│   |                             │
│ ● Return Initiated              │
│   20 Oct 2025 - 23:50          │
│   Return order initiated by     │
│   business.                     │
└─────────────────────────────────┘
```

### Example 2: Return Order (In Progress)

**API State:**
- `orderPlaced.isCompleted = true`
- `returnInitiated.isCompleted = true`
- `returnAssigned.isCompleted = true`
- `returnPickedUp.isCompleted = true`
- Other stages = `false`

**Timeline Display:**
```
┌─────────────────────────────────┐
│ ● Order Placed                  │
│   20 Oct 2025 - 23:50          │
│   |                             │
│ ● Return Initiated              │
│   20 Oct 2025 - 23:50          │
│   |                             │
│ ● Return Assigned               │
│   20 Oct 2025 - 23:55          │
│   |                             │
│ ● Return Picked Up              │
│   20 Oct 2025 - 23:58          │
└─────────────────────────────────┘
```

## ✅ Benefits

1. **Accurate Timeline**: Shows only what has actually happened
2. **No Clutter**: No future/pending stages displayed
3. **Real-time Updates**: Timeline grows as order progresses
4. **API-Driven**: Completely based on backend data
5. **Return Support**: Properly handles both deliver and return flows

## 🧪 Testing

### Test Case 1: New Order
- **Expected:** Only "Order Placed" appears
- **Verify:** `stageTimeline` has only 1 completed stage

### Test Case 2: Return Order - Initial
- **Expected:** "Order Placed" + "Return Initiated"
- **Verify:** 2 stages in timeline

### Test Case 3: Return Order - Completed
- **Expected:** Full return flow visible
- **Verify:** All 8+ return stages shown

## 📝 Notes

- The `stageTimeline` array from the API is trusted as the primary source
- For return orders, `orderStages` provides additional return-specific stages
- All timestamps are formatted as "dd MMM yyyy - HH:mm"
- Stage descriptions come from the API `notes` field
- Empty or missing notes fall back to default descriptions

## 🚀 Next Steps

The tracking system is now fully dynamic and based on actual order progress. As the backend updates the `isCompleted` flags in the API response, the mobile app timeline will automatically update to reflect the current state.

---

**Status:** ✅ Complete  
**Last Updated:** October 21, 2025

