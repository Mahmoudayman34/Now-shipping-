# GET /orders

## Description

Retrieves orders for the authenticated business user. Supports filtering by order type and returns data sorted from newest to oldest based on `orderDate` and `createdAt`.

## Authentication

Required — The user must be authenticated with a valid token. The token should include `userData._id` to identify the business.

## Request

### Query Parameters

| Parameter  | Type   | Required | Description |
|------------|--------|----------|-------------|
| orderType  | String | No       | Filter orders by type. Valid values: `"Deliver"`, `"Return"`, `"Exchange"`, `"Cash Collection"`. If omitted, all orders are returned. |

### Example Request

```http
GET /orders?orderType=Deliver
```

## Response

### Success Response (200 OK)

Returns an array of order objects sorted by `orderDate` and `createdAt` in descending order (newest first).

### Error Response (500 Internal Server Error)

Returned if the server encounters an error while processing the request.

### Note

- The API returns an empty array if no orders match the filter.
- `orderType` is case-sensitive.
- Orders are only accessible for the authenticated business (from the token payload).

## Response Body Fields

| Field                                | Type                | Description |
|-------------------------------------|---------------------|-------------|
| _id                                 | String              | MongoDB unique identifier for the order |
| orderNumber                         | String              | Unique reference number for the order |
| orderDate                           | Date                | Date when the order was created |
| orderFees                           | Number              | Shipping fees for the order |
| orderStatus                         | String              | Current status of the order (`new`, `processing`, `completed`, etc.) |
| Attemps                             | Number              | Number of delivery attempts made |
| UnavailableReason                   | Array of Strings    | Reasons for unsuccessful delivery attempts |
| orderStatusHistory                  | Array of Objects    | Log of status changes with timestamps |
| orderCustomer.fullName              | String              | Customer's full name |
| orderCustomer.phoneNumber           | String              | Customer's contact number |
| orderCustomer.address               | String              | Customer's delivery address |
| orderCustomer.government            | String              | Government/province of the delivery address |
| orderCustomer.zone                  | String              | Specific zone within the government |
| orderShipping.productDescription    | String              | Description of the product being delivered |
| orderShipping.numberOfItems         | Number              | Quantity of items in the order |
| orderShipping.productDescriptionReplacement | String     | Description of replacement product (for exchanges) |
| orderShipping.numberOfItemsReplacement     | Number      | Quantity of replacement items |
| orderShipping.orderType             | String              | Type of order (`Deliver`, `Return`, `Exchange`, `Cash Collection`) |
| orderShipping.amountType            | String              | Payment type (`COD`, `CD`, `CC`, `NA`) |
| orderShipping.amount                | Number              | Amount to be collected from the customer |
| orderShipping.isExpressShipping     | Boolean             | Whether express shipping is selected |
| referralNumber                      | String              | Reference number for referrals |
| isOrderAvailableForPreview          | Boolean             | Whether order can be previewed by customer |
| orderNotes                          | String              | Additional notes for the order |
| orderStages                         | Array of Objects    | Detailed tracking of order progress |
| deliveryMan                         | ObjectId            | Reference to the assigned courier |
| business                            | ObjectId            | Reference to the business who created the order |
| isMoneyRecivedFromCourier           | Boolean             | Whether money has been received from the courier |
| completedDate                       | Date                | Date when the order was completed |
| moneyReleaseDate                    | Date                | Scheduled date for releasing funds |
| createdAt                           | Date                | Timestamp of record creation |
| updatedAt                           | Date                | Timestamp of last update |

## Sample Response

```json
[
  {
    "_id": "60d21b4667d0d8992e610c85",
    "orderNumber": "123456",
    "orderDate": "2023-05-15T12:30:45.000Z",
    "orderFees": 80,
    "orderStatus": "headingToCustomer",
    "Attemps": 1,
    "UnavailableReason": [],
    "orderStatusHistory": [
      {
        "status": "new",
        "date": "2023-05-15T12:30:45.000Z"
      },
      {
        "status": "headingToCustomer",
        "date": "2023-05-16T09:15:30.000Z"
      }
    ],
    "orderCustomer": {
      "fullName": "Ahmed Mohamed",
      "phoneNumber": "+201234567890",
      "address": "123 Main St, Apt 4",
      "government": "Cairo",
      "zone": "Nasr City"
    },
    "orderShipping": {
      "productDescription": "iPhone 13 Pro 128GB",
      "numberOfItems": 1,
      "productDescriptionReplacement": "",
      "numberOfItemsReplacement": 0,
      "orderType": "Deliver",
      "amountType": "COD",
      "amount": 15000,
      "isExpressShipping": false
    },
    "referralNumber": "REF123",
    "isOrderAvailableForPreview": true,
    "orderNotes": "Please call before delivery",
    "orderStages": [
      {
        "stageName": "Order Created",
        "stageDate": "2023-05-15T12:30:45.000Z",
        "stageNotes": [
          {
            "text": "Order has been created.",
            "date": "2023-05-15T12:30:45.000Z"
          }
        ]
      }
    ],
    "deliveryMan": "60d21b4667d0d8992e610c86",
    "business": "60d21b4667d0d8992e610c87",
    "isMoneyRecivedFromCourier": false,
    "createdAt": "2023-05-15T12:30:45.000Z",
    "updatedAt": "2023-05-16T09:15:30.000Z"
  }
]
```