
# E-Shop Flutter App
## Overview

E-Shop is a Flutter-based E-commerce application designed using **MVVM (Model-View-ViewModel)** architecture. The app allows users to browse products, manage their cart and wishlist, and purchase products. It uses **Firebase Authentication** for user login and signup, **Firestore** for storing user-specific cart and wishlist data, and **SharedPreferences** for managing user preferences such as cart items, wishlist items, and theme settings.

## Project Structre Well organized project
<img width="1696" height="1023" alt="image" src="https://github.com/user-attachments/assets/2757e9cf-98d6-416d-9514-cc7cb79afade" />

## Project Demo 
<img src="https://github.com/user-attachments/assets/d37aa220-3d0a-41f4-8901-13eebd17895c" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/d0a86e49-aa62-4fd5-8b7e-091dce978e41" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/2cae4a47-6c83-4125-803f-5e355d78e53b" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/1af85a8e-7311-4cca-bad9-38d3050a094a" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/f7dd34e1-ea0c-4b10-8198-48cd2bc26458" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/5bb48122-f6be-4195-b293-92401d8e1c8e" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/a4cfc52c-94c6-4ffc-bd5b-e72c6ba12f2d" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/8ae65484-735f-48b0-95bb-5ff470ee9d76" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/6c622710-7c09-4797-9699-c902bc3e60f7" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/357804cb-060a-48bd-96e3-5282e2784b56" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/9eda6660-0a6c-49fa-b216-5b5d62c5908f" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/86d1346a-98ec-4de0-aad4-ba147ddd38c9" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/1b3c37e6-6c9e-48a2-b11a-cfbed0ac2450" width="300" height="1000" />

<img src="https://github.com/user-attachments/assets/436eaecc-8cfb-42c2-8097-02d7992b8e58" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/06f6ffd4-885e-4753-8b3f-343926c107a6" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/c0fb5555-e721-47ad-a952-d2bc41cf6f5a" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/7b452e19-aa51-4cbe-a503-5e91960de686" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/000d9145-0400-43ea-b862-f126daa3f80f" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/e962163d-0d56-4705-9015-2fcd029163c9" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/a0b39891-531d-4376-be73-4a1e0a2cadd7" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/cd74a721-f842-4c8a-8a3f-8b2f551ac5b0" width="300" height="1000" />


The app is structured around a **Bottom Navigation Bar** with five main screens:
- **Home Screen**
- **Wishlist Screen**
- **Chat Screen**
- **Cart Screen**
- **Profile Screen**

## Tech Stack
- **Flutter**: Framework for building the app.
- **REST API**: Data is fetched from [FakeStoreAPI](https://fakestoreapi.com/products).
- **Firebase**: For user authentication (Firebase Auth) and storing user-specific data (Firestore).
- **Provider**: For state management following the MVVM pattern.
- **SharedPreferences**: To store user preferences like cart, wishlist, and theme.
- **Shimmer Effects**: To enhance the user experience with smooth loading indicators.

## Features

### 1. **Authentication**:
- **Signup**: Users can sign up using their email and password.
- **Login**: Users can log in with their credentials.
- **Password Recovery**: Users can recover their password via email.
- **Sign Out**: Users can log out of their account.

### 2. **Home Screen**:
The **Home Screen** displays various sections, including:
- **Categories Section**: Displays product categories. Clicking on a category navigates to the respective category screen, where users can filter products based on categories.
- **Most Popular Section**: Displays the most popular products.
- **Sales Section**: Displays products on sale.
- **New Items Section**: Shows newly added products.
- **Just For You Section**: Personalized product recommendations.
- Clicking on a product in any of these sections takes the user to the **Product Detail Screen**.

### 3. **Product Detail Screen**:
On the **Product Detail Screen**, users can:
- View detailed information about the product (images, description, price).
- Add the product to the cart.
- Add the product to the wishlist.
- Purchase the product directly.

### 4. **Wishlist Screen**:
The **Wishlist Screen** displays products that the logged-in user has added to their wishlist. Users can:
- Remove items from the wishlist.
- View product details by tapping on the product.

### 5. **Cart Screen**:
The **Cart Screen** displays products that the user has added to the cart. Users can:
- Increase or decrease the quantity of items in the cart.
- Remove items from the cart.
- Proceed to checkout.

### 6. **Firestore Integration**:
- All user data (cart, wishlist) is stored in **Firestore** based on the user’s unique ID. Each user’s data is isolated, ensuring that one user cannot manipulate another user’s data.

### 7. **Shimmer Effects**:
Shimmer effects are added to all screens, providing a smooth loading experience while data is being fetched or processed.

### 8. **Error Handling**:
Error handling is implemented across the app, ensuring users receive appropriate messages for network issues, authentication errors, and other exceptions.
