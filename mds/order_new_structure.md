# 🧾 Order Status & Stages Reference

This document explains the **Order Lifecycle** for all orders handled by the system.  
Each order moves through **statuses** (business logic level) and **stages** (detailed tracking inside `orderStages`).

---

## 🚦 Order Statuses

Each order has a primary field:

```plaintext
orderStatus: String
````

and a derived classification:

```plaintext
statusCategory: ['NEW', 'PROCESSING', 'PAUSED', 'SUCCESSFUL', 'UNSUCCESSFUL']
```

---

## 🧩 Status Categories Overview

| **Category**     | **Description**                                           | **Example Statuses**                                   |
| ---------------- | --------------------------------------------------------- | ------------------------------------------------------ |
| **NEW**          | Order just created or waiting for pickup                  | `new`, `pendingPickup`                                 |
| **PROCESSING**   | Order is being handled (pickup, delivery, or return flow) | `pickedUp`, `inStock`, `inProgress`, `returnInitiated` |
| **PAUSED**       | Order awaiting business or system action                  | `waitingAction`, `rejected`                            |
| **SUCCESSFUL**   | Order flow completed successfully                         | `completed`, `returnCompleted`                         |
| **UNSUCCESSFUL** | Order flow ended unsuccessfully                           | `canceled`, `returned`, `terminated`, `deliveryFailed` |

---

## 🧭 All Supported Order Statuses

| **Status**            | **Description**                                    | **Category** |
| --------------------- | -------------------------------------------------- | ------------ |
| `new`                 | Order created by business                          | NEW          |
| `pendingPickup`       | Waiting for courier pickup                         | NEW          |
| `pickedUp`            | Picked up from business                            | PROCESSING   |
| `inStock`             | Arrived at warehouse                               | PROCESSING   |
| `inReturnStock`       | Returned item received in warehouse                | PROCESSING   |
| `inProgress`          | Being processed or prepared for delivery           | PROCESSING   |
| `headingToCustomer`   | Courier is on the way to deliver to customer       | PROCESSING   |
| `returnToWarehouse`   | Return order on the way to warehouse               | PROCESSING   |
| `headingToYou`        | Return heading back to business                    | PROCESSING   |
| `rescheduled`         | Delivery rescheduled                               | PROCESSING   |
| `waitingAction`       | Awaiting business response or action               | PAUSED       |
| `rejected`            | Order rejected by courier                          | PAUSED       |
| `completed`           | Delivered successfully to customer                 | SUCCESSFUL   |
| `returnCompleted`     | Return successfully completed                      | SUCCESSFUL   |
| `canceled`            | Canceled by business or admin                      | UNSUCCESSFUL |
| `returned`            | Returned to business                               | UNSUCCESSFUL |
| `terminated`          | Terminated manually by admin                       | UNSUCCESSFUL |
| `deliveryFailed`      | Delivery failed (customer unavailable/rejected)    | UNSUCCESSFUL |
| `autoReturnInitiated` | System auto-triggered a return flow                | UNSUCCESSFUL |
| `returnInitiated`     | Business initiated a return process                | PROCESSING   |
| `returnAssigned`      | Courier assigned for return pickup                 | PROCESSING   |
| `returnPickedUp`      | Return picked up from customer                     | PROCESSING   |
| `returnAtWarehouse`   | Returned item received at warehouse                | PROCESSING   |
| `returnToBusiness`    | Courier assigned to deliver return to business     | PROCESSING   |
| `returnLinked`        | Return order linked to its original delivery order | PROCESSING   |

---

## 🧱 Order Stages (`orderStages`)

Each stage represents a detailed operational milestone in the order’s lifecycle.

Each has the following structure:

```plaintext
{
  isCompleted: Boolean,
  completedAt: Date,
  notes: String
}
```

Some stages also include additional fields such as `initiatedBy`, `assignedCourier`, `inspectionResult`, etc.

---

### 🔹 Main Delivery Flow Stages

| **Stage**        | **Description**                   | **Trigger**              |
| ---------------- | --------------------------------- | ------------------------ |
| `orderPlaced`    | Order created successfully        | On creation              |
| `packed`         | Business packed the order         | Before pickup            |
| `shipping`       | Order in shipping process         | Courier in transit       |
| `inProgress`     | Warehouse is processing the order | After warehouse receives |
| `outForDelivery` | Courier heading to customer       | Courier assigned         |
| `delivered`      | Delivered successfully            | Customer received        |

---

### 🔸 Return Flow Stages

| **Stage**           | **Description**                                | **Additional Fields**                                  |
| ------------------- | ---------------------------------------------- | ------------------------------------------------------ |
| `returnInitiated`   | Business or system initiates return            | `initiatedBy`, `reason`                                |
| `returnAssigned`    | Admin assigns courier for pickup               | `assignedCourier`, `assignedBy`                        |
| `returnPickedUp`    | Courier picked up from customer                | `pickedUpBy`, `pickupLocation`, `pickupPhotos`         |
| `returnAtWarehouse` | Return item received at warehouse              | `receivedBy`, `warehouseLocation`, `conditionNotes`    |
| `returnInspection`  | Inspection at warehouse                        | `inspectedBy`, `inspectionResult`, `inspectionPhotos`  |
| `returnProcessing`  | Refund/Exchange/Repair processing              | `processedBy`, `processingType`                        |
| `returnToBusiness`  | Courier assigned to deliver return to business | `assignedCourier`, `assignedBy`                        |
| `returnCompleted`   | Return successfully delivered to business      | `completedBy`, `businessSignature`, `deliveryLocation` |
| `returned`          | Final state confirming return completion       | `returnOrderCompleted`, `returnOrderCompletedAt`       |

---

## 🧾 Courier History Tracking

Each action by a courier is logged in:

```plaintext
courierHistory: [
  {
    courier: ObjectId,
    assignedAt: Date,
    action: 'assigned' | 'pickup_from_customer' | 'delivered_to_warehouse' | 'pickup_from_warehouse' | 'delivered_to_business' | 'completed',
    notes: String
  }
]
```

---

## ⚙️ Auto-Update Rules

* When `orderStatus` changes, a new entry is added to `orderStatusHistory` with the current category.
* When status changes to `inStock`, the system auto-checks if the pickup can be marked as completed.
* On completion or return, the system auto-sets `moneyReleaseDate` to the **next Wednesday**.

---

```

---

Would you like me to export it as a downloadable `.md` file for you (so you can directly import it into Postman or GitHub)?
```
