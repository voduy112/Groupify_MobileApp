**Groupify_MobileApp** là một hệ sinh thái ứng dụng quản lý nhóm học tập, bao gồm:

- Ứng dụng di động (Flutter)
- Backend API (Node.js/Express)
- Dashboard quản trị (Vue.js + TailwindCSS)

## Mục lục

- [Kiến trúc tổng quan](#kiến-trúc-tổng-quan)
- [Hướng dẫn cài đặt & chạy từng thành phần](#hướng-dẫn-cài-đặt--chạy-từng-thành-phần)
  - [1. Mobile App (Flutter)](#1-mobile-app-flutter)
  - [2. Backend API (Nodejsexpress)](#2-backend-api-nodejsexpress)
  - [3. Dashboard (Vue.js + TailwindCSS)](#3-dashboard-vuejs--tailwindcss)
- [Liên hệ & đóng góp](#liên-hệ--đóng-góp)

---

## Kiến trúc tổng quan

```
Groupify_MobileApp/
│
├── app/                   # Ứng dụng di động Flutter
├── api/                   # Backend Node.js/Express (REST API, WebSocket)
├── vue-tailwind-dashboard/ # Dashboard quản trị (Vue.js + TailwindCSS)
└── ...
```

- **app/**: Ứng dụng di động, hỗ trợ đa nền tảng (Android, iOS, Web, Desktop).
- **api/**: Backend RESTful API, quản lý dữ liệu nhóm, người dùng, tài liệu, ... (MongoDB, Socket.io, Cloudinary, ...).
- **vue-tailwind-dashboard/**: Dashboard web cho admin/giáo viên quản lý nhóm, người dùng, thống kê.

---

## Hướng dẫn cài đặt & chạy từng thành phần

### 1. Mobile App (Flutter)

**Yêu cầu:**

- Flutter SDK (>=3.x)
- Dart SDK

**Cài đặt & chạy:**

```bash
cd app
flutter pub get
flutter run
```

> Có thể chạy trên Android/iOS/Web/Windows/Mac/Linux tùy thiết bị.

---

### 2. Backend API (Node.js/Express)

**Yêu cầu:**

- Node.js >= 16.x
- MongoDB (local hoặc cloud)
- Tạo file `.env` theo mẫu `.env.example` (nếu có)

**Cài đặt & chạy:**

```bash
cd api
npm install
npm start
```

> Server sẽ chạy mặc định trên cổng 3000 (hoặc theo cấu hình).

---

### 3. Dashboard (Vue.js + TailwindCSS)

**Yêu cầu:**

- Node.js >= 16.x

**Cài đặt & chạy:**

```bash
cd vue-tailwind-dashboard
npm install
npm run serve
```

> Dashboard sẽ chạy trên cổng 8080 (hoặc theo cấu hình).

---

## Liên hệ & đóng góp

- Đóng góp code, báo lỗi hoặc ý tưởng mới qua GitHub Pull Request/Issue.
- Liên hệ nhóm phát triển qua email hoặc các kênh liên lạc nội bộ.

---

**Chúc bạn sử dụng và phát triển hệ thống Groupify_MobileApp hiệu quả!**

## Deployment

| Thành phần         | Link Production/Demo                | Ghi chú                |
|--------------------|-------------------------------------|------------------------|
| Mobile App (Flutter) | https://drive.google.com/drive/folders/1f2BDn86rETlZ-laRVSgIkR14aictSpcL?usp=sharing | Có thể build APK |
| Backend API        | [https://groupifymobileapp-production.up.railway.app](https://groupifymobileapp-production.up.railway.app) | REST API server |
| Dashboard          | [https://groupifyad.netlify.app/login](https://groupifyad.netlify.app/login) | Dashboard quản trị |

## Screenshots

<img src="https://github.com/user-attachments/assets/d88ceab8-6c2e-48d6-8159-a3bbbe31b440" width="400"/>

<img src="https://github.com/user-attachments/assets/d3cc517b-8ab3-42b4-b438-462cdcfeb28b" width="400"/>

<img src="https://github.com/user-attachments/assets/d1f56189-652a-4395-9a66-718dc1b8fc0c" width="400"/>

<img src="https://github.com/user-attachments/assets/0f59db49-39a1-472e-84e1-d4ee75ec0506" width="400"/>

<img src="https://github.com/user-attachments/assets/45832e30-7dc4-4885-a9cc-da628810450b" width="400"/>

<img src="https://github.com/user-attachments/assets/24c3513e-4c0b-4833-ac3a-1ced08e071dc" width="400"/>

<img src="https://github.com/user-attachments/assets/7efc6ad2-f44f-4886-a226-cde7b619f362" width="400"/>

<img src="https://github.com/user-attachments/assets/df01d10f-bc8e-4ca4-9e82-35736aa4a9da" width="400"/>

<img src="https://github.com/user-attachments/assets/dc72b012-d7e3-464c-9113-2ee0909e89f6" width="400"/>

<img src="https://github.com/user-attachments/assets/9e0aae0b-4178-4afa-981b-ee4d1d38e907" width="400"/>

<img src="https://github.com/user-attachments/assets/1b8979bc-3358-497a-a01b-15b2f86ccea8" width="400"/>







