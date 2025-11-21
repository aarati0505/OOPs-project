# Retailer & Wholesaler UI Documentation

## 📋 Overview

This document provides a comprehensive overview of all Retailer and Wholesaler Flutter UI screens created for the e-commerce system. All screens are built using the existing color scheme (AppColors) and font family (Gilroy), ensuring consistency with the current application design.

---

## 🎨 Design System Used

### Colors (from `app_colors.dart`)
- **Primary**: `#00AD48` (AppColors.primary)
- **Scaffold Background**: `#FFFFFF` (AppColors.scaffoldBackground)
- **Scaffold with Box Background**: `#F7F7F7` (AppColors.scaffoldWithBoxBackground)
- **Card Color**: `#F2F2F2` (AppColors.cardColor)
- **Placeholder**: `#8B8B97` (AppColors.placeholder)
- **Gray**: `#E1E1E1` (AppColors.gray)

### Typography
- **Font Family**: Gilroy (Regular, Medium, Bold)
- All text styles follow existing theme (`app_themes.dart`)

### Spacing & Layout
- **Padding**: 15px (AppDefaults.padding)
- **Margin**: 15px (AppDefaults.margin)
- **Border Radius**: 15px (AppDefaults.radius)

---

## 📦 Created Files Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart (UPDATED - added new endpoints)
│   └── models/
│       └── dashboard_model.dart (NEW)
├── views/
│   ├── shared/
│   │   └── components/
│   │       ├── kpi_tile.dart (NEW)
│   │       ├── status_badge.dart (NEW)
│   │       └── order_card.dart (NEW)
│   ├── retailer/
│   │   ├── retailer_dashboard_new.dart (NEW)
│   │   ├── import_wholesaler_product_page.dart (NEW)
│   │   ├── create_wholesale_order_page.dart (NEW)
│   │   └── inventory_management_page.dart (NEW)
│   └── wholesaler/
│       └── wholesaler_dashboard_new.dart (NEW)
```

---

## 🏪 RETAILER SCREENS

### 1. Retailer Dashboard (`retailer_dashboard_new.dart`)

**Purpose**: Main dashboard for retailers with analytics and quick actions

**Features**:
- **KPI Tiles Grid** (2x2):
  - Total Products (with in-stock count)
  - Total Revenue (with completed orders)
  - Pending Orders
  - Low Stock Alerts
- **Quick Actions Grid**:
  - Add Product
  - Import from Wholesaler (blue themed)
  - Manage Inventory (purple themed)
  - Wholesale Orders (indigo themed)
- **Low Stock Alerts Section**:
  - List of products with stock < 10
  - Visual "Low" badge
  - Quick access to restock
- **Recent Customer Orders**:
  - Order cards with status badges
  - Customer name, amount, date
  - Tap to view details
- **Wholesale Orders History**:
  - Orders placed to wholesalers
  - Wholesaler name, status, amount
  - Differentiated with warehouse icon

**APIs Connected**:
- `GET /users/dashboard` - Loads all dashboard data
- Returns role-specific analytics

**Key Components Used**:
- `KPITile` - Metrics display
- `StatusBadge` - Order status
- `_QuickActionButton` - Action buttons
- `_OrderSummaryCard` - Order preview

---

### 2. Import Wholesaler Product Page (`import_wholesaler_product_page.dart`)

**Purpose**: Browse and import wholesaler products (Proxy Inventory feature)

**Features**:
- **Search Bar**: Search wholesaler products
- **Product Cards**:
  - Product image, name, category
  - "Wholesaler Product" badge
  - Wholesale price displayed
  - Stock availability
  - "Import to My Inventory" button
- **Import Dialog**:
  - Customize selling price (default: wholesaler price)
  - Set initial stock (default: 0)
  - Info message about "Imported" badge
  - Confirm/Cancel actions
- **Empty State**: 
  - Friendly message when no products found

**APIs Connected**:
- `GET /products?sourceType=wholesaler` - Fetch wholesaler products
- `POST /inventory/import-from-wholesaler` - Import product

**Data Flow**:
1. Browse wholesaler products
2. Select product to import
3. Customize price & initial stock
4. Confirm import
5. Product appears in retailer inventory with proxy badge

**Key Features**:
- Price override capability
- Initial stock setting
- Visual feedback on import
- Prevents duplicate imports

---

### 3. Create Wholesale Order Page (`create_wholesale_order_page.dart`)

**Purpose**: Place wholesale orders to wholesalers (Retailer → Wholesaler flow)

**Features**:
- **Shopping Cart**:
  - Add products from wholesalers
  - Adjust quantities
  - Remove items
  - Real-time total calculation
- **Cart Item Card**:
  - Product image & name
  - Price per unit
  - Quantity controls (+/-)
  - Subtotal display
  - Delete button
- **Empty Cart State**:
  - Helpful message
  - "Browse Wholesaler Products" CTA
- **Bottom Bar**:
  - Total amount display
  - "Place Order" button
  - Loading state during submission

**APIs Connected**:
- `POST /orders/wholesale` - Create wholesale order

**Order Flow**:
1. Browse wholesaler products
2. Add to wholesale cart
3. Adjust quantities
4. Review total
5. Place order
6. Confirmation & navigation back

**Key Features**:
- Multi-product orders
- Quantity management
- Total calculation
- Order validation
- Success feedback

---

### 4. Inventory Management Page (`inventory_management_page.dart`)

**Purpose**: Manage all products with distinction between owned and imported

**Features**:
- **Tab Navigation**:
  - All Products
  - Owned (retailer's own products)
  - Imported (proxy products from wholesalers)
- **Product Cards**:
  - Product image, name, category, price
  - **Proxy Badge** for imported products
  - Stock indicator (green if > 10, red if < 10)
  - Two action buttons per product
- **Action Buttons**:
  - For owned products:
    - "Update Stock"
    - "Edit"
  - For imported products:
    - "Update Stock"
    - "Order More" (places order to wholesaler)
- **Floating Action Buttons**:
  - Mini FAB: Import from Wholesaler (blue)
  - Extended FAB: Add Product (primary green)
- **Stock Update Dialog**:
  - Quick inline stock editing
  - Numeric keyboard
  - Instant API update

**APIs Connected**:
- `GET /inventory` - Load all inventory
- `PATCH /inventory/stock/:productId` - Update stock

**Key Visual Indicators**:
- 🔵 Blue "Imported" badge for proxy products
- 🟢 Green stock indicator (> 10 units)
- 🔴 Red stock indicator (< 10 units)
- ⚠️ Warning icon for low stock

---

## 🏭 WHOLESALER SCREENS

### 5. Wholesaler Dashboard (`wholesaler_dashboard_new.dart`)

**Purpose**: Main dashboard for wholesalers with business analytics

**Features**:
- **KPI Tiles Grid** (2x2):
  - Total Retailers (partners count)
  - Total Revenue (with order count)
  - Pending Orders (actionable)
  - Total Products (with stock info)
- **Recent Wholesale Orders**:
  - Orders from retailers
  - Retailer names (when available)
  - Order amounts & status
  - Tap to view/fulfill
- **Top Selling Products**:
  - Horizontal scrollable list
  - Product images
  - Units sold count
  - Trending up indicator
- **Business Insights Card**:
  - Total Inventory Value
  - Completed Orders
  - Average Order Value (calculated)
  - Icon indicators per metric
- **Floating Action Button**:
  - "Add Product" extended FAB
  - Quick access to add inventory

**APIs Connected**:
- `GET /users/dashboard` - Loads wholesaler analytics

**Key Metrics Displayed**:
- Retailer partnerships
- Revenue tracking
- Order fulfillment status
- Inventory value
- Top performers

---

## 🧩 SHARED COMPONENTS

### 1. KPI Tile (`kpi_tile.dart`)

**Variants**:
- **KPITile**: Vertical layout with icon, value, title, optional subtitle
- **KPITileHorizontal**: Compact horizontal layout

**Props**:
- `title`: String - Metric name
- `value`: String - Metric value
- `icon`: IconData - Icon to display
- `color`: Color? - Optional theme color
- `onTap`: VoidCallback? - Tap handler
- `subtitle`: String? - Optional additional info
- `trailing`: Widget? - Optional trailing widget

**Usage**:
```dart
KPITile(
  title: 'Total Products',
  value: '245',
  icon: Icons.inventory_2_outlined,
  subtitle: '180 in stock',
  onTap: () => navigateToInventory(),
)
```

---

### 2. Status Badge (`status_badge.dart`)

**Variants**:
- **StatusBadge**: Order status indicator
- **ProxyBadge**: "Imported" indicator for proxy products

**StatusBadge Props**:
- `status`: String - Order status (pending, confirmed, processing, shipped, delivered, cancelled)
- `isSmall`: bool - Compact size

**Status Colors**:
- Pending: Orange
- Confirmed: Blue
- Processing: Purple
- Shipped: Indigo
- Delivered: Green (primary)
- Cancelled: Red

**ProxyBadge**:
- Blue background
- Cloud download icon
- "Imported" text
- Small variant available

**Usage**:
```dart
StatusBadge(status: order.status, isSmall: true)
ProxyBadge(isSmall: true)
```

---

### 3. Order Card (`order_card.dart`)

**Purpose**: Reusable order display component

**Props**:
- `order`: OrderModel - Order data
- `onTap`: VoidCallback? - Tap handler
- `showCustomerName`: bool - Display customer (for retailers)
- `showRetailerName`: bool - Display retailer (for wholesalers)
- `showWholesalerName`: bool - Display wholesaler (for retailers)

**Features**:
- Order ID (last 6 chars)
- Status badge
- Customer/Retailer/Wholesaler name (conditional)
- Item count
- Order date
- Total amount (highlighted in primary color)
- Clean card design with divider

---

## 🔄 UX FLOW DIAGRAMS

### Flow 1: Retailer Importing Wholesaler Product (Proxy Inventory)

```
┌─────────────────────────────────────────────────────────────┐
│ 1. RETAILER DASHBOARD                                       │
│    ↓ Click "Import from Wholesaler" button                 │
├─────────────────────────────────────────────────────────────┤
│ 2. IMPORT WHOLESALER PRODUCT PAGE                           │
│    ↓ Search/Browse wholesaler products                      │
│    ↓ View product details (price, stock, wholesaler)        │
│    ↓ Click "Import to My Inventory"                         │
├─────────────────────────────────────────────────────────────┤
│ 3. IMPORT DIALOG                                            │
│    ↓ Set selling price (override wholesaler price)          │
│    ↓ Set initial stock (default: 0)                         │
│    ↓ Read info: "Product will have 'Imported' badge"        │
│    ↓ Click "Import"                                         │
├─────────────────────────────────────────────────────────────┤
│ 4. API CALL                                                 │
│    POST /inventory/import-from-wholesaler                   │
│    Body: { productId, price, stock }                        │
│    ↓ Backend creates proxy product                          │
│    ↓ Sets sourceType="wholesaler"                           │
│    ↓ Sets sourceProductId=original_product_id               │
├─────────────────────────────────────────────────────────────┤
│ 5. CONFIRMATION                                             │
│    ↓ Success snackbar: "Product imported successfully!"     │
│    ↓ Navigate back to dashboard                             │
├─────────────────────────────────────────────────────────────┤
│ 6. INVENTORY MANAGEMENT PAGE                                │
│    ↓ Product now appears with "Imported" badge              │
│    ↓ Shows in "Imported" tab                                │
│    ↓ "Order More" button available                          │
└─────────────────────────────────────────────────────────────┘
```

### Flow 2: Retailer Placing Wholesale Order

```
┌─────────────────────────────────────────────────────────────┐
│ 1. RETAILER DASHBOARD / INVENTORY PAGE                      │
│    ↓ Low stock alert appears                                │
│    ↓ Click "Order More" on imported product                 │
│    OR Click "Wholesale Orders" quick action                 │
├─────────────────────────────────────────────────────────────┤
│ 2. CREATE WHOLESALE ORDER PAGE                              │
│    ↓ Browse/search wholesaler products                      │
│    ↓ Add products to cart                                   │
│    ↓ Adjust quantities with +/- controls                    │
│    ↓ See real-time total calculation                        │
│    ↓ Review cart items                                      │
│    ↓ Click "Place Order"                                    │
├─────────────────────────────────────────────────────────────┤
│ 3. API CALL                                                 │
│    POST /orders/wholesale                                   │
│    Body: { items: [{productId, quantity}], paymentMethod }  │
│    ↓ Backend validates products & stock                     │
│    ↓ Decrements wholesaler product stock                    │
│    ↓ Increases retailer proxy product stock                 │
│    ↓ Creates notifications for both parties                 │
├─────────────────────────────────────────────────────────────┤
│ 4. CONFIRMATION                                             │
│    ↓ Success snackbar: "Wholesale order placed!"            │
│    ↓ Navigate back                                          │
├─────────────────────────────────────────────────────────────┤
│ 5. DASHBOARD UPDATE                                         │
│    ↓ Order appears in "Wholesale Orders" section            │
│    ↓ Inventory stock automatically updated                  │
│    ↓ Notification received                                  │
│    ↓ Wholesaler receives order notification                 │
└─────────────────────────────────────────────────────────────┘
```

### Flow 3: Wholesaler Fulfilling Retailer Order

```
┌─────────────────────────────────────────────────────────────┐
│ 1. WHOLESALER DASHBOARD                                     │
│    ↓ Notification: "New wholesale order from Retailer X"    │
│    ↓ Pending orders count increases                         │
│    ↓ Click on order in "Recent Wholesale Orders"            │
├─────────────────────────────────────────────────────────────┤
│ 2. ORDER DETAILS PAGE (to be built)                         │
│    ↓ View retailer information                              │
│    ↓ View order items & quantities                          │
│    ↓ See delivery address                                   │
│    ↓ Click status update: "Confirmed" → "Processing"        │
│    ↓ Add tracking number (optional)                         │
│    ↓ Click "Update Status"                                  │
├─────────────────────────────────────────────────────────────┤
│ 3. API CALL                                                 │
│    PATCH /orders/:orderId                                   │
│    Body: { status, trackingNumber }                         │
│    ↓ Backend updates order status                           │
│    ↓ Creates notification for retailer                      │
├─────────────────────────────────────────────────────────────┤
│ 4. STATUS UPDATE TIMELINE                                   │
│    Pending → Confirmed → Processing → Shipped → Delivered   │
│    Each update triggers retailer notification               │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔌 API Integration Summary

### Dashboard Endpoint
```dart
GET /users/dashboard
Headers: { Authorization: Bearer <token> }
Response: DashboardModel (role-specific data)
```

### Import Wholesaler Product
```dart
POST /inventory/import-from-wholesaler
Headers: { Authorization: Bearer <token> }
Body: {
  "productId": "string",
  "stock": int (optional),
  "price": double (optional)
}
Response: Imported ProductModel with sourceType="wholesaler"
```

### Create Wholesale Order
```dart
POST /orders/wholesale
Headers: { Authorization: Bearer <token> }
Body: {
  "items": [{ "productId": "string", "quantity": int }],
  "paymentMethod": "cash_on_delivery"
}
Response: OrderModel
```

### Get Inventory
```dart
GET /inventory
Headers: { Authorization: Bearer <token> }
Response: Paginated list of products
  - Filter by sourceType in frontend
  - Owned: sourceType == null || sourceType == "retailer"
  - Imported: sourceType == "wholesaler"
```

### Update Stock
```dart
PATCH /inventory/stock/:productId
Headers: { Authorization: Bearer <token> }
Body: {
  "quantity": int,
  "operation": "set" | "add" | "subtract"
}
Response: Updated ProductModel
```

---

## 📱 Widget Mapping (Flutter → Backend)

| Flutter Widget | Backend Endpoint | Data Model |
|----------------|------------------|------------|
| KPITile | `/users/dashboard` | DashboardStats |
| StatusBadge | Order status field | String (status) |
| ProxyBadge | Product sourceType | String ("wholesaler") |
| OrderCard | `/orders/*` | OrderModel |
| _InventoryProductCard | `/inventory` | ProductModel |
| _WholesaleCartItemCard | Local state | ProductModel + quantity |

---

## 🎨 Design Tokens Used

### Colors
- Primary actions: `AppColors.primary` (#00AD48)
- Danger/Low stock: `Colors.red.shade700`
- Info/Import: `Colors.blue.shade700`
- Warning: `Colors.orange`
- Success: `Colors.green`

### Spacing
- Card padding: `AppDefaults.padding` (15px)
- Card margin: `AppDefaults.padding` (15px)
- Section spacing: `24px`
- Element spacing: `8px, 12px, 16px`

### Typography
- Headline: `textTheme.headlineSmall` (Bold)
- Title: `textTheme.titleLarge` (Bold)
- Body: `textTheme.bodyMedium`
- Caption: `textTheme.bodySmall`
- Placeholder: `AppColors.placeholder`

### Border Radius
- Cards: `AppDefaults.borderRadius` (15px)
- Buttons: `AppDefaults.borderRadius` (15px)
- Badges: `BorderRadius.circular(20)`
- Images: `BorderRadius.circular(8)`

---

## 🚀 Next Steps / Future Enhancements

### Additional Screens to Build
1. **Order Details Page** (for both retailer & wholesaler)
   - Full order information
   - Item list with images
   - Status timeline with tracking
   - Update status controls (for sellers)

2. **Product Details/Edit Page**
   - Full product information
   - Image gallery
   - Edit controls
   - Delete confirmation

3. **Wholesaler Order Fulfillment Page**
   - Batch order processing
   - Bulk status updates
   - Tracking number assignment
   - Internal notes

4. **Analytics Dashboard (Web View)**
   - Revenue charts
   - Sales trends
   - Retailer performance (for wholesalers)
   - Product performance

5. **Notifications Page**
   - Filter by type (order, system, payment)
   - Mark as read
   - Navigate to related entity

### Recommended Improvements
- Add pull-to-refresh on all list screens ✅ (Already added)
- Implement search functionality
- Add filters (category, price range, stock status)
- Add sorting options
- Implement pagination for large lists
- Add image upload for products
- Add bulk operations (multi-select)
- Add export functionality (CSV, PDF)

---

## 📚 Usage Guide

### For Developers

1. **Import Required Files**:
```dart
import 'package:grocery/core/constants/app_colors.dart';
import 'package:grocery/core/constants/app_defaults.dart';
import 'package:grocery/core/models/dashboard_model.dart';
import 'package:grocery/views/shared/components/kpi_tile.dart';
import 'package:grocery/views/shared/components/status_badge.dart';
```

2. **Replace Token Placeholders**:
   - Search for `'YOUR_TOKEN_HERE'` in all files
   - Replace with actual token from auth service:
   ```dart
   final authService = Provider.of<AuthService>(context, listen: false);
   final token = authService.accessToken;
   ```

3. **Add Routes** (in `app_routes.dart`):
```dart
static const String retailerDashboard = '/retailer/dashboard';
static const String importWholesaler = '/retailer/import-wholesaler';
static const String createWholesaleOrder = '/retailer/wholesale-order';
static const String inventoryManagement = '/retailer/inventory';
static const String wholesalerDashboard = '/wholesaler/dashboard';
```

4. **Update Navigation** (in `on_generate_route.dart`):
```dart
case AppRoutes.retailerDashboard:
  return MaterialPageRoute(
    builder: (_) => const RetailerDashboardNew(),
  );
// ... add other routes
```

---

## ✅ Checklist for Integration

- [x] Created dashboard model
- [x] Created shared components (KPI, badges, cards)
- [x] Created retailer dashboard
- [x] Created import wholesaler screen
- [x] Created wholesale order screen
- [x] Created inventory management screen
- [x] Created wholesaler dashboard
- [x] Updated constants with new endpoints
- [ ] Replace token placeholders with auth service
- [ ] Add routes to app_routes.dart
- [ ] Update on_generate_route.dart
- [ ] Test API connections
- [ ] Handle loading states
- [ ] Handle error states
- [ ] Add validation
- [ ] Test on different screen sizes
- [ ] Test tablet/web layouts

---

## 📞 Support

For questions or issues with these screens:
1. Check API documentation in `backend/nodejs/HEALTH_CHECK_SUMMARY.md`
2. Verify endpoints in `lib/core/constants/app_constants.dart`
3. Review existing patterns in `lib/views/home/` screens
4. Consult theme configuration in `lib/core/themes/app_themes.dart`

---

**Created**: November 21, 2025  
**Version**: 1.0  
**Status**: ✅ Ready for Integration

