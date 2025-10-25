# **E-Shop Flutter E-commerce App**

**Project Brief Summary**:  
E-Shop is a feature-rich Flutter-based e-commerce app designed to offer a seamless shopping experience. It integrates Firebase authentication, a caching mechanism for optimized performance, and advanced features such as AI-powered product recommendations and session management for user data security.
## Project Structre Well organized project
<img width="1696" height="1023" alt="image" src="https://github.com/user-attachments/assets/2757e9cf-98d6-416d-9514-cc7cb79afade" />
**Tech Stack:**

- **Flutter**: Framework for building the app.
- **REST API**: Data is fetched from [FakeStoreAPI](https://fakestoreapi.com/).
- **Firebase**: User authentication (Firebase Auth) and storing user-specific data (Firestore).
- **Provider**: State management following the MVVM pattern.
- **SharedPreferences**: Store user preferences like cart, wishlist, and theme.
- **Shimmer Effects**: Smooth loading indicators to enhance UX.
- **Caching**: To reduce redundant API calls and improve performance.

## **App Structure**

The app uses a Bottom Navigation Bar with five main screens:

- **Home Screen**
- **Wishlist Screen**
- **Chatbot Screen**
- **Cart Screen**
- **Profile Screen**

## **Features**

### **Authentication**
- **Sign Up**: Users can sign up using their email and password.
- **Log In**: Users can log in with their credentials.
- **Password Recovery**: Users can recover their password via email.
- **Sign Out**: Users can log out of their account.

### **Home Screen**
The Home Screen displays various sections, including:
- **Categories Section**: Displays product categories. Users can click to navigate to the respective category and filter products based on categories.
- **Most Popular Section**: Displays the most popular products.
- **Sales Section**: Displays products on sale.
- **New Items Section**: Shows newly added products.
- **Just For You Section**: Personalized product recommendations based on user activity.

### **Product Detail Screen**
On this screen, users can:
- View detailed information about the product (images, description, price).
- Add the product to their cart or wishlist.
- Purchase the product directly.

### **Wishlist Screen**
The Wishlist Screen displays products the user has added to their wishlist. Users can:
- Remove items from the wishlist.
- View product details by tapping on the product.

### **Cart Screen**
The Cart Screen displays products that the user has added to their cart. Users can:
- Increase or decrease the quantity of items in the cart.
- Remove items from the cart.
- Proceed to checkout.

### **Firestore Integration**
All user data (cart, wishlist) is stored in Firestore based on the user’s unique ID. Data is isolated, ensuring each user's data is private.

### **Shimmer Effects**
Smooth shimmer effects are applied to all screens to enhance user experience while data is being fetched.

### **Error Handling**
Robust error handling ensures users receive appropriate feedback on network issues, authentication errors, and other exceptions.

## **Caching Mechanism**

### **Before Optimization:**
1. User opens the app and fetches 50 products (New Items).
2. User scrolls down and fetches 100 products (Top Products).
3. User scrolls more and fetches 100 products (Popular Items).
4. User searches for "phone" and fetches 100 products again.
5. User navigates to category and fetches products again.

**Total API Calls**: 5-10+ calls  
**Total Data Fetched**: 500+ products (mostly duplicates!)

### **After Caching:**
1. User opens the app and fetches 100 products once, storing them in memory.
2. User scrolls down and uses the cached data, no additional API calls.
3. User scrolls more and uses the cached data.
4. User searches for "phone" and filters cached data.
5. User navigates to category and filters cached data.

**Total API Calls**: 1 call  
**Total Data Fetched**: 100 products  
**Performance**: 10x faster! 🚀

## **Search & Advanced Filters**
- Users can now perform advanced searches with filters based on categories, price, ratings, and more.  
- The search results screen displays filtered products instantly from the cached data, ensuring a seamless experience.

## **AI Assistant Integration**
- The AI Assistant helps users find products based on their preferences and provides suggestions in real-time.

## **User Session Handling**
- **User Session Management**: Ensures that each user has a unique session after logging in. This session persists throughout the app and ensures that users stay logged in until they explicitly sign out.
- **Authenticated Users**: The app manages authenticated users, ensuring that only signed-in users can access their cart, wishlist, and profile data.
- **Session Expiry**: Automatically logs out users after a set period of inactivity to ensure security.
- **Session Management Benefits**: Enhances security, personalization, and smooth user experience by maintaining user context across screens.

## **Project Demo**
### ***Watch Demo Video***
https://drive.google.com/file/d/1Jqb82D0n7l5m4Q-ozyQo3W1Hh-tjewVU/view?usp=drivesdk

## **App Screenshots**
### ***Login, Signup AND Welcome Screen***

<img src="https://github.com/user-attachments/assets/d50c1879-4876-4e67-beac-86e1b1c69d85" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/b3fd46ca-77ba-4ada-800e-582dd1910c25" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/fc27c90c-fafd-4e03-aff9-79edaf63686f" width="300" height="1000" />

### ***Home Screen***


<img src="https://github.com/user-attachments/assets/1a92616d-97af-4667-8a25-1744d3a4ae25" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/685f5efb-f311-41f8-b6d9-a6cd829a7bf1" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/133004ec-9b12-4f5f-8130-cf21161a7303" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/1c178637-ba7e-4771-8d59-daa8a7c6cea0" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/a61b5e97-6262-4183-b682-57c8a8644279" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/5f504e99-bbee-419e-a279-80d9fcd9a7f2" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/16df9c12-58c1-4caa-a375-bd4c0293d5c3" width="300" height="1000" />


### ***WishList Screen***
<img src="https://github.com/user-attachments/assets/a7b27a60-6f1e-4e24-ada2-6ab6dbaa9034" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/a3fea662-0bf7-4aa5-908a-09f0e96ef527" width="300" height="1000" />

### ***Chatbot Screen***
<img src="https://github.com/user-attachments/assets/b265b4fc-d1e4-4148-a007-19a9d6a563bc" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/900f8112-eed8-41a0-8506-42c2f04bc263" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/2eac7c53-515d-40e8-b7c8-945c9de272d4" width="300" height="1000" />


### ***Cart Screen***

<img src="https://github.com/user-attachments/assets/a9960377-391d-4d21-99ac-5a4bdf8c3429" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/c2e41ccc-80ed-44a9-93ef-1a216d602fa5" width="300" height="1000" />


### ***Profile Screen***
<img src="https://github.com/user-attachments/assets/2876056b-a391-4b93-b48f-664b4ca6124a" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/e68c5366-5855-4413-bec5-52254ab90aa4" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/640ef9b7-5d93-41f7-9eb8-5155414cd54a" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/205e9874-7e21-4212-9b93-1cf267601f08" width="300" height="1000" />


### ***All Categoires ,New Item , Flash Sale,  Most Popular Nested-Screen***

<img src="https://github.com/user-attachments/assets/1e007347-d64c-4e0c-af68-05c06df88b93" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/515fcf22-464e-46dc-9b67-df9903a108ba" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/a9c7a27f-1a4f-45dc-9405-e5d4ca24bdc8" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/bcd21a1d-9f5c-4e46-bb13-8f2d94aeed12" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/af8cb204-fb76-469f-bb6c-a52d47e9b882" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/7f6e0a83-5246-4cd5-b501-61bc3169f99a" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/db47f016-ff3c-4339-be26-03dc253b3899" width="300" height="1000" />

### ***Product Detail Screen***
<img src="https://github.com/user-attachments/assets/5aecc690-7a65-4667-bb94-144b0e739780" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/c3cb50fe-59bd-4f39-8678-a4f1c8006e90" width="300" height="1000" />


### ***Advanced Filter And Search Result Screen***
<img src="https://github.com/user-attachments/assets/16a1b8ce-f442-4b42-861f-a01e3871ab90" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/4368a857-2809-40aa-b5f2-12d5318e4d89" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/26a96248-9218-435a-8b54-747130bf2b40" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/06ddba97-09fd-40a0-8f84-362098773e9a" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/e934259b-1e1b-491b-ad8d-81572f39ee9c" width="300" height="1000" />



### *** App ScreenShots with Light THeme**

<img src="https://github.com/user-attachments/assets/bda3e3df-e669-4461-a338-58d68422313d" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/70e67ac2-a12e-4c5f-b245-4d97099be9a3" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/f6ee27ea-a1db-4bf9-b5c0-889526119e60" width="300" height="1000" />

<img src="https://github.com/user-attachments/assets/032a437f-e9f6-4cda-b270-83b7666f84a7" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/21679b64-77c2-40ff-8561-a54fb106ad3a" width="300" height="1000" />
<img src="https://github.com/user-attachments/assets/6ccdfdf6-6615-4ded-8788-ec39aafd4032" width="300" height="1000" />







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

## **Setup and Installation**

1. **Clone the repository**:  
   `git clone [https://github.com/Abasalat/Ecommerce-App.git]`

2. **Install dependencies**:  
   Run `flutter pub get` to install required packages.

3. **Run the app**:  
   Use `flutter run` to launch the app on your preferred device or emulator.

## **Contributions**

Contributions are welcome! Please fork the repository, create a new branch, and submit a pull request. Ensure you follow the coding standards, write clean code, and document any new features.

---

**Why this is good:**

- **Optimized User Experience**: By caching data, we've reduced redundant API calls, speeding up the app and ensuring a smoother experience for users.
- **Robust Session Management**: The user session handling ensures that only authenticated users can access their data, offering enhanced security.
- **Seamless Performance**: The use of advanced filters and AI Assistant improves product discovery, helping users find exactly what they need.
- **Scalable**: The app is built to handle growing product lists and user data with optimized performance, caching, and state management.

